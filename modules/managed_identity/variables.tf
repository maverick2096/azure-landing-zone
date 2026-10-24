variable "name" {
  description = "The name of the user-assigned managed identity."
  type        = string
}

variable "location" {
  description = "The Azure region where the managed identity will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the managed identity will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the managed identity."
  type        = map(string)
  default     = {}
}
