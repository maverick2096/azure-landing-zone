############################
# Resource Group
###########################
module "resource_group" {
  source   = "./modules/resource_group"
  for_each = local.enable_rg ? local.regions : {}

  name     = "${var.rg_name}${each.value.suffix}"
  location = each.value.location
  tags     = merge(var.tags, { BuildDate = local.build_date })
}

############################################
# Managed Identity (platform workload identity)
############################################
module "managed_identity" {
  source   = "./modules/managed_identity"
  for_each = local.regions

  name                = "${var.managed_identity_name}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  tags                = merge(var.tags, { BuildDate = local.build_date })

  depends_on = [module.resource_group]
}

############################################
# Virtual Network + subnets + NSGs (per region)
############################################
module "virtual_network" {
  source     = "./modules/virtual_network"
  for_each   = local.regions
  depends_on = [module.resource_group]

  name                = "${var.vnet_name}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  address_space       = each.value.address_space
  tags                = merge(var.tags, { BuildDate = local.build_date })

  subnets = {
    for k, d in local.subnet_defs : k => {
      address_prefixes = [cidrsubnet(each.value.address_space[0], var.subnet_newbits, d.index)]
      delegation       = d.delegation
    }
  }
}

############################################
# Private DNS zones (global - linked to every region VNet)
############################################
module "private_dns_zones" {
  source     = "./modules/private_dns_zones"
  depends_on = [module.virtual_network]

  resource_group_name = var.rg_name
  zone_names          = local.service_private_dns_zones
  vnet_links          = { for k, m in module.virtual_network : k => m.vnet_id }
  tags                = merge(var.tags, { BuildDate = local.build_date })
}

