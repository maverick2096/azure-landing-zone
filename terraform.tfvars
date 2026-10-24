# ======== terraform.tfvars  ========
# Global
location = "eastus"

# Disaster Recovery (second region). Set enable_dr = true to deploy a full
# standby copy of the platform in dr_location; every DR resource is suffixed -dr.
enable_dr   = false
dr_location = "westus"

#############################################################################
# Platform inputs for the standardized modules
# (managed identity, Application Insights, Function App, and the EXISTING
#  private DNS zone IDs used by the link-to-existing private-endpoint pattern).
# Replace the <...> placeholders below with your real values.
#############################################################################

# Managed identity (platform workload identity)
managed_identity_name = "id-app-platform"

# Application Insights
app_insights_name = "appi-app-platform"

# Function App (Linux, dedicated plan)
build_function_app        = true
function_app_name         = "func-app-platform"
function_app_plan_name    = "asp-func-app-platform"
function_app_plan_sku     = "P1v3"
function_app_node_version = "20"

# Networking is now created by the virtual_network + private_dns_zones modules
# (no existing zone/subnet IDs required). Override the VNet address spaces if the
# 10.0.0.0/16 (primary) / 10.1.0.0/16 (DR) defaults clash with your environment.
vnet_name          = "vnet-app-platform"
vnet_address_space = ["10.0.0.0/16"]

# Document Intelligence (Cognitive Services)
build_document_intelligence = true
document_intelligence_name  = "di-app-platform"
document_intelligence_sku   = "S0"
tags = {
  Department  = ""
  Application = ""
  Environment = ""
  Region      = ""
  Owner       = ""
  BuildUserId = "REPLACE_BUILD_ID"  # Will be replaced by Azure DevOps pipeline with $(Build.RequestedForEmail)
  BuildURL    = "REPLACE_BUILD_URL" # Will be replaced by Azure DevOps pipeline with build URL
  StateFile   = "https://#################/tfstate/terraform.tfstate"
  SupportedBy = ""
}

# Toggles (booleans)
build_resource_group            = true
build_acr                       = true
build_key_vault                 = true
build_log_analytics             = true
build_vm                        = true
enable_private_endpoints        = false
build_servicebus                = true
build_app_service_plan          = false # apps create their own dedicated plan
build_app_service               = true
build_storage                   = true
build_storage_diag              = false
build_private_dns_zone          = false # zones are created by the private_dns_zones module
build_private_link_service      = false
build_recovery_vault            = true
build_postgres                  = true
build_nsg                       = false
build_load_balancer             = true
build_api_management            = false
build_frontdoor                 = false
build_rbac                      = true
build_automation_account        = true
build_maintenance_configuration = true # Set to true to create maintenance configuration

# Networking
virtual_network_id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001"
private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-001"
vm_subnet_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-003"

#LB
private_link_service_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-003"
private_dns_zone_name          = "privatelink.azurewebsites.net"
saname                         = "privatelink.blob.core.windows.net"
private_dns_zone_vnet_ids      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001"
private_dns_zone_link_name     = "pdns-link-vnet-core"
private_dns_zone_sku_name      = "Standard"
subnet_id_webapp_integration   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-002"
#subnet_id_dr-webapp_integration = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network02/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-002/subnets/sn-sdc-network-003"
#Resource Group
rg_name = "rg-Stg-AZ"

#RBAC
#windows_vm_names = ["vm-Rpt-AZ"]
#linux_vm_names   = ["vm-Drools-AZ"]

# ACR
acr_name                               = "acrstgaz"
acr_sku                                = "Premium"
acr_admin_enabled                      = false
acr_private_endpoint_subresource_names = ["registry"]

# Key Vault
kv_name                               = "kv-Stg-AZ"
kv_sku                                = "premium"
kv_purge_protection                   = true
kv_soft_delete_retention_days         = 7
kv_private_endpoint_subresource_names = ["vault"]
virtual_network_subnet_ids_kv         = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-002", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-001", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-003", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-004"]

