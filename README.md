# SQL-analytics-installment
SQL project of installment contracts: expected vs. paid, debt, and overdue buckets (point-in-time).


## How to run (quick)
1. Run `sql/01_schema.sql`.
2. Import data (see `scripts/02_import_notes.md`).
3. (Optional) Run validations: `scripts/90_validation_checks.sql`.
4. Single-contract reports:
   - `sql/02_contract_details.sql`
   - `sql/03_contract_payments.sql`
   - `sql/04_contract_summary.sql`
5. Portfolio report:
   - `sql/05_portfolio_debt_summary.sql`

> Default reporting date in scripts: `2020-04-30`. Adjust `@merchant_id` / `@contract_number` as needed.
