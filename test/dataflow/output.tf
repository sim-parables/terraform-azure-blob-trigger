output "trigger_bucket_name" {
  description = "ADLS Bucket Name for Trigger Data"
  value       = module.trigger_bucket.bucket_name
}

output "results_bucket_name" {
  description = "ADLS Bucket Name for Results Data"
  value       = module.results_bucket.bucket_name
}

output "function_url" {
  description = "Azure Function Application URL"
  value       = module.azure_function_application.function_url
}