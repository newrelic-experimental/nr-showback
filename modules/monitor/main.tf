locals {
  templatefile_render = templatefile(
   "${path.module}/showback_script.tftpl",
    {
      tf_new_relic_region = var.new_relic_region
      tf_showback_insert_account_id = var.showback_insert_account_id
      tf_showback_ignore_groups = var.showback_ignore.groups
      tf_showback_ignore_newrelic_users = var.showback_ignore.newrelic_users
      tf_showback_config = var.showback_config
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

output "showback_ignore_newrelic_users" {
  value = var.showback_ignore.newrelic_users
}

output "showback_ignore_groups" {
  value = var.showback_ignore.groups
}
