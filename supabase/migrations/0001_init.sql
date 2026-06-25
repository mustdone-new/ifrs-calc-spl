create table if not exists groups_of_contracts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  group_code text not null,
  group_type text not null,
  measurement_model text not null,
  product_line text,
  inception_date date,
  currency text default 'USD',
  created_at timestamptz not null default now()
);

alter table groups_of_contracts enable row level security;
drop policy if exists "groups_of_contracts_v1_read" on groups_of_contracts;
create policy "groups_of_contracts_v1_read" on groups_of_contracts for select using (true);
drop policy if exists "groups_of_contracts_v1_write" on groups_of_contracts;
create policy "groups_of_contracts_v1_write" on groups_of_contracts for all using (true) with check (true);

create table if not exists valuation_runs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  goc_id uuid references groups_of_contracts(id),
  as_at_date date not null,
  status text not null default 'queued',
  error_message text,
  excel_path text,
  created_at timestamptz not null default now()
);

alter table valuation_runs enable row level security;
drop policy if exists "valuation_runs_v1_read" on valuation_runs;
create policy "valuation_runs_v1_read" on valuation_runs for select using (true);
drop policy if exists "valuation_runs_v1_write" on valuation_runs;
create policy "valuation_runs_v1_write" on valuation_runs for all using (true) with check (true);

create table if not exists yield_curves (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  curve_date date not null,
  month_offset int not null,
  rate_type text not null,
  rate numeric not null,
  created_at timestamptz not null default now()
);

alter table yield_curves enable row level security;
drop policy if exists "yield_curves_v1_read" on yield_curves;
create policy "yield_curves_v1_read" on yield_curves for select using (true);
drop policy if exists "yield_curves_v1_write" on yield_curves;
create policy "yield_curves_v1_write" on yield_curves for all using (true) with check (true);

create table if not exists risk_adjustment_configs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  goc_id uuid references groups_of_contracts(id),
  ra_claim_factor numeric not null default 0.08,
  ra_expense_factor numeric not null default 0.05,
  ra_claim_cost_factor numeric not null default 0.06,
  created_at timestamptz not null default now()
);

alter table risk_adjustment_configs enable row level security;
drop policy if exists "risk_adjustment_configs_v1_read" on risk_adjustment_configs;
create policy "risk_adjustment_configs_v1_read" on risk_adjustment_configs for select using (true);
drop policy if exists "risk_adjustment_configs_v1_write" on risk_adjustment_configs;
create policy "risk_adjustment_configs_v1_write" on risk_adjustment_configs for all using (true) with check (true);

create table if not exists cash_flow_projections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  run_id uuid references valuation_runs(id),
  month_offset int not null,
  premium numeric not null default 0,
  commission numeric not null default 0,
  claims_paid numeric not null default 0,
  expenses numeric not null default 0,
  refunds numeric not null default 0,
  inflation_factor numeric not null default 1.0,
  discount_factor numeric not null default 1.0,
  pv_cash_flow numeric not null default 0,
  created_at timestamptz not null default now()
);

alter table cash_flow_projections enable row level security;
drop policy if exists "cash_flow_projections_v1_read" on cash_flow_projections;
create policy "cash_flow_projections_v1_read" on cash_flow_projections for select using (true);
drop policy if exists "cash_flow_projections_v1_write" on cash_flow_projections;
create policy "cash_flow_projections_v1_write" on cash_flow_projections for all using (true) with check (true);

create table if not exists csm_ledger (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  run_id uuid references valuation_runs(id),
  month_offset int not null,
  csm_opening numeric not null default 0,
  interest_accretion numeric not null default 0,
  amortisation numeric not null default 0,
  experience_adj numeric not null default 0,
  csm_closing numeric not null default 0,
  created_at timestamptz not null default now()
);

alter table csm_ledger enable row level security;
drop policy if exists "csm_ledger_v1_read" on csm_ledger;
create policy "csm_ledger_v1_read" on csm_ledger for select using (true);
drop policy if exists "csm_ledger_v1_write" on csm_ledger;
create policy "csm_ledger_v1_write" on csm_ledger for all using (true) with check (true);

create table if not exists journal_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  run_id uuid references valuation_runs(id),
  entry_type text not null,
  month_offset int not null,
  account text not null,
  debit numeric not null default 0,
  credit numeric not null default 0,
  description text,
  created_at timestamptz not null default now()
);

