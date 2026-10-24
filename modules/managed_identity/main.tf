############################################
# User-Assigned Managed Identity
############################################
# A managed identity is an Entra ID (Azure AD) principal and has no private
# endpoint or diagnostic settings of its own. This identity is intended to be
# attached to workloads (web/function apps) and granted data-plane access to
# Key Vault, Storage, ACR and Service Bus by the respective modules.
############################################

resource "azurerm_user_assigned_identity" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
