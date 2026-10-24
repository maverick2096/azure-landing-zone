############################################
# Log Analytics Workspace (private-only)
############################################
resource "azurerm_log_analytics_workspace" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_days

  # No public ingestion / query - traffic must flow through the AMPLS.
  internet_ingestion_enabled = false
  internet_query_enabled     = false

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

############################################
# Azure Monitor Private Link Scope (AMPLS)
############################################
resource "azurerm_monitor_private_link_scope" "this" {
  name                  = "ampls-${var.name}"
  resource_group_name   = var.resource_group_name
  ingestion_access_mode = var.ingestion_access_mode
  query_access_mode     = var.query_access_mode
  tags                  = var.tags
}

resource "azurerm_monitor_private_link_scoped_service" "law" {
  name                = "amplss-${var.name}"
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.this.name
  linked_resource_id  = azurerm_log_analytics_workspace.this.id
}

############################################
# Monitor private DNS zones (owned by this module)
############################################
locals {
  monitor_dns_zones = {
    monitor  = "privatelink.monitor.azure.com"
    oms      = "privatelink.oms.opinsights.azure.com"
    ods      = "privatelink.ods.opinsights.azure.com"
    agentsvc = "privatelink.agentsvc.azure-automation.net"
  }
}

resource "azurerm_private_dns_zone" "monitor" {
  for_each            = local.monitor_dns_zones
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "monitor" {
  for_each              = azurerm_private_dns_zone.monitor
  name                  = "vnetlink-${each.key}-${var.name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
}

############################################
# Private Endpoint to the AMPLS
############################################
# The AMPLS DNS zone group needs the four monitor zones created above plus the
# (shared) blob zone, when supplied, for the agent download path.
locals {
  ampls_zone_ids = concat(
    [for z in azurerm_private_dns_zone.monitor : z.id],
    var.blob_private_dns_zone_id == null ? [] : [var.blob_private_dns_zone_id],
  )
}

resource "azurerm_private_endpoint" "ampls" {
  name                          = "pe-${var.name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = "nic-${var.name}"
  tags                          = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_monitor_private_link_scope.this.id
    subresource_names              = ["azuremonitor"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "ampls-dns-zone-group"
    private_dns_zone_ids = local.ampls_zone_ids
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.monitor]

  lifecycle {
    ignore_changes = [
      tags,
      private_dns_zone_group,
    ]
  }
}

############################################
# Diagnostic settings (workspace -> itself) + PE NIC
############################################
resource "azurerm_monitor_diagnostic_setting" "law" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_log_analytics_workspace.this.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_log {
    category = "Audit"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
