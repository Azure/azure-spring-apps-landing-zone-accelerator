# Azure CLI Quickstart - Azure Spring Cloud Reference Architecture

## Overview

The purpose of this script is to deploy an Azure Spring cloud instance on an existing Hub and Spoke network and configure it use an existing Log Analytics workspace to store diagnostic logs.
 - **Note:** This deployment assumes that you have an existing Hub and Spoke network and Log Analytics workspace.Please create these components before proceed with this deployment.
 - **Reference:** [Azure CLI Quickstart - Azure Spring Cloud Reference Architecture](https://github.com/Azure/azure-spring-cloud-reference-architecture/tree/main/CLI)

## Prerequisites

1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. Run the following command to register the Azure Spring Cloud Resource Provider.

    `az provider register --namespace 'Microsoft.AppPlatform'`

3. Run the command below to add the required extensions to Azure CLI.

    `az extension add --name spring-cloud`

4. Run az login to log into Azure

5. Record your subscription id of the Azure account you will be deploying to. This id will be used when you run deploySpringCloud and prompted to enter the subscrition.

    `az account list`

6. Create a resource group to deploy the resource to.

```bash
    export RESOURCE_GROUP=my-resource-group
    export LOCATION=eastus

    az group create --name ${RESOURCE_GROUP} --location ${LOCATION}
```

## Deployment

Execute the deploySpringCloud.sh Bash script. You will be prompted at the start of the script to enter:

 - Subscrition ID the Azure account you will be deploying to

 - A valid Azure Region where resources are deployed
     - Run `open https://azure.microsoft.com/global-infrastructure/services/?products=spring-cloud&regions=all` command to find list of available regions for Azure Spring Cloud
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
