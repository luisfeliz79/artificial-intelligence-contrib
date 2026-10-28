# Azure AI Foundry with customer-owned supporting services and private networking

This is **sample** Terraform code for how to provision an Azure AI Foundry account and project with an Agents capability host, customer-owned Storage, Azure AI Search, and Cosmos DB, plus Key Vault, monitoring, managed identities, and private networking.

Although this directory is named `terraform-azurerm`, it uses both **AzureRM** and **AzAPI**: AzureRM manages the supporting infrastructure and connections, while AzAPI manages the Foundry account, project, and project capability host.  AzAPI is being used in cases where the existing AzureRM provider does not yet support the required resources.


## Prerequisites and deployment

Before deploying:

1. **Contributor** and **Role Based Access Control Administrator** permissions are required on the subscription.  However, this plan can be adjusted to use an existing resource group for a lesser privilege scenario.


2. **Required Resource Providers**

   ```bash
   az provider register --namespace 'Microsoft.KeyVault'
   az provider register --namespace 'Microsoft.CognitiveServices'
   az provider register --namespace 'Microsoft.Storage'
   az provider register --namespace 'Microsoft.Search'
   az provider register --namespace 'Microsoft.Network'
   az provider register --namespace 'Microsoft.App'
   az provider register --namespace 'Microsoft.ContainerService'
   ```
3. Modify locals.tf to set the deployment values for your environment.


## Architecture

```text
Resource group
|
+-- Foundry account (AIServices, S0)
|   +-- proj-default
|       +-- Agents capability host
|           +-- Vector store connection ------> Azure AI Search
|           +-- Storage connection -----------> Storage account
|           +-- Thread storage connection ----> Cosmos DB
|   +-- Account connections to Key Vault and Application Insights
|
+-- Shared user-assigned managed identity for Foundry account/project
+-- Key Vault
+-- Log Analytics workspace <--- Diagnostic settings
+-- Application Insights ------> Log Analytics workspace
|
+-- Virtual network: 10.99.0.0/16
    +-- foundry-subnet:   10.99.0.0/24  (agent network injection)
    +-- endpoints-subnet: 10.99.1.0/24  (six private endpoints)
    +-- tools-subnet:     10.99.2.0/24  (reserved for future tools)
    +-- Eight linked private DNS zones
```

The supporting services are **created by this configuration** and then connected to Foundry. They are not references to pre-existing services supplied as inputs.

## Resources provisioned

### Foundry account, project, and connections

| Component | Configuration |
| --- | --- |
| Foundry account | `Microsoft.CognitiveServices/accounts@2025-06-01`, kind `AIServices`, SKU `S0`, project management enabled, and a custom subdomain matching the account name. |
| Default project | `proj-default`, created with `Microsoft.CognitiveServices/accounts/projects@2025-06-01`. |
| Managed identity | One user-assigned identity attached to both the account and project. |
| Agent networking | The account injects the `agent` scenario into `foundry-subnet`. |
| Project capability host | `project-capability-host`, kind `Agents`, using `Microsoft.CognitiveServices/accounts/projects/capabilityHosts@2025-04-01-preview`. Schema validation is disabled for this resource. |

The project capability host selects the Search connection for vector storage, the Storage connection for file storage, and the Cosmos DB connection for thread storage. There is no explicit account-level capability host resource; the configuration notes that network injection creates it automatically.

Five **account-level connections** are created:

| Target | Connection category | Authentication configured |
| --- | --- | --- |
| Key Vault | `AzureKeyVault` | Account managed identity |
| Storage blob endpoint | `AzureStorageAccount` | Microsoft Entra ID |
| Cosmos DB endpoint | `CosmosDb` | Microsoft Entra ID |
| Azure AI Search endpoint | `CognitiveSearch` | Microsoft Entra ID |
| Application Insights | `AppInsights` | API-key connection resource populated with the Application Insights connection string |

The Key Vault connection is created before the other four connections through explicit dependencies.

### Supporting services

| Service | Important settings |
| --- | --- |
| Resource group | Named `<prefix>-rg`; uses the configured region and `environment = dev` tag. |
| Storage account | Standard, zone-redundant storage (`ZRS`); HTTPS only; minimum TLS 1.2; shared-key access disabled; OAuth is the default authentication method; nested items cannot be public; system-assigned identity enabled. |
| Azure AI Search | Basic SKU, default hosting mode, local authentication disabled, system-assigned identity enabled. |
| Cosmos DB | NoSQL account (`GlobalDocumentDB`), Standard offer, Session consistency, one region with failover priority 0, local authentication disabled, system-assigned identity enabled. |
| Key Vault | Standard SKU, Azure RBAC authorization, purge protection enabled, seven-day soft-delete retention. |
| Log Analytics | `PerGB2018` workspace with 30-day retention. |
| Application Insights | Workspace-based instance with application type `web`, linked to the Log Analytics workspace. |

Terraform also maintains a four-character lowercase alphanumeric naming suffix and a ten-second RBAC propagation delay resource. Neither is an Azure service.

## Networking and public access

This is **not a fully private-only deployment**. Private endpoints are provisioned, but the Foundry and Search public endpoints remain enabled with restrictions.

### Subnets

