provider "keycloak" {
  client_id                = "admin-cli"
  username                 = split(",", data.aws_ssm_parameter.keycloak_admin_credentials.value)[0]
  password                 = split(",", data.aws_ssm_parameter.keycloak_admin_credentials.value)[1]
  url                      = "https://${var.keycloak_domain}"
  tls_insecure_skip_verify = true
}