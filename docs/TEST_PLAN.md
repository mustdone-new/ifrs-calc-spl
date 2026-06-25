# Test Plan — ifrs-calc-spl

## v1 Success Scenario (manual)
1. Open `/` — verify 3 seeded GoCs render (no login prompt)
2. Click `GRP-001` (Insurance, GMM) → GoC detail loads; RA config shows claim factor 0.08
3. Click "New Run" → fill AS AT `2024-12-31`, model `GMM` → submit
4. Verify `/runs/[id]` shows status `running` then `complete` within 30 s
5. Check summary: BEL negative, RA negative, CSM = –(BEL + RA), net = 0.00
6. Click "Download Excel" → file `GRP-001_2024-12-31.xlsx` downloads
7. Open in Excel → Initial Recognition sheet: cell F5 = `=-(C5+D5)` (CSM formula)
8. IFRS Movement sheet: 60 rows, LRC month 60 near zero
9. Journal Entries sheet: debits = credits for each month
10. Metadata sheet: run ID matches URL, engine version present

## Reinsurance Mode Sign Check
1. Select `GRP-003` (Reinsurance, GMM)
2. Run valuation → verify CSM sign convention flipped (asset not liability)
3. Journal entries show reinsurance asset accounts

## Empty / Error Cases
- Submit run with invalid Group ID → API returns 400, form shows "Group not found in SQL Server"
- SQL Server unreachable → run status set to `failed`, error message displayed
- Missing yield curve month → warning banner: "Month 23 rate missing — using linear interpolation"
- GoC with no RA config → form blocks run, shows "Configure RA factors first"

## Onerous Contract Test
1. Set RA factors to zero for a GoC with large claims → trigger run
2. Verify CSM Month 1 < 0 → red onerous badge appears
3. "Download Excel" button disabled until user clicks "Acknowledge Onerous Flag"
4. After acknowledgement → export proceeds, onerous sheet tab added to workbook

## Anomaly Detection Test
1. Seed a cash flow with month 37 claims = 10× mean
2. Run valuation → verify anomaly flag in `audit_logs` with `month_offset = 37`
3. Excel month 37 row highlighted amber
