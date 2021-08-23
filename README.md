# Terraform Module for Cloud Adoption Framework Enterprise-scale

[![Build Status](https://dev.azure.com/mscet/CAE-ESTF/_apis/build/status/Tests/E2E?branchName=main)](https://dev.azure.com/mscet/CAE-ESTF/_build/latest?definitionId=26&branchName=main)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/Azure/terraform-azurerm-caf-enterprise-scale?style=flat&logo=github)

> **MODULE UPGRADE NOTES**
>
> The `v0.4.0` release represents a major milestone for the module, introducing capabilities for deploying `Identity` and `Connectivity` solutions from the Enterprise-scale architecture.
> The following breaking changes should be noted when upgrading from `v0.3.x`:
> - The minimum supported version of Terraform is now set to `0.15.0`
> - The minimum supported version of the AzureRM Provider is now set to `2.66.0`
> - Resources have been renamed to support multiple providers within the module
> - The [`azurerm_policy_assignment`][azurerm_policy_assignment] resource type has been replaced by the new [`azurerm_management_group_policy_assignment`][azurerm_management_group_policy_assignment] resource type
>
> These changes were necessary to support the latest features for Availability Zone configuration settings on the [`azurerm_public_ip`][azurerm_public_ip] resources, allow integration of multiple providers within the module to enable deploying resources to multiple Subscriptions, and to future proof against deprecation of the [`azurerm_policy_assignment`][azurerm_policy_assignment] resource.
> We believe this provides the best end-user experience going forward, so to make the transition as easy as possible, we have also provided documentation explaining how to [upgrade from v0.3.3 to v0.4.0][wiki_upgrade_from_v0_3_3_to_v0_4_0].
> We strongly recommend to review this, along with the [release notes][release_notes_v0_4_0] and test your deployment before upgrading.
>
> The `v0.3.0` release focuses mainly on updating the test framework, but also introduces a breaking change which removes the need (and support for) wrapping user-defined parameters in `jsonencode()`.
> When upgrading to this release, please ensure to update your code to use native HCL values as documented in the [release notes][release_notes_v0_3_0].
>
> The `v0.2.0` release added new functionality to enable deployment of [Management and monitoring][ESLZ-Management] resources into the current Subscription context.
> Please refer to the [Deploy Management Resources][wiki_deploy_management_resources] page on our Wiki for more information about how to use this.

## Documentation

For detailed information about how to use, configure and extend this module, please refer to the documentation on our Wiki:

- [Home][wiki_home]
- [User Guide][wiki_user_guide]
  - [Getting Started][wiki_getting_started]
  - [Module Permissions][wiki_module_permissions]
  - [Module Variables][wiki_module_variables]
  - [Provider Configuration][wiki_provider_configuration]
  - [Archetype Definitions][wiki_archetype_definitions]
  - [Core Resources][wiki_core_resources]
  - [Management Resources][wiki_management_resources]
  - [Connectivity Resources][wiki_connectivity_resources]
  - [Identity Resources][wiki_identity_resources]
  - [Upgrade from v0.0.8 to v0.1.0][wiki_upgrade_from_v0_0_8_to_v0_1_0]
  - [Upgrade from v0.1.2 to v0.2.0][wiki_upgrade_from_v0_1_2_to_v0_2_0]
  - [Upgrade from v0.3.3 to v0.4.0][wiki_upgrade_from_v0_3_3_to_v0_4_0]
- [Examples][wiki_examples]
  - [Level 100][wiki_examples_level_100]
    - [Deploy Default Configuration][wiki_deploy_default_configuration]
    - [Deploy Demo Landing Zone Archetypes][wiki_deploy_demo_landing_zone_archetypes]
  - [Level 200][wiki_examples_level_200]
    - [Deploy Custom Landing Zone Archetypes][wiki_deploy_custom_landing_zone_archetypes]
    - [Deploy Connectivity Resources][wiki_deploy_connectivity_resources]
    - [Deploy Identity Resources][wiki_deploy_identity_resources]
    - [Deploy Management Resources][wiki_deploy_management_resources]
  - [Level 300][wiki_examples_level_300]
    - [Deploy Connectivity Resources With Custom Settings][wiki_deploy_connectivity_resources_custom]
    - [Deploy Identity Resources With Custom Settings][wiki_deploy_identity_resources_custom]
    - [Deploy Management Resources With Custom Settings][wiki_deploy_management_resources_custom]
    - [Expand Built-in Archetype Definitions][wiki_expand_built_in_archetype_definitions]
    - [Override Module Role Assignments][wiki_override_module_role_assignments]
    - [Deploy Using Module Nesting][wiki_deploy_using_module_nesting]
- [Frequently Asked Questions][wiki_frequently_asked_questions]
- [Troubleshooting][wiki_troubleshooting]
- [Contributing][wiki_contributing]
  - [Raising an Issue][wiki_raising_an_issue]
  - [Feature Requests][wiki_feature_requests]
  - [Contributing to Code][wiki_contributing_to_code]
  - [Contributing to Documentation][wiki_contributing_to_documentation]

## Overview

The [Terraform Module for Cloud Adoption Framework Enterprise-scale][terraform-registry-caf-enterprise-scale] provides an opinionated approach for deploying and managing the core platform capabilities of [Cloud Adoption Framework enterprise-scale landing zone architecture][ESLZ-Architecture] using Terraform.

Depending on selected options, this module can deploy different groups of resources as needed.

This is currently split logically into the following capabilities:

- [Core Resources](#core-resources)
- [Management Resources](#management-resources)
- [Connectivity Resources](#connectivity-resources)
- [Identity Resources](#identity-resources)

The following sections outline the different resource types deployed and managed by this module, depending on the configuration options specified.

### Core resources

The core capability of this module deploys the foundations of the [Cloud Adoption Framework enterprise-scale landing zone architecture][ESLZ-Architecture], with a focus on the central resource hierarchy and governance:

![Enterprise-scale Core Landing Zones Architecture][TFAES-Overview]

The following resource types are deployed and managed by this module when using the core capabilities:

|     | Azure Resource | Terraform Resource |
| --- | -------------- | ------------------ |
| Management Groups | [`Microsoft.Management/managementGroups`][arm_management_group] | [`azurerm_management_group`][azurerm_management_group] |
| Management Group Subscriptions | [`Microsoft.Management/managementGroups/subscriptions`][arm_management_group_subscriptions] | [`azurerm_management_group`][azurerm_management_group] |
| Policy Assignments | [`Microsoft.Authorization/policyAssignments`][arm_policy_assignment] | [`azurerm_management_group_policy_assignment`][azurerm_management_group_policy_assignment] |
| Policy Definitions | [`Microsoft.Authorization/policyDefinitions`][arm_policy_definition] | [`azurerm_policy_definition`][azurerm_policy_definition] |
| Policy Set Definitions | [`Microsoft.Authorization/policySetDefinitions`][arm_policy_set_definition] | [`azurerm_policy_set_definition`][azurerm_policy_set_definition] |
| Role Assignments | [`Microsoft.Authorization/roleAssignments`][arm_role_assignment] | [`azurerm_role_assignment`][azurerm_role_assignment] |
| Role Definitions | [`Microsoft.Authorization/roleDefinitions`][arm_role_definition] | [`azurerm_role_definition`][azurerm_role_definition] |

The exact number of resources created depends on the module configuration, but you can expect upwards of 200 resources to be created by this module for a default installation based on the example below.

> **NOTE:** None of these resources are deployed at the Subscription scope, however Terraform still requires a Subscription to establish an authenticated session with Azure.

### Management resources

From release `v0.2.0` onwards, the module includes new functionality to enable deployment of [Management and monitoring][ESLZ-Management] resources into the current Subscription context.
This brings the benefit of being able to manage the full lifecycle of these resources using Terraform, with native integration into the corresponding Policy Assignments to ensure full policy compliance.

![Enterprise-scale Management Landing Zone Architecture][TFAES-Management]

The following resource types are deployed and managed by this module when the Management resources capabilities are enabled:

|     | Azure Resource | Terraform Resource |
| --- | -------------- | ------------------ |
| Resource Groups | [`Microsoft.Resources/resourceGroups`][arm_resource_group] | [`azurerm_resource_group`][azurerm_resource_group] |
| Log Analytics Workspace | [`Microsoft.OperationalInsights/workspaces`][arm_log_analytics_workspace] | [`azurerm_log_analytics_workspace`][azurerm_log_analytics_workspace] |
| Log Analytics Solutions | [`Microsoft.OperationsManagement/solutions`][arm_log_analytics_solution] | [`azurerm_log_analytics_solution`][azurerm_log_analytics_solution] |
| Automation Account | [`Microsoft.Automation/automationAccounts`][arm_automation_account] | [`azurerm_automation_account`][azurerm_automation_account] |
| Log Analytics Linked Service | [`Microsoft.OperationalInsights/workspaces /linkedServices`][arm_log_analytics_linked_service] | [`azurerm_log_analytics_linked_service`][azurerm_log_analytics_linked_service] |

Please refer to the [Deploy Management Resources][wiki_deploy_management_resources] page on our Wiki for more information about how to use this capability.

### Connectivity resources

From release `v0.4.0` onwards, the module includes new functionality to enable deployment of [Network topology and connectivity][ESLZ-Connectivity] resources into the current Subscription context.
This is currently limited to the Hub & Spoke network topology, but the addition of Virtual WAN capabilities is on our roadmap (date TBC).

![Enterprise-scale Connectivity Landing Zone Architecture][TFAES-Connectivity]

> **NOTE:** The module currently only configures the networking hub, and dependent resources for the `Connectivity` Subscription.
> To ensure we achieve the right balance of managing resources via Terraform vs. Azure Policy, we are still working on how best to handle the creation of spoke Virtual Networks and Virtual Network Peering.
> Improving this story is our next priority on the product roadmap.

The following resource types are deployed and managed by this module when the Connectivity resources capabilities are enabled:

|     | Azure Resource | Terraform Resource |
| --- | -------------- | ------------------ |
| Resource Groups | [`Microsoft.Resources/resourceGroups`][arm_resource_group] | [`azurerm_resource_group`][azurerm_resource_group] |
| Virtual Networks | [`Microsoft.Network/virtualNetworks`][arm_virtual_network] | [`azurerm_virtual_network`][azurerm_virtual_network] |
| Subnets | [`Microsoft.Network/virtualNetworks/subnets`][arm_subnet] | [`azurerm_subnet`][azurerm_subnet] |
| Virtual Network Gateways | [`Microsoft.Network/virtualNetworkGateways`][arm_virtual_network_gateway] | [`azurerm_virtual_network_gateway`][azurerm_virtual_network_gateway] |
| Azure Firewalls | [`Microsoft.Network/azureFirewalls`][arm_firewall] | [`azurerm_firewall`][azurerm_firewall] |
| Public IP Addresses | [`Microsoft.Network/publicIPAddresses`][arm_public_ip] | [`azurerm_public_ip`][azurerm_public_ip] |
| DDoS Protection Plans | [`Microsoft.Network/ddosProtectionPlans`][arm_ddos_protection_plan] | [`azurerm_network_ddos_protection_plan`][azurerm_network_ddos_protection_plan] |
| DNS Zones (pending) | [`Microsoft.Network/dnsZones`][arm_dns_zone] | [`azurerm_dns_zone`][azurerm_dns_zone] |
| Virtual Network Peerings (pending) | [`Microsoft.Network/virtualNetworks/virtualNetworkPeerings`][arm_virtual_network_peering] | [`azurerm_virtual_network_peering`][azurerm_virtual_network_peering] |

Please refer to the [Deploy Connectivity Resources][wiki_deploy_connectivity_resources] page on our Wiki for more information about how to use this capability.

### Identity resources

From release `v0.4.0` onwards, the module includes new functionality to enable deployment of [Identity and access management][ESLZ-Identity] resources into the current Subscription context.

![Enterprise-scale Identity Landing Zone Architecture][TFAES-Identity]

No additional resources are deployed by this capability, however policy settings relating to the `Identity` Management Group can now be easily updated via the `configure_identity_resources` input variable.

Please refer to the [Deploy Identity Resources][wiki_deploy_identity_resources] page on our Wiki for more information about how to use this capability.

## Terraform versions

This module has been tested using Terraform `0.15.0` and AzureRM Provider `2.66.0` as a baseline, and various versions to up the most recent at the time of release.
In some cases, individual versions of the AzureRM provider may cause errors.
If this happens, we advise upgrading to the latest version and checking our [troubleshooting][wiki_troubleshooting] guide before [raising an issue](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/issues).


## Usage

As a basic starting point, we recommend starting with the following configuration in your root module.

This will deploy the core components only.

> **NOTE:** For production use we highly recommend using the Terraform Registry and pinning to the latest stable version, as per the example below.
> Pinning to the `main` branch in GitHub will give you the latest updates quicker, but increases the likelihood of unplanned changes to your environment and unforeseen issues.

**File: `main.tf`**

```hcl
# Configure Terraform to set the required AzureRM provider
# version and features{} block.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.66.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# Management Group.

data "azurerm_client_config" "core" {}

# Use variables to customise the deployment

variable "root_id" {
  type    = string
  default = "es"
}

variable "root_name" {
  type    = string
  default = "Enterprise-Scale"
}

# Declare the Terraform Module for Cloud Adoption Framework
# Enterprise-scale and provide a base configuration.

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "0.4.0"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name

}
```

> For additional guidance on how to customise your deployment using the advanced configuration options for this module, please refer to our [User Guide][wiki_user_guide] and the additional [examples][wiki_examples] in our documentation.

## Permissions

Please refer to our [Module Permissions][wiki_module_permissions] guide on the Wiki.

## Examples

Please refer to our [Examples][wiki_examples] guide on the Wiki.

## License

[MIT License][TFAES-LICENSE]

## Contributing

[Contributing Guide][TFAES-CONTRIBUTING]

 [//]: # (*****************************)
 [//]: # (INSERT IMAGE REFERENCES BELOW)
 [//]: # (*****************************)

[TFAES-Overview]:     https://raw.githubusercontent.com/wiki/Azure/terraform-azurerm-caf-enterprise-scale/media/terraform-caf-enterprise-scale-overview.png "Diagram showing the core Cloud Adoption Framework Enterprise-scale Landing Zone architecture deployed by this module."
[TFAES-Management]:   https://raw.githubusercontent.com/wiki/Azure/terraform-azurerm-caf-enterprise-scale/media/terraform-caf-enterprise-scale-management.png "Diagram showing the Management resources for Cloud Adoption Framework Enterprise-scale Landing Zone architecture deployed by this module."
[TFAES-Connectivity]: https://raw.githubusercontent.com/wiki/Azure/terraform-azurerm-caf-enterprise-scale/media/terraform-caf-enterprise-scale-connectivity.png "Diagram showing the Connectivity resources for Cloud Adoption Framework Enterprise-scale Landing Zone architecture deployed by this module."
[TFAES-Identity]:     https://raw.githubusercontent.com/wiki/Azure/terraform-azurerm-caf-enterprise-scale/media/terraform-caf-enterprise-scale-identity.png "Diagram showing the Identity resources for Cloud Adoption Framework Enterprise-scale Landing Zone architecture deployed by this module."

 [//]: # (************************)
 [//]: # (INSERT LINK LABELS BELOW)
 [//]: # (************************)

[terraform-registry-caf-enterprise-scale]: https://registry.terraform.io/modules/Azure/caf-enterprise-scale/azurerm/latest "Terraform Registry: Terraform Module for Cloud Adoption Framework Enterprise-scale"

[ESLZ-Architecture]: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/architecture
[ESLZ-Management]:   https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/management-and-monitoring
[ESLZ-Connectivity]: https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/network-topology-and-connectivity
[ESLZ-Identity]:     https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/identity-and-access-management

[arm_management_group]:               https://docs.microsoft.com/en-us/azure/templates/microsoft.management/managementgroups
[arm_management_group_subscriptions]: https://docs.microsoft.com/en-us/azure/templates/microsoft.management/managementgroups/subscriptions
[arm_policy_assignment]:              https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/policyassignments
[arm_policy_definition]:              https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/policydefinitions
[arm_policy_set_definition]:          https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/policysetdefinitions
[arm_role_assignment]:                https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments
[arm_role_definition]:                https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roledefinitions
[arm_resource_group]:                 https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/resourcegroups
[arm_log_analytics_workspace]:        https://docs.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces
[arm_log_analytics_solution]:         https://docs.microsoft.com/en-us/azure/templates/microsoft.operationsmanagement/solutions
[arm_automation_account]:             https://docs.microsoft.com/en-us/azure/templates/microsoft.automation/automationaccounts
[arm_log_analytics_linked_service]:   https://docs.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces/linkedservices
[arm_virtual_network]:                https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks
[arm_subnet]:                         https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/subnets
[arm_virtual_network_gateway]:        https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworkgateways
[arm_firewall]:                       https://docs.microsoft.com/en-us/azure/templates/microsoft.network/azurefirewalls
[arm_public_ip]:                      https://docs.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses
[arm_ddos_protection_plan]:           https://docs.microsoft.com/en-us/azure/templates/microsoft.network/ddosprotectionplans
[arm_dns_zone]:                       https://docs.microsoft.com/en-us/azure/templates/microsoft.network/dnszones
[arm_virtual_network_peering]:        https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks/virtualnetworkpeerings

[azurerm_management_group]:                   https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group
[azurerm_management_group_policy_assignment]: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment
[azurerm_policy_assignment]:                  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_assignment
[azurerm_policy_definition]:                  https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition
[azurerm_policy_set_definition]:              https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_set_definition
[azurerm_role_assignment]:                    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
[azurerm_role_definition]:                    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition
[azurerm_resource_group]:                     https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
[azurerm_log_analytics_workspace]:            https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
[azurerm_log_analytics_solution]:             https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution
[azurerm_automation_account]:                 https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account
[azurerm_log_analytics_linked_service]:       https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_service
[azurerm_virtual_network]:                    https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
[azurerm_subnet]:                             https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
[azurerm_virtual_network_gateway]:            https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway
[azurerm_firewall]:                           https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall
[azurerm_public_ip]:                          https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
[azurerm_network_ddos_protection_plan]:       https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_ddos_protection_plan
[azurerm_dns_zone]:                           https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone
[azurerm_virtual_network_peering]:            https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering

[TFAES-LICENSE]:      https://github.com/Azure/terraform-azurerm-enterprise-scale/blob/main/LICENSE
[TFAES-CONTRIBUTING]: https://github.com/Azure/terraform-azurerm-enterprise-scale/blob/main/CONTRIBUTING
[TFAES-Library]:      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/tree/main/modules/terraform-azurerm-caf-enterprise-scale-archetypes/lib

[release_notes_v0_3_0]: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/releases/tag/v0.3.0 "Release notes for v0.3.0"
[release_notes_v0_4_0]: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/releases/tag/v0.4.0 "Release notes for v0.4.0"

<!--
The following link references should be copied from `_sidebar.md` in the `./docs/wiki/` folder.
Replace `./` with `https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/` when copying to here.
-->

[wiki_home]:                                  https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Home "Wiki - Home"
[wiki_user_guide]:                            https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/User-Guide "Wiki - User Guide"
[wiki_getting_started]:                       https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Getting-Started "Wiki - Getting Started"
[wiki_module_permissions]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Module-Permissions "Wiki - Module Permissions"
[wiki_module_variables]:                      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Module-Variables "Wiki - Module Variables"
[wiki_provider_configuration]:                https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Provider-Configuration "Wiki - Provider Configuration"
[wiki_archetype_definitions]:                 https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Archetype-Definitions "Wiki - Archetype Definitions"
[wiki_core_resources]:                        https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Core-Resources "Wiki - Core Resources"
[wiki_management_resources]:                  https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Management-Resources "Wiki - Management Resources"
[wiki_connectivity_resources]:                https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Connectivity-Resources "Wiki - Connectivity Resources"
[wiki_identity_resources]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Identity-Resources "Wiki - Identity Resources"
[wiki_upgrade_from_v0_0_8_to_v0_1_0]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Upgrade-from-v0.0.8-to-v0.1.0 "Wiki - Upgrade from v0.0.8 to v0.1.0"
[wiki_upgrade_from_v0_1_2_to_v0_2_0]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Upgrade-from-v0.1.2-to-v0.2.0 "Wiki - Upgrade from v0.1.2 to v0.2.0"
[wiki_upgrade_from_v0_3_3_to_v0_4_0]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Upgrade-from-v0.3.3-to-v0.4.0 "Wiki - Upgrade from v0.3.3 to v0.4.0"
[wiki_examples]:                              https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Examples "Wiki - Examples"
[wiki_examples_level_100]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Examples#advanced-level-100 "Wiki - Examples"
[wiki_examples_level_200]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Examples#advanced-level-200 "Wiki - Examples"
[wiki_examples_level_300]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Examples#advanced-level-300 "Wiki - Examples"
[wiki_deploy_default_configuration]:          https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Default-Configuration "Wiki - Deploy Default Configuration"
[wiki_deploy_demo_landing_zone_archetypes]:   https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Demo-Landing-Zone-Archetypes "Wiki - Deploy Demo Landing Zone Archetypes"
[wiki_deploy_custom_landing_zone_archetypes]: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Custom-Landing-Zone-Archetypes "Wiki - Deploy Custom Landing Zone Archetypes"
[wiki_deploy_management_resources]:           https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Management-Resources "Wiki - Deploy Management Resources"
[wiki_deploy_management_resources_custom]:    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Management-Resources-With-Custom-Settings "Wiki - Deploy Management Resources With Custom Settings"
[wiki_deploy_connectivity_resources]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Connectivity-Resources "Wiki - Deploy Connectivity Resources"
[wiki_deploy_connectivity_resources_custom]:  https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Connectivity-Resources-With-Custom-Settings "Wiki - Deploy Connectivity Resources With Custom Settings"
[wiki_deploy_identity_resources]:             https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Identity-Resources "Wiki - Deploy Identity Resources"
[wiki_deploy_identity_resources_custom]:      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Identity-Resources-With-Custom-Settings "Wiki - Deploy Identity Resources With Custom Settings"
[wiki_deploy_using_module_nesting]:           https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Using-Module-Nesting "Wiki - Deploy Using Module Nesting"
[wiki_frequently_asked_questions]:            https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Frequently-Asked-Questions "Wiki - Frequently Asked Questions"
[wiki_troubleshooting]:                       https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Troubleshooting "Wiki - Troubleshooting"
[wiki_contributing]:                          https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Contributing "Wiki - Contributing"
[wiki_raising_an_issue]:                      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Raising-an-Issue "Wiki - Raising an Issue"
[wiki_feature_requests]:                      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Feature-Requests "Wiki - Feature Requests"
[wiki_contributing_to_code]:                  https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Contributing-to-Code "Wiki - Contributing to Code"
[wiki_contributing_to_documentation]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Contributing-to-Documentation "Wiki - Contributing to Documentation"
[wiki_expand_built_in_archetype_definitions]: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Expand-Built-in-Archetype-Definitions "Wiki - Expand Built-in Archetype Definitions"
[wiki_override_module_role_assignments]:      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Override-Module-Role-Assignments "Wiki - Override Module Role Assignments"
