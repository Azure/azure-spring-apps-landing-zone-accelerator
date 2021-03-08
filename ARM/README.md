# ARM Template Quickstart - Azure Spring Cloud Reference Architecture

## Overview

## Prerequisites

1. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. Run the following command to register the Azure Spring Cloud Resource Provider.

    `az provider register --namespace 'Microsoft.AppPlatform'`

3. Run the two commands below to add the required extensions to Azure CLI.

    `az extension add --name azure-firewall`

    `az extension add --name spring-cloud`

4. Record your tenant id of the Azure AD instance associated with the subscription you will be deploying to. This will be used for the tenantId parameter of the template.

    `az account show --subscription mysubscription --query tenantId --output tsv`

5. Get the object id of the security principal (user, managed identity, service principal) that will have access to the Azure Key Vault instance. This will be used for the keyVaultAdminObjectId parameter of the template.

    `az ad user show --id someuser@sometenant.com --query objectId --output tsv`

6. Get the object id of the Spring Cloud Resource Provider from your Azure AD tenant. This will be used for the springCloudPrincipalObjectId parameter of the template.

    `az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query objectId --output tsv`

7. Create a resource group to deploy the resource to.

```bash
    export RESOURCE_GROUP=my-resource-group
    export LOCATION=eastus

    az group create --name ${RESOURCE_GROUP} --location ${LOCATION}
```

## Deployment

Execute the template including the parameters of the tenant id from step 4, the object id from step 5, the object id from step 6. This will take about 30 minutes to deploy.
   *    Azure Virtual Machine [administrator name ](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm) and [password](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm) requirements.
   *    Azure database for MySQL [administrator name](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-cli#create-an-azure-database-for-mysql-server) and [password](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-cli#create-an-azure-database-for-mysql-server) requirements.

```bash
    az deployment group create --resource-group ${RESOURCE_GROUP} \
    --name initial \
    --template-uri="https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/ARM/deploy.json" \
    --parameters tenantId=<TENANT_ID> keyVaultAdminObjectId=<KEY_VAULT_ADMIN_OBJECT_ID> springCloudPrincipalObjectId=<SPRING_CLOUD_SP_OBJECT_ID>
```

You will be prompted to set a username and password.  This will be the username and password for the virtual machine and the MySQL instance.

## Post Deployment

Install one of the following sample applications:
* [Pet Clinic App with MySQL Integration](https://github.com/azure-samples/spring-petclinic-microservices) (Microservices with MySQL backend)
* [Simple Hello World](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-quickstart?tabs=Azure-CLI&pivots=programming-language-java)

For the Pet Clinic application, you can skip the steps for creating the Azure Spring Cloud instance and MySQL instance but do follow the steps for configuring MySQL (Create database etc). When ready to test the application, connect to the Jump VM deployed to the VNet using Azure Bastion.

If you set az cli defaults deploying the Pet Clinic application, clear the defaults using the following.

```bash
    az configure --defaults location='' \
    group='' \
    spring-cloud=''
```

## Deploy Azure Application Gateway with WAF (optional)

Here you will have 2 options:
- Option 1: Use a public Azure Application gateway for direct ingress.
- Option 2: Use a private Azure Application gateway in between Azure Firewall and the Azure Spring Cloud application (DNAT Rule and ingress on Azure Firewall).

1. You will need a TLS/SSL Certificate with the Private Key (PFX Format) for the Application Gateway Listener. The PFX certificate on the listener needs the entire certificate chain and the password must be 4 to 12 characters. For the purpose of this quickstart, you can use a self signed certificate or one issued from an internal Certificate Authority. You will need to convert the certificate to a Base64 string value for the next step. The following will set the Base64 string value to a variable to be used as part of the deployment (replace the file name with your own).

```bash
    export HTTPSDATA=$(base64 -w 0 nameofcertificatefile.pfx)
```

### Option 1 - Public Application Gateway

1. Execute the template and when prompted, enter the certificate password for https_password and the FQDN of the internal Azure Spring Cloud application e.g. petclinic-in-vnet-api-gateway.private.azuremicroservices.io. Note: For this quickstart, use the same resource group that was created previously.

```bash
    az deployment group create --resource-group ${RESOURCE_GROUP} \
     --name appGW \
    --template-uri="https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/ARM/resources/deployPublicAppGw.json" \
    --parameters https_data=${HTTPSDATA}
```

2. Once deployed, look for the Application Gateway Resource in the Resource Group and note the Frontend Public IP address

3. From a browser that isn't in the quickstart virtual network, browse to https://`<publicIPofAppGW>`. You will get a warning in the browser that the connection is not secure. This is expected as we are connecting via the IP address. Proceed to the page anyway.

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/Petclinic-External.jpeg)

### Option 2 - Private Application Gateway behind Azure Firewall (DNAT)

1. Execute the template and when prompted, enter the certificate password for https_password and the FQDN of the internal Azure Spring Cloud application e.g. petclinic-in-vnet-api-gateway.private.azuremicroservices.io. Note: For this quickstart, use the same resource group that was created previously.

```bash
    az deployment group create --resource-group ${RESOURCE_GROUP}  \
    --name appGW \
    --template-uri="https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/ARM/resources/deployPrivateAppGw.json" \
    --parameters https_data=${HTTPSDATA}
```

2. Once deployed, add a DNAT rule on the Azure Firewall using the following command, replacing "destination-addresses" with the public IP address of your Azure Firewall instance:

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/azfwpip.jpeg)

```bash
    az network firewall nat-rule create --resource-group ${RESOURCE_GROUP} \
    --firewall-name "fwhub" \
    --name springCLoudIngressDNAT \
    --collection-name springCLoudIngressDNAT \
    --protocols "TCP" --source-addresses "*" \
    --destination-addresses "x.x.x.x" \
    --destination-ports 443 --action "Dnat" \
    --priority 100 --translated-address "10.0.3.10" \
    --translated-port "443"
```

3. From a browser that isn't in the quickstart virtual network, browse to https://`<publicIPofAzFWNatRule>`. You will get a warning in the browser that the connection is not secure. This is expected as we are connecting via the IP address being used for the DNAT rule. Proceed to the page anyway.

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/Petclinic-External.jpeg)

## Additional Notes

You can use a custom domain suffix for your Azure Spring Cloud application instead of the default .private.azuremicrososervices.io domain suffix. See the [custom-domain](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/custom-domain/) section of this repo.

This quickstart deploys an Azure Application gateway with a basic listener. To host multiple sites on the same Application gateway, you can use multi-site listeners. For more information see https://docs.microsoft.com/en-us/azure/application-gateway/multiple-site-overview

Azure Application Gateway can also retrieve TLS certificates from Azure Key Vault. Fore more information see https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs