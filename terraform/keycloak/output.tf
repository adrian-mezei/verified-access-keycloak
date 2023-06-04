output "keycloak_users" {
  value = {
    (nonsensitive(split(",", data.aws_ssm_parameter.keycloak_admin_credentials.value)[0])) = {
      username = nonsensitive(split(",", data.aws_ssm_parameter.keycloak_admin_credentials.value)[0])
      password = "<Get from SSM parameter: ${data.aws_ssm_parameter.keycloak_admin_credentials.name}>"
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

output "va_trust_provider_information" {
  value =  {
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