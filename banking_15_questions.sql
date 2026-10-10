-- Banking Analytics & Reporting | 15 business questions (MySQL 8.0)
-- Tables: branches, customers, accounts, transactions, loans, credit_cards

-- Q1: How many customers are in each customer segment?
SELECT segment, COUNT(*) AS customers
FROM customers
GROUP BY segment
ORDER BY customers DESC;

-- Q2: How many accounts are Active, Dormant and Closed?
SELECT status, COUNT(*) AS accounts
FROM accounts
GROUP BY status
ORDER BY accounts DESC;

-- Q3: What is the total balance by account type?
SELECT account_type, COUNT(*) AS accounts, ROUND(SUM(balance), 0) AS total_balance
FROM accounts
GROUP BY account_type
ORDER BY total_balance DESC;

-- Q4: Monthly transaction volume and value, with month-over-month growth (window function)
WITH monthly AS (
  SELECT SUBSTR(txn_date, 1, 7) AS txn_month,
         COUNT(*) AS txn_count,
         ROUND(SUM(amount), 0) AS txn_value
  FROM transactions
  GROUP BY SUBSTR(txn_date, 1, 7)
)
SELECT txn_month, txn_count, txn_value,
       ROUND(100.0 * (txn_value - LAG(txn_value) OVER (ORDER BY txn_month))
             / LAG(txn_value) OVER (ORDER BY txn_month), 1) AS mom_growth_pct
FROM monthly
ORDER BY txn_month;

-- Q5: Which transaction types have the highest value?
SELECT txn_type, COUNT(*) AS txn_count,
       ROUND(SUM(amount), 0) AS total_value,
       ROUND(AVG(amount), 0) AS avg_value
FROM transactions
GROUP BY txn_type
ORDER BY total_value DESC;

-- Q6: Top 10 customers by transaction value (RANK window function)
WITH cust_txn AS (
  SELECT c.customer_id, c.customer_name, c.segment, ROUND(SUM(t.amount), 0) AS total_value
  FROM transactions t
  JOIN accounts a ON t.account_id = a.account_id
  JOIN customers c ON a.customer_id = c.customer_id
  GROUP BY c.customer_id, c.customer_name, c.segment
)
SELECT RANK() OVER (ORDER BY total_value DESC) AS rnk, customer_id, customer_name, segment, total_value
FROM cust_txn
ORDER BY rnk
LIMIT 10;

-- Q7: Loan portfolio by loan type
SELECT loan_type, COUNT(*) AS loans,
       ROUND(SUM(loan_amount), 0) AS total_loan_value,
       ROUND(AVG(interest_rate), 2) AS avg_interest_rate
FROM loans
GROUP BY loan_type
ORDER BY total_loan_value DESC;

-- Q8: How much loan exposure is overdue (overall and by loan type)?
WITH by_type AS (
  SELECT loan_type,
         SUM(loan_amount) AS total_loan_value,
         SUM(CASE WHEN status = 'Overdue' THEN loan_amount ELSE 0 END) AS overdue_loan_value,
         SUM(overdue_amount) AS overdue_amount,
         SUM(CASE WHEN status = 'Overdue' THEN 1 ELSE 0 END) AS overdue_loans,
         COUNT(*) AS loans
  FROM loans
  GROUP BY loan_type
)
SELECT loan_type, loans, overdue_loans,
       ROUND(100.0 * overdue_loans / loans, 1) AS overdue_loan_pct,
       ROUND(overdue_loan_value, 0) AS overdue_loan_value,
       ROUND(100.0 * overdue_loan_value / total_loan_value, 1) AS overdue_value_pct
FROM by_type
ORDER BY overdue_value_pct DESC;

-- Q9: Which customers have overdue loans? (largest overdue per loan type, ROW_NUMBER)
WITH od AS (
  SELECT l.loan_id, l.loan_type, c.customer_id, c.customer_name, l.loan_amount, l.overdue_amount,
         ROW_NUMBER() OVER (PARTITION BY l.loan_type ORDER BY l.overdue_amount DESC) AS rn
  FROM loans l JOIN customers c ON l.customer_id = c.customer_id
  WHERE l.status = 'Overdue'
)
SELECT loan_type, customer_id, customer_name, loan_amount, overdue_amount
FROM od WHERE rn <= 3
ORDER BY loan_type, overdue_amount DESC;

-- Q10: Which credit cards have high utilization (80% or more)?
SELECT card_id, customer_id, card_type, credit_limit, current_balance,
       ROUND(100.0 * current_balance / credit_limit, 1) AS utilization_pct
FROM credit_cards
WHERE current_balance >= 0.8 * credit_limit
ORDER BY utilization_pct DESC;

-- Q11: Average credit utilization by card type
SELECT card_type, COUNT(*) AS cards,
       ROUND(100.0 * SUM(current_balance) / SUM(credit_limit), 1) AS utilization_pct,
       SUM(CASE WHEN current_balance >= 0.8 * credit_limit THEN 1 ELSE 0 END) AS high_util_cards
FROM credit_cards
GROUP BY card_type
ORDER BY utilization_pct DESC;

-- Q12: How many accounts are there in each city (via branch)?
SELECT b.city, COUNT(*) AS accounts
FROM accounts a JOIN branches b ON a.branch_id = b.branch_id
GROUP BY b.city
ORDER BY accounts DESC;

-- Q13: Which customer segments have the highest average balance (open accounts only)?
SELECT c.segment, COUNT(*) AS accounts, ROUND(AVG(a.balance), 0) AS avg_balance
FROM accounts a JOIN customers c ON a.customer_id = c.customer_id
WHERE a.status <> 'Closed'
GROUP BY c.segment
ORDER BY avg_balance DESC;

-- Q14: What percentage of accounts are dormant?
SELECT ROUND(100.0 * SUM(CASE WHEN status = 'Dormant' THEN 1 ELSE 0 END) / COUNT(*), 1) AS dormant_pct
FROM accounts;

-- Q15: Customers who have BOTH an active account and an overdue loan (by segment)
WITH risky AS (
  SELECT DISTINCT a.customer_id
  FROM accounts a
  JOIN loans l ON a.customer_id = l.customer_id
  WHERE a.status = 'Active' AND l.status = 'Overdue'
)
SELECT c.segment, COUNT(*) AS customers
FROM risky r JOIN customers c ON r.customer_id = c.customer_id
GROUP BY c.segment
ORDER BY customers DESC;
