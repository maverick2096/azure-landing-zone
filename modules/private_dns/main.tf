# resource "azurerm_private_dns_zone" "dns" {
#     name                = var.name
#     resource_group_name = var.resource_group_name
#     tags                = var.tags
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "this" {
#   for_each = { for idx, vnet_id in var.virtual_network_ids : format("%s-%02d", coalesce(var.link_name, "pdns-link"), idx + 1) => vnet_id }

#   name                  = each.key
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.dns.name
#   virtual_network_id    = each.value
#   registration_enabled  = false
# }

# resource "azurerm_private_dns_zone" "appsvc_zone" {
#   name                = "privatelink.azurewebsites.net"
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }

resource "azurerm_private_dns_zone" "webapp_zone" {
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# 4. Link DNS zone to VNet
# resource "azurerm_private_dns_zone_virtual_network_link" "webapp_dns_link" {
#   name                  = "vnetlink-appservices"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.webapp_zone.name
#   virtual_network_id    = var.virtual_network_id
# }

# resource "azurerm_private_dns_zone" "sa_zone" {
#   name                = var.saname
#   resource_group_name = var.resource_group_name
#   tags                          = var.tags
# }

# # 4. Link DNS zone to VNet
# resource "azurerm_private_dns_zone_virtual_network_link" "sa_dns_link" {
#   name                  = "vnetlink-storageaccounts"
#   resource_group_name   = var.resource_group_name
#   private_dns_zone_name = azurerm_private_dns_zone.sa_zone.name
#   virtual_network_id    = var.virtual_network_id
# }
