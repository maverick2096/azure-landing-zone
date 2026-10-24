###########################################################################
# Example usage of the app_service_plan module.
# Commented out on purpose - copy into your root module and adjust.
#
# NOTE: the app_service and function_app modules each create their OWN plan.
# Use this standalone module when you want a shared plan that several apps
# reference via their `service_plan_id` input.
###########################################################################

# module "app_service_plan" {
#   source                     = "./modules/app_service_plan"
#   plan_name                  = "asp-shared-prod-eus"
#   location                   = "eastus"
#   resource_group_name        = module.resource_group.name
#   os_type                    = "Linux"
#   sku_name                   = "P1v3"
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#   enable_autoscale           = true
#   tags                       = { environment = "prod" }
# }
