terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }

  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "sim-parables"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "ci-cd-azure-workspace"
    }
  }
}


##---------------------------------------------------------------------------------------------------------------------
## AZURERM PROVIDER
##
## Azure Resource Manager (Azurerm) provider authenticated with service account client credentials.
##
## Parameters:
## - `client_id`: Service account client ID.
## - `client_secret`: Service account client secret.
## - `subscription_id`: Azure subscription ID.
## - `tenant_id`: Azure tenant ID.
## - `prevent_deletion_if_contains_resources`: Disable resource loss prevention mechanism.
##---------------------------------------------------------------------------------------------------------------------
provider "azurerm" {
  alias = "auth_session"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

##---------------------------------------------------------------------------------------------------------------------
## AZURERM RESOURCE GROUP RESOURCE
##
## Create an Azure Resource Group to organize/group collections of resources, and isolate for billing.
##
## Parameters:
## - `name`: Azure Resource Group name.
## - `location`: Azure resource group location.
##---------------------------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  provider = azurerm.auth_session

  name     = "example-resource-group"
  location = var.azure_region
}


##---------------------------------------------------------------------------------------------------------------------
## TRIGGER BUCKET MODULE
##
## This module creates an ADLS Storage Account for the Azure Function blob trigger.
##
## Parameters:
## - `bucket_name`: ADLS storage account name.
## - `container_name`: ADLS storage account container name.
## - `resource_group_name`: Azure Resource Group name.
## - `resource_group_location`: Azure Resource Group location.
## - `security_group_id`: Azure AD Group ID to allow for access.
##---------------------------------------------------------------------------------------------------------------------
module "trigger_bucket" {
  source = "../../modules/adls_bucket"

  bucket_name             = "exampletriggerbucket"
  container_name          = "trigger"
  resource_group_name     = azurerm_resource_group.this.name
  resource_group_location = azurerm_resource_group.this.location
  security_group_id       = var.SECURITY_GROUP_ID

  providers = {
    azurerm.auth_session = azurerm.auth_session
  }
}

##---------------------------------------------------------------------------------------------------------------------
## RESULTS BUCKET MODULE
##
## This module creates an ADLS Storage Account for the Azure Function blob trigger results.
##
## Parameters:
## - `bucket_name`: ADLS storage account name.
## - `container_name`: ADLS storage account container name.
## - `resource_group_name`: Azure Resource Group name.
## - `resource_group_location`: Azure Resource Group location.
## - `security_group_id`: Azure AD Group ID to allow for access.
##---------------------------------------------------------------------------------------------------------------------
module "results_bucket" {
  source                  = "../../modules/adls_bucket"
  bucket_name             = "exampleresultsbucket"
  container_name          = "results"
  resource_group_name     = azurerm_resource_group.this.name
  resource_group_location = azurerm_resource_group.this.location
  security_group_id       = var.SECURITY_GROUP_ID

  providers = {
    azurerm.auth_session = azurerm.auth_session
  }
}


##---------------------------------------------------------------------------------------------------------------------
## AZURE FUNCTION APPLICATION MODULE
##
## This module provisions an Azure Functions Service Plan and Application configured to execute on a blob trigger. 
## This Function Application is also configured to log to Azure Applications Insights for debug purposes.
##
## Parameters:
## - `function_name`: Azure Function Application name.
## - `trigger_bucket_name`: ADLS trigger bucket name.
## - `trigger_bucket_access_key`: ADLS trigger bucket shared access key.
## - `resource_group_name`: Azure Resource Group name.
## - `resource_group_location`: Azure Resource Group location.
## - `app_settings`: Map of Azure Functions environment variables.
##---------------------------------------------------------------------------------------------------------------------
module "azure_function_application" {
  source = "../../"

  function_name           = "example-function-blob-trigger"
  trigger_bucket_name     = module.trigger_bucket.bucket_name
  trigger_bucket_key      = module.trigger_bucket.bucket_key
  resource_group_name     = azurerm_resource_group.this.name
  resource_group_location = azurerm_resource_group.this.location
  security_group_id       = var.SECURITY_GROUP_ID

  app_settings = {
    OUTPUT_BUCKET_NAME = module.results_bucket.bucket_name
    OUTPUT_BUCKET_KEY  = module.results_bucket.bucket_key
  }

  providers = {
    azurerm.auth_session = azurerm.auth_session
  }
}