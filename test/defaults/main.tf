locals {
  owner       = "myself"
  project     = var.project
  environment = var.environment
  dns_zones   = {}
  dns_records = {}
}

module "dns" {
  source = "../../"

  owner       = local.owner
  environment = local.environment
  project     = local.project

  dns_zones = local.dns_zones
}

output "dns" {
  value = module.dns
}

module "dns-records" {
  source = "../../modules/dns-records/"

  owner       = local.owner
  environment = local.environment
  project     = local.project

  dns_records = local.dns_records
}

output "dns-records" {
  value = module.dns-records
}
