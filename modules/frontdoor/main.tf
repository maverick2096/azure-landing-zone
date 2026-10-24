resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = var.profile_name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = var.endpoint_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  enabled                  = true
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  name                     = coalesce(var.origin_group_name, "default-origin-group")
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    interval_in_seconds = 30
    path                = var.health_probe_path
    protocol            = var.health_probe_protocol
    request_type        = var.health_probe_request_type
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  name                           = coalesce(var.origin_name, "primary-origin")
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this.id
  host_name                      = var.origin_host_name
  origin_host_header             = coalesce(var.origin_host_header, var.origin_host_name)
  http_port                      = var.origin_http_port
  https_port                     = var.origin_https_port
  enabled                        = true
  weight                         = 1000
  priority                       = 1
  certificate_name_check_enabled = false

  dynamic "private_link" {
    for_each = var.origin_private_link_target_id == null ? [] : [1]
    content {
      private_link_target_id = var.origin_private_link_target_id
      location               = var.origin_private_link_location
      request_message        = var.origin_private_link_request_message
      target_type            = var.origin_private_link_target_type
    }
  }
}

resource "azurerm_cdn_frontdoor_route" "this" {
  name                          = coalesce(var.route_name, "default-route")
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.this.id]
  supported_protocols           = var.supported_protocols
  patterns_to_match             = var.patterns_to_match
  https_redirect_enabled        = var.https_redirect_enabled
  forwarding_protocol           = var.forwarding_protocol
  link_to_default_domain        = true
  enabled                       = true
}