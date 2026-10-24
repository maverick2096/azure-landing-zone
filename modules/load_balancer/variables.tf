# Load Balancer Basic Configuration
variable "name" {
  description = "Name of the load balancer"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Location for the load balancer"
  type        = string
}

variable "frontend_ip_configuration_name" {
  description = "Name for the load balancer frontend IP configuration"
  type        = string
  default     = "frontend-ip"
}

variable "backend_pool_name" {
  description = "Backend pool name"
  type        = string
  default     = "backend-pool"
}

variable "subnet_id" {
  description = "Subnet ID for load balancer frontend"
  type        = string
  default     = null
}

variable "private_ip_address" {
  description = "Private IP address for the load balancer frontend"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to resources"
  type        = map(string)
  default     = {}
}

variable "lb_sku" {
  description = "SKU for the load balancer"
  type        = string
  default     = "Standard"
}

variable "zones" {
  description = "Availability zones for the load balancer frontend IP"
  type        = list(string)
  default     = []
}

# Probe variables
variable "probe_name" {
  description = "Name for the load balancer health probe"
  type        = string
  default     = "http-probe"
}

variable "probe_protocol" {
  description = "Health probe protocol"
  type        = string
  default     = "Https"
}

variable "probe_port" {
  description = "Health probe port"
  type        = number
  default     = 443
}

variable "probe_path" {
  description = "Health probe path"
  type        = string
  default     = "/health"
}

variable "probe_interval_in_seconds" {
  description = "Interval in seconds between health probes"
  type        = number
  default     = 15
}

variable "probe_number_of_probes" {
  description = "Number of failed probes before marking backend as unhealthy"
  type        = number
  default     = 2
}

# Load Balancer Rule variables
variable "lb_rule_name" {
  description = "Name for the load balancer rule"
  type        = string
  default     = "lb-rule-https"
}

variable "lb_rule_protocol" {
  description = "Load balancer rule protocol"
  type        = string
  default     = "Tcp"
}

variable "lb_rule_port" {
  description = "Load balancer rule port"
  type        = number
  default     = 443
}

variable "lb_rule_idle_timeout_in_minutes" {
  description = "Idle timeout in minutes for the load balancer rule"
  type        = number
  default     = 4
}

variable "enable_floating_ip" {
  description = "Enable floating IP for the load balancer rule"
  type        = bool
  default     = false
}

variable "enable_tcp_reset" {
  description = "Enable TCP reset for the load balancer rule"
  type        = bool
  default     = true
}

# NAT Rule variables
variable "use_nat_rule_v2" {
  description = "Use NAT Rules v2"
  type        = bool
  default     = true
}

variable "nat_rule_name" {
  description = "Name for the NAT rule"
  type        = string
  default     = "nat-rule-ssh"
}

variable "nat_rule_protocol" {
  description = "Protocol for the NAT rule"
  type        = string
  default     = "Tcp"
}

variable "nat_rule_frontend_port" {
  description = "Frontend port for the NAT rule"
  type        = number
  default     = 22
}

variable "nat_rule_frontend_port_end" {
  description = "Ending frontend port for NAT rule v2"
  type        = number
  default     = 30
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

# NAT Pool variables
variable "nat_pool_name" {
  description = "Name for the NAT pool"
  type        = string
  default     = ""
}

variable "nat_pool_protocol" {
  description = "Protocol for the NAT pool"
  type        = string
  default     = "Tcp"
}

variable "nat_pool_frontend_port_start" {
  description = "Starting frontend port for the NAT pool"
  type        = number
  default     = 50000
}

variable "nat_pool_frontend_port_end" {
  description = "Ending frontend port for the NAT pool"
  type        = number
  default     = 50119
}

variable "nat_pool_backend_port" {
  description = "Backend port for the NAT pool"
  type        = number
  default     = 22
}

# Diagnostic settings
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the load balancer"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostic settings"
  type        = string
  default     = null
}

variable "diagnostics_storage_account_id" {
  description = "Storage account ID for diagnostic settings"
  type        = string
  default     = null
}

variable "eventhub_authorization_rule_id" {
  description = "Event Hub authorization rule ID for diagnostic settings"
  type        = string
  default     = null
}

variable "eventhub_name" {
  description = "Event Hub name for diagnostic settings"
  type        = string
  default     = null
}

# Lifecycle settings
variable "prevent_destroy" {
  description = "Prevent destruction of the load balancer"
  type        = bool
  default     = false
}

variable "ignore_tags_changes" {
  description = "Ignore changes to tags"
  type        = bool
  default     = false
}

variable "lifecycle_create_before_destroy" {
  description = "Create new resource before destroying old one"
  type        = bool
  default     = true
}

# Backend pool configuration
variable "backend_pool_network_interface_ids" {
  description = "List of network interface IDs to associate with the backend address pool"
  type        = list(string)
  default     = []
}

variable "backend_pool_ip_configuration_name" {
  description = "IP configuration name for the network interface backend pool association"
  type        = string
  default     = "ipconfig1"
}

