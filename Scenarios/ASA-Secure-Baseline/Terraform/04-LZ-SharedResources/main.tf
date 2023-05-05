### Notice about changes ######################################################
# We recommend the use of parameters.tfvars for changes.
# Have a particular customization in mind not addressable via parameters.tfvars?
#  Consider filing a feature request at 
#  https://github.com/Azure/azure-spring-apps-landing-zone-accelerator/issues 
# 

data "terraform_remote_state" "lz-network" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.state_sa_container_name
    key                  = "lz-network"
    resource_group_name  = var.state_sa_rg
  }
}


resource "random_string" "random" {
  length = 4
  upper = false
  special = false
}

#Random password for Jump Host
resource "random_password" "jumphostpass" {
  length = 15
  upper = true
  special = true  
}


locals  {
  shared_rg                = ( var.Shared_Rg == "" ? "${var.prefix_rg}${var.name_prefix}-SHARED${var.suffix_rg}" : var.Shared_Rg)
 
  spoke_rg                 = data.terraform_remote_state.lz-network.outputs.spoke_rg
  spoke_vnet_name          = data.terraform_remote_state.lz-network.outputs.spoke_vnet_name
  subnet_shared_name       = var.shared-subnet-name
  subnet_cloudsupport_name = var.springboot-support-subnet-name

  private_dns_rg           = data.terraform_remote_state.lz-network.outputs.private_dns_rg

  jumphost_name            = substr("${var.prefix_vm}${var.name_prefix}${var.environment}${var.suffix_vm}",0,14)
  jumphost_user            = var.jump_host_admin_username

  # If a jumphost_pass was provided, then use that, otherwise, use a random password.
  jumphost_pass            = ( var.jump_host_password == "" ? random_password.jumphostpass.result : var.jump_host_password )
  password_notice          = ( var.jump_host_password == "" ? "To get access to the VM, use the Reset Password feature in the Azure Portal.\nAzure Portal > VM > Reset Password" : "A custom password was provided.  To reset go to Azure Portal > VM > Reset Password" )

  keyvault_name            = "${var.prefix_keyvault}${var.name_prefix}-${random_string.random.result}${var.suffix_keyvault}"
  law_name                 = "${var.prefix_law}${var.name_prefix}-${random_string.random.result}${var.suffix_law}"
}

# Get info about the current azurerm context
data "azurerm_client_config" "current" {}

# Get info about the existing Spoke VNET and subnets
data "azurerm_virtual_network" "spoke_vnet" {
  name                = local.spoke_vnet_name
  resource_group_name = local.spoke_rg
}

data "azurerm_subnet" "snetsharedsubnet" {
  name                 =  local.subnet_shared_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

data "azurerm_subnet" "azuresbcloudsupport" {
  name                 =  local.subnet_cloudsupport_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}


# Get info about Private DNS Zones
data "azurerm_private_dns_zone" "keyvault_zone" {
  name                 =  var.keyvault_dnszone_name
  resource_group_name  =  local.private_dns_rg

}

# Create the Shared Resource group 
resource "azurerm_resource_group" "shared_rg" {
    name                        = local.shared_rg
    location                    = var.location

    tags = var.tags
}



