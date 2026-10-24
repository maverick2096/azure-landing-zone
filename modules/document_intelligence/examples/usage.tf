###########################################################################
# Example usage of the document_intelligence module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "document_intelligence" {
#   source              = "./modules/document_intelligence"
#   name                = "di-app-prod-eus"
#   location            = "eastus"
#   resource_group_name = module.resource_group.name
#   sku_name            = "S0"
#
#   # Private networking - no public access.
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   private_dns_zone_ids       = [var.cognitive_private_dns_zone_id] # privatelink.cognitiveservices.azure.com
#
#   # Diagnostics + data-plane role for the workload identity.
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#   role_principal_ids         = [module.managed_identity.principal_id]
#
#   tags = { environment = "prod" }
# }
