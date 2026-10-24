variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}
variable "webapp_name" {
  description = "Name of the web app"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}
/*
variable "apim_name" {
  description = "Name of the API Management service"
  type        = string
}
*/
variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "postgresql_server_name" {
  description = "Name of the PostgreSQL Flexible Server"
  type        = string
}

variable "servicebus_namespace_name" {
  description = "Name of the Service Bus namespace"
  type        = string
}

variable "api_name" {
  description = "Name of the API Linux Web App"
  type        = string
}

variable "n8n_name" {
  description = "Name of the n8n Linux Web App"
  type        = string
}
/*
variable "windows_vm_names" {
  description = "List of Windows VM names for which to assign ACRPull role"
  type        = list(string)
  default     = []
}

variable "linux_vm_names" {
  description = "List of Linux VM names for which to assign ACRPull role"
  type        = list(string)
  default     = []
}*/