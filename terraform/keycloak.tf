provider "keycloak" {
  client_id                = "admin-cli"
  username                 = var.keycloak_username
  password                 = random_password.keycloak.result
  url                      = "https://${aws_lb.keycloak_alb.dns_name}"
  tls_insecure_skip_verify = true
}

resource "keycloak_openid_client" "this" {
  realm_id  = "master"

  name      = "AWS Verified Access application"
  client_id = "aws-verified-access-application"

  # Capability config
  access_type           = "CONFIDENTIAL"
  standard_flow_enabled = true
  implicit_flow_enabled = true
  direct_access_grants_enabled = true

  # Login settings
  root_url = "https://${var.application_domain}"
  base_url = "https://${var.application_domain}" // Home URL
  valid_redirect_uris                        = ["*"]
  web_origins                                = ["*", "/*"]

  # Other
  extra_config = {}
}

resource "aws_ssm_parameter" "keycloak_client_id_client_secret" {
  name  = "${local.name}-keycloak-client-id-client-secret"
  type  = "StringList"
  value = "${keycloak_openid_client.this.client_id},${keycloak_openid_client.this.client_secret}"
}

# Test user 1
resource "keycloak_user" "engineer_emma" {
  realm_id   = keycloak_openid_client.this.realm_id
  username   = "engineer_emma"
  email = "engineer.emma@serverless-budapest.com"
  email_verified = true

  first_name = "Engineer"
  last_name  = "Emma"

  initial_password {
    value = random_password.keycloak_engineer_emma.result
  }
}

resource "random_password" "keycloak_engineer_emma" {
  length  = 30
  special = false
}

resource "aws_ssm_parameter" "keycloak_engineer_emma_credentials" {
  name  = "${local.name}-keycloak-engineer-emma-credentials"
  type  = "StringList"
  value = "${keycloak_user.engineer_emma.username},${random_password.keycloak_engineer_emma.result}"
}

# Test user 2
resource "keycloak_user" "manager_mario" {
  realm_id   = keycloak_openid_client.this.realm_id
  username   = "manager_mario"
  email = "manager.mario@serverless-budapest.com"
  email_verified = true

  first_name = "Manager"
  last_name  = "Mario"

  initial_password {
    value = random_password.keycloak_manager_mario.result
  }
}

resource "random_password" "keycloak_manager_mario" {
  length  = 30
  special = false
}

resource "aws_ssm_parameter" "keycloak_manager_mario_credentials" {
  name  = "${local.name}-keycloak-manager-mario-credentials"
  type  = "StringList"
  value = "${keycloak_user.manager_mario.username},${random_password.keycloak_manager_mario.result}"
}