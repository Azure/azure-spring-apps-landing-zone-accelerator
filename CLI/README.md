# Azure CLI Quickstart - Azure Spring Apps Reference Architecture

## Overview

## Prerequisites

1. [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)

2. Run the two commands below to add the required extensions to Azure CLI if they are not installed already

    `az extension add --name azure-firewall`

    `az extension add --name spring-cloud`

3. The script has been tested using `Azure CLI version 2.17.1`

# Azure CLI Quickstart - Azure Spring Apps Reference Architecture

## Overview

## Prerequisites

1. [Install Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)

2. Run the two commands below to add the required extensions to Azure CLI if they are not installed already

    `az extension add --name azure-firewall`

    `az extension add --name spring-cloud`

3. The script has been tested using `Azure CLI version 2.17.1`

## Deployment

1. Run `az login` to log into Azure

2. Run `az account set --subscription {your subscription name}` to set your default subscription

3. Execute the `deploy-azurespringcloud-internal.sh` Bash script.  You will be prompted at the start of the script to enter:

    - [Azure Virtual Machine](https://azure.microsoft.com/services/virtual-machines/) administrator name and password
        - [Password syntax](https://docs.microsoft.com/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm)
        - [Administrator syntax](https://docs.microsoft.com/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm)

    - [Azure database for MySQL](https://azure.microsoft.com/services/mysql/) administrator and password
        - [Password syntax](https://docs.microsoft.com/azure/mysql/quickstart-create-mysql-server-database-using-azure-cli#create-an-azure-database-for-mysql-server)
        - [Administrator syntax](https://docs.microsoft.com/azure/mysql/quickstart-create-mysql-server-database-using-azure-cli#create-an-azure-database-for-mysql-server)

    - A valid Azure Region where resources are deployed
        - Run `open https://azure.microsoft.com/global-infrastructure/services/?products=spring-cloud&regions=all` command to find list of available regions for Azure Spring Apps
        - **Note:** region format must be lower case with no spaces.  For example: East US is represented as eastus
    - key=value pairs to be applied as [Tags](https://docs.microsoft.com/azure/azure-resource-manager/management/tag-resources) on all resources which support tags
        - Space separated list to support applying multiple tags
        - **Example:** environment=Dev BusinessUnit=finance

## Post Deployment

There are a few options available from a post deployment perspective the are as follows:

1. Install one of the following sample applications from the locations below:
&nbsp;
    - [Pet Clinic App with MySQL Integration](https://github.com/azure-samples/spring-petclinic-microservices) (Microservices with MySQL backend)
    - [Simple Hello World](https://docs.microsoft.com/azure/spring-cloud/spring-cloud-quickstart?tabs=Azure-CLI&pivots=programming-language-java)
&nbsp;
2. For an automated installation you can leverage a PowerShell or bash script provided on Jumpbox created during the deployment process. To install the Pet Clinic App leveraging the PowerShell or Shell Script that is provided as part of the deployment login in to the Jumphost (jumphostvm) created usining the Bastion connection and the admin username and password created during the initial installation.  Both the PowerShell script and the Shell script can be found in c:\petclinic.
&nbsp;
    If you choose to leverage the PowerShell script you must navigate to the c:\petclinic and edit the deployPetClinicApp.ps1 script before running. Provide the following information for the corresponding variables:
&nbsp;
    - Your Subscription ID
    - A Resource Group
    - An Azure Region
    - The name of the Spring Apps Service that was created
    - The name of the MySQL Server created
    - The MySQL Administrator name
    - The MySQL Administrator password
&nbsp;

    The variables to be edited in the deployPetClinicApp.ps1 script are as follows:

    ```powershell
      $SUBSCRIPTION='<Insert your Subscription ID>'
      $RESOURCE_GROUP='<Insert Resource Group Name>'
      $REGION='<Insert Azure Region>'
      $SPRING_CLOUD_SERVICE='<Insert Spring Apps Service Name Created>'
      $MYSQL_SERVER_NAME='<Insert MySQL Server Name>'
      $MYSQL_SERVER_ADMIN_NAME='<Insert MySQL Admin Name>' 
      $MYSQL_SERVER_ADMIN_PASSWORD='<Insert MySQL Admin Password>'
    ```

    If you are more comfortable leveraging a shell script, navigate to the same directory, c:\petclininc, and edit the deployPetClinicApp.sh script before running. Provide the following information for the corresponding variables:

    ```bash
      subscription='<Insert your Subscription ID>'
      resource_group='<Insert Resource Group Name>'
      region='<Insert Azure Region>'
      spring_cloud_service='<Insert Spring Apps Service Name Created>'
      mysql_server_name='<Insert MySQL Server Name>'
      mysql_server_admin_name='<Insert MySQL Admin Name>' 
      mysql_server_admin_password='<Insert MySQL Admin Password>'
    ```

## Deploy Azure Application Gateway with WAF (optional)

Here you will have 2 options:

- **Option 1:** Use a public Azure Application gateway for direct ingress.
- **Option 2:** Use a private Azure Application gateway in between Azure Firewall and the Azure Spring Apps application (DNAT Rule and ingress on Azure Firewall).

**Note:** You will need a TLS/SSL Certificate with the Private Key (PFX Format) for the Application Gateway Listener. The PFX certificate on the listener needs the entire certificate chain and the password must be 4 to 12 characters. For the purpose of this quickstart, you can use a self signed certificate or one issued from an internal Certificate Authority.

### Option 1 - Public Application Gateway

1. Change the directory to to deployPublicAppGW

    ```bash
        cd PublicApplicationGateway
    ```

2. Copy the SSL/TLS certificate PFX file to this directory.

3. Run the following script to deploy Application Gateway

    ```bash
        deploy-public-application-gateway.sh
    ```

    **Note:** You will prompted to enter Azure Application Gateway name, name of PFX certificate, password of PFX certificate, and Azure Firewall name.
&nbsp;
4. Once deployed, look for the Application Gateway Resource in the Resource Group and note the Frontend Public IP address.

5. From a browser that isn't in the quickstart virtual network, browse to https://`<publicIPofAppGW>`. You will get a warning in the browser that the connection is not secure. This is expected as we are connecting via the IP address. Proceed to the page anyway.

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/Petclinic-External.jpeg)

### Option 2 - Private Application Gateway behind Azure Firewall (DNAT)

1. Change the directory to to deployPrivateAppGW

    ```bash
        cd PrivateApplicationGateway
    ```

2. Copy the SSL/TLS certificate PFX file to this directory.

3. Run the following script to deploy Application Gateway

    ```bash
        deploy-private-application-gateway.sh
    ```

    **Note:** You will prompted to enter Azure Application Gateway name, name of PFX certificate, password of PFX certificate, and Azure Firewall name.
&nbsp;
4. From a browser that isn't in the quickstart virtual network, browse to https://`<publicIPofAzFWNatRule>`. You will get a warning in the browser that the connection is not secure. This is expected as we are connecting via the IP address being used for the DNAT rule. Proceed to the page anyway.

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/Petclinic-External.jpeg)

## Additional Notes

This quick start deploys an Azure Application gateway with a basic listener. To host multiple sites on the same Application gateway, you can use multi-site listeners. For more information see https://docs.microsoft.com/azure/application-gateway/multiple-site-overview

Azure Application Gateway can also retrieve TLS certificates from Azure Key Vault. Fore more information see https://docs.microsoft.com/azure/application-gateway/key-vault-certs 

## Cleaning up

Unless you plan to perform additional tasks with the Azure resources from the quickstart (such as post deployment steps above), it is important to destroy the resources that you created to avoid the cost of keeping them provisioned.

The easiest way to do this is to call `az group delete`.

```azurecli
az group delete --name sc-corp-rg --yes --no-wait
```

## Change Log

- **03-05-21:** Update script to support bring your own route table [Azure Spring Apps documentation](https://docs.microsoft.com/azure/spring-cloud/spring-cloud-tutorial-deploy-in-azure-virtual-network#bring-your-own-route-table), add additional firewall rules and update MySQL Server TLS/SSL enforcement
- **03-08-21:** Fix typoes in README
- **03-09-21:** Add support for tagging and update README instructions
- **03-16-21** - Added third option to install PetClinic Application using PowerShell or Shell Script provided on the jumpbox
