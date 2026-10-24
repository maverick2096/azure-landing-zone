variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "administrator_login" {
  type = string
}

variable "administrator_login_password" {
  type      = string
  sensitive = true
}

variable "sku_name" {
  type = string
}

variable "server_version" {
  type = string
}

variable "storage_mb" {
  type = number
}

variable "backup_retention_days" {
  type    = number
  default = 35
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "log_analytics_name" {
  type    = string
  default = ""

}
variable "pg_lower_name" {
  type        = string
  default     = null
  description = "Lowercase name for PostgreSQL and DNS records"

}
variable "postgres_backup_vault" {
  type        = string
  default     = "null"
  description = "Name for PostgreSQL Backup Vault"
}

variable "virtual_network_id" {
  type = string
}