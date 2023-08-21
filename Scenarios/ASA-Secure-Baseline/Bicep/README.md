# Azure Spring Apps Landing Zone Accelerator - VNet Injection Scenario for Bicep

## Accounting for Separation of Duties

While the code here is located in a single repo, the steps are segregated by section folder and are designed to mimic how an organization may break up the deployment of various Azure components across teams, into different code repos or have them run by different pipelines with specific credentials. 

## Bicep Parameter Files

The repo contains a single parameters.json file in the Deployment folder. Resource names are all exposed as Bicep parameters with default values.  View `\Deployment\main.bicep` to see the complete list of resource names and additional parameters.  You can run the deployment as-is and accept the default resource names, or you can add override the values in the parameter.json file to values that correspond with your organization's naming convention.

## Prerequisites

1. This deployment scenario requires the following tools installed locally if you intend to execute the deployment from your local machine:
    1. PowerShell. [Click here](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3) for instructions on installing PowerShell.
    1. Azure PowerShell Az Module. [Click here](https://learn.microsoft.com/en-us/powershell/azure/install-azure-powershell?view=azps-10.2.0) for instructions on installing the Azure PowerShell Az Module.
    1. Azure CLI. [Click here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) for instructions on installing Azure CLI.
    1. Azure Bicep. [Click here](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) for instructions on installing Azure Bicep.
        1. If Bicep is already installed, ensure you have the latest version by running `az bicep upgrade`
1. Clone this repo:

### To clone this repo

```bash
git clone https://github.com/Azure/azure-spring-apps-reference-architecture.git`
```

### To authenticate Azure CLI

_az login_ (Azure CLI) or _Connect-AzAccount_ ([PowerShell](https://learn.microsoft.com/en-us/powershell/module/az.accounts/connect-azaccount?view=azps-10.2.0))

### To set a specific subscription

_az account list --output table_
_az account set --subscription {name-of-subscription}_ (Azure CLI) or _Set-AzContext -Subscription {id-of-subscription}_ ([PowerShell](https://docs.microsoft.com/en-us/powershell/module/az.accounts/set-azcontext?view=azps-10.2.0))

1. If not already registered in the subscription, use the following Azure CLI commands to register the required resource providers for Azure Spring Apps:
    1. _az provider register --namespace 'Microsoft.AppPlatform'_
    1. _az provider register --namespace 'Microsoft.ContainerService'_
    1. _az provider register --namespace 'Microsoft.ServiceLinker'_

1. Modify the variables within the parameters.json files as needed

EXAMPLE - These correspond to the Azure tag key value pairs applied to all resources deployed as part of the landing zone.  You could inlcude environment information, team details, or other tags required by your organization

```json
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
1. Define a local variable called _$namePrefix_ and set it to a value appropriate for your organization. i.e. `$namePrefix = 'myorg'`
1. Execute _deploy\_enterpise.ps1_ in the Deployment folder
    1. You will be prompted for the admin password for the jumpbox VM.  This value will be stored within Key Vault for secure access at a later time.
    1. For standard deployments, execute _deploy\_standard.ps1_ in the Deployment folder

## Deployment via Azure Dev CLI

You can deploy the current LZA directly in your azure subscription using Azure Dev CLI.

1. Using Codespaces via Azure Dev CLI
1. Visit https://github.com/Azure/azure-spring-apps-landing-zone-accelerator
1. Click on the Green Code button
1. Navigate to the CodeSpaces tab and create a new code space
1. Open the terminal by pressing Ctrl + `.
1. Navigate to the scenario folder using the command cd /workspaces/azure-spring-apps-landing-zone-accelerator/Scenarios/ASA-Secure-Baseline
1. Login to Azure using the command azd auth login.
1. Use the command azd up to deploy, provide the following to deploy
   1. environment name (location)
   1. namePrefix
   1. subscription
   1. jumpHostPassword This value will be stored within Key Vault for secure access at a later time. (note the password must be between 8-123 and satisy 3 complex requirements like to have contain an uppercase character, a lowercase character, a numeric digit, a speacial character)
   1. principalId, You can retrieve this by running the command `az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv`
1. Finally, use the command azd down to clean up resources deployed.

## Bringing your own Hub

If you have an existing corporate network hub you can override the details of the hub in the `main.parameters.json` file and this script will use your existing resource.  You will need the contributor role to the the existing hub and/or resource group where the existing hub is deployed.  You may also need to modify the subnet prefixes in `main.parameters.json` to avoid IP address space collisions with existing subnets.  Add the following values to the bottom of the `main.parameters.json` file to specify an existing hub VNET:

```json
"deployHub": {
  "value": false
},
"hubVnetName": {
  "value": "{name-of-your-hub-vnet}"
},
"hubVnetRgName": {
  "value": "{name-of-resource-group-containing-your-hub-vnet}"
}
```

## Bringing your own Firewall/Deploying without an egress Firewall

If you have an existing firewall, or you do not have a requirement for egress traffic to route through a firewall, you can override the details of the firewall in the `main.parameters.json` file and this script will use your existing resource or not deploy firewall settings at all.  Add the following values to the bottom of the `main.parameters.json` file:

  **Option 1:** Deploy an Azure Firewall to the LZA
    No changes to `main.parameters.json` required

  **Option 2:** Use an existing firewall.  *NOTE*: If you use an existing firewall, that firewall needs to implement specific rules to allow Azure Spring Apps to provision and boot strap.  See the [Azure Spring Apps FQDN requirements/application rules](https://learn.microsoft.com/en-us/azure/spring-apps/vnet-customer-responsibilities#azure-spring-apps-fqdn-requirementsapplication-rules) for details.

```json
"firewallIp": {
  "value": "{internal-ip-of-your-existing-firewall}"
}
```

  **Option 3:** Do not configure any firewall

```json
"deployFirewall": {
  "value": false
}
```
