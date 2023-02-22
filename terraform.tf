# Configure the minimum required providers supported by this module
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.management,
      ]
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }

  required_version = ">= 1.3.1"
}
