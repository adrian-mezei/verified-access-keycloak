# EC2 instance
resource "aws_instance" "keycloak" {
  ami                         = data.aws_ami.amazon_linux_2.image_id
  instance_type               = "t3.micro"
  iam_instance_profile        = aws_iam_instance_profile.keycloak_instance.id
  subnet_id                   = aws_subnet.keycloak[0].id
  vpc_security_group_ids      = [aws_security_group.keycloak_instance.id]
  associate_public_ip_address = true

  user_data_replace_on_change = true
  user_data                   = <<-EOL
    #!/bin/bash -xe
    yum update

    yum install docker -y
    useradd ssm-user
    usermod -aG docker ssm-user
    systemctl enable docker.service
    systemctl start docker.service

    docker run --restart=always -p 80:8080 -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=${random_password.keycloak.result} -e KC_PROXY=passthrough -d quay.io/keycloak/keycloak:21.0.2 start-dev
  EOL

  tags = { Name = "${local.name}-keycloak-instance" }
}

resource "aws_ssm_parameter" "keycloak_credentials" {
  name  = "${local.name}-keycloak-credentials"
  type  = "StringList"
  value = "admin,${random_password.keycloak.result}"
}

resource "random_password" "keycloak" {
  length  = 30
  special = false
}

# Instance profile
resource "aws_iam_role" "keycloak_instance" {
  name               = "${local.name}-keycloak-instance-iam-role"
  assume_role_policy = data.aws_iam_policy_document.keycloak_instance.json
}

data "aws_iam_policy_document" "keycloak_instance" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "keycloak_instance" {
  role       = aws_iam_role.keycloak_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "keycloak_instance" {
  name = "${local.name}-keycloak-instance-profile"
  role = aws_iam_role.keycloak_instance.name
}

# Security group
resource "aws_security_group" "keycloak_instance" {
  name        = "${local.name}-keycloak-instance-sg"
  vpc_id      = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "keycloak_instance" {
  security_group_id = aws_security_group.keycloak_instance.id

  referenced_security_group_id = aws_security_group.keycloak_alb.id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "keycloak_instance" {
  security_group_id = aws_security_group.keycloak_instance.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}