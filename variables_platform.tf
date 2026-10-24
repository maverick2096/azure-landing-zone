#############################################################################
# Platform inputs for the standardized modules
# (managed identity, existing private DNS zone IDs, function app).
#
# Per the module design, private endpoints register in EXISTING private DNS
# zones. Supply the resource IDs of those zones below. Diagnostics flow to the
# Log Analytics workspace created by the log_analytics module.
#############################################################################

#########################
# Managed Identity
#########################
variable "managed_identity_name" {
  description = "Name of the platform user-assigned managed identity."
  type        = string
}

#########################
# Application Insights
#########################
variable "app_insights_name" {
  description = "Name of the Application Insights component."
  type        = string
  default     = ""
}

#########################
# Networking (created here by the virtual_network + private_dns_zones modules)
#########################
variable "vnet_name" {
  description = "Base name of the virtual network (DR gets the dr suffix)."
  type        = string
  default     = "vnet-app-platform"
}

variable "vnet_address_space" {
  description = "Address space for the primary VNet."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "dr_vnet_address_space" {
  description = "Address space for the DR VNet (must not overlap the primary - the two are peered)."
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "subnet_newbits" {
  description = "Extra CIDR bits used to carve subnets from the VNet address space (8 turns a /16 into /24 subnets)."
  type        = number
  default     = 8
}

#########################
# Document Intelligence (Cognitive Services)
#########################
variable "build_document_intelligence" {
  description = "Whether to create the Document Intelligence account."
  type        = bool
  default     = true
}

variable "document_intelligence_name" {
  description = "Name of the Document Intelligence (Cognitive Services) account."
  type        = string
  default     = ""
}

variable "document_intelligence_sku" {
  description = "SKU for the Document Intelligence account (S0 supports private endpoints)."
  type        = string
  default     = "S0"
}

#########################
# Function App
#########################
variable "build_function_app" {
  description = "Whether to create the Function App."
  type        = bool
  default     = true
}

variable "function_app_name" {
  description = "Name of the Linux Function App."
  type        = string
  default     = ""
}

variable "function_app_plan_name" {
  description = "Name of the dedicated plan created for the Function App."
  type        = string
  default     = ""
}

variable "function_app_plan_sku" {
  description = "SKU for the Function App dedicated plan."
  type        = string
  default     = "P1v3"
}

variable "function_app_node_version" {
  description = "Node.js version for the Function App (set one runtime; leave others null)."
  type        = string
  default     = null
}

variable "function_app_python_version" {
  description = "Python version for the Function App."
  type        = string
  default     = null
}

variable "function_app_dotnet_version" {
  description = ".NET version for the Function App."
  type        = string
  default     = null
}

#########################
# Disaster Recovery (second region)
#########################
variable "enable_dr" {
  description = "Deploy a full standby copy of the platform in the DR region. When true, every in-scope module is also created in dr_location with the DR suffix."
  type        = bool
  default     = false
}

variable "dr_location" {
  description = "Azure region for the DR (standby) deployment. Required when enable_dr = true."
  type        = string
  default     = ""
}

variable "dr_resource_suffix" {
  description = "Suffix appended to every DR resource name (and the DR resource group)."
  type        = string
  default     = "-dr"
}

locals {
  enable_managed_identity      = true
  enable_app_insights          = var.build_log_analytics
  enable_function_app          = var.build_function_app
  enable_document_intelligence = var.build_document_intelligence

  # Deployment regions. "primary" always; "dr" added (same inputs, only the
  # region changes) when enable_dr = true. Each in-scope module in main.tf loops
  # over this map: location = each.value.location, and names get each.value.suffix.
  regions = merge(
    { primary = { location = var.location, suffix = "", address_space = var.vnet_address_space } },
    var.enable_dr ? { dr = { location = var.dr_location, suffix = var.dr_resource_suffix, address_space = var.dr_vnet_address_space } } : {}
  )

  # Subnet layout, carved from each region's address space via cidrsubnet(index).
  subnet_defs = {
    private_endpoint = { index = 0, delegation = null }
    apps             = { index = 1, delegation = "Microsoft.Web/serverFarms" }
    vm               = { index = 2, delegation = null }
  }

  # Service private DNS zones - created once, linked to all region VNets.
  # (The Azure Monitor zones are owned by the log_analytics module.)
  service_private_dns_zones = [
    "privatelink.vaultcore.azure.net",
    "privatelink.blob.core.windows.net",
    "privatelink.azurecr.io",
    "privatelink.servicebus.windows.net",
    "privatelink.azurewebsites.net",
    "privatelink.cognitiveservices.azure.com",
  ]
}
