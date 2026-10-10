"""Banking Analytics - Python analysis (pandas + matplotlib).
Run from this folder:  python banking_analysis.py
"""
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

cust = pd.read_csv("customers.csv")
acc = pd.read_csv("accounts.csv")
txn = pd.read_csv("transactions.csv", parse_dates=["txn_date"])
loans = pd.read_csv("loans.csv")
cards = pd.read_csv("credit_cards.csv")

# ---- Data quality checks ----
for name, df in [("customers", cust), ("accounts", acc), ("transactions", txn), ("loans", loans), ("credit_cards", cards)]:
    print(f"{name:13s} rows={len(df):6d} nulls={int(df.isna().sum().sum())} duplicates={int(df.duplicated().sum())}")

# ---- KPIs ----
overdue = loans[loans.status == "Overdue"]
kpis = {
    "Total customers": len(cust),
    "Total account balance (Rs crore)": acc.balance.sum() / 1e7,
    "Total transaction value (Rs crore)": txn.amount.sum() / 1e7,
    "Total loan value (Rs crore)": loans.loan_amount.sum() / 1e7,
    "Overdue loan exposure (Rs crore)": overdue.loan_amount.sum() / 1e7,
    "Overdue exposure % of loan value": 100 * overdue.loan_amount.sum() / loans.loan_amount.sum(),
    "Dormant accounts %": 100 * (acc.status == "Dormant").mean(),
    "Overall card utilization %": 100 * cards.current_balance.sum() / cards.credit_limit.sum(),
    "High-utilization cards (>=80%)": int((cards.current_balance >= 0.8 * cards.credit_limit).sum()),
}
print("\nKPIs")
for k, v in kpis.items():
    print(f"  {k}: {v:,.1f}")

# ---- Charts ----
m = txn.set_index("txn_date").resample("MS").amount.sum() / 1e7
ax = m.plot(figsize=(9, 4), marker="o", title="Monthly transaction value (Rs crore)")
ax.set_xlabel(""); plt.tight_layout(); plt.savefig("charts/monthly_transaction_value.png", dpi=130); plt.close()

by = loans.assign(is_overdue=loans.status == "Overdue").groupby("loan_type").is_overdue.mean().mul(100).sort_values()
ax = by.plot(kind="barh", figsize=(7, 4), title="Overdue loans % by loan type", color="#c0392b")
ax.set_xlabel("% of loans overdue"); plt.tight_layout(); plt.savefig("charts/overdue_by_loan_type.png", dpi=130); plt.close()

ut = cards.groupby("card_type").apply(lambda d: 100 * d.current_balance.sum() / d.credit_limit.sum()).sort_values()
ax = ut.plot(kind="barh", figsize=(7, 3.5), title="Credit utilization % by card type", color="#2980b9")
ax.set_xlabel("utilization %"); plt.tight_layout(); plt.savefig("charts/utilization_by_card_type.png", dpi=130); plt.close()
print("\nCharts saved to charts/")
