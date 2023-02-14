# Azure Spring Apps Landing Zone Accelerator - Vnet Injection Scenario for Terraform

## Accounting for Separation of Duties 
While the code here is located in one folder in a single repo, the steps are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials. 

## Terraform State Management
In this example, state is stored in an Azure Storage account that was created out-of-band.  All deployments reference this storage account to either store state or reference variables from other parts of the deployment however you may choose to use other tools for state management, like Terraform Cloud after making the necessary code changes.

## Getting Started 
This section is organized using folders that match the steps outlined below. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment. 

### Prerequisites 
1. Clone this repo, install Azure CLI, install Terraform

2. If not already registered in the subscription, use the following Azure CLI commands to register the required resource providers for Azure Spring Apps:

    `az provider register --namespace 'Microsoft.AppPlatform'`

    `az provider register --namespace 'Microsoft.ContainerService'`

3. Modify the variables within the Global section of the variable definitons file paramaters.tfvars as needed

Sample:
```bash

##################################################
## Global
##################################################
# The Region to deploy to
    location              = "westus3"

# This Prefix will be used on most deployed resources.  10 Characters max.
# The environment will also be used as part of the name
    name_prefix           = "springlza"
    environment           = "dev"

# tags = { 
#    project = "ASA-Accelerator"
#    deployenv = "dev"
# }

```


### Deployment
1. [Creation of Azure Storage Account for State Management](./01-State-Storage.md)

2. [Creation of the Hub Virtual Network & its respective components](./02-Hub-Network.md)

3. [Creation of Landing Zone (Spoke) Network & its respective Components](./03-LZ-Network.md)

4. [Creation of Shared components for this deployment](./04-LZ-SharedResources.md)
 
5. [Creation of Azure Firewall with UDRs](./05-Hub-Firewall.md)

6. [Creation of Azure Spring Apps](./06-LZ-SpringApps.md)

7. [Optional: Creation of Application Gateway](./07-LZ-AppGateway.md)



BELOW IS LEGACY AND NEEDS TO BE SHUFFLED

## Configure deployment parameters
Modify parameters.tfvars as needed

Sample:
```bash

##################################################
# REQUIRED
##################################################


# The Region to deploy to
    location              = "westus3"

# This Prefix will be used on most deployed resources. 10 Characters max.
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
# Optional - Hub VNET / Bring your own Firewall/NVA
##################################################
# Specify IP of existing Firewall/NVA in BYO Hub

   # FW_IP = "10.0.1.4"

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


##################################################
# Optional - Zone Redundancy
##################################################
    # spring_apps_zone_redundant     = true
    # azure_firewall_zones           = [1,2,3]
    # azure_app_gateway_zones        = [1,2,3]
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

