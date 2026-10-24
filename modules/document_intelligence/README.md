# Document Intelligence Module

Creates an **Azure AI Document Intelligence** account (Cognitive Services,
`kind = "FormRecognizer"`) that is **private only** (no public endpoint), with a
private endpoint, diagnostics, and data-plane RBAC for the workload managed
identity.

## Features

- `kind = "FormRecognizer"` (Document Intelligence), SKU `S0` by default
  (required for private endpoints; `F0` free tier does not support them).
- `public_network_access_enabled = false` with a default-deny `network_acls`.
- A **custom subdomain** (required for private endpoints and Entra ID token
  auth) — defaults to the lowercased account name.
- `local_auth_enabled` toggles API-key auth (default `true`; set `false` for
  Entra ID-only).
- System-assigned identity on the account.
- **Private endpoint** on the `account` sub-resource, registered in the
  **existing** private DNS zone(s) via `private_dns_zone_ids`
  (`privatelink.cognitiveservices.azure.com`).
- **Diagnostic settings** (all logs + metrics) → Log Analytics.
- **RBAC**: grants `role_definition_name` (default `Cognitive Services User`) to
  each principal in `role_principal_ids`.

## Usage

See [`examples/usage.tf`](./examples/usage.tf).

## Key Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `name` | Account name. | `string` | n/a |
| `sku_name` | SKU (`S0` for private endpoints). | `string` | `S0` |
| `custom_subdomain_name` | Custom subdomain. | `string` | `""` (→ lowercased name) |
| `local_auth_enabled` | Allow API-key auth. | `bool` | `true` |
| `private_endpoint_subnet_id` | Subnet for the private endpoint. | `string` | n/a |
| `private_dns_zone_ids` | Existing `privatelink.cognitiveservices.azure.com` zone ID(s). | `list(string)` | n/a |
| `log_analytics_workspace_id` | Workspace ID for diagnostics. | `string` | n/a |
| `role_principal_ids` | Principals granted the data role. | `list(string)` | `[]` |
| `role_definition_name` | Role to grant. | `string` | `Cognitive Services User` |

## Outputs

| Name | Description |
|------|-------------|
| `id` | Account resource ID. |
| `name` | Account name. |
| `endpoint` | Document Intelligence endpoint URL. |
| `primary_access_key` | Primary API key (sensitive; only when `local_auth_enabled`). |
| `identity_principal_id` | System-assigned identity principal ID. |
| `private_endpoint_id` | Private endpoint resource ID. |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_cognitive_account` | 1 |
| `azurerm_private_endpoint` | 1 |
| `azurerm_monitor_diagnostic_setting` | 1 |
| `azurerm_role_assignment` | 0–N |

## Providers

`hashicorp/azurerm`
