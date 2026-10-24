############################################
# Resource Group
############################################
# A resource group has no private endpoint or per-resource diagnostic
# settings (activity logs are emitted at the subscription level), so this
# module only manages the group and its tags.
############################################

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}
