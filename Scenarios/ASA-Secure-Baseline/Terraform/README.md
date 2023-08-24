# Azure Spring Apps Landing Zone Accelerator - VNet Injection Scenario for Terraform

## Accounting for Separation of Duties

While the code here is located in one folder in a single repo, the steps are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials. 

## Terraform State Management

In this example, state is stored in an Azure Storage account that was created out-of-band.  All deployments reference this storage account to either store state or reference variables from other parts of the deployment however you may choose to use other tools for state management, like Terraform Cloud after making the necessary code changes. See [special considerations](#special-notes-for-customers-using-azure-devops-pipelines) for customers implementing DevOps pipelines.

## Terraform Variable Definitons File

In this example, there is a common variable defintions file [parameters.tfvars](./parameters.tfvars) that is shared across all deployments. Review each section and update the variable definitons file as needed. 

## Prerequisites 

1. Clone this repo, install or upgrade [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli), install [Terraform](https://www.terraform.io/downloads.html)

    ### To clone this repo

    ```bash
    git clone https://github.com/Azure/azure-spring-apps-reference-architecture.git
    ```
    
    ### To authenticate Azure CLI

    ```bash
    az login
    ```

    ### To set a specific subscription

    ```bash
    az account list --output table
    az account set --subscription <name-of-subscription>
    ```

2. If not already registered in the subscription, use the following Azure CLI commands to register the required resource providers for Azure Spring Apps:

    ```bash
    az provider register --namespace 'Microsoft.AppPlatform'
    az provider register --namespace 'Microsoft.ContainerService'
    az provider register --namespace 'Microsoft.ServiceLinker'
    ```

3. Obtain the ObjectID of the service principal for Azure Spring Apps. This ID is unique per Azure AD Tenant. In Step 4, set the value of variable SRINGAPPS_SPN_OBJECT_ID to the result from this command.

    `az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv`



4. Modify the variables within the Global section of the variable definitons file paramaters.tfvars as needed

    ```bash
    # EXAMPLE
    
    ##################################################
    ## Global
    ##################################################
    # The Region to deploy to
    location = "eastus"

    # This Prefix will be used on most deployed resources.  10 Characters max.
    # The environment will also be used as part of the name
    name_prefix = "springent"
    environment = "dev"

    # Specify the Object ID for the "Azure Spring Apps Resource Provider" service principal in the customer's Azure AD Tenant
    # Use this command to obtain:
    #    az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv
    SPRINGAPPS_SPN_OBJECT_ID = "<change this>"

    # tags = { 
    #    project = "ASA-Accelerator"
    #    deployenv = "dev"
    # }
    ```
    
4. For Azure Spring Apps Enterprise tier, you need to run the following Azure CLI commands to accept the legal terms and privacy statements. This step is necessary only if your subscription has never been used to create an Enterprise tier instance of Azure Spring Apps. Note: This command can take several minutes to complete. 

    ```bash
    az provider register --namespace Microsoft.SaaS
    az term accept \
        --publisher vmware-inc \
        --product azure-spring-cloud-vmware-tanzu-2 \
        --plan asa-ent-hr-mtr
    ```

## Deployment

1. [Creation of Azure Storage Account for State Management](./01-State-Storage.md)

2. [Creation of the Hub Virtual Network & its respective components](./02-Hub-Network.md)

3. [Creation of Landing Zone (Spoke) Network & its respective Components](./03-LZ-Network.md)

4. [Creation of Shared components for this deployment](./04-LZ-SharedResources.md)
 
5. [Creation of Azure Firewall with UDRs](./05-Hub-AzureFirewall.md)

6. [Creation of Azure Spring Apps](./06-LZ-SpringApps.md)

7. [Optional: Creation of Application Gateway](./07-LZ-AppGateway.md)

8. [Cleanup](./08-cleanup.md)

9. [E2E Deployment using GitHub Action for Azure Spring Apps Standard](./09-e2e-githubaction-standard.md)
    
10. [E2E Deployment using Azure DevOps for Azure Spring Apps Standard](./09-e2e-azuredevops-standard.md).

11. [E2E Deployment using GitHub Action for Azure Spring Apps Enterprise](./09-e2e-githubaction-enterprise.md)

## Known Issues

- Please take the following actions before attempting to destroy this deployment.
  - Turn on the Jump Box Virtual Machine
  - If you have deployed Azure Spring apps Enterprise edition, first disable the public endpoint on the Azure Spring apps Enterprise - API Portal
    - To do this via the Azure Portal, do this:

        Azure Portal > Azure Spring Apps instance > API Portal > Assign endpoint -> Set to No

    - To do this via Terraform:
      - Modify file 06-LZ-SpringApps-Enterprise\enterprise_tanzu_components.tf
      - Line 44 - public_network_access_enabled , set it to False
      - Then Apply

## Special Notes for customers using Azure DevOps Pipelines

Please note the expected key/state file name for each module.

| Module                      | Key/State file name      |
| --------------------------- | ------------------------ |
| 02-Hub-Network              | hub-network              |
| 03-LZ-Network               | lz-network               |
| 04-LZ-SharedResources       | lz-sharedresources       |
| 05-Hub-AzureFirewall        | hub-azurefirewall        |
| 05-Hub-BYO-Firewall-Routes  | hub-byo-firewall-routes  |
| 06-LZ-SpringApps-Enterprise | lz-springapps-enterprise |
| 06-LZ-SpringApps-Standard   | lz-springapps-standard   |
| 07-LZ-AppGateway            | appgateway               |


