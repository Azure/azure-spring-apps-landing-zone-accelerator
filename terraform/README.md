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

    ```azurecli
    az login

    az account set --subscription "Your Subscription Name"
    ```

2. Run the following command to initialize the terraform modules.

    ```azurecli
    terraform init
    ```

3. Run the following command to plan the terraform deployment

  **Note:** Terraform will prompt you for the following variables: 
    - Jumphost administrator username
    - Jumphost administrator password
    - MySQL Db administrator username
    - MySQL Db administrator password

    ```azurecli
    terraform plan -out=springcloud.plan
    ````
    
    - [Azure Virtual Machine](https://azure.microsoft.com/en-us/services/virtual-machines/) administrator name and password
        - [Password syntax](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm)
        - [Administrator syntax](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-username-requirements-when-creating-a-vm)

    - [Azure database for MySQL](https://azure.microsoft.com/en-us/services/mysql/) administrator and password
        - [Password syntax](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-cli#create-an-azure-database-for-mysql-server)
        - [Administrator syntax](https://docs.microsoft.com/en-us/azure/mysql/quickstart-create-mysql-server-database-using-azure-cli#create-an-azure-database-for-mysql-server)



4. Finally, deploy the terraform Spring Cloud using the following command.

    ```azurecli
    terraform apply springcloud.plan
    ````

5. For each of the two route tables above, add the default route 0.0.0.0/0 with the Azure Firewall private IP as the Next Hop address.

## Post Deployment

Install one of the following sample applications:
* [Simple Hello World](https://docs.microsoft.com/en-us/azure/spring-cloud/spring-cloud-quickstart?tabs=Azure-CLI&pivots=programming-language-java)
* [Pet Clinic App with MySQL Integration](https://github.com/azure-samples/spring-petclinic-microservices)

## Cleaning up

Unless you plan to perform additional tasks with the Azure resources from the quickstart (such 
as post deployment steps above), it is important to destroy the resources that you created 
to avoid the cost of keeping them provisioned.

The easiest way to do this is to call `terraform destroy`.

```azurecli
terraform destroy
```
## Known Issues

There is an existing ARM caching issue which causes the terraform default route update to fail. This issue is common when selecting East US 2. A 10 minute delay added to minimize the occurrence of this problem. The error message that appears is documented below:

```azurecli
Error: Invalid index

  on modules/azure_spring_cloud/main.tf line 111, in resource "azurerm_route" "default_egress_apps":
 111:   route_table_name              = data.azurerm_resources.route_table_apps.resources[0].name
    |----------------
    | data.azurerm_resources.route_table_apps.resources is empty list of object

The given key does not identify an element in this collection value.


Error: Invalid index

  on modules/azure_spring_cloud/main.tf line 135, in resource "azurerm_route" "default_egress_runtime":
 135:   route_table_name              = data.azurerm_resources.route_table_runtime.resources[0].name
    |----------------
    | data.azurerm_resources.route_table_runtime.resources is empty list of object

The given key does not identify an element in this collection value.
```

If you encounter this error, there are two options to correct this:

* **Option 1**: Comment or  the terraform route table update code under the **azure_spring_cloud** module.

```azurecli
data "azurerm_resources" "route_table_apps" {
  type = "Microsoft.Network/routeTables"
  resource_group_name           = "${var.sc_service_name}-apps-rg"
  depends_on = [time_sleep.wait_600_seconds]
}

resource "azurerm_route" "default_egress_apps" {
  name                          = "default" 
  route_table_name              = data.azurerm_resources.route_table_apps.resources[0].name

  resource_group_name           = "${var.sc_service_name}-apps-rg"
  address_prefix              = "0.0.0.0/0"
  next_hop_type               = "VirtualAppliance"
  next_hop_in_ip_address      =  var.azure_fw_private_ip  
}

resource "time_sleep" "wait_600_seconds" {
  depends_on = [azurerm_spring_cloud_service.sc]
  create_duration = "600s"
}

data "azurerm_resources" "route_table_runtime" {
  type = "Microsoft.Network/routeTables"
  resource_group_name           = "${var.sc_service_name}-runtime-rg"
  depends_on = [time_sleep.wait_600_seconds]
}

resource "azurerm_route" "default_egress_runtime" {
  name                          = "default" 
  route_table_name              = data.azurerm_resources.route_table_runtime.resources[0].name

  resource_group_name           = "${var.sc_service_name}-runtime-rg"
  address_prefix              = "0.0.0.0/0"
  next_hop_type               = "VirtualAppliance"
  next_hop_in_ip_address      =  var.azure_fw_private_ip  
}
```
Once this section is commented out/removed, the Azure Firewall default internet route be manually added to both the Spring Cloud Apps and Spring Cloud Service route tables. Within each of the apps and runtime resource groups, there should be a route table that has the following naming pattern:

```azurecli
aks-agentpool-xxxxxxxx-routetable
```
Where xxxxxxxx is a random generated number for your specific deployment.

* **Option 2:** Wait for the Azure ARM cache to refresh and re-run the terraform apply script. The refresh time can vary depending on the selected region.

[Azure Resource Explorer](https://resources.azure.com) can be used to confirm that the route tables have been cached. You can navigate to Subscription Name -> ResourceGroups and find the two resource groups automatically created for the Spring Cloud runtime resource group and Spring Cloud apps resource group.
