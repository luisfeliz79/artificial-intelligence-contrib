
# Create connections for the Foundry account.
# This Key Vault is used to store sensitive information
# securely
# Also, this should be the first connection created,
# hence the depends_on on the rest of the connections
resource "azurerm_cognitive_account_connection_account_managed_identity" "kv" {
  name                 = azurerm_key_vault.kv.name
  cognitive_account_id = azapi_resource.example.id
  category             = "AzureKeyVault"
  target               = azurerm_key_vault.kv.id

  metadata = {
    ApiType    = "Azure"
    ResourceId = azurerm_key_vault.kv.id
    Location   = azurerm_key_vault.kv.location
  }
}

# Create a Storage account, Azure AI Search and Cosmos DB resource
# For a Bring your own resources scenario.

resource "azurerm_cognitive_account_connection_entra_id" "storage" {
  name                 = azurerm_storage_account.sa.name
  cognitive_account_id = azapi_resource.example.id
  category             = "AzureStorageAccount"
  target               = azurerm_storage_account.sa.primary_blob_endpoint

  metadata = {
    ApiType    = "Azure"
    ResourceId = azurerm_storage_account.sa.id
    Location   = azurerm_storage_account.sa.location
  }

  depends_on = [ azurerm_cognitive_account_connection_account_managed_identity.kv ]
}

resource "azurerm_cognitive_account_connection_entra_id" "cosmos" {
  name                 = azurerm_cosmosdb_account.cosmos.name
  cognitive_account_id = azapi_resource.example.id
  category             = "CosmosDb"
  target               = azurerm_cosmosdb_account.cosmos.endpoint

  metadata = {
    ApiType    = "Azure"
    ResourceId = azurerm_cosmosdb_account.cosmos.id
    Location   = azurerm_cosmosdb_account.cosmos.location
  }

  depends_on = [ azurerm_cognitive_account_connection_account_managed_identity.kv ]
}

resource "azurerm_cognitive_account_connection_entra_id" "search" {
  name                 = azurerm_search_service.search.name
  cognitive_account_id = azapi_resource.example.id
  category             = "CognitiveSearch"
  target               = azurerm_search_service.search.endpoint

  metadata = {
    ApiType    = "Azure"
    ResourceId = azurerm_search_service.search.id
    Location   = azurerm_search_service.search.location
  }

  depends_on = [ azurerm_cognitive_account_connection_account_managed_identity.kv ]
}

# Create an Application Insights connection.
# For Traces.
# Currently only possible to use API Key, however, support for Entra auth is coming
# and the required RBAC is being included in file rbac-foundry-managed-identity.tf

resource "azurerm_cognitive_account_connection_api_key" "appinsights" {
  name                 = azurerm_application_insights.app_insights.name
  cognitive_account_id = azapi_resource.example.id
  category             = "AppInsights"
  target               = azurerm_application_insights.app_insights.id
  api_key              = azurerm_application_insights.app_insights.connection_string

  metadata = {
    ApiType    = "Azure"
    ResourceId = azurerm_application_insights.app_insights.id
    Location   = azurerm_application_insights.app_insights.location
  }

  depends_on = [ azurerm_cognitive_account_connection_account_managed_identity.kv ]
}


