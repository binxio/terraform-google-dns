output "name_servers" {
  description = "Delegate your managed_zone to these virtual name servers; defined by the server."
  value       = { for key, zone in google_dns_managed_zone.map : key => zone.name_servers }
}
output "dns_zone_defaults" {
  description = "Defaults for overriding without copy/pasting half the module"
  value       = local.module_dns_zone_defaults
}
output "dns_policy_defaults" {
  description = "Defaults for overriding without copy/pasting half the module"
  value       = local.module_dns_policy_defaults
}
