# Import notes (SQL Server / SSMS)

## Option A — SSMS Import Wizard
1) DB → **Tasks → Import Data…**
2) **Data source:** Excel/CSV → pick files from `/data`.
3) **Destination:** your DB (`dbo.installment_plan`, `dbo.payments`).
4) Map columns and types. Dates must be real `DATE` (yyyy-mm-dd).
5) Run import, then run validation (see `scripts/90_validation_checks.sql`).

## Option B — BULK INSERT (CSV)
```sql
-- Example for payments.csv with columns: merchant_id,contract_number,date_payment,payment
BULK INSERT dbo.payments
FROM 'C:\path\payments.csv'
WITH (
  FIRSTROW = 2,           -- skip header
  FIELDTERMINATOR = ',', 
  ROWTERMINATOR = '0x0a', -- LF
  TABLOCK, KEEPNULLS
);

-- Example for installment_plan.csv
BULK INSERT dbo.installment_plan
FROM 'C:\path\installment_plan.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK, KEEPNULLS);
