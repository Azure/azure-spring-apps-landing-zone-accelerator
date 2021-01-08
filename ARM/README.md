# Azure Spring Cloud Lab

## Overview

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

    `az group create --name my-resource-group --location eastus`

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

1. You will need a TLS/SSL Certificate with the Private Key (PFX Format) for the Application Gateway Listener. The PFX certificate on the listener needs the entire certificate chain and the password must be 4 to 12 characters. For the purpose of this lab, you can use a self signed certificate or one issued from an internal Certificate Authority. You will need to convert the certificate to a Base64 string value for the next step. The following will set the Base64 string value to a variable to be used as part of the deployment (replace the file name with your own).

    `export HTTPSDATA=$(base64 -w 0 nameofcertificatefile.pfx)`

2. Execute the template and when prompted, enter the certificate password for https_password and the FQDN of the internal Azure Spring Cloud application e.g. petclinic-in-vnet-api-gateway.private.azuremicroservices.io. Note: For this lab, use the same resource group that was created previously.

    `az deployment group create --resource-group my-resource-group --name appGW --template-uri="https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/ARM/resources/deployAppGw.json" --parameters https_data=${HTTPSDATA}`

3. Once deployed, look for the Application Gateway Resource in the Resource Group and note the Frontend Public IP address

4. From a browser that isn't in the lab virtual network, browse to https://<publicIPofAppGW>. You will get a warning in the browser that the connection is not secure. This is expected as we are connecting via the IP address. Proceed to the page anyway.     

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/Petclinic-External.jpeg)

## Aditional Notes

This lab deploys an Azure Application gateway with a basic listener. To host multiple sites on the same Application gateway, you can use multi-site listeners. For more information see https://docs.microsoft.com/en-us/azure/application-gateway/multiple-site-overview

Azure Application Gateway can also retrieve TLS certificates from Azure Key Vault. Fore more information see https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs 