# Azure Spring Apps Landing Zone Accelerator - VNet Injection Scenario for Terraform

## Accounting for Separation of Duties 
While the code here is located in one folder in a single repo, the steps are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials. 

## Terraform State Management
In this example, state is stored in an Azure Storage account that was created out-of-band.  All deployments reference this storage account to either store state or reference variables from other parts of the deployment however you may choose to use other tools for state management, like Terraform Cloud after making the necessary code changes.

## Terraform Variable Definitons File
In this example, there is a common variable defintions file [parameters.tfvars](./parameters.tfvars) that is shared across all deployments. Review each section and update the variable definitons file as needed. 

## Getting Started 
This section is organized using folders that match the steps outlined below. Make any necessary adjustments to the variables and settings within that folder to match the needs of your deployment. 

## Prerequisites 
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


## Deployment
1. [Creation of Azure Storage Account for State Management](./01-State-Storage.md)

2. [Creation of the Hub Virtual Network & its respective components](./02-Hub-Network.md)

3. [Creation of Landing Zone (Spoke) Network & its respective Components](./03-LZ-Network.md)

4. [Creation of Shared components for this deployment](./04-LZ-SharedResources.md)
 
5. [Creation of Azure Firewall with UDRs](./05-Hub-Firewall.md)

6. [Creation of Azure Spring Apps](./06-LZ-SpringApps.md)

7. [Optional: Creation of Application Gateway](./07-LZ-AppGateway.md)

8. [Cleanup](./08-cleanup.md)

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


BELOW IS LEGACY AND NEEDS TO BE SHUFFLED

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

