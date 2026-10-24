############################################
# Service Bus Namespace (private-only)
############################################
# A private endpoint requires the Premium SKU.
resource "azurerm_servicebus_namespace" "ns" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  public_network_access_enabled = false
  local_auth_enabled            = false
  capacity                      = var.capacity
  premium_messaging_partitions  = var.premium_messaging_partitions

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

############################################
# Topics and Queues
############################################
resource "azurerm_servicebus_topic" "topics" {
  for_each             = toset(var.topics)
  name                 = each.key
  namespace_id         = azurerm_servicebus_namespace.ns.id
  partitioning_enabled = true
}

resource "azurerm_servicebus_queue" "queues" {
  for_each             = toset(var.queues)
  name                 = each.key
  namespace_id         = azurerm_servicebus_namespace.ns.id
  partitioning_enabled = true
}

############################################
# Data-plane RBAC - grant the managed identity
############################################
resource "azurerm_role_assignment" "data_role" {
  for_each             = toset(var.role_principal_ids)
  scope                = azurerm_servicebus_namespace.ns.id
  role_definition_name = var.role_definition_name
  principal_id         = each.value
}

############################################
# Private Endpoint (namespace) -> existing private DNS zone(s)
############################################
resource "azurerm_private_endpoint" "sb" {
  name                          = "pe-${var.name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = "nic-${var.name}"
  tags                          = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_servicebus_namespace.ns.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
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
resource "azurerm_monitor_diagnostic_setting" "sb" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_servicebus_namespace.ns.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "OperationalLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
