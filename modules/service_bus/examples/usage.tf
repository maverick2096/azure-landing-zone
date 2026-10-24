###########################################################################
# Example usage of the service_bus module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "service_bus" {
#   source              = "./modules/service_bus"
#   name                = "sb-app-prod-eus"
#   location            = "eastus"
#   resource_group_name = module.resource_group.name
#   sku                 = "Premium" # required for private endpoints
#   capacity            = 1
#   topics              = ["events"]
#   queues              = ["jobs"]
#
#   # Private networking - no public access.
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   private_dns_zone_ids       = [var.servicebus_private_dns_zone_id] # privatelink.servicebus.windows.net
#
#   # Diagnostics + data role for the workload identity.
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#   role_principal_ids         = [module.managed_identity.principal_id]
#
#   tags = { environment = "prod" }
# }
