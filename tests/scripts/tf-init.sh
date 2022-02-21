#!/usr/bin/bash
set -e

#
# Shell Script
# - Terraform Initialize
#

TF_WORKSPACE="$PIPELINE_WORKSPACE/s/$TEST_MODULE_PATH"
TF_STATE="../tfstate/terraform-$TF_VERSION-$TF_AZ_VERSION.tfstate"

echo "==> Switching directories..."
cd "$TF_WORKSPACE"

echo "==> Creating terraform_override.tf with required_provider and local backend configuration..."
cat >terraform_override.tf <<TFCONFIG
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "$TF_AZ_VERSION"
      configuration_aliases = [
        azurerm.connectivity,
        azurerm.management,
      ]
    }
  }
  backend "local" {
    path = "$TF_STATE"
  }
}
TFCONFIG

echo "==> Creating providers_override.tf with subscription configuration and credentials..."
cat >providers_override.tf <<TFCONFIG
provider "azurerm" {
  features {}

  alias                       = "connectivity"
  subscription_id             = "$TF_SUBSCRIPTION_ID_CONNECTIVITY"
  client_id                   = "$ARM_CERTIFICATE_CLIENT_ID"
  client_certificate_path     = "$ARM_CERTIFICATE_PATH"
  client_certificate_password = "$ARM_CERTIFICATE_PASSWORD"
  tenant_id                   = "$ARM_TENANT_ID"
}

provider "azurerm" {
  features {}

  alias                       = "management"
  subscription_id             = "$TF_SUBSCRIPTION_ID_MANAGEMENT"
  client_id                   = "$ARM_CERTIFICATE_CLIENT_ID"
  client_certificate_path     = "$ARM_CERTIFICATE_PATH"
  client_certificate_password = "$ARM_CERTIFICATE_PASSWORD"
  tenant_id                   = "$ARM_TENANT_ID"
}
TFCONFIG

echo "==> Initializaing Terraform workspace..."
terraform init
