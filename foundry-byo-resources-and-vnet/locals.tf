## SAMPLE Values, update with your own!

locals {

  deploy_egress_ip                = "x.x.x.x"

  subscription_id                 = "xxxxx-xxxx-xxxx-xxxx-xxxxx"

  prefix                          = "changeme"

  random_suffix                     = random_string.suffix.result
  resource_group_name             = "${local.prefix}-rg"
  
  location                        = "eastus"

  vnet_name                       = "${local.prefix}-vnet"
  vnet_address_prefix             = "10.99.0.0/16"

  foundry_subnet_name             = "foundry-subnet"
  foundry_subnet_address_prefix   = "10.99.0.0/24" # Minimum recommended

  endpoints_subnet_name           = "endpoints-subnet"
  endpoints_subnet_address_prefix = "10.99.1.0/24"

  tools_subnet_name               = "tools-subnet"
  tools_subnet_address_prefix     = "10.99.2.0/24"

  foundry_name                    = "${local.prefix}-${local.random_suffix}-foundry"
  key_vault_name                  = "${local.prefix}-${local.random_suffix}-kv"
  storage_account_name            = "${local.prefix}${local.random_suffix}sa" #MAX 24 chars
  cosmos_db_account_name          = "${local.prefix}-${local.random_suffix}-cosmos"
  search_service_name             = "${local.prefix}-${local.random_suffix}-search"
  app_insights_name               = "${local.prefix}-${local.random_suffix}-insights"

  tags = {
    environment = "dev"
  }
}
