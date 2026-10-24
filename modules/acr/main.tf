############################################
# Azure Container Registry (private-only)
############################################
# A private endpoint requires the Premium SKU.
resource "azurerm_container_registry" "acr" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"
  retention_policy_in_days      = var.retention_policy_in_days
  trust_policy_enabled          = var.trust_policy_enabled

  tags = var.tags

  identity {
    type = "SystemAssigned"
  }

  dynamic "georeplications" {
    for_each = var.georeplications
    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = try(georeplications.value.zone_redundancy_enabled, false)
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

############################################
# Data-plane RBAC - grant the managed identity AcrPull
############################################
resource "azurerm_role_assignment" "acr_pull" {
  for_each             = toset(var.role_principal_ids)
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = each.value
}

############################################
# Private Endpoint (registry) -> existing private DNS zone(s)
############################################
resource "azurerm_private_endpoint" "acr" {
  name                          = "pe-${var.name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = "nic-${var.name}"
  tags                          = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_container_registry.acr.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
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
resource "azurerm_monitor_diagnostic_setting" "acr" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_container_registry.acr.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
