# Azure AI Foundry with customer-owned supporting services and private networking

## Require roles

This document summarizes the **11 active role assignments** declared in [`rbac-foundry-managed-identity.tf`](./rbac-foundry-managed-identity.tf): ten Azure RBAC assignments and one Cosmos DB for NoSQL data-plane assignment.

All assignments target the user-assigned managed identity for the Foundry resource and the default project:




## Permission summary

| Role name | Scope configured in Terraform | Reason / permissions provided |
| --- | --- | --- |
| **Monitoring Metrics Publisher** | Application Insights instance | Allows publishing monitoring metrics and telemetry to support Foundry tracing and monitoring.  |
| **Log Analytics Reader** | Application Insights instance | Intended to support monitoring and Insights read access.  |
| **Key Vault Secrets Officer** | Key Vault | Allows managing secret contents and lifecycle for sensitive information used by Foundry connections.  |
| **Storage Queue Data Contributor** | Storage account | Allows reading, writing, and deleting queues and queue messages used by supporting storage workflows. |
| **Storage Blob Data Contributor** | Storage account | Allows reading, writing, and deleting blob containers and blob data used for agent files and supporting storage. |
| **Storage Blob Data Owner** | Storage account | Provides full blob-data access |
| **Search Index Data Contributor** | Azure AI Search service | Allows reading, uploading, updating, and deleting indexed documents for agent retrieval and vector-store data operations. |
| **Search Service Contributor** | Azure AI Search service | Allows managing the Search service and search objects such as indexes and indexers. Complements Search Index Data Contributor, which grants indexed-document access. |
| **Cosmos DB Operator** | Cosmos DB account | Allows account-management operations  |
| **DocumentDB Account Contributor** | Cosmos DB account | Grants broader Cosmos DB account-management permissions |
| **Cosmos DB Built-in Data Contributor** | Cosmos DB NoSQL account | Grants NoSQL data-plane access across the account, including database/container operations, item read/write operations, and queries, supporting agent thread storage. |


## References
- [Standard Agent setup](https://learn.microsoft.com/en-us/azure/foundry/agents/concepts/standard-agent-setup#phase-4-assign-granular-resource-permissions)
- [Keyvault Connection setup](https://learn.microsoft.com/en-us/azure/foundry/how-to/set-up-key-vault-connection)

