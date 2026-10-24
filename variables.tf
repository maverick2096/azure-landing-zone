#########################
# Global
#########################
variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}
variable "build_date" {
  description = "datetime for all resources"
  type        = string
  default     = "NULL"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

#########################
# Build toggles (booleans)
#########################
variable "build_resource_group" {
  type    = bool
  default = true
}

variable "build_acr" {
  type    = bool
  default = true
}

variable "build_key_vault" {
  type    = bool
  default = true
}

variable "build_log_analytics" {
  type    = bool
  default = true
}

variable "build_vm" {
  type    = bool
  default = false
}

variable "build_servicebus" {
  type    = bool
  default = true
}

variable "build_app_service" {
  type    = bool
  default = true
}

variable "build_storage" {
  type    = bool
  default = true
}

variable "build_storage_diag" {
  type    = bool
  default = true

}

variable "enable_private_endpoints" {
  description = "Enable creation of private endpoints for provisioned services"
  type        = bool
  default     = true
}

variable "build_private_dns_zone" {
  type    = bool
  default = true
}

variable "build_app_service_plan" {
  type    = bool
  default = true
}

variable "build_private_link_service" {
  type    = bool
  default = false
}

variable "build_recovery_vault" {
  type    = bool
  default = false
}

variable "build_postgres" {
  type    = bool
  default = false
}

variable "build_nsg" {
  type    = bool
  default = false
}

variable "build_load_balancer" {
  type    = bool
  default = false
}

variable "build_api_management" {
  type    = bool
  default = false
}

variable "build_frontdoor" {
  type    = bool
  default = false
}

variable "build_rbac" {
  type    = bool
  default = false
}

variable "build_automation_account" {
  type    = bool
  default = false
}

variable "build_maintenance_configuration" {
  type    = bool
  default = false
}

locals {
  enable_rg                 = var.build_resource_group
  enable_acr                = var.build_acr
  enable_kv                 = var.build_key_vault
  enable_law                = var.build_log_analytics
  enable_vm                 = var.build_vm
  enable_servicebus         = var.build_servicebus
  enable_app_service        = var.build_app_service
  enable_storage            = var.build_storage
  enable_storage_diag       = var.build_storage_diag
  enable_private_ep         = var.enable_private_endpoints
  enable_private_dns        = var.build_private_dns_zone
  enable_pls                = var.build_private_link_service
  enable_recovery_vault     = var.build_recovery_vault
  enable_postgres           = var.build_postgres
  enable_nsg                = var.build_nsg
  enable_load_balancer      = var.build_load_balancer
  enable_apim               = var.build_api_management
  enable_frontdoor          = var.build_frontdoor
  enable_app_service_plan   = var.build_app_service_plan
  enable_rbac               = var.build_rbac
  enable_automation         = var.build_automation_account
  enable_maintenance_config = var.build_maintenance_configuration
}

#########################
# Networking inputs
#########################
variable "virtual_network_id" {
  description = "Existing virtual network to associate private DNS links with"
  type        = string
  default     = null
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID where private endpoints will be created"
  type        = string
  default     = null
}

variable "private_link_service_subnet_id" {
  description = "Subnet ID used by the private link service (if enabled)"
  type        = string
  default     = null
}

variable "private_dns_zone_name" {
  description = "Name of the general purpose private DNS zone"
  type        = string
  default     = null
}

variable "saname" {
  description = "Name of the stoeragaccount private DNS zone"
  type        = string
  default     = null
}


variable "private_dns_zone_vnet_ids" {
  description = "List of virtual network IDs to link to the private DNS zone"
  type        = string
  default     = null
}

variable "private_dns_zone_sku_name" {
  description = "The SKU name for the Private DNS Zone"
  type        = string
  default     = "Standard"
}
#########################
# Resource-specific inputs (defaults prevent prompts)
#########################

# Resource Group
variable "rg_name" {
  type    = string
  default = null
  validation {
    condition     = (var.build_resource_group == false) || (var.rg_name != null && length(var.rg_name) > 0)
    error_message = "rg_name is required when build_resource_group = true."
  }
}

# ACR
variable "acr_name" {
  type    = string
  default = null
  validation {
    condition     = (var.build_acr == false) || (var.acr_name != null && can(regex("^[a-z0-9]{5,50}$", var.acr_name)))
    error_message = "acr_name (lowercase alphanumeric, 5-50) is required when build_acr = true."
  }
}

variable "acr_sku" {
  type    = string
  default = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic | Standard | Premium."
  }
}

variable "acr_admin_enabled" {
  type    = bool
  default = false
}

variable "acr_private_endpoint_subresource_names" {
  description = "Subresource names used for the ACR private endpoint"
  type        = list(string)
  default     = ["registry"]
}

# Key Vault (infra)
variable "kv_name" {
  type    = string
  default = null
  validation {
    condition = (!var.build_key_vault) || (
      var.kv_name != null &&
      length(var.kv_name) >= 3 &&
      length(var.kv_name) <= 24 &&
      regex("^[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?$", var.kv_name) != null
    )
    error_message = "kv_name must be 3-24 characters, lowercase alphanumeric with optional single dashes (no leading/trailing dash)."
  }
}

variable "kv_sku" {
  type    = string
  default = "standard"
  validation {
    condition     = contains(["standard", "premium"], lower(var.kv_sku))
    error_message = "kv_sku must be 'standard' or 'premium'."
  }
}

variable "kv_purge_protection" {
  type    = bool
  default = true
}

variable "kv_soft_delete_retention_days" {
  type    = number
  default = 7
}

variable "kv_private_endpoint_subresource_names" {
  description = "Subresource names used for the Key Vault private endpoint"
  type        = list(string)
  default     = ["vault"]
}

# Log Analytics
variable "log_analytics_name" {
  type    = string
  default = null
  validation {
    condition     = (var.build_log_analytics == false) || (var.log_analytics_name != null && length(var.log_analytics_name) > 0)
    error_message = "log_analytics_name is required when build_log_analytics = true."
  }
}

variable "log_analytics_sku" {
  type    = string
  default = "PerGB2018"
}

variable "log_analytics_retention_days" {
  type    = number
  default = 30
}

variable "log_analytics_private_endpoint_subresource_names" {
  description = "Subresource names for the Log Analytics private endpoint"
  type        = list(string)
  default     = ["workspace"]
}

/*
#Automation Account
variable "automation_account_name" {
  type    = string
  default = null
  validation {
    condition     = (var.build_automation_account == false) || (var.automation_account_name != null && length(var.automation_account_name) > 0)
    error_message = "automation_account_name is required when build_automation_account = true."
  }
}
variable "automation_account_sku" {
  type    = string
  default = "Basic"
  validation {
    condition     = contains(["Basic", "Free"], var.automation_account_sku)
    error_message = "automation_account_sku must be 'Basic' or 'Free'."
  }
}
*/

