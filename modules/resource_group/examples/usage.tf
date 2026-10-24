###########################################################################
# Example usage of the resource_group module.
# This block is commented out on purpose - copy it into your root module
# (e.g. ../../main.tf) and adjust the values to call this module.
###########################################################################

# module "resource_group" {
#   source   = "./modules/resource_group"
#   name     = "rg-app-prod-eus"
#   location = "eastus"
#   tags = {
#     environment = "prod"
#     owner       = "platform-team"
#   }
# }
