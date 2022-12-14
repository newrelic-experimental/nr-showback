# Used by both dashboard.tf and monitor.tf to associate departments with accounts

showback_price = {  # Standard plan, Nov 2022
  core_user_usd = 49,  # Standard plan $49 / month 
  full_user_usd = 99,  # Standard plan $99 / month, max 5 full users
  gb_ingest_usd = 0.30  # Standard plan $0.30 / GB beyond free limits, default retention, US region
}

showback_ignore = {
  groups = []
  newrelic_users = true  # Set to false to include New Relic users in departmental reporting; regardless of setting, New Relic users will always be included in user and account reporting 
}

showback_config = [
  {
    department_name = "Dept 1"  # Both named accounts, and pattern matches
    accounts_in = [
      "An account that does not match a pattern for this department",
      "Another account not matching a pattern"
    ]
    accounts_regex = [
      "^one..*",  # Match any account beginning with one., which is required for association with the department in the synthetic script and dashboard
      "^anotherone..*"
    ]
  },
  {
    department_name = "Dept 2"  # No named accounts, only patterns
    accounts_in = []
    accounts_regex = [
      "^two..*"
    ]
  },
  {
    department_name = "Dept 3"  # Only named accounts
    accounts_in = [
      "Third dept account",
      "Another account from department three"
    ]
    accounts_regex = []  # No patterns to be matched
  },
]
