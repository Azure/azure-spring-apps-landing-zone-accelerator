# Azure Spring Cloud Lab

## To Do Terraform

## Overview
This ARM template creates a small lab in Azure that can be used for experimenting with [Azure Spring Cloud](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-overview) in a typical enterprise landing zone design for a regulated organization. It uses a [hub and spoke architecture](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/hybrid-networking/hub-spoke) with a single spoke.  East/West traffic (traffic between resources in the hub and resources in the spoke) is filtered with Network Security Groups and North/South traffic (traffic between the Internet and resources in the hub or spoke) is routed through and mediated with an instance of Azure Firewall.  

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/lab.jpeg)

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
    
3. Record your tenant id of the Azure AD instance associated with the subscription you will be deploying to. This will be used for the tenantId parameter of the template.

    `az account show --subscription mysubscription --query tenantId --output tsv`

4. Get the object id of the security principal (user, managed identity, service principal) that will have access to the Azure Key Vault instance. This will be used for the keyVaultAdminObjectId parameter of the template.

    `az ad user show --id someuser@sometenant.com --query objectId --output tsv`

5. Get the object id of the Spring Cloud Resource Provider from your Azure AD tenant. This will be used for the springCloudPrincipalObjectId parameter of the template.

    `az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query objectId --output tsv`

6. Create a resource group to deploy the resource to.

    `az group create --name my-resource-group`

## Installation
1. Execute the template including the parameters of the tenant id from step 3, the object id from step 4, the object id from step 5, and a username for the administrator account on the virtual machine created and for the My SQL instance.

    `az deployment group create --resource-group my-resource-group --name initial --template-uri="https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/ARM/deploy.json" --parameters tenantId=<TENANT_ID>  keyVaultAdminObjectId=<KEY_VAULT_ADMIN_OBJECT_ID> springCloudPrincipalObjectId=<SPRING_CLOUD_SP_OBJECT_ID>`

You will be prompted to set a password.  This will be the password for the virtual machine and the My SQL instance.

2. Run the add-routes.sh bash script or the commands within it to set the default routes on the Spring Cloud subnets.

## Post Installation
1. Install one of the following sample applications:
    * [Simple Hello World](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-quickstart?tabs=Azure-CLI&pivots=programming-language-java)
    * [Pet Clinic App with MySQL Integration](https://github.com/azure-samples/spring-petclinic-microservices)

2. Connect to the virtual machine deployed into the resource group using Azure Bastion.

3. From the virtual machine, browse to the private URL of the application e.g. https://petclinic-in-vnet-api-gateway.private.azuremicroservices.io

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/Petclinic-Internal.jpeg)

## Deploy Azure Application Gateway with WAF (optional)

1. You will need a TLS/SSL Certificate with the Private Key (PFX Format) for the Application Gateway Listener. The PFX certificate on the listener needs the entire certificate chain and the password must be 4 to 12 characters. For the purpose of this lab, you can use a self signed certificate or one issued from an internal Certificate Authority. You will need to convert the certificate to a Base64 string value for the next step.  

2. Execute the template and when prompted, enter the Base64 string value for parameter https_data, the certificate password for https_password and the FQDN of the internal Azure Spring Cloud application e.g. petclinic-in-vnet-api-gateway.private.azuremicroservices.io. Note: For this lab, use the same resource group that was created previously.

    `az deployment group create --resource-group my-resource-group --name appGW --template-uri="https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/ARM/resources/deployAppGw.json"`

3. Once deployed, look for the Application Gateway Resource in the Resource Group and note the Frontend Public IP address

4. From a browser that isn't in the lab virtual network, browse to https://<publicIPofAppGW> . You will get a warning in the browser that the connection is not secure. This is expected as we are connecting via the IP address. Proceed to the page anyway.     

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/Petclinic-External.jpeg)

## Aditional Notes

This lab deploys an Azure Application gateway with a basic listener. To host multiple sites on the same Application gateway, you can use multi-site listeners. For more information see https://docs.microsoft.com/en-us/azure/application-gateway/multiple-site-overview

