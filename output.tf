output "function_url" {
  description = "Azure Function Application URL"
  value       = "https://${var.function_name}.azurewebsites.net/"
}