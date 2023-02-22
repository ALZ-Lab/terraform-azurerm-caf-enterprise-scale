<!-- BEGIN_TF_DOCS -->
# Azure landing zones Terraform module

[![Build Status](https://dev.azure.com/mscet/CAE-ALZ-Terraform/_apis/build/status/Tests/E2E?branchName=refs%2Ftags%2Fv3.2.0)](https://dev.azure.com/mscet/CAE-ALZ-Terraform/_build/latest?definitionId=26&branchName=refs%2Ftags%2Fv3.2.0)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/Azure/terraform-azurerm-caf-enterprise-scale?style=flat&logo=github)
[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/azure/terraform-azurerm-caf-enterprise-scale.svg)](http://isitmaintained.com/project/azure/terraform-azurerm-caf-enterprise-scale "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/azure/terraform-azurerm-caf-enterprise-scale.svg)](http://isitmaintained.com/project/azure/terraform-azurerm-caf-enterprise-scale "Percentage of issues still open")

Detailed information about how to use, configure and extend this module can be found on our Wiki:

- [Home][wiki\_home]
- [User Guide][wiki\_user\_guide]
- [Examples][wiki\_examples]
- [Frequently Asked Questions][wiki\_frequently\_asked\_questions]
- [Troubleshooting][wiki\_troubleshooting]
- [Contributing][wiki\_contributing]

## Overview

The [Azure landing zones Terraform module][alz\_tf\_registry] is designed to accelerate deployment of platform resources based on the [Azure landing zones conceptual architecture][alz\_architecture] using Terraform.

![A conceptual architecture diagram highlighting the design areas covered by the Azure landing zones Terraform module.][alz\_tf\_overview]

This is currently split logically into the following capabilities within the module (*links to further guidance on the Wiki*):

| Module capability | Scope | Design area |
| :--- | :--- | :--- |
| [Core Resources][wiki\_core\_resources] | Management group and subscription organization | [Resource organization][alz\_hierarchy] |
| [Management Resources][wiki\_management\_resources] | Management subscription | [Management][alz\_management] |
| [Connectivity Resources][wiki\_connectivity\_resources] | Connectivity subscription | [Network topology and connectivity][alz\_connectivity] |
| [Identity Resources][wiki\_identity\_resources] | Identity subscription | [Identity and access management][alz\_identity] |

Using a very [simple initial configuration](#maintf), the module will deploy a management group hierarchy based on the above diagram.
This includes the recommended governance baseline, applied using Azure Policy and Access control (IAM) resources deployed at the management group scope.
The default configuration can be easily extended to meet differing requirements, and includes the ability to deploy platform resources in the `management` and `connectivity` subscriptions.

> **NOTE:** In addition to setting input variables to control which resources are deployed, the module requires setting a [Provider Configuration][wiki\_provider\_configuration] block to enable deployment across multiple subscriptions.

Although resources are logically grouped to simplify operations, the modular design of the module also allows resources to be deployed using different Terraform workspaces.
This allows customers to address concerns around managing large state files, or assigning granular permissions to pipelines based on the principle of least privilege. (*more information coming soon in the Wiki*)

## Terraform versions

This module has been tested using Terraform `1.3.1` and AzureRM Provider `3.19.0` as a baseline, and various versions to up the latest at time of release.
In some cases, individual versions of the AzureRM provider may cause errors.
If this happens, we advise upgrading to the latest version and checking our [troubleshooting][wiki\_troubleshooting] guide before [raising an issue](https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/issues).

> **NOTE:** The module now requires a minimum Terraform version of `1.3.1` to support the GA release of [`optional()` Object Type Attributes](https://developer.hashicorp.com/terraform/language/expressions/type-constraints#optional-object-type-attributes) and the required fix for [issue #31844](https://github.com/hashicorp/terraform/issues/31844).

## Usage

We recommend starting with the following configuration in your root module to learn what resources are created by the module and how it works.

This will deploy the core components only.

> **NOTE:** For production use we highly recommend using the Terraform Registry and pinning to the latest stable version, as per the example below.
> Pinning to the `main` branch in GitHub will give you the latest updates quicker, but increases the likelihood of unplanned changes to your environment and unforeseen issues.

### `main.tf`

```hcl
# Configure Terraform to set the required AzureRM provider
# version and features{} block.

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints
    }
  }
}

provider "azurerm" {
  features {}
}

# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# management group.

data "azurerm_client_config" "core" {}

# Use variables to customize the deployment

variable "root_id" {
  type    = string
  default = "es"
}

variable "root_name" {
  type    = string
  default = "Enterprise-Scale"
}

# Declare the Azure landing zones Terraform module
# and provide a base configuration.

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "<version>" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

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

> **NOTE:** For additional guidance on how to customize your deployment using the advanced configuration options for this module, please refer to our [User Guide][wiki\_user\_guide] and the additional [examples][wiki\_examples] in our documentation.

## Permissions

Please refer to our [Module Permissions][wiki\_module\_permissions] guide on the Wiki.

## Examples

The following list outlines some of our most popular examples:

- [Examples - Level 100][wiki\_examples\_level\_100]
  - [Deploy Default Configuration][wiki\_deploy\_default\_configuration]
  - [Deploy Demo Landing Zone Archetypes][wiki\_deploy\_demo\_landing\_zone\_archetypes]
- [Examples - Level 200][wiki\_examples\_level\_200]
  - [Deploy Custom Landing Zone Archetypes][wiki\_deploy\_custom\_landing\_zone\_archetypes]
  - [Deploy Connectivity Resources][wiki\_deploy\_connectivity\_resources]
  - [Deploy Identity Resources][wiki\_deploy\_identity\_resources]
  - [Deploy Management Resources][wiki\_deploy\_management\_resources]
  - [Assign a Built-in Policy][wiki\_assign\_a\_built\_in\_policy]
- [Examples - Level 300][wiki\_examples\_level\_300]
  - [Deploy Connectivity Resources With Custom Settings][wiki\_deploy\_connectivity\_resources\_custom]
  - [Deploy Identity Resources With Custom Settings][wiki\_deploy\_identity\_resources\_custom]
  - [Deploy Management Resources With Custom Settings][wiki\_deploy\_management\_resources\_custom]
  - [Expand Built-in Archetype Definitions][wiki\_expand\_built\_in\_archetype\_definitions]
  - [Create Custom Policies, Policy Sets and Assignments][wiki\_create\_custom\_policies\_policy\_sets\_and\_assignments]

For the complete list of our latest examples, please refer to our [Examples][wiki\_examples] page on the Wiki.

## Release notes

Please see the [releases][repo\_releases] page for the latest module updates.

## Upgrade guides

For upgrade guides from previous versions, please refer to the following links:

- [Upgrade from v2.4.1 to v3.0.0][wiki\_upgrade\_from\_v2\_4\_1\_to\_v3\_0\_0]
- [Upgrade from v1.1.4 to v2.0.0][wiki\_upgrade\_from\_v1\_1\_4\_to\_v2\_0\_0]
- [Upgrade from v0.4.0 to v1.0.0][wiki\_upgrade\_from\_v0\_4\_0\_to\_v1\_0\_0]
- [Upgrade from v0.3.3 to v0.4.0][wiki\_upgrade\_from\_v0\_3\_3\_to\_v0\_4\_0]
- [Upgrade from v0.1.2 to v0.2.0][wiki\_upgrade\_from\_v0\_1\_2\_to\_v0\_2\_0]
- [Upgrade from v0.0.8 to v0.1.0][wiki\_upgrade\_from\_v0\_0\_8\_to\_v0\_1\_0]

## Documentation
<!-- markdownlint-disable MD033 -->

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.1)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.19.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.1.0)

- <a name="requirement_time"></a> [time](#requirement\_time) (>= 0.7.0)

## Modules

The following Modules are called:

### <a name="module_connectivity_resources"></a> [connectivity\_resources](#module\_connectivity\_resources)

Source: ./modules/connectivity

Version:

### <a name="module_identity_resources"></a> [identity\_resources](#module\_identity\_resources)

Source: ./modules/identity

Version:

### <a name="module_management_group_archetypes"></a> [management\_group\_archetypes](#module\_management\_group\_archetypes)

Source: ./modules/archetypes

Version:

### <a name="module_management_resources"></a> [management\_resources](#module\_management\_resources)

Source: ./modules/management

Version:

### <a name="module_role_assignments_for_policy"></a> [role\_assignments\_for\_policy](#module\_role\_assignments\_for\_policy)

Source: ./modules/role_assignments_for_policy

Version:

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_root_parent_id"></a> [root\_parent\_id](#input\_root\_parent\_id)

Description: The root\_parent\_id is used to specify where to set the root for all Landing Zone deployments. Usually the Tenant ID when deploying the core Enterprise-scale Landing Zones.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_archetype_config_overrides"></a> [archetype\_config\_overrides](#input\_archetype\_config\_overrides)

Description: If specified, will set custom Archetype configurations for the core ALZ Management Groups. Does not work for management groups specified by the 'custom\_landing\_zones' input variable.

Type: `any`

Default: `{}`

### <a name="input_configure_connectivity_resources"></a> [configure\_connectivity\_resources](#input\_configure\_connectivity\_resources)

Description: If specified, will customize the "Connectivity" landing zone settings and resources.

Type:

```hcl
object({
    settings = optional(object({
      hub_networks = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            address_space                = list(string)
            location                     = optional(string, "")
            link_to_ddos_protection_plan = optional(bool, false)
            dns_servers                  = optional(list(string), [])
            bgp_community                = optional(string, "")
            subnets = optional(list(
              object({
                name                      = string
                address_prefixes          = list(string)
                network_security_group_id = optional(string, "")
                route_table_id            = optional(string, "")
              })
            ), [])
            virtual_network_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                address_prefix           = optional(string, "")
                gateway_sku_expressroute = optional(string, "")
                gateway_sku_vpn          = optional(string, "")
                advanced_vpn_settings = optional(object({
                  enable_bgp                       = optional(bool, null)
                  active_active                    = optional(bool, null)
                  private_ip_address_allocation    = optional(string, "")
                  default_local_network_gateway_id = optional(string, "")
                  vpn_client_configuration = optional(list(
                    object({
                      address_space = list(string)
                      aad_tenant    = optional(string, null)
                      aad_audience  = optional(string, null)
                      aad_issuer    = optional(string, null)
                      root_certificate = optional(list(
                        object({
                          name             = string
                          public_cert_data = string
                        })
                      ), [])
                      revoked_certificate = optional(list(
                        object({
                          name             = string
                          public_cert_data = string
                        })
                      ), [])
                      radius_server_address = optional(string, null)
                      radius_server_secret  = optional(string, null)
                      vpn_client_protocols  = optional(list(string), null)
                      vpn_auth_types        = optional(list(string), null)
                    })
                  ), [])
                  bgp_settings = optional(list(
                    object({
                      asn         = optional(number, null)
                      peer_weight = optional(number, null)
                      peering_addresses = optional(list(
                        object({
                          ip_configuration_name = optional(string, null)
                          apipa_addresses       = optional(list(string), null)
                        })
                      ), [])
                    })
                  ), [])
                  custom_route = optional(list(
                    object({
                      address_prefixes = optional(list(string), [])
                    })
                  ), [])
                }), {})
              }), {})
            }), {})
            azure_firewall = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                address_prefix                = optional(string, "")
                enable_dns_proxy              = optional(bool, true)
                dns_servers                   = optional(list(string), [])
                sku_tier                      = optional(string, "Standard")
                base_policy_id                = optional(string, "")
                private_ip_ranges             = optional(list(string), [])
                threat_intelligence_mode      = optional(string, "Alert")
                threat_intelligence_allowlist = optional(list(string), [])
                availability_zones = optional(object({
                  zone_1 = optional(bool, true)
                  zone_2 = optional(bool, true)
                  zone_3 = optional(bool, true)
                }), {})
              }), {})
            }), {})
            spoke_virtual_network_resource_ids      = optional(list(string), [])
            enable_outbound_virtual_network_peering = optional(bool, false)
            enable_hub_network_mesh_peering         = optional(bool, false)
          })
        })
      ), [])
      vwan_hub_networks = optional(list(
        object({
          enabled = optional(bool, true)
          config = object({
            address_prefix = string
            location       = string
            sku            = optional(string, "")
            routes = optional(list(
              object({
                address_prefixes    = list(string)
                next_hop_ip_address = string
              })
            ), [])
            expressroute_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                scale_unit = optional(number, 1)
              }), {})
            }), {})
            vpn_gateway = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                bgp_settings = optional(list(
                  object({
                    asn         = number
                    peer_weight = number
                    instance_0_bgp_peering_address = optional(list(
                      object({
                        custom_ips = list(string)
                      })
                    ), [])
                    instance_1_bgp_peering_address = optional(list(
                      object({
                        custom_ips = list(string)
                      })
                    ), [])
                  })
                ), [])
                routing_preference = optional(string, "Microsoft Network")
                scale_unit         = optional(number, 1)
              }), {})
            }), {})
            azure_firewall = optional(object({
              enabled = optional(bool, false)
              config = optional(object({
                enable_dns_proxy              = optional(bool, true)
                dns_servers                   = optional(list(string), [])
                sku_tier                      = optional(string, "Standard")
                base_policy_id                = optional(string, "")
                private_ip_ranges             = optional(list(string), [])
                threat_intelligence_mode      = optional(string, "Alert")
                threat_intelligence_allowlist = optional(list(string), [])
                availability_zones = optional(object({
                  zone_1 = optional(bool, true)
                  zone_2 = optional(bool, true)
                  zone_3 = optional(bool, true)
                }), {})
              }), {})
            }), {})
            spoke_virtual_network_resource_ids        = optional(list(string), [])
            secure_spoke_virtual_network_resource_ids = optional(list(string), [])
            enable_virtual_hub_connections            = optional(bool, false)
          })
        })
      ), [])
      ddos_protection_plan = optional(object({
        enabled = optional(bool, false)
        config = optional(object({
          location = optional(string, "")
        }), {})
      }), {})
      dns = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          location = optional(string, "")
          enable_private_link_by_service = optional(object({
            azure_api_management                 = optional(bool, true)
            azure_app_configuration_stores       = optional(bool, true)
            azure_arc                            = optional(bool, true)
            azure_automation_dscandhybridworker  = optional(bool, true)
            azure_automation_webhook             = optional(bool, true)
            azure_backup                         = optional(bool, true)
            azure_batch_account                  = optional(bool, true)
            azure_bot_service_bot                = optional(bool, true)
            azure_bot_service_token              = optional(bool, true)
            azure_cache_for_redis                = optional(bool, true)
            azure_cache_for_redis_enterprise     = optional(bool, true)
            azure_container_registry             = optional(bool, true)
            azure_cosmos_db_cassandra            = optional(bool, true)
            azure_cosmos_db_gremlin              = optional(bool, true)
            azure_cosmos_db_mongodb              = optional(bool, true)
            azure_cosmos_db_sql                  = optional(bool, true)
            azure_cosmos_db_table                = optional(bool, true)
            azure_data_explorer                  = optional(bool, true)
            azure_data_factory                   = optional(bool, true)
            azure_data_factory_portal            = optional(bool, true)
            azure_data_health_data_services      = optional(bool, true)
            azure_data_lake_file_system_gen2     = optional(bool, true)
            azure_database_for_mariadb_server    = optional(bool, true)
            azure_database_for_mysql_server      = optional(bool, true)
            azure_database_for_postgresql_server = optional(bool, true)
            azure_digital_twins                  = optional(bool, true)
            azure_event_grid_domain              = optional(bool, true)
            azure_event_grid_topic               = optional(bool, true)
            azure_event_hubs_namespace           = optional(bool, true)
            azure_file_sync                      = optional(bool, true)
            azure_hdinsights                     = optional(bool, true)
            azure_iot_dps                        = optional(bool, true)
            azure_iot_hub                        = optional(bool, true)
            azure_key_vault                      = optional(bool, true)
            azure_key_vault_managed_hsm          = optional(bool, true)
            azure_kubernetes_service_management  = optional(bool, true)
            azure_machine_learning_workspace     = optional(bool, true)
            azure_managed_disks                  = optional(bool, true)
            azure_media_services                 = optional(bool, true)
            azure_migrate                        = optional(bool, true)
            azure_monitor                        = optional(bool, true)
            azure_purview_account                = optional(bool, true)
            azure_purview_studio                 = optional(bool, true)
            azure_relay_namespace                = optional(bool, true)
            azure_search_service                 = optional(bool, true)
            azure_service_bus_namespace          = optional(bool, true)
            azure_site_recovery                  = optional(bool, true)
            azure_sql_database_sqlserver         = optional(bool, true)
            azure_synapse_analytics_dev          = optional(bool, true)
            azure_synapse_analytics_sql          = optional(bool, true)
            azure_synapse_studio                 = optional(bool, true)
            azure_web_apps_sites                 = optional(bool, true)
            azure_web_apps_static_sites          = optional(bool, true)
            cognitive_services_account           = optional(bool, true)
            microsoft_power_bi                   = optional(bool, true)
            signalr                              = optional(bool, true)
            signalr_webpubsub                    = optional(bool, true)
            storage_account_blob                 = optional(bool, true)
            storage_account_file                 = optional(bool, true)
            storage_account_queue                = optional(bool, true)
            storage_account_table                = optional(bool, true)
            storage_account_web                  = optional(bool, true)
          }), {})
          private_link_locations                                 = optional(list(string), [])
          public_dns_zones                                       = optional(list(string), [])
          private_dns_zones                                      = optional(list(string), [])
          enable_private_dns_zone_virtual_network_link_on_hubs   = optional(bool, true)
          enable_private_dns_zone_virtual_network_link_on_spokes = optional(bool, true)
          virtual_network_resource_ids_to_link                   = optional(list(string), [])
        }), {})
      }), {})
    }), {})
    location = optional(string, "")
    tags     = optional(any, {})
    advanced = optional(any, {})
  })
