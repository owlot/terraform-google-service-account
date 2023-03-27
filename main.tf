locals {
  project     = var.project
  environment = var.environment
  owner       = var.owner

  # Check if we want to deploy to a specific gcp_project or not.
  gcp_project = (var.gcp_project == null ? null : (length(var.gcp_project) > 0 ? var.gcp_project : null))

  service_accounts = { for sa, settings in var.service_accounts : sa =>
    merge(settings,
      {
        account_id   = replace(sa, "/[^\\p{Ll}\\p{Lo}\\p{N}-]+/", "-")
        display_name = title(format("Terraform Managed SA: %s %s %s %s", local.owner, local.environment, local.project, sa))
        roles = { for role, role_settings in try(settings.roles, {}) : (length(regexall("^roles/", role)) > 0 ? role : format("roles/%s", role)) =>
          merge(role_settings,
            {
              members = [for member, type in role_settings.members : format("%s:%s", type, member)]
            }
          )
        }
      }
    )
  }
}

resource "google_service_account" "map" {
  project  = local.gcp_project
  for_each = local.service_accounts

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
}

data "google_iam_policy" "map" {
  for_each = { for service_account, settings in local.service_accounts : service_account => settings if settings.roles != null }

  dynamic "binding" {
    for_each = each.value.roles

    content {
      role    = binding.key
      members = binding.value.members
      dynamic "condition" {
        for_each = binding.value.condition != null ? [binding.value.condition] : []
        content {
          expression  = condition.value.expression
          title       = condition.value.title
          description = try(condition.value.description, null)
        }
      }
    }
  }
}

resource "google_service_account_iam_policy" "map" {
  for_each = data.google_iam_policy.map

  service_account_id = google_service_account.map[each.key].name
  policy_data        = each.value.policy_data
}
