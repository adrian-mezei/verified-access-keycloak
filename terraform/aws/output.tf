output "keycloak_lb_dns_name" {
  value = aws_lb.keycloak_alb.dns_name
}

output "verified_access_configuration" {
  value = {
    group = {
      policy = <<-EOT
        permit(principal,action,resource)
        when {
            context.keycloak.email_verified == true
        };
      EOT
    }
    endpoint = {
      application_details = {
        application_domain          = var.application_domain
        application_certificate_arn = var.application_listener_certificate_arn
      }
      endpoint_details = {
        attachment_type = "VPC"
        security_groups = aws_security_group.va_endpoint.name
        endpoint_domain_prefix = split(".", var.application_domain)[0]
        endpoint_type = "Load balancer"
        protocol = "HTTPS"
        port = 443
        loadbalancer_arn = aws_lb.application_alb.arn
        subnet = aws_subnet.application.*.arn
      }
      policy = <<-EOT
        permit(principal,action,resource)
        when {
            context.keycloak.groups.contains("/manager")
        };
      EOT
    }
  }
}