```

Default:

```json
{
  "settings": {
    "ddos_protection_plan": {
      "config": {
        "location": ""
      },
      "enabled": false
    },
    "dns": {
      "config": {
        "enable_private_dns_zone_virtual_network_link_on_hubs": true,
        "enable_private_dns_zone_virtual_network_link_on_spokes": true,
        "enable_private_link_by_service": {
          "azure_api_management": true,
          "azure_app_configuration_stores": true,
          "azure_arc": true,
          "azure_automation_dscandhybridworker": true,
          "azure_automation_webhook": true,
          "azure_backup": true,
          "azure_batch_account": true,
          "azure_bot_service_bot": true,
          "azure_bot_service_token": true,
          "azure_cache_for_redis": true,
          "azure_cache_for_redis_enterprise": true,
          "azure_container_registry": true,
          "azure_cosmos_db_cassandra": true,
          "azure_cosmos_db_gremlin": true,
          "azure_cosmos_db_mongodb": true,
          "azure_cosmos_db_sql": true,
          "azure_cosmos_db_table": true,
          "azure_data_explorer": true,
          "azure_data_factory": true,
          "azure_data_factory_portal": true,
          "azure_data_health_data_services": true,
          "azure_data_lake_file_system_gen2": true,
          "azure_database_for_mariadb_server": true,
          "azure_database_for_mysql_server": true,
          "azure_database_for_postgresql_server": true,
          "azure_digital_twins": true,
          "azure_event_grid_domain": true,
          "azure_event_grid_topic": true,
          "azure_event_hubs_namespace": true,
          "azure_file_sync": true,
          "azure_hdinsights": true,
          "azure_iot_dps": true,
          "azure_iot_hub": true,
          "azure_key_vault": true,
          "azure_key_vault_managed_hsm": true,
          "azure_kubernetes_service_management": true,
          "azure_machine_learning_workspace": true,
          "azure_managed_disks": true,
          "azure_media_services": true,
          "azure_migrate": true,
          "azure_monitor": true,
          "azure_purview_account": true,
          "azure_purview_studio": true,
          "azure_relay_namespace": true,
          "azure_search_service": true,
          "azure_service_bus_namespace": true,
          "azure_site_recovery": true,
          "azure_sql_database_sqlserver": true,
          "azure_synapse_analytics_dev": true,
          "azure_synapse_analytics_sql": true,
          "azure_synapse_studio": true,
          "azure_web_apps_sites": true,
          "azure_web_apps_static_sites": true,
          "cognitive_services_account": true,
          "microsoft_power_bi": true,
          "signalr": true,
          "signalr_webpubsub": true,
          "storage_account_blob": true,
          "storage_account_file": true,
          "storage_account_queue": true,
          "storage_account_table": true,
          "storage_account_web": true
        },
        "location": "",
        "private_dns_zones": [],
        "private_link_locations": [],
        "public_dns_zones": [],
        "virtual_network_resource_ids_to_link": []
      },
      "enabled": true
    },
    "hub_networks": [
      {
        "config": {
          "address_space": [
            "10.100.0.0/16"
          ],
          "azure_firewall": {
            "config": {
              "address_prefix": "10.100.0.0/24",
              "availability_zones": {
                "zone_1": true,
                "zone_2": true,
                "zone_3": true
              },
              "base_policy_id": "",
              "dns_servers": [],
              "enable_dns_proxy": true,
              "private_ip_ranges": [],
              "sku_tier": "",
              "threat_intelligence_allowlist": [],
              "threat_intelligence_mode": ""
            },
            "enabled": false
          },
          "bgp_community": "",
          "dns_servers": [],
          "enable_hub_network_mesh_peering": false,
          "enable_outbound_virtual_network_peering": false,
          "link_to_ddos_protection_plan": false,
          "location": "",
          "spoke_virtual_network_resource_ids": [],
          "subnets": [],
          "virtual_network_gateway": {
            "config": {
              "address_prefix": "10.100.1.0/24",
              "advanced_vpn_settings": {
                "active_active": null,
                "bgp_settings": [],
                "custom_route": [],
                "default_local_network_gateway_id": "",
                "enable_bgp": null,
                "private_ip_address_allocation": "",
                "vpn_client_configuration": []
              },
              "gateway_sku_expressroute": "ErGw2AZ",
              "gateway_sku_vpn": "VpnGw3"
            },
            "enabled": false
          }
        },
        "enabled": true
      }
    ],
    "vwan_hub_networks": [
      {
        "config": {
          "address_prefix": "10.200.0.0/22",
          "azure_firewall": {
            "config": {
              "availability_zones": {
                "zone_1": true,
                "zone_2": true,
                "zone_3": true
              },
              "base_policy_id": "",
              "dns_servers": [],
              "enable_dns_proxy": false,
              "private_ip_ranges": [],
              "sku_tier": "Standard",
              "threat_intelligence_allowlist": [],
              "threat_intelligence_mode": ""
            },
            "enabled": false
          },
          "enable_virtual_hub_connections": false,
          "expressroute_gateway": {
            "config": {
              "scale_unit": 1
            },
            "enabled": false
          },
          "location": "",
          "routes": [],
          "secure_spoke_virtual_network_resource_ids": [],
          "sku": "",
          "spoke_virtual_network_resource_ids": [],
          "vpn_gateway": {
            "config": {
              "bgp_settings": [],
              "routing_preference": "",
              "scale_unit": 1
            },
            "enabled": false
          }
        },
        "enabled": false
      }
    ]
  }
}
```

### <a name="input_configure_identity_resources"></a> [configure\_identity\_resources](#input\_configure\_identity\_resources)

Description: If specified, will customize the "Identity" landing zone settings.

Type:

```hcl
object({
    settings = optional(object({
      identity = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          enable_deny_public_ip             = optional(bool, true)
          enable_deny_rdp_from_internet     = optional(bool, true)
          enable_deny_subnet_without_nsg    = optional(bool, true)
          enable_deploy_azure_backup_on_vms = optional(bool, true)
        }), {})
      }), {})
    }), {})
  })
