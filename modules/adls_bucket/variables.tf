## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## ---------------------------------------------------------------------------------------------------------------------

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
  description = "Security Group to Assign Contributor Role"
}

variable "bucket_name" {
  type        = string
  description = "Azure Storage Account Name"
}

variable "container_name" {
  type        = string
  description = "Azure Storage Account Container Name"
}

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## ---------------------------------------------------------------------------------------------------------------------

variable "role_definition_name" {
  type        = string
  description = "Azure AD role definition to allow authentication for ADLS bucket"
  default     = "Storage Blob Data Contributor"
}

variable "hierarchical_namespace" {
  type        = bool
  description = "Flag to enable Azure Storage Account Hierarchical Namespace"
  default     = false
}