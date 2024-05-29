## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

variable "function_name" {
  type        = string
  description = "Azure Function App Name"
}

variable "trigger_bucket_name" {
  type        = string
  description = "Azure Trigger Storage Account Bucket Name"
}

variable "trigger_bucket_key" {
  type        = string
  description = "Azure Trigger Storage Account Bucket Access Key"
}

variable "resource_group_name" {
  type        = string
  description = "Azure Resouce Group Name"
}

variable "resource_group_location" {
  type        = string
  description = "Azure Resouce Group Location"
}

variable "security_group_id" {
  type        = string
  description = "Microsoft Entra Security Group ID"
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "python_version" {
  type        = string
  description = "Azure Function Runtime Python Version"
  default     = "3.10"
}

variable "service_plan_name" {
  type        = string
  description = "Azure Service Plan Name"
  default     = "example-function-service-plan"
}

variable "service_plan_os_type" {
  type        = string
  description = "Azure Service Plan OS Type"
  default     = "Linux"
}

variable "service_plan_sku_type" {
  type        = string
  description = "Azure Service Plan SKU Type"
  default     = "B1"
}

variable "app_settings" {
  type        = map(any)
  description = "Azure Functions Application App Setting/ Environment Variables"
  default     = {}
}