############################################
# Dedicated App Service Plan (created by this module)
############################################
resource "azurerm_service_plan" "plan" {
  name                = var.plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.plan_sku_name
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

############################################
# Linux Web App (private-only)
############################################
resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  https_only                    = true
  public_network_access_enabled = false
  virtual_network_subnet_id     = var.vnet_integration_subnet_id

  identity {
    type         = length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  app_settings = var.app_settings

  site_config {
    always_on                         = true
    http2_enabled                     = true
    ftps_state                        = "Disabled"
    minimum_tls_version               = var.minimum_tls_version
    vnet_route_all_enabled            = true
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = 10

    dynamic "application_stack" {
      for_each = var.container_image_name == null ? [] : [1]
      content {
        docker_registry_url = var.container_registry_url
        docker_image_name   = "${var.container_image_name}:${var.container_image_tag}"
      }
    }
  }

  logs {
    application_logs {
      file_system_level = "Error"
    }
  }

  auth_settings {
    enabled = false
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
      app_settings,
      site_config,
      sticky_settings,
      connection_string,
      virtual_network_subnet_id,
    ]
  }
}

############################################
# Private Endpoint (sites) -> existing private DNS zone(s)
############################################
resource "azurerm_private_endpoint" "app" {
  name                          = "pe-${var.app_name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = "nic-${var.app_name}"
  tags                          = var.tags

  private_service_connection {
    name                           = "psc-${var.app_name}"
    private_connection_resource_id = azurerm_linux_web_app.app.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  lifecycle {
    ignore_changes = [
      tags,
      private_dns_zone_group,
    ]
  }
}

############################################
# Diagnostic settings
############################################
resource "azurerm_monitor_diagnostic_setting" "app" {
  name                       = "diag-${var.app_name}"
  target_resource_id         = azurerm_linux_web_app.app.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
