#######################################################################################################
#
# Terraform does not have a easy way to check if the input parameters are in the correct format.
# On top of that, terraform will sometimes produce a valid plan but then fail during apply.
# To handle these errors beforehad, we're using the 'file' hack to throw errors on known mistakes.
#
#######################################################################################################
locals {

  # Terraform assertion hack
  assert_head = "\n\n-------------------------- /!\\ ASSERTION FAILED /!\\ --------------------------\n\n"
  assert_foot = "\n\n-------------------------- /!\\ ^^^^^^^^^^^^^^^^ /!\\ --------------------------\n"

  asserts = {
    for record, settings in local.dns_records : record => merge({
      recordname_too_long = length(settings.name) > 63 ? file(format("%sDNS record [%s]'s generated name is too long:\n%s\n%s > 63 chars!%s", local.assert_head, record, settings.name, length(settings.name), local.assert_foot)) : "ok"
      zone_missing        = length(settings.zone == null ? "" : settings.zone) == 0 ? file(format("%sDNS record [%s]'s is missing a zone!\n%s", local.assert_head, record, local.assert_foot)) : "ok"
      keytest = {
        for setting in keys(settings) : setting => merge(
          {
            keytest = lookup(local.dns_record_defaults, setting, "!TF_SETTINGTEST!") == "!TF_SETTINGTEST!" ? file(format("%sUnknown DNS record variable assigned - record [%s] defines [%q] -- Please check for typos etc!%s", local.assert_head, record, setting, local.assert_foot)) : "ok"
        })
      }
    })
  }
}
