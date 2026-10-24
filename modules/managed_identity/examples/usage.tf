###########################################################################
# Example usage of the managed_identity module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "managed_identity" {
#   source              = "./modules/managed_identity"
#   name                = "id-app-prod-eus"
#   location            = "eastus"
#   resource_group_name = module.resource_group.name
#   tags                = { environment = "prod" }
# }
#
# # The principal_id output is then passed to the data-service modules so the
# # identity receives Key Vault access and data-plane RBAC, e.g.:
# #
# #   module "storage_account" {
# #     ...
# #     role_principal_ids = [module.managed_identity.principal_id]
# #   }
