terraform {
  required_version = ">= 1.11.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.27.0"
    }
  }
  backend "azurerm" {
    key = "lab.tfstate"
  }
}

provider "azurerm" {
  features {}
}
