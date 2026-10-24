###########################################################################
# Example usage of the acr module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "acr" {
#   source              = "./modules/acr"
#   name                = "acrappprodeus"
#   location            = "eastus"
#   resource_group_name = module.resource_group.name
#   sku                 = "Premium" # required for private endpoints
#   admin_enabled       = false
#
#   # Private networking - no public access.
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   private_dns_zone_ids       = [var.acr_private_dns_zone_id] # privatelink.azurecr.io
#
#   # Diagnostics + AcrPull for the workload identity.
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#   role_principal_ids         = [module.managed_identity.principal_id]
#
#   tags = { environment = "prod" }
# }
