###########################################################################
# Example usage of the private_dns_zones module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "private_dns_zones" {
#   source              = "./modules/private_dns_zones"
#   resource_group_name = module.resource_group.name
#   zone_names = [
#     "privatelink.vaultcore.azure.net",
#     "privatelink.blob.core.windows.net",
#     "privatelink.azurecr.io",
#     "privatelink.servicebus.windows.net",
#     "privatelink.azurewebsites.net",
#     "privatelink.cognitiveservices.azure.com",
#   ]
#   # Link every zone to each region's VNet.
#   vnet_links = {
#     primary = module.virtual_network["primary"].vnet_id
#     dr      = module.virtual_network["dr"].vnet_id
#   }
#   tags = { environment = "prod" }
# }
#
# # Zone IDs are then consumed by the service modules, e.g.:
# #   private_dns_zone_ids = [module.private_dns_zones.zone_ids["privatelink.vaultcore.azure.net"]]
