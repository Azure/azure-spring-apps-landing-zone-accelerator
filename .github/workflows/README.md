# Deploy ASA Baseline
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
- Modify SPRING_APPS_SERVICE_NAME, KEY_VALUT_NAME in pet-clinic-workload.yml file
  - These are created by the baseline deployment
  
- Modify AzureRM Backend env settings in pet-clinic-workload.yml file