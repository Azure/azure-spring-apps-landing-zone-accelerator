# Azure Spring Cloud Quickstart

## Overview

## Prerequisites

**Note:** *You must have owner privileges on the target subscription. This script will automatically assign the Azure Spring Cloud Resource Provider Owner rights on the created VNET.*

1. [Install Hashicorp Terraform](https://www.terraform.io/downloads.html) - This script was built using version *0.14.4*

2. [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Deployment

1. Login to Azure and select the target subscription.

    ```azurecli
    az login

    az account set --subscription "Your Subscription Name"
    ```

2. Run the following command to initialize the terraform modules.

    ```azurecli
    terraform init
    ```

3. Run the following command to plan the terraform deployment

    ```azurecli
    terraform plan -out=springcloud.plan
    ````

4. Finally, deploy the terraform Spring Cloud using the following command.

    ```azurecli
    terraform apply springcloud.plan
    ````
5. There is a known caching issue which requires that the Azure Firewall default internet route be added manually to both the Azure Spring Cloud Apps and Service route tables. Within each of the apps and runtime resource groups, there should be a route table that has the following naming pattern:

```azurecli
aks-agentpool-xxxxxxxx-routetable
```
Where xxxxxxxx is a random generated number for your specific deployment.

6. For each of the two route tables above, add the default route 0.0.0.0/0 with the Azure Firewall private IP as the Next Hop address.

## Post Deployment

Install one of the following sample applications:
* [Simple Hello World](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-quickstart?tabs=Azure-CLI&pivots=programming-language-java)
* [Pet Clinic App with MySQL Integration](https://github.com/azure-samples/spring-petclinic-microservices)