# Maintenance Configuration
variable "maintenance_configuration_name" {
  type    = string
  default = null
  validation {
    condition     = (var.build_maintenance_configuration == false) || (var.maintenance_configuration_name != null && length(var.maintenance_configuration_name) > 0)
    error_message = "maintenance_configuration_name is required when build_maintenance_configuration = true."
  }
}
variable "maintenance_configuration_scope" {
  description = "Scope of the maintenance configuration. Options: 'InGuestPatch', 'OSImage', 'Extension', 'InGuestPatchAndOSImage', 'SQLDB', 'SQLManagedInstance'"
  type        = string
  default     = "InGuestPatch"
  validation {
    condition     = contains(["InGuestPatch", "OSImage", "Extension", "InGuestPatchAndOSImage", "SQLDB", "SQLManagedInstance"], var.maintenance_configuration_scope)
    error_message = "maintenance_configuration_scope must be one of: InGuestPatch, OSImage, Extension, InGuestPatchAndOSImage, SQLDB, SQLManagedInstance."
  }
}
variable "maintenance_configuration_visibility" {
  description = "Visibility of the maintenance configuration. Options: 'Custom', 'Public'"
  type        = string
  default     = "Custom"
  validation {
    condition     = contains(["Custom", "Public"], var.maintenance_configuration_visibility)
    error_message = "maintenance_configuration_visibility must be 'Custom' or 'Public'."
  }
}
variable "maintenance_configuration_install_patches" {
  description = "Enable automatic patch installation during maintenance"
  type        = bool
  default     = true
}
variable "maintenance_configuration_reboot_setting" {
  description = "Reboot setting for maintenance. Options: 'IfRequired', 'Always', 'Never'"
  type        = string
  default     = "IfRequired"
  validation {
    condition     = contains(["IfRequired", "Always", "Never"], var.maintenance_configuration_reboot_setting)
    error_message = "maintenance_configuration_reboot_setting must be 'IfRequired', 'Always', or 'Never'."
  }
}
variable "maintenance_configuration_windows_classifications" {
  description = "Windows update classifications to include. Options: 'Critical', 'Security', 'UpdateRollup', 'FeaturePack', 'ServicePack', 'Definition', 'Tools', 'Updates'"
  type        = list(string)
  default     = ["Critical", "Security"]
}
variable "maintenance_configuration_linux_classifications" {
  description = "Linux update classifications to include. Options: 'Critical', 'Security', 'Other'"
  type        = list(string)
  default     = ["Critical", "Security"]
}
variable "maintenance_configuration_duration" {
  description = "Duration of the maintenance window in hours (1-23)"
  type        = number
  default     = 4
  validation {
    condition     = var.maintenance_configuration_duration >= 1 && var.maintenance_configuration_duration <= 23
    error_message = "maintenance_configuration_duration must be between 1 and 23 hours."
  }
}
variable "maintenance_configuration_timezone" {
  description = "Timezone for maintenance schedule (e.g., 'America/New_York', 'UTC')"
  type        = string
  default     = "UTC"
}
variable "maintenance_configuration_recur_every" {
  description = "Recurrence pattern for maintenance (e.g., 'Day', 'Week', 'Month')"
  type        = string
  default     = "Week"
  validation {
    condition     = contains(["Day", "Week", "Month"], var.maintenance_configuration_recur_every)
    error_message = "maintenance_configuration_recur_every must be 'Day', 'Week', or 'Month'."
  }
}

variable "virtual_network_subnet_ids_kv" {
  description = "List of subnet IDs for resources requiring subnet associations"
  type        = list(string)
  default     = []

}

