############################################
# Storage Account (private-only)
############################################
resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind

  # Security hardening - no public access (reachable only via private endpoint).
  public_network_access_enabled   = false
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allowed_copy_scope              = "AAD"
  shared_access_key_enabled       = var.shared_access_key_enabled
  default_to_oauth_authentication = true

  tags = var.tags

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

############################################
# Containers
############################################
resource "azurerm_storage_container" "container" {
  for_each              = toset(var.containers)
  name                  = each.key
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}

############################################
# Data-plane RBAC - grant the managed identity blob access
############################################
resource "azurerm_role_assignment" "blob_contributor" {
  for_each             = toset(var.role_principal_ids)
  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}

############################################
# Private Endpoint (blob only) -> existing private DNS zone(s)
############################################
resource "azurerm_private_endpoint" "blob" {
  name                          = "pe-${var.name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = "nic-${var.name}"
  tags                          = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
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
# Account-level metrics.
resource "azurerm_monitor_diagnostic_setting" "account" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_storage_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_metric {
    category = "AllMetrics"
  }
}

# Blob-service logs (read / write / delete).
resource "azurerm_monitor_diagnostic_setting" "blob" {
  name                       = "diag-blob-${var.name}"
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }
  enabled_log {
    category = "StorageWrite"
  }
  enabled_log {
    category = "StorageDelete"
  }

  enabled_metric {
    category = "Transaction"
  }
}
