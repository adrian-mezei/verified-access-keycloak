terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.67.0"
    }
    keycloak = {
      source  = "mrparkers/keycloak"
      version = "= 4.2.0"
    }
  }
  required_version = ">= 1.3.5"
}
