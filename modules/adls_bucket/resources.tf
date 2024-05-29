terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      configuration_aliases = [
        azurerm.auth_session,
      ]
    }
  }
}


## ---------------------------------------------------------------------------------------------------------------------
## AZURE STORAGE ACCOUNT RESOURCE
## 
## Create an ADLS Bucket.
## 
## Parameters:
## - `name`: ADLS bucket name.
## - `resource_group_name`: Azure Resource Group name.
## - `location`: Azure Resource Group location.
## - `account_tier`: ADLS account tier.
## - `account_replication_type`: ADLS replication type.
## ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_storage_account" "this" {
  provider = azurerm.auth_session

  name                     = var.bucket_name
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


## ---------------------------------------------------------------------------------------------------------------------
## AZURERM ROLE ASSIGNMENT RESOURCE
## 
## Assign Security Group
## Provie the Data Contributor Role to the Security Group with access to this Storage Account.
## 
## Parameters:
## - `scope`: ADLS bucket ID.
## - `role_definition_name`: Azure AD role name.
## - `principal_id`: Azure AD security group.
## ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_role_assignment" "this" {
  provider = azurerm.auth_session

  scope                = azurerm_storage_account.this.id
  role_definition_name = var.role_definition_name
  principal_id         = var.security_group_id
}


## ---------------------------------------------------------------------------------------------------------------------
## AZURERM STORAGE CONTAINER RESOURCE
## 
## Create Container in the Storage Account.
## 
## Parameters:
## - `name`: ADLS container name.
## - `storage_account_name`: ADLS bucket name.
## - `container_access_type`: ADLS bucket configuration to block public acccess.
## ---------------------------------------------------------------------------------------------------------------------
resource "azurerm_storage_container" "this" {
  provider = azurerm.auth_session

  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}