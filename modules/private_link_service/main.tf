data "azurerm_lb" "name" {
  name                = var.load_balancer_name
  resource_group_name = var.resource_group_name
}
resource "azurerm_private_link_service" "this" {
  name                                        = var.name
  location                                    = var.location
  resource_group_name                         = var.resource_group_name
  load_balancer_frontend_ip_configuration_ids = data.azurerm_lb.name.frontend_ip_configuration[*].id
  auto_approval_subscription_ids              = var.auto_approval_subscription_ids
  visibility_subscription_ids                 = var.visibility_subscription_ids
  tags                                        = var.tags

  nat_ip_configuration {
    name                       = coalesce(var.nat_ip_configuration_name, "${var.name}-nic")
    subnet_id                  = var.nat_subnet_id
    primary                    = true
    private_ip_address_version = "IPv4"
  }
}