# Create a Foundry resource.
resource "azapi_resource" "example" {
  type      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name      = local.foundry_name
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  tags      = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.foundry_identity.id]
  }

  body = {
    kind = "AIServices"
    sku = {
      name = "S0"
    }
    properties = {
      allowProjectManagement = true
      customSubDomainName    = local.foundry_name
      disableLocalAuth       = true
      publicNetworkAccess    = "Enabled"

      networkAcls = {
        defaultAction = "Deny"
        bypass        = "AzureServices"
        ipRules = [
          { value = local.deploy_egress_ip }
        ]
      }

      networkInjections = [
        {
          scenario    = "agent"
          subnetArmId = azurerm_subnet.foundry.id
        }
      ]
    }
  }

  depends_on = [
    time_sleep.wait_for_rbac
  ]
}

# Creates a project resource.
resource "azapi_resource" "default" {
  type      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name      = "proj-default"
  parent_id = azapi_resource.example.id
  location  = azurerm_resource_group.rg.location
  tags      = local.tags


  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.foundry_identity.id]
  }

  body = {
    properties = {
      description = "Default project created with the resource"
      displayName = "proj-default"
    }
  }

  response_export_values = ["identity.principalId"]
}