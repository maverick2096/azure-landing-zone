data "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_name
  resource_group_name = var.resource_group_name
}
resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.name
  location               = var.location
  resource_group_name    = var.resource_group_name
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_login_password
  sku_name               = var.sku_name
  version                = var.server_version
  storage_mb             = var.storage_mb
  auto_grow_enabled      = true
  backup_retention_days  = var.backup_retention_days
  #geo_redundant_backup_enabled      = true
  public_network_access_enabled = false
  tags                          = var.tags
  high_availability {
    mode = "SameZone"
  }
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
  }
}
resource "azurerm_private_dns_zone" "pgsqlflex_zone" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#Link DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "pgsql_dns_link" {
  name                  = "vnetlink-pgsql-${var.name}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.pgsqlflex_zone.name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_endpoint" "pesqlflex" {
  name                = "pe-${var.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  custom_network_interface_name = "nic-${var.name}"
  private_service_connection {
    name                           = "pgsql-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.this.id
    is_manual_connection           = false
    subresource_names              = ["postgresqlServer"]
  }
  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.pgsqlflex_zone.id]
  }
  timeouts {
    create = "60m"
    delete = "30m"
  }
}
resource "azurerm_private_dns_a_record" "postgres_a_record" {
  name                = local.pg_lower_name
  zone_name           = azurerm_private_dns_zone.pgsqlflex_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 3600
  records             = [azurerm_private_endpoint.pesqlflex.private_service_connection[0].private_ip_address]

  depends_on = [azurerm_private_endpoint.pesqlflex]
  lifecycle {
    ignore_changes = [records] # Avoid conflicts with Azure-managed records
  }
}
resource "azurerm_monitor_diagnostic_setting" "name" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_postgresql_flexible_server.this.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  # enabled_log {
  #   category = "audit"
  # }
  #  # Supported log categories
  enabled_log { category = "PostgreSQLLogs" }
  # enabled_log { category = "QueryStoreRuntimeStatistics" }
  # enabled_log { category = "QueryStoreWaitStatistics" }
  # enabled_log { category = "AutovacuumAndSchemaStatistics" }
  # enabled_log { category = "RemainingTransactions" }
  #enabled_metric {
  #  category = "AllMetrics"
  #}
  enabled_metric {
    category = "AllMetrics"
  }


}

# Get the NIC of the Private Endpoint
data "azurerm_network_interface" "pg_pe_nic" {
  name                = "nic-${var.name}"
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_private_endpoint.pesqlflex]
}

# ---------------------------
# Add Diagnostic Settings for NIC
# ---------------------------
resource "azurerm_monitor_diagnostic_setting" "nic_diagnostics" {
  name                       = "${azurerm_private_endpoint.pesqlflex.name}-nic-diag"
  target_resource_id         = data.azurerm_network_interface.pg_pe_nic.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  #enabled_metric {
  #  category = "AllMetrics"
  #}
  enabled_metric {
    category = "AllMetrics"
  }

}
###############################################################################
# PostgreSQL Flexible Server – Long-Term Retention (Vaulted Backups Policy)
# -Stg-AZ | Azure Gov Cloud Compatible
###############################################################################

###############################################################################
# Create a Backup Vault (Required for PostgreSQL LTR)
###############################################################################
# resource "azurerm_data_protection_backup_vault" "__pgsql_backup_vault" {
#   name                = var.postgres_backup_vault
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   datastore_type = "VaultStore"          # required
#   redundancy     = "GeoRedundant"        # or "LocallyRedundant" if required
#   identity {
#     type = "SystemAssigned"
#   }
#   tags           = var.tags
# }


# # 2. Backup Policy (correct schema as of provider ≥ 3.114)
# resource "azurerm_data_protection_backup_policy_postgresql_flexible_server" "__pgsql_ltr_policy" {
#   name      = "policy-pgsql-ltr-Stg-AZ"
#   vault_id  = azurerm_data_protection_backup_vault.__pgsql_backup_vault.id
#   backup_repeating_time_intervals = ["R/2025-11-09T02:00:00Z/P1W"]
#   time_zone                       = "America/Phoenix"
#   default_retention_rule {
#     life_cycle {
#       data_store_type = "VaultStore"
#       duration        = "P12W"
#     }
#   }
#   retention_rule {
#     name     = "yearly-retention"
#     priority = 10
#     criteria {
#       absolute_criteria = "FirstOfYear"
#     }
#     life_cycle {
#       data_store_type = "VaultStore"
#       duration        = "P5Y"
#     }
#   }
# }

# # Assign Contributor role to the Backup Vault’s SystemAssigned Identity
# resource "azurerm_role_assignment" "vault_contributor_pgsql" {
#   scope                = azurerm_postgresql_flexible_server.this.id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_data_protection_backup_vault.__pgsql_backup_vault.identity[0].principal_id

#   depends_on = [
#     azurerm_data_protection_backup_vault.__pgsql_backup_vault,
#     azurerm_postgresql_flexible_server.this
#   ]
# }
# # 3. Associate the Backup Policy with the PostgreSQL Flexible Server
# resource "azurerm_data_protection_backup_instance_postgresql_flexible_server" "__pgsql_ltr_instance" {
#   name             = "backup-pgsql-ltr-${azurerm_postgresql_flexible_server.this.name}"
#   location         = var.location
#   vault_id         = azurerm_data_protection_backup_vault.__pgsql_backup_vault.id
#   server_id        = azurerm_postgresql_flexible_server.this.id
#   backup_policy_id = azurerm_data_protection_backup_policy_postgresql_flexible_server.__pgsql_ltr_policy.id

#   depends_on = [
#     azurerm_postgresql_flexible_server.this,
#     azurerm_data_protection_backup_policy_postgresql_flexible_server.__pgsql_ltr_policy
#   ]
# }


output "postgresql_flexible_server_id" {
  value = azurerm_postgresql_flexible_server.this.id
}