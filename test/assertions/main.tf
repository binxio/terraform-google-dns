locals {
  owner       = "myself"
  project     = var.project
  environment = var.environment
  dns_zones = {
    "no-period.local" = {
    }
    "weird.setting." = {
      foo = "bar"
    }
  }
  dns_records = [
    {
      name = "missing-zone-and-type"
    }
  ]
}

module "dns" {
  source = "../../"

  owner       = local.owner
  environment = local.environment
  project     = local.project

  dns_zones = local.dns_zones
}

module "dns-records" {
  source = "../../modules/dns-records"

  owner       = local.owner
  environment = local.environment
  project     = local.project

  dns_records = local.dns_records
}


output "dns" {
  value = module.dns
}
