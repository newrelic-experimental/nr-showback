# Use a templatefile. For dashboards with many replacement values this is cleaner than using replace().
locals {
  unique_tiers = distinct([
    for department in var.showback_config : department.tier
  ])

  unique_accounts = distinct(flatten([
    for department in var.showback_config : [
      for account in department.accounts_in : account
    ]
  ]))

  templatefile_render = templatefile(
   "${path.module}/dashboards/dashboard.json.tftpl",
    {
      tf_showback_config = var.showback_config
      tf_dashboard_name = var.dashboard_name
      tf_event_name_prefix = var.event_name_prefix
      tf_metric_name_prefix = var.metric_name_prefix
      tf_account_id = var.showback_insert_account_id
      tf_core_user_usd = var.showback_price.core_user_usd
      tf_full_user_usd = var.showback_price.full_user_usd
      tf_gb_ingest_usd = var.showback_price.gb_ingest_usd
      tf_unique_tiers = local.unique_tiers
      tf_unique_accounts = local.unique_accounts
    }
  )
}

resource "newrelic_one_dashboard_json" "templatefile_dashboard" {
  json = local.templatefile_render
}

# Tag terraform managed dashboards
resource "newrelic_entity_tags" "templatefile_dashboard" {
  guid = newrelic_one_dashboard_json.templatefile_dashboard.guid
  tag {
    key = "terraform"
    values = [true]
  }
}

output "templatefile_dashboard" {
  value=newrelic_one_dashboard_json.templatefile_dashboard.permalink 
}

output "unique_tiers" {
  value = distinct([
    for department in var.showback_config : department.tier
  ])
}

output "unique_accounts" {
  value = distinct(flatten([
    for department in var.showback_config : [
      for account in department.accounts_in : account
    ]
  ]))
}