#############################
#created 
#############################
# VM (Linux)
variable "vm_image" {
  description = "Image reference (deprecated - use vm_configurations instead)"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# Multiple VM configurations - supports Windows and Linux VMs
variable "vm_configurations" {
  description = "List of VM configurations to create. Each VM can be Windows or Linux (RHEL)"
  type = map(object({
    os_type                          = string
    vm_size                          = string
    admin_username                   = string
    admin_password                   = optional(string, "")
    ssh_public_key                   = optional(string, "")
    subnet_id                        = string
    os_disk_size_gb                  = number
    os_disk_caching                  = optional(string, "ReadWrite")
    os_disk_storage_account_type     = optional(string, "Premium_LRS")
    image_publisher                  = string
    image_offer                      = string
    image_sku                        = string
    image_version                    = optional(string, "latest")
    private_ip_allocation            = optional(string, "Dynamic")
    private_ip                       = optional(string, null)
    computer_name                    = optional(string, "")
    enable_boot_diagnostics          = optional(bool, false)
    boot_diagnostics_storage_account = optional(string, "")
    # Diagnostic settings
    enable_diagnostics                = optional(bool, false)
    log_analytics_name                = optional(string, null)
    log_analytics_workspace_id        = optional(string, null)
    log_analytics_resource_group_name = optional(string, null)
    diagnostics_storage_account_id    = optional(string, null)

    # Private DNS Zone
    private_dns_zone_id = optional(string, null)
    dns_record_name     = optional(string, null)
    # Monitoring - optional Data Collection Rule to route Azure Monitor Agent telemetry
    data_collection_rule_id = optional(string, null)
    # Availability Set
    availability_set_id                  = optional(string, null)
    availability_set_name                = optional(string, null)
    availability_set_fault_domain_count  = optional(number, 2)
    availability_set_update_domain_count = optional(number, 5)
    availability_set_managed             = optional(bool, true)
    # Network Interface
    ip_configuration_name = optional(string, "ipconfig1")
    nic_name              = optional(string, null)
    # OS Disk
    os_disk_name = optional(string, null)
    # Security and Management Features
    enable_managed_identity                = optional(bool, true)
    user_assigned_identity_ids             = optional(list(string), [])
    enable_entra_id_auth                   = optional(bool, true)
    enable_vm_insights                     = optional(bool, true)
    enable_change_tracking                 = optional(bool, true)
    enable_performance_diagnostics         = optional(bool, true)
    enable_config_management               = optional(bool, false)
    automation_account_name                = optional(string, null)
    automation_account_resource_group_name = optional(string, null)
    enable_maintenance_configuration       = optional(bool, false)
    maintenance_configuration_id           = optional(string, null)
    automatic_extension_upgrade_enabled    = optional(bool, true)

    # Application Health Extension
    # enable_application_health = optional(bool, false)
    # application_health_protocol = optional(string, null)
    # application_health_port = optional(number, null)
    # application_health_request_path = optional(string, null)
    # application_health_interval = optional(number, null)
    # application_health_unhealthy_threshold = optional(number, null)
  }))
  default = {}
}

variable "enable_application_health" {
  description = "Enable health monitoring on Windows VMs"
  type        = bool
  default     = false
}

variable "application_health_protocol" {
  description = "Protocol for health monitoring (HTTP/TCP)"
  type        = string
  default     = "HTTP"
}

variable "application_health_port" {
  description = "Port for health monitoring"
  type        = number
  default     = 8080
}

variable "application_health_request_path" {
  description = "Request path for health monitoring"
  type        = string
  default     = "/health"
}

variable "application_health_interval" {
  description = "Interval for health monitoring in seconds"
  type        = number
  default     = 60
}

variable "application_health_unhealthy_threshold" {
  description = "Number of failed health checks to mark VM unhealthy"
  type        = number
  default     = 3
}

variable "vm_subnet_id" {
  type    = string
  default = null
}

/*
variable "target_vnet_id" {
  description = "The ID of the VNet where the VM's NIC will be created."
  type        = string
}

variable "target_subnet_name" {
  description = "The name of the Subnet within the VNet where the VM's NIC will be attached."
  type        = string
}
*/
############################
###Old ones##########

/*
# VM (Linux)
variable "vm_name" {
  type    = string
  default = null
}

variable "vm_size" {
  type    = string
  default = "Standard_DS2_v2"
}

variable "vm_admin_user" {
  type    = string
  default = "azureuser"
}

variable "vm_ssh_public_key" {
  type    = string
  default = null
}

variable "vm_os_disk_size_gb" {
  type    = number
  default = 64
}

variable "vm_subnet_id" {
  type    = string
  default = null
}

variable "vm_image" {
  description = "Image reference"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

variable "vm_requirements_ok" {
  description = "Internal validation guard for VM inputs"
  type        = bool
  default     = true
  validation {
    condition = (!var.vm_requirements_ok) || (
      var.build_vm == false ||
      (var.vm_name != null && var.vm_subnet_id != null && var.vm_ssh_public_key != null)
    )
    error_message = "When build_vm = true, set vm_name, vm_subnet_id and vm_ssh_public_key."
  }
}
*/

# Service Bus
variable "sb_namespace_name" {
  type    = string
  default = null
}

variable "sb_sku" {
  type    = string
  default = "Standard"
}

variable "sb_queues" {
  type    = list(string)
  default = []
}

variable "sb_requirements_ok" {
  type    = bool
  default = true
  validation {
    condition     = (!var.sb_requirements_ok) || (var.build_servicebus == false) || (var.sb_namespace_name != null)
    error_message = "sb_namespace_name is required when build_servicebus = true."
  }
}

variable "sb_private_endpoint_subresource_names" {
  description = "Subresource names for the Service Bus private endpoint"
  type        = list(string)
  default     = ["namespace"]
}

# App Service (Linux)
variable "app_service_plan_name" {
  type    = string
  default = null
}

variable "app_service_sku" {
  type    = string
  default = "P1v3"
}

variable "app_name" {
  type    = string
  default = null
}

variable "app_name_2" {
  type    = string
  default = null
}

variable "app_name_3" {
  type    = string
  default = null
}
variable "app_name_4" {
  type    = string
  default = null
}

variable "app_image_name" {
  description = "Container image/repository name for the API web app (in the ACR). Replace the placeholder with your image name."
  type        = string
  default     = "REPLACE_WITH_IMAGE_NAME"
}

variable "app_image_tag" {
  type    = string
  default = "latest"

}

variable "app_image_name_2" {
  description = "Container image/repository name for web app 2 (in the ACR). Replace the placeholder with your image name."
  type        = string
  default     = "REPLACE_WITH_IMAGE_NAME"
}
variable "app_image_tag_2" {
  type    = string
  default = "latest"

}
variable "app_image_name_3" {
  description = "Container image/repository name for web app 3 (in the ACR). Replace the placeholder with your image name."
  type        = string
  default     = "REPLACE_WITH_IMAGE_NAME"
}
variable "app_image_tag_3" {
  type    = string
  default = "latest"

}
variable "app_image_name_4" {
  description = "Container image/repository name for web app 4 (in the ACR). Replace the placeholder with your image name."
  type        = string
  default     = "REPLACE_WITH_IMAGE_NAME"
}
variable "app_image_tag_4" {
  type    = string
  default = "latest"
}

variable "app_settings" {
  type    = map(string)
  default = {}
}

variable "subnet_id_webapp_integration" {
  description = "Subnet ID for App Service VNet integration"
  type        = string
  default     = null

}
variable "app_requirements_ok" {
  type    = bool
  default = true
  validation {
    condition     = (!var.app_requirements_ok) || (var.build_app_service == false) || (var.app_service_plan_name != null && var.app_name != null)
    error_message = "app_service_plan_name and app_name are required when build_app_service = true."
  }
}

variable "app_private_endpoint_subresource_names" {
  description = "Subresource names for the App Service private endpoint"
  type        = list(string)
  default     = ["sites"]
}

# Storage Account
variable "sa_name" {
  type    = string
  default = null
  validation {
    condition     = (var.build_storage == false) || (var.sa_name != null && can(regex("^[a-z0-9]{3,24}$", var.sa_name)))
    error_message = "sa_name (3-24 lowercase alphanumeric) is required when build_storage = true."
  }
}

variable "sa_namediag" {
  type    = string
  default = null
  validation {
    condition     = (var.build_storage_diag == false) || (var.sa_namediag != null && can(regex("^[a-z0-9]{3,24}$", var.sa_namediag)))
    error_message = "sa_name_diag (3-24 lowercase alphanumeric) is required when build_storage_diag = true."
  }

}

variable "sa_tier" {
  type    = string
  default = "Standard"
}

variable "sa_replication" {
  type    = string
  default = "GRS"
}

variable "storage_containers" {
  type    = list(string)
  default = []
}

variable "storage_containers_diag" {
  type    = list(string)
  default = []
}

variable "storage_private_endpoint_subresource_names" {
  description = "Subresource names for the Storage account private endpoint"
  type        = list(string)
  default     = ["blob"]
}

#########################
# Private DNS Zone
#########################
variable "private_dns_zone_link_name" {
  description = "Name for the private DNS zone virtual network link"
  type        = string
  default     = null
}

#########################
# Private Link Service
#########################
variable "private_link_service_name" {
  type    = string
  default = null
}

variable "private_link_service_lb_frontend_ip_configuration_name" {
  description = "Name of the load balancer frontend IP configuration associated with the private link service"
  type        = string
  default     = null
}

#########################
# Recovery Services Vault
#########################
variable "rsv_name" {
  type    = string
  default = null
}

variable "rsv_sku" {
  type    = string
  default = "Standard"
}

#########################
# PostgreSQL Single Server
#########################
variable "postgres_server_name" {
  type    = string
  default = null
}

variable "postgres_sku_name" {
  type    = string
  default = "GP_Gen5_4"
}

variable "postgres_version" {
  type    = string
  default = "11"
}

variable "postgres_administrator_login" {
  type    = string
  default = null
}

variable "postgres_administrator_password" {
  type    = string
  default = null
}

variable "postgres_storage_mb" {
  type    = number
  default = 51200
}

variable "postgres_backup_vault" {
  type        = string
  description = "Name for PostgreSQL Backup Vault"
}

#########################
# Network Security Group
#########################
# New NSG rule variables for the 4 NSGs
variable "nsg_apim_rules" {
  description = "List of NSG security rules for API Management NSG"
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default = []
}
variable "nsg_pe_rules" {
  description = "List of NSG security rules for Private Endpoint NSG"
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default = []
}
variable "nsg_vm_rules" {
  description = "List of NSG security rules for VM Subnet NSG"
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default = []
}
variable "nsg_vnt_rules" {
  description = "List of NSG security rules for VNet Integration NSG"
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default = []
}
# NSG Names
variable "nsg_apim_name" {
  description = "Name of the API Management NSG"
  type        = string
  default     = null
}
variable "nsg_pe_name" {
  description = "Name of the Private Endpoint NSG"
  type        = string
  default     = null
}
variable "nsg_vm_name" {
  description = "Name of the VM Subnet NSG"
  type        = string
  default     = null
}
variable "nsg_vnt_name" {
  description = "Name of the VNet Integration NSG"
  type        = string
  default     = null
}

variable "nsg_enable_diagnostics" {
  description = "Enable diagnostic settings for the NSG"
  type        = bool
  default     = false
}

variable "nsg_log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for load balancer diagnostics (full resource ID)"
  type        = string
  default     = null
}

