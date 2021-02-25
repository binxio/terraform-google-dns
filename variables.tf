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
variable "dns_zones" {
  description = "Map of dns zones and their configurations"
  type        = any
  default     = {}
}

variable "dns_policies" {
  description = "DNS Policies for your VPC(s)"
  type        = any
  default     = {}
}

variable "dns_policy_defaults" {
  type = object({
    enable_inbound_forwarding = bool
    enable_logging            = bool
    networks                  = map(string)
    alternative_name_server_config = object({
      target_name_servers = map(object({
        ipv4_address = string
      }))
    })
  })
  default = null
}

variable "dns_zone_defaults" {
  type = object({
    owner = string
    # The zone's visibility: public zones are exposed to the Internet, while private zones are visible only to Virtual Private Cloud resources. Must be one of: public, private.
    visibility = string
    # For privately visible zones, the set of Virtual Private Cloud resources that the zone is visible from.
    private_visibility_config = object({
      networks = map(string)
    })
    # The presence for this field indicates that outbound forwarding is enabled for this zone. The value of this field contains the set of destinations to forward to.
    forwarding_config = object({
      target_name_servers = map(object({
        ipv4_address    = string
        forwarding_path = string
      }))
    })
    # The presence of this field indicates that DNS Peering is enabled for this zone. The value of this field contains the network to peer with.
    peering_config = object({
      target_network = map(object({
        network_url = string
      }))
    })
    # DNSSEC configuration
    dnssec_config = map(object({
      kind          = string
      non_existence = string
      state         = string
      default_key_specs = map(object({
        algorithm  = string
        key_length = string
        key_type   = string
        kind       = string
      }))
    }))
    # Service Directory configuration
    service_directory_config = object({
      namespace = object({
        namespace_url = string
      })
    })
  })
  default = null
}
