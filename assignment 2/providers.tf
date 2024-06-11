terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.8"
    }
  }
}

# Configure the Azure provider
provider "azurerm" {
  features {}
}
