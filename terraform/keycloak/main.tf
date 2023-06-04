locals {
  name = "va"
}

data "aws_ssm_parameter" "keycloak_admin_credentials" {
  name = var.keycloak_admin_credentials_ssm_parameter_name
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
  web_origins                                = ["*"]

  # Other
  extra_config = {}
}

resource "aws_ssm_parameter" "keycloak_client_id_client_secret" {
  name  = "${local.name}-keycloak-client-id-client-secret"
  type  = "StringList"
  value = "${keycloak_openid_client.this.client_id},${keycloak_openid_client.this.client_secret}"
}

# Scope
resource "keycloak_openid_client_scope" "this" {
  realm_id               = keycloak_openid_client.this.realm_id
  name                   = "groups"
  description            = "When requested, this scope will map a user's group memberships to a claim"
  include_in_token_scope = true
  gui_order              = 1
}

resource "keycloak_openid_group_membership_protocol_mapper" "this" {
  realm_id  = keycloak_openid_client.this.realm_id
  client_scope_id = keycloak_openid_client_scope.this.id
  name      = "group-membership-mapper"

  claim_name = "groups"
}

resource "keycloak_openid_client_default_scopes" "this" {
  realm_id  = keycloak_openid_client.this.realm_id
  client_id = keycloak_openid_client.this.id

  default_scopes = [
    "acr",
    "profile",
    "email",
    "roles",
    "web-origins",
    keycloak_openid_client_scope.this.name,
  ]
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

# Test user 3
resource "keycloak_user" "not_verified_noah" {
  realm_id   = keycloak_openid_client.this.realm_id
  username   = "not_verified_noah"
  email = "not.verified.noah@serverless-budapest.com"
  email_verified = false

  first_name = "Not Verified"
  last_name  = "Noah"

  initial_password {
    value = random_password.keycloak_not_verified_noah.result
  }
}

resource "random_password" "keycloak_not_verified_noah" {
  length  = 30
  special = false
}

resource "aws_ssm_parameter" "keycloak_not_verified_noah_credentials" {
  name  = "${local.name}-keycloak-not-verified-noah-credentials"
  type  = "StringList"
  value = "${keycloak_user.not_verified_noah.username},${random_password.keycloak_not_verified_noah.result}"
}

# Groups
resource "keycloak_group" "manager" {
  realm_id = keycloak_openid_client.this.realm_id
  name     = "manager"
}

resource "keycloak_group_memberships" "manager" {
  realm_id = keycloak_openid_client.this.realm_id
  group_id = keycloak_group.manager.id

  members  = [
    keycloak_user.manager_mario.username,
    keycloak_user.not_verified_noah.username
  ]
}

resource "keycloak_group" "engineer" {
  realm_id = keycloak_openid_client.this.realm_id
  name     = "engineer"
}

resource "keycloak_group_memberships" "engineer" {
  realm_id = keycloak_openid_client.this.realm_id
  group_id = keycloak_group.engineer.id

  members  = [
    keycloak_user.engineer_emma.username
  ]
}