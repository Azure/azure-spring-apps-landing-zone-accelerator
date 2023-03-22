variable "instance_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "spring_cloud_service_name" {
  type = string
}

variable "is_public" {
  type    = bool
  default = false
}

variable "service_connection_id" {
  type = string
}

locals {
  service_connection_name = "${replace(var.instance_name, "-", "_")}_service_connection"
}

resource "azurerm_spring_cloud_app" "app_instance" {
  name                = var.instance_name
  resource_group_name = var.resource_group_name
  service_name        = var.spring_cloud_service_name
  is_public           = var.is_public

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_spring_cloud_java_deployment" "app_instance" {
  name                = "default"
  spring_cloud_app_id = azurerm_spring_cloud_app.app_instance.id
  instance_count      = 1
  jvm_options         = "-Xms2048m -Xmx2048m"
  runtime_version     = "Java_17"

  quota {
    cpu    = "2"
    memory = "2Gi"
  }

  lifecycle {
    ignore_changes = [
      environment_variables
    ]
  }
}

resource "azurerm_spring_cloud_active_deployment" "app_instance" {
  spring_cloud_app_id = azurerm_spring_cloud_app.app_instance.id
  deployment_name     = azurerm_spring_cloud_java_deployment.app_instance.name
}

resource "azurerm_spring_cloud_connection" "app_instance" {
  name               = local.service_connection_name
  spring_cloud_id    = azurerm_spring_cloud_java_deployment.app_instance.id
  target_resource_id = var.service_connection_id

  authentication {
    type = "systemAssignedIdentity"
  }
}