```

Default:

```json
{
  "settings": {
    "identity": {
      "config": {
        "enable_deny_public_ip": true,
        "enable_deny_rdp_from_internet": true,
        "enable_deny_subnet_without_nsg": true,
        "enable_deploy_azure_backup_on_vms": true
      },
      "enabled": true
    }
  }
}
```

### <a name="input_configure_management_resources"></a> [configure\_management\_resources](#input\_configure\_management\_resources)

Description: If specified, will customize the "Management" landing zone settings and resources.

Type:

```hcl
object({
    settings = optional(object({
      log_analytics = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          retention_in_days                                 = optional(number, 30)
          enable_monitoring_for_vm                          = optional(bool, true)
          enable_monitoring_for_vmss                        = optional(bool, true)
          enable_solution_for_agent_health_assessment       = optional(bool, true)
          enable_solution_for_anti_malware                  = optional(bool, true)
          enable_solution_for_change_tracking               = optional(bool, true)
          enable_solution_for_service_map                   = optional(bool, true)
          enable_solution_for_sql_assessment                = optional(bool, true)
          enable_solution_for_sql_vulnerability_assessment  = optional(bool, true)
          enable_solution_for_sql_advanced_threat_detection = optional(bool, true)
          enable_solution_for_updates                       = optional(bool, true)
          enable_solution_for_vm_insights                   = optional(bool, true)
          enable_sentinel                                   = optional(bool, true)
        }), {})
      }), {})
      security_center = optional(object({
        enabled = optional(bool, true)
        config = optional(object({
          email_security_contact             = optional(string, "security_contact@replace_me")
          enable_defender_for_app_services   = optional(bool, true)
          enable_defender_for_arm            = optional(bool, true)
          enable_defender_for_containers     = optional(bool, true)
          enable_defender_for_dns            = optional(bool, true)
          enable_defender_for_key_vault      = optional(bool, true)
          enable_defender_for_oss_databases  = optional(bool, true)
          enable_defender_for_servers        = optional(bool, true)
          enable_defender_for_sql_servers    = optional(bool, true)
          enable_defender_for_sql_server_vms = optional(bool, true)
          enable_defender_for_storage        = optional(bool, true)
        }), {})
      }), {})
    }), {})
    location = optional(string, "")
    tags     = optional(any, {})
    advanced = optional(any, {})
  })
