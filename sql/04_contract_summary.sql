/* I.3 Contract summary: expected vs. paid, remaining, and debt due to missed/underpaid months */

DECLARE @reporting_date  DATE = '2020-04-30';
DECLARE @merchant_id     INT  = 84;   -- examples to test: 67 / 84 / 44
DECLARE @contract_number INT  = 228;  -- examples to test: 227 / 228 / 1229
DECLARE @MaxNumber       INT  = 120;  -- upper bound for expected months

-- 1) Numbers 1..@MaxNumber
WITH Numbers AS (
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM Numbers WHERE n + 1 <= @MaxNumber
),

-- 2) Expected monthly payments up to @reporting_date
ExpectedPayments AS (
  SELECT i.merchant_id,
         i.contract_number,
         i.inst,
         DATEADD(MONTH, n.n - 1, i.date_purch) AS expected_date
  FROM dbo.installment_plan i
  JOIN Numbers n ON n.n BETWEEN 1 AND i.qu_inst
  WHERE DATEADD(MONTH, n.n - 1, i.date_purch) <= @reporting_date
    AND i.merchant_id = @merchant_id
    AND i.contract_number = @contract_number
),

-- 3) Total actually paid for the contract by @reporting_date
TotalPaid AS (
  SELECT p.merchant_id, p.contract_number, SUM(p.payment) AS total_paid
  FROM dbo.payments p
  WHERE p.date_payment <= @reporting_date
    AND p.merchant_id = @merchant_id
    AND p.contract_number = @contract_number
  GROUP BY p.merchant_id, p.contract_number
),

-- 4) Debt formed specifically by missed/underpaid installments by @reporting_date
Debt AS (
  SELECT ep.merchant_id, ep.contract_number,
         CASE WHEN SUM(ep.inst) - ISNULL(MAX(tp.total_paid),0) > 0
              THEN SUM(ep.inst) - ISNULL(MAX(tp.total_paid),0) ELSE 0 END AS debt_missed
  FROM ExpectedPayments ep
  LEFT JOIN TotalPaid tp
    ON tp.merchant_id = ep.merchant_id AND tp.contract_number = ep.contract_number
  GROUP BY ep.merchant_id, ep.contract_number
)
SELECT i.merchant_id                                  AS [Seller ID],
       i.contract_number                              AS [Contract #],
       -- expected by @reporting_date (capped by total number of installments)
       i.inst * CASE
                  WHEN DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1 > i.qu_inst
                  THEN i.qu_inst
                  ELSE DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1
                END                                   AS [Expected by reporting date, UAH],
       ISNULL(tp.total_paid, 0)                       AS [Paid by reporting date, UAH],
       i.inst * i.qu_inst - ISNULL(tp.total_paid, 0)  AS [Remaining till contract end, UAH],
       ISNULL(d.debt_missed, 0)                       AS [Debt due to missed/underpaid, UAH]
FROM dbo.installment_plan i
LEFT JOIN TotalPaid tp
  ON tp.merchant_id = i.merchant_id AND tp.contract_number = i.contract_number
LEFT JOIN Debt d
  ON d.merchant_id  = i.merchant_id AND d.contract_number = i.contract_number
WHERE i.merchant_id = @merchant_id
  AND i.contract_number = @contract_number
OPTION (MAXRECURSION 0);
