# Temporary testing Intructions 


## Create a remote state storage account

Create some variables to start with

```bash
# Bash
REGION=<REGION>
STORAGEACCOUNTNAME=<UNIQUENAME>
CONTAINERNAME=springappsterraform
TFSTATE_RG=springappsterraform

#      -- or --

## PowerShell
$REGION="<REGION>"
$STORAGEACCOUNTNAME="<UNIQUENAME>"
$CONTAINERNAME="springappsterraform"
$TFSTATE_RG="springappsterraform"
```


Create a Resource Group:
```bash
az group create --name $TFSTATE_RG --location $REGION
```

Create a Storage Account:
```bash
az storage account create -n $STORAGEACCOUNTNAME -g $TFSTATE_RG -l $REGION --sku Standard_LRS
```

Create a Storage Container within the Storage Account:

```bash
az storage container-rm create --storage-account $STORAGEACCOUNTNAME --name $CONTAINERNAME
```

Obtain the access keys

```bash
 az storage account keys list -g $TFSTATE_RG  -n $STORAGEACCOUNTNAME 

```


## Configure deployment parameters
Modify parameters.tfvars as needed

Sample:
```bash
# The Region to deploy to
    location              = "westus3"

# This Prefix will be used on most deployed resources.
# The environment will also be used as part of the name
    name_prefix           = "springlza"
    environment           = "dev"

# If using a different name for the Hub Vnet, specify it here
# Otherwise, keep this as is.   The prefix on the names below
# should match the name_prefix
    Hub_Vnet_Name         = "springlza-vnet-HUB"
    Hub_Vnet_RG           = "springlza-HUB"

# Deployment state information
    state_sa_name="xxxx-enter-the-storage-account-name-xxxx"
    container_name="springappsterraform"

# This can also be sourced from variable ARM_ACCESS_KEY
# https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#access_key

    access_key="xxxx-enter-the-access-key-here-xxxx"
```

## Deploy all components at once
This will run a PowerShell script that will deploy each component in the appropiate order. You will be prompted for a username and password for the Jump Host.

```bash
    # Define the state variables (PowerShell Shown)
    $STORAGEACCOUNTNAME="<UNIQUENAME>"
    $CONTAINERNAME="springappsterraform"
    $TFSTATE_RG="springappsterraform"

    # Login to Azure CLI
    az login

    # There is deployment script for Spring Apps Standard and one for Spring Apps Enterprise
    cd Deployment
    ./deploy_xxxxx.ps1
```

## Deploy individual components
Use this to deploy each component individually.  It is important to include the --var-file parameter on each run.

For ***Step 06*** , Spring apps Deployment, choose Either Standard or Enterprise

```bash
    # Define the state variables (PowerShell Shown)
    $STORAGEACCOUNTNAME="<UNIQUENAME>"
    $CONTAINERNAME="springappsterraform"
    $TFSTATE_RG="springappsterraform"

    # Login to Azure CLI
    az login

    # Change directory in the component and init terraform
    cd <xx-FolderName>
    terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"

    # Plan and apply
    terraform plan -out my.plan --var-file ../parameters.tfvars
    terraform apply my.plan
```

## Clean up
This will run a PowerShell script that will destroy the terraform deployment
```bash
    az login
    cd Deploy
    ./_destroy.ps1
```


# Project

> This repo has been populated by an initial template to help get you started. Please
> make sure to update the content to build a great experience for community-building.

As the maintainer of this project, please make a few updates:

- Improving this README.MD file to provide a great experience
- Updating SUPPORT.MD with content about this project's support experience
- Understanding the security reporting process in SECURITY.MD
- Remove this section from the README

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
