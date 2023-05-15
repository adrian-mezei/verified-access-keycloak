resource "aws_lb" "keycloak_alb" {
  name               = "${local.name}-keycloak-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.keycloak_alb.id]
  subnets            = aws_subnet.keycloak[*].id

  tags = { Name = "${local.name}-application-subnet" }
}

# Security group
resource "aws_security_group" "keycloak_alb" {
  name        = "${local.name}-keycloak-alb-sg"
  vpc_id      = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "keycloak_alb" {
  security_group_id = aws_security_group.keycloak_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "keycloak_alb" {
  security_group_id = aws_security_group.keycloak_alb.id

  referenced_security_group_id = aws_security_group.keycloak_instance.id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

# Target group, listener
resource "aws_lb_listener" "keycloak_alb" {
  load_balancer_arn = aws_lb.keycloak_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.keycloak_listener_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.keycloak_alb.arn
  }
}

resource "aws_lb_target_group" "keycloak_alb" {
  name     = "${local.name}-keycloak-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id
}

resource "aws_lb_target_group_attachment" "keycloak_alb" {
  target_group_arn = aws_lb_target_group.keycloak_alb.arn
  target_id        = aws_instance.keycloak.id
  port             = 80
}