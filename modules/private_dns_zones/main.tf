############################################
# Private DNS zones (global) + VNet links
############################################
# Private DNS zones are global. This module creates each zone ONCE and links it
# to every VNet in var.vnet_links (e.g. the primary and DR VNets), which is the
# correct pattern for a multi-region / peered deployment.
############################################

resource "azurerm_private_dns_zone" "this" {
  for_each = toset(var.zone_names)

  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

locals {
  # zone x vnet-link cartesian product
  links = {
    for pair in setproduct(var.zone_names, keys(var.vnet_links)) :
    "${pair[0]}|${pair[1]}" => {
      zone = pair[0]
      link = pair[1]
    }
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = local.links

  name                  = "vnetlink-${each.value.link}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone].name
  virtual_network_id    = var.vnet_links[each.value.link]
  registration_enabled  = false
  tags                  = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}
