
##################################################
# REQUIRED
##################################################


# The Region to deploy to
    location              = "westus3"

# This Prefix will be used on most deployed resources.
# The environment will also be used as part of the name
    name_prefix           = "springlza"
    environment           = "dev"

# Only populate Hub VNET name and RG if you have
# Precreated a Hub and Resource group that you want to use
# Otherwise leave blank

    Hub_Vnet_Name         = ""
    Hub_Vnet_RG           = ""

# Deployment state information
    state_sa_name="xxxx-enter-the-storage-account-name-xxxx"
    container_name="springappsterraform"

# This can also be sourced from variable ARM_ACCESS_KEY
# https://developer.hashicorp.com/terraform/language/settings/backends/azurerm#access_key
    access_key="xxxx-enter-the-access-key-here-xxxx"









##################################################
# Optional
##################################################
# jump_host_vm_size = "Standard_DS3_v2"
# tags
# jump_host_admin_username
# jump_host_password

##################################################
# Optional - Networking
##################################################
# hub_vnet_addr_prefix           = "10.0.0.0/16"
# azurefw_addr_prefix            = "10.0.1.0/24"

# spoke_vnet_addr_prefix         = "10.1.0.0/16"
# springboot-service-subnet-addr = "10.1.0.0/24"
# springboot-apps-subnet-addr    = "10.1.1.0/24"
# springboot-support-subnet-addr = "10.1.2.0/24"
# springboot-data-subnet-addr    = "10.1.3.0/24"
# shared-subnet-addr             = "10.1.4.0/24"
# appgw-subnet-addr              = "10.1.5.0/24"

# appgw-subnet-name              = "snet-agw"
# springboot-service-subnet-name = "snet-runtime"
# springboot-apps-subnet-name    = "snet-app"
# springboot-support-subnet-name = "snet-support"
# springboot-data-subnet-name    = "snet-data"
# shared-subnet-name             = "snet-shared"





