###########################################################################
# Example usage of the storage_account module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "storage_account" {
#   source                   = "./modules/storage_account"
#   name                     = "stappprodeus001"
#   location                 = "eastus"
#   resource_group_name      = module.resource_group.name
#   account_tier             = "Standard"
#   account_replication_type = "ZRS"
#   containers               = ["data", "logs"]
#
#   # Private networking - blob only, no public access.
#   private_endpoint_subnet_id = var.private_endpoint_subnet_id
#   private_dns_zone_ids       = [var.blob_private_dns_zone_id] # privatelink.blob.core.windows.net
#
#   # Diagnostics + data-plane RBAC for the workload identity.
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#   role_principal_ids         = [module.managed_identity.principal_id]
#
#   tags = { environment = "prod" }
# }
