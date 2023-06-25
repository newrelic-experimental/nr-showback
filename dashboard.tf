# Use a templatefile. For dashboards with many replacement values this is cleaner than using replace().
locals {
  total_consumption_cost_by_department_this_month = "FROM Metric, NrConsumption SELECT (max(`showback.department.coreuser.count`) * ${var.showback_price.core_user_usd}) + (max(`showback.department.fulluser.count`) * ${var.showback_price.full_user_usd}) + (sum(GigabytesIngested) * ${var.showback_price.gb_ingest_usd}) AS 'Total Cost (USD)' SINCE this month FACET CASES(%{ for index_department, department in var.showback_config ~}%{ if index_department != 0 ~}, %{ endif }WHERE department = '${department.department_name}' OR consumingAccountName IN (%{ for index_accounts_in, account in department.accounts_in }%{ if index_accounts_in != 0 ~}, %{ endif }'${account}'%{ endfor ~})%{ for regex in department.accounts_regex } OR consumingAccountName RLIKE r'${regex}'%{ endfor } AS '${department.department_name}'%{ endfor ~}) AS 'Department'"

  consumption_cost_by_department_this_month = "FROM Metric, NrConsumption SELECT max(`showback.department.coreuser.count`) * ${var.showback_price.core_user_usd} + max(`showback.department.fulluser.count`) * ${var.showback_price.full_user_usd} + sum(GigabytesIngested) * ${var.showback_price.gb_ingest_usd} AS 'Total Cost (USD)', max(`showback.department.fulluser.count`) AS 'Full User Count', max(`showback.department.fulluser.count`) * ${var.showback_price.full_user_usd} as 'Full User Cost (USD)', max(`showback.department.coreuser.count`) AS 'Core User Count', max(`showback.department.coreuser.count`) * ${var.showback_price.core_user_usd} as 'Core User Cost (USD)', sum(GigabytesIngested) AS ingestGigabytes, sum(GigabytesIngested) * ${var.showback_price.gb_ingest_usd} AS 'Ingest Cost (USD)' SINCE this month FACET CASES(%{ for index_department, department in var.showback_config ~}%{ if index_department != 0 ~}, %{ endif }WHERE department = '${department.department_name}' OR consumingAccountName IN (%{ for index_accounts_in, account in department.accounts_in }%{ if index_accounts_in != 0 ~}, %{ endif }'${account}'%{ endfor ~})%{ for regex in department.accounts_regex } OR consumingAccountName RLIKE r'${regex}'%{ endfor } as '${department.department_name}'%{ endfor ~}) AS 'Department'"

  templatefile_render = templatefile(
   "${path.module}/dashboards/dashboard.json.tftpl",
    {
     tf_dashboard_name = var.dashboard_name
     tf_account_id = var.showback_insert_account_id
     tf_total_consumption_cost_by_department_this_month = local.total_consumption_cost_by_department_this_month
     tf_consumption_cost_by_department_this_month = local.consumption_cost_by_department_this_month
     tf_core_user_usd = var.showback_price.core_user_usd
     tf_full_user_usd = var.showback_price.full_user_usd
     tf_gb_ingest_usd = var.showback_price.gb_ingest_usd
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

output "consumption_cost_by_department_this_month" {
  value = local.consumption_cost_by_department_this_month
}
