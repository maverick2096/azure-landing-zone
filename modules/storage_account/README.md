# Storage Account Module

Creates a **private-only** Storage Account with a **blob** private endpoint,
blob logging, and data-plane RBAC for the workload managed identity.

## Features

- `public_network_access_enabled = false`, `network_rules` default-deny,
  TLS 1.2 minimum, `allowed_copy_scope = "AAD"`,
  `default_to_oauth_authentication = true`.
- Private containers created from `containers`.
- **Private endpoint on the `blob` sub-resource only** (per design), registered
  in the **existing** private DNS zone(s) passed via `private_dns_zone_ids`.
- **Diagnostic settings**: account metrics, blob-service logs
  (read/write/delete) -> Log Analytics.
- **RBAC**: grants `Storage Blob Data Contributor` to each principal in
  `role_principal_ids` (the managed identity).

> Only the `blob` sub-resource gets a private endpoint. If you later need
> file/queue/table privately, add the corresponding sub-resources + zones.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name                         | Description                                           | Type           | Default      |
|------------------------------|-------------------------------------------------------|----------------|--------------|
| `name`                       | Storage account name.                                 | `string`       | n/a          |
| `account_tier`               | `Standard` / `Premium`.                               | `string`       | `Standard`   |
| `account_replication_type`   | `LRS` / `ZRS` / `GRS` ...                             | `string`       | `LRS`        |
| `shared_access_key_enabled`  | Allow access-key auth.                                | `bool`         | `true`       |
| `containers`                 | Containers to create.                                 | `list(string)` | `[]`         |
| `private_endpoint_subnet_id` | Subnet for the blob private endpoint.                 | `string`       | n/a          |
| `private_dns_zone_ids`       | Existing `privatelink.blob.core.windows.net` zone ID. | `list(string)` | n/a          |
| `log_analytics_workspace_id` | Workspace ID for diagnostics.                         | `string`       | n/a          |
| `role_principal_ids`         | Principals granted Blob Data Contributor.             | `list(string)` | `[]`         |

## Outputs

| Name                    | Description                               |
|-------------------------|-------------------------------------------|
| `storage_account_id`    | Resource ID.                              |
| `storage_account_name`  | Name.                                     |
| `primary_blob_endpoint` | Primary blob endpoint.                    |
| `primary_access_key`    | Primary key (sensitive).                  |
| `private_endpoint_id`   | Blob PE resource ID.                      |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_monitor_diagnostic_setting` | 2 |
| `azurerm_private_endpoint` | 1 |
| `azurerm_role_assignment` | 1 |
| `azurerm_storage_account` | 1 |
| `azurerm_storage_container` | 1 |

## Providers

`hashicorp/azurerm`
