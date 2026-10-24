data "azurerm_client_config" "current" {}

############################################
# Key Vault
############################################
resource "azurerm_key_vault" "kv" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = coalesce(var.tenant_id, data.azurerm_client_config.current.tenant_id)
  sku_name                   = var.sku_name
  purge_protection_enabled   = var.purge_protection
  soft_delete_retention_days = var.soft_delete_retention_days

  # No public access - reachable only through the private endpoint.
  public_network_access_enabled = false

  # Authorization model: classic access policies (RBAC disabled).
  rbac_authorization_enabled = false

  tags = var.tags

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.network_acls_subnet_ids
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

############################################
# Access policies
############################################
# Deployer / pipeline identity - full management so secrets can be seeded.
resource "azurerm_key_vault_access_policy" "deployer" {
  count        = var.grant_deployer_access ? 1 : 0
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = coalesce(var.tenant_id, data.azurerm_client_config.current.tenant_id)
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions      = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"]
  key_permissions         = ["Get", "List", "Create", "Delete", "Recover", "Backup", "Restore", "Purge"]
  certificate_permissions = ["Get", "List", "Create", "Delete", "Recover", "Backup", "Restore", "Purge"]
}

# Managed identity (and any other workload principals) - data-plane read.
resource "azurerm_key_vault_access_policy" "principals" {
  for_each     = toset(var.access_policy_object_ids)
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = coalesce(var.tenant_id, data.azurerm_client_config.current.tenant_id)
  object_id    = each.value

  secret_permissions      = var.principal_secret_permissions
  key_permissions         = var.principal_key_permissions
  certificate_permissions = var.principal_certificate_permissions
}

############################################
# Private Endpoint (vault) -> existing private DNS zone(s)
############################################
resource "azurerm_private_endpoint" "kv" {
  name                          = "pe-${var.name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = "nic-${var.name}"
  tags                          = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "privatelink-dns-zone-group"
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
resource "azurerm_monitor_diagnostic_setting" "kv" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