variable "nsg_diagnostics_storage_account_id" {
  description = "Storage account ID for NSG diagnostics (alternative to Log Analytics)"
  type        = string
  default     = null
}

/*

# Virtual Network Flow Logs Configuration - added 23/11
# Flow logs are configured and created entirely within the network_security_group module
# This variable is passed to all NSG modules - flow logs are created by default when storage_account_id is provided
variable "vnet_flow_log_config" {
  description = "Virtual Network Flow Logs configuration (passed to NSG module). Flow logs are created automatically when storage_account_id is provided."
  type = object({
    storage_account_id                    = optional(string, null)
    network_watcher_name                  = optional(string, null)
    network_watcher_resource_group_name   = optional(string, "NetworkWatcherRG")
    retention_days                       = optional(number, 30)
    enable_traffic_analytics              = optional(bool, true)
    traffic_analytics_workspace_id       = optional(string, null)
    traffic_analytics_workspace_region   = optional(string, null)
    traffic_analytics_interval           = optional(number, 60)
  })
  default = {
    storage_account_id                  = null
    network_watcher_name                = null
    network_watcher_resource_group_name = "NetworkWatcherRG"
    retention_days                      = 30
    enable_traffic_analytics            = true
    traffic_analytics_workspace_id     = null
    traffic_analytics_workspace_region = null
    traffic_analytics_interval         = 60
  }
  validation {
    condition     = var.vnet_flow_log_config.traffic_analytics_interval == null || contains([10, 60], var.vnet_flow_log_config.traffic_analytics_interval)
    error_message = "traffic_analytics_interval must be 10 or 60 minutes."
  }
}


# Virtual Network Flow Logs Configuration

variable "vnet_flow_log_storage_account_id" {
  description = "Storage account ID where VNet flow logs will be stored"
  type        = string
  default     = null
}
variable "vnet_flow_log_network_watcher_name" {
  description = "Name of the Network Watcher (if using existing). If not provided, will use default NetworkWatcher_<region>"
  type        = string
  default     = null
}
variable "vnet_flow_log_network_watcher_resource_group_name" {
  description = "Resource group name where Network Watcher is located (defaults to NetworkWatcherRG)"
  type        = string
  default     = "NetworkWatcherRG"
}
variable "vnet_flow_log_retention_days" {
  description = "Number of days to retain flow logs in storage account"
  type        = number
  default     = 7
}
variable "vnet_flow_log_enable_traffic_analytics" {
  description = "Enable Traffic Analytics for VNet Flow Logs (requires Log Analytics workspace)"
  type        = bool
  default     = false
}
variable "vnet_flow_log_traffic_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID for Traffic Analytics"
  type        = string
  default     = null
}
variable "vnet_flow_log_traffic_analytics_workspace_region" {
  description = "Region of the Log Analytics workspace for Traffic Analytics"
  type        = string
  default     = null
}
variable "vnet_flow_log_traffic_analytics_interval" {
  description = "How frequently Traffic Analytics should query flow logs (in minutes). Valid values: 10 or 60"
  type        = number
  default     = 60
  validation {
    condition     = var.vnet_flow_log_traffic_analytics_interval == null || contains([10, 60], var.vnet_flow_log_traffic_analytics_interval)
    error_message = "vnet_flow_log_traffic_analytics_interval must be 10 or 60 minutes."
  }
}
variable "vnet_flow_log_subnets" {
  description = "Map of subnet names to subnet IDs for which to enable flow logs. If not provided, will use configured subnets (apim, private_endpoint, vm, vnet_integration)"
  type = map(object({
    subnet_id = string
    enabled   = optional(bool, true)
  }))
  default = {}
}
*/

/*

# Old commented#############




variable "nsg_name" {
  type    = string
  default = null
}

variable "nsg_security_rules" {
  description = "List of NSG security rules"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "vnt_nsg_rules" {
  description = "List of NSG security rules for VM NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
  
}
variable "vm_subnet_nsg_rules" {
  description = "List of NSG security rules for VM Subnet NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
  
}

variable "pe_nsg_rules" {
  description = "List of NSG security rules for Private Endpoint NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
  
}

*/


#PUBLIC IP
variable "public_ip_name" {
  type    = string
  default = null
}

#########################
# Load Balancer
#########################

variable "lb_name" {
  type    = string
  default = null
}


variable "lb_name_apim" {
  type    = string
  default = null
}

variable "lb_backend_pool_name" {
  type    = string
  default = null
}

