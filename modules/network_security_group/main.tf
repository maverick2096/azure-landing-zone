data "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_security_rule" "rules" {
  for_each = { for r in var.security_rules : r.name => r }

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = try(each.value.source_port_range, null)
  source_port_ranges           = try(each.value.source_port_ranges, null)
  destination_port_range       = try(each.value.destination_port_range, null)
  destination_port_ranges      = try(each.value.destination_port_ranges, null)
  source_address_prefix        = try(each.value.source_address_prefix, null)
  source_address_prefixes      = try(each.value.source_address_prefixes, null)
  destination_address_prefix   = try(each.value.destination_address_prefix, null)
  destination_address_prefixes = try(each.value.destination_address_prefixes, null)
  description                  = try(each.value.description, null)
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "subnet_assoc" {
  count                     = var.associate_to_subnet && var.subnet_id != null && var.subnet_id != "" ? 1 : 0
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.this.id
}
resource "azurerm_network_interface_security_group_association" "nic_assoc" {
  count                     = var.associate_to_nic && var.nic_id != null && var.nic_id != "" ? 1 : 0
  network_interface_id      = var.nic_id
  network_security_group_id = azurerm_network_security_group.this.id
}
# Network Watcher data source for Virtual Network Flow Logs
data "azurerm_network_watcher" "flow_logs" {
  count               = var.flow_log_storage_account_id != null ? 1 : 0
  name                = var.flow_log_network_watcher_name != null ? var.flow_log_network_watcher_name : "NetworkWatcher_${replace(replace(var.location, " ", ""), "-", "")}"
  resource_group_name = var.flow_log_network_watcher_resource_group_name
}
# Log Analytics Workspace data source for Traffic Analytics
locals {
  law_resource_id_parts = var.flow_log_enable_traffic_analytics && var.flow_log_traffic_analytics_workspace_id != null ? {
    resource_group = element(split("/", var.flow_log_traffic_analytics_workspace_id), 4)
    workspace_name = element(split("/", var.flow_log_traffic_analytics_workspace_id), 8)
  } : null
}
data "azurerm_log_analytics_workspace" "traffic_analytics" {
  count               = var.flow_log_enable_traffic_analytics && var.flow_log_traffic_analytics_workspace_id != null && local.law_resource_id_parts != null ? 1 : 0
  name                = local.law_resource_id_parts.workspace_name
  resource_group_name = local.law_resource_id_parts.resource_group
}
/*
# Virtual Network Flow Log for this subnet (created by default when storage_account_id is provided)
resource "azurerm_network_watcher_flow_log" "subnet" {
  count = var.flow_log_storage_account_id != null && var.subnet_id != null && var.subnet_id != "" && length(data.azurerm_network_watcher.flow_logs) > 0 ? 1 : 0
  name                      = "flowlog-${replace(var.name, "nsg-", "")}"
  network_watcher_name      = data.azurerm_network_watcher.flow_logs[0].name
  resource_group_name      = data.azurerm_network_watcher.flow_logs[0].resource_group_name
  target_resource_id       = var.subnet_id
  storage_account_id       = var.flow_log_storage_account_id
  enabled                  = true
  retention_policy {
    enabled = var.flow_log_retention_days > 0
    days    = var.flow_log_retention_days
  }
  dynamic "traffic_analytics" {
    for_each = var.flow_log_enable_traffic_analytics && var.flow_log_traffic_analytics_workspace_id != null && length(data.azurerm_log_analytics_workspace.traffic_analytics) > 0 ? [1] : []
    content {
      enabled              = true
      workspace_id         = data.azurerm_log_analytics_workspace.traffic_analytics[0].workspace_id
      workspace_region     = var.flow_log_traffic_analytics_workspace_region
      workspace_resource_id = var.flow_log_traffic_analytics_workspace_id
      interval_in_minutes  = var.flow_log_traffic_analytics_interval
    }
  }
  tags = var.tags
}
*/
# Azure Monitor Diagnostic Settings for NSG
resource "azurerm_monitor_diagnostic_setting" "nsg_diagnostics" {
  count                          = var.enable_diagnostics && (var.log_analytics_workspace_id != null || var.diagnostics_storage_account_id != null || var.eventhub_authorization_rule_id != null) ? 1 : 0
  name                           = "diag-${var.name}"
  target_resource_id             = azurerm_network_security_group.this.id
  log_analytics_workspace_id     = var.log_analytics_workspace_id
  storage_account_id             = var.diagnostics_storage_account_id
  eventhub_authorization_rule_id = var.eventhub_authorization_rule_id
  eventhub_name                  = var.eventhub_name
  # NSG-specific log categories
  enabled_log {
    category_group = "allLogs"
  }
}
# resource "azurerm_subnet_network_security_group_association" "subnet_association" {
#   network_security_group_id  = azurerm_network_security_group.this.id
#   #subnet_id                  = var.subnet_id
#   subnet_id                  = var.subnet_id
#   depends_on = [azurerm_network_security_group.this]
# }

# Flow Logs Configuration 
#flow_log_storage_account_id                  = var.vnet_flow_log_config.storage_account_id
#flow_log_network_watcher_name                = var.vnet_flow_log_config.network_watcher_name
#flow_log_network_watcher_resource_group_name = var.vnet_flow_log_config.network_watcher_resource_group_name
#flow_log_retention_days                      = var.vnet_flow_log_config.retention_days
#flow_log_enable_traffic_analytics            = var.vnet_flow_log_config.enable_traffic_analytics
#flow_log_traffic_analytics_workspace_id      = var.vnet_flow_log_config.traffic_analytics_workspace_id
#flow_log_traffic_analytics_workspace_region = var.vnet_flow_log_config.traffic_analytics_workspace_region
#flow_log_traffic_analytics_interval         = var.vnet_flow_log_config.traffic_analytics_interval

