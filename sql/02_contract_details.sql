/* I.1 Contract details with expected installments by reporting date */

DECLARE @reporting_date DATE = '2020-04-30';
DECLARE @merchant_id INT = 84;                   -- change for checks: 67, 84, 44
DECLARE @contract_number INT = 228;              -- change for checks: 227, 228, 1229

SELECT i.merchant_id            AS [Seller ID],
       i.contract_number        AS [Contract #],
       i.qu_inst                AS [Installments (months)],
       i.inst                   AS [Monthly installment, UAH],
       i.date_purch             AS [Purchase/first payment date],
       CASE WHEN DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1 > i.qu_inst
            THEN i.qu_inst
            ELSE DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1
       END                      AS [Expected installments by reporting date],
       i.inst *
       CASE WHEN DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1 > i.qu_inst
            THEN i.qu_inst
            ELSE DATEDIFF(MONTH, i.date_purch, @reporting_date) + 1
       END                      AS [Expected amount by reporting date, UAH]
FROM dbo.installment_plan i
WHERE i.merchant_id = @merchant_id
  AND i.contract_number = @contract_number;
