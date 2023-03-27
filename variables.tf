#------------------------------------------------------------------------------------------------------------------------
#
# Generic variables
#
#------------------------------------------------------------------------------------------------------------------------
variable "owner" {
  description = "Company owner name"
  type        = string
}

variable "project" {
  description = "Company project name"
  type        = string
}

variable "environment" {
  description = "Company environment for which the resources are created (e.g. dev, tst, dmo, stg, prd, all)."
  type        = string
}

variable "region" {
  description = "Company region for which the resources are created (e.g. global, us, eu, asia)."
  type        = string
}

variable "gcp_project" {
  description = "GCP Project ID override - this is normally not needed and should only be used in specific cases."
  type        = string
  default     = null
}

#------------------------------------------------------------------------------------------------------------------------
#
# Service account variables
#
#------------------------------------------------------------------------------------------------------------------------

variable "service_accounts" {
  description = "Map of accounts to be created. The key will be used for the SA name so it should describe the SA purpose. A list of roles can be provided to set an authoritive iam policy for the service account."

  type = map(object({
    description = optional(string, null)
    roles = optional(map(object({
      members = map(string)
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string, null)
      }))
    })))
  }))
}
