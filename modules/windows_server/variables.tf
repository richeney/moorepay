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
  type = string

  default = null

  validation {
    condition     = contains(["iis", "addc"], var.script)
    error_message = "The script type (files pulled from local.os). Must be set to either iis or addc."
  }
}
