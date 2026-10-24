###########################################################################
# Example usage of the app_insights module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "app_insights" {
#   source                     = "./modules/app_insights"
#   app_insights_name          = "appi-app-prod-eus"
#   location                   = "eastus"
#   resource_group_name        = module.resource_group.name
#   application_type           = "web"
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#   ampls_name                 = module.log_analytics.ampls_name
#   tags                       = { environment = "prod" }
# }
