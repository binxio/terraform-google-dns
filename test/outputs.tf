output "vpc" {
  value = module.vpc.vpc
}

output "subnets" {
  value = module.vpc.map
}

output "vpc_vars" {
  value = local.vpc
}
