
# NIC for jump_host
resource "azurerm_network_interface" "jump_host" { 
    name                              = "${local.jumphost_name}-nic"
    location                          = var.location
    resource_group_name               = azurerm_resource_group.shared_rg.name
    
    ip_configuration { 
        name                          = "configuration"
        subnet_id                     = data.azurerm_subnet.snetsharedsubnet.id 
        private_ip_address_allocation = "Static"
        private_ip_address            = var.jump_host_private_ip_addr
    }
}


# Virtual Machine for jump_host 

resource "azurerm_virtual_machine" "jump_host" {
  name                  = local.jumphost_name
  location              = var.location
  resource_group_name   = azurerm_resource_group.shared_rg.name
  network_interface_ids = [
        azurerm_network_interface.jump_host.id
    ]
  vm_size               = var.jump_host_vm_size
 
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
 }
 
  storage_os_disk {
    name              = "${local.jumphost_name}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
 
  os_profile {
    computer_name      = local.jumphost_name
    admin_username     = var.jump_host_admin_username
    admin_password     = var.jump_host_password
  }
 
  os_profile_windows_config {
    provision_vm_agent = true
  }
 

  timeouts {
      create = "60m"
      delete = "2h"
  }
}
 
resource "azurerm_virtual_machine_extension" "Installdependencies" {
    name                    = "${local.jumphost_name}-vmext"
    virtual_machine_id = azurerm_virtual_machine.jump_host.id
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"
 
  protected_settings = <<PROTECTED_SETTINGS
    {
      "commandToExecute": "powershell.exe -Command \"./DeployDeveloperConfig.ps1; exit 0;\""
    }
  PROTECTED_SETTINGS
 
  settings = <<SETTINGS
    {
        "fileUris": [
           "https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/terraform/greenfield-deployment/scripts/DeployDeveloperConfig.ps1",
           "https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/petclinic/deployPetClinicApp.ps1",
           "https://raw.githubusercontent.com/Azure/azure-spring-cloud-reference-architecture/main/petclinic/deployPetClinicApp.sh"

           ]
    }
SETTINGS
  
}

