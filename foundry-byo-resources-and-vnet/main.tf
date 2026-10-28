
#  Get current context
data "azurerm_client_config" "current" {}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
  tags = local.tags
}

# Random
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}