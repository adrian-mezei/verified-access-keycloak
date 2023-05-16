variable "keycloak_listener_certificate_arn" {
  type = string
  description = "The ACM certificate ARN of the domain name for the ALB in front of Keycloak."
}

variable "application_listener_certificate_arn" {
  type = string
  description = "The ACM certificate ARN of the domain name for the ALB in front of the application."
}

variable "keycloak_username" {
  type = string
  default = "admin"
  description = "The username of the Keycloak amin user."
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