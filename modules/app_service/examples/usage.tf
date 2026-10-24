###########################################################################
# Example usage of the app_service (Linux Web App) module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "app_service" {
#   source              = "./modules/app_service"
#   app_name            = "app-web-prod-eus"
#   location            = "eastus"
#   resource_group_name = module.resource_group.name
#
#   # This module creates its OWN dedicated plan.
#   plan_name     = "asp-web-prod-eus"
#   plan_sku_name = "P1v3"
#
#   # Optional container image from ACR.
#   container_registry_url = "https://${module.acr.login_server}"
#   container_image_name   = "my-api"
#   container_image_tag    = "latest"
#
#   # Private networking - no public access.
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   private_dns_zone_ids       = [var.sites_private_dns_zone_id] # privatelink.azurewebsites.net
#   vnet_integration_subnet_id = var.webapp_integration_subnet_id
#
#   # Observability + workload identity.
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#   user_assigned_identity_ids = [module.managed_identity.id]
#
#   app_settings = { WEBSITES_PORT = "8080" }
#   tags         = { environment = "prod" }
# }
