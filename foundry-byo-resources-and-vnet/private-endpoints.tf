# Create private endpoints for supporting services, including Private DNS zones, and VNET links

# Create Private DNS zones
# Key Vault DNS zone
resource "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.tags
}
# Storage Blob
resource "azurerm_private_dns_zone" "storage_blob_dns" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
}

# Storage Queue
resource "azurerm_private_dns_zone" "storage_queue_dns" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
}


# Cosmos
resource "azurerm_private_dns_zone" "cosmos_dns" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
}
# Search
resource "azurerm_private_dns_zone" "search_dns" {
  name                = "privatelink.search.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
}





# Link the zones to the virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_vnet_link" {

  name = "${azurerm_virtual_network.vnet.name}-link"
  # resource_group_name   = azurerm_resource_group.rg.name
  # private_dns_zone_name   = azurerm_private_dns_zone.kv_dns.name
  private_dns_zone_id     = azurerm_private_dns_zone.kv_dns.id
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

  resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_vnet_link" {
    name                  = "${azurerm_virtual_network.vnet.name}-link"
    # resource_group_name   = azurerm_resource_group.rg.name
    # private_dns_zone_name   = azurerm_private_dns_zone.storage_blob_dns.name
    private_dns_zone_id     = azurerm_private_dns_zone.storage_blob_dns.id
    virtual_network_id    = azurerm_virtual_network.vnet.id
    registration_enabled  = false
  }

  resource "azurerm_private_dns_zone_virtual_network_link" "storage_queue_dns_vnet_link" {
    name                  = "${azurerm_virtual_network.vnet.name}-link"
    # resource_group_name   = azurerm_resource_group.rg.name
    # private_dns_zone_name   = azurerm_private_dns_zone.storage_queue_dns.name
    private_dns_zone_id     = azurerm_private_dns_zone.storage_queue_dns.id
    virtual_network_id    = azurerm_virtual_network.vnet.id
    registration_enabled  = false
  }

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_dns_vnet_link" {
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  # resource_group_name   = azurerm_resource_group.rg.name
  # private_dns_zone_name   = azurerm_private_dns_zone.cosmos_dns.name
  private_dns_zone_id     = azurerm_private_dns_zone.cosmos_dns.id
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "search_dns_vnet_link" {
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  # resource_group_name   = azurerm_resource_group.rg.name
  # private_dns_zone_name   = azurerm_private_dns_zone.search_dns.name
  private_dns_zone_id     = azurerm_private_dns_zone.search_dns.id
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# Private Endpoints for various services
# Key Vault
resource "azurerm_private_endpoint" "kv_pe" {
  name                = "${local.key_vault_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "${local.key_vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_dns.id]
  }
  tags = local.tags
}

# Storage account blob
resource "azurerm_private_endpoint" "storage_pe" {
  name                = "${local.storage_account_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "${local.storage_account_name}-psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob_dns.id]
  }

  tags = local.tags
}


# Storage account blob
resource "azurerm_private_endpoint" "storage_queue_pe" {
  name                = "${local.storage_account_name}-queue-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "${local.storage_account_name}-queue-psc"
    private_connection_resource_id = azurerm_storage_account.sa.id
    is_manual_connection           = false
    subresource_names              = ["queue"]
  }
  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_queue_dns.id]
  }

  tags = local.tags
}


# Azure Search
resource "azurerm_private_endpoint" "search_pe" {
  name                = "${local.search_service_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "${local.search_service_name}-psc"
    private_connection_resource_id = azurerm_search_service.search.id
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }
  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.search_dns.id]
  }

  tags = local.tags
}

# Cosmos DB
resource "azurerm_private_endpoint" "cosmos_pe" {
  name                = "${local.cosmos_db_account_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "${local.cosmos_db_account_name}-psc"
    private_connection_resource_id = azurerm_cosmosdb_account.cosmos.id
    is_manual_connection           = false
    subresource_names              = ["Sql"]
  }
  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.cosmos_dns.id]
  }

  tags = local.tags
}


#### Foundry and Cognitive services accounts
# Foundry and Cognitive services accounts
# Foundry DNS zone
resource "azurerm_private_dns_zone" "foundry_dns" {
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
}

# OpenAI DNS zone
resource "azurerm_private_dns_zone" "openai_dns" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
}

# Azure AI Services - privatelink.services.ai.azure.com
resource "azurerm_private_dns_zone" "ai_services_dns" {
  name                = "privatelink.services.ai.azure.com"
  resource_group_name = azurerm_resource_group.rg.name
  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ai_services_dns_vnet_link" {
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  # resource_group_name   = azurerm_resource_group.rg.name
  # private_dns_zone_name   = azurerm_private_dns_zone.ai_services_dns.name
  private_dns_zone_id     = azurerm_private_dns_zone.ai_services_dns.id
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}


resource "azurerm_private_dns_zone_virtual_network_link" "openai_dns_vnet_link" {
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  # resource_group_name   = azurerm_resource_group.rg.name
  # private_dns_zone_name   = azurerm_private_dns_zone.openai_dns.name
  private_dns_zone_id     = azurerm_private_dns_zone.openai_dns.id
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}


resource "azurerm_private_dns_zone_virtual_network_link" "foundry_dns_vnet_link" {
  name                  = "${azurerm_virtual_network.vnet.name}-link"
  # resource_group_name   = azurerm_resource_group.rg.name
  # private_dns_zone_name   = azurerm_private_dns_zone.foundry_dns.name
  private_dns_zone_id     = azurerm_private_dns_zone.foundry_dns.id
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
}

# Create a private endpoint for the Foundry Resource
resource "azurerm_private_endpoint" "foundry" {
  name                = "${local.foundry_name}-pe"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.endpoints.id

  private_service_connection {
    name                           = "${local.foundry_name}-psc"
    private_connection_resource_id = azapi_resource.example.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.foundry_dns.id, azurerm_private_dns_zone.ai_services_dns.id, azurerm_private_dns_zone.openai_dns.id]
  }

  tags = local.tags
}

