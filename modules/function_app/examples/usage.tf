###########################################################################
# Example usage of the function_app (Linux Function App) module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "function_app" {
#   source              = "./modules/function_app"
#   function_app_name   = "func-app-prod-eus"
#   location            = "eastus"
#   resource_group_name = module.resource_group.name
#
#   # This module creates its OWN dedicated plan.
#   plan_name     = "asp-func-prod-eus"
#   plan_sku_name = "P1v3"
#
#   # Backing storage (reuse the storage_account module).
#   storage_account_name       = module.storage_account.storage_account_name
#   storage_account_access_key = module.storage_account.primary_access_key
#
#   # Runtime (set one).
#   node_version = "20"
#
#   # Private networking - no public access.
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   private_dns_zone_ids       = [var.sites_private_dns_zone_id] # privatelink.azurewebsites.net
#   vnet_integration_subnet_id = var.webapp_integration_subnet_id
#
#   # Observability + workload identity.
#   log_analytics_workspace_id             = module.log_analytics.log_analytics_workspace_id
#   application_insights_connection_string = module.app_insights.connection_string
#   user_assigned_identity_ids             = [module.managed_identity.id]
#
#   tags = { environment = "prod" }
# }
