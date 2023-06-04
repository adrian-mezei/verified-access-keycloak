# Security group
resource "aws_security_group" "va_endpoint" {
  name        = "${local.name}-va-endpoint-sg"
  vpc_id      = aws_vpc.this.id
}

resource "aws_vpc_security_group_egress_rule" "va_endpoint" {
  security_group_id = aws_security_group.va_endpoint.id

  referenced_security_group_id = aws_security_group.application_alb.id
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

# Cloud Watch LG for access logs
resource "aws_cloudwatch_log_group" "va_access_logs" {
  name = "/aws/va/${local.name}-access-logs-cw-lg"
}