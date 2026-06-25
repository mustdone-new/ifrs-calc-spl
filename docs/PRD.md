# PRD — ifrs-calc-spl

## Problem
Actuaries and financial controllers run IFRS 17 closing cycles manually in fragmented spreadsheets — no single tool connects to the source SQL database, enforces dual-mode sign rules (Insurance vs Reinsurance), and produces an auditable Excel workbook in one click.

## Target Users
Actuaries, Financial Controllers, Insurance Accountants, Risk Analysts, External Auditors running monthly/quarterly IFRS 17 closings.

## Core Objects
- **Group of Contracts (GoC)** — the valuation unit (Insurance or Reinsurance)
- **Valuation Run** — one execution: GoC + AS AT date + measurement model (GMM / PAA)
- **Cash Flow Projection** — 60-month timeline (premiums, commissions, claims, expenses, refunds)
- **Yield Curve** — locked-in vs current discount rates per period
- **Risk Adjustment Config** — RA factors (claim, expense, claim-cost) per GoC
- **CSM Ledger** — month-by-month CSM opening, accretion, amortisation, closing
- **Journal Entry** — double-entry debits/credits for LRC and LIC
- **IFRS Movement Schedule** — BEL, RA, CSM roll-forwards
- **Excel Report** — generated workbook per Valuation Run

## MVP Checklist (v1)
- [ ] Enter Group ID, Group Type (I/R), AS AT date → trigger Valuation Run
- [ ] Connect to SQL Server (SEA_CANDI) and pull policy metrics
- [ ] Compute BEL, RA, CSM (Month 1: CSM = –(BEL + RA), net = 0)
- [ ] Build 60-month cash flow projection with multi-year claim patterns and monthly inflation loading
- [ ] Apply correct sign conventions per mode (Insurance / Reinsurance)
- [ ] Generate initial recognition metrics + double-entry journal vouchers
- [ ] Generate IFRS Movement schedule (CSM roll-forward, RA, BEL)
- [ ] Export formatted Excel workbook (380+ row audit trail, live formulas)
- [ ] Demo rows viewable without login

## Non-Goals (v1)
- Multi-tenant SaaS billing / team management
- Real-time streaming from SQL Server
- PAA onerous contract loss-recovery component (later)
- Automated email distribution of reports

## Success Criteria
User enters Group ID `GRP-001`, type `I`, date `2024-12-31` → system connects, runs full GMM calculation, and downloads `GRP-001_2024-12-31.xlsx` containing Month 1 CSM = –(BEL + RA), 60-month projections, journal entries, and IFRS movement schedule — traceable formula by formula by an external auditor.
