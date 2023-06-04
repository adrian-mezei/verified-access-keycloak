variable "keycloak_admin_credentials_ssm_parameter_name" {
  type = string
  default = "va-keycloak-admin-credentials"
  description = "The SSM parameter name where the username and password of the Keycloak amin user is stored."
}

variable "keycloak_domain" {
  type = string
  default = "keycloak.serverless-budapest.com"
  description = "The FQDN where the integrated application will be accessible."
}

variable "application_domain" {
  type = string
  default = "app.serverless-budapest.com"
  description = "The FQDN where the integrated application will be accessible."
}