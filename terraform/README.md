# Terraform Quickstart - Azure Spring Cloud Reference Architecture

## Overview

## Prerequisites

**Note:** *You must have owner privileges on the target subscription. This script will automatically assign the Azure Spring Cloud Resource Provider Owner rights on the created VNET.*

1. [Install Hashicorp Terraform](https://www.terraform.io/downloads.html)

    **Note:** This script was tested using the following terraform version:
    https://registry.terraform.io/providers/hashicorp/azurerm/2.42.0
    Earlier and later versions will need to be independently tested and verified.

2. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Deployment

1. Login to Azure and select the target subscription.

```bash
  az login

  az account set --subscription "Your Subscription Name"
```

2. Run the following command to initialize the terraform modules.

```bash
  terraform init
```

3. Run the following command to plan the terraform deployment

  **Note:** Terraform will prompt you for the following variables:  
    - Jumphost administrator username
    - Jumphost administrator password
    - MySQL Db administrator username
    - MySQL Db administrator password

  *    Azure Virtual Machine [administrator name ](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm) and [password](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm) requirements.

  *    Azure database for MySQL [administrator name](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-cli#create-an-azure-database-for-mysql-server) and [password](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-cli#create-an-azure-database-for-mysql-server) requirements.

```bash
  terraform plan -out=springcloud.plan
```

4. Finally, deploy the terraform Spring Cloud using the following command.

```bash
  terraform apply springcloud.plan
```

5. For each of the two route tables above, add the default route 0.0.0.0/0 with the Azure Firewall private IP as the Next Hop address.

## Post Deployment

Install one of the following sample applications:
* [Pet Clinic App with MySQL Integration](https://github.com/azure-samples/spring-petclinic-microservices) (Microservices with MySQL backend)
* [Simple Hello World](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-quickstart?tabs=Azure-CLI&pivots=programming-language-java)

## Deploy Azure Application Gateway with WAF (optional)

Here you will have 2 options:
- Option 1: Use a public Azure Application gateway for direct ingress.
- Option 2: Use a private Azure Application gateway in between Azure Firewall and the Azure Spring Cloud application (DNAT Rule and ingress on Azure Firewall).

1. You will need a TLS/SSL Certificate with the Private Key (PFX Format) for the Application Gateway Listener. The PFX certificate on the listener needs the entire certificate chain and the password must be 4 to 12 characters. For the purpose of this quickstart, you can use a self signed certificate or one issued from an internal Certificate Authority.

### Option 1 - Public Application Gateway

1. Change the directory to to deployPublicAppGW

```bash
    cd deployPublicAppGW
```

2. copy the SSL/TLS certificate PFX file to this directory.

3. Run the following command to initialize the terraform.

```bash
    terraform init
```

4. Run the following command to plan the terraform deployment.

```bash
    terraform plan -out=appgwpublic.plan
```

When prompted enter the values for the variables.

5. Once deployed, look for the Application Gateway Resource in the Resource Group and note the Frontend Public IP address.

6. From a browser that isn't in the quickstart virtual network, browse to https://`<publicIPofAppGW>`. You will get a warning in the browser that the connection is not secure. This is expected as we are connecting via the IP address. Proceed to the page anyway.

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/Petclinic-External.jpeg)

### Option 2 - Private Application Gateway behind Azure Firewall (DNAT)

1. Change the directory to to deployPrivateAppGW

```bash
    cd deployPrivateAppGW
```

2. copy the SSL/TLS certificate PFX file to this directory.

3. Run the following command to initialize the terraform.

```bash
    terraform init
```

4. Run the following command to plan the terraform deployment.

```bash
    terraform plan -out=appgwprivate.plan
```

When prompted enter the values for the variables.

5. Locate the Public IP of your Azure Firewall.

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/terraform/images/azfwpip.jpeg)

6. From a browser that isn't in the quickstart virtual network, browse to https://`<publicIPofAzFWNatRule>`. You will get a warning in the browser that the connection is not secure. This is expected as we are connecting via the IP address being used for the DNAT rule. Proceed to the page anyway.

![lab image](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/ARM/images/Petclinic-External.jpeg)

## Cleaning up

Unless you plan to perform additional tasks with the Azure resources from the quickstart (such 
as post deployment steps above), it is important to destroy the resources that you created 
to avoid the cost of keeping them provisioned.

The easiest way to do this is to call `terraform destroy`. Do this in both directories.

```bash
terraform destroy
```

## Change Log

**3-5-21** - Added bring your own route table as documented in the [Azure Spring Cloud documentation](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-tutorial-deploy-in-azure-virtual-network#bring-your-own-route-table)

## Additional Notes

You can use a custom domain suffix for your Azure Spring Cloud application instead of the default .private.azuremicrososervices.io domain suffix. See the [custom-domain](https://github.com/Azure/azure-spring-cloud-reference-architecture/blob/main/custom-domain/) section of this repo.