variable "new_relic_region" {
  type = string
}
variable "monitor_name" {
  type = string
}
variable "dashboard_name" {
  type = string
}
variable "showback_query_account_id" {
  type = string
}
variable "showback_query_user_api_key" {
  type = string
}
variable "showback_insert_account_id" {
  type = string
}
variable "showback_insert_license_api_key" {
  type = string
}

variable "showback_price" {
  type = object({
    core_user_usd = number
    full_user_usd = number
    gb_ingest_usd = number
  })
}
variable "showback_ignore" {
  type = object({
    groups = list(string)
    newrelic_users = bool
  })
}
variable "showback_config" {
  description = "Showback config"
  type = list(object({
    department_name = string
    tier = optional(string)
    accounts_in = list(string)
    accounts_regex = list(string)
  }))
}