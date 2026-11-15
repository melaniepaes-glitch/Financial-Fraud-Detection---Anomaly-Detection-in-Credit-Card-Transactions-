-- FINANCIAL FRAUD DETECTION | MySQL 8.0 | Revised, rerunnable import
-- Source files: cc_data.csv (389002), location_data.csv (979),
--               cc_data_dec19.csv (42308, ALL already in cc_data.csv).
-- IMPORTANT: Back up your database before modifying existing tables.
-- This script does not DROP or TRUNCATE tables. It creates a new set of
-- portfolio tables so your existing finance.cc_data is not altered.
-- Change paths to where your MySQL SERVER can read the CSV files.
-- LOAD DATA INFILE requires FILE privilege and permitted secure_file_priv path.
-- For local client files use LOAD DATA LOCAL INFILE with a configured client.
-- ============================================================
-- CSV FILE PATH CONFIGURATION
-- ============================================================
-- Before running this script:
--
-- 1. Download the authorized source dataset locally.
-- 2. Locate the following three CSV files:
--      cc_data.csv
--      location_data.csv
--      cc_data_dec19.csv
--
-- 3. Update the file paths in all three LOAD DATA INFILE
--    statements to match your local MySQL setup.
--
-- Example Windows MySQL server upload directory:
-- C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/
--
-- LOAD DATA INFILE reads files from the MySQL server's
-- filesystem, not necessarily your personal computer.
--
-- Check the permitted import directory using:
-- SHOW VARIABLES LIKE 'secure_file_priv';
--
-- If importing client-side files, use LOAD DATA LOCAL INFILE
-- only when it is appropriately enabled and permitted.
--
-- Do not upload the source CSV files to this public repository.
-- ============================================================


CREATE DATABASE IF NOT EXISTS finance;
USE finance;

-- 1) Main transaction table: unique trans_num prevents double imports.
-- Card numbers are identifiers, not numeric measures. Stored as CHAR to
-- preserve exact digits and prevent accidental numerical operations.
CREATE TABLE IF NOT EXISTS cc_data (
    idx BIGINT NULL,
    trans_date_trans_time DATETIME NULL,
    cc_num VARCHAR(32) NULL,
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
    trans_num VARCHAR(80) NOT NULL,
    unix_time BIGINT NULL,
    merch_lat DECIMAL(10,6) NULL,
    merch_long DECIMAL(10,6) NULL,
    is_fraud TINYINT NULL,
    PRIMARY KEY (trans_num),
    INDEX idx_merchant (merchant),
    INDEX idx_category (category),
    INDEX idx_is_fraud (is_fraud),
    INDEX idx_trans_dt (trans_date_trans_time)
);

-- Import is idempotent: IGNORE skips existing transaction IDs.
-- If a duplicate ID has conflicting values, investigate it; IGNORE does
-- NOT update the existing record. Check warnings after the import.
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cc_data.csv'
IGNORE INTO TABLE cc_data
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(idx, @trans_dt, cc_num, merchant, category, amt, first, last,
 gender, street, city, state, zip, lat, `long`, city_pop, job,
 @dob, trans_num, unix_time, merch_lat, merch_long, is_fraud)
SET trans_date_trans_time = STR_TO_DATE(@trans_dt, '%d-%m-%Y %H:%i'),
    dob = STR_TO_DATE(@dob, '%d-%m-%Y'); SHOW WARNINGS;

-- 2) Location reference table.
-- location_data.csv cc_num values are rounded scientific notation; they
-- cannot be used for a reliable exact credit-card-number join.
-- Retain the source token for auditing, but use coordinates as join keys.
-- 979 source rows contain 966 distinct coordinate pairs; UNIQUE(lat,long)
-- makes the location lookup one-to-one and prevents duplicate join results.
CREATE TABLE IF NOT EXISTS location_data (
    location_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    cc_num_rounded VARCHAR(40) NULL,
    lat DECIMAL(10,6) NOT NULL,
    `long` DECIMAL(10,6) NOT NULL,
    UNIQUE KEY uq_location_coordinates (lat, `long`)
); SHOW WARNINGS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/location_data.csv'
IGNORE INTO TABLE location_data
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(cc_num_rounded, lat, `long`); SHOW WARNINGS;

