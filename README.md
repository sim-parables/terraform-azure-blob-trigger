<p float="left">
  <img id="b-0" src="https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white" height="25px"/>
  <img id="b-1" src="https://img.shields.io/badge/Microsoft_Azure-0089D6?style=for-the-badge&logo=microsoft-azure&logoColor=white" height="25px"/>
  <img id="b-2" src="https://img.shields.io/github/actions/workflow/status/sim-parables/terraform-azure-blob-trigger/tf-integration-test.yml?style=flat&logo=github&label=CD%20(May%202024)" height="25px"/>
</p>

# Terraform Azure Blob Trigger Module

A reusable module for creating & configuring ADLS Gen2 Buckets with custom Blob Trigger Functions.

## Usage

```hcl
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

```

## Inputs

| Name                    | Description                           | Type           | Required |
|:------------------------|:--------------------------------------|:---------------|:---------|
| function_name           | Function Aop Name                     | String         | Yes      |
| trigger_bucket_name     | Azure Trigger Bucket Name             | String         | Yes      |
| trigger_bucket_key      | Azure Trigger Bucket Access Key       | String         | Yes      |
| resource_group_name     | Azure Resouce Group Name              | String         | Yes      |
| resource_group_location | Azure Resouce Group Location          | String         | Yes      |
| security_group_id       | Microsoft Entra Security Group ID     | String         | Yes      |
| python_version          | Azure Function Runtime Python Version | String         | No       |
| service_plan_name       | Azure Service Plan Name               | String         | No       |
| service_plan_os_type    | Azure Service Plan OS Type            | String         | No       |
| service_plansku_type    | Azure Service Plan SKU Type           | String         | No       |
| app_settings            | Addition. Azure Function App Env Vars | Object()       | No       |  

## Outputs

| Name                   | Description                            |
|:-----------------------|:---------------------------------------|
| function_url           | Azure Function Application URL         |
