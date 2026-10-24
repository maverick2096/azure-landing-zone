variable "profile_name" {
  type = string
}

variable "sku_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "endpoint_name" {
  type = string
}

variable "origin_host_name" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "origin_group_name" {
  type    = string
  default = null
}

variable "health_probe_path" {
  type    = string
  default = "/"
}

variable "health_probe_protocol" {
  type    = string
  default = "Https"
}

variable "health_probe_request_type" {
  type    = string
  default = "GET"
}

variable "origin_name" {
  type    = string
  default = null
}

variable "origin_host_header" {
  type    = string
  default = null
}

variable "origin_http_port" {
  type    = number
  default = 80
}

variable "origin_https_port" {
  type    = number
  default = 443
}

variable "origin_private_link_target_id" {
  type    = string
  default = null
}

variable "origin_private_link_location" {
  type    = string
  default = null
}

variable "origin_private_link_request_message" {
  type    = string
  default = "Requesting approval for Front Door private link"
}

variable "origin_private_link_target_type" {
  type    = string
  default = "AzureResource"
}

variable "route_name" {
  type    = string
  default = null
}

variable "supported_protocols" {
  type    = list(string)
  default = ["Http", "Https"]
}

variable "patterns_to_match" {
  type    = list(string)
  default = ["/*"]
}

variable "https_redirect_enabled" {
  type    = bool
  default = true
}

variable "forwarding_protocol" {
  type    = string
  default = "HttpsOnly"
}