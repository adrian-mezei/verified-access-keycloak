# AWS Verified Access and Keycloak

This is an example AWS infrastructure that integrates Verified Access with 
Keycloak authentication and makes a private backend application accessible.

With AWS Verified Access, you can provide secure access to your applications 
without requiring the use of a virtual private network (VPN). Verified Access 
evaluates each application request and helps ensure that users can access 
each application only when they meet the specified security requirements.

## Deployment

- Run `npm i` and `npm run bundle` in the backend folder
- Run `terraform apply` from the `terrafor/aws` folder (provide required input or create terraform.tfvars)
- Manually create a CNAME record for the Keycloak FQDN with the DNS name of the Keycloak Load Balancer
- Run `terraform apply` from the `terrafor/keycloak` folder (provide required input or create terraform.tfvars)
- Configure Verified Access based on terraform output
- Manually create a CNAME record for the application FQDN with the DNS name of the Verified Access Endpoint

