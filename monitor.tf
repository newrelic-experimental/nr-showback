module "monitor1" {
  source = "./modules/monitor"
  new_relic_region = var.new_relic_region
  monitor_name = var.monitor_name
  showback_config = var.showback_config
  showback_query_account_id = var.showback_query_account_id
  showback_query_user_api_key = var.showback_query_user_api_key
  showback_insert_account_id = var.showback_insert_account_id
  showback_insert_license_api_key = var.showback_insert_license_api_key
  showback_ignore = var.showback_ignore
}