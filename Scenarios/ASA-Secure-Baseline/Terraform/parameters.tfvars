
##################################################
## Global
##################################################
# The Region to deploy to
    location              = "eastus"

# This Prefix will be used on most deployed resources.  10 Characters max.
# The environment will also be used as part of the name
    name_prefix           = "springlza"
    environment           = "dev"

# Specify the Object ID for the "Azure Spring Apps Resource Provider" service principal in the customer's Azure AD Tenant
# Use this command to obtain:
#    az ad sp show --id e8de9221-a19c-4c81-b814-fd37c6caf9d2 --query id --output tsv

    SRINGAPPS_SPN_OBJECT_ID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# tags = { 
#    project = "ASA-Accelerator"
#    deployenv = "dev"
# }


##################################################
## 01 Remote Storage State configuration
##################################################

# Deployment state storage information
    state_sa_name="xxxx-enter-the-storage-account-name-xxxx"
    container_name="springappsterraform"

    #access_key="xxxx-enter-the-access-key-here-xxxx"

        # Note, it is recommended to use an environment variable for the access key.  The environment variable name is  ARM_ACCESS_KEY
        # For more info, see here https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#access_key

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

# To bring your own HUB VNET (Precreated Hub VNET), then specify the Name/RG/Subscription below
# and do not deploy the plan under "02-Hub-Network"

    # Hub_Vnet_Name         = ""
    # Hub_Vnet_RG           = ""
    # Hub_Vnet_Subscription = ""

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

##################################################
## Optional - 04 Shared - Jumpbox
##################################################
# The Jumpbox username defaults to "lzadmin"
# The Jumpbox password defaults to a Random password and stored to the KeyVault
# under the Jumpbox-Pass secret
# My_External_IP will be automatically calculated unless you specify it here.

    # jump_host_admin_username = "lzadmin"

    # jump_host_password ="xxxxxx"
    # Note: 
    # It is recommended to pass jump_host_password # as an environment variable
    # and not stored on the parameters file.
    # Example:
    # If using PowerShell
    #    $ENV:TF_VAR_jump_host_password="xxxxx"
    # If using Bash
    #    export TF_VAR_jump_host_password="xxxxx"
    
    # jump_host_vm_size = "Standard_DS3_v2"
    # My_External_IP = "1.2.3.4/32"

##################################################
## 05 Hub Azure Firewall
##################################################
    # azure_firewall_zones           = [1,2,3]

##################################################
## Optional - 05 BYO Hub VNET / Bring your own Firewall/NVA
##################################################
# Specify IP of existing Firewall/NVA in BYO Hub

   # FW_IP = "10.0.1.4"

##################################################
# 06 Azure Spring Apps
##################################################

    # spring_apps_zone_redundant     = true

##################################################
# 07 Application Gateway
##################################################

    # azure_app_gateway_zones        = [1,2,3]
    # backendPoolFQDN                = "default-replace-me.private.azuremicroservices.io"
    # certfilename                   = "mycertificate.pfx"