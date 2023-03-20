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

    # jump_host_admin_username = "lzadmin"
    
    # jump_host_password ="xxxxxx"
    # Note: 
    # It is recommended to pass jump_host_password # as an environment variable
    # and not stored on the parameters file.
    # Example:
    # If using PowerShell
    #    $ENV:TF_VAR_jump_host_password="xxxxx"
    # If using Bash
    #    export TF_VAR_jump_host_password="xxxxx"

```

If you do not wish to deploy the Virtual machine for testing, remove the jump_host.tf file from the directory


## Deploy the Shared resources

Navigate to the "/Scenarios/ASA-Secure-Baseline/Terraform/04-LZ-SharedResources" directory. 

```bash
cd ../04-LZ-SharedResources
```

Deploy using Terraform Init, Plan and Apply

```bash
# Ensure the following state management runtime variables have been defined:
#   STORAGEACCOUNTNAME = 'xxxxx'
#   CONTAINERNAME      = 'xxxxx'
#   TFSTATE_RG         = 'xxxxx'


terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"
```

```bash
# If using PowerShell
$ENV:TF_VAR_JUMP_HOST_PASS="xxxxx"

# If using Bash
export TF_VAR_JUMP_HOST_PASS="xxxxx"

# Then proceed to the plan step
terraform plan -out my.plan --var-file ../parameters.tfvars
```

```bash
terraform apply my.plan
```

### Next step

:arrow_forward: [Deploy the Azure Firewall Resource](./05-Hub-AzureFirewall.md)