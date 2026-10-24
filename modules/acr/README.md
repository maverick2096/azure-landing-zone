# Azure Container Registry Module

Creates a **private-only** Azure Container Registry (Premium) with a private
endpoint, diagnostics, and `AcrPull` RBAC for the workload managed identity.

## Features

- `sku = "Premium"` (enforced - required for private endpoints) with
  `public_network_access_enabled = false` and
  `network_rule_bypass_option = "AzureServices"`.
- Content trust + untagged-manifest retention configurable.
- System-assigned identity on the registry; optional geo-replications.
- **Private endpoint on the `registry` sub-resource**, registered in the
  **existing** private DNS zone(s) passed via `private_dns_zone_ids`.
- **Diagnostic settings** (all logs + metrics) on the registry.
- **RBAC**: grants `AcrPull` to each principal in `role_principal_ids`.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name                         | Description                                      | Type           | Default     |
|------------------------------|--------------------------------------------------|----------------|-------------|
| `name`                       | Registry name.                                   | `string`       | n/a         |
| `sku`                        | Must be `Premium`.                               | `string`       | `Premium`   |
| `admin_enabled`              | Enable admin user.                               | `bool`         | `false`     |
| `retention_policy_in_days`   | Untagged manifest retention.                     | `number`       | `90`        |
| `trust_policy_enabled`       | Content trust.                                   | `bool`         | `true`      |
| `georeplications`            | Geo-replication targets.                         | `list(object)` | `[]`        |
| `private_endpoint_subnet_id` | Subnet for the private endpoint.                 | `string`       | n/a         |
| `private_dns_zone_ids`       | Existing `privatelink.azurecr.io` zone ID.       | `list(string)` | n/a         |
| `log_analytics_workspace_id` | Workspace ID for diagnostics.                    | `string`       | n/a         |
| `role_principal_ids`         | Principals granted `AcrPull`.                    | `list(string)` | `[]`        |

## Outputs

| Name                    | Description                               |
|-------------------------|-------------------------------------------|
| `id`                    | Registry resource ID.                     |
| `name`                  | Registry name.                            |
| `login_server`          | Login server.                             |
| `identity_principal_id` | System-assigned identity principal ID.    |
| `private_endpoint_id`   | Registry PE resource ID.                  |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_container_registry` | 1 |
| `azurerm_monitor_diagnostic_setting` | 1 |
| `azurerm_private_endpoint` | 1 |
| `azurerm_role_assignment` | 1 |

## Providers

`hashicorp/azurerm`
