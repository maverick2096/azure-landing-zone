variable "name" {
  description = "The name of the public IP address."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group where the public IP will be created."
  type        = string

}

variable "location" {
  description = "The location/region where the public IP will be created."
  type        = string
}

variable "sku" {
  description = "The SKU of the public IP address (e.g., Basic or Standard)."
  type        = string
  default     = "Basic"
}

variable "allocation_method" {
  description = "The allocation method for the public IP (Static or Dynamic)."
  type        = string
  default     = "Static"
}

variable "tags" {
  description = "A map of tags to assign to the public IP."
  type        = map(string)
  default     = {}
}