variable "root_id" {
  type        = string
  description = "Sets the value used for generating unique resource naming within the module."
  default     = "myorg"
}

variable "root_name" {
  type    = string
  default = "My Organization"
}

variable "primary_location" {
  type        = string
  description = "Sets the location for \"primary\" resources to be created in."
  default     = "northeurope"
}

variable "secondary_location" {
  type        = string
  description = "Sets the location for \"secondary\" resources to be created in."
  default     = "westeurope"
}

variable "subscription_id_connectivity" {
  type        = string
  description = "Subscription ID to use for \"connectivity\" resources."
  default     = ""
}

variable "subscription_id_identity" {
  type        = string
  description = "Subscription ID to use for \"identity\" resources."
  default     = ""
}

variable "subscription_id_management" {
  type        = string
  description = "Subscription ID to use for \"management\" resources."
  default     = ""
}

variable "deploy_connectivity_resources" {
  type        = bool
  description = "Controls whether to create \"connectivity\" resources."
  default     = true
}

variable "deploy_management_resources" {
  type        = bool
  description = "Controls whether to create \"management\" resources."
  default     = true
}

variable "email_security_contact" {
  type        = string
  description = "Set a custom value for the security contact email address."
  default     = "test.user@replace_me"
}

variable "log_retention_in_days" {
  type        = number
  description = "Set a custom value for the security contact email address."
  default     = 60
}

variable "enable_ddos_protection" {
  type        = bool
  description = "Controls whether to create a DDoS Network Protection plan and link to hub virtual networks."
  default     = true
}

variable "default_tags" {
  type = map(string)
  default = {
    deployedBy = "terraform/azure/caf-enterprise-scale/examples/l400-multi"
    demo_type  = "Deploy using multiple module declarations"
  }
}

variable "connectivity_resources_tags" {
  type = map(string)
  default = {
    demo_type = "Deploy connectivity resources using multiple module declarations"
  }
}

variable "management_resources_tags" {
  type = map(string)
  default = {
    demo_type = "Deploy management resources using multiple module declarations"
  }
}