| Subnet | Default address range | Purpose |
| --- | --- | --- |
| `foundry-subnet` | `10.99.0.0/24` | Agent network injection; delegated to `Microsoft.App/environments`. |
| `endpoints-subnet` | `10.99.1.0/24` | All six private endpoints; no service delegation. |
| `tools-subnet` | `10.99.2.0/24` | Reserved for future MCP tools; delegated to `Microsoft.App/environments`. No tools are deployed. |

### Private endpoints and DNS

Each private endpoint has an automatically requested service connection and a private DNS zone group. All eight DNS zones are linked to the virtual network with automatic registration disabled.

| Target | Private Link subresource | Private DNS zone(s) |
| --- | --- | --- |
| Key Vault | `vault` | `privatelink.vaultcore.azure.net` |
| Storage blobs | `blob` | `privatelink.blob.core.windows.net` |
| Storage queues | `queue` | `privatelink.queue.core.windows.net` |
| Cosmos DB | `Sql` | `privatelink.documents.azure.com` |
| Azure AI Search | `searchService` | `privatelink.search.windows.net` |
| Foundry account | `account` | `privatelink.cognitiveservices.azure.com`, `privatelink.openai.azure.com`, `privatelink.services.ai.azure.com` |

There are no Storage Files or Tables private endpoints, despite diagnostic settings being configured for those services.



## Identity and access control

The shared Foundry user-assigned identity receives:

| Scope | Role assignments |
| --- | --- |
| Application Insights instance | `Monitoring Metrics Publisher`, `Log Analytics Reader` |
| Key Vault | `Key Vault Secrets Officer` |
| Storage account | `Storage Queue Data Contributor`, `Storage Blob Data Contributor`, `Storage Blob Data Owner` |
| Azure AI Search | `Search Index Data Contributor`, `Search Service Contributor` |
| Cosmos DB account | `Cosmos DB Operator`, `DocumentDB Account Contributor` |
| Cosmos DB NoSQL data plane | Built-in Data Contributor role (`00000000-0000-0000-0000-000000000002`) at account scope |

The Search service's system-assigned identity also receives **`Foundry User`** on the Foundry account. This grants access permissions; it does not deploy a model or configure a Search indexer.


Foundry account creation depends on a ten-second delay after the listed Azure RBAC assignments. This is a fixed wait, not a check that every permission has propagated; the Cosmos DB SQL role assignment is not included in that explicit wait dependency.

## Monitoring

The reusable [`modules/diagnostics`](./modules/diagnostics) module discovers the log and metric categories supported by each target and enables all categories returned by Azure, sending them to the shared Log Analytics workspace.

Eleven diagnostic settings named `monitoring` cover:

- Key Vault.
- Storage account and its Blob, File, Queue, and Table services.
- Cosmos DB.
- Azure AI Search.
- Application Insights.
- Foundry account.
- Foundry project.

Application Insights is also connected to Foundry for tracing. No alert rules, action groups, dashboards, or subscription Activity Log diagnostic setting are deployed.

## Configuration and naming

Deployment settings are currently hard-coded in [`locals.tf`](./locals.tf). The root [`variables.tf`](./variables.tf) is empty, so these settings cannot currently be overridden through `-var` or a `.tfvars` file.

| Local | Current value or behavior |
| --- | --- |
| `subscription_id` | Explicit subscription ID in `locals.tf`; replace with the intended subscription before deploying. |
| `prefix` | `<changeme>` |
| `location` | `<azure-region>` |
| `deploy_egress_ip` | Explicit public IPv4 address in `locals.tf`; replace with the deployment/client egress IP. |
| `vnet_address_prefix` | `ex. 10.99.0.0/16` |
| Subnet names/ranges | As listed in the networking section. |
| `tags` | `environment = "dev"` |

The resource group and virtual network use `<prefix>-rg` and `<prefix>-vnet`. Most service names include the persisted random suffix, for example `<prefix>-<suffix>-foundry`, `<prefix>-<suffix>-kv`, and `<prefix>-<suffix>-search`. Storage uses `<prefix><suffix>sa` without hyphens; keep it within Azure's 24-character limit and naming requirements.





## Source map

| File | Responsibility |
| --- | --- |
| [`main.tf`](./main.tf), [`locals.tf`](./locals.tf), [`provider.tf`](./provider.tf) | Resource group, random suffix, deployment settings, and provider setup. |
| [`foundry-azapi.tf`](./foundry-azapi.tf) | Foundry account and default project. |
| [`foundry-capability-hosts-azapi.tf`](./foundry-capability-hosts-azapi.tf) | Project Agents capability host and supporting connection selection. |
| [`foundry-connections.tf`](./foundry-connections.tf) | Five account-level service connections. |
| [`supporting-services.tf`](./supporting-services.tf) | Storage, Search, Cosmos DB, Key Vault, Log Analytics, and Application Insights. |
| [`virtual-network.tf`](./virtual-network.tf), [`private-endpoints.tf`](./private-endpoints.tf) | Virtual network, subnets, private endpoints, DNS zones, and links. |
| [`rbac-foundry-managed-identity.tf`](./rbac-foundry-managed-identity.tf), [`rbac-azure-search.tf`](./rbac-azure-search.tf) | Managed identity, role assignments, and RBAC delay. |
| [`diagnostics.tf`](./diagnostics.tf), [`modules/diagnostics`](./modules/diagnostics) | Diagnostic settings and dynamic category discovery. |
| [`outputs.tf`](./outputs.tf) | Managed identity client and object IDs. |
