###########################################################################
# Example usage of the virtual_network module.
# Commented out on purpose - copy into your root module and adjust.
###########################################################################

# module "virtual_network" {
#   source              = "./modules/virtual_network"
#   name                = "vnet-app-prod-eus"
#   location            = "eastus"
#   resource_group_name = module.resource_group.name
#   address_space       = ["10.0.0.0/16"]
#
#   subnets = {
#     private_endpoint = { address_prefixes = ["10.0.0.0/24"] }
#     apps             = { address_prefixes = ["10.0.1.0/24"], delegation = "Microsoft.Web/serverFarms" }
#     vm               = { address_prefixes = ["10.0.2.0/24"] }
#   }
#
#   tags = { environment = "prod" }
# }
