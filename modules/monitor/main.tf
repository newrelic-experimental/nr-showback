locals {
  showback_switch_statement =<<-EOT
  switch (true) {%{ for department in var.showback_config }%{ for account in department.accounts_in }
      case accountName === '${account}':%{ endfor ~}
      %{ for regex in department.accounts_regex }
      case (new RegExp('${regex}').test(accountName)):%{ endfor }
        department = '${department.department_name}';
        break;%{ endfor }
      default:
        break;
    }
  EOT

  showback_ignore_groups=trimspace(
    <<-EOT
    [ %{ for index_group, group in var.showback_ignore.groups }%{ if index_group != 0 }, %{ endif }
            "${group}"%{ endfor }
          ]
    EOT
  )

  templatefile_render = templatefile(
   "${path.module}/showback_script.tftpl",
    {
      NEW_RELIC_REGION = var.new_relic_region
      SHOWBACK_INSERT_ACCOUNT_ID = var.showback_insert_account_id
      SHOWBACK_SWITCH_STATEMENT = local.showback_switch_statement
      SHOWBACK_IGNORE_GROUP_ARRAY = local.showback_ignore_groups
      SHOWBACK_IGNORE_NEWRELIC_USERS = var.showback_ignore.newrelic_users
    }
  )
}

resource "newrelic_synthetics_script_monitor" "showback_monitor" {
  name                 = var.monitor_name
  type                 = "SCRIPT_API"
  locations_public     = ["US_EAST_1"]
  period               = "EVERY_DAY"
  status               = "ENABLED"
  script               = local.templatefile_render
  script_language      = "JAVASCRIPT"
  runtime_type         = "NODE_API"
  runtime_type_version = "16.10"
  tag {
    key = "terraform"
    values = [true]
  }
}

resource "newrelic_synthetics_secure_credential" "showback_insert_license_api_key" {
  key = "SHOWBACK_INSERT_LICENSE_API_KEY"
  value = var.showback_insert_license_api_key
  description = "NR Showback reporting insert license key for account: ${var.showback_insert_account_id}"
}

resource "newrelic_synthetics_secure_credential" "showback_query_user_api_key" {
  key = "SHOWBACK_QUERY_USER_API_KEY"
  value = var.showback_query_user_api_key
  description = "NR Showback reporting query user api key"
}

output "showback_switch_statement" {
  value = local.showback_switch_statement
}

output "showback_ignore_groups" {
  value = local.showback_ignore_groups
}
