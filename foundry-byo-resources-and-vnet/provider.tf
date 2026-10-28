terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=5.11.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">=2.13.0"
    }
  }
}

provider "azurerm" {
  subscription_id = local.subscription_id
  features {
    # Force RG deletion without confirmation
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


provider "azapi" {
  subscription_id = local.subscription_id
}
