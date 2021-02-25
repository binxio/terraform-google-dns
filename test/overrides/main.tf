locals {
  owner       = "myself"
  project     = var.project
  environment = var.environment
  dns_zone_defaults_test = merge(module.dns_defaults.dns_zone_defaults, {
    private_visibility_config = {
      networks = {
        "myvpc" = var.test_vpc
      }
    }
  })
  dns_policy_defaults_test = merge(module.dns_defaults.dns_policy_defaults, {
    networks = {
      "myvpc" = var.test_vpc
    }
  })
  dns_record_defaults_test = merge(module.dns_records_defaults.dns_record_defaults, {
    rrdatas = ["127.0.0.1"]
  })
  dns_records = [
    {
      name    = "do-not"
      zone    = "forward-me-private"
      type    = "TXT"
      rrdatas = ["Look.at.the.name"]
    }
  ]
  dns_zones = {
    "forward.me." = {
      visibility = "private"
      forwarding_config = {
        target_name_servers = {
          "onprem1" = {
            ipv4_address    = "192.168.1.1"
            forwarding_path = "private"
          }
          "onprem2" = {
            ipv4_address    = "192.168.1.2"
            forwarding_path = "private"
          }
        }
      }
    }
  }
  dns_policies = {
    # Can only test 1 policy against a VPC, so unless we create more than 1 we can't test multiple policies....
    #"onprem-forward" = {
    #  enable_inbound_forwarding = true
    #}
    "onprem-alternative" = {
      enable_logging = true
      #networks = {
      #	myvpc = var.othervpc
      #}
      alternative_name_server_config = {
        target_name_servers = {
          "onprem1" = {
            ipv4_address = "192.168.1.1"
          }
        }
      }
    }
  }
}

module "dns_defaults" {
  source = "../../"

  owner       = local.owner
  environment = local.environment
  project     = local.project
}

module "dns" {
  source = "../../"

  owner       = local.owner
  environment = local.environment
  project     = local.project

  dns_zones           = local.dns_zones
  dns_policies        = local.dns_policies
  dns_zone_defaults   = local.dns_zone_defaults_test
  dns_policy_defaults = local.dns_policy_defaults_test
}

module "dns_records_defaults" {
  source = "../../modules/dns-records/"

  owner       = local.owner
  environment = local.environment
  project     = local.project
}

output "dns" {
  value = module.dns
}
