# Service Bus Module

Creates a **private-only** Service Bus (Premium) namespace with topics/queues, a
private endpoint, diagnostics, and data-plane RBAC for the workload managed
identity.

## Features

- `sku = "Premium"` (enforced - required for private endpoints),
  `public_network_access_enabled = false`, `local_auth_enabled = false`
  (Entra ID auth only - no SAS keys).
- Topics and queues from `topics` / `queues` (partitioning enabled).
- **Private endpoint on the `namespace` sub-resource**, registered in the
  **existing** private DNS zone(s) via `private_dns_zone_ids`.
- **Diagnostic settings** (operational logs + metrics) on the namespace.
- **RBAC**: grants `role_definition_name` (default `Azure Service Bus Data Owner`)
  to each principal in `role_principal_ids`.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name                           | Description                                               | Type           | Default                        |
|--------------------------------|-----------------------------------------------------------|----------------|--------------------------------|
| `name`                         | Namespace name.                                           | `string`       | n/a                            |
| `sku`                          | Must be `Premium`.                                        | `string`       | `Premium`                      |
| `capacity`                     | Messaging units.                                          | `number`       | `1`                            |
| `premium_messaging_partitions` | Messaging partitions.                                     | `number`       | `1`                            |
| `topics` / `queues`            | Entities to create.                                       | `list(string)` | `[]`                           |
| `private_endpoint_subnet_id`   | Subnet for the private endpoint.                          | `string`       | n/a                            |
| `private_dns_zone_ids`         | Existing `privatelink.servicebus.windows.net` zone ID.    | `list(string)` | n/a                            |
| `log_analytics_workspace_id`   | Workspace ID for diagnostics.                             | `string`       | n/a                            |
| `role_principal_ids`           | Principals granted the data role.                         | `list(string)` | `[]`                           |
| `role_definition_name`         | Role to grant.                                            | `string`       | `Azure Service Bus Data Owner` |

## Outputs

| Name                  | Description                          |
|-----------------------|--------------------------------------|
| `namespace_id`        | Namespace resource ID.               |
| `namespace_name`      | Namespace name.                      |
| `endpoint`            | Namespace endpoint URL.              |
| `private_endpoint_id` | Namespace PE resource ID.            |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_monitor_diagnostic_setting` | 1 |
| `azurerm_private_endpoint` | 1 |
| `azurerm_role_assignment` | 1 |
| `azurerm_servicebus_namespace` | 1 |
| `azurerm_servicebus_queue` | 1 |
| `azurerm_servicebus_topic` | 1 |

## Providers

`hashicorp/azurerm`
