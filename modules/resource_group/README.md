# Resource Group Module

Creates an Azure Resource Group.

> **Note on private endpoints / diagnostics:** A resource group is a management
> container, not a networked resource. It has no private endpoint and no
> per-resource diagnostic settings (resource-group activity is captured by the
> subscription Activity Log). This module therefore only manages the group and
> its tags.

## Usage

See [`examples/usage.tf`](./examples/usage.tf) for a copy-paste example.

```hcl
module "resource_group" {
  source   = "./modules/resource_group"
  name     = "rg-app-prod-eus"
  location = "eastus"
  tags     = { environment = "prod" }
}
```

## Inputs

| Name       | Description                     | Type          | Default | Required |
|------------|---------------------------------|---------------|---------|:--------:|
| `name`     | Name of the resource group.     | `string`      | n/a     | yes      |
| `location` | Azure region.                   | `string`      | n/a     | yes      |
| `tags`     | Tags to apply.                  | `map(string)` | `{}`    | no       |

## Outputs

| Name       | Description                          |
|------------|--------------------------------------|
| `name`     | The name of the resource group.      |
| `id`       | The resource ID of the group.        |
| `location` | The location of the group.           |

## Lifecycle

`tags` changes are ignored so the automatically-stamped `BuildDate` tag does not
produce a diff on every plan.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.14.0 |
| azurerm   | ~> 4.54  |

## Resources

| Type | Count |
|------|-------|
| `azurerm_resource_group` | 1 |

## Providers

`hashicorp/azurerm`
