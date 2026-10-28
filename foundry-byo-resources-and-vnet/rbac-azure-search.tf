# Configure the Foundry user role for Azure search
resource "azurerm_role_assignment" "search_access_to_models" {
  scope                = azapi_resource.example.id
  role_definition_name = "Foundry User"
  principal_id         = azurerm_search_service.search.identity[0].principal_id
}