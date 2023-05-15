# AWS Verified Access and Keycloak

This is an example AWS infrastructure that integrates Verified Access with 
Keycloak authentication and makes a private backend application accessible.

With AWS Verified Access, you can provide secure access to your applications 
without requiring the use of a virtual private network (VPN). Verified Access 
evaluates each application request and helps ensure that users can access 
each application only when they meet the specified security requirements.

## Deployment

- Run terraform apply from the terraform folder
- Manually create a CNAME record for the FQDN with the DNS name of the Keycloak Loadbalancer