# Log Analytics
log_analytics_name                               = "law-Stg-AZ"
log_analytics_sku                                = "PerGB2018"
log_analytics_retention_days                     = 90
log_analytics_private_endpoint_subresource_names = ["workspace"]

# Automation Account
automation_account_sku = "Basic"

# Maintenance Configuration
maintenance_configuration_name                    = "mc-Stg-AZ"
maintenance_configuration_scope                   = "InGuestPatch"
maintenance_configuration_visibility              = "Custom"
maintenance_configuration_install_patches         = true
maintenance_configuration_reboot_setting          = "IfRequired"
maintenance_configuration_windows_classifications = ["Critical", "Security"]
maintenance_configuration_linux_classifications   = ["Critical", "Security"]
maintenance_configuration_duration                = 4 # hours
maintenance_configuration_timezone                = "America/New_York"
maintenance_configuration_recur_every             = "Week" # Day, Week, or Month

# Service Bus
sb_namespace_name                     = "sb-STG-AZ"
sb_sku                                = "Premium"
sb_queues                             = ["queue-deadletter-events", "queue-deadletter-events", "queue-deadletterservicebus", "queue-medicaid-cm-forms"]
sb_private_endpoint_subresource_names = ["namespace"]
#Queues: eadletter-events deadletter-forms deadletterservicebus medicaid-cm-forms
#topics: events-topic forms-topic medicaid-cm-forms-topic 

# App Service
app_service_plan_name = "asp-STG-AZ"
app_service_sku       = "P1v3"
app_name              = "app-api"
app_image_name        = "REPLACE_WITH_IMAGE_NAME"
app_image_tag         = "7178"

app_name_2       = "app-n8n"
app_image_name_2 = "n8n"
app_image_tag_2  = "2.9.24"

app_name_3       = "app-webapp"
app_image_name_3 = "REPLACE_WITH_IMAGE_NAME"
app_image_tag_3  = "7179"

app_name_4       = "app-proxy-app"
app_image_name_4 = "proxy-app"
app_image_tag_4  = "latest"

/*
#app_name_4 = "app-webapp-codescan"
#app_image_name_4 = "sonarqube-1.0.0-"
#app_image_tag_4 = "latest"
#app_name              = ["app-api", "app-n8n", "app-webapp", "app-webapp-codescan", "app-proxy-app"]
*/
app_settings = {
  #"WEBSITE_RUN_FROM_PACKAGE" = "1"
  #"WEBSITES_PORT"                              = "8080"
  #"APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.appi.connection_string
  #"APPINSIGHTS_INSTRUMENTATIONKEY"             = azurerm_application_insights.appi.instrumentation_key
  "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
  # Example: Key Vault reference (value set later after KV secret exists)
  # "MY_SECRET" = "@Microsoft.KeyVault(SecretUri=<filled by TF below>)"
}
app_private_endpoint_subresource_names = ["sites"]

# Storage Account
sa_name = "sastgaz"
#sa_namediag                               = "sastgazdiag"
sa_tier                                    = "Standard"
sa_replication                             = "RAGRS"
storage_containers                         = ["customuserflow-stg-az", "pics-storage-stg-az"]
storage_containers_diag                    = ["logs"]
storage_private_endpoint_subresource_names = ["blob"]

backup_policy_name              = "blob-backup-policy"
delete_retention_days           = 30
container_delete_retention_days = 30
restore_days                    = 7

diagnostics_storage_account_name = "sastgaz"
#diagnostics_storage_account_name           = "sastgazdiag"
diagnostics_storage_account_resource_group = "rg-Stg-AZ"

# Private Link Service
private_link_service_name                              = "pls-Stg-AZ"
private_link_service_lb_frontend_ip_configuration_name = "pls-frontend"

# Recovery Services Vault
rsv_name = "rsv-Stg-AZ"
rsv_sku  = "Standard"