variable "lb_backend_pool_network_interface_ids" {
  description = "List of NIC IDs to associate with the load balancer backend pool"
  type        = list(string)
  default     = []
}

variable "backend_pool_ip_configuration_name" {
  description = "IP configuration name used when associating NICs to the backend pool"
  type        = string
  default     = "ipconfig1"
}

variable "lb_frontend_ip_configuration_name" {
  type    = string
  default = "lb-frontend"
}

variable "lb_is_public" {
  type    = bool
  default = false
}

variable "lb_private_ip_address" {
  type    = string
  default = null
}

variable "lb_private_ip_address_apim" {
  type    = string
  default = null
}

variable "subnet_id_dr_webapp_integration" {
  description = "Subnet ID for Load Balancer VNet integration"
  type        = string
  default     = null

}

variable "lb_sku" {
  description = "SKU for the load balancer (Standard or Basic)"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.lb_sku)
    error_message = "lb_sku must be either 'Basic' or 'Standard'."
  }
}

variable "lb_rule_name" {
  description = "Name for the load balancer rule"
  type        = string
  default     = "lb-rule-https"
}

variable "lb_rule_port" {
  description = "Load balancer rule port"
  type        = number
  default     = 443
}

variable "lb_rule_protocol" {
  description = "Load balancer rule protocol"
  type        = string
  default     = "Tcp"
}

variable "lb_rule_idle_timeout_in_minutes" {
  description = "Idle timeout in minutes for the load balancer rule"
  type        = number
  default     = 4
}

variable "lb_enable_floating_ip" {
  description = "Enable floating IP for the load balancer rule"
  type        = bool
  default     = false
}

variable "lb_enable_tcp_reset" {
  description = "Enable TCP reset for the load balancer rule"
  type        = bool
  default     = true
}

variable "probe_name" {
  description = "Name for the load balancer health probe"
  type        = string
  default     = "http-probe"
}

variable "probe_port" {
  description = "Health probe port"
  type        = number
  default     = 80
}

variable "probe_protocol" {
  description = "Health probe protocol (Http, Https, or Tcp)"
  type        = string
  default     = "Tcp"
}

variable "probe_path" {
  description = "Health probe path (required for Http and Https protocols)"
  type        = string
  default     = "/health"
}

variable "create_nat_rule" {
  description = "Whether to create a NAT rule"
  type        = bool
  default     = false
}

variable "use_nat_rule_v2" {
  description = "Use NAT Rules v2 (recommended)."
  type        = bool
  default     = true
}

variable "nat_rule_name" {
  description = "Name for the NAT rule"
  type        = string
  default     = "nat-rule-ssh"
}

variable "nat_rule_protocol" {
  description = "Protocol for the NAT rule (Tcp or Udp)"
  type        = string
  default     = "Tcp"
}

variable "nat_rule_frontend_port" {
  description = "Frontend port for the NAT rule (v1) or starting frontend port (v2)"
  type        = number
  default     = 22
}

variable "nat_rule_frontend_port_end" {
  description = "Ending frontend port for NAT rule v2"
  type        = number
  default     = null
}

variable "nat_rule_backend_port" {
  description = "Backend port for the NAT rule"
  type        = number
  default     = 22
}

variable "nat_rule_idle_timeout_in_minutes" {
  description = "Idle timeout in minutes for the NAT rule"
  type        = number
  default     = 4
}

variable "nat_rule_enable_floating_ip" {
  description = "Enable floating IP for the NAT rule"
  type        = bool
  default     = false
}

variable "nat_rule_enable_tcp_reset" {
  description = "Enable TCP reset for the NAT rule"
  type        = bool
  default     = true
}

variable "create_nat_pool" {
  description = "Whether to create a NAT pool"
  type        = bool
  default     = false
}

variable "lb_enable_diagnostics" {
  description = "Enable diagnostic settings for the load balancer"
  type        = bool
  default     = false
}

variable "lb_log_analytics_name" {
  description = "Log Analytics Workspace name for load balancer diagnostics"
  type        = string
  default     = null
}

variable "lb_log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for load balancer diagnostics (full resource ID)"
  type        = string
  default     = null
}

variable "lb_log_analytics_resource_group_name" {
  description = "Resource group name where Log Analytics Workspace is located (if different from rg_name)."
  type        = string
  default     = null
}

variable "lb_diagnostics_storage_account_id" {
  description = "Storage account ID for load balancer diagnostics (alternative to Log Analytics)"
  type        = string
  default     = null
}

# Backend pool addresses - for adding IP addresses directly to backend pool
variable "backend_pool_addresses" {
  description = "List of IP addresses to add directly to the backend pool (for VMs outside Terraform or standalone IPs). Each entry requires: name, ip_address, and virtual_network_id"
  type = list(object({
    name               = string
    ip_address         = string
    virtual_network_id = string
  }))
  default = []
}

variable "backend_pool_addresses_apim" {
  description = "List of IP addresses to add directly to the backend pool (for VMs outside Terraform or standalone IPs). Each entry requires: name, ip_address, and virtual_network_id"
  type = list(object({
    name               = string
    ip_address         = string
    virtual_network_id = string
  }))
  default = []
}



###Added for VMMS############
#########################
# Virtual Machine Scale Sets
#########################

# Windows VMSS (Rpt) Variables
variable "enable_vmss_rpt" {
  description = "Enable Windows VMSS for Rpt"
  type        = bool
  default     = false
}