-- 3) December 2019 subset: separate table, NOT appended to main table.
-- This file has 20 columns and lacks unix_time, merch_lat, merch_long.
-- All 42308 trans_num values already appear in the main file.
CREATE TABLE IF NOT EXISTS cc_data_dec19 (
    idx BIGINT NULL,
    trans_date_trans_time DATETIME NULL,
    cc_num VARCHAR(32) NULL,
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
    trans_num VARCHAR(80) NOT NULL,
    is_fraud TINYINT NULL,
    PRIMARY KEY (trans_num)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cc_data_dec19.csv'
IGNORE INTO TABLE cc_data_dec19
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(idx, @trans_dt, cc_num, merchant, category, amt, first, last,
 gender, street, city, state, zip, lat, `long`, city_pop, job,
 @dob, trans_num, is_fraud)
SET trans_date_trans_time = STR_TO_DATE(@trans_dt, '%d-%m-%Y %H:%i'),
    dob = STR_TO_DATE(@dob, '%d-%m-%Y'); SHOW WARNINGS;

-- 4) Data validation. Expected counts: 389002, 966, 42308.
SELECT COUNT(*) AS main_rows,
       COUNT(DISTINCT trans_num) AS unique_transactions,
       SUM(is_fraud = 1) AS fraud_transactions
FROM cc_data;

SELECT COUNT(*) AS unique_locations FROM location_data;
SELECT COUNT(*) AS december_rows FROM cc_data_dec19;

-- No unmatched transaction coordinates expected.
SELECT COUNT(*) AS unmatched_location_rows
FROM cc_data c
LEFT JOIN location_data l
  ON c.lat = l.lat AND c.`long` = l.`long`
WHERE l.location_id IS NULL;

-- No December-only transaction IDs expected.
SELECT COUNT(*) AS december_ids_missing_from_main
FROM cc_data_dec19 d
LEFT JOIN cc_data c ON c.trans_num = d.trans_num
WHERE c.trans_num IS NULL;

-- 5) Required SQL data exploration.
-- A. Total number of transactions
SELECT COUNT(*) AS total_transactions FROM cc_data;

-- B. Top 10 merchants by transaction frequency
SELECT merchant, COUNT(*) AS txn_count
FROM cc_data
GROUP BY merchant
ORDER BY txn_count DESC
LIMIT 10;

-- C. Average transaction amount by category
SELECT category, ROUND(AVG(amt), 2) AS avg_transaction_amount
FROM cc_data
GROUP BY category
ORDER BY avg_transaction_amount DESC;

-- D. Fraud count and fraud percentage
SELECT COUNT(*) AS total_transactions,
       SUM(is_fraud = 1) AS fraudulent_transactions,
       ROUND(100.0 * SUM(is_fraud = 1) / NULLIF(COUNT(*), 0), 2) AS fraud_percentage
FROM cc_data;

-- E. Safe one-to-one coordinate join: rounded cc_num is NOT used.
SELECT c.trans_num, c.trans_date_trans_time, c.amt,
       l.lat, l.`long`
FROM cc_data c
JOIN location_data l
  ON c.lat = l.lat AND c.`long` = l.`long`
LIMIT 100;

-- F. Largest city population: location_data has no city/population fields.
-- Use city_pop from the main transaction table instead.
SELECT city, state, MAX(city_pop) AS max_city_pop
FROM cc_data
GROUP BY city, state
ORDER BY max_city_pop DESC
LIMIT 1;

-- G. Earliest and latest transaction timestamps
SELECT MIN(trans_date_trans_time) AS earliest_txn,
       MAX(trans_date_trans_time) AS latest_txn
FROM cc_data;

-- 6) Required SQL aggregations.
-- A. Total transaction amount
SELECT ROUND(SUM(amt), 2) AS total_amt_spent
FROM cc_data;

-- B. Transaction counts by category
SELECT category, COUNT(*) AS txn_count
FROM cc_data
GROUP BY category
ORDER BY txn_count DESC;

-- C. Average amount by gender
SELECT gender, ROUND(AVG(amt), 2) AS avg_amt
FROM cc_data
GROUP BY gender;

-- D. Weekday with highest average amount
SELECT DAYNAME(trans_date_trans_time) AS weekday,
       ROUND(AVG(amt), 2) AS avg_amt
FROM cc_data
GROUP BY DAYOFWEEK(trans_date_trans_time), DAYNAME(trans_date_trans_time)
ORDER BY avg_amt DESC
LIMIT 1;

-- 7) December subset analysis: compare separately, do not union into main.
SELECT COUNT(*) AS december_transactions,
       ROUND(SUM(amt), 2) AS december_amount,
       SUM(is_fraud = 1) AS december_fraud_count
FROM cc_data_dec19;
