data "azurerm_log_analytics_workspace" "law" {
  name                = var.log_analytics_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_data_protection_resource_guard" "rg" {
  name                = "${var.name}-rg-backup-guard"
  location            = var.location
  resource_group_name = var.resource_group_name
}


resource "azurerm_recovery_services_vault" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  soft_delete_enabled           = true
  tags                          = var.tags
  public_network_access_enabled = false
  #cross_region_restore_enabled = true
  #cross_subscription_restore_enabled = false
  #resource_guard_id = azurerm_data_protection_resource_guard.rg.id
  immutability = "Locked"
}
resource "azurerm_recovery_services_vault_resource_guard_association" "rsv_assoc" {
  vault_id          = azurerm_recovery_services_vault.this.id
  resource_guard_id = azurerm_data_protection_resource_guard.rg.id
}
resource "azurerm_site_recovery_fabric" "primary" {
  name                = "primary-fabric-${var.name}"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  location            = var.location
}

resource "azurerm_site_recovery_protection_container" "primary" {
  name                 = "primary-container-${var.name}"
  resource_group_name  = var.resource_group_name
  recovery_vault_name  = azurerm_recovery_services_vault.this.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
}

resource "azurerm_private_dns_zone" "rsv_zone" {
  name                = "privatelink.backup.windowsazure.com"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link DNS zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "rsv_dns_link" {
  name                  = "vnetlink-rsv"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.rsv_zone.name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_private_endpoint" "rsv" {
  name                = "pe-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags


  custom_network_interface_name = "nic-${var.name}"
  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_recovery_services_vault.this.id
    is_manual_connection           = false
    subresource_names              = ["AzureBackup"]
  }

  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.rsv_zone.id]
  }
}

#Added newly
# BACKUP POLICIES
# 1. DEFAULT BACKUP POLICY (Standard 30-day retention)
resource "azurerm_backup_policy_vm" "default" {
  name                = "DefaultPolicy"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name

  # Backup Schedule
  backup {
    frequency = "Daily"
    time      = var.default_backup_time
  }

  # Retention Policy
  retention_daily {
    count = var.default_retention_daily_count
  }

  retention_weekly {
    count    = var.default_retention_weekly_count
    weekdays = var.default_retention_weekly_days
  }

  retention_monthly {
    count    = var.default_retention_monthly_count
    weekdays = var.default_retention_weekly_days
    weeks    = var.default_retention_monthly_weeks
  }

  retention_yearly {
    count    = var.default_retention_yearly_count
    weekdays = var.default_retention_weekly_days
    weeks    = var.default_retention_monthly_weeks
    months   = var.default_retention_yearly_months
  }

  # Policy Settings
  timezone = var.timezone
}


resource "azurerm_monitor_diagnostic_setting" "name" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_recovery_services_vault.this.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  # enabled_log {
  #   category = "ContainerRegistryLoginEvents"
  # }
  # Enable all log categories by group
  enabled_log {
    category_group = "allLogs"
  }
  # enabled_metric {
  #   category = "AllMetrics"
  # }
}

# Get the NIC of the Private Endpoint
# ---------------------------
data "azurerm_network_interface" "pe_nic" {
  name                = "nic-${var.name}"
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_private_endpoint.rsv]
}

# ---------------------------
# Add Diagnostic Settings for NIC
# ---------------------------
resource "azurerm_monitor_diagnostic_setting" "nic_diagnostics" {
  name                       = "${azurerm_private_endpoint.rsv.name}-nic-diag"
  target_resource_id         = data.azurerm_network_interface.pe_nic.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  #enabled_metric {
  #  category = "AllMetrics"
  #}
  enabled_metric {
    category = "AllMetrics"
  }
}