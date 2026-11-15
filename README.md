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
| Transaction date range | 2019-01-01 through 2020-06-12 |
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

<img width="1736" height="732" alt="Screenshot 2026-11-14 181910" src="https://github.com/user-attachments/assets/e80b88cd-10ba-49a3-8431-782f65e00f1e" />


<img width="1772" height="728" alt="Screenshot 2026-11-14 182056" src="https://github.com/user-attachments/assets/dd59be57-ba2e-4653-80d2-d67e58421d66" />


<img width="1712" height="650" alt="Screenshot 2026-11-14 182316" src="https://github.com/user-attachments/assets/7e0ecded-cbef-47fa-9037-724ff77868ea" />


The dashboard includes six KPI cards: total transactions, fraudulent transactions, fraud rate, total transaction value, fraudulent transaction amount, and fraudulent amount percentage. The last two quantify the financial share associated with fraud-labeled transactions. The fraud amount percentage should use an all-status denominator so it remains interpretable when the Fraud Status slicer changes.

The MAQ box-and-whisker visual uses `trans_num` in **Axis**, `category` in **Axis category I**, `gender` in **Legend**, and Average of `amt` in **Value**. Quartiles were checked against independent DAX measures for a filtered category/gender subset. Due to apparent visual data-reduction limitations, the chart is intended for **one or two selected categories at a time**; it should not be represented as a fully validated all-category chart. Its whiskers use **Min/Max**, not 1.5×IQR.

The weekly `Inflation_Adj_Amt` formula applies an **assumed fixed 2% annual rate** using `YEAR(TODAY())`. It is **not** a CPI-based adjustment, and its output changes when the model refreshes in a new year. `WeekNum` combines corresponding week numbers across years as required by the project brief.


## Files

```text
Financial-Fraud-Detection/
├── README.md
├── Credit_Card_Fraud_EDA.ipynb
├── Financial_Fraud_Detection.sql
└── requirements.txt
```

- **README.md** – Project overview, methodology, dashboard screenshots, key findings, and limitations.
- **Credit_Card_Fraud_EDA.ipynb** – Python exploratory data analysis, visualizations, and business recommendations.
- **Financial_Fraud_Detection.sql** – MySQL 8.0 script for importing, validating, and analyzing transaction data.
- **requirements.txt** – Python dependencies needed to run the notebook, including Pandas, NumPy, Matplotlib, Seaborn, and Jupyter.



## Reproduce

### 1. Install Python dependencies

```bash
pip install -r requirements.txt
```

### 2. Prepare the dataset

Obtain the dataset from an authorized source and store these files locally:

- `cc_data.csv`
- `location_data.csv`
- `cc_data_dec19.csv`

Do not upload the raw CSV files to this public repository because they contain sensitive information.

### 3. Run the Python notebook

Open `Credit_Card_Fraud_EDA.ipynb` in Jupyter Notebook or VS Code.

Update the CSV path in the notebook if necessary, then restart the kernel and run all cells.

### 4. Configure MySQL

Use MySQL 8.0.

Open `Financial_Fraud_Detection.sql` and update all three `LOAD DATA INFILE` paths to match the location of your CSV files.

The example paths in the SQL script refer to a Windows MySQL server upload directory.

Check the permitted import directory using:

```sql
SHOW VARIABLES LIKE 'secure_file_priv';
```

Ensure that the MySQL server has permission to read the files.

### 5. Import and validate the data

Execute `Financial_Fraud_Detection.sql`.

The script:
- Creates the `finance` database if it does not exist.
- Creates the required transaction and location tables if they do not exist.
- Uses transaction IDs to prevent duplicate transaction imports.
- Imports the December 2019 supplementary data into a separate table.
- Uses `SHOW WARNINGS;` after each CSV import.
- Runs validation and descriptive analysis queries.

Expected validation results:
- Main transactions: 389,002
- Unique transaction IDs: 389,002
- Fraud-labeled transactions: 2,252
- Unique location coordinate pairs: 966
- December 2019 transactions: 42,308

Investigate import warnings or unexpected counts before relying on the analysis.

### 6. Review the Power BI dashboard

Open the private Power BI `.pbix` file locally.

Update data-source paths, refresh the model, and verify the six KPI cards, date range, and dashboard filters.

Only publish screenshots after reviewing them for sensitive information.


## Limitations and ethics

- This is **descriptive fraud analytics**, not a classifier; do not claim prediction accuracy or fraud prevention impact.
- Fraud labels are rare (about 0.58%), and observational patterns do not prove causation.
- The source includes sensitive card numbers, names, addresses, and birth dates. **Do not publish raw CSV files, an unreviewed `.pbix`, or the private Excel workbook.**
- The supplementary location file has rounded card identifiers; exact card-number joins are not trustworthy without additional validation.
- The SQL script uses environment-specific CSV paths. Update these paths, check MySQL import permissions, and review the script before execution.


## Key Insights & Business Recommendations

1. **Fraud Impact:** Only 0.58% of transactions were fraudulent, but they represented 4.26% ($1.17M) of total transaction value. Prioritize monitoring higher-value suspicious transactions.
2. **Transaction Trends:** Monthly transaction volumes fluctuated significantly, with a peak in late 2019. Monitor unusual changes in transaction activity.
3. **Geographic Patterns:** Fraudulent transactions occurred across the US, with visible concentrations in the eastern regions. Compare regional fraud rates to identify higher-risk areas.
4. **Spending Behavior:** Transaction amounts varied by category and gender. Use category-specific spending patterns to help identify unusual transactions.
5. **Business Value:** Combining financial KPIs, time trends, geographic analysis, and transaction distributions supports more informed fraud monitoring and investigation.
- Transaction activity is analyzed over **January 2019 through December 2020**, using validated day-month-year timestamps.

## Skills demonstrated

Data validation · Data cleaning · SQL analysis · Python EDA · Fraud segmentation · DAX measures · Power BI dashboard design · Statistical validation · Data privacy

