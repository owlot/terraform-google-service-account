#######################################################################################################
#
# Terraform does not have a easy way to check if the input parameters are in the correct format.
# On top of that, terraform will sometimes produce a valid plan but then fail during apply.
# To handle these errors beforehad, we're using the 'file' hack to throw errors on known mistakes.
#
#######################################################################################################
locals {
  # Regular expressions
  regex_service_account_name = "[a-zA-Z0-9\\-\"' !:_]*"
  regex_service_account_id   = "[a-z](?:[-a-z0-9]{4,28}[a-z0-9])"

  # Terraform assertion hack
  assert_head = "\n\n-------------------------- /!\\ ASSERTION FAILED /!\\ --------------------------\n\n"
  assert_foot = "\n\n-------------------------- /!\\ ^^^^^^^^^^^^^^^^ /!\\ --------------------------\n"
  asserts = {
    for service_account, settings in local.service_accounts : service_account => merge({
      service_account_id_too_long   = length(settings.account_id) > 30 ? file(format("%sService Account [%s]'s generated id is too long:\n%s\n%s > 30 chars!%s", local.assert_head, service_account, settings.account_id, length(settings.account_id), local.assert_foot)) : "ok"
      service_account_id_regex      = length(regexall("^${local.regex_service_account_id}$", settings.account_id)) == 0 ? file(format("%sService Account [%s]'s generated id [%s] does not match regex ^%s$%s", local.assert_head, service_account, settings.account_id, local.regex_service_account_id, local.assert_foot)) : "ok"
      service_account_name_too_long = length(settings.display_name) > 100 ? file(format("%sService Account [%s]'s generated name is too long:\n%s\n%s > 100 chars!%s", local.assert_head, service_account, settings.display_name, length(settings.display_name), local.assert_foot)) : "ok"
      service_account_name_regex    = length(regexall("^${local.regex_service_account_name}$", settings.display_name)) == 0 ? file(format("%sService Account [%s]'s generated name [%s] does not match regex ^%s$%s", local.assert_head, service_account, settings.display_name, local.regex_service_account_name, local.assert_foot)) : "ok"
    })
  }
}
