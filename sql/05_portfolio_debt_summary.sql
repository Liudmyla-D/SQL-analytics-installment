/* II. Portfolio debt summary across all contracts as of a reporting date */

DECLARE @reporting_date DATE = '2020-04-30';

WITH TotalPaid AS (
  SELECT p.merchant_id, p.contract_number, SUM(p.payment) AS total_paid
  FROM dbo.payments p
  WHERE p.date_payment <= @reporting_date
  GROUP BY p.merchant_id, p.contract_number
),
Calc AS (
  SELECT
    i.merchant_id,
    i.contract_number,
    DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1 AS months_passed,
    ISNULL(tp.total_paid, 0) AS total_paid,
    (i.qu_inst * i.inst)     AS total_installment,
    CASE
      WHEN DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1 < i.qu_inst
        THEN (DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1) * i.inst
      ELSE i.qu_inst * i.inst
    END AS expected_by_date,
    CASE
      WHEN DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1 >= i.qu_inst
        THEN 0
      ELSE (i.qu_inst - (DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1)) * i.inst
    END AS remaining_amount,
    CASE
      WHEN DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1 >= i.qu_inst
        THEN 'Finished' ELSE 'Not finished'
    END AS installment_status,
    CASE
      WHEN ISNULL(tp.total_paid, 0) < i.qu_inst * i.inst
        THEN 'Has debt' ELSE 'No debt'
    END AS debt_status,
    CASE
      WHEN ISNULL(tp.total_paid, 0) >= i.qu_inst * i.inst     THEN 0
      WHEN ISNULL(tp.total_paid, 0) >= (i.qu_inst-1) * i.inst THEN 1
      WHEN ISNULL(tp.total_paid, 0) >= (i.qu_inst-2) * i.inst THEN 2
      WHEN ISNULL(tp.total_paid, 0) >= (i.qu_inst-3) * i.inst THEN 3
      ELSE 4
    END AS months_overdue_bucket
  FROM dbo.installment_plan i
  LEFT JOIN TotalPaid tp
    ON tp.merchant_id = i.merchant_id
   AND tp.contract_number = i.contract_number
)
SELECT
  c.installment_status                      AS [Installment period],
  c.debt_status                             AS [Debt status],
  SUM(c.total_installment)                  AS [Installment amount, UAH],
  SUM(c.expected_by_date)                   AS [Expected by reporting date, UAH],
  SUM(c.total_paid)                         AS [Paid by reporting date, UAH],
  COUNT(DISTINCT CONCAT(c.merchant_id,'-',c.contract_number)) AS [Customers],
  SUM(CASE WHEN (c.expected_by_date - c.total_paid) > 0
           THEN (c.expected_by_date - c.total_paid) ELSE 0 END) AS [Debt, UAH],
  SUM(c.remaining_amount)                   AS [Remaining, UAH],

  -- counts by overdue buckets
  SUM(CASE WHEN c.months_overdue_bucket = 0 THEN 1 ELSE 0 END) AS [Clients 0 mo overdue],
  SUM(CASE WHEN c.months_overdue_bucket = 1 THEN 1 ELSE 0 END) AS [Clients 1 mo overdue],
  SUM(CASE WHEN c.months_overdue_bucket = 2 THEN 1 ELSE 0 END) AS [Clients 2 mo overdue],
  SUM(CASE WHEN c.months_overdue_bucket = 3 THEN 1 ELSE 0 END) AS [Clients 3 mo overdue],
  SUM(CASE WHEN c.months_overdue_bucket = 4 THEN 1 ELSE 0 END) AS [Clients 4+ mo overdue],

  -- debt sums by buckets
  SUM(CASE WHEN c.months_overdue_bucket = 0 THEN (c.expected_by_date - c.total_paid) ELSE 0 END) AS [Debt 0 mo],
  SUM(CASE WHEN c.months_overdue_bucket = 1 THEN (c.expected_by_date - c.total_paid) ELSE 0 END) AS [Debt 1 mo],
  SUM(CASE WHEN c.months_overdue_bucket = 2 THEN (c.expected_by_date - c.total_paid) ELSE 0 END) AS [Debt 2 mo],
  SUM(CASE WHEN c.months_overdue_bucket = 3 THEN (c.expected_by_date - c.total_paid) ELSE 0 END) AS [Debt 3 mo],
  SUM(CASE WHEN c.months_overdue_bucket = 4 THEN (c.expected_by_date - c.total_paid) ELSE 0 END) AS [Debt 4+ mo]
FROM Calc c
GROUP BY c.installment_status, c.debt_status
ORDER BY 1;
