
# NIC for jump_host
resource "azurerm_network_interface" "jump_host" {
  name                = "${var.prefix_nic}${local.jumphost_name}${var.suffix_nic}"
  location            = var.location
  resource_group_name = azurerm_resource_group.shared_rg.name

  ip_configuration {
    name                          = "configuration"
    subnet_id                     = data.azurerm_subnet.snetsharedsubnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.jump_host_private_ip_addr
  }

  tags = var.tags
}


# Virtual Machine for jump_host 

resource "azurerm_virtual_machine" "jump_host" {
  name                = local.jumphost_name
  location            = var.location
  resource_group_name = azurerm_resource_group.shared_rg.name
  network_interface_ids = [
    azurerm_network_interface.jump_host.id
  ]
  vm_size = var.jump_host_vm_size

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix_disk}${local.jumphost_name}${var.suffix_disk}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = local.jumphost_name
    admin_username = local.jumphost_user
    admin_password = local.jumphost_pass
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }


  timeouts {
    create = "60m"
    delete = "2h"
  }

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "Installdependencies" {
  name                 = "${local.jumphost_name}-vmext"
  virtual_machine_id   = azurerm_virtual_machine.jump_host.id
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
           "https://raw.githubusercontent.com/Azure/azure-spring-apps-landing-zone-accelerator/main/Scenarios/ASA-Secure-Baseline/scripts/DeployDeveloperConfig.ps1"
    
           ]
    }
SETTINGS

}

