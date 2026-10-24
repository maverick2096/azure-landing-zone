###########################################################################
# Example usage of the virtual_machine module.
# Commented out on purpose - copy into your root module and adjust.
#
# Supports Windows and Linux. The NIC has no public IP (private only);
# telemetry flows to Log Analytics via the Azure Monitor Agent + a Data
# Collection Rule.
###########################################################################

# # --- Linux (SSH key auth) ---
# module "vm_linux" {
#   source              = "./modules/virtual_machine"
#   vm_name             = "vm-app-lnx-01"
#   resource_group_name = module.resource_group.name
#   location            = "eastus"
#   os_type             = "Linux"
#   vm_size             = "Standard_D2s_v5"
#   admin_username      = "azureuser"
#   ssh_public_key      = var.linux_ssh_public_key
#   subnet_id           = var.vm_subnet_id
#
#   image_publisher = "Canonical"
#   image_offer     = "ubuntu-24_04-lts"
#   image_sku       = "server"
#
#   # Private-only + monitoring.
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#   data_collection_rule_id    = var.vm_data_collection_rule_id
#   user_assigned_identity_ids = [module.managed_identity.id]
#
#   tags = { environment = "prod" }
# }
#
# # --- Windows (password auth; source the password from Key Vault / a pipeline var) ---
# module "vm_windows" {
#   source              = "./modules/virtual_machine"
#   vm_name             = "vm-app-win-01"
#   resource_group_name = module.resource_group.name
#   location            = "eastus"
#   os_type             = "Windows"
#   vm_size             = "Standard_D2s_v5"
#   admin_username      = "azureadmin"
#   admin_password      = var.windows_admin_password
#   subnet_id           = var.vm_subnet_id
#
#   image_publisher = "MicrosoftWindowsServer"
#   image_offer     = "WindowsServer"
#   image_sku       = "2022-datacenter-azure-edition"
#
#   log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
#   data_collection_rule_id    = var.vm_data_collection_rule_id
#
#   tags = { environment = "prod" }
# }
