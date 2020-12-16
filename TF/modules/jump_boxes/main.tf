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
  tags                        = var.tags 
  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "server-os"
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

/*
resource "azurerm_network_security_rule" "jump_box_ssh" { 
    name                            = "${var.jump_box_name}-ssh"
    priority                        = 100
    direction                       = "Inbound"
    access                          = "Allow"
    protocol                        = "Tcp"
    source_port_range               = "*"
    destination_port_range          = "22"
    source_address_prefixes         = var.jump_box_ssh_source_addr_prefixes 
    destination_address_prefix      = azurerm_subnet.jump_box.address_prefixes[0]
    resource_group_name             = var.resource_group_name
    network_security_group_name     = azurerm_network_security_group.jump_box.name
}

resource "azurerm_subnet_network_security_group_association" "jump_box" { 
    subnet_id                   = azurerm_subnet.jump_box.id
    network_security_group_id   = azurerm_network_security_group.jump_box.id 
}
*/
# Virtual Machine for jump_box 

/*
resource "azurerm_linux_virtual_machine" "jump_box" {
    name                        = var.jump_box_name 
    resource_group_name         = var.resource_group_name
    location                    = var.location
    size                        = var.jump_box_vm_size
    admin_username              = var.jump_box_admin_username
    network_interface_ids = [ 
        azurerm_network_interface.jump_box.id
    ] 

    admin_ssh_key { 
        username                = var.jump_box_admin_username
        public_key              = file(var.jump_box_pub_key_name)
    }

    os_disk { 
        caching                 = "ReadWrite"
        storage_account_type    = "Standard_LRS"
    }

    source_image_reference { 
        publisher               = "Canonical"
        offer                   = "UbuntuServer"
        sku                     = "16.04-LTS"
        version                 = "latest"
    }
    
    tags                        = var.tags 
}
*/
/*
# Install jump_box with custom script extension 
resource "azurerm_virtual_machine_extension" "jump_box_install" { 
    name                        = "${var.jump_box_name}_vm_extension"
    virtual_machine_id          = azurerm_linux_virtual_machine.jump_box.id
    publisher                   = "Microsoft.Azure.Extensions"
    type                        = "CustomScript"
    type_handler_version        = "2.0"

    settings = <<SETTINGS
    {
        "script":"${filebase64("modules/jump_boxes/tools_install.sh")}"
    }
    SETTINGS
}*/