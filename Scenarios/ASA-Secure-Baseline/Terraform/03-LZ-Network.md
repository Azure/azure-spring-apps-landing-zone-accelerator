# Create the Landing Zone Virtual Network (Spoke)

The following will be created:
* Resource Group for Landing Zone Networking (main.tf)
* Peering of Hub and Spoke Networks (hub_spoke_peering.tf)
* Private DNS Zones (private_dns-zones.tf)
* Subnets for Azure Spring Apps and supporting components (spoke_vnet_subnets.tf)
* RBAC for the Azure Spring Apps Resource Provider applied to the Spoke Virtual Network (spoke_vnet_rbac.tf) see [docs]](https://learn.microsoft.com/en-us/azure/spring-apps/how-to-deploy-in-azure-virtual-network?tabs=azure-portal#grant-service-permission-to-the-virtual-network)

Review and if needed, comment out and modify the variables within the "03 Spoke Virtual Network" section of the common variable definitons file parameters.tfvars](./parameters.tfvars). 

Sample:

```bash

##################################################
## 03 Spoke Virtual Network
##################################################
    # spoke_vnet_addr_prefix         = "10.1.0.0/16"
    # springboot-service-subnet-addr = "10.1.0.0/24"
    # springboot-apps-subnet-addr    = "10.1.1.0/24"
    # springboot-support-subnet-addr = "10.1.2.0/24"
    # shared-subnet-addr             = "10.1.4.0/24"
    # appgw-subnet-addr              = "10.1.5.0/24"

    # springboot-service-subnet-name = "snet-runtime"
    # springboot-apps-subnet-name    = "snet-app"
    # springboot-support-subnet-name = "snet-support"
    # shared-subnet-name             = "snet-shared"
    # appgw-subnet-name              = "snet-agw"

```
## Deploy the Landing Zone (spoke) Virtual Network

Navigate to the "/Scenarios/ASA-Secure-Baseline/Terraform/03-LZ-Network" directory. 

```bash
cd ../03-LZ-Network
```
Deploy using Terraform Init, Plan and Apply

```bash

# Ensure the following state management runtime variables have been defined:
#   STORAGEACCOUNTNAME = 'xxxxx'
#   CONTAINERNAME      = 'xxxxx'
#   TFSTATE_RG         = 'xxxxx'


terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"
```

```bash
terraform plan -out my.plan --var-file ../parameters.tfvars
```

```bash
terraform apply my.plan
```
# Optional: Bring your own Hub Virtual Network (BYOH)
If you have configured the (BYOH) option, you will need to have the owner of the hub VNet finish the Vnet Peering by adding a Virtual Network Peer from the Hub to the Spoke. 

See below sample on how to do this with [terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering):

```
resource "azurerm_virtual_network_peering" "hub_spoke_peering" {
   
    name                        = "hub_spoke_peer"
    resource_group_name         = "xxxx-xxxx"
    virtual_network_name        = "xxxx-xxxx"
    remote_virtual_network_id   = "xxxx-xxxx" 
}
```


### Next step

:arrow_forward: [Deploy the Shared Resources](./04-LZ-SharedResources.md)