# Create the Landing Zone Network (Spoke)

The following will be created:
* Resource Group for Landing Zone Networking (main.tf)
* Peering of Hub and Spoke Networks (hub_spoke_peering.tf)
* Private DNS Zones (private_dns-zones.tf)
* Subnets for Azure Spring Apps and supporting components (spoke_vnet_subnets.tf)
* RBAC for the Azure Spring Apps Resource Provider applied to the Spoke Virtual Network (spoke_vnet_rbac.tf)

Review and if needed, comment out and modify the variables within the "03 Spoke Virtual Network" section of the variable definitons file paramaters.tfvars. 

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

Navigate to the "/Scenarios/ASA-Secure-Baseline-/Terraform/03-LZ-Network" directory. 

```bash
cd ../03-LZ-Network
```
Deploy using Terraform Init, Plan and Apply

```bash
terraform init -backend-config="resource_group_name=$TFSTATE_RG" -backend-config="storage_account_name=$STORAGEACCOUNTNAME" -backend-config="container_name=$CONTAINERNAME"
```

```bash
terraform plan -out my.plan --var-file ../parameters.tfvars
```

```bash
terraform apply my.plan
```

### Next step

:arrow_forward: [Deploy the Shared Resources](./04-LZ-SharedResources.md)