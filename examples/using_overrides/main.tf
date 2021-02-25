locals {
  owner       = "myself"
  project     = "demo"
  environment = "dev"

  dns_policies = {
    "allow-onprem" = {
      enable_inbound_forwarding = true
      enable_logging            = true
      networks = {
        "myvpc" = module.vpc.vpc
      }
      alternative_name_server_config = {
        # Note that this kills off .internal lookups
        target_name_servers = {
          "onprem1" = {
            ipv4_address = "192.168.1.1"
          }
          "onprem2" = {
            ipv4_address = "192.168.1.2"
          }
        }
      }
    }
  }
  dns_zones = {
    "example.local." = {
      visibility = "private"
      private_visibility_config = {
        networks = {
          "myvpc" = module.vpc.vpc
        }
      }
      forwarding_config = {
        target_name_servers = {
          "onprem1" = {
            ipv4_address    = "192.168.1.1"
            forwarding_path = "private" # or default
          }
          "onprem2" = {
            ipv4_address    = "192.168.1.2"
            forwarding_path = "private"
          }
        }
      }
    }
    "prd.gcp.example.local." = {
      visibility = "private"
      private_visibility_config = {
        networks = {
          "myvpc" = module.vpc.vpc
        }
      }
    }
    "dev.gcp.example.local." = {
      visibility = "private"
      private_visibility_config = {
        networks = {
          "myvpc" = module.vpc.vpc
        }
      }
      peering_config = {
        target_network = {
          network_url = replace(module.vpc.vpc, "prd", "dev") # reference to other project's network
        }
      }
    }
    "servicedir.local." = {
      visibility = "private"
      service_directory_config = {
        namespace = {
          namespace_url = module.service_directory.self_link
        }
      }
    }
  }
  dns_records = [
    {
      name    = "localhost"
      type    = "A"
      zone    = "example-local-private"
      rrdatas = ["127.0.0.1"]
    }
  ]
}

module "dns" {
  source  = "binxio/dns/google"
  version = "~> 1.0.0"

  owner       = local.owner
  project     = "demo"
  environment = "dev"

  dns_zones = local.dns_zones
  dns_zone_defaults = merge(module.dns.dns_zone_defaults, {
    visibility = "private"
  })

  dns_policies = local.dns_policies
  dns_policy_defaults = merge(module.dns.dns_policy_defaults, {
    enable_logging = true
  })
}

module "dnsrecords" {
  source  = "binxio/dns/google//modules/dns-records"
  version = "~> 1.0.0"

  owner       = local.owner
  project     = "demo"
  environment = "dev"

  dns_records = local.dns_records
  dns_record_defaults = merge(module.dnsrecords.dns_record_defaults, {
    ttl = 60
  })
}
