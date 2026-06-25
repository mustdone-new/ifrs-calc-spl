# Data Model — ifrs-calc-spl

## groups_of_contracts
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable, owner scope later |
| group_code | text | e.g. GRP-001 |
| group_type | text | 'I' or 'R' |
| measurement_model | text | 'GMM' or 'PAA' |
| product_line | text | |
| inception_date | date | |
| currency | text | |
| created_at | timestamptz | |

## valuation_runs
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| goc_id | uuid FK → groups_of_contracts | |
| as_at_date | date | |
| status | text | queued/running/complete/failed |
| error_message | text | nullable |
| excel_path | text | storage URL |
| created_at | timestamptz | |

## yield_curves
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| curve_date | date | |
| month_offset | int | 1–60 |
| rate_type | text | 'locked_in' or 'current' |
| rate | numeric | |
| created_at | timestamptz | |

## risk_adjustment_configs
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| goc_id | uuid FK | |
| ra_claim_factor | numeric | |
| ra_expense_factor | numeric | |
| ra_claim_cost_factor | numeric | |
| created_at | timestamptz | |

## cash_flow_projections
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| run_id | uuid FK → valuation_runs | |
| month_offset | int | 1–60 |
| premium | numeric | |
| commission | numeric | |
| claims_paid | numeric | |
| expenses | numeric | |
| refunds | numeric | |
| inflation_factor | numeric | |
| discount_factor | numeric | |
| pv_cash_flow | numeric | |
| created_at | timestamptz | |

## csm_ledger
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| run_id | uuid FK | |
| month_offset | int | |
| csm_opening | numeric | |
| interest_accretion | numeric | |
| amortisation | numeric | |
| experience_adj | numeric | |
| csm_closing | numeric | |
| created_at | timestamptz | |

## journal_entries
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| run_id | uuid FK | |
| entry_type | text | 'initial' or 'subsequent' |
| month_offset | int | |
| account | text | e.g. LRC, LIC, P&L |
| debit | numeric | |
| credit | numeric | |
| description | text | |
| created_at | timestamptz | |

## ifrs_movements
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| run_id | uuid FK | |
| month_offset | int | |
| bel_opening | numeric | |
| bel_unwinding | numeric | |
| bel_new_business | numeric | |
| bel_closing | numeric | |
| ra_opening | numeric | |
| ra_release | numeric | |
| ra_closing | numeric | |
| csm_opening | numeric | |
| csm_closing | numeric | |
| lrc_total | numeric | |
| created_at | timestamptz | |

## audit_logs
| Field | Type | Notes |
|---|---|---|
| id | uuid PK | |
| user_id | uuid | nullable |
| action | text | e.g. 'run_started', 'export_downloaded' |
| entity_type | text | |
| entity_id | uuid | |
| payload | jsonb | |
| created_at | timestamptz | |

## AI Fields
`ifrs_movements.lrc_total` when estimated by model: store `lrc_total_value numeric`, `lrc_total_source text`, `lrc_total_confidence numeric`, `lrc_total_review_status text default 'unreviewed'`.

## RLS
All tables: RLS enabled. v1 = permissive open policies. Lock-down sprint replaces with `auth.uid() = user_id`.
