# Managed Identity Module

Creates a **user-assigned managed identity**. This identity is the central
workload identity for the platform: it is attached to the web/function apps and
granted access to Key Vault, Storage, ACR and Service Bus by those modules
(pass `module.managed_identity.principal_id` into their `role_principal_ids` /
Key Vault access-policy inputs).

> **Note on private endpoints / diagnostics:** A managed identity is an Entra ID
> principal, not a networked resource - it has no private endpoint and no
> diagnostic settings.

## Usage

See [`examples/usage.tf`](./examples/usage.tf) for a copy-paste example.

```hcl
module "managed_identity" {
  source              = "./modules/managed_identity"
  name                = "id-app-prod-eus"
  location            = "eastus"
  resource_group_name = module.resource_group.name
}
```

## Inputs

| Name                  | Description                     | Type          | Default | Required |
|-----------------------|---------------------------------|---------------|---------|:--------:|
| `name`                | Name of the identity.           | `string`      | n/a     | yes      |
| `location`            | Azure region.                   | `string`      | n/a     | yes      |
| `resource_group_name` | Resource group name.            | `string`      | n/a     | yes      |
| `tags`                | Tags to apply.                  | `map(string)` | `{}`    | no       |

## Outputs

| Name           | Description                                              |
|----------------|----------------------------------------------------------|
| `id`           | Resource ID of the identity.                             |
| `principal_id` | Object ID - use for RBAC / Key Vault access policies.    |
| `client_id`    | Client ID - use in app settings.                         |
| `tenant_id`    | Tenant ID.                                                |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_user_assigned_identity` | 1 |

## Providers

`hashicorp/azurerm`
