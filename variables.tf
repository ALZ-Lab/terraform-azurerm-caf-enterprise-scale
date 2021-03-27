# The following variables are used to configure the default
# Enterprise-scale Management Groups.
#
# Further information provided within the description block
# for each variable

variable "root_parent_id" {
  type        = string
  description = "The root_parent_id is used to specify where to set the root for all Landing Zone deployments. Usually the Tenant ID when deploying the core Enterprise-scale Landing Zones."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_\\(\\)\\.]{1,36}$", var.root_parent_id))
    error_message = "Value must be a valid Management Group ID, consisting of alphanumeric characters, hyphens, underscores, periods and parentheses."
  }
}

variable "root_id" {
  type        = string
  description = "If specified, will set a custom Name (ID) value for the Enterprise-scale \"root\" Management Group, and append this to the ID for all core Enterprise-scale Management Groups."
  default     = "es"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{2,10}$", var.root_id))
    error_message = "Value must be between 2 to 10 characters long, consisting of alphanumeric characters and hyphens."
  }
}

variable "root_name" {
  type        = string
  description = "If specified, will set a custom Display Name value for the Enterprise-scale \"root\" Management Group."
  default     = "Enterprise-Scale"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9- ._]{1,22}[A-Za-z0-9]?$", var.root_name))
    error_message = "Value must be between 2 to 24 characters long, start with a letter, end with a letter or number, and can only contain space, hyphen, underscore or period characters."
  }
}

variable "deploy_core_landing_zones" {
  type        = bool
  description = "If set to true, module will deploy the core Enterprise-scale Management Group hierarchy, including \"out of the box\" policies and roles."
  default     = true
}

variable "deploy_demo_landing_zones" {
  type        = bool
  description = "If set to true, module will deploy the demo \"Landing Zone\" Management Groups (\"Corp\", \"Online\", and \"SAP\") into the core Enterprise-scale Management Group hierarchy."
  default     = false
}

variable "deploy_management_resources" {
  type = object({
    enabled = bool
    settings_log_analytics = object({
      enabled = bool
      config = object({
        retention_in_days                         = number
        enable_arc_monitoring                     = bool
        enable_vm_monitoring                      = bool
        enable_vmss_monitoring                    = bool
        enable_solution_for_AgentHealthAssessment = bool
        enable_solution_for_AntiMalware           = bool
        enable_solution_for_AzureActivity         = bool
        enable_solution_for_ChangeTracking        = bool
        enable_solution_for_ServiceMap            = bool
        enable_solution_for_SQLAssessment         = bool
        enable_solution_for_Updates               = bool
        enable_solution_for_VMInsights            = bool
        enable_sentinel                           = bool
      })
    })
    settings_security_center = object({
      enabled = bool
      config = object({
        enable_asc_for_acr          = bool
        enable_asc_for_app_services = bool
        enable_asc_for_arm          = bool
        enable_asc_for_dns          = bool
        enable_asc_for_key_vault    = bool
        enable_asc_for_kubernetes   = bool
        enable_asc_for_servers      = bool
        enable_asc_for_sql          = bool
        enable_asc_for_storage      = bool
      })
    })
    location = any
    tags     = any
    advanced = any
  })
  description = "If specified, will deploy the \"Management\" landing zone resources into the current Subscription context."
  default = {
    enabled = false
    settings_log_analytics = {
      enabled = true
      config = {
        retention_in_days                         = 30
        enable_arc_monitoring                     = true
        enable_vm_monitoring                      = true
        enable_vmss_monitoring                    = true
        enable_solution_for_AgentHealthAssessment = true
        enable_solution_for_AntiMalware           = true
        enable_solution_for_AzureActivity         = true
        enable_solution_for_ChangeTracking        = true
        enable_solution_for_ServiceMap            = true
        enable_solution_for_SQLAssessment         = true
        enable_solution_for_Updates               = true
        enable_solution_for_VMInsights            = true
        enable_sentinel                           = true
      }
    }
    settings_security_center = {
      enabled = true
      config = {
        enable_asc_for_acr          = true
        enable_asc_for_app_services = true
        enable_asc_for_arm          = true
        enable_asc_for_dns          = true
        enable_asc_for_key_vault    = true
        enable_asc_for_kubernetes   = true
        enable_asc_for_servers      = true
        enable_asc_for_sql          = true
        enable_asc_for_storage      = true
      }
    }
    location = null
    tags     = null
    advanced = null
  }
}

