# Architecture — ifrs-calc-spl

## Stack
- **Frontend:** Next.js 14 (App Router) + Tailwind + shadcn/ui
- **Backend API:** Next.js Route Handlers (Node.js)
- **App DB:** Supabase (Postgres) — stores runs, configs, results, audit logs
- **Source DB:** SQL Server (SEA_CANDI) — read-only via `mssql` driver; credentials in server env only
- **Excel Generation:** `exceljs` — server-side, streamed to download
- **Hosting:** Vercel

## Now vs Later
**Now (v1):** GoC config UI → trigger valuation run → SQL Server pull → BEL/RA/CSM engine → Excel export
**Next:** PAA mode engine, experience adjustment input, yield curve upload UI
**Later:** Scheduled auto-runs, email dispatch, audit sign-off workflow, auth + RLS lockdown

## Key User Action — Step by Step
1. User fills Run form (Group ID, type, date, model)
2. POST `/api/valuation/run` — validates inputs, writes `valuation_runs` row (status: `queued`)
3. Server fetches policy metrics from SQL Server (read-only, server-side only)
4. **Calculation engine** (pure TS): builds 60-month cash flow matrix → discounts with yield curve → sums BEL → applies RA factors → sets CSM = –(BEL + RA) at Month 1 → rolls forward months 2-60
5. Results written to `cash_flow_projections`, `csm_ledger`, `journal_entries`, `ifrs_movements`
6. Status set to `complete`; frontend polls and shows download button
7. GET `/api/valuation/[id]/export` streams the Excel workbook

## Layer Plan
1. **Data first** — Supabase schema + seed demo rows (no login needed)
2. **App logic** — calculation engine runs end-to-end in pure TypeScript (no AI dependency)
3. **Smart features** — anomaly flagging, CSM sufficiency warnings (later)

## Core Without AI
The entire BEL/RA/CSM/journal engine is deterministic actuarial math. AI is optional overlay only.
