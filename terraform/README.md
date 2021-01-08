# Azure Spring Cloud Lab


## Overview
This terraform template creates a small lab in Azure that can be used for experimenting with [Azure Spring Cloud](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-overview) in a typical enterprise landing zone design for a regulated organization. It uses a [hub and spoke architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) with a single spoke.  East/West traffic (traffic between resources in the hub and resources in the spoke) is filtered with Network Security Groups and North/South traffic (traffic between the Internet and resources in the hub or spoke) is routed through and mediated with an instance of Azure Firewall.  

![lab image](https://github.com/mattfeltonma/azure-labs/blob/master/azure-spring-cloud/images/lab.jpeg)

Additional features of the lab are:

* Azure Spring Cloud is deployed using [vnet-injection](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-tutorial-deploy-in-azure-virtual-network) to allow for mediation inbound and outbound traffic to the Spring Cloud Instance and deployed applications.
* The Azure Firewall instance has been configured to write its logs to a Log Analytics Workspace.  You can leverage [these Kusto queries](https://docs.microsoft.com/en-us/azure/firewall/log-analytics-samples) to analyze Azure Firewall log data written to Log Analytics.
* Hub and Spoke Virtual Networks are configured to use Azure Firewall for DNS queries utilizing the [DNS Proxy feature](https://docs.microsoft.com/en-us/azure/firewall/dns-settings#dns-proxy) of Azure Firewall. 
* Azure Private DNS zones for Azure Spring Cloud and support services deployed with Private Endpoints
* A single Windows Server 2016 Virtual Machine the hub Virtual Network for testing access to applications deployed into the Azure Spring Cloud instance.  This virtual machine is configured with the Microsoft Monitoring Agent and is integrated with the Log Analytics Workspace.
* Log Analytics Workspace where Azure Spring Cloud, Azure Firewall, and the virtual machine deliver logs and metrics.
* Instance of Azure Key Vault deployed with a Private Endpoint for secrets and certificates storage for applications deployed to Azure Spring Cloud
* Instance of Azure Database for MySQL deployed with a Private Endpoint.  This can be used to deploy the sample app described in later in this document.

## Prerequisites

**Note:** *You must have owner privileges on the target subscription. This script will automatically assign the Azure Spring Cloud Resource Provider Owner rights on the created VNET.*

1. [Install Hashicorp Terraform](https://www.terraform.io/downloads.html) - This script was built using version *0.14.4*

2. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Deployment

1. Login to Azure and select the target subscription.

    `az login`

    `az account set --subscription "Your Subscription Name"`

2. Run the following command to initialize the terraform modules.

    `terraform init`

3. Run the following command to plan the terraform deployment

    `terraform plan -out=springcloud.plan`

4. Finally, deploy the terraform Spring Cloud using the following command.

    `terraform apply springcloud.plan`

## Post Deployment

Install one of the following sample applications:
* [Simple Hello World](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-quickstart?tabs=Azure-CLI&pivots=programming-language-java)
* [Pet Clinic App with MySQL Integration](https://github.com/azure-samples/spring-petclinic-microservices)





