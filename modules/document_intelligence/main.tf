############################################
# Azure AI Document Intelligence (Cognitive Services, kind = FormRecognizer)
############################################
# Private-only cognitive account for Document Intelligence (formerly Form
# Recognizer). A custom subdomain is required for private endpoints and
# Entra ID (token) authentication.
############################################

locals {
  custom_subdomain = var.custom_subdomain_name != "" ? var.custom_subdomain_name : lower(var.name)
}

resource "azurerm_cognitive_account" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "FormRecognizer"
  sku_name            = var.sku_name

  custom_subdomain_name = local.custom_subdomain

  # No public access - reachable only through the private endpoint.
  public_network_access_enabled      = false
  local_auth_enabled                 = var.local_auth_enabled
  outbound_network_access_restricted = false

  identity {
    type = "SystemAssigned"
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

############################################
# Data-plane RBAC - grant the managed identity
############################################
resource "azurerm_role_assignment" "cognitive_user" {
  for_each             = toset(var.role_principal_ids)
  scope                = azurerm_cognitive_account.this.id
  role_definition_name = var.role_definition_name
  principal_id         = each.value
}

############################################
# Private Endpoint (account) -> existing private DNS zone(s)
############################################
resource "azurerm_private_endpoint" "di" {
  name                          = "pe-${var.name}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.private_endpoint_subnet_id
  custom_network_interface_name = "nic-${var.name}"
  tags                          = var.tags

  private_service_connection {
    name                           = "psc-${var.name}"
    private_connection_resource_id = azurerm_cognitive_account.this.id
    is_manual_connection           = false
    subresource_names              = ["account"]
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
resource "azurerm_monitor_diagnostic_setting" "di" {
  name                       = "diag-${var.name}"
  target_resource_id         = azurerm_cognitive_account.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
