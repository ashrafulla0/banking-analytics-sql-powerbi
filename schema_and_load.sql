-- MySQL 8.0 setup for Banking Analytics & Reporting
-- Run once in MySQL Workbench, then run banking_15_questions.sql
-- If LOAD DATA is blocked, use Workbench: right-click table > Table Data Import Wizard.

CREATE DATABASE IF NOT EXISTS banking_analytics;
USE banking_analytics;

CREATE TABLE branches (
  branch_id VARCHAR(10) PRIMARY KEY, branch_name VARCHAR(50), city VARCHAR(30));
CREATE TABLE customers (
  customer_id VARCHAR(10) PRIMARY KEY, customer_name VARCHAR(60), city VARCHAR(30),
  segment VARCHAR(10), age INT, join_date DATE);
CREATE TABLE accounts (
  account_id VARCHAR(10) PRIMARY KEY, customer_id VARCHAR(10), branch_id VARCHAR(10),
  account_type VARCHAR(10), status VARCHAR(10), balance DECIMAL(14,2), open_date DATE,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (branch_id) REFERENCES branches(branch_id));
CREATE TABLE transactions (
  txn_id VARCHAR(10) PRIMARY KEY, account_id VARCHAR(10), txn_date DATE,
  txn_type VARCHAR(20), direction VARCHAR(10), amount DECIMAL(14,2),
  FOREIGN KEY (account_id) REFERENCES accounts(account_id));
CREATE TABLE loans (
  loan_id VARCHAR(10) PRIMARY KEY, customer_id VARCHAR(10), loan_type VARCHAR(15),
  loan_amount DECIMAL(14,2), interest_rate DECIMAL(5,2), tenure_months INT, status VARCHAR(10),
  overdue_amount DECIMAL(14,2), disbursal_date DATE,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id));
CREATE TABLE credit_cards (
  card_id VARCHAR(10) PRIMARY KEY, customer_id VARCHAR(10), card_type VARCHAR(10),
  credit_limit DECIMAL(12,2), current_balance DECIMAL(12,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id));

-- Change the folder path below to where you saved the CSV files (use forward slashes)
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'C:/banking/branches.csv' INTO TABLE branches FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/banking/customers.csv' INTO TABLE customers FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/banking/accounts.csv' INTO TABLE accounts FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/banking/transactions.csv' INTO TABLE transactions FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/banking/loans.csv' INTO TABLE loans FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA LOCAL INFILE 'C:/banking/credit_cards.csv' INTO TABLE credit_cards FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- Row-count check: expect 20 / 5000 / 6000 / 60000 / 2000 / 3000
SELECT 'branches' t, COUNT(*) n FROM branches UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts UNION ALL SELECT 'transactions', COUNT(*) FROM transactions
UNION ALL SELECT 'loans', COUNT(*) FROM loans UNION ALL SELECT 'credit_cards', COUNT(*) FROM credit_cards;
