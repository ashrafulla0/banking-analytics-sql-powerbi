# Banking Analytics & Reporting

**Business problem:** Where are the risk and growth opportunities in a retail bank's portfolio — overdue loans, dormant accounts, over-used credit cards and high-value customers?

## Dataset
Synthetic dataset generated programmatically with Python (fixed random seed). It contains no real customer or bank data.

| Table | Rows |
|---|---|
| customers | 5,000 |
| accounts | 6,000 |
| transactions (Jan 2024 – Dec 2025) | 60,000 |
| loans | 2,000 |
| credit_cards | 3,000 |
| branches | 20 |

**Total: 76,020 records across 6 tables.**

## Tools
MySQL 8 (joins, CTEs, window functions) · Python (pandas, matplotlib) · Power BI (DAX)

## Repository contents
- `*.csv` — the 6 tables
- `schema_and_load.sql` — creates the MySQL tables and loads the CSVs
- `banking_15_questions.sql` — 15 business questions answered in SQL
- `banking_analysis.py` — data-quality checks, KPIs and charts
- `charts/` — charts produced by the Python script
- `dashboard.png` / `Banking_Dashboard.pbix` — Power BI dashboard (one page)

## Key insights
1. **Overdue loans:** 227 of 2,000 loans (11.3%) are overdue, worth **₹35.7 crore, or 8.8% of the ₹404 crore loan book**.
2. **Personal loans are the weak spot:** 17.7% of personal loans are overdue, about 2.6x the rate of home loans (6.7%). Home loans still carry the largest overdue amount (₹14.7 crore) because of ticket size.
3. **Dormant accounts:** 14.2% of accounts (854 of 6,000) are dormant, holding ₹5.5 crore in balances.
4. **Credit cards:** 191 cards (6.4%) are at 80%+ utilization, and 173 of them are Silver. Silver utilization averages 54.8% versus 29.7% for Platinum.
5. **Premium customers:** 21% of customers, but an average balance of ₹4.8 lakh versus ₹0.6 lakh for Retail (about 8x).
6. **Transaction mix:** NEFT/IMPS is 12% of transactions but 43% of transaction value; UPI is 35% of transactions but only 7.5% of value.
7. **Combined risk:** 180 customers hold both an active account and an overdue loan, so collections can reach them through the account relationship.
8. **Growth:** monthly transaction value rose from ₹1.1 crore (Jan 2024) to ₹3.8 crore (Dec 2025).

## Recommendations
- Tighten underwriting and early-warning follow-up on personal loans.
- Run a reactivation campaign for dormant accounts.
- Review credit limits or offer EMI conversion for the 173 high-utilization Silver cards.
- Prioritise the 180 customers with an overdue loan and an active account for collections outreach.

## How to run
1. Create the tables: run `schema_and_load.sql` (change the CSV folder path first).
2. Run `banking_15_questions.sql` in MySQL Workbench.
3. `pip install pandas matplotlib` then `python banking_analysis.py`.
4. Open the Power BI file and refresh from the CSVs.

## Power BI dashboard
![Dashboard](dashboard.png)
