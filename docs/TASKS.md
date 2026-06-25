# Tasks — ifrs-calc-spl

## Sprint 1 — Database + Demo Data + GoC Config UI
**Goal:** Schema live, seed data visible without login, GoC list and detail pages render.
- [ ] Apply migration SQL to Supabase (all tables + RLS open policies)
- [ ] Seed 3 demo GoCs (2 Insurance GMM, 1 Reinsurance GMM) with yield curves, RA configs
- [ ] Build `/` homepage — GoC list table (group code, type, model, last run date)
- [ ] Build `/goc/[id]` detail page — GoC fields + RA config display
- [ ] Add "New GoC" form (group_code, group_type, measurement_model, currency, inception_date)
- [ ] Empty state, loading skeleton, error boundary on all pages
**DoD:** Homepage loads with 3 seeded GoCs, no login required, form persists new GoC to DB.

## Sprint 2 — Core Valuation Engine (v1 functional milestone) ✅
**Goal:** End-to-end: user triggers run → SQL Server pull → BEL/RA/CSM calculation → results stored.
- [ ] Build "New Run" form on GoC detail page (AS AT date, model selector)
- [ ] `POST /api/valuation/run` — writes `valuation_runs` row, status `queued`
- [ ] `fetch_sql_server_metrics` tool — mssql read-only pull of policy metrics
- [ ] Cash flow projection engine (60 months, premium/commission/claims/expenses/refunds, monthly inflation)
- [ ] Multi-year claim payment pattern handler
- [ ] Discount engine — apply yield curve (locked-in / current) per month
- [ ] BEL aggregation, RA calculation (claim × factor + expense × factor + claim-cost × factor)
- [ ] Month 1 CSM = –(BEL + RA); sign-rule switch for I vs R mode
- [ ] CSM roll-forward months 2–60 (interest accretion + straight-line amortisation)
- [ ] Write results to `cash_flow_projections`, `csm_ledger`, `journal_entries`, `ifrs_movements`
- [ ] Status polling endpoint `GET /api/valuation/[id]/status`
- [ ] Run results page `/runs/[id]` — summary table: BEL, RA, CSM Month 1, onerous flag
- [ ] Write audit_log on run start and complete
**DoD:** GRP-001 run completes, Month 1 net = 0, results visible at `/runs/[id]`.

## Sprint 3 — Excel Export Engine
**Goal:** Download button produces compliant workbook.
- [ ] `GET /api/valuation/[id]/export` — exceljs workbook streamed
- [ ] Sheet: **Initial Recognition** — BEL, RA, CSM Month 1, net liability check
- [ ] Sheet: **Cash Flow Projections** — 60-row table, live formulas for PV
- [ ] Sheet: **Journal Entries** — debit/credit rows for LRC and LIC, initial + subsequent
- [ ] Sheet: **IFRS Movement Schedule** — BEL/RA/CSM roll-forward, LRC total per month
- [ ] Sheet: **Metadata** — run ID, GoC, date, engine version, anomaly flags
- [ ] Colour-code anomaly months (amber), onerous flag (red)
- [ ] Download button on `/runs/[id]` page
- [ ] Audit log: `export_downloaded`
**DoD:** Downloaded XLSX opens in Excel; Month 1 CSM formula = –(BEL+RA); auditor can trace every row.

## Sprint 4 — Anomaly Flagging + Run Dashboard
**Goal:** Runs dashboard, RA sufficiency warnings, onerous detection.
- [ ] `/runs` dashboard — all runs, sortable by date, status badge, anomaly count
- [ ] Onerous flag: CSM < 0 → red badge, block export until acknowledged
- [ ] RA sufficiency warning: RA/BEL outside [5%, 25%] → advisory banner
- [ ] Claim spike detection: month > mean + 2σ → flag in DB + Excel cell comment
- [ ] Re-run button (creates new run, links to same GoC)
- [ ] Filter runs by GoC, status, date range
**DoD:** Flagged run shows anomaly badge; onerous GoC blocked until user acknowledges.

## Sprint 5 — PAA Mode + Yield Curve Upload
**Goal:** Premium Allocation Approach engine + yield curve management.
- [ ] PAA cash flow engine (unearned premium liability, simplified BEL)
- [ ] PAA journal entry generation
- [ ] Yield curve upload UI (CSV → `yield_curves` table)
- [ ] Locked-in vs current rate selector on run form
- [ ] PAA results sheet in Excel export
**DoD:** PAA run for a Reinsurance GoC completes and exports correctly.

## Sprint 6 — Lock It Down (Auth + RLS)
**Goal:** Secure the app before real data enters.
- [ ] Supabase Auth — email/password login, signup
- [ ] Replace open RLS policies with `auth.uid() = user_id` owner-scoped policies
- [ ] Login / logout UI; redirect unauthenticated users from write actions
- [ ] Backfill `user_id` on demo rows to a demo service account
- [ ] Session check on all API route handlers
**DoD:** Anonymous visitor can view seeded demo rows only; all writes require login.

## Gantt
```
Sprint 1  |████| DB + Demo UI
Sprint 2  |████| Valuation Engine ← v1 functional ✅
Sprint 3  |████| Excel Export
Sprint 4  |████| Anomaly + Dashboard
Sprint 5  |████| PAA + Yield Curve
Sprint 6  |████| Auth + Lock-down
```
