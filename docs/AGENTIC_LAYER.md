# Agentic Layer — ifrs-calc-spl

## Risk Classification

### Low — Auto-execute
- Tag valuation run with anomaly flags after calculation
- Set `review_status = 'flagged'` on suspicious cash flow months
- Draft Excel export filename using GoC + date convention
- Score RA sufficiency and append advisory to run record

### Medium — Light Approval (user confirms)
- Re-run valuation with updated yield curve (creates new run row, replaces old)
- Mark GoC as onerous and apply loss component split
- Override an RA factor outside normal range

### High — Always Approval
- Export and email Excel workbook to external auditor address
- Publish IFRS movement schedule to shared drive

### Critical — Human Only
- Delete a completed valuation run and its child rows
- Override a negative CSM (suppress onerous flag)
- Alter locked-in yield curve after initial recognition date

## Named Tools (approved)
- `run_valuation(goc_id, as_at_date, model)` — triggers calculation pipeline
- `export_excel(run_id)` — generates and streams workbook
- `fetch_sql_server_metrics(group_id, as_at_date)` — read-only SQL Server pull
- `flag_anomaly(run_id, month_offset, reason)` — writes audit log
- `update_ra_config(goc_id, factors)` — medium risk, requires approval

## Audit Log Fields
`action | entity_type | entity_id | payload (inputs + outputs) | user_id | created_at | risk_level`

## v1 vs Later
**v1:** `run_valuation` + `export_excel` + `fetch_sql_server_metrics` auto-execute; anomaly flagging auto.
**Later:** scheduled monthly runs, auditor email dispatch (high approval gate), experience adjustment agent.