############################################
# VNet peering between primary and DR (when DR is enabled)
############################################
resource "azurerm_virtual_network_peering" "primary_to_dr" {
  count = var.enable_dr ? 1 : 0

  name                         = "peer-primary-to-dr"
  resource_group_name          = var.rg_name
  virtual_network_name         = module.virtual_network["primary"].vnet_name
  remote_virtual_network_id    = module.virtual_network["dr"].vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "dr_to_primary" {
  count = var.enable_dr ? 1 : 0

  name                         = "peer-dr-to-primary"
  resource_group_name          = "${var.rg_name}${var.dr_resource_suffix}"
  virtual_network_name         = module.virtual_network["dr"].vnet_name
  remote_virtual_network_id    = module.virtual_network["primary"].vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

############################
# Key Vault
############################
module "key_vault" {
  source     = "./modules/key_vault"
  for_each   = local.enable_kv ? local.regions : {}
  depends_on = [module.log_analytics]

  name                       = "${var.kv_name}${each.value.suffix}"
  location                   = each.value.location
  resource_group_name        = "${var.rg_name}${each.value.suffix}"
  tenant_id                  = null # current tenant by default
  sku_name                   = var.kv_sku
  purge_protection           = var.kv_purge_protection
  soft_delete_retention_days = var.kv_soft_delete_retention_days
  tags                       = merge(var.tags, { BuildDate = local.build_date })

  # Private networking (link to existing DNS zone) + diagnostics.
  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids       = [module.private_dns_zones.zone_ids["privatelink.vaultcore.azure.net"]]
  network_acls_subnet_ids    = var.virtual_network_subnet_ids_kv
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id

  # Grant the platform managed identity data-plane read via access policy.
  access_policy_object_ids = compact([module.managed_identity[each.key].principal_id])
}

############################
# ACR
############################
module "acr" {
  source     = "./modules/acr"
  for_each   = local.enable_acr ? local.regions : {}
  depends_on = [module.log_analytics]

  # ACR names are alphanumeric only - strip the hyphen from the DR suffix.
  name                = "${var.acr_name}${replace(each.value.suffix, "-", "")}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  sku                 = var.acr_sku # Premium required for private endpoints
  admin_enabled       = var.acr_admin_enabled
  tags                = merge(var.tags, { BuildDate = local.build_date })

  # Private networking (link to existing DNS zone) + diagnostics.
  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids       = [module.private_dns_zones.zone_ids["privatelink.azurecr.io"]]
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id

  # Grant the platform managed identity AcrPull.
  role_principal_ids = compact([module.managed_identity[each.key].principal_id])
}

############################
# Log Analytics
############################
module "log_analytics" {
  source     = "./modules/log_analytics"
  for_each   = local.enable_law ? local.regions : {}
  depends_on = [module.resource_group]

  name                = "${var.log_analytics_name}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  sku                 = var.log_analytics_sku
  retention_days      = var.log_analytics_retention_days
  tags                = merge(var.tags, { BuildDate = local.build_date })

  # AMPLS networking: this module owns the monitor private DNS zones and the
  # AMPLS private endpoint. It reuses the existing blob zone for the agent path.
  virtual_network_id         = module.virtual_network[each.key].vnet_id
  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  blob_private_dns_zone_id   = module.private_dns_zones.zone_ids["privatelink.blob.core.windows.net"]
}

############################################
# Application Insights (attached to the AMPLS)
############################################
module "application_insights" {
  source     = "./modules/app_insights"
  for_each   = local.enable_app_insights ? local.regions : {}
  depends_on = [module.log_analytics]

  app_insights_name          = "${var.app_insights_name}${each.value.suffix}"
  location                   = each.value.location
  resource_group_name        = "${var.rg_name}${each.value.suffix}"
  application_type           = "web"
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id
  ampls_name                 = module.log_analytics[each.key].ampls_name
  tags                       = merge(var.tags, { BuildDate = local.build_date })
}

############################
# Storage Account
############################
module "storage" {
  source     = "./modules/storage_account"
  for_each   = local.enable_storage ? local.regions : {}
  depends_on = [module.log_analytics]

  # Storage account names are lowercase alphanumeric only - strip the hyphen.
  name                     = "${var.sa_name}${replace(each.value.suffix, "-", "")}"
  location                 = each.value.location
  resource_group_name      = "${var.rg_name}${each.value.suffix}"
  account_tier             = var.sa_tier
  account_replication_type = var.sa_replication
  containers               = var.storage_containers
  tags                     = merge(var.tags, { BuildDate = local.build_date })

  # Private networking (blob only, link to existing DNS zone) + diagnostics.
  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids       = [module.private_dns_zones.zone_ids["privatelink.blob.core.windows.net"]]
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id

  # Grant the platform managed identity Storage Blob Data Contributor.
  role_principal_ids = compact([module.managed_identity[each.key].principal_id])
}
/*
############################
# Storage Account Diag
############################
 module "storage_account_diag" {
   source = "./modules/storage_account"
   count  = local.enable_storage_diag ? 1 : 0
   depends_on = [ module.private_dns ]
 
   name                     = var.sa_namediag
   location                 = var.location
   resource_group_name      = var.rg_name
   account_tier             = var.sa_tier
   account_replication_type = var.sa_replication
   containers               = var.storage_containers_diag
   tags = merge(var.tags, { BuildDate = local.build_date })
   #tags                     = var.tags
   private_endpoint_subnet_id = var.private_endpoint_subnet_id
   log_analytics_name         = var.log_analytics_name
   saname                    = var.saname
   virtual_network_id         = var.virtual_network_id
}
*/
############################
# Recovery Vault
############################
module "recovery_vault" {
  source              = "./modules/recovery_vault"
  count               = local.enable_recovery_vault ? 1 : 0
  name                = var.rsv_name
  location            = var.location
  resource_group_name = var.rg_name
  sku                 = var.rsv_sku
  tags                = merge(var.tags, { BuildDate = local.build_date })
  #tags                = var.tags
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  log_analytics_name         = var.log_analytics_name
  virtual_network_id         = var.virtual_network_id

}

############################
# Public IP
############################
module "public_ip" {
  source = "./modules/public_ip"
  # count  = local.enable_public_ip ? 1 : 0

  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.rg_name
  #allocation_method  = var.public_ip_allocation_method
  #sku                 = var.public_ip_sku
  tags = merge(var.tags, { BuildDate = local.build_date })
  #tags                = var.tags

}

############################
# Private DNS
############################
module "private_dns" {
  source = "./modules/private_dns"
  count  = local.enable_private_dns ? 1 : 0

  name                       = var.private_dns_zone_name
  resource_group_name        = var.rg_name
  location                   = var.location
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  virtual_network_id         = var.private_dns_zone_vnet_ids
  link_name                  = var.private_dns_zone_link_name
  sku_name                   = var.private_dns_zone_sku_name
  tags                       = merge(var.tags, { BuildDate = local.build_date })
  #tags                       = var.tags
  saname = var.saname
}

############################
# PostGres
############################
module "postgres" {
  source = "./modules/postgresql_flex"
  count  = local.enable_postgres ? 1 : 0

  name                         = var.postgres_server_name
  location                     = var.location
  resource_group_name          = var.rg_name
  administrator_login          = var.postgres_administrator_login
  administrator_login_password = var.postgres_administrator_password
  sku_name                     = var.postgres_sku_name
  server_version               = var.postgres_version
  storage_mb                   = var.postgres_storage_mb
  tags                         = merge(var.tags, { BuildDate = local.build_date })
  #tags                         = var.tags
  private_endpoint_subnet_id = var.private_endpoint_subnet_id
  log_analytics_name         = var.log_analytics_name
  postgres_backup_vault      = var.postgres_backup_vault
  virtual_network_id         = var.virtual_network_id
}

############################
# Service Bus
############################
module "servicebus" {
  source     = "./modules/service_bus"
  for_each   = local.enable_servicebus ? local.regions : {}
  depends_on = [module.log_analytics]

  name                = "${var.sb_namespace_name}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  sku                 = var.sb_sku # Premium required for private endpoints
  queues              = var.sb_queues
  tags                = merge(var.tags, { BuildDate = local.build_date })

  # Private networking (link to existing DNS zone) + diagnostics.
  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids       = [module.private_dns_zones.zone_ids["privatelink.servicebus.windows.net"]]
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id

  # Grant the platform managed identity Azure Service Bus Data Owner.
  role_principal_ids = compact([module.managed_identity[each.key].principal_id])
}

###########################
# Application Service Plan
###########################
# NOTE: app_service and function_app each create their OWN dedicated plan
# (per the module design), so this shared plan is optional. It is kept for
# callers who want a standalone/shared plan - disable with build_app_service_plan.
module "app_service_plan" {
  source     = "./modules/app_service_plan"
  for_each   = local.enable_app_service_plan ? local.regions : {}
  depends_on = [module.log_analytics]

  plan_name                  = "${var.app_service_plan_name}${each.value.suffix}"
  sku_name                   = var.app_service_sku
  os_type                    = "Linux"
  location                   = each.value.location
  resource_group_name        = "${var.rg_name}${each.value.suffix}"
  tags                       = merge(var.tags, { BuildDate = local.build_date })
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id
}
/*
###########################
# Application Insights
###########################
module "application_insights" {
  source = "./modules/app_insights"
  count  = local.enable_application_insights ? 1 : 0
  name                = var.app_insights_name
  location            = var.location
  resource_group_name = var.rg_name
  tags = merge(var.tags, { BuildDate = local.build_date })
} 

*/
############################
# App Service
############################
module "app_service" {
  source     = "./modules/app_service"
  for_each   = local.regions
  depends_on = [module.log_analytics]

  app_name            = "${var.app_name}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  tags                = merge(var.tags, { BuildDate = local.build_date })

  # This module creates its own dedicated plan.
  plan_name     = "asp-${var.app_name}${each.value.suffix}"
  plan_sku_name = var.app_service_sku

  app_settings = var.app_settings

  container_registry_url = local.enable_acr ? "https://${module.acr[each.key].login_server}" : null
  container_image_name   = var.app_image_name
  container_image_tag    = var.app_image_tag

  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids       = [module.private_dns_zones.zone_ids["privatelink.azurewebsites.net"]]
  vnet_integration_subnet_id = module.virtual_network[each.key].subnet_ids["apps"]
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id
  user_assigned_identity_ids = compact([module.managed_identity[each.key].id])
}

############################
# App Service 2
############################
module "app_service2" {
  source     = "./modules/app_service"
  for_each   = local.regions
  depends_on = [module.log_analytics]

  app_name            = "${var.app_name_2}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  tags                = merge(var.tags, { BuildDate = local.build_date })

  plan_name     = "asp-${var.app_name_2}${each.value.suffix}"
  plan_sku_name = var.app_service_sku

  app_settings = var.app_settings

  container_registry_url = local.enable_acr ? "https://${module.acr[each.key].login_server}" : null
  container_image_name   = var.app_image_name_2
  container_image_tag    = var.app_image_tag_2

  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids       = [module.private_dns_zones.zone_ids["privatelink.azurewebsites.net"]]
  vnet_integration_subnet_id = module.virtual_network[each.key].subnet_ids["apps"]
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id
  user_assigned_identity_ids = compact([module.managed_identity[each.key].id])
}

############################
# App Service 3 
############################
module "app_service3" {
  source     = "./modules/app_service"
  for_each   = local.regions
  depends_on = [module.log_analytics]

  app_name            = "${var.app_name_3}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  tags                = merge(var.tags, { BuildDate = local.build_date })

  plan_name     = "asp-${var.app_name_3}${each.value.suffix}"
  plan_sku_name = var.app_service_sku

  app_settings = var.app_settings

  container_registry_url = local.enable_acr ? "https://${module.acr[each.key].login_server}" : null
  container_image_name   = var.app_image_name_3
  container_image_tag    = var.app_image_tag_3

  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids       = [module.private_dns_zones.zone_ids["privatelink.azurewebsites.net"]]
  vnet_integration_subnet_id = module.virtual_network[each.key].subnet_ids["apps"]
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id
  user_assigned_identity_ids = compact([module.managed_identity[each.key].id])
}

############################
# App Service 4
############################
module "app_service4" {
  source     = "./modules/app_service"
  for_each   = local.regions
  depends_on = [module.log_analytics]

  app_name            = "${var.app_name_4}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  tags                = merge(var.tags, { BuildDate = local.build_date })

  plan_name     = "asp-${var.app_name_4}${each.value.suffix}"
  plan_sku_name = var.app_service_sku

  app_settings = var.app_settings

  container_registry_url = local.enable_acr ? "https://${module.acr[each.key].login_server}" : null
  container_image_name   = var.app_image_name_4
  container_image_tag    = var.app_image_tag_4

  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids       = [module.private_dns_zones.zone_ids["privatelink.azurewebsites.net"]]
  vnet_integration_subnet_id = module.virtual_network[each.key].subnet_ids["apps"]
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id
  user_assigned_identity_ids = compact([module.managed_identity[each.key].id])
}

############################################
# Function App (Linux, dedicated plan)
############################################
module "function_app" {
  source     = "./modules/function_app"
  for_each   = local.enable_function_app ? local.regions : {}
  depends_on = [module.log_analytics, module.storage]

  function_app_name   = "${var.function_app_name}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  tags                = merge(var.tags, { BuildDate = local.build_date })

  # Dedicated plan created by the module.
  plan_name     = "${var.function_app_plan_name}${each.value.suffix}"
  plan_sku_name = var.function_app_plan_sku

  # Backing storage (reuse the storage_account module - same region).
  storage_account_name       = module.storage[each.key].storage_account_name
  storage_account_access_key = module.storage[each.key].primary_access_key

  # Runtime (set one).
  node_version   = var.function_app_node_version
  python_version = var.function_app_python_version
  dotnet_version = var.function_app_dotnet_version

  # Private networking (link to existing DNS zone) + diagnostics.
  private_endpoint_subnet_id             = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids                   = [module.private_dns_zones.zone_ids["privatelink.azurewebsites.net"]]
  vnet_integration_subnet_id             = module.virtual_network[each.key].subnet_ids["apps"]
  log_analytics_workspace_id             = module.log_analytics[each.key].log_analytics_workspace_id
  application_insights_connection_string = local.enable_app_insights ? module.application_insights[each.key].connection_string : null
  user_assigned_identity_ids             = compact([module.managed_identity[each.key].id])
}

############################
# Document Intelligence (Cognitive Services)
############################
module "document_intelligence" {
  source     = "./modules/document_intelligence"
  for_each   = local.enable_document_intelligence ? local.regions : {}
  depends_on = [module.log_analytics]

  name                = "${var.document_intelligence_name}${each.value.suffix}"
  location            = each.value.location
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  sku_name            = var.document_intelligence_sku
  tags                = merge(var.tags, { BuildDate = local.build_date })

  # Private networking (link to existing DNS zone) + diagnostics.
  private_endpoint_subnet_id = module.virtual_network[each.key].subnet_ids["private_endpoint"]
  private_dns_zone_ids       = [module.private_dns_zones.zone_ids["privatelink.cognitiveservices.azure.com"]]
  log_analytics_workspace_id = module.log_analytics[each.key].log_analytics_workspace_id

  # Grant the platform managed identity Cognitive Services User.
  role_principal_ids = compact([module.managed_identity[each.key].principal_id])
}


############################
# Network Security Group
############################
# Standalone NSGs are superseded by the per-subnet NSGs created inside the
# virtual_network module (which also owns the subnet associations). Left
# commented to avoid two NSGs associating to the same subnet.
/*
module "network_security_group" {
  source = "./modules/network_security_group"
  count  = local.enable_nsg ? 1 : 0
  ############################
  # NSG for API Management
  ############################
  name                = coalesce(var.nsg_apim_name, "nsg-apim")
  location            = var.location
  resource_group_name = var.rg_name
  security_rules      = var.nsg_apim_rules
  #tags                = var.tags
  tags                           = merge(var.tags, { BuildDate = local.build_date })
  subnet_id                      = var.apim_subnet_id
  log_analytics_name             = var.log_analytics_name
  enable_diagnostics             = var.nsg_enable_diagnostics
  log_analytics_workspace_id     = var.nsg_log_analytics_workspace_id
  diagnostics_storage_account_id = var.nsg_diagnostics_storage_account_id
}

############################
# NSG for VM
############################
module "nsg_vm" {
  source              = "./modules/network_security_group"
  name                = coalesce(var.nsg_vm_name, "nsg-vm")
  location            = var.location
  resource_group_name = var.rg_name
  security_rules      = var.nsg_vm_rules
  tags                = merge(var.tags, { BuildDate = local.build_date })
  #tags                = var.tags
  subnet_id                      = var.vm_subnet_id
  log_analytics_name             = var.log_analytics_name
  enable_diagnostics             = var.nsg_enable_diagnostics
  log_analytics_workspace_id     = var.nsg_log_analytics_workspace_id
  diagnostics_storage_account_id = var.nsg_diagnostics_storage_account_id

}

############################
# NSG for Private Endpoint
############################
module "nsg_privateendpoint" {
  source = "./modules/network_security_group"
  #name                = "nsg-pe-OYS-AZ"
  name                = coalesce(var.nsg_pe_name, "nsg-pe")
  location            = var.location
  resource_group_name = var.rg_name
  security_rules      = var.nsg_pe_rules
  #tags                = var.tags
  tags                           = merge(var.tags, { BuildDate = local.build_date })
  subnet_id                      = var.private_endpoint_subnet_id
  log_analytics_name             = var.log_analytics_name
  enable_diagnostics             = var.nsg_enable_diagnostics
  log_analytics_workspace_id     = var.nsg_log_analytics_workspace_id
  diagnostics_storage_account_id = var.nsg_diagnostics_storage_account_id
}

############################
# NSG for VNet Integration
############################
module "nsg_vnetintegration" {
  source              = "./modules/network_security_group"
  name                = coalesce(var.nsg_vnt_name, "nsg-vnt")
  location            = var.location
  resource_group_name = var.rg_name
  security_rules      = var.nsg_vnt_rules
  tags                = merge(var.tags, { BuildDate = local.build_date })
  #tags                = var.tags
  subnet_id                      = var.subnet_id_webapp_integration
  log_analytics_name             = var.log_analytics_name
  enable_diagnostics             = var.nsg_enable_diagnostics
  log_analytics_workspace_id     = var.nsg_log_analytics_workspace_id
  diagnostics_storage_account_id = var.nsg_diagnostics_storage_account_id
}
*/


#####################################
#Load Balancer
#####################################
module "load_balancer" {
  source = "./modules/load_balancer"
  count  = local.enable_load_balancer ? 1 : 0

  name                           = var.lb_name
  location                       = var.location
  resource_group_name            = var.rg_name
  lb_sku                         = var.lb_sku
  frontend_ip_configuration_name = var.lb_frontend_ip_configuration_name
  backend_pool_name              = var.lb_backend_pool_name
  backend_pool_addresses         = var.backend_pool_addresses
  subnet_id                      = var.private_link_service_subnet_id
  private_ip_address             = var.lb_private_ip_address
  tags                           = merge(var.tags, { BuildDate = local.build_date })
  enable_diagnostics             = var.lb_enable_diagnostics
  #log_analytics_name                = var.lb_log_analytics_name
  log_analytics_workspace_id = var.lb_log_analytics_workspace_id
  #log_analytics_resource_group_name = var.lb_log_analytics_resource_group_name
  diagnostics_storage_account_id     = var.lb_diagnostics_storage_account_id
  backend_pool_network_interface_ids = var.lb_backend_pool_network_interface_ids
  backend_pool_ip_configuration_name = var.backend_pool_ip_configuration_name


  # ------------------------------
  # VMSS — Windows (Rpt)
  # ------------------------------
  enable_vmss_rpt                            = var.enable_vmss_rpt
  vmss_rpt_name                              = var.vmss_rpt_name
  vmss_rpt_computer_name_prefix              = var.vmss_rpt_computer_name_prefix
  vmss_rpt_vm_size                           = var.vmss_rpt_vm_size
  vmss_rpt_instance_count                    = var.vmss_rpt_instance_count
  vmss_rpt_min_instance_count                = var.vmss_rpt_min_instance_count
  vmss_rpt_max_instance_count                = var.vmss_rpt_max_instance_count
  vmss_rpt_admin_username                    = var.vmss_rpt_admin_username
  vmss_rpt_admin_password                    = var.vmss_rpt_admin_password
  vmss_rpt_license_type                      = var.vmss_rpt_license_type
  vmss_rpt_timezone                          = var.vmss_rpt_timezone
  vmss_rpt_subnet_id                         = var.vmss_rpt_subnet_id
  vmss_rpt_accelerated_networking            = var.vmss_rpt_accelerated_networking
  vmss_rpt_nic_name                          = var.vmss_rpt_nic_name
  vmss_rpt_image_publisher                   = var.vmss_rpt_image_publisher
  vmss_rpt_image_offer                       = var.vmss_rpt_image_offer
  vmss_rpt_image_sku                         = var.vmss_rpt_image_sku
  vmss_rpt_image_version                     = var.vmss_rpt_image_version
  vmss_rpt_os_disk_caching                   = var.vmss_rpt_os_disk_caching
  vmss_rpt_os_disk_storage_account_type      = var.vmss_rpt_os_disk_storage_account_type
  vmss_rpt_os_disk_size_gb                   = var.vmss_rpt_os_disk_size_gb
  vmss_rpt_os_disk_write_accelerator_enabled = var.vmss_rpt_os_disk_write_accelerator_enabled
  vmss_rpt_automatic_instance_repair         = var.vmss_rpt_automatic_instance_repair
  vmss_rpt_identity_type                     = var.vmss_rpt_identity_type
  # Autoscale RPT
  enable_vmss_rpt_autoscale            = var.enable_vmss_rpt_autoscale
  vmss_rpt_autoscale_cpu_threshold_out = var.vmss_rpt_autoscale_cpu_threshold_out
  vmss_rpt_autoscale_cpu_threshold_in  = var.vmss_rpt_autoscale_cpu_threshold_in
  # RPT private DNS
  vmss_rpt_private_dns_zone_id = var.vmss_rpt_private_dns_zone_id
  vmss_rpt_dns_record_name     = var.vmss_rpt_dns_record_name
  vmss_rpt_dns_record_ttl      = var.vmss_rpt_dns_record_ttl
  # ------------------------------
  # VMSS — Linux (Drools)
  # ------------------------------
  enable_vmss_drools                       = var.enable_vmss_drools
  vmss_drools_name                         = var.vmss_drools_name
  vmss_drools_computer_name_prefix         = var.vmss_drools_computer_name_prefix
  vmss_drools_vm_size                      = var.vmss_drools_vm_size
  vmss_drools_instance_count               = var.vmss_drools_instance_count
  vmss_drools_min_instance_count           = var.vmss_drools_min_instance_count
  vmss_drools_max_instance_count           = var.vmss_drools_max_instance_count
  vmss_drools_admin_username               = var.vmss_drools_admin_username
  vmss_drools_ssh_public_key               = var.vmss_drools_ssh_public_key
  vmss_drools_subnet_id                    = var.vmss_drools_subnet_id
  vmss_drools_image_publisher              = var.vmss_drools_image_publisher
  vmss_drools_image_offer                  = var.vmss_drools_image_offer
  vmss_drools_image_sku                    = var.vmss_drools_image_sku
  vmss_drools_image_version                = var.vmss_drools_image_version
  vmss_drools_os_disk_size_gb              = var.vmss_drools_os_disk_size_gb
  vmss_drools_os_disk_caching              = var.vmss_drools_os_disk_caching
  vmss_drools_os_disk_storage_account_type = var.vmss_drools_os_disk_storage_account_type
  vmss_drools_automatic_instance_repair    = var.vmss_drools_automatic_instance_repair
  # Autoscale Drools
  enable_vmss_drools_autoscale            = var.enable_vmss_drools_autoscale
  vmss_drools_autoscale_cpu_threshold_out = var.vmss_drools_autoscale_cpu_threshold_out
  vmss_drools_autoscale_cpu_threshold_in  = var.vmss_drools_autoscale_cpu_threshold_in
  # Drools private DNS
  vmss_drools_private_dns_zone_id = var.vmss_drools_private_dns_zone_id
  vmss_drools_dns_record_name     = var.vmss_drools_dns_record_name
  vmss_drools_dns_record_ttl      = var.vmss_drools_dns_record_ttl
}

#####################################
#Load Balancer - APIM
#####################################
module "load_balancer_apim" {
  source = "./modules/load_balancer"
  count  = local.enable_load_balancer ? 1 : 0

  name                           = var.lb_name_apim
  location                       = var.location
  resource_group_name            = var.rg_name
  lb_sku                         = var.lb_sku
  frontend_ip_configuration_name = var.lb_frontend_ip_configuration_name
  backend_pool_name              = var.lb_backend_pool_name
  backend_pool_addresses         = var.backend_pool_addresses_apim
  subnet_id                      = var.private_link_service_subnet_id
  private_ip_address             = var.lb_private_ip_address_apim
  tags                           = merge(var.tags, { BuildDate = local.build_date })
  enable_diagnostics             = var.lb_enable_diagnostics
  #log_analytics_name                = var.lb_log_analytics_name
  log_analytics_workspace_id = var.lb_log_analytics_workspace_id
  #log_analytics_resource_group_name = var.lb_log_analytics_resource_group_name
  diagnostics_storage_account_id     = var.lb_diagnostics_storage_account_id
  backend_pool_network_interface_ids = var.lb_backend_pool_network_interface_ids
  backend_pool_ip_configuration_name = var.backend_pool_ip_configuration_name
}

#####################################
#RBAC
#####################################
module "rbac" {
  source = "./modules/rbac"
  count  = local.enable_rbac ? 1 : 0

  resource_group_name = var.rg_name
  webapp_name         = var.app_name_3
  api_name            = var.app_name
  n8n_name            = var.app_name_2
  acr_name            = var.acr_name
  #apim_name                 = var.apim_name
  storage_account_name      = var.sa_name
  key_vault_name            = var.kv_name
  postgresql_server_name    = var.postgres_server_name
  servicebus_namespace_name = var.sb_namespace_name
  #windows_vm_names          = var.windows_vm_names
  #linux_vm_names            = var.linux_vm_names
}

############################
# APIM
############################
/*module "api_management" {
  source = "./modules/api_management"
  count  = local.enable_apim ? 1 : 0
  depends_on = [ module.nsg_apim ]

  name                = var.apim_name
  location            = var.location
  resource_group_name = var.rg_name
  publisher_name      = var.apim_publisher_name
  publisher_email     = var.apim_publisher_email
  sku_name            = var.apim_sku_name
  subnet_id           = var.apim_subnet_id
  #tags                = var.tags
  tags = merge(var.tags, { BuildDate = local.build_date })
}
*/
############################
# Virtual Machines (Windows and RHEL)
############################

# Availability Set (shared by all VMs in a region)
locals {
  shared_availability_set_name = local.enable_vm && length(var.vm_configurations) > 0 ? try(values(var.vm_configurations)[0].availability_set_name, null) : null
  create_availability_set      = local.shared_availability_set_name != null && local.shared_availability_set_name != ""

  # Flatten region x vm_configuration so VMs loop across both the primary and
  # (when enabled) the DR region. Keys look like "primary|<vm>" / "dr|<vm>".
  vm_instances = local.enable_vm ? merge([
    for rkey, r in local.regions : {
      for vmname, cfg in var.vm_configurations :
      "${rkey}|${vmname}" => {
        region_key = rkey
        location   = r.location
        suffix     = r.suffix
        name       = "${vmname}${r.suffix}"
        cfg        = cfg
      }
    }
  ]...) : {}
}

resource "azurerm_availability_set" "shared" {
  for_each                     = local.create_availability_set ? local.regions : {}
  name                         = "${local.shared_availability_set_name}${each.value.suffix}"
  location                     = each.value.location
  resource_group_name          = "${var.rg_name}${each.value.suffix}"
  platform_fault_domain_count  = try(values(var.vm_configurations)[0].availability_set_fault_domain_count, 2)
  platform_update_domain_count = try(values(var.vm_configurations)[0].availability_set_update_domain_count, 5)
  managed                      = try(values(var.vm_configurations)[0].availability_set_managed, true)
  tags                         = merge(var.tags, { BuildDate = local.build_date })
}

# Create VMs across region(s) using for_each - supports both Windows and Linux
module "virtual_machine" {
  source   = "./modules/virtual_machine"
  for_each = local.vm_instances

  vm_name             = each.value.name
  resource_group_name = "${var.rg_name}${each.value.suffix}"
  location            = each.value.location
  os_type             = each.value.cfg.os_type
  vm_size             = each.value.cfg.vm_size

  admin_username = each.value.cfg.admin_username
  admin_password = each.value.cfg.admin_password
  # For Linux VMs with no key in the config, use the SSH key generated below.
  ssh_public_key = each.value.cfg.os_type == "Linux" && (each.value.cfg.ssh_public_key == "" || each.value.cfg.ssh_public_key == null) ? (local.has_linux_vms && length(tls_private_key.vm_ssh_key) > 0 ? tls_private_key.vm_ssh_key[0].public_key_openssh : "") : each.value.cfg.ssh_public_key

  # Networking - private only (no public IP). Uses the created VM subnet for the region.
  subnet_id             = module.virtual_network[each.value.region_key].subnet_ids["vm"]
  private_ip_allocation = each.value.cfg.private_ip_allocation
  private_ip            = each.value.cfg.private_ip
  nic_name              = each.value.cfg.nic_name
  ip_configuration_name = each.value.cfg.ip_configuration_name

  # OS disk + image.
  os_disk_name                 = each.value.cfg.os_disk_name
  os_disk_caching              = each.value.cfg.os_disk_caching
  os_disk_storage_account_type = each.value.cfg.os_disk_storage_account_type
  os_disk_size_gb              = each.value.cfg.os_disk_size_gb
  image_publisher              = each.value.cfg.image_publisher
  image_offer                  = each.value.cfg.image_offer
  image_sku                    = each.value.cfg.image_sku
  image_version                = each.value.cfg.image_version

  computer_name = each.value.cfg.computer_name

  # Placement - same-region shared availability set when one is configured.
  availability_set_id = local.create_availability_set ? azurerm_availability_set.shared[each.value.region_key].id : each.value.cfg.availability_set_id

  # Identity - system-assigned plus the platform managed identity (or config-provided ones).
  enable_system_assigned_identity = each.value.cfg.enable_managed_identity
  user_assigned_identity_ids      = length(each.value.cfg.user_assigned_identity_ids) > 0 ? each.value.cfg.user_assigned_identity_ids : compact([module.managed_identity[each.value.region_key].id])

  # Boot diagnostics (managed storage).
  enable_boot_diagnostics = each.value.cfg.enable_boot_diagnostics

  # Monitoring - Azure Monitor Agent + optional Data Collection Rule association.
  enable_monitoring                   = each.value.cfg.enable_vm_insights
  automatic_extension_upgrade_enabled = each.value.cfg.automatic_extension_upgrade_enabled
  log_analytics_workspace_id          = each.value.cfg.log_analytics_workspace_id != null ? each.value.cfg.log_analytics_workspace_id : (local.enable_law ? module.log_analytics[each.value.region_key].log_analytics_workspace_id : null)
  data_collection_rule_id             = each.value.cfg.data_collection_rule_id

  tags = merge(var.tags, { BuildDate = local.build_date })
}

############################
# SSH Key Generation
############################
# Check if there are any Linux VMs that need SSH keys
locals {
  has_linux_vms = local.enable_vm && length(var.vm_configurations) > 0 && length([for k, v in var.vm_configurations : k if v.os_type == "Linux"]) > 0
}

# Generate SSH key pair for Linux VMs
resource "tls_private_key" "vm_ssh_key" {
  count     = local.has_linux_vms ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to local file (using local_sensitive_file for better security handling)
resource "local_sensitive_file" "private_key" {
  count           = local.has_linux_vms ? 1 : 0
  content         = tls_private_key.vm_ssh_key[0].private_key_pem
  filename        = "${path.module}/vm_ssh_key.pem"
  file_permission = "0600"
}

# Save public key to local file (for reference)
resource "local_file" "public_key" {
  count           = local.has_linux_vms ? 1 : 0
  content         = tls_private_key.vm_ssh_key[0].public_key_openssh
  filename        = "${path.module}/vm_ssh_key.pub"
  file_permission = "0644"
}

/*
############################
# Data Sources for Existing Resources
############################
# Data sources for existing VMs
data "azurerm_virtual_machine" "existing" {
  for_each            = local.enable_vm && var.use_existing_vms ? var.existing_vm_names : {}
  name                = each.value
  resource_group_name = var.rg_name
}

locals {
  existing_vm_nic_ids = local.enable_vm && var.use_existing_vms ? {
    for k, vm in data.azurerm_virtual_machine.existing :
    k => try(vm.network_interface_ids[0], null)
  } : {}
}

data "azurerm_network_interface" "existing" {
  for_each = { for k, nic_id in local.existing_vm_nic_ids : k => nic_id if nic_id != null }

  name                = basename(each.value)
  resource_group_name = var.rg_name
}

locals {
  existing_vm_nics = local.enable_vm && var.use_existing_vms ? {
    for k, nic in data.azurerm_network_interface.existing :
    k => {
      id                    = nic.id
      ip_configuration_name = try(nic.ip_configuration[0].name, "ipconfig1")
      private_ip            = try(nic.ip_configuration[0].private_ip_address, null)
    }
  } : {}
}
*/
locals {
  apim_subnet_parts = var.apim_subnet_id != null ? {
    resource_group = element(split("/", var.apim_subnet_id), 4)
    vnet_name      = element(split("/", var.apim_subnet_id), 8)
    subnet_name    = element(split("/", var.apim_subnet_id), 10)
  } : null
  private_endpoint_subnet_parts = var.private_endpoint_subnet_id != null ? {
    resource_group = element(split("/", var.private_endpoint_subnet_id), 4)
    vnet_name      = element(split("/", var.private_endpoint_subnet_id), 8)
    subnet_name    = element(split("/", var.private_endpoint_subnet_id), 10)
  } : null
  vm_subnet_parts = var.vm_subnet_id != null ? {
    resource_group = element(split("/", var.vm_subnet_id), 4)
    vnet_name      = element(split("/", var.vm_subnet_id), 8)
    subnet_name    = element(split("/", var.vm_subnet_id), 10)
  } : null
  vnt_subnet_parts = var.subnet_id_webapp_integration != null ? {
    resource_group = element(split("/", var.subnet_id_webapp_integration), 4)
    vnet_name      = element(split("/", var.subnet_id_webapp_integration), 8)
    subnet_name    = element(split("/", var.subnet_id_webapp_integration), 10)
  } : null
}

data "azurerm_subnet" "apim" {
  count = local.apim_subnet_parts != null ? 1 : 0

  name                 = local.apim_subnet_parts.subnet_name
  virtual_network_name = local.apim_subnet_parts.vnet_name
  resource_group_name  = local.apim_subnet_parts.resource_group
}

data "azurerm_subnet" "private_endpoint" {
  count = local.private_endpoint_subnet_parts != null ? 1 : 0

  name                 = local.private_endpoint_subnet_parts.subnet_name
  virtual_network_name = local.private_endpoint_subnet_parts.vnet_name
  resource_group_name  = local.private_endpoint_subnet_parts.resource_group
}

data "azurerm_subnet" "vm" {
  count = local.vm_subnet_parts != null ? 1 : 0

  name                 = local.vm_subnet_parts.subnet_name
  virtual_network_name = local.vm_subnet_parts.vnet_name
  resource_group_name  = local.vm_subnet_parts.resource_group
}

data "azurerm_subnet" "vnet_integration" {
  count = local.vnt_subnet_parts != null ? 1 : 0

  name                 = local.vnt_subnet_parts.subnet_name
  virtual_network_name = local.vnt_subnet_parts.vnet_name
  resource_group_name  = local.vnt_subnet_parts.resource_group
}

locals {
  apim_subnet_prefix             = local.apim_subnet_parts != null ? data.azurerm_subnet.apim[0].address_prefixes[0] : null
  private_endpoint_subnet_prefix = local.private_endpoint_subnet_parts != null ? data.azurerm_subnet.private_endpoint[0].address_prefixes[0] : null
  vm_subnet_prefix               = local.vm_subnet_parts != null ? data.azurerm_subnet.vm[0].address_prefixes[0] : null
  vnt_subnet_prefix              = local.vnt_subnet_parts != null ? data.azurerm_subnet.vnet_integration[0].address_prefixes[0] : null
}
/*
data "azurerm_network_watcher" "vnet_flow_logs" {
  name                = var.vnet_flow_log_network_watcher_name != null ? var.vnet_flow_log_network_watcher_name : "NetworkWatcher_${replace(replace(var.location, " ", ""), "-", "")}"
  resource_group_name = var.vnet_flow_log_network_watcher_resource_group_name
}
# Log Analytics Workspace data source for Traffic Analytics
# Extract workspace name and resource group from the resource ID
locals {
  law_resource_id_parts = var.vnet_flow_log_traffic_analytics_workspace_id != null ? {
    resource_group = element(split("/", var.vnet_flow_log_traffic_analytics_workspace_id), 4)
    workspace_name = element(split("/", var.vnet_flow_log_traffic_analytics_workspace_id), 8)
  } : null
}
data "azurerm_log_analytics_workspace" "traffic_analytics" {
  count = var.vnet_flow_log_enable_traffic_analytics && var.vnet_flow_log_traffic_analytics_workspace_id != null ? 1 : 0
  name                = local.law_resource_id_parts.workspace_name
  resource_group_name = local.law_resource_id_parts.resource_group
}
locals {
  apim_destination_prefix             = local.apim_subnet_prefix
  private_endpoint_destination_prefix = local.private_endpoint_subnet_prefix
  vm_destination_prefix               = local.vm_subnet_prefix
  vnt_destination_prefix              = local.vnt_subnet_prefix
}
locals {
  nsg_apim_rules_default = []
  nsg_pe_rules_default   = []
  nsg_vm_rules_default   = []
  nsg_vnt_rules_default  = []
}

*/

############################
# Outputs
############################
output "resource_group_name" {
  value = local.enable_rg ? module.resource_group["primary"].name : var.rg_name
}
output "kv_uri" {
  value = local.enable_kv ? module.key_vault["primary"].vault_uri : null
}

output "ssh_private_key_path" {
  description = "Path to the generated SSH private key file"
  value       = local.has_linux_vms && length(tls_private_key.vm_ssh_key) > 0 ? local_sensitive_file.private_key[0].filename : null
  sensitive   = false
}

output "ssh_public_key" {
  description = "Generated SSH public key (for reference)"
  value       = local.has_linux_vms && length(tls_private_key.vm_ssh_key) > 0 ? tls_private_key.vm_ssh_key[0].public_key_openssh : null
  sensitive   = false
}