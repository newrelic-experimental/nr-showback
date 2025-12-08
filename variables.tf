variable "new_relic_region" {
  type = string
}
variable "monitor_name" {
  type = string
}
variable "dashboard_name" {
  type = string
}
variable "event_name_prefix" {
  type = string
}
variable "metric_name_prefix" {
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
    # Non-commitment pricing (maintained for backward compatibility)
    core_user_usd = number
    full_user_usd = number
    gb_ingest_usd = number

    # Optional: Enhanced committed minimum pricing
    core_user_committed_usd = optional(number)
    full_user_committed_usd = optional(number)
    gb_ingest_committed_usd = optional(number)

    # Optional: Additional usage pricing (for usage above minimum commitments)
    core_user_additional_usd = optional(number)
    full_user_additional_usd = optional(number)
    gb_ingest_additional_usd = optional(number)

    # Minimum commitments (0 = no minimum, uses non-commitment pricing)
    min_core_users = optional(number, 0)
    min_full_users = optional(number, 0)
    min_gb_ingest  = optional(number, 0)

    # Optional: Synthetics pricing
    synthetics_checks_included      = optional(number, 0)
    synthetics_additional_check_usd = optional(number)

    # Optional: Advanced Compute (aCCU) pricing
    accu_unit_usd       = optional(number, 0)
    accu_committed_usd  = optional(number)
    accu_additional_usd = optional(number)
    min_accu            = optional(number, 0)

    # Optional: Partial month commitment handling
    prorate_minimums = optional(bool, false)
  })

  validation {
    condition     = var.showback_price.min_core_users >= 0 && var.showback_price.min_full_users >= 0 && var.showback_price.min_gb_ingest >= 0 && var.showback_price.synthetics_checks_included >= 0 && var.showback_price.min_accu >= 0
    error_message = "Minimum commitments, synthetics checks included, and minimum aCCU must be non-negative numbers."
  }

  validation {
    condition = (
      # Either no minimums are set (non-commitment mode)
      (var.showback_price.min_core_users == 0 && var.showback_price.min_full_users == 0 && var.showback_price.min_gb_ingest == 0) ||
      # Or if minimums are set, both committed and additional rates must be provided
      (var.showback_price.core_user_committed_usd != null && var.showback_price.core_user_additional_usd != null &&
        var.showback_price.full_user_committed_usd != null && var.showback_price.full_user_additional_usd != null &&
      var.showback_price.gb_ingest_committed_usd != null && var.showback_price.gb_ingest_additional_usd != null)
    )
    error_message = "When minimum commitments are specified, both committed and additional usage rates must be provided for all user types and ingest."
  }

  validation {
    condition = (
      # Either no synthetics pricing is set
      var.showback_price.synthetics_checks_included == 0 ||
      # Or if synthetics pricing is set, additional rate must be provided
      (var.showback_price.synthetics_checks_included > 0 && var.showback_price.synthetics_additional_check_usd != null)
    )
    error_message = "When synthetics checks included is specified, synthetics additional check rate must also be provided."
  }

  validation {
    condition = (
      # Either no aCCU minimum is set (no aCCU pricing)
      var.showback_price.min_accu == 0 ||
      # Or if aCCU minimum is set, both committed and additional rates must be provided
      (var.showback_price.min_accu > 0 &&
       var.showback_price.accu_committed_usd != null &&
       var.showback_price.accu_additional_usd != null)
    )
    error_message = "When minimum aCCU commitment is specified, both committed and additional aCCU rates must be provided."
  }
}
variable "showback_ignore" {
  type = object({
    groups         = list(string)
    newrelic_users = bool
  })
}
variable "showback_config" {
  description = "Showback config"
  type = list(object({
    department_name = string
    tier            = optional(string)
    accounts_in     = list(string)
    accounts_regex  = list(string)
  }))
}