/* Basic validations after import */

-- 1) duplicates in installment_plan
SELECT merchant_id, contract_number, COUNT(*) AS cnt
FROM dbo.installment_plan
GROUP BY merchant_id, contract_number
HAVING COUNT(*) > 1;

-- 2) payments date range
SELECT MIN(date_payment) AS min_date, MAX(date_payment) AS max_date
FROM dbo.payments;

-- 3) null sanity in critical fields
SELECT * FROM dbo.installment_plan
WHERE date_purch IS NULL OR qu_inst IS NULL OR inst IS NULL;

-- 4) quick row counts
SELECT (SELECT COUNT(*) FROM dbo.installment_plan) AS contracts,
       (SELECT COUNT(*) FROM dbo.payments)        AS payments;
