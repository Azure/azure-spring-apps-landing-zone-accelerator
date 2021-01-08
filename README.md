# Azure Spring Cloud Lab

## Overview

This ARM template creates a small lab in Azure that can be used for experimenting with [Azure Spring Cloud](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-overview) in a typical enterprise landing zone design for a regulated organization.  It uses a [hub and spoke architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) with a single spoke.  East/West traffic (traffic between resources in the hub and resources in the spoke) is filtered with Network Security Groups and North/South traffic (traffic between the Internet and resources in the hub or spoke) is routed through and mediated with an instance of Azure Firewall.  

![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/azure-spring-cloud/images/lab.jpeg)

Additional features of the lab are:

* Azure Spring Cloud is deployed using [vnet-injection](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-tutorial-deploy-in-azure-virtual-network) to allow for mediation inbound and outbound traffic to the Spring Cloud Instance and deployed applications.
* The Azure Firewall instance has been configured to write its logs to a Log Analytics Workspace.  You can leverage [these Kusto queries](https://docs.microsoft.com/en-us/azure/firewall/log-analytics-samples) to analyze Azure Firewall log data written to Log Analytics.
* Hub and Spoke Virtual Networks are configured to use Azure Firewall for DNS queries utilizing the [DNS Proxy feature](https://docs.microsoft.com/en-us/azure/firewall/dns-settings#dns-proxy) of Azure Firewall. 
* Azure Private DNS zones for Azure Spring Cloud and support services deployed with Private Endpoints
* A single Windows Server 2016 Virtual Machine the hub Virtual Network for testing access to applications deployed into the Azure Spring Cloud instance.  This virtual machine is configured with the Microsoft Monitoring Agent and is integrated with the Log Analytics Workspace.
* Log Analytics Workspace where Azure Spring Cloud, Azure Firewall, and the virtual machine deliver logs and metrics.
* Instance of Azure Key Vault deployed with a Private Endpoint for secrets and certificates storage for applications deployed to Azure Spring Cloud
* Instance of Azure Database for MySQL deployed with a Private Endpoint.  This can be used to deploy the sample app described in this document.

## Prerequisites

1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. Run the two commands below to add the required extensions to Azure CLI.

    `az extension add --name firewall`

    `az extension add --name spring-cloud`

3. Record your tenant id of the Azure AD instance associated with the subscription you will be deploying to.

    `az account show --subscription mysubscription --query tenantId --output tsv`

4. Get the object id of the security principal (user, managed identity, service principal) that will have access to the Azure Key Vault instance.

    `az ad user show --id someuser@sometenant.com --query objectId --output tsv`

5. Get the object id of the Spring Cloud Resource Provider from your Azure AD tenant.

    `az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --output tsv`

6. Create a resource group to deploy the resource to.

    `az group create --name my-resource-group`

## Installation
1. Execute the template including the parameters of the tenant id from step 3, the object id from step 4, the object id from step 5, and a username for the administrator account on the virtual machine created and for the My SQL instance.

    `az deployment group create --resource-group my-resource-group --name initial --template-file="/Users/mattfelton/OneDrive - Microsoft/Code/Azure Labs/azure-labs/azure-spring-cloud/deploy.json" --parameters tenantId <TENANT_ID>  keyVaultAdminObjectId <KEY_VAULT_ADMIN_OBJECT_ID> springCloudPrincipalObjectId <SPRING_CLOUD_SP_OBJECT_ID>`

You will be prompted to set a password.  This will be the password for the virtual machine and the My SQL instance.

2. Run the add-routes.sh bash script or the commands within it to set the default routes on the Spring Cloud subnets.

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
