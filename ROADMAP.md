# nr-showback Roadmap

This document tracks planned improvements and enhancements for the New Relic showback dashboard project.

## Pricing Model Support Strategy

New Relic offers two primary consumption-based pricing models:

1. **Data + Users Model** (Current Focus)
   - Data Ingest (GB)
   - Full Platform Users (monthly count)
   - Core Users (optional, monthly count)
   - Synthetics Monitoring - optional add-on with check-based pricing
   - Advanced Compute Capacity Units (aCCU) - optional add-on (PLANNED)

2. **Data + Core Compute Model** (Future)
   - Data Ingest (GB)
   - Core Compute Capacity Units (CCU)
   - Advanced Compute Capacity Units (aCCU) - optional add-on

**Current State:** This repository supports the Data + Users model with showback for data ingest, users (full/core), synthetics checks, and Advanced Compute (aCCU).

## Upcoming Features & Improvements

### 1. Data + Core Compute Pricing Model Support
**Priority:** Medium
**Status:** Planned
**Description:** Enable support for the Data + Core Compute pricing model alongside the existing Data + Users model.

**Implementation Plan:**
- [ ] Add `pricing_model` variable to `variables.tf` with validation ("users" or "compute")
- [ ] Extend `showback_price` variable to support compute model pricing
  - [ ] `ccu_committed_usd` - cost per CCU at commitment level
  - [ ] `ccu_additional_usd` - cost per CCU above commitment
  - [ ] `min_ccu` - minimum CCU commitment
  - [ ] Reuse aCCU variables from item #1 above (aCCU optional in both models)
  - [ ] Reuse `gb_ingest_*` variables (common to both models)
- [ ] Research CCU consumption metrics
  - [ ] Identify NrConsumption metrics for CCU usage
  - [ ] Understand department attribution for CCU
  - [ ] Determine synthetics handling in CCU model
- [ ] Create conditional dashboard logic based on pricing model
  - [ ] Option A: Single template with conditional sections
  - [ ] Option B: Separate templates per model
- [ ] Implement CCU-based widgets
  - [ ] CCU Usage & Cost by Department table
  - [ ] CCU consumption visualizations
  - [ ] Conditional synthetics cost handling
- [ ] Create example configurations for compute model
- [ ] Update documentation for both pricing models

**Benefits:**
- Support for all New Relic pricing model customers
- Flexible showback architecture
- Future-proof solution for pricing changes

**Technical Considerations:**
- Architecture decision: Single vs separate templates
- Backward compatibility: Default to "users" for existing deployments
- Both models share data ingest and aCCU components
- Synthetics handling differs between models

**Files to modify:**
- `variables.tf` - Add pricing model selection and CCU variables
- `dashboards/` - Add compute model template or conditionals
- `terraform.tfvars.sample` - Add compute model examples
- `README.md` - Document both pricing models
- Main Terraform files - Model selection logic

### 3. Dynamic Provider Region Configuration
**Priority:** Medium  
**Status:** Planned  
**Description:** Make the New Relic provider region configurable via variables instead of hardcoded.

**Implementation Plan:**
- [ ] Add `newrelic_region` variable to `variables.tf` with validation (US/EU only)
- [ ] Update `provider.tf` to use `var.newrelic_region` instead of hardcoded "US"
- [ ] Update all `runtf-*.sh` wrapper scripts to set `TF_VAR_newrelic_region`
- [ ] Add region configuration to `terraform.tfvars.sample`
- [ ] Update documentation with region configuration examples

**Benefits:**
- Supports multi-region deployments
- Environment-specific region configuration
- Better flexibility for different New Relic accounts
- Maintains consistency across environments

**Files to modify:**
- `variables.tf` - Add region variable with validation
- `provider.tf` - Replace hardcoded region with variable
- `runtf-*.sh` scripts - Add TF_VAR_newrelic_region export
- `terraform.tfvars.sample` - Add region example
- `README.md` - Document region configuration

### 2. Regional Synthetics Script Execution
**Priority:** Medium  
**Status:** Planned  
**Description:** Configure synthetics monitoring scripts to run from geographically appropriate locations based on New Relic account region.

**Implementation Plan:**
- [ ] Add location-based synthetics configuration
- [ ] Configure Washington DC location for US region accounts
- [ ] Configure Frankfurt location for EU region accounts
- [ ] Update synthetics script deployment logic
- [ ] Add location validation and error handling

**Benefits:**
- Improved monitoring accuracy for regional services
- Reduced network latency for synthetics checks
- Compliance with data residency requirements
- Better user experience simulation from appropriate geolocations

**Technical Details:**
- US Region accounts → Washington DC synthetics location
- EU Region accounts → Frankfurt synthetics location
- Automatic location selection based on provider region variable
- Fallback logic for unsupported regions

---

## Recently Completed

### ✅ Advanced Compute (aCCU) Support (v1.7.0)
**Completed:** December 2025
**Description:** Added comprehensive support for Advanced Compute Capacity Units (aCCU) in the Data + Users pricing model with dual pricing support (simple and commitment-based).

**Features delivered:**
- ✅ aCCU pricing variables with validation in `variables.tf`
  - `accu_unit_usd` - cost per aCCU unit (simple pricing, when min_accu = 0)
  - `accu_committed_usd` - cost per aCCU at commitment level (with minimums)
  - `accu_additional_usd` - cost per aCCU above minimum commitment
  - `min_accu` - minimum aCCU commitment (optional, default: 0)
