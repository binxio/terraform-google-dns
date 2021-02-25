#---------------------------------------------------------------------------------------------
# Define our locals for increased readability
#---------------------------------------------------------------------------------------------

locals {
  project     = var.project
  environment = var.environment
  owner       = var.owner

  # Startpoint for our dns policy and -zone defaults
  module_dns_policy_defaults = {
    name                           = ""
    enable_inbound_forwarding      = false
    enable_logging                 = false
    networks                       = null
    alternative_name_server_config = null
  }
  module_dns_zone_defaults = {
    owner                     = var.owner
    visibility                = "private"
    private_visibility_config = null
    forwarding_config         = null
    peering_config            = null
    dnssec_config             = {}
    service_directory_config  = null
    name                      = ""
    description               = ""
  }

  # Merge defaults with module defaults and user provided variables
  dns_zone_defaults   = var.dns_zone_defaults == null ? local.module_dns_zone_defaults : merge(local.module_dns_zone_defaults, var.dns_zone_defaults)
  dns_policy_defaults = var.dns_policy_defaults == null ? local.module_dns_policy_defaults : merge(local.module_dns_policy_defaults, var.dns_policy_defaults)

  labels = {
    "creator"     = "terraform"
    "project"     = substr(replace(lower(local.project), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
    "environment" = substr(replace(lower(local.environment), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
    "owner"       = substr(replace(lower(local.owner), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
  }

  # Merge dns zone global default settings with zone specific settings and generate name
  dns_zones = {
    for zone, settings in var.dns_zones : zone => merge(local.dns_zone_defaults, settings, {
      name        = replace(format("%s-%s", replace(substr(zone, 0, length(zone) - 1), ".", "-"), lookup(settings, "visibility", local.dns_zone_defaults.visibility)), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "-")
      description = format("TF Managed Zone: %s (%s)", lower(zone), lower(lookup(settings, "visibility", local.dns_zone_defaults.visibility)))
    })
  }
  dns_policies = {
    for policy, settings in var.dns_policies : policy => merge(local.dns_policy_defaults, settings, {
      name = replace(format("%s", replace(policy, ".", "-")), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "-")
    })
  }
}

#---------------------------------------------------------------------------------------------
# GCP Resources
#---------------------------------------------------------------------------------------------

resource "google_dns_managed_zone" "map" {
  for_each = local.dns_zones
  provider = google-beta

  dns_name    = each.key
  name        = each.value.name
  description = each.value.description
  visibility  = each.value.visibility

  labels = merge(
    local.labels, {
      owner = substr(replace(lower(each.value.owner), "/[^\\p{Ll}\\p{Lo}\\p{N}_-]+/", "_"), 0, 63)
    }
  )

  dynamic "dnssec_config" {
    # Only allow setting dnssec_config when local.visibility is set to 'public'
    for_each = (each.value.visibility == "public" ? each.value.dnssec_config : {})

    content {
      kind          = dnssec_config.value.kind
      non_existence = dnssec_config.value.non_existence
      state         = dnssec_config.value.state

      dynamic "default_key_specs" {
        for_each = dnssec_config.value.default_key_specs

        content {
          algorithm  = default_key_specs.value.algorithm
          key_length = default_key_specs.value.key_length
          key_type   = default_key_specs.value.key_type
          kind       = default_key_specs.value.kind
        }
      }
    }
  }

  dynamic "private_visibility_config" {
    # Only allow setting private_visibility_config when local.visibility is set to 'private'
    for_each = (each.value.visibility == "private" ? (each.value.private_visibility_config == null ? {} : each.value.private_visibility_config) : {})

    content {
      dynamic "networks" {
        for_each = private_visibility_config.value

        content {
          network_url = networks.value
        }
      }
    }
  }

  dynamic "peering_config" {
    for_each = (each.value.peering_config == null ? {} : each.value.peering_config)
    content {
      target_network {
        network_url = peering_config.value.network_url
      }
    }
  }

  dynamic "forwarding_config" {
    for_each = (each.value.forwarding_config == null ? {} : each.value.forwarding_config)
    content {
      dynamic "target_name_servers" {
        for_each = forwarding_config.value
        content {
          ipv4_address    = target_name_servers.value.ipv4_address
          forwarding_path = lookup(target_name_servers.value, "forwarding_path", null)
        }
      }
    }
  }

  dynamic "service_directory_config" {
    for_each = (each.value.visibility == "private" ? (each.value.service_directory_config == null ? {} : each.value.service_directory_config) : {})
    content {
      dynamic "namespace" {
        for_each = service_directory_config.value
        content {
          namespace_url = namespace.value
        }
      }
    }
  }
}

resource "google_dns_policy" "map" {
  for_each = local.dns_policies
  provider = google-beta

  name                      = each.value.name
  enable_inbound_forwarding = each.value.enable_inbound_forwarding
  enable_logging            = each.value.enable_logging
  dynamic "networks" {
    for_each = (each.value.networks == null ? {} : each.value.networks)
    content {
      network_url = networks.value # .network_url if user needs to be more verbose
    }
  }
  dynamic "alternative_name_server_config" {
    for_each = (each.value.alternative_name_server_config == null ? {} : each.value.alternative_name_server_config)
    content {
      dynamic "target_name_servers" {
        for_each = alternative_name_server_config.value
        content {
          ipv4_address = target_name_servers.value.ipv4_address
        }
      }
    }
  }
}