# PostgreSQL Single Server
postgres_server_name            = "postgres-stg-az"
postgres_sku_name               = "GP_Standard_D4s_v3"
postgres_version                = "16"
postgres_administrator_login    = "pgadmin"
postgres_administrator_password = "CHANGE_ME_BEFORE_APPLY"
postgres_storage_mb             = 262144 # 256 GB
postgres_backup_vault           = "bv-Stg-AZ"

###############################################
####Added by Sup##########

#/23/11 added
# Network Security Group
# NSG Names
nsg_apim_name = "nsg-APIM-Stg-AZ"
nsg_pe_name   = "nsg-pe-Stg-AZ"
nsg_vm_name   = "nsg-vm-Stg-AZ"
nsg_vnt_name  = "nsg-vnt-Stg-AZ"
# Virtual Network Flow Logs Configuration
# Flow logs are configured and created entirely within the network_security_group module
# Flow logs are created automatically when storage_account_id is provided
#vnet_flow_log_config = {
#storage_account_id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-Stg-AZ/providers/Microsoft.Storage/storageAccounts/sastgazdiag"
#network_watcher_resource_group_name = "NetworkWatcherRG"
# network_watcher_name = "NetworkWatcher_eastus"  # Uncomment if Network Watcher is in a different region
#retention_days                      = 30
#enable_traffic_analytics            = true
#traffic_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-Stg-AZ/providers/Microsoft.OperationalInsights/workspaces/law-Stg-AZ"
#traffic_analytics_workspace_region = "eastus"
#traffic_analytics_interval         = 60
#}
# NSG Rules
# Private Endpoint subnet: 10.250.32.0/26
# VNet Integration subnet: 10.250.32.64/26
# VM subnet: 10.250.32.128/26
# APIM subnet: 10.250.32.192/26

# NSG Diagnostics
nsg_enable_diagnostics                = true
nsg_log_analytics_name                = "law-Stg-AZ"
nsg_log_analytics_workspace_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-Stg-AZ/providers/Microsoft.OperationalInsights/workspaces/law-Stg-AZ"
nsg_log_analytics_resource_group_name = "rg-Stg-AZ"

