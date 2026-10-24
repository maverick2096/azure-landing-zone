###########################################################################
# Example usage of the log_analytics module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "log_analytics" {
#   source              = "./modules/log_analytics"
#   name                = "law-app-prod-eus"
#   location            = "eastus"
#   resource_group_name = module.resource_group.name
#   sku                 = "PerGB2018"
#   retention_days      = 30
#
#   # AMPLS networking - workspace is private-only.
#   virtual_network_id         = var.virtual_network_id
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#
#   # Reuse the storage module's blob zone for the agent download path
#   # (optional - avoids creating a duplicate blob private DNS zone).
#   blob_private_dns_zone_id = var.blob_private_dns_zone_id
#
#   tags = { environment = "prod" }
# }
