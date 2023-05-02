# Azure Spring Apps Landing Zone Accelerator - VNet Injection Scenario for Bicep

## Accounting for Separation of Duties 
While the code here is located in a single repo, the steps are segregated by section folder and are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials. 

## Bicep Parameter Files
In this example, each section folder contains a parameters.json file.  These files contain parameter values specific to each section, however some parameters are used by multiple sections.  Use caution when updating a parameter value as it may exist in multiple files - a global find and replace is ideal in this scenario.  In addition the resource names are all exposed as Bicep parameters with default values.  You can run the deployment as-is and accept the default resource names, or you can add override values to the parameter.json files that correspond with your organization's naming convention.

## Prerequisites 
1. Clone this repo, install or upgrade [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), Ensure you have the latest [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-cli) by running `az bicep upgrade`

    ### To clone this repo
    `git clone https://github.com/Azure/azure-spring-apps-reference-architecture.git`
    
    ### To authenticate Azure CLI
    `az login`

    ### To set a specific subscription
    `az account list --output table`<br>
    `az account set --subscription <name-of-subscription>`


2. If not already registered in the subscription, use the following Azure CLI commands to register the required resource providers for Azure Spring Apps:

    `az provider register --namespace 'Microsoft.AppPlatform'`
    `az provider register --namespace 'Microsoft.ContainerService'`
    `az provider register --namespace 'Microsoft.ServiceLinker'`


3. Obtain the ObjectID of the service principal for Azure Spring Cloud Resource Provider. This ID is unique per Azure AD Tenant. 

    `az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv`

    This value will need to be set in both the ***03-LZ-Network/parameters.json*** and ***05-Hub-AzureFirewall/parameters.json*** files.  It is used to grant permissions to the provisioned VNET and user defined route tables.


4. Modify the variables within the parameters.json files as needed
    ```bash
    # EXAMPLE
    
    ##################################################
    ## 04-LZ-SharedResource/parameters.json
    ##################################################
        "environment": {
            "value": "dev"
        }

    ##################################################
    ## 06-LZ-SpringApps-Standard/parameters.json
    ##################################################
        "environment": {
            "value": "dev"
        }

    ##################################################
    ## {All-Sections}/parameters.json
    ##################################################
        "tags": {
                "value": {
                "{YourFirstTag}": "{YourFirstTagValue}",
                "{YourSecondTag}": "{YourSecondTagValue}",
                ...
            }
        }
    ```

## Deployment via PowerShell
1. Define a local variable called _$location_ and set it to the value of the target region. i.e. `$location = 'eastus'`
2. Define a local variable called _$namePrefix_ and set it to a value appropriate for your organization. i.e. `$namePrefix = 'myorg'`
3. Executed _deploy_standard.ps1_ in the Deployment folder