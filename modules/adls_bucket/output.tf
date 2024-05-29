output "bucket_name" {
  description = "Azure Storage Bucket Name"
  value       = azurerm_storage_account.this.name
}

output "bucket_key" {
  description = "Azure Storage Bucket Access Key"
  value       = azurerm_storage_account.this.primary_access_key
}

output "bucket_connection" {
  description = "Azure Storage Bucket Connection Key"
  value       = azurerm_storage_account.this.primary_connection_string
}

output "bucket_dfs_host" {
  description = "Azure Storage Bucket Primary DFS Host Connection String"
  value       = azurerm_storage_account.this.primary_dfs_host
}