- ✅ aCCU cost tracking integrated into main Department Showback table
  - Total aCCU column showing raw usage
  - Billable aCCU column (shows total usage with simple pricing, overage with commitment pricing)
  - aCCU Cost (USD) column with dual pricing model support
- ✅ aCCU cost included in Total Cost (USD) pie chart
- ✅ aCCU cost included in Total Cost calculation across all widgets
- ✅ Dedicated aCCU Usage & Cost by Department table widget
- ✅ aCCU Usage by Department pie chart visualization
- ✅ aCCU Usage Trend line chart (3-month history)
- ✅ aCCU breakdown added to Total Consumption by Month table
- ✅ Dual pricing model support:
  - Simple unit pricing when min_accu = 0
  - Commitment-based pricing with separate committed/additional rates when min_accu > 0
  - Proportional cost allocation using org-level billing methodology
- ✅ Comprehensive null safety to handle accounts without aCCU features
- ✅ Backward compatibility maintained (all aCCU pricing optional)
- ✅ Documentation updates:
  - README.md updated with aCCU examples
  - terraform.tfvars.sample includes aCCU configuration examples
  - Inline code comments explaining aCCU metrics

**Technical Implementation:**
- Used `filter(sum(consumption), WHERE metric = 'AdvancedCCU' AND dimension_productFeature != 'Cloud bytes received')` pattern
- Proportional cost allocation matches New Relic's organization-level billing
- Department costs correctly sum to actual invoice amount
- Graceful degradation when aCCU metric doesn't exist

### ✅ Data Ingest and Synthetics Usage Widgets (v1.6.0)
**Completed:** December 2025
**PR:** [#35](https://github.com/newrelic-experimental/nr-showback/pull/35)
**Description:** Added comprehensive usage and cost tracking widgets for data ingest above commitment and synthetics monitoring.

**Features delivered:**
- Data Ingest Usage & Cost table showing:
  - Total Ingest GB per department
  - Ingest Above Commit GB (usage beyond minimum commitment)
  - Proportional cost allocation for overage
- Synthetics Usage & Cost table showing:
  - Total Checks per department
  - Billable Checks (usage beyond included amount)
  - Proportional cost allocation for overage
- Synthetics visualization charts:
  - Pie chart showing distribution across departments
  - Line chart showing 3-month usage trends
- Fixed department matching consistency using dual-query pattern (`FROM Metric, NrConsumption`)
- Updated dashboard layout to accommodate new widgets
- Comprehensive documentation updates

### ✅ Proportional Cost Allocation System
**Completed:** November 2025
**PR:** [#33](https://github.com/newrelic-experimental/nr-showback/pull/33)
**Description:** Implemented proportional cost allocation for usage above minimum commitments.

**Features delivered:**
- Commitment-based pricing model with separate rates for committed vs additional usage
- Proportional allocation formulas for costs above minimum commitments
- Support for minimum commitments on users (full/core), data ingest, and synthetics
- Flexible pricing structure supporting both non-commitment and commitment-based contracts
- Backward compatibility with existing configurations

### ✅ Synthetics Cost Tracking Feature
**Completed:** October 2025
**Description:** Added comprehensive synthetics monitoring cost tracking with minimum commitment pricing support.

**Features delivered:**
- Synthetics cost variables with validation
- Enhanced dashboard widgets with synthetics data
- Department-based synthetics cost allocation
- Monthly consumption tracking with synthetics
- Backward compatibility maintained
- Dual-query architecture preserved

---

## Future Considerations

### Additional Consumption Metrics
- **Browser monitoring sessions** - session-based pricing tracking
- **Mobile monitoring metrics** - app-specific consumption
- **Infrastructure monitoring hosts** - host-based or entity-based pricing
- **Custom events pricing** - event volume tracking and cost allocation
- **Logs pricing** - log ingest volume (if priced separately from data)
- **Traces pricing** - trace data consumption (if priced separately)
- **Pixie data** - Kubernetes monitoring data consumption

### Dashboard Enhancements
- **Cost forecasting widgets** - predictive consumption and cost trends
- **Budget alerts integration** - automated alerting on cost thresholds
- **Department-level cost controls** - budget tracking per department
- **Export functionality** - CSV/Excel export for finance teams
- **Cost anomaly detection** - identify unusual consumption patterns
- **Comparison views** - month-over-month and year-over-year comparisons
- **Drill-down capabilities** - account-level detail within departments

### User Attribution & Tracking
- **User-to-department mapping** - automated user assignment logic
- **User activity tracking** - consumption attribution by individual user
- **User role-based costs** - differentiate costs by user permission levels
- **Guest user tracking** - monitor and allocate guest user costs

### Infrastructure Improvements
- **Multi-environment support** - dev/staging/prod configurations
- **Automated testing** - unit tests for dashboard widgets and NRQL queries
- **CI/CD pipeline** - automated deployment and validation
- **Terraform state management** - remote state and locking improvements
- **Module architecture** - refactor into reusable Terraform modules
- **Version upgrade automation** - streamlined update process

### Pricing & Billing
- **Multi-currency support** - handle non-USD pricing
- **Tax and fee allocation** - support for regional taxes and fees
- **Enterprise pricing structures** - tiered or negotiated rate handling
- **Contract term handling** - annual vs monthly commitment tracking
- **Chargeback automation** - integrate with financial systems (Workday, SAP, etc.)

### Reporting & Analytics
- **Executive dashboards** - high-level cost summaries
- **Trend analysis** - long-term consumption patterns
- **Cost optimization recommendations** - identify savings opportunities
- **Capacity planning** - forecast future capacity needs
- **ROI tracking** - measure value delivered per department

---

*Last updated: December 1, 2025*