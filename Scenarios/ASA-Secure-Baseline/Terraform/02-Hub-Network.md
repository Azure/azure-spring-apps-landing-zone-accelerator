# Create the Hub Virtual Network

The following will be created:
* Resource Group for Hub Networking (main.tf)
* Hub Network (main.tf)
* Azure Bastion Host (azure_bastion.tf)

Review and if needed, comment out and modify the variables within the "02 Hub Virtual Network" section of the common variable definitons file [parameters.tfvars](./parameters.tfvars). Do not modify if you plan to use the default values. 

If you wish to bring your own Hub Virtual Network, skip to the [step](#optional-bring-your-own-hub-virtual-network) below (Bring your own Hub Virtual Network). 

Sample:

```bash

##################################################
## 02 Hub Virtual Network
##################################################
    # hub_vnet_addr_prefix           = "10.0.0.0/16"
    # azurefw_addr_prefix            = "10.0.1.0/24"
    # azurebastion_addr_prefix       = "10.0.0.0/24"

```

Navigate to the "/Scenarios/ASA-Secure-Baseline/Terraform/02-Hub-Network" directory. 

```bash
cd Scenarios/ASA-Secure-Baseline/Terraform/02-Hub-Network
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

Follow this section if you have an existing Hub virtual network you would like to use to peer with the Azure Spring Apps Landing Zone Vnet. Comment out and modify the variables within the "Optional 02 - Hub VNET / Bring your own HUB VNET" section of the variable definitons file paramaters.tfvars as needed.

Note: The following Spring Apps LZA features are **not** available when using Bring your own Hub Virtual Network:

   - Bidirectional VNET peering with the Hub Vnet (Peering is only initiated from the spoke. You will need to manually create the peering from the Hub Vnet)
   - Azure Firewall Deployment (assumption is that a firewall is already deployed in the hub if required)
   - Linking of Private DNS Zones to the Hub (Private DNS Zones are only linked to the Spoke Vnet)


Sample:

```bash 
##################################################
# Optional 02 - Hub VNET / Bring your own HUB VNET
##################################################
# You can specify your own Hub Vnet Name and RG
# You can also specify a different subscription for the Hub Deployment.

# If you leave the Subscription empty, we will use the current Subscription

# To bring your own HUB VNET (Precreated Hub VNET), then specify the Name/RG/Subscription below, set Bring_Your_Own_Hub=true
# and do not deploy the plan under "02-Hub-Network"

    # Bring_Your_Own_Hub    = true
    # Hub_Vnet_Name         = ""
    # Hub_Vnet_RG           = ""
    # Hub_Vnet_Subscription = ""

```
After Modifying the variables, move on to deploying the Spoke/LZ Virtual Network.

### Next step

:arrow_forward: [Deploy the Spoke/LZ Virtual Network](./03-LZ-Network.md)