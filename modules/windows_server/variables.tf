variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Azure resource ID for the subnet."
}

variable "script" {
  type    = string
  default = null

  validation {
    condition     = var.script == null || contains(["iis", "addc", "_null"], coalesce(var.script, "_null"))
    error_message = "The script type (files pulled from local.os). Must be set to either iis or addc."
  }
}
