# Create a project capability host.
# Note: The account level capability host is created automatically
#       When Network injection is enabled.

locals {
   project_capability_properties = {
    capabilityHostKind       = "Agents"
    vectorStoreConnections   = [azurerm_cognitive_account_connection_entra_id.search.name]
    storageConnections       = [azurerm_cognitive_account_connection_entra_id.storage.name]
    threadStorageConnections = [azurerm_cognitive_account_connection_entra_id.cosmos.name]
  }
}

resource "azapi_resource" "project_capability_host" {

  type                      = "Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview"
  name                      = "project-capability-host"
  parent_id                 = azapi_resource.default.id
  schema_validation_enabled = false
  body = { properties = local.project_capability_properties }
  
}
