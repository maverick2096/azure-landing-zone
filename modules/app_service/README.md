# App Service (Linux Web App) Module

Creates a **private-only** Linux Web App on its **own dedicated App Service
Plan**, with regional VNet integration, a private endpoint, diagnostics, and the
workload managed identity attached.

## Features

- Creates a dedicated `azurerm_service_plan` (Linux) - per project design each
  app owns its plan.
- Web app: `https_only = true`, `public_network_access_enabled = false`,
  TLS floor, `always_on`, `ftps_state = Disabled`, `vnet_route_all_enabled`,
  health check.
- Regional **VNet integration** via `vnet_integration_subnet_id` (outbound).
- **Private endpoint on the `sites` sub-resource** (inbound), registered in the
  **existing** private DNS zone(s) via `private_dns_zone_ids`.
- Optional **container image** from ACR (`container_registry_url` +
  `container_image_name` + `container_image_tag`).
- **Managed identity**: SystemAssigned, plus any `user_assigned_identity_ids`
  (attach the platform identity so the app can reach KV/Storage/ACR/SB).
- **Diagnostic settings** (all logs + metrics) on the web app.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name                         | Description                                           | Type           | Default   |
|------------------------------|-------------------------------------------------------|----------------|-----------|
| `app_name`                   | Web app name.                                         | `string`       | n/a       |
| `plan_name`                  | Name of the dedicated plan this app creates.          | `string`       | n/a       |
| `plan_sku_name`              | Plan SKU.                                             | `string`       | `P1v3`    |
| `container_registry_url`     | ACR URL (optional).                                   | `string`       | `null`    |
| `container_image_name`       | Image repo (optional).                                | `string`       | `null`    |
| `private_endpoint_subnet_id` | Subnet for the private endpoint.                      | `string`       | n/a       |
| `private_dns_zone_ids`       | Existing `privatelink.azurewebsites.net` zone ID.     | `list(string)` | n/a       |
| `vnet_integration_subnet_id` | Delegated subnet for VNet integration.                | `string`       | `null`    |
| `log_analytics_workspace_id` | Workspace ID for diagnostics.                         | `string`       | n/a       |
| `user_assigned_identity_ids` | Managed identity IDs to attach.                       | `list(string)` | `[]`      |
| `app_settings`               | App settings.                                         | `map(string)`  | `{}`      |

## Outputs

| Name                    | Description                               |
|-------------------------|-------------------------------------------|
| `id`                    | Web app resource ID.                      |
| `name`                  | Web app name.                             |
| `default_hostname`      | Default hostname.                         |
| `service_plan_id`       | Dedicated plan ID.                        |
| `identity_principal_id` | System-assigned identity principal ID.    |
| `private_endpoint_id`   | App PE resource ID.                       |

## Lifecycle

Ignores `tags`, `app_settings`, `site_config`, `sticky_settings`,
`connection_string`, and `virtual_network_subnet_id` so runtime/portal changes
and the `BuildDate` tag do not churn the plan.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_linux_web_app` | 1 |
| `azurerm_monitor_diagnostic_setting` | 1 |
| `azurerm_private_endpoint` | 1 |
| `azurerm_service_plan` | 1 |

## Providers

`hashicorp/azurerm`
