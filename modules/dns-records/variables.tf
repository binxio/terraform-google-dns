#------------------------------------------------------------------------------------------------------------------------
# 
# Generic variables
#
#------------------------------------------------------------------------------------------------------------------------
variable "owner" {
  description = "Owner of the resource. This variable is used to set the 'owner' label. Will be used as default for each subnet, but can be overridden using the subnet settings."
  type        = string
}

variable "project" {
  description = "Company project name."
  type        = string
}

variable "environment" {
  description = "Company environment for which the resources are created (e.g. dev, tst, acc, prd, all)."
  type        = string
}

#------------------------------------------------------------------------------------------------------------------------
#
# DNS resources variables
#
#------------------------------------------------------------------------------------------------------------------------

variable "dns_records" {
  # dns_records = [{ name = "mysubdomain", zone = "myzone-private", type = "A"; rrdata = ["a","b","c"]; ttl = 3600 }]
  type    = any
  default = {}
}

variable "dns_record_defaults" {
  type = object({
    name    = string
    zone    = string
    ttl     = number
    type    = string
    rrdatas = list(string)
  })
  default = null
}

variable "depends" {
  type        = any
  description = "Terraform does not support module's to depends_on, this variable fixes that"
  default     = []
}
