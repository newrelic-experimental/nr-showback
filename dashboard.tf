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

  # Determine which metrics need WITH subqueries (max 3 due to NRQL limit)
  # A metric needs WITH if it has tiered pricing with different rates
  needs_with_core_users = var.showback_price.min_core_users > 0 && coalesce(var.showback_price.core_user_committed_usd, 0) != coalesce(var.showback_price.core_user_additional_usd, 0)

  needs_with_full_users = var.showback_price.min_full_users > 0 && coalesce(var.showback_price.full_user_committed_usd, 0) != coalesce(var.showback_price.full_user_additional_usd, 0)

  needs_with_ingest = var.showback_price.min_gb_ingest > 0

  needs_with_synth = var.showback_price.synthetics_checks_included > 0

  needs_with_accu = coalesce(var.showback_price.min_accu, 0) > 0 && coalesce(var.showback_price.accu_committed_usd, 0) != coalesce(var.showback_price.accu_additional_usd, 0)

  # Count total WITH subqueries needed
  with_count = (local.needs_with_core_users ? 1 : 0) + (local.needs_with_full_users ? 1 : 0) + (local.needs_with_ingest ? 1 : 0) + (local.needs_with_synth ? 1 : 0) + (local.needs_with_accu ? 1 : 0)

  templatefile_render = templatefile(
    "${path.module}/dashboards/dashboard.json.tftpl",
    {
      tf_showback_config                 = var.showback_config
      tf_dashboard_name                  = var.dashboard_name
      tf_event_name_prefix               = var.event_name_prefix
      tf_metric_name_prefix              = var.metric_name_prefix
      tf_account_id                      = var.showback_insert_account_id
      tf_core_user_usd                   = var.showback_price.core_user_usd
      tf_full_user_usd                   = var.showback_price.full_user_usd
      tf_gb_ingest_usd                   = var.showback_price.gb_ingest_usd
      tf_core_user_committed_usd         = coalesce(var.showback_price.core_user_committed_usd, 0)
      tf_full_user_committed_usd         = coalesce(var.showback_price.full_user_committed_usd, 0)
      tf_gb_ingest_committed_usd         = coalesce(var.showback_price.gb_ingest_committed_usd, 0)
      tf_core_user_additional_usd        = coalesce(var.showback_price.core_user_additional_usd, 0)
      tf_full_user_additional_usd        = coalesce(var.showback_price.full_user_additional_usd, 0)
      tf_gb_ingest_additional_usd        = coalesce(var.showback_price.gb_ingest_additional_usd, 0)
      tf_min_core_users                  = var.showback_price.min_core_users
      tf_min_full_users                  = var.showback_price.min_full_users
      tf_min_gb_ingest                   = var.showback_price.min_gb_ingest
      tf_synthetics_checks_included      = var.showback_price.synthetics_checks_included
      tf_synthetics_additional_check_usd = coalesce(var.showback_price.synthetics_additional_check_usd, 0)
      tf_accu_unit_usd                   = coalesce(var.showback_price.accu_unit_usd, 0)
      tf_accu_committed_usd              = coalesce(var.showback_price.accu_committed_usd, 0)
      tf_accu_additional_usd             = coalesce(var.showback_price.accu_additional_usd, 0)
      tf_min_accu                        = var.showback_price.min_accu
      tf_prorate_minimums                = var.showback_price.prorate_minimums
      tf_unique_tiers                    = local.unique_tiers
      tf_unique_accounts                 = local.unique_accounts
      tf_needs_with_core_users           = local.needs_with_core_users
      tf_needs_with_full_users           = local.needs_with_full_users
      tf_needs_with_ingest               = local.needs_with_ingest
      tf_needs_with_synth                = local.needs_with_synth
      tf_needs_with_accu                 = local.needs_with_accu
    }
  )
}

# Validation: Ensure we don't exceed NRQL's 3 subquery limit
resource "null_resource" "validate_subquery_limit" {
  count = local.with_count > 3 ? 1 : 0

  provisioner "local-exec" {
    command = "echo 'ERROR: Your pricing configuration requires ${local.with_count} WITH subqueries, but NRQL only supports 3. Please adjust your pricing to use the same committed and additional rates for some metrics.' && exit 1"
  }

  triggers = {
    with_count = local.with_count
  }
}

resource "newrelic_one_dashboard_json" "templatefile_dashboard" {
  json = local.templatefile_render
}

# Tag terraform managed dashboards
resource "newrelic_entity_tags" "templatefile_dashboard" {
  guid = newrelic_one_dashboard_json.templatefile_dashboard.guid
  tag {
    key    = "terraform"
    values = [true]
  }
}

output "templatefile_dashboard" {
  value = newrelic_one_dashboard_json.templatefile_dashboard.permalink
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
