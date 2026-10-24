# Key Vault Module

Creates an Azure Key Vault that is **private only** (no public endpoint),
secured with **classic access policies**, and wired for diagnostics.

## Features

- `public_network_access_enabled = false` and `network_acls` default-deny.
- **Access policies** (RBAC disabled). The workload managed identity is granted
  data-plane read (`Get`/`List`) on secrets/keys/certs via
  `access_policy_object_ids`; the Terraform deployer optionally gets full
  management so it can seed secrets (`grant_deployer_access`).
- **Private endpoint** on the `vault` sub-resource, registered in the
  **existing** private DNS zone(s) passed via `private_dns_zone_ids`.
- **Diagnostic settings** (all logs + metrics) on the vault, sent
  to the Log Analytics workspace.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name                         | Description                                              | Type           | Default      |
|------------------------------|----------------------------------------------------------|----------------|--------------|
| `name`                       | Key Vault name.                                          | `string`       | n/a          |
| `location` / `resource_group_name` | Placement.                                         | `string`       | n/a          |
| `sku_name`                   | `standard` or `premium`.                                 | `string`       | `standard`   |
| `purge_protection`           | Enable purge protection.                                 | `bool`         | `true`       |
| `soft_delete_retention_days` | Retention (7-90).                                        | `number`       | `90`         |
| `private_endpoint_subnet_id` | Subnet for the private endpoint.                         | `string`       | n/a          |
| `private_dns_zone_ids`       | Existing `privatelink.vaultcore.azure.net` zone ID(s).   | `list(string)` | n/a          |
| `log_analytics_workspace_id` | Workspace ID for diagnostics.                            | `string`       | n/a          |
| `access_policy_object_ids`   | Principals granted data-plane read (the managed identity).| `list(string)`| `[]`         |
| `grant_deployer_access`      | Give the deployer full management access.                | `bool`         | `true`       |

## Outputs

| Name                  | Description                          |
|-----------------------|--------------------------------------|
| `id`                  | Key Vault resource ID.               |
| `name`                | Key Vault name.                      |
| `vault_uri`           | Key Vault URI.                       |
| `private_endpoint_id` | Private endpoint resource ID.        |

## Lifecycle

`tags` and the PE `private_dns_zone_group` are ignored to avoid churn from the
`BuildDate` tag and Azure-managed DNS group updates.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_key_vault` | 1 |
| `azurerm_key_vault_access_policy` | 2 |
| `azurerm_monitor_diagnostic_setting` | 1 |
| `azurerm_private_endpoint` | 1 |

**Data sources:** `azurerm_client_config`

## Providers

`hashicorp/azurerm`
