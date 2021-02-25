locals {
  owner       = "myself"
  project     = var.project
  region      = "global"
  environment = var.environment

  vpc = {
    network_name = "dnstest"
  }
}

module "vpc" {
  source  = "binxio/network-vpc/google"
  version = "~> 1.0.0"

  owner       = local.owner
  project     = local.project
  environment = local.environment

  network_name = local.vpc.network_name
}
