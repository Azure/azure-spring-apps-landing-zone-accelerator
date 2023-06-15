# Azure Spring Apps Landing Zone Accelerator - VNet Injection Scenario for Bicep

## Accounting for Separation of Duties 
While the code here is located in a single repo, the steps are segregated by section folder and are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials. 

## Bicep Parameter Files
The repo contains a single parameters.json file in the Deployment folder. Resource names are all exposed as Bicep parameters with default values.  View `\Deployment\main.bicep` to see the complete list of resource names and additional parameters.  You can run the deployment as-is and accept the default resource names, or you can add override the values in the parameter.json file to values that correspond with your organization's naming convention.

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

4. Modify the variables within the parameters.json files as needed
    ```json
    # EXAMPLE - These correspond to the Azure tag key value pairs applied to all resources deployed as part of the landing zone.  You could inlcude environment information, team details, or other tags required by your organization.
    
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
3. Execute _deploy_standard.ps1_ in the Deployment folder
    1. You will be prompted for the admin password for the jumpbox VM.  This value will be stored within Key Vault for secure access at a later time.

## Deployment via Azure Dev CLI
You can deploy the current LZA directly in your azure subscription using Azure Dev CLI.

- Using Codespaces via Azure Dev CLI
- Visit https://github.com/Azure/azure-spring-apps-landing-zone-accelerator
- Click on the Green Code button
- Navigate to the CodeSpaces tab and create a new code space
- Open the terminal by pressing Ctrl + `.
- Navigate to the scenario folder using the command cd /workspaces/azure-spring-apps-landing-zone-accelerator/Scenarios/ASA-Secure-Baseline
- Login to Azure using the command azd auth login.
- Use the command azd up to deploy, provide the following to deploy
  - environment name (location)
  - namePrefix
  - subscription
  - jumpHostPassword This value will be stored within Key Vault for secure access at a later time. (note the password must be between 8-123 and satisy 3 complex requirements like to have contain an uppercase character, a lowercase character, a numeric digit, a speacial character)
  - principalId, Yu can retrieve this by running the command <<az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv>>
- Finally, use the command azd down to clean up resources deployed.

## Bringing your own Hub or Firewall
If you have an existing network hub and/or firewall you can override the details of the hub and firewall in the `main.parameters.json` file and this script will use your existing resources.  Add the following values to the bottom of the `main.parameters.json` file:

    ```json
    "deployHub": {
      "value": false
    },
    "hubVnetName": {
      "value": "{name-of-your-hub-vnet}"
    },
    "hubVnetRgName": {
      "value": "{name-of-resource-group-containing-your-hub-vnet}"
    },
    "deployFirewall": {
      "value": false
    },
    "azureFirewallIp": {
      "value": "{internal-ip-of-your-firewall}"
    }
    ```