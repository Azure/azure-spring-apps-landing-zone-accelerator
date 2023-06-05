# Variable Definition 
variable "project_name" {
  type        = string
  default     = "fitness-store"
  description = "Project Name"
}

variable "asa_cart_service" {
  type        = string
  default     = "cart-service"
  description = "Cart Service App Name"
}

variable "asa_order_service" {
  type        = string
  default     = "order-service"
  description = "Order Service App Name"
}

variable "asa_payment_service" {
  type        = string
  default     = "payment-service"
  description = "Payment Service App Name"
}

variable "asa_catalog_service" {
  type        = string
  default     = "catalog-service"
  description = "Catalog Service App Name"
}

variable "asa_frontend" {
  type        = string
  default     = "frontend"
  description = "Frontend App Name"
}

variable "asa_identity_service" {
  type        = string
  default     = "identity-service"
  description = "Identity Service App Name"
}

variable "asa_apps" {
  type        = list(string)
  default     = ["catalog_service", "payment_service", "identity_service"]
  description = "Varible used as keys to create apps"
}

variable "asa_apps_bind" {
  type        = list(string)
  default     = ["order_service", "cart_service", "frontend"]
  description = "Varible used as keys to create apps with Tanzu Component Binds"
}

variable "order_service_db_name" {
  type    = string
  default = "acmefit_order"
}

variable "catalog_service_db_name" {
  type    = string
  default = "acmefit_catalog"
}

locals {
  azure-metadeta      = "azure.extensions"
  spring_gateway_id   = "${data.azurerm_spring_cloud_service.sc_enterprise.id}/gateways/default"
  spring_registery_id = "${data.azurerm_spring_cloud_service.sc_enterprise.id}/serviceRegistries/default"
}

data "azurerm_client_config" "current" {}

# Configure Application Configuration Service for ASA
resource "azurerm_spring_cloud_configuration_service" "asa_config_svc" {
  name                    = "default"
  spring_cloud_service_id = data.azurerm_spring_cloud_service.sc_enterprise.id
  repository {
    name     = "acme-fitness-store-config"
    label    = "main"
    patterns = ["catalog", "identity", "payment"]
    uri      = "https://github.com/Azure-Samples/acme-fitness-store-config"
  }
}

# Configure Tanzu Build Service for ASA
resource "azurerm_spring_cloud_builder" "asa_builder" {
  name                    = "no-bindings-builder"
  spring_cloud_service_id = data.azurerm_spring_cloud_service.sc_enterprise.id
  build_pack_group {
    name           = "default"
    build_pack_ids = ["tanzu-buildpacks/nodejs", "tanzu-buildpacks/dotnet-core", "tanzu-buildpacks/go", "tanzu-buildpacks/python"]
  }
  stack {
    id      = "io.buildpacks.stacks.bionic"
    version = "full"
  }
}
# Create ASA Apps Service
resource "azurerm_spring_cloud_app" "asa_app_service" {
  name = lookup(zipmap(var.asa_apps,
    tolist([var.asa_order_service,
      var.asa_cart_service,
    var.asa_frontend])),
  var.asa_apps[count.index])

  resource_group_name = data.azurerm_resource_group.springapps_rg.name
  service_name        = data.azurerm_spring_cloud_service.sc_enterprise.name
  is_public           = true

  identity {
    type = "SystemAssigned"
  }
  count      = length(var.asa_apps)
  depends_on = [azurerm_spring_cloud_configuration_service.asa_config_svc]
}


# Create ASA Apps Service with Tanzu Component binds
resource "azurerm_spring_cloud_app" "asa_app_service_bind" {
  name = lookup(zipmap(var.asa_apps_bind,
    tolist([var.asa_catalog_service,
      var.asa_payment_service,
    var.asa_identity_service])),
  var.asa_apps_bind[count.index])

  resource_group_name = data.azurerm_resource_group.springapps_rg.name
  service_name        = data.azurerm_spring_cloud_service.sc_enterprise.name
  is_public           = true

  identity {
    type = "SystemAssigned"
  }

  addon_json = jsonencode({
    applicationConfigurationService = {
      resourceId = azurerm_spring_cloud_configuration_service.asa_config_svc.id
    }
    serviceRegistry = {
      resourceId = local.spring_registery_id
    }
  })

  count      = length(var.asa_apps_bind)
  depends_on = [azurerm_spring_cloud_configuration_service.asa_config_svc]
}

