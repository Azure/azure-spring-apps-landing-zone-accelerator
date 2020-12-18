# Jump Box TF Module
# Subnet for jump_box
resource "azurerm_subnet" "jump_box" {
    name                        = "${var.jump_box_name}-subnet"
    resource_group_name         = var.resource_group_name
    virtual_network_name        = var.jump_box_vnet_name
    address_prefixes            = [var.jump_box_addr_prefix]
} 

# NIC for jump_box

resource "azurerm_network_interface" "jump_box" { 
    name                              = "${var.jump_box_name}-nic"
    location                          = var.location
    resource_group_name               = var.resource_group_name
    
    ip_configuration { 
        name                          = "configuration"
        subnet_id                     = azurerm_subnet.jump_box.id 
        private_ip_address_allocation = "Static"
        private_ip_address            = var.jump_box_private_ip_addr
    }
}

# NSG for jump_box Subnet

resource "azurerm_network_security_group" "jump_box" { 
    name                        = "${var.jump_box_name}-nsg"
    location                    = var.location
    resource_group_name         = var.resource_group_name
}

# Virtual Machine for jump_box 

resource "azurerm_virtual_machine" "jump_box" {
  name                  = var.jump_box_name 
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [ 
        azurerm_network_interface.jump_box.id
    ]
  vm_size               = var.jump_box_vm_size

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.jump_box_name}-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name      = var.jump_box_name
    admin_username     = var.jump_box_admin_username
    admin_password     = var.jump_box_password

  }

  os_profile_windows_config {
  }

}
