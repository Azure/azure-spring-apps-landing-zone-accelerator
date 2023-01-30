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

##################################################
# REQUIRED
##################################################


# The Region to deploy to
    location              = "westus3"

# This Prefix will be used on most deployed resources.
# The environment will also be used as part of the name
    name_prefix           = "springlza"
    environment           = "dev"

# Deployment state storage information
    state_sa_name="xxxx-enter-the-storage-account-name-xxxx"
    container_name="springappsterraform"

# This can also be sourced from variable ARM_ACCESS_KEY
# https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#access_key
    access_key="xxxx-enter-the-access-key-here-xxxx"

##################################################
# Optional - Hub VNET / Bring your own HUB VNET
##################################################
# You can specify your own Hub Vnet Name and RG
# You can also specify a different subscription for the Hub Deployment.

# If you leave the Subscription empty, we will use the current Subscription

# To bring your own HUB VNET (Precreated Hub VNET), then specify the Name/RG/Subscription below
# and do not deploy the plan under "02-Hub-Network"

    # Hub_Vnet_Name         = ""
    # Hub_Vnet_RG           = ""
    # Hub_Vnet_Subscription = ""

##################################################
# Optional - Jumpbox
##################################################
# The Jumpbox username defaults to "lzadmin"
# The Jumpbox password defaults to a Random password and stored to the KeyVault
# under the Jumpbox-Pass secret
# My_External_IP will be automatically calculated unless you specify it here.

    # jump_host_vm_size = "Standard_DS3_v2"
    # jump_host_admin_username = "lzadmin"
    # jump_host_password ="xxxxxx"
    # My_External_IP = "1.2.3.4/32"

##################################################
# Optional
##################################################
    # tags = { 
    #    project = "ASA-Accelerator"
    #    deployenv = "dev"
    # }


##################################################
# Optional - Networking
##################################################
    # hub_vnet_addr_prefix           = "10.0.0.0/16"
    # azurefw_addr_prefix            = "10.0.1.0/24"

    # spoke_vnet_addr_prefix         = "10.1.0.0/16"
    # springboot-service-subnet-addr = "10.1.0.0/24"
    # springboot-apps-subnet-addr    = "10.1.1.0/24"
    # springboot-support-subnet-addr = "10.1.2.0/24"
    # shared-subnet-addr             = "10.1.4.0/24"
    # appgw-subnet-addr              = "10.1.5.0/24"

    # springboot-service-subnet-name = "snet-runtime"
    # springboot-apps-subnet-name    = "snet-app"
    # springboot-support-subnet-name = "snet-support"
    # shared-subnet-name             = "snet-shared"
    # appgw-subnet-name              = "snet-agw"
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
    # First review Known issues below
    az login
    cd Deploy
    ./_destroy.ps1
```

## Known Issues / Notes
  - When destroying Azure Spring Apps **Enterprise**, there is an issue with the API Portal destruction where destruction will fail with error "Please unassign public endpoint before deleting API Portal.".  This issues does not apply to Spring Apps Standard Edition.
    - A bug has been filed with the AZURERM terraform provider Github
    https://github.com/hashicorp/terraform-provider-azurerm/issues/19949

    - To get around this and complete the destruction, first disable the public endpoint on the Azure Spring apps Enterprise - API Portal
        - To do this via the Azure Portal, do this:
    Azure Portal > Azure Spring Apps instance > API Portal > Assign endpoint -> Set to No

        - To do this via Terraform
    Modify file 06-LZ-SpringApps-Enterprise\enterprise_tanzu_components.tf
    Line 44 - public_network_access_enabled , set it to False
    Then Apply

    - Then you can destroy the deployment

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