alter table journal_entries enable row level security;
drop policy if exists "journal_entries_v1_read" on journal_entries;
create policy "journal_entries_v1_read" on journal_entries for select using (true);
drop policy if exists "journal_entries_v1_write" on journal_entries;
create policy "journal_entries_v1_write" on journal_entries for all using (true) with check (true);

create table if not exists ifrs_movements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  run_id uuid references valuation_runs(id),
  month_offset int not null,
  bel_opening numeric not null default 0,
  bel_unwinding numeric not null default 0,
  bel_new_business numeric not null default 0,
  bel_closing numeric not null default 0,
  ra_opening numeric not null default 0,
  ra_release numeric not null default 0,
  ra_closing numeric not null default 0,
  csm_opening numeric not null default 0,
  csm_closing numeric not null default 0,
  lrc_total numeric not null default 0,
  lrc_total_source text,
  lrc_total_confidence numeric,
  lrc_total_review_status text default 'unreviewed',
  created_at timestamptz not null default now()
);

alter table ifrs_movements enable row level security;
drop policy if exists "ifrs_movements_v1_read" on ifrs_movements;
create policy "ifrs_movements_v1_read" on ifrs_movements for select using (true);
drop policy if exists "ifrs_movements_v1_write" on ifrs_movements;
create policy "ifrs_movements_v1_write" on ifrs_movements for all using (true) with check (true);

create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid,
  action text not null,
  entity_type text,
  entity_id uuid,
  payload jsonb,
  risk_level text default 'low',
  created_at timestamptz not null default now()
);

alter table audit_logs enable row level security;
drop policy if exists "audit_logs_v1_read" on audit_logs;
create policy "audit_logs_v1_read" on audit_logs for select using (true);
drop policy if exists "audit_logs_v1_write" on audit_logs;
create policy "audit_logs_v1_write" on audit_logs for all using (true) with check (true);

insert into groups_of_contracts (id, group_code, group_type, measurement_model, product_line, inception_date, currency) values
  ('a1b2c3d4-0001-0001-0001-000000000001', 'GRP-001', 'I', 'GMM', 'Motor Third Party Liability', '2022-01-01', 'USD'),
  ('a1b2c3d4-0002-0002-0002-000000000002', 'GRP-002', 'I', 'GMM', 'Property Fire & Allied Perils', '2022-07-01', 'USD'),
  ('a1b2c3d4-0003-0003-0003-000000000003', 'GRP-003', 'R', 'GMM', 'Quota Share Reinsurance — Motor', '2023-01-01', 'USD');

insert into risk_adjustment_configs (goc_id, ra_claim_factor, ra_expense_factor, ra_claim_cost_factor) values
  ('a1b2c3d4-0001-0001-0001-000000000001', 0.080, 0.050, 0.060),
  ('a1b2c3d4-0002-0002-0002-000000000002', 0.075, 0.045, 0.055),
  ('a1b2c3d4-0003-0003-0003-000000000003', 0.070, 0.040, 0.050);

insert into yield_curves (curve_date, month_offset, rate_type, rate) values
  ('2024-12-31', 1,  'locked_in', 0.0412),
  ('2024-12-31', 6,  'locked_in', 0.0418),
  ('2024-12-31', 12, 'locked_in', 0.0425),
  ('2024-12-31', 24, 'locked_in', 0.0438),
  ('2024-12-31', 36, 'locked_in', 0.0445),
  ('2024-12-31', 60, 'locked_in', 0.0460),
  ('2024-12-31', 1,  'current',   0.0430),
  ('2024-12-31', 6,  'current',   0.0436),
  ('2024-12-31', 12, 'current',   0.0444),
  ('2024-12-31', 24, 'current',   0.0452),
  ('2024-12-31', 36, 'current',   0.0461),
  ('2024-12-31', 60, 'current',   0.0475);

insert into valuation_runs (id, goc_id, as_at_date, status) values
  ('b2c3d4e5-0001-0001-0001-000000000001', 'a1b2c3d4-0001-0001-0001-000000000001', '2024-12-31', 'complete'),
  ('b2c3d4e5-0002-0002-0002-000000000002', 'a1b2c3d4-0002-0002-0002-000000000002', '2024-12-31', 'complete'),
  ('b2c3d4e5-0003-0003-0003-000000000003', 'a1b2c3d4-0003-0003-0003-000000000003', '2024-12-31', 'complete');