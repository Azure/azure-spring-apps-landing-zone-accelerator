


resource "random_string" "random_open_ai" {
  length  = 4
  upper   = false
  special = false
}



resource "azurerm_subnet" "openai" {
  name                 = "snet-openai"
  resource_group_name  = data.azurerm_resource_group.spoke_rg.name
  virtual_network_name = data.azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["${var.openai_CIDR}"]

}

resource "azurerm_network_security_group" "openai" {
  name                = "snet-openai-nsg"
  location            = data.azurerm_resource_group.spoke_rg.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
}

resource "azurerm_subnet_network_security_group_association" "openai" {
  subnet_id                 = azurerm_subnet.openai.id
  network_security_group_id = azurerm_network_security_group.openai.id
}

resource "azurerm_private_dns_zone" "openai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = data.azurerm_resource_group.private_zones_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai" {
  name = "openai-spoke-link"

  resource_group_name   = data.azurerm_resource_group.private_zones_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.openai.name
  virtual_network_id    = data.azurerm_virtual_network.spoke_vnet.id
}



resource "azurerm_cognitive_account" "open_ai_account" {
  name                = "ca-${var.name_prefix}-openai"
  location            = data.azurerm_resource_group.springapps_rg.location
  resource_group_name = data.azurerm_resource_group.springapps_rg.name
  kind                = "OpenAI"
  sku_name            = "S0"

  custom_subdomain_name         = random_string.random_open_ai.result
  public_network_access_enabled = false
}

resource "azurerm_cognitive_deployment" "text-embedding-ada-002" {
  name                 = "text-embedding-ada-002"
  cognitive_account_id = azurerm_cognitive_account.open_ai_account.id
  model {
    format  = "OpenAI"
    name    = "text-embedding-ada-002"
    version = "2"
  }

  scale {
    type = "Standard"
  }
}


resource "azurerm_cognitive_deployment" "gpt-35-turbo-16k" {
  name                 = "gpt-35-turbo-16k"
  cognitive_account_id = azurerm_cognitive_account.open_ai_account.id
  model {
    format  = "OpenAI"
    name    = "gpt-35-turbo-16k"
    version = "0613"
  }

  scale {
    type     = "Standard"
    capacity = 120
  }
}


resource "azurerm_private_endpoint" "openai-pe01" {
  name                = "pe-${var.name_prefix}-openai"
  location            = data.azurerm_resource_group.spoke_rg.location
  resource_group_name = data.azurerm_resource_group.spoke_rg.name
  subnet_id           = azurerm_subnet.openai.id


  private_service_connection {
    name                           = "pe-${var.name_prefix}-openai"
    private_connection_resource_id = azurerm_cognitive_account.open_ai_account.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.openai.id]
  }
}