# Create ASA Apps Deployment
resource "azurerm_spring_cloud_build_deployment" "asa_app_deployment" {
  name = "default"
  spring_cloud_app_id = concat(azurerm_spring_cloud_app.asa_app_service,
  azurerm_spring_cloud_app.asa_app_service_bind)[count.index].id
  build_result_id = "<default>"

  quota {
    cpu    = "1"
    memory = "1Gi"
  }
  count = sum([length(var.asa_apps), length(var.asa_apps_bind)])
}

# Activate ASA Apps Deployment
resource "azurerm_spring_cloud_active_deployment" "asa_app_deployment_activation" {
  spring_cloud_app_id = concat(azurerm_spring_cloud_app.asa_app_service,
  azurerm_spring_cloud_app.asa_app_service_bind)[count.index].id
  deployment_name = azurerm_spring_cloud_build_deployment.asa_app_deployment[count.index].name

  count = sum([length(var.asa_apps), length(var.asa_apps_bind)])
}

# Postgres Flexible Server Connector for Order Service
resource "azurerm_spring_cloud_connection" "asa_app_order_connection" {
  name               = "order_service_db"
  spring_cloud_id    = azurerm_spring_cloud_build_deployment.asa_app_deployment[0].id
  target_resource_id = azurerm_postgresql_flexible_server_database.postgres_order_service_db.id
  client_type        = "dotnet"
  authentication {
    type   = "secret"
    name   = random_password.admin.result
    secret = random_password.password.result
  }
}

# Postgres Flexible Server Connector for Catalog Service
resource "azurerm_spring_cloud_connection" "asa_app_catalog_connection" {
  name               = "catalog_service_db"
  spring_cloud_id    = azurerm_spring_cloud_build_deployment.asa_app_deployment[3].id
  target_resource_id = azurerm_postgresql_flexible_server_database.postgres_catalog_service_db.id
  client_type        = "springBoot"

  authentication {
    type   = "secret"
    name   = random_password.admin.result
    secret = random_password.password.result
  }

}

##########################################
#  Spring Gateway Route Config
#  Moved to cli step until issue 21617 is resolved
##########################################

# # Create Routing for Catalog Service
resource "azurerm_spring_cloud_gateway_route_config" "asa_app_catalog_routing" {
  name                    = var.asa_catalog_service
  spring_cloud_gateway_id = local.spring_gateway_id
  spring_cloud_app_id     = azurerm_spring_cloud_app.asa_app_service_bind[0].id

  route {
    filters             = ["StripPrefix=0"]
    order               = 100
    predicates          = ["Path=/products", "Method=GET"]
    classification_tags = ["catalog"]
  }
  route {
    filters             = ["StripPrefix=0"]
    order               = 101
    predicates          = ["Path=/products/{id}", "Method=GET"]
    classification_tags = ["catalog"]
  }
  route {
    filters             = ["StripPrefix=0", "SetPath=/actuator/health/liveness"]
    order               = 103
    predicates          = ["Path=/catalogliveness", "Method=GET"]
    classification_tags = ["catalog"]
  }
  route {
    filters             = ["StripPrefix=0"]
    order               = 104
    predicates          = ["Path=/static/images/{id}", "Method=GET"]
    classification_tags = ["catalog"]
  }
  depends_on = [azurerm_spring_cloud_active_deployment.asa_app_deployment_activation]
}

# Create Routing for Order Service
resource "azurerm_spring_cloud_gateway_route_config" "asa_app_order_routing" {
  name                    = var.asa_order_service
  spring_cloud_gateway_id = local.spring_gateway_id
  spring_cloud_app_id     = azurerm_spring_cloud_app.asa_app_service[0].id

  route {
    description            = "Creates an order for the user."
    filters                = ["StripPrefix=0"]
    order                  = 200
    predicates             = ["Path=/order/add/{userId}", "Method=POST"]
    sso_validation_enabled = true
    title                  = "Create an order."
    token_relay            = true
    classification_tags    = ["order"]
  }
  route {
    description            = "Lookup all orders for the given user"
    filters                = ["StripPrefix=0"]
    order                  = 201
    predicates             = ["Path=/order/{userId}", "Method=GET"]
    sso_validation_enabled = true
    title                  = "Retrieve User's Orders."
    token_relay            = true
    classification_tags    = ["order"]
  }
  depends_on = [azurerm_spring_cloud_active_deployment.asa_app_deployment_activation]
}