variable "archetype_config_overrides" {
  type        = map(any)
  description = "If specified, will set custom Archetype configurations to the default Enterprise-scale Management Groups."
  default     = {}
}

variable "subscription_id_overrides" {
  type        = map(list(string))
  description = "If specified, will be used to assign subscription_ids to the default Enterprise-scale Management Groups."
  default     = {}
}

variable "subscription_id_connectivity" {
  type        = string
  description = "If specified, identifies the Platform subscription for \"Connectivity\" for resource deployment and correct placement in the Management Group hierarchy."
  default     = ""

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.subscription_id_connectivity)) || var.subscription_id_connectivity == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "subscription_id_identity" {
  type        = string
  description = "If specified, identifies the Platform subscription for \"Identity\" for resource deployment and correct placement in the Management Group hierarchy."
  default     = ""

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.subscription_id_identity)) || var.subscription_id_identity == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "subscription_id_management" {
  type        = string
  description = "If specified, identifies the Platform subscription for \"Management\" for resource deployment and correct placement in the Management Group hierarchy."
  default     = ""

  validation {
    condition     = can(regex("^[a-z0-9-]{36}$", var.subscription_id_management)) || var.subscription_id_management == ""
    error_message = "Value must be a valid Subscription ID (GUID)."
  }
}

variable "custom_landing_zones" {
  type = map(
    object({
      display_name               = string
      parent_management_group_id = string
      subscription_ids           = list(string)
      archetype_config = object({
        archetype_id   = string
        parameters     = any
        access_control = any
      })
    })
  )
  description = "If specified, will deploy additional Management Groups alongside Enterprise-scale core Management Groups."
  default     = {}

  validation {
    condition     = can(regex("^[a-z0-9-]{2,36}$", keys(var.custom_landing_zones)[0])) || length(keys(var.custom_landing_zones)) == 0
    error_message = "The custom_landing_zones keys must be between 2 to 36 characters long and can only contain lowercase letters, numbers and hyphens."
  }
}

variable "library_path" {
  type        = string
  description = "If specified, sets the path to a custom library folder for archetype artefacts."
  default     = ""
}

variable "template_file_variables" {
  type        = map(any)
  description = "If specified, provides the ability to define custom template variables used when reading in template files from the built-in and custom library_path."
  default     = {}
}

variable "default_location" {
  type        = string
  description = "If specified, will use set the default location used for resource deployments where needed."
  default     = "eastus"

  # Need to add validation covering all Azure locations
}

variable "default_tags" {
  type        = map(string)
  description = "If specified, will set the default tags for all resources deployed by this module where supported."
  default     = {}
}

variable "create_duration_delay" {
  type        = map(string)
  description = "Used to tune terraform apply when faced with errors caused by API caching or eventual consistency. Sets a custom delay period after creation of the specified resource type."
  default = {
    azurerm_management_group      = "30s"
    azurerm_policy_assignment     = "30s"
    azurerm_policy_definition     = "30s"
    azurerm_policy_set_definition = "30s"
    azurerm_role_assignment       = "0s"
    azurerm_role_definition       = "60s"
  }

  validation {
    condition     = can([for v in values(var.create_duration_delay) : regex("^[0-9]{1,6}(s|m|h)$", v)])
    error_message = "The create_duration_delay values must be a string containing the duration in numbers (1-6 digits) followed by the measure of time represented by s (seconds), m (minutes), or h (hours)."
  }
}

variable "destroy_duration_delay" {
  type        = map(string)
  description = "Used to tune terraform deploy when faced with errors caused by API caching or eventual consistency. Sets a custom delay period after destruction of the specified resource type."
  default = {
    azurerm_management_group      = "0s"
    azurerm_policy_assignment     = "0s"
    azurerm_policy_definition     = "0s"
    azurerm_policy_set_definition = "0s"
    azurerm_role_assignment       = "0s"
    azurerm_role_definition       = "0s"
  }

  validation {
    condition     = can([for v in values(var.destroy_duration_delay) : regex("^[0-9]{1,6}(s|m|h)$", v)])
    error_message = "The destroy_duration_delay values must be a string containing the duration in numbers (1-6 digits) followed by the measure of time represented by s (seconds), m (minutes), or h (hours)."
  }
}
