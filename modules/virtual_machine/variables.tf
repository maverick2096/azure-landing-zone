variable "vm_name" {
  description = "Name of the virtual machine."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}

variable "os_type" {
  description = "Operating system type: Windows or Linux."
  type        = string

  validation {
    condition     = contains(["Windows", "Linux"], var.os_type)
    error_message = "os_type must be either \"Windows\" or \"Linux\"."
  }
}

variable "vm_size" {
  description = "VM size (SKU)."
  type        = string
  default     = "Standard_D2s_v5"
}

# ---------- Authentication ----------
variable "admin_username" {
  description = "Administrator username."
  type        = string
}

variable "admin_password" {
  description = "Administrator password (required for Windows; for Linux only when no SSH key is supplied). Source from Key Vault / pipeline, not from version control."
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for Linux VMs. When set, password auth is disabled."
  type        = string
  default     = ""
}

# ---------- Networking (private only) ----------
variable "subnet_id" {
  description = "Subnet ID for the VM NIC."
  type        = string
}

variable "private_ip_allocation" {
  description = "Private IP allocation: Dynamic or Static."
  type        = string
  default     = "Dynamic"
}

variable "private_ip" {
  description = "Static private IP (used only when private_ip_allocation = Static)."
  type        = string
  default     = null
}

variable "nic_name" {
  description = "NIC name. Defaults to nic-<vm_name>."
  type        = string
  default     = null
}

variable "ip_configuration_name" {
  description = "NIC IP configuration name."
  type        = string
  default     = "ipconfig1"
}

# ---------- OS disk ----------
variable "os_disk_name" {
  description = "OS disk name (optional)."
  type        = string
  default     = null
}

variable "os_disk_caching" {
  description = "OS disk caching."
  type        = string
  default     = "ReadWrite"
}

variable "os_disk_storage_account_type" {
  description = "OS disk storage account type."
  type        = string
  default     = "Premium_LRS"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB."
  type        = number
  default     = 128
}

# ---------- Image ----------
variable "image_publisher" {
  description = "Marketplace image publisher."
  type        = string
}

variable "image_offer" {
  description = "Marketplace image offer."
  type        = string
}

variable "image_sku" {
  description = "Marketplace image SKU."
  type        = string
}

variable "image_version" {
  description = "Marketplace image version."
  type        = string
  default     = "latest"
}

# ---------- Placement / identity ----------
variable "computer_name" {
  description = "OS computer/host name. Defaults to the VM name (Windows truncated to 15 chars)."
  type        = string
  default     = ""
}

variable "availability_set_id" {
  description = "Availability set resource ID (optional)."
  type        = string
  default     = null
}

variable "zone" {
  description = "Availability zone (optional; mutually exclusive with availability sets)."
  type        = string
  default     = null
}

variable "patch_mode" {
  description = "Windows patch mode (e.g. AutomaticByPlatform). Ignored for Linux."
  type        = string
  default     = "AutomaticByPlatform"
}

variable "enable_system_assigned_identity" {
  description = "Enable a system-assigned managed identity on the VM."
  type        = bool
  default     = true
}

variable "user_assigned_identity_ids" {
  description = "User-assigned managed identity IDs to attach."
  type        = list(string)
  default     = []
}

# ---------- Boot diagnostics ----------
variable "enable_boot_diagnostics" {
  description = "Enable boot diagnostics."
  type        = bool
  default     = true
}

variable "boot_diagnostics_storage_account_uri" {
  description = "Boot diagnostics storage account blob URI. Null = managed storage."
  type        = string
  default     = null
}

# ---------- Monitoring ----------
variable "enable_monitoring" {
  description = "Install the Azure Monitor Agent extension."
  type        = bool
  default     = true
}

variable "automatic_extension_upgrade_enabled" {
  description = "Allow automatic minor-version upgrades of the monitor agent extension."
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID (telemetry target; wired through the Data Collection Rule)."
  type        = string
  default     = null
}

variable "data_collection_rule_id" {
  description = "Existing Data Collection Rule ID to associate with the VM (routes agent telemetry to Log Analytics). Null to skip the association."
  type        = string
  default     = null
}
