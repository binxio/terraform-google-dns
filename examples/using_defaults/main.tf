locals {
  owner       = "myself"
  project     = "demo"
  environment = "dev"

  dns_zones = {
    "myzone.local." = {
      # Defaults to private zone!
    }
    "myzone.com." = {
      visibility = "public"
    }
  }
}

module "dns" {
  source  = "binxio/dns/google"
  version = "~> 1.0.0"

  owner       = local.owner
  project     = "demo"
  environment = "dev"

  dns_zones = local.dns_zones
}