```

Default:

```json
{
  "settings": {
    "log_analytics": {
      "config": {
        "enable_monitoring_for_vm": true,
        "enable_monitoring_for_vmss": true,
        "enable_sentinel": true,
        "enable_solution_for_agent_health_assessment": true,
        "enable_solution_for_anti_malware": true,
        "enable_solution_for_change_tracking": true,
        "enable_solution_for_service_map": true,
        "enable_solution_for_sql_advanced_threat_detection": true,
        "enable_solution_for_sql_assessment": true,
        "enable_solution_for_sql_vulnerability_assessment": true,
        "enable_solution_for_updates": true,
        "enable_solution_for_vm_insights": true,
        "retention_in_days": 30
      },
      "enabled": true
    },
    "security_center": {
      "config": {
        "email_security_contact": "security_contact@replace_me",
        "enable_defender_for_app_services": true,
        "enable_defender_for_arm": true,
        "enable_defender_for_containers": true,
        "enable_defender_for_dns": true,
        "enable_defender_for_key_vault": true,
        "enable_defender_for_oss_databases": true,
        "enable_defender_for_servers": true,
        "enable_defender_for_sql_server_vms": true,
        "enable_defender_for_sql_servers": true,
        "enable_defender_for_storage": true
      },
      "enabled": true
    }
  }
}
```

### <a name="input_create_duration_delay"></a> [create\_duration\_delay](#input\_create\_duration\_delay)

Description: Used to tune terraform apply when faced with errors caused by API caching or eventual consistency. Sets a custom delay period after creation of the specified resource type.

Type:

```hcl
object({
    azurerm_management_group      = optional(string, "30s")
    azurerm_policy_assignment     = optional(string, "30s")
    azurerm_policy_definition     = optional(string, "30s")
    azurerm_policy_set_definition = optional(string, "30s")
    azurerm_role_assignment       = optional(string, "0s")
    azurerm_role_definition       = optional(string, "60s")
  })
