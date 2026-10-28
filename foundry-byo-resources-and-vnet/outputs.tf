output "foundry_identity_client_id" {
    value = azurerm_user_assigned_identity.foundry_identity.client_id
}

output "foundry_identity_object_id" {
    value = azurerm_user_assigned_identity.foundry_identity.principal_id
}