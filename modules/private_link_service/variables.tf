variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "load_balancer_frontend_ip_configuration_ids" {
  type = list(string)
}

variable "nat_subnet_id" {
  type = string
}

variable "load_balancer_name" {
  type = string

}
variable "nat_ip_configuration_name" {
  type    = string
  default = null
}

variable "auto_approval_subscription_ids" {
  type    = list(string)
  default = []
}

variable "visibility_subscription_ids" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}