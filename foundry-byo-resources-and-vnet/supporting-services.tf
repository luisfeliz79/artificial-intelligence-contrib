# Create a Key vault with Public Network endpoint disabled
resource "azurerm_key_vault" "kv" {
  name                          = local.key_vault_name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false

  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = local.tags

}

# Create a Log Analytics workspace
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${local.foundry_name}-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

# Create an Application Insights instance
resource "azurerm_application_insights" "app_insights" {
  name                = local.app_insights_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.law.id
  tags                = local.tags
}

# Create an Azure Storage account for supporting services
resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"

  allow_nested_items_to_be_public = false

  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  https_traffic_only_enabled      = true
  public_network_access           = "Disabled"
  min_tls_version                 = "TLS1_2"

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = [local.deploy_egress_ip]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags

}

# Create an Azure AI Search service
resource "azurerm_search_service" "search" {
  name                = local.search_service_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "basic"

  hosting_mode                  = "Default"
  local_authentication_enabled  = false

  # Enabled but with restrictions
  public_network_access_enabled = true

  allowed_ips = [local.deploy_egress_ip]

  network_rule_bypass_option = "AzureServices"
  

  identity {
    type = "SystemAssigned"
  }


  tags = local.tags
}

# Create a cosmos DB account
resource "azurerm_cosmosdb_account" "cosmos" {
  name                = local.cosmos_db_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  public_network_access_enabled = false
  local_authentication_enabled  = false

  identity {
    type = "SystemAssigned"
  }


  tags = local.tags
}
