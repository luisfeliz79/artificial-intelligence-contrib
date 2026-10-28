# Create a user assigned managed identity for Foundry
resource "azurerm_user_assigned_identity" "foundry_identity" {
  name                = "${local.foundry_name}-identity"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = local.tags
}

# RBAC ROLES

# Application Insights
# Needed for Tracing and for the Insights feature
# 3913510d-42f4-4e42-8a64-420c390055eb - Monitoring Metrics Publisher
# 73c42c96-874c-492b-b04d-ab87d138a893 - Log Analytics Reader

resource "azurerm_role_assignment" "foundry_identity_app_insights_publisher" {
  scope                = azurerm_application_insights.app_insights.id
  role_definition_name = "Monitoring Metrics Publisher"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}
resource "azurerm_role_assignment" "foundry_identity_app_insights_reader" {
  scope                = azurerm_application_insights.app_insights.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}

# Key Vault
# Used for storing sensitive information
# REF: https://learn.microsoft.com/en-us/azure/foundry/how-to/set-up-key-vault-connection
# b86a8fe4-44ce-4948-aee5-eccb2c155cd7 - Key Vault Secrets Officer

resource "azurerm_role_assignment" "foundry_identity_kv" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}

# Storage
# Used as part of bring your own resources
# REF: https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/standard-agent-setup#phase-4-assign-granular-resource-permissions
# ba92f5b4-2d11-453d-a403-e96b0029c9fe - Storage Blob Data Contributor
# 974c5e8b-45b9-4653-ba55-5f855dd0fb88 - Storage Blob Data Owner
# 974c5e8b-45b9-4653-ba55-5f855dd0fb88 - Storage Queue Data Contributor

resource "azurerm_role_assignment" "foundry_identity_storage_queue_data_contributor" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Queue Data Contributor"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}

resource "azurerm_role_assignment" "foundry_identity_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}

resource "azurerm_role_assignment" "foundry_identity_storage_blob_data_owner" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}

# Azure AI Search
# 8ebe5a00-799e-43f5-93ac-243d3dce84a7 - Search Index Data Contributor
# 7ca78c08-252a-4471-8644-bb5ff32d4ba0 - Search Service Contributor

resource "azurerm_role_assignment" "foundry_identity_search_index_data_contributor" {
  scope                = azurerm_search_service.search.id
  role_definition_name = "Search Index Data Contributor"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}
resource "azurerm_role_assignment" "foundry_identity_search_service_contributor" {
  scope                = azurerm_search_service.search.id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}

# Cosmos DB
# 230815da-be43-4aae-9cb4-875f7bd000aa - Cosmos DB Operator
# 5bd9cd88-fe45-4216-938b-f97437e15450 - DocumentDB Account Contributor

resource "azurerm_role_assignment" "foundry_identity_cosmos_db_operator" {
  scope                = azurerm_cosmosdb_account.cosmos.id
  role_definition_name = "Cosmos DB Operator"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}
resource "azurerm_role_assignment" "foundry_identity_documentdb_account_contributor" {
  scope                = azurerm_cosmosdb_account.cosmos.id
  role_definition_name = "DocumentDB Account Contributor"
  principal_id         = azurerm_user_assigned_identity.foundry_identity.principal_id
}

resource "azurerm_cosmosdb_sql_role_assignment" "cosmos_contributor" {
  resource_group_name = azurerm_resource_group.rg.name
  account_name        = azurerm_cosmosdb_account.cosmos.name
  role_definition_id  = "${azurerm_cosmosdb_account.cosmos.id}/sqlRoleDefinitions/00000000-0000-0000-0000-000000000002"
  principal_id        = azurerm_user_assigned_identity.foundry_identity.principal_id
  scope               = azurerm_cosmosdb_account.cosmos.id
}

# Add a timer after all the RBAC roles are configured
resource "time_sleep" "wait_for_rbac" {
  create_duration = "10s"

  depends_on = [
    azurerm_role_assignment.foundry_identity_app_insights_publisher,
    azurerm_role_assignment.foundry_identity_app_insights_reader,
    azurerm_role_assignment.foundry_identity_cosmos_db_operator,
    azurerm_role_assignment.foundry_identity_documentdb_account_contributor,
    azurerm_role_assignment.foundry_identity_kv,
    azurerm_role_assignment.foundry_identity_search_index_data_contributor,
    azurerm_role_assignment.foundry_identity_search_service_contributor,
    azurerm_role_assignment.foundry_identity_storage_blob_data_contributor,
    azurerm_role_assignment.foundry_identity_storage_blob_data_owner,
    azurerm_role_assignment.foundry_identity_storage_queue_data_contributor,
    azurerm_role_assignment.foundry_identity_app_insights_publisher
    
  ]
}



