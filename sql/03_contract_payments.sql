/* I.2 Month-by-month payments ledger + first expected installment flag (i_htbp) */

DECLARE @reporting_date DATE = '2020-04-30';
DECLARE @merchant_id INT = 67;                                                                      -- example: 67 / 84 / 44
DECLARE @contract_number INT = 227;                                                                 -- example: 227 / 228 / 1229

SELECT 
  i.merchant_id,
  i.contract_number,
  a.p_year,
  a.p_month,
  CASE 
    WHEN ROW_NUMBER() OVER (
      PARTITION BY i.merchant_id, i.contract_number, a.p_year, a.p_month
      ORDER BY p.date_payment
    ) = 1
    AND (YEAR(DATEADD(MONTH, i.qu_inst-1, i.date_purch))*100 + MONTH(DATEADD(MONTH, i.qu_inst-1, i.date_purch)))
          >= (a.p_year*100 + a.p_month)
    THEN i.inst ELSE 0
  END AS i_htbp,                                                                                    -- first expected payment in a month
  ISNULL(CONVERT(nvarchar(10), p.date_payment, 104), '') AS date_payment,
  ISNULL(p.payment, 0) AS payment
FROM dbo.installment_plan i
CROSS APPLY dbo.my_period('2018-01-01','2020-04-30') a
LEFT JOIN dbo.payments p
  ON p.merchant_id     = i.merchant_id
 AND p.contract_number = i.contract_number
 AND YEAR(p.date_payment)  = a.p_year
 AND MONTH(p.date_payment) = a.p_month
WHERE i.merchant_id     = @merchant_id
  AND i.contract_number = @contract_number
  AND (a.p_year*100 + a.p_month) BETWEEN
        (YEAR(i.date_purch)*100 + MONTH(i.date_purch))
    AND (YEAR(DATEADD(MONTH, i.qu_inst-1, i.date_purch))*100 + MONTH(DATEADD(MONTH, i.qu_inst-1, i.date_purch)))
ORDER BY a.p_year, a.p_month;