```

Default:

```json
{
  "azurerm_management_group": "30s",
  "azurerm_policy_assignment": "30s",
  "azurerm_policy_definition": "30s",
  "azurerm_policy_set_definition": "30s",
  "azurerm_role_assignment": "0s",
  "azurerm_role_definition": "60s"
}
```

### <a name="input_custom_landing_zones"></a> [custom\_landing\_zones](#input\_custom\_landing\_zones)

Description: If specified, will deploy additional Management Groups alongside Enterprise-scale core Management Groups.

Type: `any`

Default: `{}`

### <a name="input_custom_policy_roles"></a> [custom\_policy\_roles](#input\_custom\_policy\_roles)

Description: If specified, the custom\_policy\_roles variable overrides which Role Definition ID(s) (value) to assign for Policy Assignments with a Managed Identity, if the assigned "policyDefinitionId" (key) is included in this variable.

Type: `map(list(string))`

Default: `{}`

### <a name="input_default_location"></a> [default\_location](#input\_default\_location)

Description: If specified, will set the Azure region in which region bound resources will be deployed. Please see: https://azure.microsoft.com/en-gb/global-infrastructure/geographies/

Type: `string`

Default: `"eastus"`

### <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags)

Description: If specified, will set the default tags for all resources deployed by this module where supported.

Type: `map(string)`

Default: `{}`

### <a name="input_deploy_connectivity_resources"></a> [deploy\_connectivity\_resources](#input\_deploy\_connectivity\_resources)

Description: If set to true, will enable the "Connectivity" landing zone settings and add "Connectivity" resources into the current Subscription context.

Type: `bool`

Default: `false`

### <a name="input_deploy_core_landing_zones"></a> [deploy\_core\_landing\_zones](#input\_deploy\_core\_landing\_zones)

Description: If set to true, module will deploy the core Enterprise-scale Management Group hierarchy, including "out of the box" policies and roles.

Type: `bool`

Default: `true`

### <a name="input_deploy_corp_landing_zones"></a> [deploy\_corp\_landing\_zones](#input\_deploy\_corp\_landing\_zones)

Description: If set to true, module will deploy the "Corp" Management Group, including "out of the box" policies and roles.

Type: `bool`

Default: `false`

### <a name="input_deploy_demo_landing_zones"></a> [deploy\_demo\_landing\_zones](#input\_deploy\_demo\_landing\_zones)

Description: If set to true, module will deploy the demo "Landing Zone" Management Groups ("Corp", "Online", and "SAP") into the core Enterprise-scale Management Group hierarchy.

Type: `bool`

Default: `false`

### <a name="input_deploy_identity_resources"></a> [deploy\_identity\_resources](#input\_deploy\_identity\_resources)

Description: If set to true, will enable the "Identity" landing zone settings.

Type: `bool`

Default: `false`

### <a name="input_deploy_management_resources"></a> [deploy\_management\_resources](#input\_deploy\_management\_resources)

Description: If set to true, will enable the "Management" landing zone settings and add "Management" resources into the current Subscription context.

Type: `bool`

Default: `false`

### <a name="input_deploy_online_landing_zones"></a> [deploy\_online\_landing\_zones](#input\_deploy\_online\_landing\_zones)

Description: If set to true, module will deploy the "Online" Management Group, including "out of the box" policies and roles.

Type: `bool`

Default: `false`

### <a name="input_deploy_sap_landing_zones"></a> [deploy\_sap\_landing\_zones](#input\_deploy\_sap\_landing\_zones)

Description: If set to true, module will deploy the "SAP" Management Group, including "out of the box" policies and roles.

Type: `bool`

Default: `false`

### <a name="input_destroy_duration_delay"></a> [destroy\_duration\_delay](#input\_destroy\_duration\_delay)

Description: Used to tune terraform deploy when faced with errors caused by API caching or eventual consistency. Sets a custom delay period after destruction of the specified resource type.

Type:

```hcl
object({
    azurerm_management_group      = optional(string, "0s")
    azurerm_policy_assignment     = optional(string, "0s")
    azurerm_policy_definition     = optional(string, "0s")
    azurerm_policy_set_definition = optional(string, "0s")
    azurerm_role_assignment       = optional(string, "0s")
    azurerm_role_definition       = optional(string, "0s")
  })
