variable "name" {
  type = string
}

variable "saname" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "private_endpoint_subnet_id" {
  type = string
}

variable "tenant_id" {
  type    = string
  default = null
}

variable "sku_name" {
  type = string
}

variable "link_name" {
  type = string
}

variable "virtual_network_id" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "private_dns_zone_sku_name" {
  type    = string
  default = "Standard"

}
