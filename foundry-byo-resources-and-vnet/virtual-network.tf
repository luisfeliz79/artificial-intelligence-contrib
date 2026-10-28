# Create a virtual network for Foundry BYO Vnet
# REF: https://learn.microsoft.com/en-us/azure/foundry/agents/how-to/virtual-networks?tabs=portal&pivots=templates
resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = [local.vnet_address_prefix]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
}

# Create the foundry subnet delegated to Microsoft.app/environments
resource "azurerm_subnet" "foundry" {
  name                 = local.foundry_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.foundry_subnet_address_prefix]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

# Create the endpoints subnet
resource "azurerm_subnet" "endpoints" {
  name                 = local.endpoints_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.endpoints_subnet_address_prefix]
}   

# Create another subnet for future MCP tools
resource "azurerm_subnet" "mcp_tools" {
  name                 = local.tools_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [local.tools_subnet_address_prefix]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}