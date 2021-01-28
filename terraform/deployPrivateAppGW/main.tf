terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.42"
    }
  }
}

provider "azurerm" {
    features {} 
}

data "azurerm_subnet" "azure_appgw" {
  name                 = var.appGW_subnet_name
  virtual_network_name = var.appGW_vnet_name
  resource_group_name  = var.resource_group_name
}

data "azurerm_public_ip" "az_fw" {
  name                = "azure-firewall-ip"
  resource_group_name = var.resource_group_name
}


locals {

    
    backend_address_pool = {
      fqdns = ["${var.backendPoolFQDN}"]
  }
  backend_address_pool_name               = "backend-pool"
  frontend_port_name                      = "port_443"
  frontend_ip_configuration_name          = "appGwPublicFrontendIp"
  private_frontend_ip_configuration_name  = "appGwPrivateFrontendIp"
  http_setting_name                       = "backend-httpsettings"
  listener_name                           = "myapp-listener-https"
  request_routing_rule_name               = "myapp-rule"  
}

resource "azurerm_public_ip" "azure_appgw" { 
    name                        = "appGW-ip"
    location                    = var.location
    resource_group_name         = var.resource_group_name
    allocation_method           = "Static"
    sku                         = "Standard" 
}

resource "azurerm_application_gateway" "azure_appgw" {
  name                = "appGW01"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_V2"
    capacity = 2
  }
  ssl_certificate {
    name     = "mySSLCert"
    data     = filebase64("./${var.certfilename}")
    password = var.https_password
  }
  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = "${data.azurerm_subnet.azure_appgw.id}"
  }

  frontend_port {
    name = local.frontend_port_name
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.azure_appgw.id
  }

  frontend_ip_configuration {
    name                 = local.private_frontend_ip_configuration_name
    subnet_id            = "${data.azurerm_subnet.azure_appgw.id}"
    private_ip_address_allocation = "Static"
    private_ip_address   = var.appGW_ILB_IP
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
    frontend_ip_configuration_name = local.private_frontend_ip_configuration_name
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
  }
  depends_on = [ azurerm_public_ip.azure_appgw ]
}

resource "azurerm_firewall_nat_rule_collection" "az_fw" {
  name                = "springCLoudIngressDNAT"
  azure_firewall_name = var.az_fw_name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "springCLoudIngressDNAT"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "443"
    ]

    destination_addresses = [
      "${data.azurerm_public_ip.az_fw.ip_address}"
    ]

    translated_port = 443

    translated_address = var.appGW_ILB_IP

    protocols = [
      "TCP"
      
      ]
    }
}