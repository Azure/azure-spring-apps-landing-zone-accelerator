# Create the Shared Resources 

The following will be created:
* Resource Group for Shared Components (main.tf)
* Log Analytics Workspace (log_analytics_workspace.tf)
* Azure Key Vault with a Private Endpoint (key_vault.tf)
* Virtual Machine for testing the application/s (jump_host.tf)

Provide a username and password for the Virtual Machine.

Review and if needed, comment out and modify the variables within the "Optional - 04 Shared - Jumpbox" section of the common variable definitons file [parameters.tfvars](./parameters.tfvars). 

Sample:

```bash
##################################################
## Optional - 04 Shared - Jumpbox
##################################################
# The Jumpbox username defaults to "lzadmin"
# The Jumpbox password defaults to a Random password and stored to the KeyVault
# under the Jumpbox-Pass secret
# My_External_IP will be automatically calculated unless you specify it here.

    jump_host_admin_username = "lzadmin"
    jump_host_password       = "xxxxxx"    # You can optionally provide this via command line

    # jump_host_vm_size = "Standard_DS3_v2"
    # My_External_IP = "1.2.3.4/32"

```

If you do not wish to deploy the Virtual machine for testing, remove the jump_host.tf file from the directory


## Deploy the Shared resources

Navigate to the "/Scenarios/ASA-Secure-Baseline/Terraform/04-LZ-SharedResources" directory. 

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