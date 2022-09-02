# Configure the Azure & Azure AD provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.4.3"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.2.1"
    }
  }
}

provider "azurerm" {
  features {}
}

#-- Resource Group
resource "azurerm_resource_group" "azfinsim" {
  name     = format("%srg", var.prefix)
  location = var.location
}

#-- Current user info using Azure cli 
data "external" "UserAccount" {
  # sometime "az ad signed-in-user show" this command executed values are not giving objectId
  program = ["az", "ad", "signed-in-user", "show", "--query", "{displayName:displayName, userPrincipalName:userPrincipalName, objectId:id}"]
}

#-- Resource Tags: just add this line to resources to be tagged: 
#  tags = local.resource_tags
locals {
  resource_tags = {
    Application = var.prefix
    Environment = "Demo" 
    CreatedOn   = formatdate("YYYYMMDD-hhmmss", timestamp())
    CreatedBy   = data.external.UserAccount.result.userPrincipalName
  }
}

#-- get subscription id, tenant id, & object id 
data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

#-- create a short random string for keyvault (soft delete means names cannot be re-used)
resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}
