terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-stg-az"
    storage_account_name = "satfstatestgaz"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    environment          = "public"
  }
}
