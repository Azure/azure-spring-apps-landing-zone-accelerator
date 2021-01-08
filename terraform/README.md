# Azure Spring Cloud Lab

## Overview

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
