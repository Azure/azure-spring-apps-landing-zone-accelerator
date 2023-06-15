
##################################################
## Global
##################################################
# The Region to deploy to
location = "eastus"

# This Prefix will be used on most deployed resources.  10 Characters max.
# The environment will also be used as part of the name
name_prefix = "springent"
environment = "dev"

# Specify the Object ID for the "Azure Spring Apps Resource Provider" service principal in the customer's Azure AD Tenant
# Use this command to obtain:
#    az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv

SRINGAPPS_SPN_OBJECT_ID = "77e44c53-4911-427e-83c2-e2a52f569dee"

# tags = { 
#    project = "ASA-Accelerator"
#    deployenv = "dev"
# }


##################################################
## 01 Remote Storage State configuration
##################################################

# Deployment state storage information
state_sa_name           = "jeffdevopssa"
state_sa_rg             = "devops-rg"
state_sa_container_name = "springapps-ent"

##################################################
## 02 Hub Virtual Network
##################################################
# hub_vnet_addr_prefix           = "10.0.0.0/16"
# azurefw_addr_prefix            = "10.0.1.0/24"
# azurebastion_addr_prefix       = "10.0.0.0/24"

##################################################
# Optional 02 - Hub VNET / Bring your own HUB VNET
##################################################
# You can specify your own Hub Vnet Name and RG
# You can also specify a different subscription for the Hub Deployment.

# If you leave the Subscription empty, we will use the current Subscription

# To bring your own HUB VNET (Precreated Hub VNET), then specify the Name/RG/Subscription below, set Bring_Your_Own_Hub=true
# and do not deploy the plan under "02-Hub-Network"

# Bring_Your_Own_Hub    = false   # Only set this to true if you have created your own Hub

# Hub_Vnet_Name         = ""      # Must be set if Bring_Your_Own_Hub is true, otherwise leave empty for auto-naming
# Hub_Vnet_RG           = ""      # Must be set if Bring_Your_Own_Hub is true, otherwise leave empty for auto-naming
# Hub_Vnet_Subscription = ""      # Must be set if Bring_Your_Own_Hub is true

# Bastion_Name         = ""       # Leave empty for auto-naming
# Bastion_Nsg          = ""       # Leave empty for auto-naming
# Bastion_Pip          = ""       # Leave empty for auto-naming


##################################################
## 03 Spoke Virtual Network
##################################################

# Spoke_Vnet_Name              = ""    # Leave empty for auto-naming
# Spoke_Rg                     = ""    # Leave empty for auto-naming
# Spoke_Private_Dns_Rg         = ""    # Leave empty for auto-naming

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

##################################################
## Optional - 04 Shared - Jumpbox
##################################################
# The Jumpbox username defaults to "lzadmin"
# The Jumpbox password defaults to a Random password unless specified via paramater.
# If not specified, the random password is not provided.  Use the Reset Password feature to regain access.


# Shared_Rg                = ""   # Leave empty for auto-naming
# jump_host_admin_username = "lzadmin"


##################################################
## 05 Hub Azure Firewall
##################################################
# FW_Name                        = ""     # Leave empty for auto-naming
# azure_firewall_zones           = [1,2,3]

##################################################
## Optional - 05 BYO Hub VNET / Bring your own Firewall/NVA
##################################################
# Specify IP of existing Firewall/NVA in BYO Hub

# FW_IP = "10.0.1.4"

##################################################
# 06 Azure Spring Apps
##################################################
# SpringApps_Name                = ""  # Leave empty for auto-naming
# SpringApps_Rg                  = ""  # Leave empty for auto-naming

# spring_apps_zone_redundant     = true

##################################################
# 07 Application Gateway
##################################################

# APPGW_Name                     = ""   # Leave empty for auto-naming
# APPGW_Rg                       = ""   # Leave empty for auto-naming
# azure_app_gateway_zones        = [1,2,3]
# backendPoolFQDN                = "default-replace-me.private.azuremicroservices.io"
# certfilename                   = "mycertificate.pfx"


##################################################
# NAMING STANDARD CUSTOMIZATION
##################################################


### PREFIXES used when using plan default resource names.

### By default the following prefixes are used.
### If you prefer to use suffixes, uncomment and set the prefixes to an empty string ""
### then uncomment the suffixes, and specify as desired.

# prefix_rg           = "rg-"    
# prefix_vnet         = "vnet-"    
# prefix_bastion      = "bastion-"      
# prefix_nsg          = "nsg-"    
# prefix_pip          = "pip-"    
# prefix_nic          = "nic-"    
# prefix_keyvault     = "kv-"    
# prefix_law          = "law-"    
# prefix_app_insights = "ai-"    
# prefix_fw           = "fw-"    
# prefix_spring       = "spring-"    
# prefix_appgw        = "appgw-"    
# prefix_vm           = "vm"
# prefix_disk         = "disk-"    

# By default suffixes are blank unless uncommented out here

# suffix_rg           = ""    
# suffix_vnet         = ""    
# suffix_bastion      = ""      
# suffix_nsg          = ""    
# suffix_pip          = ""    
# suffix_nic          = ""    
# suffix_keyvault     = ""    
# suffix_law          = ""    
# suffix_app_insights = ""    
# suffix_fw           = ""    
# suffix_spring       = ""    
# suffix_appgw        = ""    
# suffix_vm           = ""
# suffix_disk         = ""