variable "vmss_rpt_vm_size" {
  description = "VM size for Rpt Windows VMSS"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "vmss_rpt_instance_count" {
  description = "Initial instance count for Rpt VMSS"
  type        = number
  default     = 1
}

variable "vmss_rpt_min_instance_count" {
  description = "Minimum instance count for Rpt VMSS"
  type        = number
  default     = 1
}

variable "vmss_rpt_max_instance_count" {
  description = "Maximum instance count for Rpt VMSS"
  type        = number
  default     = 3
}

variable "vmss_rpt_admin_username" {
  description = "Admin username for Rpt VMSS"
  type        = string
  default     = "azureadmin"
}

variable "vmss_rpt_admin_password" {
  description = "Admin password for Rpt VMSS"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vmss_rpt_subnet_id" {
  description = "Subnet ID for Rpt VMSS"
  type        = string
  default     = null
}

variable "vmss_rpt_image_publisher" {
  description = "Image publisher for Rpt VMSS"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "vmss_rpt_image_offer" {
  description = "Image offer for Rpt VMSS"
  type        = string
  default     = "WindowsServer"
}

variable "vmss_rpt_image_sku" {
  description = "Image SKU for Rpt VMSS"
  type        = string
  default     = "2022-datacenter-azure-edition"
}

variable "vmss_rpt_image_version" {
  description = "Image version for Rpt VMSS"
  type        = string
  default     = "latest"
}

variable "vmss_rpt_os_disk_size_gb" {
  description = "OS disk size for Rpt VMSS"
  type        = number
  default     = 128
}

variable "vmss_rpt_os_disk_caching" {
  description = "OS disk caching for Rpt VMSS"
  type        = string
  default     = "ReadWrite"
}

variable "vmss_rpt_os_disk_storage_account_type" {
  description = "OS disk storage account type for Rpt VMSS"
  type        = string
  default     = "Premium_LRS"
}

variable "enable_vmss_rpt_autoscale" {
  description = "Enable auto-scaling for Rpt VMSS"
  type        = bool
  default     = false
}

# DNS Configuration for Rpt VMSS
variable "vmss_rpt_private_dns_zone_id" {
  description = "Private DNS zone ID where VMSS Rpt DNS A record should be created (optional)"
  type        = string
  default     = null
}

variable "vmss_rpt_dns_record_name" {
  description = "DNS record name for the Rpt VMSS in the private DNS zone (optional, defaults to vmss-Rpt-AZ if private_dns_zone_id is provided)"
  type        = string
  default     = null
}

variable "vmss_rpt_dns_record_ttl" {
  description = "TTL (Time To Live) for the DNS A record in seconds"
  type        = number
  default     = 300
}

# Linux VMSS (Drools) Variables
variable "enable_vmss_drools" {
  description = "Enable VMSS for Drools"
  type        = bool
  default     = false
}

variable "vmss_drools_vm_size" {
  description = "VM size for Drools VMSS"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "vmss_drools_instance_count" {
  description = "Initial instance count for Drools VMSS"
  type        = number
  default     = 1
}

variable "vmss_drools_min_instance_count" {
  description = "Minimum instance count for Drools VMSS"
  type        = number
  default     = 1
}

variable "vmss_drools_max_instance_count" {
  description = "Maximum instance count for Drools VMSS"
  type        = number
  default     = 5
}

variable "vmss_drools_admin_username" {
  description = "Admin username for Drools VMSS"
  type        = string
  default     = "azureuser"
}

variable "vmss_drools_ssh_public_key" {
  description = "SSH public key for Drools VMSS"
  type        = string
  default     = ""
}

variable "vmss_drools_subnet_id" {
  description = "Subnet ID for Drools VMSS"
  type        = string
  default     = null
}

variable "vmss_drools_image_publisher" {
  description = "Image publisher for Drools VMSS"
  type        = string
  default     = "RedHat"
}

variable "vmss_drools_image_offer" {
  description = "Image offer for Drools VMSS"
  type        = string
  default     = "RHEL"
}

variable "vmss_drools_image_sku" {
  description = "Image SKU for Drools VMSS"
  type        = string
  default     = "9_4"
}

variable "vmss_drools_image_version" {
  description = "Image version for Drools VMSS"
  type        = string
  default     = "latest"
}

variable "vmss_drools_os_disk_size_gb" {
  description = "OS disk size for Drools VMSS"
  type        = number
  default     = 128
}

variable "vmss_drools_os_disk_caching" {
  description = "OS disk caching for Drools VMSS"
  type        = string
  default     = "ReadWrite"
}

variable "vmss_drools_os_disk_storage_account_type" {
  description = "OS disk storage account type for Drools VMSS"
  type        = string
  default     = "Premium_LRS"
}

variable "enable_vmss_drools_autoscale" {
  description = "Enable auto-scaling for Drools VMSS"
  type        = bool
  default     = false
}
# Added after errors
variable "vmss_rpt_name" {
  description = "Name for Rpt VMSS"
  type        = string
  default     = "vmss-Rpt-AZ"
}
variable "vmss_rpt_computer_name_prefix" {
  description = "Computer name prefix for Rpt VMSS"
  type        = string
  default     = "vmssrpt"
}
variable "vmss_rpt_license_type" {
  description = "License type for Windows VMSS"
  type        = string
  default     = "Windows_Server"
}
variable "vmss_rpt_timezone" {
  description = "Timezone for Windows VMSS"
  type        = string
  default     = "UTC"
}
variable "vmss_rpt_accelerated_networking" {
  description = "Enable accelerated networking for Rpt VMSS"
  type        = bool
  default     = false
}
variable "vmss_rpt_nic_name" {
  description = "NIC name for Rpt VMSS"
  type        = string
  default     = "vmss-rpt-nic"
}
variable "vmss_rpt_os_disk_write_accelerator_enabled" {
  description = "Enable write accelerator for OS disk"
  type        = bool
  default     = false
}
variable "vmss_rpt_automatic_instance_repair" {
  description = "Enable automatic instance repair for Rpt VMSS"
  type        = bool
  default     = false
}
variable "vmss_rpt_identity_type" {
  description = "Identity type for VMSS"
  type        = string
  default     = "SystemAssigned"
}
variable "vmss_rpt_autoscale_cpu_threshold_out" {
  description = "CPU threshold for scale out"
  type        = number
  default     = 70
}
variable "vmss_rpt_autoscale_cpu_threshold_in" {
  description = "CPU threshold for scale in"
  type        = number
  default     = 30
}
variable "vmss_drools_name" {
  description = "Name for Drools VMSS"
  type        = string
  default     = "vmss-Drools-AZ"
}
variable "vmss_drools_computer_name_prefix" {
  description = "Computer name prefix for Drools VMSS"
  type        = string
  default     = "vmssdrools"
}
variable "vmss_drools_automatic_instance_repair" {
  description = "Enable automatic instance repair for Drools VMSS"
  type        = bool
  default     = false
}
variable "vmss_drools_autoscale_cpu_threshold_out" {
  description = "CPU threshold for scale out"
  type        = number
  default     = 70
}
variable "vmss_drools_autoscale_cpu_threshold_in" {
  description = "CPU threshold for scale in"
  type        = number
  default     = 30
}

# DNS Configuration for Drools VMSS
variable "vmss_drools_private_dns_zone_id" {
  description = "Private DNS zone ID where VMSS Drools DNS A record should be created (optional)"
  type        = string
  default     = null
}

variable "vmss_drools_dns_record_name" {
  description = "DNS record name for the Drools VMSS in the private DNS zone (optional, defaults to vmss-Drools-AZ if private_dns_zone_id is provided)"
  type        = string
  default     = null
}

variable "vmss_drools_dns_record_ttl" {
  description = "TTL (Time To Live) for the DNS A record in seconds"
  type        = number
  default     = 300
}
/*
# Linux VMSS (Pipeline) Variables
variable "enable_vmss_pipeline" {
  description = "Enable VMSS for Pipeline"
  type        = bool
  default     = false
}

variable "vmss_pipeline_vm_size" {
  description = "VM size for Pipeline VMSS"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "vmss_pipeline_instance_count" {
  description = "Initial instance count for Pipeline VMSS"
  type        = number
  default     = 1
}

variable "vmss_pipeline_min_instance_count" {
  description = "Minimum instance count for Pipeline VMSS"
  type        = number
  default     = 1
}

variable "vmss_pipeline_max_instance_count" {
  description = "Maximum instance count for Pipeline VMSS"
  type        = number
  default     = 5
}

variable "vmss_pipeline_admin_username" {
  description = "Admin username for Pipeline VMSS"
  type        = string
  default     = "azureuser"
}

variable "vmss_pipeline_ssh_public_key" {
  description = "SSH public key for Pipeline VMSS"
  type        = string
  default     = ""
}

variable "vmss_pipeline_subnet_id" {
  description = "Subnet ID for Pipeline VMSS"
  type        = string
  default     = null
}

variable "vmss_pipeline_image_publisher" {
  description = "Image publisher for Pipeline VMSS"
  type        = string
  default     = "RedHat"
}

variable "vmss_pipeline_image_offer" {
  description = "Image offer for Pipeline VMSS"
  type        = string
  default     = "RHEL"
}

variable "vmss_pipeline_image_sku" {
  description = "Image SKU for Pipeline VMSS"
  type        = string
  default     = "9_4"
}

variable "vmss_pipeline_image_version" {
  description = "Image version for Pipeline VMSS"
  type        = string
  default     = "latest"
}

variable "vmss_pipeline_os_disk_size_gb" {
  description = "OS disk size for Pipeline VMSS"
  type        = number
  default     = 128
}

variable "vmss_pipeline_os_disk_caching" {
  description = "OS disk caching for Pipeline VMSS"
  type        = string
  default     = "ReadWrite"
}

variable "vmss_pipeline_os_disk_storage_account_type" {
  description = "OS disk storage account type for Pipeline VMSS"
  type        = string
  default     = "Premium_LRS"
}

variable "enable_vmss_pipeline_autoscale" {
  description = "Enable auto-scaling for Pipeline VMSS"
  type        = bool
  default     = false
}
*/
##############################

#####old ones commented #######

/*variable "lb_name" {
  type    = string
  default = null
}

variable "lb_frontend_ip_configuration_name" {
  type    = string
  default = null
}

variable "lb_backend_pool_name" {
  type    = string
  default = null
}

variable "lb_is_public" {
  description = "Use a public load balancer if true, otherwise internal"
  type        = bool
  default     = false
}

variable "lb_private_ip_address" {
  type    = string
  default = null
}

*/

#########################

#########################
# API Management
#########################
variable "apim_name" {
  type    = string
  default = null
}

variable "apim_subnet_id" {
  description = "Subnet ID for API Management service"
  type        = string
  default     = null

}

variable "apim_publisher_email" {
  type    = string
  default = null
}

variable "apim_publisher_name" {
  type    = string
  default = null
}

variable "apim_sku_name" {
  type    = string
  default = "Premium" # Developer | Basic | Standard | Premium
}

#########################
# Front Door (Standard/Premium)
#########################
variable "frontdoor_name" {
  type    = string
  default = null
}

variable "frontdoor_sku_name" {
  type    = string
  default = "Premium_AzureFrontDoor"
}

variable "frontdoor_endpoint_name" {
  type    = string
  default = null
}

variable "frontdoor_origin_host_name" {
  description = "Origin host name (e.g. app service default hostname)"
  type        = string
  default     = null
}

variable "frontdoor_origin_host_header" {
  type    = string
  default = null
}

variable "frontdoor_origin_private_link_target" {
  description = "Resource ID for Front Door private link origin (if using private endpoints)"
  type        = string
  default     = null
}

variable "frontdoor_origin_private_link_location" {
  type    = string
  default = null
}

variable "frontdoor_origin_private_link_request_message" {
  type    = string
  default = "Requesting approval for Front Door private link"
}

#########################
# Validations for new features
#########################
variable "network_requirements_ok" {
  type    = bool
  default = true
  validation {
    condition = (!var.network_requirements_ok) || (
      (var.enable_private_endpoints == false) || (var.private_endpoint_subnet_id != null)
    )
    error_message = "private_endpoint_subnet_id must be provided when enable_private_endpoints = true."
  }
}

variable "private_dns_requirements_ok" {
  type    = bool
  default = true
  validation {
    condition = (!var.private_dns_requirements_ok) || (
      (var.build_private_dns_zone == false) || (var.private_dns_zone_name != null && length(var.private_dns_zone_name) > 0)
    )
    error_message = "private_dns_zone_name is required when build_private_dns_zone = true."
  }
}

variable "postgres_requirements_ok" {
  type    = bool
  default = true
  validation {
    condition = (!var.postgres_requirements_ok) || (
      (var.build_postgres == false) || (
        var.postgres_server_name != null &&
        var.postgres_administrator_login != null &&
        var.postgres_administrator_password != null
      )
    )
    error_message = "PostgreSQL server name, admin login, and password are required when build_postgres = true."
  }
}

variable "apim_requirements_ok" {
  type    = bool
  default = true
  validation {
    condition = (!var.apim_requirements_ok) || (
      (var.build_api_management == false) || (
        var.apim_name != null &&
        var.apim_publisher_email != null &&
        var.apim_publisher_name != null
      )
    )
    error_message = "API Management name, publisher email, and publisher name are required when build_api_management = true."
  }
}

variable "frontdoor_requirements_ok" {
  type    = bool
  default = true
  validation {
    condition = (!var.frontdoor_requirements_ok) || (
      (var.build_frontdoor == false) || (
        var.frontdoor_name != null &&
        var.frontdoor_endpoint_name != null &&
        var.frontdoor_origin_host_name != null
      )
    )
    error_message = "Front Door name, endpoint name, and origin host name are required when build_frontdoor = true."
  }
}
#########################Added by Supriya########################
/*
# Variables for using existing resources
variable "use_existing_vms" {
  description = "Use existing VMs instead of creating new ones"
  type        = bool
  default     = true
}
variable "existing_vm_names" {
  description = "Map of VM keys to existing VM names (used when use_existing_vms = true)"
  type        = map(string)
  default     = {}
}
*/

/*
############################
# Variables for VMSS
############################

# Windows VMSS (Rpt) Variables
variable "enable_vmss_rpt" {
  description = "Enable Windows VMSS for Rpt"
  type        = bool
  default     = false
}

variable "vmss_rpt_vm_size" {
  description = "VM size for Rpt Windows VMSS"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "vmss_rpt_instance_count" {
  description = "Initial instance count for Rpt VMSS"
  type        = number
  default     = 1
}

variable "vmss_rpt_min_instance_count" {
  description = "Minimum instance count for Rpt VMSS"
  type        = number
  default     = 1
}

variable "vmss_rpt_max_instance_count" {
  description = "Maximum instance count for Rpt VMSS"
  type        = number
  default     = 3
}

variable "vmss_rpt_admin_username" {
  description = "Admin username for Rpt VMSS"
  type        = string
  default     = "azureadmin"
}

variable "vmss_rpt_admin_password" {
  description = "Admin password for Rpt VMSS"
  type        = string
  sensitive   = true
  default     = ""
}

variable "vmss_rpt_subnet_id" {
  description = "Subnet ID for Rpt VMSS"
  type        = string
  default     = null
}

variable "vmss_rpt_image_publisher" {
  description = "Image publisher for Rpt VMSS"
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "vmss_rpt_image_offer" {
  description = "Image offer for Rpt VMSS"
  type        = string
  default     = "WindowsServer"
}

variable "vmss_rpt_image_sku" {
  description = "Image SKU for Rpt VMSS"
  type        = string
  default     = "2022-datacenter-azure-edition"
}

variable "vmss_rpt_image_version" {
  description = "Image version for Rpt VMSS"
  type        = string
  default     = "latest"
}

variable "vmss_rpt_os_disk_size_gb" {
  description = "OS disk size for Rpt VMSS"
  type        = number
  default     = 128
}

variable "vmss_rpt_os_disk_caching" {
  description = "OS disk caching for Rpt VMSS"
  type        = string
  default     = "ReadWrite"
}

variable "vmss_rpt_os_disk_storage_account_type" {
  description = "OS disk storage account type for Rpt VMSS"
  type        = string
  default     = "Premium_LRS"
}

variable "enable_vmss_rpt_autoscale" {
  description = "Enable auto-scaling for Rpt VMSS"
  type        = bool
  default     = false
}

# Linux VMSS (Drools) Variables - Same as before
variable "enable_vmss_drools" {
  description = "Enable VMSS for Drools"
  type        = bool
  default     = false
}

variable "vmss_drools_vm_size" {
  description = "VM size for Drools VMSS"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "vmss_drools_instance_count" {
  description = "Initial instance count for Drools VMSS"
  type        = number
  default     = 1
}

variable "vmss_drools_min_instance_count" {
  description = "Minimum instance count for Drools VMSS"
  type        = number
  default     = 1
}

variable "vmss_drools_max_instance_count" {
  description = "Maximum instance count for Drools VMSS"
  type        = number
  default     = 5
}

variable "vmss_drools_admin_username" {
  description = "Admin username for Drools VMSS"
  type        = string
  default     = "azureuser"
}

variable "vmss_drools_ssh_public_key" {
  description = "SSH public key for Drools VMSS"
  type        = string
  default     = ""
}

variable "vmss_drools_subnet_id" {
  description = "Subnet ID for Drools VMSS"
  type        = string
  default     = null
}

variable "vmss_drools_image_publisher" {
  description = "Image publisher for Drools VMSS"
  type        = string
  default     = "RedHat"
}

variable "vmss_drools_image_offer" {
  description = "Image offer for Drools VMSS"
  type        = string
  default     = "RHEL"
}

variable "vmss_drools_image_sku" {
  description = "Image SKU for Drools VMSS"
  type        = string
  default     = "9_4"
}

variable "vmss_drools_image_version" {
  description = "Image version for Drools VMSS"
  type        = string
  default     = "latest"
}

variable "vmss_drools_os_disk_size_gb" {
  description = "OS disk size for Drools VMSS"
  type        = number
  default     = 128
}

variable "vmss_drools_os_disk_caching" {
  description = "OS disk caching for Drools VMSS"
  type        = string
  default     = "ReadWrite"
}

variable "vmss_drools_os_disk_storage_account_type" {
  description = "OS disk storage account type for Drools VMSS"
  type        = string
  default     = "Premium_LRS"
}

variable "enable_vmss_drools_autoscale" {
  description = "Enable auto-scaling for Drools VMSS"
  type        = bool
  default     = false
}

# Linux VMSS (Pipeline) Variables - Same structure as Drools
variable "enable_vmss_pipeline" {
  description = "Enable VMSS for Pipeline"
  type        = bool
  default     = false
}

variable "vmss_pipeline_vm_size" {
  description = "VM size for Pipeline VMSS"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "vmss_pipeline_instance_count" {
  description = "Initial instance count for Pipeline VMSS"
  type        = number
  default     = 1
}

variable "vmss_pipeline_min_instance_count" {
  description = "Minimum instance count for Pipeline VMSS"
  type        = number
  default     = 1
}

variable "vmss_pipeline_max_instance_count" {
  description = "Maximum instance count for Pipeline VMSS"
  type        = number
  default     = 5
}

variable "vmss_pipeline_admin_username" {
  description = "Admin username for Pipeline VMSS"
  type        = string
  default     = "azureuser"
}

variable "vmss_pipeline_ssh_public_key" {
  description = "SSH public key for Pipeline VMSS"
  type        = string
  default     = ""
}

variable "vmss_pipeline_subnet_id" {
  description = "Subnet ID for Pipeline VMSS"
  type        = string
  default     = null
}

variable "vmss_pipeline_image_publisher" {
  description = "Image publisher for Pipeline VMSS"
  type        = string
  default     = "RedHat"
}

variable "vmss_pipeline_image_offer" {
  description = "Image offer for Pipeline VMSS"
  type        = string
  default     = "RHEL"
}

variable "vmss_pipeline_image_sku" {
  description = "Image SKU for Pipeline VMSS"
  type        = string
  default     = "9_4"
}

variable "vmss_pipeline_image_version" {
  description = "Image version for Pipeline VMSS"
  type        = string
  default     = "latest"
}

variable "vmss_pipeline_os_disk_size_gb" {
  description = "OS disk size for Pipeline VMSS"
  type        = number
  default     = 128
}

variable "vmss_pipeline_os_disk_caching" {
  description = "OS disk caching for Pipeline VMSS"
  type        = string
  default     = "ReadWrite"
}

variable "vmss_pipeline_os_disk_storage_account_type" {
  description = "OS disk storage account type for Pipeline VMSS"
  type        = string
  default     = "Premium_LRS"
}

variable "enable_vmss_pipeline_autoscale" {
  description = "Enable auto-scaling for Pipeline VMSS"
  type        = bool
  default     = false
}
*/
