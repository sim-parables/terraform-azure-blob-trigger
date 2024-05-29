## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group Name to Create ADLS Bucket"
}

variable "resource_group_location" {
  type        = string
  description = "Azure Resource Group Location"
}

variable "security_group_id" {
  type        = string
  description = "Azure AD Security Group ID to Allow access to ADLS Storage Account"
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "function_bucket_name" {
  type        = string
  description = "Azure Functions Storage Account Name for Function Zip"
  default     = "examplefunctionbucket"
}

variable "function_container_name" {
  type        = string
  description = "Azure Functions Storage Account Container for Function Zip"
  default     = "functions"
}

variable "function_sas_token_expiry" {
  type        = string
  description = "Function ZIP SAS Token Relative Expiry Time"
  default     = "24h"
}

variable "dependency_install_path" {
  type        = string
  description = "Source Dependency Install Target Path"
  default     = "./source"
}

variable "archive_path" {
  type        = string
  description = "Zip Archival Path"
  default     = "./source/function.zip"
}