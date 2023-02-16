# Create the Shared Resources 

The following will be created:
* Resource Group for Shared Components (main.tf)
* Log Analytics Workspace (log_analytics_workspace.tf)
* Azure Key Vault with a Private Endpoint (key_vault.tf)
* Virtual Machine for testing the application/s (jump_host.tf)
* Luis add infor here on the IP firewall rule on KeyVault

Review and if needed, comment out and modify the variables within the "Optional - 04 Shared - Jumpbox" section of the common variable definitons file [parameters.tfvars](./parameters.tfvars). 

If you do not wish to deploy the Virtual machine for testing, remove the jump_host.tf file from the directory

## Deploy the Shared resources

Navigate to the "/Scenarios/ASA-Secure-Baseline-/Terraform/04-LZ-SharedResources" directory. 

```bash
cd ../04-LZ-SharedResources
```

Deploy using Terraform Init, Plan and Apply

```bash
terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"
```

```bash
terraform plan -out my.plan --var-file ../parameters.tfvars
```

```bash
terraform apply my.plan
```

### Next step

:arrow_forward: [Deploy the Azure Firewall Resource](./05-Hub-Firewall.md)