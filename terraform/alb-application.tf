resource "aws_lb" "application_alb" {
  name               = "${local.name}-application-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.application_alb.id]
  subnets            = aws_subnet.application[*].id

  tags = { Name = "${local.name}-application-subnet" }
}

# Security group
resource "aws_security_group" "application_alb" {
  name        = "${local.name}-application-alb-sg"
  vpc_id      = aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "application_alb" {
  security_group_id = aws_security_group.application_alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "application_alb" {
  security_group_id = aws_security_group.application_alb.id

  referenced_security_group_id = aws_security_group.application_lambda.id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

# Target group, listener
resource "aws_lb_listener" "application_alb" {
  load_balancer_arn = aws_lb.application_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.application_listener_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application_alb.arn
  }

  lifecycle {
    replace_triggered_by = [aws_lb_target_group.application_alb]
  }
}

resource "aws_lb_target_group" "application_alb" {
  name     = "${local.name}-application-alb-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.this.id
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "application_alb" {
  target_group_arn = aws_lb_target_group.application_alb.arn
  target_id        = aws_lambda_function.this.arn

  depends_on       = [aws_lambda_permission.this]
}