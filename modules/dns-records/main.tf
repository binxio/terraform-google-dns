#---------------------------------------------------------------------------------------------
# Define our locals for increased readability
#---------------------------------------------------------------------------------------------
locals {
  project     = var.project
  environment = var.environment

  module_dns_record_defaults = {
    name    = null
    zone    = null
    ttl     = 300
    type    = null
    rrdatas = []
  }

  dns_record_defaults = var.dns_record_defaults == null ? local.module_dns_record_defaults : merge(local.module_dns_record_defaults, var.dns_record_defaults)

  dns_records = {
    for r in var.dns_records : format("%s-%s-%s", r.zone, r.name, r.type) => merge(local.dns_record_defaults, r)
  }
  dns_records_zones = {
    for r in var.dns_records : format("%s-%s-%s", r.zone, r.name, r.type) => r.zone
  }
}

#---------------------------------------------------------------------------------------------
# GCP Resources
#---------------------------------------------------------------------------------------------
data "google_dns_managed_zone" "map" {
  for_each = local.dns_records_zones
  name     = each.value
  provider = google-beta
}

resource "google_dns_record_set" "map" {
  for_each = local.dns_records
  provider = google-beta

  name         = format("%s.%s", each.value.name, data.google_dns_managed_zone.map[format("%s-%s-%s", each.value.zone, each.value.name, each.value.type)].dns_name)
  managed_zone = each.value.zone
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas

  depends_on = [var.depends]
}
