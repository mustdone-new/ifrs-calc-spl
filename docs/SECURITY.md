# Security — ifrs-calc-spl

## Secret Handling
- SQL Server connection string (`MSSQL_CONNECTION_STRING`) stored in Vercel env — never referenced in client bundle
- Supabase service-role key server-side only; anon key in frontend
- All SQL Server queries run inside Next.js Route Handlers (server) — zero exposure to browser

## Permission Model (v1 → lock-down)
- **v1:** Supabase RLS open/permissive — demo rows readable by anyone; suitable for internal preview only
- **Lock-down sprint:** Replace with `auth.uid() = user_id` owner policies; add Supabase Auth (email/password)
- Valuation run and export endpoints will check session before writing in lock-down sprint

## Approved-Tools Rule
- Agent may only call named tools in `AGENTIC_LAYER.md`
- No `run_any_sql`, `send_any_email`, or raw `exec` calls permitted
- Every tool call writes to `audit_logs` before and after execution

## Audit Principle
- Every meaningful action (run triggered, export downloaded, RA override) writes an `audit_logs` row with full payload
- Audit logs are append-only; no delete policy on that table even in v1
- Excel workbooks include a metadata sheet: run ID, timestamp, user, engine version
