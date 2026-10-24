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

locals {
  # Build an application_stack block only when a runtime version is supplied.
  runtime_set = (
    var.node_version != null ||
    var.python_version != null ||
    var.dotnet_version != null ||
    var.java_version != null
  )
}

############################################
# Linux Function App (private-only)
############################################
resource "azurerm_linux_function_app" "fn" {
  name                = var.function_app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.plan.id

  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  https_only                    = true
  public_network_access_enabled = false
  virtual_network_subnet_id     = var.vnet_integration_subnet_id

  identity {
    type         = length(var.user_assigned_identity_ids) > 0 ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  app_settings = var.app_settings

  site_config {
    always_on                              = true
    ftps_state                             = "Disabled"
    minimum_tls_version                    = var.minimum_tls_version
    vnet_route_all_enabled                 = true
    http2_enabled                          = true
    application_insights_connection_string = var.application_insights_connection_string

    dynamic "application_stack" {
      for_each = local.runtime_set ? [1] : []
      content {
        node_version   = var.node_version
        python_version = var.python_version
        dotnet_version = var.dotnet_version
        java_version   = var.java_version
      }
    }
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
resource "azurerm_private_endpoint" "fn" {
  name                          = "pe-${var.function_app_name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = "nic-${var.function_app_name}"
  tags                          = var.tags

  private_service_connection {
    name                           = "psc-${var.function_app_name}"
    private_connection_resource_id = azurerm_linux_function_app.fn.id
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
resource "azurerm_monitor_diagnostic_setting" "fn" {
  name                       = "diag-${var.function_app_name}"
  target_resource_id         = azurerm_linux_function_app.fn.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
