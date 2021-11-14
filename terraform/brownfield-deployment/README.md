# Create Azure Spring Cloud into an existing Virtual Network

## Overview

This template will create an Azure Spring Cloud cluster into an existing Virtual Network. This can be used with or without an NVA (Network Virtual Appliance) or Azure FIrewall for restricting egress traffic. This will also create a [workspace-based](https://docs.microsoft.com/en-us/azure/azure-monitor/app/create-workspace-resource) Azure Application Insights resource and deploy into an existing Log Analytics Workspace. The Azure Spring cloud Diagnostics settings will also be configured to use the Log Analytics Workspace.

## Prerequisites

1. 2 dedicated subnets for the Azure Spring Cloud Cluster. One for the service runtime and another for the Spring Boot micro-service applications. see [here](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#virtual-network-requirements) for subnet and virtual network requirements.

1. An existing Log Analytics workspace for Azure Spring Cloud [diagnostics settings](https://docs.microsoft.com/en-us/azure/spring-cloud/diagnostic-services) as well as a workspace-based [Application Insights](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-distributed-tracing) resource.

1. You must plan the 3 internal CIDR ranges (at least /16 each) used for the Azure Spring Cloud cluster. These will not be directly routable and will be used only internally by the Azure Spring Cloud Cluster. Clusters may not use 169.254.0.0/16, 172.30.0.0/16, 172.31.0.0/16, or 192.0.2.0/24 for the internal Spring Cloud CIDR ranges, or any ranges included within the cluster virtual network address range.

1. Grant service permission to the virtual network. The Azure Spring Cloud Resource Provider requires Owner permission to your virtual network in order to grant a dedicated and dynamic service principal on the virtual network for further deployment and maintenance. See [here](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#grant-service-permission-to-the-virtual-network) for instructions and more information.

1. If using Azure Firewall or an NVA you will need the following:
    * Network and FQDN rules. see [requirements](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#virtual-network-requirements).
    * A unique UDR ([User Defined Route](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview)) applied to each of the service runtime and Spring Boot micro-service application subnets. The UDR should be configured with a route for **0.0.0.0/0** with a destination of your NVA. See [here](https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network#bring-your-own-route-table) for more information.

1. [Install Hashicorp Terraform](https://www.terraform.io/downloads.html)

    **Note:** This script was tested using the following terraform version:
    https://registry.terraform.io/providers/hashicorp/azurerm/2.42.0
    Earlier and later versions will need to be independently tested and verified. 

1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Deployment

1. Login to Azure and select the target subscription.

    ```bash
    az login

    az account set --subscription "Your Subscription Name"
    ```

    Before running the terraform plan, the following information should be added to the variables.tf file otherwise you will be prompted to provide each item during execution:

    * Subscription ID the Azure account you will be deploying to

    * A valid Azure Region where resources are deployed
    * Run `https://azure.microsoft.com/global-infrastructure/services/?products=spring-cloud&regions=all` command to find list of available regions for Azure Spring Cloud
        * **Note:** region format must be lower case with no spaces.  For example: East US is represented as eastus
    * Name of the Resource Group where resources will be deployed

    * Desired name for the Spring Cloud Deployment

    * Name of the Virtual Network Resource Group where resources will be deployed

    * Name of the Spoke Virtual Network name(e.g. vnet-spoke)

    * Name of the SubNet to be used by Spring Cloud App Service (e.g snet-app) 

    * Name of the SubNet to be used by Spring Cloud runtime Service (e.g snet-runtime) 

    * Name of the Azure Log Analytics workspace to be used for storing diagnostic logs(e.g la-cb5sqq6574o2a)

    * CIDR Ranges from your Virtual network to be used by Azure Spring Cloud(e.g XX.X.X.X/16,XX.X.X.X/16,XX.X.X.X/16)

    * key=value pairs to be applied as Tags on all resources which support tags
        * **Example:** The tages for environment=Dev and BusinessUnit=finance

            ```terraform
            tags = {
                type = map
                default = {
                    environment = "Dev"
                    BusinesUnit = "Finance"
                }    
            }

1. Run the following command to initialize the terraform modules:

    ```bash
    terraform init
    ```

1. Run the following command to plan the terraform deployment:

    ```bash
    terraform plan -out=springcloud.plan
    ```

## Cleaning up

Unless you plan to perform additional tasks with the Azure resources from the quickstart (such as post deployment steps above), it is important to destroy the resources that you created to avoid the cost of keeping them provisioned.

The easiest way to do this is to call `terraform destroy`. Do this in both directories (root directory and relevant app gateway directory).

  ```bash
  terraform destroy
  ```
