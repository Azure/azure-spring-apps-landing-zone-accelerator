
resource "azurerm_public_ip" "azure_appgw" { 
    name                        = "${local.appgw_name}-pip"
    location                    = var.location
    resource_group_name         = azurerm_resource_group.appgw_rg.name
    allocation_method           = "Static"
    sku                         = "Standard"

    tags = var.tags 
}

resource "azurerm_application_gateway" "azure_appgw" {
  name                = local.appgw_name
  resource_group_name = azurerm_resource_group.appgw_rg.name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
  ssl_certificate {
    name     = "mySSLCert"
    data     = filebase64("./${var.certfilename}")
    password = var.https_password
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = "${data.azurerm_subnet.appgwsubnet.id}"
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.azure_appgw.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = local.backend_address_pool.fqdns
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 60
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Https"
    ssl_certificate_name           = "mySSLCert"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority                   = 100
  }

  waf_configuration {
    enabled                    = true
    firewall_mode              = "Prevention"
    rule_set_version           = "3.2" 
  }

  zones = var.azure_app_gateway_zones

  tags = var.tags

  depends_on = [ azurerm_public_ip.azure_appgw ]
}




