#######################################################################################################
#
# Terraform does not have a easy way to check if the input parameters are in the correct format.
# On top of that, terraform will sometimes produce a valid plan but then fail during apply.
# To handle these errors beforehad, we're using the 'file' hack to throw errors on known mistakes.
#
#######################################################################################################
locals {
  # Regular expressions
  # regex_firewall_name = "(([a-z0-9]|[a-z0-9][a-z0-9\\-]*[a-z0-9])\\.)*([a-z0-9]|[a-z0-9][a-z0-9\\-]*[a-z0-9])" # See https://cloud.google.com/storage/docs/naming-firewalls

  # Terraform assertion hack
  assert_head = "\n\n-------------------------- /!\\ ASSERTION FAILED /!\\ --------------------------\n\n"
  assert_foot = "\n\n-------------------------- /!\\ ^^^^^^^^^^^^^^^^ /!\\ --------------------------\n"
  asserts = {
    for zone, settings in local.dns_zones : zone => merge({
      zonename_too_long = length(settings.name) > 63 ? file(format("%sDNS zone [%s]'s generated name is too long:\n%s\n%s > 63 chars!%s", local.assert_head, zone, settings.name, length(settings.name), local.assert_foot)) : "ok"
      zonename_fqdn     = length(regexall("\\.$", zone)) == 0 ? file(format("%sDNS zone [%s] does not end in a period - we want the FQDN with a period at the end! e.g. [%s.]\n%s", local.assert_head, zone, zone, local.assert_foot)) : "ok"
      # zone_private_config = settings.visibility == "private" && settings.private_visibility_config == null ? file(format("%sDNS zone [%s] is private but does not specify a private visibility config - please add!\n%s", local.assert_head, zone, local.assert_foot)) : "ok"
      keytest = {
        for setting in keys(settings) : setting => merge(
          {
            keytest = lookup(local.dns_zone_defaults, setting, "!TF_SETTINGTEST!") == "!TF_SETTINGTEST!" ? file(format("%sUnknown DNS zone variable assigned - zone [%s] defines [%q] -- Please check for typos etc!%s", local.assert_head, zone, setting, local.assert_foot)) : "ok"
        })
      }
    })
  }
  asserts2 = {
    for policy, settings in local.dns_policies : policy => merge({
      policyname_too_long = length(settings.name) > 63 ? file(format("%sDNS policy [%s]'s generated name is too long:\n%s\n%s > 63 chars!%s", local.assert_head, policy, settings.name, length(settings.name), local.assert_foot)) : "ok"
      keytest = {
        for setting in keys(settings) : setting => merge(
          {
            keytest = lookup(local.dns_policy_defaults, setting, "!TF_SETTINGTEST!") == "!TF_SETTINGTEST!" ? file(format("%sUnknown DNS policy variable assigned - policy [%s] defines [%q] -- Please check for typos etc!%s", local.assert_head, policy, setting, local.assert_foot)) : "ok"
        })
      }
    })
  }
}
