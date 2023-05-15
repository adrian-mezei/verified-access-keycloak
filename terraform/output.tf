output "keycloak_lb_dns_name" {
  value = aws_lb.keycloak_alb.dns_name
}