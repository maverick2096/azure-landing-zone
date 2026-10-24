###########################################################################
# Example usage of the key_vault module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "key_vault" {
#   source                     = "./modules/key_vault"
#   name                       = "kv-app-prod-eus"
#   location                   = "eastus"
#   resource_group_name        = module.resource_group.name
#   sku_name                   = "standard"
#   purge_protection           = true
#   soft_delete_retention_days = 90
#
#   # Private networking - no public access.
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   private_dns_zone_ids       = [var.kv_private_dns_zone_id] # privatelink.vaultcore.azure.net
#
#   # Diagnostics.
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#
#   # Grant the workload managed identity read access to secrets.
#   access_policy_object_ids = [module.managed_identity.principal_id]
#
#   tags = { environment = "prod" }
# }