variable "backend_pool_addresses" {
  description = "List of IP addresses to add directly to the backend pool"
  type = list(object({
    name               = string
    ip_address         = string
    virtual_network_id = string
  }))
  default = []
}

# VMSS Common Variables
variable "boot_diagnostics_storage_account_uri" {
  description = "Storage account URI for boot diagnostics"
  type        = string
  default     = null
}

# Windows VMSS (Rpt) Variables
variable "enable_vmss_rpt" {
  description = "Enable Windows VMSS for Rpt"
  type        = bool
  default     = false
}

variable "vmss_rpt_name" {
  description = "Name for Rpt VMSS"
  type        = string
  default     = "vmss-Rpt-AZ"
}

variable "vmss_rpt_computer_name_prefix" {
  description = "Computer name prefix for Rpt VMSS"
  type        = string
  default     = "vmss-rpt-az"
}

variable "vmss_rpt_nic_name" {
  description = "NIC name for Rpt VMSS"
  type        = string
  default     = "vmss-Rpt-AZ-nic"
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

variable "vmss_rpt_os_disk_write_accelerator_enabled" {
  description = "Enable write accelerator for OS disk"
  type        = bool
  default     = false
}

variable "vmss_rpt_accelerated_networking" {
  description = "Enable accelerated networking for Rpt VMSS"
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

variable "enable_vmss_rpt_autoscale" {
  description = "Enable auto-scaling for Rpt VMSS"
  type        = bool
  default     = false
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

variable "vmss_rpt_private_dns_zone_id" {
  description = "Private DNS zone ID where VMSS Rpt DNS A record should be created"
  type        = string
  default     = null
}

variable "vmss_rpt_dns_record_name" {
  description = "DNS record name for the Rpt VMSS"
  type        = string
  default     = "vmss-Rpt-AZ"
}

variable "vmss_rpt_dns_record_ttl" {
  description = "TTL for DNS A record"
  type        = number
  default     = 300
}

# Linux VMSS (Drools) Variables
variable "enable_vmss_drools" {
  description = "Enable VMSS for Drools"
  type        = bool
  default     = false
}

variable "vmss_drools_name" {
  description = "Name for Drools VMSS"
  type        = string
  default     = "vmss-Drools-AZ"
}

variable "vmss_drools_computer_name_prefix" {
  description = "Computer name prefix for Drools VMSS"
  type        = string
  default     = "vmss-drools-az"
}

variable "vmss_drools_nic_name" {
  description = "NIC name for Drools VMSS"
  type        = string
  default     = "vmss-Drools-AZ-nic"
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

variable "vmss_drools_automatic_instance_repair" {
  description = "Enable automatic instance repair for Drools VMSS"
  type        = bool
  default     = false
}

variable "enable_vmss_drools_autoscale" {
  description = "Enable auto-scaling for Drools VMSS"
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

variable "vmss_drools_private_dns_zone_id" {
  description = "Private DNS zone ID where VMSS Drools DNS A record should be created"
  type        = string
  default     = null
}

variable "vmss_drools_dns_record_name" {
  description = "DNS record name for the Drools VMSS"
  type        = string
  default     = "vmss-Drools-AZ"
}

variable "vmss_drools_dns_record_ttl" {
  description = "TTL for DNS A record"
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

variable "vmss_pipeline_name" {
  description = "Name for Pipeline VMSS"
  type        = string
  default     = "vmss-Pipeline-AZ"
}

variable "vmss_pipeline_computer_name_prefix" {
  description = "Computer name prefix for Pipeline VMSS"
  type        = string
  default     = "vmsspipeline"
}

variable "vmss_pipeline_nic_name" {
  description = "NIC name for Pipeline VMSS"
  type        = string
  default     = "vmss-pipeline-nic"
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

variable "vmss_pipeline_automatic_instance_repair" {
  description = "Enable automatic instance repair for Pipeline VMSS"
  type        = bool
  default     = false
}

variable "enable_vmss_pipeline_autoscale" {
  description = "Enable auto-scaling for Pipeline VMSS"
  type        = bool
  default     = false
}

variable "vmss_pipeline_autoscale_cpu_threshold_out" {
  description = "CPU threshold for scale out"
  type        = number
  default     = 70
}

variable "vmss_pipeline_autoscale_cpu_threshold_in" {
  description = "CPU threshold for scale in"
  type        = number
  default     = 30
}

variable "vmss_pipeline_private_dns_zone_id" {
  description = "Private DNS zone ID where VMSS Pipeline DNS A record should be created"
  type        = string
  default     = null
}

variable "vmss_pipeline_dns_record_name" {
  description = "DNS record name for the Pipeline VMSS"
  type        = string
  default     = "vmss-Pipeline-AZ"
}

variable "vmss_pipeline_dns_record_ttl" {
  description = "TTL for DNS A record"
  type        = number
  default     = 300
}*/