# Create Routing for Cart Service
resource "azurerm_spring_cloud_gateway_route_config" "asa_app_cart_routing" {
  name                    = var.asa_cart_service
  spring_cloud_gateway_id = local.spring_gateway_id
  spring_cloud_app_id     = azurerm_spring_cloud_app.asa_app_service[1].id

  route {
    filters                = ["StripPrefix=0"]
    order                  = 300
    predicates             = ["Path=/cart/item/add/{userId}", "Method=POST"]
    sso_validation_enabled = true
    token_relay            = true
    classification_tags    = ["cart"]
  }
  route {
    filters                = ["StripPrefix=0"]
    order                  = 301
    predicates             = ["Path=/cart/item/modify/{userId}", "Method=POST"]
    sso_validation_enabled = true
    token_relay            = true
    classification_tags    = ["cart"]
  }
  route {
    filters                = ["StripPrefix=0"]
    order                  = 302
    predicates             = ["Path=/cart/items/{userId}", "Method=GET"]
    sso_validation_enabled = true
    token_relay            = true
    classification_tags    = ["cart"]
  }
  route {
    filters                = ["StripPrefix=0"]
    order                  = 303
    predicates             = ["Path=/cart/clear/{userId}", "Method=GET"]
    sso_validation_enabled = true
    token_relay            = true
    classification_tags    = ["cart"]
  }
  route {
    filters                = ["StripPrefix=0"]
    order                  = 304
    predicates             = ["Path=/cart/total/{userId}", "Method=GET"]
    sso_validation_enabled = true
    token_relay            = true
    classification_tags    = ["cart"]
  }
  depends_on = [azurerm_spring_cloud_active_deployment.asa_app_deployment_activation]
}

# Create Routing for Identity Service
resource "azurerm_spring_cloud_gateway_route_config" "asa_app_identity_routing" {
  name                    = var.asa_identity_service
  spring_cloud_gateway_id = local.spring_gateway_id
  spring_cloud_app_id     = azurerm_spring_cloud_app.asa_app_service_bind[2].id

  route {
    filters                = ["RedirectTo=302, /"]
    order                  = 1
    predicates             = ["Path=/acme-login", "Method=GET"]
    sso_validation_enabled = true
    classification_tags    = ["sso"]
  }
  route {
    filters                = ["RedirectTo=302, /whoami", "SetResponseHeader=Cache-Control, no-store"]
    order                  = 2
    predicates             = ["Path=/userinfo", "Method=GET"]
    sso_validation_enabled = true
    token_relay            = true
    classification_tags    = ["users"]
  }
  route {
    order                  = 3
    predicates             = ["Path=/verify-token", "Method=POST"]
    sso_validation_enabled = true
    uri                    = "no://op"
    classification_tags    = ["users"]
  }
  route {
    filters                = ["StripPrefix=0"]
    order                  = 4
    predicates             = ["Path=/whoami", "Method=GET"]
    sso_validation_enabled = true
    token_relay            = true
    classification_tags    = ["users"]

  }
  depends_on = [azurerm_spring_cloud_active_deployment.asa_app_deployment_activation]
}

# Create Routing for Frontend
resource "azurerm_spring_cloud_gateway_route_config" "asa_app_frontend_routing" {
  name                    = var.asa_frontend
  spring_cloud_gateway_id = local.spring_gateway_id
  spring_cloud_app_id     = azurerm_spring_cloud_app.asa_app_service[2].id

  route {
    filters             = ["StripPrefix=0"]
    order               = 1000
    predicates          = ["Path=/**", "Method=GET"]
    classification_tags = ["frontend"]
  }
  depends_on = [azurerm_spring_cloud_active_deployment.asa_app_deployment_activation]
}

