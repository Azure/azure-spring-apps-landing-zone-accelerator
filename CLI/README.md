# Azure Spring Cloud Quick Start

## Overview

## Prerequisites

1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. Run the two commands below to add the required extensions to Azure CLI.

    `az extension add --name azure-firewall`

    `az extension add --name spring-cloud`

3. The script has been tested using `Azure CLI version 2.17.1`

## Deployment


1. Run `az login`

2. Run `az account set --subscription {your subscription name}`

3. Execute the `deploy-azurespringcloud-internal.sh` Bash script.  You will be prompted on screen to enter a valid User Principal Name for Azure Key Vault access, MySQL administrator name, MySQL Administrator password, a jumphost VM administrator name, and a jumphost VM administrator password.  Other resource names are parameters in the script and can be edited before execution.

**Note:** resource and administrator names have syntax restrictions:
    -   [Virtual Machine Administrator syntax restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm)
    -   [Virtual Machine Administrator password syntax requirements and restrictions](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm)
    -   [Virtual Machine name syntax requirements](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute)
    -   [MySQL ]
4. If deployed into the East US 2 Azure region you will need to manually add a default Azure Firewall internet route to the Azure Spring Cloud app and service resource group route tables.  Each resource group contains a single route table that will need 0.0.0.0/0 route with Next Hop Address of Azure Firewall private IP address.

## Post Deployment

Install one of the following sample applications:
    * [Simple Hello World](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-quickstart?tabs=Azure-CLI&pivots=programming-language-java)
    * [Pet Clinic App with MySQL Integration](https://github.com/azure-samples/spring-petclinic-microservices)

## Deploy Azure Application Gateway with WAF (optional)

1. You will need a TLS/SSL Certificate with the Private Key (PFX Format) for the Application Gateway Listener. The PFX certificate on the listener needs the entire certificate chain and the password must be 4 to 12 characters. For the purpose of this quick start, you can use a self signed certificate or one issued from an internal Certificate Authority. You will need to convert the certificate to a Base64 string value for the next step. The following will set the Base64 string value to a variable to be used as part of the deployment (replace the file name with your own).

    `export HTTPSDATA=$(base64 -w 0 nameofcertificatefile.pfx)`

2. Execute the template and when prompted, enter the certificate password for https_password and the FQDN of the internal Azure Spring Cloud application e.g. petclinic-in-vnet-api-gateway.private.azuremicroservices.io. Note: For this quickstart, use the same resource group that was created previously.

    `az deployment group create --resource-group my-resource-group --name appGW --template-uri="https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/ARM/resources/deployAppGw.json" --parameters https_data=${HTTPSDATA}`

3. Once deployed, look for the Application Gateway Resource in the Resource Group and note the Frontend Public IP address

4. From a browser that isn't in the quick start virtual network, browse to https://<publicIPofAppGW>. You will get a warning in the browser that the connection is not secure. This is expected as we are connecting via the IP address. Proceed to the page anyway.

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/Az-CLI/images/Petclinic-External.jpeg)


## Clean up Resources 

If the Azure Spring Cloud environment is no longer needed, all resources can be deleted.  This can be achieved using the Azure CLI or directly from the Azure portal.  

1. To delete all resources provisioned in the script, run `az group delete --resource-group sc-corp --yes` **Note** If you have modified the script to use a different resource group name then you will need to use that resource group name in the above example.  

## Additional Notes

This quick start deploys an Azure Application gateway with a basic listener. To host multiple sites on the same Application gateway, you can use multi-site listeners. For more information see https://docs.microsoft.com/en-us/azure/application-gateway/multiple-site-overview

Azure Application Gateway can also retrieve TLS certificates from Azure Key Vault. Fore more information see https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs 