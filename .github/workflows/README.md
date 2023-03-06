# Deploy ASA Baseline
- This github action will deploy the ASA Baseline deployment, terraform and configuration options can be found here:
   [ASA Baseline deployment](../../Scenarios/ASA-Secure-Baseline/README.md)

# Configure Github Actions for Terraform
- Service Principle
  - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret.html

- Create the following Github Action Secrets - Obtained from creating service principle above
  - AZURE_CLIENT_ID
  - AZURE_CLIENT_SECRET
  - AZURE_SUBSCRIPTION_ID
  - AZURE_TENANT_ID
  
# Configure Action to Deploy to your Spring Apps Service Instance
- Create and set secrets for the admin passwords for jump box and mysql
  - JUMP_BOX_PASSWORD
  - MYSQL_ADMIN_PASSWORD

# Deploying and Destroying
- The default setting for SHOULD_DESTROY is set to true, this will automatically clean up all resources.
- Set this to SHOULD_DESTROY: 'false' to maintain the deployment for testing 

# Deploying options
- If you would like to deploy the Azure firewall for outbound connection set the SHOULD_DEPLOY_FIREWALL: true

# Testing the Petclinic deployment
- The default deployment of petclinic is only accessible from with in the private network that is deployed by the Baseline deployment
  - If you would like to make this publicly available you can additionally configure and run the "Deploy Firewall" steps in Baseline terraform folder 
- In order to test the deployment, you must log into the jump box via bastion
- Copy the private URL for the api-gateway app instance in the spring apps deployment
- Load the pet clinic app from Edge browser in the jumpbox
  