# Configure ASA Baseline for deployment, set required parameters in the parameters.tf file.
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
- Modify AzureRM Backend env settings in deploy_baseline.yml file
  TFSTATE_RG: <YOUR TFSTATE RG>
  STORAGEACCOUNTNAME: <YOUR TF STATE STORAGE ACCOUNT>
  CONTAINERNAME: <YOU TF STATE CONTAINER NAME>
