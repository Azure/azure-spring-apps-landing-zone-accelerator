# Create Azure Spring Cloud into an existing Virtual Network

## Overview

This template will create an Azure Spring Cloud cluster into an existing Virtual Network. This can be used with or without an NVA (Network Virtual Appliance) or Azure FIrewall for restricting egress traffic. This will also create a [workspace-based](https://docs.microsoft.com/en-us/azure/azure-monitor/app/create-workspace-resource) Azure Application Insights resource and deploy into an existing Log Analytics Workspace. The Azure Spring cloud Diagnostics settings will also be configured to use the Log Analytics Workspace.

## Prerequisites

1. 2 dedicated subnets for the Azure Spring Cloud Cluster. One for the service runtime and another for the Spring Boot micro-service applications. see [here](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#virtual-network-requirements) for subnet and virtual network requirements.

2. An existing Log Analytics workspace for Azure Spring Cloud [diagnostics settings](https://docs.microsoft.com/en-us/azure/spring-cloud/diagnostic-services) as well as a workspace-based [Application Insights](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-distributed-tracing) resource.

3. You must plan the 3 internal CIDR ranges (at least /16 each) used for the Azure Spring Cloud cluster. These will not be directly routable and will be used only internally by the Azure Spring Cloud Cluster. Clusters may not use 169.254.0.0/16, 172.30.0.0/16, 172.31.0.0/16, or 192.0.2.0/24 for the internal Spring Cloud CIDR ranges, or any ranges included within the cluster virtual network address range.

4. DNS FINISH

5. Permissions/RBAC FINISH

6.  If using Azure Firewall or an NVA you will need the following:
  * Network and FQDN rules. see [requirements](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#virtual-network-requirements).
  * A unique UDR ([User Defined Route](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)) applied to each of the service runtime and Spring Boot micro-service application subnets. The UDR should be configured with a route for **0.0.0.0/0** with a destination of your NVA. See [here](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#bring-your-own-route-table) for more information.

7. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

8. Run the following command to register the Azure Spring Cloud Resource Provider.

    `az provider register --namespace 'Microsoft.AppPlatform'`

9. Run the command below to add the required extensions to Azure CLI.

    `az extension add --name spring-cloud`

10. Run az login to log into Azure

11. Record your subscription id of the Azure account you will be deploying to. This id will be used when you run deploySpringCloud and prompted to enter the subscrition.

    `az account list`

12. Create a resource group to deploy the resource to.

```bash
    export RESOURCE_GROUP=my-resource-group
    export LOCATION=eastus

    az group create --name ${RESOURCE_GROUP} --location ${LOCATION}
```

## Deployment

Execute the deploySpringCloud.sh Bash script. You will be prompted at the start of the script to enter:

 - Subscrition ID the Azure account you will be deploying to

 - A valid Azure Region where resources are deployed
     - Run `https://azure.microsoft.com/global-infrastructure/services/?products=spring-cloud&regions=all` command to find list of available regions for Azure Spring Cloud
     - **Note:** region format must be lower case with no spaces.  For example: East US is represented as eastus

 - Name of the Resource Group where resources will be deployed

 - Name of the Virtual Network Resource Group where resources will be deployed

 - Name of the Spoke Virtual Network name(e.g. vnet-spoke)

 - Name of the SubNet to be used by Spring Cloud App Service (e.g snet-app) 

 - Name of the SubNet to be used by Spring Cloud runtime Service (e.g snet-runtime) 

 - Name of the Azure Log Analytics workspace to be used for storing diagnostic logs(e.g la-cb5sqq6574o2a)

 - CIDR Ranges from your Virtual network to be used by Azure Spring Cloud(e.g XX.X.X.X/16,XX.X.X.X/16,XX.X.X.X/16)

 - key=value pairs to be applied as [Tags](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources) on all resources which support tags
     - Space separated list to support applying multiple tags
     - **Example:** environment=Dev BusinessUnit=finance

## Cleaning Up

Unless you plan to perform additional tasks with the Azure resources from the quickstart (such as post deployment steps above), it is important to destroy the resources that you created to avoid the cost of keeping them provisioned.

The easiest way to do this is to call `az group delete`.

```bash
az group delete --name ${RESOURCE_GROUP} --yes --no-wait
```
