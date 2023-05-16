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
  }
}

output "verified_access_configuration" {
  value = {
    issuer				   = "https://${var.keycloak_domain}/realms/master"
    authorization_endpoint = "https://${var.keycloak_domain}/realms/master/protocol/openid-connect/auth"
    token_endpoint		   = "https://${var.keycloak_domain}/realms/master/protocol/openid-connect/token"
    user_endpoint		   = "https://${var.keycloak_domain}/realms/master/protocol/openid-connect/userinfo"
    client_id			   = keycloak_openid_client.this.client_id
    client_secret		   = "<Get from SSM parameter: ${aws_ssm_parameter.keycloak_client_id_client_secret.name}>"
    scope				   = "openid, email"
  }
}