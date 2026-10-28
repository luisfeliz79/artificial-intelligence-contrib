# This configures diagnostic settings against
# the Log Analytics Workspace.

module "keyvault_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = azurerm_key_vault.kv.id
}

module "storage_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = azurerm_storage_account.sa.id
}

module "storage_blob_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = "${azurerm_storage_account.sa.id}/blobServices/default"
}

module "storage_file_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = "${azurerm_storage_account.sa.id}/fileServices/default"
}

module "storage_queue_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = "${azurerm_storage_account.sa.id}/queueServices/default"
}

module "storage_table_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = "${azurerm_storage_account.sa.id}/tableServices/default"
}

module "cosmos_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = azurerm_cosmosdb_account.cosmos.id
}

module "search_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = azurerm_search_service.search.id
}

module "appinsights_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = azurerm_application_insights.app_insights.id
}

module "foundry_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = azapi_resource.example.id
}

module "foundry_project_diagnostics" {
  source = "./modules/diagnostics"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  target_resource_id = azapi_resource.default.id
}