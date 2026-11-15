-- 3) Data Loading / Setup
CREATE DATABASE IF NOT EXISTS finance;
USE finance;

-- Drop & recreate tables
CREATE TABLE cc_data (
  idx BIGINT NULL,
  trans_date_trans_time DATETIME NULL,
  cc_num BIGINT NULL,
  merchant VARCHAR(255) NULL,
  category VARCHAR(100) NULL,
  amt DECIMAL(12,2) NULL,
  first VARCHAR(100) NULL,
  last VARCHAR(100) NULL,
  gender VARCHAR(10) NULL,
  street VARCHAR(255) NULL,
  city VARCHAR(100) NULL,
  state VARCHAR(10) NULL,
  zip VARCHAR(20) NULL,
  lat DECIMAL(10,6) NULL,
  `long` DECIMAL(10,6) NULL,
  city_pop BIGINT NULL,
  job VARCHAR(255) NULL,
  dob DATE NULL,
  trans_num VARCHAR(80) NULL,
  unix_time BIGINT NULL,
  merch_lat DECIMAL(10,6) NULL,
  merch_long DECIMAL(10,6) NULL,
  is_fraud TINYINT NULL,
  INDEX idx_cc_num (cc_num),
  INDEX idx_merchant (merchant),
  INDEX idx_category (category),
  INDEX idx_is_fraud (is_fraud),
  INDEX idx_trans_dt (trans_date_trans_time)
);

CREATE TABLE location_data (
  location_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  cc_num BIGINT,
  lat DECIMAL(10,6),
  `long` DECIMAL(10,6),
  INDEX idx_ccnum (cc_num)
);

-- Load data (edit file paths for your machine)
-- Option A: LOAD DATA (fast). Requires LOCAL INFILE enabled in client/server config.
-- Example:
SET GLOBAL local_infile = 1;
show global variables like 'local_infile';
SHOW VARIABLES LIKE 'secure_file_priv';

--
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cc_data.csv'
INTO TABLE cc_data
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(idx, @trans_dt, cc_num, merchant, category, amt, first, last, gender, street, city, state, zip,
lat, `long`, city_pop, job, @dob, trans_num, unix_time, merch_lat, merch_long, is_fraud)
SET
  trans_date_trans_time = STR_TO_DATE(@trans_dt, '%d-%m-%Y %H:%i'),
  dob = STR_TO_DATE(@dob, '%d-%m-%Y');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/location_data.csv'
INTO TABLE location_data
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(cc_num, lat, `long`);

-- 4) Data Exploration with SQL

-- A) Total number of transactions
SELECT COUNT(*) AS total_transactions
FROM cc_data;

-- B) Top 10 most frequent merchants
SELECT merchant, COUNT(*) AS txn_count
FROM cc_data
GROUP BY merchant
ORDER BY txn_count DESC
LIMIT 10;

-- C) Average transaction amount per category
SELECT
    category,
    ROUND(AVG(amt), 2) AS avg_transaction_amount
FROM cc_data
GROUP BY category
ORDER BY avg_transaction_amount DESC;

-- D) Fraud count and percent of total
SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END)
        AS fraudulent_transactions,
    ROUND(
        100.0 * SUM(CASE WHEN is_fraud = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS fraud_percentage
FROM cc_data;

-- E) Join cc_data and location_data to identify the latitude/longitude of each transaction

SELECT 
    c.trans_date_trans_time,
	c.cc_num,
    c.amt,
    l.lat,
    l.long
FROM cc_data c
JOIN location_data l
ON c.cc_num = l.cc_num;

-- F) City with highest population (based on cc_data city_pop)
SELECT city, state, MAX(city_pop) AS max_city_pop
FROM cc_data
GROUP BY city, state
ORDER BY max_city_pop DESC
LIMIT 1;

-- G) Earliest and latest transaction timestamps
SELECT
  MIN(trans_date_trans_time) AS earliest_txn,
  MAX(trans_date_trans_time) AS latest_txn
FROM cc_data;

-- 5) Using Data Aggregation with SQL

-- A) Total amount spent across all transactions
SELECT SUM(amt) AS total_amt_spent
FROM cc_data;

-- B) How many transactions occurred in each category?
SELECT category, COUNT(*) AS txn_count
FROM cc_data
GROUP BY category
ORDER BY txn_count DESC;

-- C) Average transaction amount for each gender
SELECT gender, AVG(amt) AS avg_amt
FROM cc_data
GROUP BY gender;

-- D) Which day of the week has the highest average transaction amount?
-- MySQL DAYOFWEEK(): 1=Sunday ... 7=Saturday
SELECT DAYOFWEEK(trans_date_trans_time) AS dow,
       AVG(amt) AS avg_amt
FROM cc_data
GROUP BY dow
ORDER BY avg_amt DESC
LIMIT 1;