nsg_apim_rules = [
  {
    name                       = "PrivateEndpointAPIM-In"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.0/26"
    destination_address_prefix = "10.250.32.192/26"
  },
  {
    name                       = "VNet-IntegrationIn-APIM"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.64/26"
    destination_address_prefix = "10.250.32.192/26"
  },
  {
    name                       = "AzureFrontDoor.Backend"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureFrontDoor.Backend"
    destination_address_prefix = "10.250.32.192/26"
  },
  {
    name                       = "ApiManagement"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3443"
    source_address_prefix      = "ApiManagement"
    destination_address_prefix = "10.250.32.192/26"
  },
  {
    name                       = "AzureLoadBalancer"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6390"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "10.250.32.192/26"
  },
  {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "PrivateEndpointAPIM-Out"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.192/26"
    destination_address_prefix = "10.250.32.0/26"
  },
  {
    name                       = "DenyAllOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]
nsg_pe_rules = [
  {
    name                       = "APIMIn-PE"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.192/26"
    destination_address_prefix = "10.250.32.0/26"
  },
  {
    name                       = "VNet-IntegrationIn-PE"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.64/26"
    destination_address_prefix = "10.250.32.0/26"
  },
  {
    name                       = "VM"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.128/26"
    destination_address_prefix = "10.250.32.0/26"
  },
  {
    name                       = "AzureFrontDoor.Backend_PE"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureFrontDoor.Backend"
    destination_address_prefix = "10.250.32.0/26"
  },
  {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "APIMOut-PE"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.0/26"
    destination_address_prefix = "10.250.32.192/26"
  },
  {
    name                       = "VNet-IntegrationOut-PE"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.0/26"
    destination_address_prefix = "10.250.32.64/26"
  },
  {
    name                       = "DenyAllOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]
nsg_vm_rules = [
  {
    name                       = "VNet-IntegrationIn-VM"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.64/26"
    destination_address_prefix = "10.250.32.128/26"
  },
  {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "PrivateEndpointVM-Out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.128/26"
    destination_address_prefix = "10.250.32.0/26"
  }
]
nsg_vnt_rules = [
  {
    name                       = "PrivateEndpoint"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.0/26"
    destination_address_prefix = "10.250.32.64/26"
  },
  {
    name                       = "APIMIn-Vnet"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.192/26"
    destination_address_prefix = "10.250.32.64/26"
  },
  {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "VM"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.64/26"
    destination_address_prefix = "10.250.32.128/26"
  },
  {
    name                       = "PrivateEndpoint-Out"
    priority                   = 110
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.64/26"
    destination_address_prefix = "10.250.32.0/26"
  },
  {
    name                       = "APIMOut-Vnet"
    priority                   = 120
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.250.32.64/26"
    destination_address_prefix = "10.250.32.192/26"
  },
  {
    name                       = "DenyAllOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]

# API Management
apim_name            = "apim-Stg-AZ"
apim_publisher_email = "publisher@example.com"
apim_publisher_name  = "Oregon Youth Authority"
apim_sku_name        = "Premium_1"
apim_subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-004"

#Public IP
public_ip_name = "pip-Stg-AZ"

# Front Door
frontdoor_name                                = "fd-az-eastus-project-application"
frontdoor_sku_name                            = "Premium_AzureFrontDoor"
frontdoor_endpoint_name                       = "fde-az-eastus-project-application"
frontdoor_origin_host_name                    = "app-az-eastus-project-application.azurewebsites.net"
frontdoor_origin_host_header                  = "app-az-eastus-project-application.azurewebsites.net"
frontdoor_origin_private_link_target          = null
frontdoor_origin_private_link_location        = null
frontdoor_origin_private_link_request_message = "Requesting approval for Front Door private link"

###############################################
####Added by Sup##########

###################################

#####Load Balancer ################

# Load Balancer - Essential Configuration Only
# All other settings (NAT rules, probes, etc.) are configured with defaults in the module
lb_name                           = "lb-Stg-AZ"
lb_name_apim                      = "lb-APIM-Stg-AZ"
lb_sku                            = "Standard"
lb_frontend_ip_configuration_name = "lb-frontend"
lb_backend_pool_name              = "lb-backend"
lb_private_ip_address             = "10.250.32.140"
lb_private_ip_address_apim        = "10.250.32.145"

# Load Balancer Diagnostics
lb_enable_diagnostics                = true
lb_log_analytics_name                = "law-Stg-AZ"
lb_log_analytics_workspace_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-Stg-AZ/providers/Microsoft.OperationalInsights/workspaces/law-Stg-AZ"
lb_log_analytics_resource_group_name = "rg-Stg-AZ"

# Backend Pool Configuration
backend_pool_ip_configuration_name    = ""
lb_backend_pool_network_interface_ids = []
backend_pool_addresses_apim           = []
# Backend pool addresses - Empty if using VMSS (VMSS instances are added automatically)
# If using individual VMs, add them here
/*backend_pool_addresses = [
  {
    name       = "vm-Rpt-AZ",
    ip_address = "10.250.32.150",
    virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001"
  },
  {
    name       = "vm-Drools-AZ",
    ip_address = "10.250.32.151",
    virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001"
  },
  {
    name       = "vm-Pipeline-AZ",
    ip_address = "10.250.32.152",
    virtual_network_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001"
  }
]
*/
#existing_vm_names = {"vm-Rpt-Stg-AZ" = "vm-Rpt-Stg-AZ", "vm-Drools-Stg-AZ"= "vm-Drools-Stg-AZ"}
#existing_vm_names = {}

############################
# Virtual Machine Scale Sets Configuration
############################
# Windows VMSS (Rpt) Configuration
enable_vmss_rpt                       = true
vmss_rpt_vm_size                      = "Standard_D2s_v3"
vmss_rpt_instance_count               = 1
vmss_rpt_min_instance_count           = 1
vmss_rpt_max_instance_count           = 3
vmss_rpt_admin_username               = "azureadmin"
vmss_rpt_admin_password               = "CHANGE_ME_BEFORE_APPLY" # Use Key Vault reference in production
vmss_rpt_subnet_id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-003"
vmss_rpt_image_publisher              = "MicrosoftWindowsServer"
vmss_rpt_image_offer                  = "WindowsServer"
vmss_rpt_image_sku                    = "2022-datacenter-azure-edition"
vmss_rpt_image_version                = "latest"
vmss_rpt_os_disk_size_gb              = 128
vmss_rpt_os_disk_caching              = "ReadWrite"
vmss_rpt_os_disk_storage_account_type = "Premium_LRS"
enable_vmss_rpt_autoscale             = true # Set to true to enable auto-scaling
# DNS Configuration for Drools VMSS
# Note: DNS record will point to the load balancer frontend IP
vmss_rpt_private_dns_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-stg-az/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net"
vmss_rpt_dns_record_name     = "vm-Rpt-AZ" # DNS record name
vmss_rpt_dns_record_ttl      = 300         # TTL in seconds
# Linux VMSS (Drools) Configuration
enable_vmss_drools                       = true
vmss_drools_vm_size                      = "Standard_D2s_v3"
vmss_drools_instance_count               = 1
vmss_drools_min_instance_count           = 1
vmss_drools_max_instance_count           = 5
vmss_drools_admin_username               = "azureuser"
vmss_drools_ssh_public_key               = ""
vmss_drools_subnet_id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-003"
vmss_drools_image_publisher              = "RedHat"
vmss_drools_image_offer                  = "RHEL"
vmss_drools_image_sku                    = "9_4"
vmss_drools_image_version                = "latest"
vmss_drools_os_disk_size_gb              = 128
vmss_drools_os_disk_caching              = "ReadWrite"
vmss_drools_os_disk_storage_account_type = "Premium_LRS"
enable_vmss_drools_autoscale             = true # Set to true to enable auto-scaling
# DNS Configuration for Drools VMSS
# Note: DNS record will point to the load balancer frontend IP
vmss_drools_private_dns_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-stg-az/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net"
vmss_drools_dns_record_name     = "vm-Drools-Stg-AZ" # DNS record name
vmss_drools_dns_record_ttl      = 300                # TTL in seconds

# Linux VMSS (Pipeline) Configuration
enable_vmss_pipeline                       = true
vmss_pipeline_vm_size                      = "Standard_D2s_v3"
vmss_pipeline_instance_count               = 1
vmss_pipeline_min_instance_count           = 1
vmss_pipeline_max_instance_count           = 5
vmss_pipeline_admin_username               = "azureuser"
vmss_pipeline_ssh_public_key               = ""
vmss_pipeline_subnet_id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-003"
vmss_pipeline_image_publisher              = "RedHat"
vmss_pipeline_image_offer                  = "RHEL"
vmss_pipeline_image_sku                    = "9_4"
vmss_pipeline_image_version                = "latest"
vmss_pipeline_os_disk_size_gb              = 128
vmss_pipeline_os_disk_caching              = "ReadWrite"
vmss_pipeline_os_disk_storage_account_type = "Premium_LRS"
enable_vmss_pipeline_autoscale             = true # Set to true to enable auto-scaling


#Virtual Machine
#use_existing_vms = false

vm_configurations = {
  "vm-Rpt-Stg-AZ" = {
    os_type                                = "Windows"
    vm_size                                = "Standard_D4s_v5"
    admin_username                         = "azureadmin"
    admin_password                         = "CHANGE_ME_BEFORE_APPLY"
    subnet_id                              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-003"
    private_ip_allocation                  = "Static"
    private_ip                             = "10.250.32.150"
    ip_configuration_name                  = "ipconfig-vm-Rpt-AZ"
    nic_name                               = "nic-Rpt-Stg-AZ"
    os_disk_name                           = "disk-Rpt-Stg-AZ"
    os_disk_size_gb                        = 128
    os_disk_caching                        = "ReadWrite"
    os_disk_storage_account_type           = "Premium_LRS"
    computer_name                          = "VM-Rpt"
    image_publisher                        = "MicrosoftWindowsServer"
    image_offer                            = "WindowsServer"
    image_sku                              = "2022-datacenter-azure-edition"
    image_version                          = "latest"
    enable_boot_diagnostics                = true
    enable_managed_identity                = true
    enable_entra_id_auth                   = true
    enable_vm_insights                     = true
    enable_change_tracking                 = true
    enable_performance_diagnostics         = true
    enable_config_management               = true        # DSC settings required if set to true
    automation_account_name                = "aa-Stg-AZ" # Automation Account name for DSC (must exist)
    automation_account_resource_group_name = "rg-Stg-AZ" # Resource group where Automation Account is located
    enable_maintenance_configuration       = true        # set maintenance_configuration_id if true
    automatic_extension_upgrade_enabled    = true
    enable_antimalware                     = true
    enable_jit_access                      = true      # Azure Defender JIT must be configured separately
    enable_machine_configuration           = true      # requires guest configuration policy assignment
    enable_diagnostics                     = true      # For diagnosis settings
    enable_diagnostics_extension           = true      # Enable Azure Diagnostics Extension (WAD/LAD) - requires diagnostics_storage_account_id
    enable_application_health              = true      # Enable application health monitoring extension
    application_health_protocol            = "http"    # Protocol for health probe (http or https)
    application_health_port                = 80        # Port for health probe
    application_health_request_path        = "/health" # Request path for health probe
    application_health_interval            = 30        # Interval in seconds between health probes
    application_health_unhealthy_threshold = 3         # Number of consecutive failed probes before marking unhealthy
    availability_set_name                  = "as-Stg-AZ"
    availability_set_fault_domain_count    = 2
    availability_set_update_domain_count   = 5
    availability_set_managed               = true
    log_analytics_name                     = "law-Stg-AZ"
    log_analytics_workspace_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-Stg-AZ/providers/Microsoft.OperationalInsights/workspaces/law-Stg-AZ"
    log_analytics_resource_group_name      = "rg-Stg-AZ"
  }

  "vm-Drools-Stg-AZ" = {
    os_type                             = "Linux"
    vm_size                             = "Standard_D4s_v5"
    admin_username                      = "azureuser"
    ssh_public_key                      = ""
    admin_password                      = ""
    subnet_id                           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-003"
    private_ip_allocation               = "Static"
    private_ip                          = "10.250.32.151"
    ip_configuration_name               = "ipconfig-vm-Drools-AZ"
    nic_name                            = "nic-Drools-Stg-AZ"
    os_disk_name                        = "disk-Drools-Stg-AZ"
    os_disk_size_gb                     = 128
    os_disk_caching                     = "ReadWrite"
    os_disk_storage_account_type        = "Premium_LRS"
    image_publisher                     = "RedHat"
    image_offer                         = "RHEL"
    image_sku                           = "9_4"
    image_version                       = "latest"
    enable_boot_diagnostics             = true
    enable_managed_identity             = true
    enable_vm_insights                  = true
    enable_change_tracking              = true
    enable_performance_diagnostics      = true
    enable_config_management            = true # DSC is Windows-only
    enable_maintenance_configuration    = true # set maintenance_configuration_id if true
    automatic_extension_upgrade_enabled = true
    enable_jit_access                   = true
    enable_machine_configuration        = true
    enable_diagnostics                  = true # For diagnosis settings
    enable_diagnostics_extension        = true # Enable Azure Diagnostics Extension (WAD/LAD) - requires diagnostics_storage_account_id
    #enable_application_health            = true # Enable application health monitoring extension
    #application_health_protocol          = "http" # Protocol for health probe (http or https)
    #application_health_port              = 80 # Port for health probe
    #application_health_request_path      = "/health" # Request path for health probe
    #application_health_interval          = 30 # Interval in seconds between health probes
    #application_health_unhealthy_threshold = 3 # Number of consecutive failed probes before marking unhealthy
    availability_set_name                = "as-Stg-AZ"
    availability_set_fault_domain_count  = 2
    availability_set_update_domain_count = 5
    availability_set_managed             = true
    log_analytics_name                   = "law-Stg-AZ"
    log_analytics_workspace_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-Stg-AZ/providers/Microsoft.OperationalInsights/workspaces/law-Stg-AZ"
    log_analytics_resource_group_name    = "rg-Stg-AZ"
    # Add DNS configuration:
    private_dns_zone_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-stg-az/providers/Microsoft.Network/privateDnsZones/privatelink.azure-api.net"
    dns_record_name     = "vm-Drools-Stg-AZ" # Optional - will use "vm-Drools-Stg-AZ" if not set
    # Disaster Recovery (Azure Site Recovery)
    enable_disaster_recovery      = true
    recovery_vault_name           = "rsv-Stg-AZ"
    recovery_vault_resource_group = "rg-Stg-AZ"
    replication_policy_name       = "asr-default-policy"
    target_resource_group_name    = "rg-Stg-TX" # Target DR region resource group
    target_location               = "westus"    # Target DR region
    #target_vnet_id                       = ""  # Target VNet ID
    #target_subnet_name                   = ""  # Target subnet name
  }
  /*
  "vm-Pipeline-AZ" = {
    os_type        = "Linux"
    vm_size        = "Standard_D4s_v5"
    admin_username = "azureuser"
    ssh_public_key = ""
    admin_password = ""
    subnet_id                            = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-sdc-network01/providers/Microsoft.Network/virtualNetworks/vn-sdc-network-001/subnets/sn-sdc-network-003"
    private_ip_allocation                = "Static"
    private_ip                           = "10.250.32.152"
    ip_configuration_name                = "ipconfig-vm-Pipeline-AZ"
    nic_name                             = "vm-Pipeline-AZ-nic"
    os_disk_name                         = "vm-Pipeline-AZ-OSDisk"
    os_disk_size_gb                      = 128
    os_disk_caching                      = "ReadWrite"
    os_disk_storage_account_type         = "Premium_LRS"
    image_publisher                      = "RedHat"
    image_offer                          = "RHEL"
    image_sku                            = "9_4"
    image_version                        = "latest"
    enable_boot_diagnostics              = true
    enable_managed_identity              = true
    enable_vm_insights                   = true
    enable_change_tracking               = true
    enable_performance_diagnostics       = true
    enable_config_management             = false # DSC is Windows-only
    enable_maintenance_configuration     = false # set maintenance_configuration_id if true
    automatic_extension_upgrade_enabled  = true
    enable_jit_access                    = false
    enable_machine_configuration         = false
    enable_diagnostics                   = false # For diagnosis settings
    enable_diagnostics_extension         = false # Enable Azure Diagnostics Extension (WAD/LAD) - requires diagnostics_storage_account_id
    enable_application_health            = true # Enable application health monitoring extension
    application_health_protocol          = "http" # Protocol for health probe (http or https)
    application_health_port              = 80 # Port for health probe
    application_health_request_path      = "/health" # Request path for health probe
    application_health_interval          = 30 # Interval in seconds between health probes
    application_health_unhealthy_threshold = 3 # Number of consecutive failed probes before marking unhealthy
    availability_set_name                = "as-Stg-AZ"
    availability_set_fault_domain_count  = 2
    availability_set_update_domain_count = 5
    availability_set_managed             = true
    log_analytics_name                   = "law-Stg-AZ"
    log_analytics_resource_group_name    = "rg-Stg-AZ"
  }
  */
}