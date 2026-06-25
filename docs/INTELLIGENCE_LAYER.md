# Intelligence Layer — ifrs-calc-spl

## Messy Inputs
- Raw SQL Server policy tables with inconsistent claim payment schedules
- Manually keyed RA factors that may not sum correctly
- Yield curves uploaded as flat files with missing months

## Auto-Structure (on run trigger)
```json
{
  "goc_id": "GRP-001",
  "group_type": "I",
  "as_at_date": "2024-12-31",
  "extracted_policies": 142,
  "cash_flow_months": 60,
  "bel": -4820000,
  "ra": -310000,
  "csm_month1": 5130000,
  "net_liability_month1": 0.00,
  "anomalies": ["month 37 claims spike >2σ"],
  "confidence": 0.91,
  "review_status": "unreviewed"
}
```

## Events to Track
- Run triggered (inputs, model selected)
- SQL Server rows fetched (count, duration)
- CSM sufficiency check (positive / onerous flag)
- Excel downloaded (user, timestamp)

## Scoring Rules (rule-based v1)
- **Onerous flag:** CSM Month 1 < 0 → flag loss component, block export until reviewed
- **Anomaly score:** claim month > mean + 2σ → tag row in Excel with warning colour
- **RA sufficiency:** RA / BEL ratio outside [5%, 25%] → advisory warning
- **Confidence:** 1.0 if all source rows present; –0.1 per missing yield curve month

## What Gets Ranked
- Valuation runs with anomaly flags surface first on dashboard
- GoCs with onerous contracts shown with red badge

## v1 vs Later
**v1:** rule-based anomaly flagging, onerous detection, RA ratio warning
**Later:** ML-assisted experience adjustment suggestions, peer-group BEL benchmarking
