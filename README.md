# Credit Card Fraud Detection & Transaction Anomaly Analysis

**Exploratory analytics portfolio | Python · MySQL · Excel · Power BI**

## Overview
Analyze historical credit-card transactions to understand fraud prevalence, spending distributions, transaction trends, and geographic patterns. This is an **exploratory analytics and dashboard project**, not a trained fraud prediction model or real-time detection system.

## Dataset at a glance

| Metric | Verified value |
|---|---:|
| Transactions | 389,002 |
| Unique transaction IDs | 389,002 |
| Fraud-labeled transactions | 2,252 |
| Fraud rate | 0.58% |
| Transaction amount total | $27,402,136.52 |
| Transaction date range | 2019-01-01 through 2020-06-21 |
| December 2019 transactions | 42,308 |

## Business questions

- How prevalent are fraud-labeled transactions, and how do they vary by transaction category and gender?
- How do transaction volumes and values change over time?
- How are transactions and fraud-labeled events distributed geographically?
- How do transaction amount distributions differ across categories and gender?

## Workflow and tools

1. **Data validation:** Checked row counts, unique transaction IDs, date parsing, and duplicate-import risk. The December 2019 supplementary file overlaps with the main dataset; it must not be appended blindly.
2. **Excel:** Exploratory summaries and descriptive analysis; the private workbook is excluded from this public repository pending privacy review.
3. **MySQL:** Queries for descriptive aggregations and transaction analysis; review script and data-source limitations before running.
4. **Python:** Notebook-based exploratory analysis of fraud labels, amounts, time patterns, and categories.
5. **Power BI:** Interactive dashboard with transaction/fraud KPIs, gender/category/fraud-status slicers, geographic maps, monthly transaction counts, weekly illustrative inflation-adjusted totals, and an **MAQ Software box-and-whisker** chart.

## Dashboard

**Screenshot:** Add a refreshed, privacy-reviewed image at `powerbi/dashboard.png` and replace this note with `![Credit Card Fraud Dashboard](powerbi/dashboard.png)` once the image is available.

The dashboard includes six KPI cards: total transactions, fraudulent transactions, fraud rate, total transaction value, fraudulent transaction amount, and fraudulent amount percentage. The last two quantify the financial share associated with fraud-labeled transactions. The fraud amount percentage should use an all-status denominator so it remains interpretable when the Fraud Status slicer changes.

The MAQ box-and-whisker visual uses `trans_num` in **Axis**, `category` in **Axis category I**, `gender` in **Legend**, and Average of `amt` in **Value**. Quartiles were checked against independent DAX measures for a filtered category/gender subset. Due to apparent visual data-reduction limitations, the chart is intended for **one or two selected categories at a time**; it should not be represented as a fully validated all-category chart. Its whiskers use **Min/Max**, not 1.5×IQR.

The weekly `Inflation_Adj_Amt` formula applies an **assumed fixed 2% annual rate** using `YEAR(TODAY())`. It is **not** a CPI-based adjustment, and its output changes when the model refreshes in a new year. `WeekNum` combines corresponding week numbers across years as required by the project brief.

## Files

```text
financial-fraud-detection/
├── README.md
├── requirements.txt
├── notebooks/Credit_Card_Fraud_EDA.ipynb
├── sql/financial_fraud_analysis.sql
├── docs/EDA_REPORT.md
├── docs/DATA_VALIDATION.md
├── docs/PORTFOLIO_PUBLICATION_CHECKLIST.md
├── docs/project_requirements.pdf
├── powerbi/README.md
├── excel/README.md
└── data/README.md
```

## Reproduce

1. Install dependencies: `pip install -r requirements.txt`.
2. Obtain the dataset from an authorized source and store it **locally**, not in this repository.
3. Open the notebook and update the dataset path as necessary.
4. Run the SQL queries against a clean MySQL import. Verify **389,002** rows and distinct transaction IDs before analyzing.
5. Open the private Power BI `.pbix` locally, update source paths, refresh, confirm the corrected date range and six KPIs, then export a privacy-reviewed screenshot.

## Limitations and ethics

- This is **descriptive fraud analytics**, not a classifier; do not claim prediction accuracy or fraud prevention impact.
- Fraud labels are rare (about 0.58%), and observational patterns do not prove causation.
- The source includes sensitive card numbers, names, addresses, and birth dates. **Do not publish raw CSV files, an unreviewed `.pbix`, or the private Excel workbook.**
- The supplementary location file has rounded card identifiers; exact card-number joins are not trustworthy without additional validation.
- The original SQL script may include destructive statements and machine-specific file paths; inspect it before execution.

## Key findings

- Fraud-labeled transactions account for **2,252 of 389,002 transactions (approximately 0.58%)**.
- The dashboard displays approximately **$1.17 million** in fraud-labeled transaction value, or approximately **4.26%** of total transaction value, subject to final verification with all report filters cleared.
- The difference between fraud frequency and fraud value share suggests fraudulent transactions have a higher average value than the overall transaction population; this is a descriptive observation, not a causal conclusion.
- Transaction activity is analyzed over **January 2019 through December 2020**, using validated day-month-year timestamps.

## Skills demonstrated

Data validation · Data cleaning · SQL analysis · Python EDA · Fraud segmentation · DAX measures · Power BI dashboard design · Statistical validation · Data privacy

