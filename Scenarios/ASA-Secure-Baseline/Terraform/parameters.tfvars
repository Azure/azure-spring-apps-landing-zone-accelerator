
##################################################
# REQUIRED
##################################################


# The Region to deploy to
    location              = "westus3"

# This Prefix will be used on most deployed resources.
# The environment will also be used as part of the name
    name_prefix           = "springlza"
    environment           = "dev"

# Deployment state storage information
    state_sa_name="xxxx-enter-the-storage-account-name-xxxx"
    container_name="springappsterraform"

# This can also be sourced from variable ARM_ACCESS_KEY
# https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#access_key
    access_key="xxxx-enter-the-access-key-here-xxxx"

##################################################
# Optional - Hub VNET / Bring your own HUB VNET
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
# Optional - Hub VNET / Bring your own Firewall/NVA
##################################################
# Specify IP of existing Firewall/NVA in BYO Hub

   # FW_IP = "10.0.1.4"

##################################################
# Optional - Jumpbox
##################################################
# The Jumpbox username defaults to "lzadmin"
# The Jumpbox password defaults to a Random password and stored to the KeyVault
# under the Jumpbox-Pass secret
# My_External_IP will be automatically calculated unless you specify it here.

    # jump_host_vm_size = "Standard_DS3_v2"
    # jump_host_admin_username = "lzadmin"
    # jump_host_password ="xxxxxx"
    # My_External_IP = "1.2.3.4/32"

##################################################
# Optional
##################################################
    # tags = { 
    #    project = "ASA-Accelerator"
    #    deployenv = "dev"
    # }


##################################################
# Optional - Networking
##################################################
    # hub_vnet_addr_prefix           = "10.0.0.0/16"
    # azurefw_addr_prefix            = "10.0.1.0/24"

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
# Optional - Zone Redundancy
##################################################
    # spring_apps_zone_redundant     = true
    # azure_firewall_zones           = [1,2,3]
    # azure_app_gateway_zones        = [1,2,3]