```

Default:

```json
{
  "azurerm_management_group": "0s",
  "azurerm_policy_assignment": "0s",
  "azurerm_policy_definition": "0s",
  "azurerm_policy_set_definition": "0s",
  "azurerm_role_assignment": "0s",
  "azurerm_role_definition": "0s"
}
```

### <a name="input_disable_base_module_tags"></a> [disable\_base\_module\_tags](#input\_disable\_base\_module\_tags)

Description: If set to true, will remove the base module tags applied to all resources deployed by the module which support tags.

Type: `bool`

Default: `false`

### <a name="input_disable_telemetry"></a> [disable\_telemetry](#input\_disable\_telemetry)

Description: If set to true, will disable telemetry for the module. See https://aka.ms/alz-terraform-module-telemetry.

Type: `bool`

Default: `false`

### <a name="input_library_path"></a> [library\_path](#input\_library\_path)

Description: If specified, sets the path to a custom library folder for archetype artefacts.

Type: `string`

Default: `""`

### <a name="input_policy_non_compliance_message_default"></a> [policy\_non\_compliance\_message\_default](#input\_policy\_non\_compliance\_message\_default)

Description: If set overrides the default non-compliance message used for policy assignments.

Type: `string`

Default: `"This resource {enforcementMode} be compliant with the assigned policy."`

### <a name="input_policy_non_compliance_message_default_enabled"></a> [policy\_non\_compliance\_message\_default\_enabled](#input\_policy\_non\_compliance\_message\_default\_enabled)

Description: If set to true, will enable the use of the default custom non-compliance messages for policy assignments if they are not provided.

Type: `bool`

Default: `true`

### <a name="input_policy_non_compliance_message_enabled"></a> [policy\_non\_compliance\_message\_enabled](#input\_policy\_non\_compliance\_message\_enabled)

Description: If set to false, will disable non-compliance messages altogether.

Type: `bool`

Default: `true`

### <a name="input_policy_non_compliance_message_enforced_replacement"></a> [policy\_non\_compliance\_message\_enforced\_replacement](#input\_policy\_non\_compliance\_message\_enforced\_replacement)

Description: If set overrides the non-compliance replacement used for enforced policy assignments.

Type: `string`

Default: `"must"`

### <a name="input_policy_non_compliance_message_enforcement_placeholder"></a> [policy\_non\_compliance\_message\_enforcement\_placeholder](#input\_policy\_non\_compliance\_message\_enforcement\_placeholder)

Description: If set overrides the non-compliance message placeholder used in message templates.

Type: `string`

Default: `"{enforcementMode}"`

### <a name="input_policy_non_compliance_message_not_enforced_replacement"></a> [policy\_non\_compliance\_message\_not\_enforced\_replacement](#input\_policy\_non\_compliance\_message\_not\_enforced\_replacement)

Description: If set overrides the non-compliance replacement used for unenforced policy assignments.

Type: `string`

Default: `"should"`

### <a name="input_policy_non_compliance_message_not_supported_definitions"></a> [policy\_non\_compliance\_message\_not\_supported\_definitions](#input\_policy\_non\_compliance\_message\_not\_supported\_definitions)

Description: If set, overrides the list of built-in policy definition that do not support non-compliance messages.

Type: `list(string)`

Default:

```json
[
  "/providers/Microsoft.Authorization/policyDefinitions/1c6e92c9-99f0-4e55-9cf2-0c234dc48f99",
  "/providers/Microsoft.Authorization/policyDefinitions/1a5b4dca-0b6f-4cf5-907c-56316bc1bf3d",
  "/providers/Microsoft.Authorization/policyDefinitions/95edb821-ddaf-4404-9732-666045e056b4"
]
```

### <a name="input_root_id"></a> [root\_id](#input\_root\_id)

Description: If specified, will set a custom Name (ID) value for the Enterprise-scale "root" Management Group, and append this to the ID for all core Enterprise-scale Management Groups.

Type: `string`

Default: `"es"`

### <a name="input_root_name"></a> [root\_name](#input\_root\_name)

Description: If specified, will set a custom Display Name value for the Enterprise-scale "root" Management Group.

Type: `string`

Default: `"Enterprise-Scale"`

### <a name="input_strict_subscription_association"></a> [strict\_subscription\_association](#input\_strict\_subscription\_association)

Description: If set to true, subscriptions associated to management groups will be exclusively set by the module and any added by another process will be removed. If set to false, the module will will only enforce association of the specified subscriptions and those added to management groups by other processes will not be removed.

Type: `bool`

Default: `true`

### <a name="input_subscription_id_connectivity"></a> [subscription\_id\_connectivity](#input\_subscription\_id\_connectivity)

Description: If specified, identifies the Platform subscription for "Connectivity" for resource deployment and correct placement in the Management Group hierarchy.

Type: `string`

Default: `""`

### <a name="input_subscription_id_identity"></a> [subscription\_id\_identity](#input\_subscription\_id\_identity)

Description: If specified, identifies the Platform subscription for "Identity" for resource deployment and correct placement in the Management Group hierarchy.

Type: `string`

Default: `""`

### <a name="input_subscription_id_management"></a> [subscription\_id\_management](#input\_subscription\_id\_management)

Description: If specified, identifies the Platform subscription for "Management" for resource deployment and correct placement in the Management Group hierarchy.

Type: `string`

Default: `""`

### <a name="input_subscription_id_overrides"></a> [subscription\_id\_overrides](#input\_subscription\_id\_overrides)

Description: If specified, will be used to assign subscription\_ids to the default Enterprise-scale Management Groups.

Type: `map(list(string))`

Default: `{}`

### <a name="input_template_file_variables"></a> [template\_file\_variables](#input\_template\_file\_variables)

Description: If specified, provides the ability to define custom template variables used when reading in template files from the built-in and custom library\_path.

Type: `any`

Default: `{}`

## Resources

The following resources are used by this module:

- [azurerm_automation_account.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account) (resource)
- [azurerm_dns_zone.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) (resource)
- [azurerm_express_route_gateway.virtual_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_gateway) (resource)
- [azurerm_firewall.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) (resource)
- [azurerm_firewall.virtual_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) (resource)
- [azurerm_firewall_policy.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) (resource)
- [azurerm_firewall_policy.virtual_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall_policy) (resource)
- [azurerm_log_analytics_linked_service.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_service) (resource)
- [azurerm_log_analytics_solution.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) (resource)
- [azurerm_log_analytics_workspace.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_management_group.level_1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) (resource)
- [azurerm_management_group.level_2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) (resource)
- [azurerm_management_group.level_3](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) (resource)
- [azurerm_management_group.level_4](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) (resource)
- [azurerm_management_group.level_5](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) (resource)
- [azurerm_management_group.level_6](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group) (resource)
- [azurerm_management_group_policy_assignment.enterprise_scale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_policy_assignment) (resource)
- [azurerm_management_group_subscription_association.enterprise_scale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_group_subscription_association) (resource)
- [azurerm_network_ddos_protection_plan.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_ddos_protection_plan) (resource)
- [azurerm_policy_definition.enterprise_scale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) (resource)
- [azurerm_policy_set_definition.enterprise_scale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_set_definition) (resource)
- [azurerm_private_dns_zone.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) (resource)
- [azurerm_private_dns_zone_virtual_network_link.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) (resource)
- [azurerm_public_ip.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) (resource)
- [azurerm_resource_group.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_resource_group.management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_resource_group.virtual_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_role_assignment.enterprise_scale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.policy_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_definition.enterprise_scale](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) (resource)
- [azurerm_subnet.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) (resource)
- [azurerm_subscription_template_deployment.telemetry_connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_template_deployment) (resource)
- [azurerm_subscription_template_deployment.telemetry_core](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_template_deployment) (resource)
- [azurerm_subscription_template_deployment.telemetry_identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_template_deployment) (resource)
- [azurerm_subscription_template_deployment.telemetry_management](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_template_deployment) (resource)
- [azurerm_virtual_hub.virtual_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub) (resource)
- [azurerm_virtual_hub_connection.virtual_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_connection) (resource)
- [azurerm_virtual_network.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) (resource)
- [azurerm_virtual_network_gateway.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) (resource)
- [azurerm_virtual_network_peering.connectivity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) (resource)
- [azurerm_virtual_wan.virtual_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_wan) (resource)
- [azurerm_vpn_gateway.virtual_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [time_sleep.after_azurerm_management_group](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.after_azurerm_policy_assignment](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.after_azurerm_policy_definition](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.after_azurerm_policy_set_definition](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.after_azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [time_sleep.after_azurerm_role_definition](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) (resource)
- [azurerm_policy_definition.external_lookup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) (data source)
- [azurerm_policy_set_definition.external_lookup](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_set_definition) (data source)

## Outputs

The following outputs are exported:

### <a name="output_azurerm_automation_account"></a> [azurerm\_automation\_account](#output\_azurerm\_automation\_account)

Description: Returns the configuration data for all Automation Accounts created by this module.

### <a name="output_azurerm_dns_zone"></a> [azurerm\_dns\_zone](#output\_azurerm\_dns\_zone)

Description: Returns the configuration data for all DNS Zones created by this module.

### <a name="output_azurerm_express_route_gateway"></a> [azurerm\_express\_route\_gateway](#output\_azurerm\_express\_route\_gateway)

Description: Returns the configuration data for all (Virtual WAN) ExpressRoute Gateways created by this module.

### <a name="output_azurerm_firewall"></a> [azurerm\_firewall](#output\_azurerm\_firewall)

Description: Returns the configuration data for all Azure Firewalls created by this module.

### <a name="output_azurerm_firewall_policy"></a> [azurerm\_firewall\_policy](#output\_azurerm\_firewall\_policy)

Description: Returns the configuration data for all Azure Firewall Policies created by this module.

### <a name="output_azurerm_log_analytics_linked_service"></a> [azurerm\_log\_analytics\_linked\_service](#output\_azurerm\_log\_analytics\_linked\_service)

Description: Returns the configuration data for all Log Analytics linked services created by this module.

### <a name="output_azurerm_log_analytics_solution"></a> [azurerm\_log\_analytics\_solution](#output\_azurerm\_log\_analytics\_solution)

Description: Returns the configuration data for all Log Analytics solutions created by this module.

### <a name="output_azurerm_log_analytics_workspace"></a> [azurerm\_log\_analytics\_workspace](#output\_azurerm\_log\_analytics\_workspace)

Description: Returns the configuration data for all Log Analytics workspaces created by this module.

### <a name="output_azurerm_management_group"></a> [azurerm\_management\_group](#output\_azurerm\_management\_group)

Description: Returns the configuration data for all Management Groups created by this module.

### <a name="output_azurerm_management_group_policy_assignment"></a> [azurerm\_management\_group\_policy\_assignment](#output\_azurerm\_management\_group\_policy\_assignment)

Description: Returns the configuration data for all Management Group Policy Assignments created by this module.

### <a name="output_azurerm_management_group_subscription_association"></a> [azurerm\_management\_group\_subscription\_association](#output\_azurerm\_management\_group\_subscription\_association)

Description: Returns the configuration data for all Management Group Subscription Associations created by this module.

### <a name="output_azurerm_network_ddos_protection_plan"></a> [azurerm\_network\_ddos\_protection\_plan](#output\_azurerm\_network\_ddos\_protection\_plan)

Description: Returns the configuration data for all DDoS Protection Plans created by this module.

### <a name="output_azurerm_policy_definition"></a> [azurerm\_policy\_definition](#output\_azurerm\_policy\_definition)

Description: Returns the configuration data for all Policy Definitions created by this module.

### <a name="output_azurerm_policy_set_definition"></a> [azurerm\_policy\_set\_definition](#output\_azurerm\_policy\_set\_definition)

Description: Returns the configuration data for all Policy Set Definitions created by this module.

### <a name="output_azurerm_private_dns_zone"></a> [azurerm\_private\_dns\_zone](#output\_azurerm\_private\_dns\_zone)

Description: Returns the configuration data for all Private DNS Zones created by this module.

### <a name="output_azurerm_private_dns_zone_virtual_network_link"></a> [azurerm\_private\_dns\_zone\_virtual\_network\_link](#output\_azurerm\_private\_dns\_zone\_virtual\_network\_link)

Description: Returns the configuration data for all Private DNS Zone network links created by this module.

### <a name="output_azurerm_public_ip"></a> [azurerm\_public\_ip](#output\_azurerm\_public\_ip)

Description: Returns the configuration data for all Public IPs created by this module.

### <a name="output_azurerm_resource_group"></a> [azurerm\_resource\_group](#output\_azurerm\_resource\_group)

Description: Returns the configuration data for all Resource Groups created by this module.

### <a name="output_azurerm_role_assignment"></a> [azurerm\_role\_assignment](#output\_azurerm\_role\_assignment)

Description: Returns the configuration data for all Role Assignments created by this module.

### <a name="output_azurerm_role_definition"></a> [azurerm\_role\_definition](#output\_azurerm\_role\_definition)

Description: Returns the configuration data for all Role Definitions created by this module.

### <a name="output_azurerm_subnet"></a> [azurerm\_subnet](#output\_azurerm\_subnet)

Description: Returns the configuration data for all Subnets created by this module.

### <a name="output_azurerm_virtual_hub"></a> [azurerm\_virtual\_hub](#output\_azurerm\_virtual\_hub)

Description: Returns the configuration data for all Virtual Hubs created by this module.

### <a name="output_azurerm_virtual_hub_connection"></a> [azurerm\_virtual\_hub\_connection](#output\_azurerm\_virtual\_hub\_connection)

Description: Returns the configuration data for all Virtual Hub Connections created by this module.

### <a name="output_azurerm_virtual_network"></a> [azurerm\_virtual\_network](#output\_azurerm\_virtual\_network)

Description: Returns the configuration data for all Virtual Networks created by this module.

### <a name="output_azurerm_virtual_network_gateway"></a> [azurerm\_virtual\_network\_gateway](#output\_azurerm\_virtual\_network\_gateway)

Description: Returns the configuration data for all Virtual Network Gateways created by this module.

### <a name="output_azurerm_virtual_network_peering"></a> [azurerm\_virtual\_network\_peering](#output\_azurerm\_virtual\_network\_peering)

Description: Returns the configuration data for all Virtual Network Peerings created by this module.

### <a name="output_azurerm_virtual_wan"></a> [azurerm\_virtual\_wan](#output\_azurerm\_virtual\_wan)

Description: Returns the configuration data for all Virtual WANs created by this module.

### <a name="output_azurerm_vpn_gateway"></a> [azurerm\_vpn\_gateway](#output\_azurerm\_vpn\_gateway)

Description: Returns the configuration data for all (Virtual WAN) VPN Gateways created by this module.

<!-- markdownlint-enable -->
## Telemetry

> **NOTE:** The following statement is applicable from release v2.0.0 onwards

When you deploy one or more modules using the Azure landing zones Terraform module, Microsoft can identify the installation of said module/s with the deployed Azure resources.
Microsoft can correlate these resources used to support the software.
Microsoft collects this information to provide the best experiences with their products and to operate their business.
The telemetry is collected through customer usage attribution.
The data is collected and governed by [Microsoft's privacy policies][msft\_privacy\_policy].

If you don't wish to send usage data to Microsoft, details on how to turn it off can be found [here][wiki\_disable\_telemetry].

## License

- [MIT License][alz\_license]

## Contributing

- [Contributing][wiki\_contributing]
  - [Raising an Issue][wiki\_raising\_an\_issue]
  - [Feature Requests][wiki\_feature\_requests]
  - [Contributing to Code][wiki\_contributing\_to\_code]
  - [Contributing to Documentation][wiki\_contributing\_to\_documentation]

[alz\_tf\_overview]: https://raw.githubusercontent.com/wiki/Azure/terraform-azurerm-caf-enterprise-scale/media/alz-tf-module-overview.png "A conceptual architecture diagram highlighting the design areas covered by the Azure landing zones Terraform module."

 [//]: # (************************)
 [//]: # (INSERT LINK LABELS BELOW)
 [//]: # (************************)

[msft\_privacy\_policy]: https://www.microsoft.com/trustcenter  "Microsoft's privacy policy"

[alz\_tf\_registry]:  https://registry.terraform.io/modules/Azure/caf-enterprise-scale/azurerm/latest "Terraform Registry: Azure landing zones Terraform module"
[alz\_architecture]: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone#azure-landing-zone-conceptual-architecture
[alz\_hierarchy]:    https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/resource-org
[alz\_management]:   https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/management
[alz\_connectivity]: https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/network-topology-and-connectivity
[alz\_identity]:     https://learn.microsoft.com/azure/cloud-adoption-framework/ready/landing-zone/design-area/identity-access
[alz\_license]:      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/blob/main/LICENSE
[repo\_releases]:    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/releases "Release notes"

<!--
The following link references should be copied from `_sidebar.md` in the `./docs/wiki/` folder.
Replace `./` with `https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/` when copying to here.
-->

[wiki\_home]:                                  https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Home "Wiki - Home"
[wiki\_user\_guide]:                            https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/User-Guide "Wiki - User Guide"
[wiki\_module\_permissions]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Module-Permissions "Wiki - Module Permissions"
[wiki\_provider\_configuration]:                https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Provider-Configuration "Wiki - Provider Configuration"
[wiki\_core\_resources]:                        https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Core-Resources "Wiki - Core Resources"
[wiki\_management\_resources]:                  https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Management-Resources "Wiki - Management Resources"
[wiki\_connectivity\_resources]:                https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Connectivity-Resources "Wiki - Connectivity Resources"
[wiki\_identity\_resources]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Identity-Resources "Wiki - Identity Resources"
[wiki\_upgrade\_from\_v0\_0\_8\_to\_v0\_1\_0]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Upgrade-from-v0.0.8-to-v0.1.0 "Wiki - Upgrade from v0.0.8 to v0.1.0"
[wiki\_upgrade\_from\_v0\_1\_2\_to\_v0\_2\_0]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Upgrade-from-v0.1.2-to-v0.2.0 "Wiki - Upgrade from v0.1.2 to v0.2.0"
[wiki\_upgrade\_from\_v0\_3\_3\_to\_v0\_4\_0]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Upgrade-from-v0.3.3-to-v0.4.0 "Wiki - Upgrade from v0.3.3 to v0.4.0"
[wiki\_upgrade\_from\_v0\_4\_0\_to\_v1\_0\_0]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Upgrade-from-v0.4.0-to-v1.0.0 "Wiki - Upgrade from v0.4.0 to v1.0.0"
[wiki\_upgrade\_from\_v1\_1\_4\_to\_v2\_0\_0]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Upgrade-from-v1.1.4-to-v2.0.0 "Wiki - Upgrade from v1.1.4 to v2.0.0"
[wiki\_upgrade\_from\_v2\_4\_1\_to\_v3\_0\_0]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BUser-Guide%5D-Upgrade-from-v2.4.1-to-v3.0.0 "Wiki - Upgrade from v2.4.1 to v3.0.0"
[wiki\_examples]:                              https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Examples "Wiki - Examples"
[wiki\_examples\_level\_100]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Examples#advanced-level-100 "Wiki - Examples"
[wiki\_examples\_level\_200]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Examples#advanced-level-200 "Wiki - Examples"
[wiki\_examples\_level\_300]:                    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Examples#advanced-level-300 "Wiki - Examples"
[wiki\_deploy\_default\_configuration]:          https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Default-Configuration "Wiki - Deploy Default Configuration"
[wiki\_deploy\_demo\_landing\_zone\_archetypes]:   https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Demo-Landing-Zone-Archetypes "Wiki - Deploy Demo Landing Zone Archetypes"
[wiki\_deploy\_custom\_landing\_zone\_archetypes]: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Custom-Landing-Zone-Archetypes "Wiki - Deploy Custom Landing Zone Archetypes"
[wiki\_deploy\_management\_resources]:           https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Management-Resources "Wiki - Deploy Management Resources"
[wiki\_deploy\_management\_resources\_custom]:    https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Management-Resources-With-Custom-Settings "Wiki - Deploy Management Resources With Custom Settings"
[wiki\_deploy\_connectivity\_resources]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Connectivity-Resources "Wiki - Deploy Connectivity Resources"
[wiki\_deploy\_connectivity\_resources\_custom]:  https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Connectivity-Resources-With-Custom-Settings "Wiki - Deploy Connectivity Resources With Custom Settings"
[wiki\_deploy\_identity\_resources]:             https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Identity-Resources "Wiki - Deploy Identity Resources"
[wiki\_deploy\_identity\_resources\_custom]:      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Deploy-Identity-Resources-With-Custom-Settings "Wiki - Deploy Identity Resources With Custom Settings"
[wiki\_frequently\_asked\_questions]:            https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Frequently-Asked-Questions "Wiki - Frequently Asked Questions"
[wiki\_troubleshooting]:                       https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Troubleshooting "Wiki - Troubleshooting"
[wiki\_contributing]:                          https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Contributing "Wiki - Contributing"
[wiki\_raising\_an\_issue]:                      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Raising-an-Issue "Wiki - Raising an Issue"
[wiki\_feature\_requests]:                      https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Feature-Requests "Wiki - Feature Requests"
[wiki\_contributing\_to\_code]:                  https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Contributing-to-Code "Wiki - Contributing to Code"
[wiki\_contributing\_to\_documentation]:         https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/Contributing-to-Documentation "Wiki - Contributing to Documentation"
[wiki\_expand\_built\_in\_archetype\_definitions]: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Expand-Built-in-Archetype-Definitions "Wiki - Expand Built-in Archetype Definitions"
[wiki\_create\_custom\_policies\_policy\_sets\_and\_assignments]: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Create-Custom-Policies-Policy-Sets-and-Assignments "Wiki - Create Custom Policies, Policy Sets and Assignments"
[wiki\_assign\_a\_built\_in\_policy]: https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BExamples%5D-Assign-a-Built-in-Policy "Wiki - Assign a Built-in Policy"
[wiki\_disable\_telemetry]:                     https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/wiki/%5BVariables%5D-disable_telemetry "Wiki - Disable telemetry"
<!-- END_TF_DOCS -->
