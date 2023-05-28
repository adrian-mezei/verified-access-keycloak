output "keycloak_lb_dns_name" {
  value = aws_lb.keycloak_alb.dns_name
}

output "keycloak_users" {
  value = {
    (var.keycloak_username) = {
      username = var.keycloak_username
      password = "<Get from SSM parameter: ${aws_ssm_parameter.keycloak_admin_credentials.name}>"
    }
    engineer_emma = {
      username = keycloak_user.engineer_emma.username
      password = "<Get from SSM parameter: ${aws_ssm_parameter.keycloak_engineer_emma_credentials.name}>"
    }
    manager_mario = {
      username = keycloak_user.manager_mario.username
      password = "<Get from SSM parameter: ${aws_ssm_parameter.keycloak_manager_mario_credentials.name}>"
    }
    not_verified_noah = {
      username = keycloak_user.not_verified_noah.username
      password = "<Get from SSM parameter: ${aws_ssm_parameter.keycloak_not_verified_noah_credentials.name}>"
    }
  }
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
    trust_provider = {
      trust_provider_information = {
        policy_reference_name    = "keycloak"
        trust_provider_type      = "User trust provider"
        user_trust_provider_type = "OIDC"
        issuer                   = "https://${var.keycloak_domain}/realms/master"
        authorization_endpoint   = "https://${var.keycloak_domain}/realms/master/protocol/openid-connect/auth"
        token_endpoint           = "https://${var.keycloak_domain}/realms/master/protocol/openid-connect/token"
        user_endpoint            = "https://${var.keycloak_domain}/realms/master/protocol/openid-connect/userinfo"
        client_id                = keycloak_openid_client.this.client_id
        client_secret            = "<Get from SSM parameter: ${aws_ssm_parameter.keycloak_client_id_client_secret.name}>"
        scope                    = "openid, email"
      }
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