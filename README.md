# Installment Plans — SQL Analytics Project

SQL Server project that analyzes phone installment **contracts** and **payments** at a fixed **reporting date** (point-in-time).  
Outputs include: expected vs. paid amounts, **debt** due to missed/underpaid installments, and **overdue buckets** (0/1/2/3/4+ months).

---

## Business context
An e-commerce store sells phones via installment plans. We need fast, reproducible views for:
1) A **single contract** (details → monthly ledger → summary as of a reporting date).  
2) The **whole portfolio** (finished/not finished, has debt/no debt, counts & debt by overdue buckets).

---

## Data model
**Tables**
- `dbo.installment_plan` — master contracts: `merchant_id`, `contract_number`, `client_id`, `phone_id`, `color_id`, `price`, `date_purch`, `qu_inst`, `inst`
- `dbo.payments` — payment facts: `merchant_id`, `contract_number`, `date_payment`, `payment`

**Composite key**: (`merchant_id`, `contract_number`).

---

## Schema (DDL)
See `sql/01_schema.sql`. Optional constraints & index: `sql/06_constraints_indexes.sql`.

---

## How to run (quick)
1. Run `sql/01_schema.sql`.
2. Import data (see `scripts/02_import_notes.md`).  
   *(Tip: if dates are `dd.MM.yyyy`, import to staging as NVARCHAR and `CONVERT(date, ..., 104)`.)*
3. (Optional) Run validations: `scripts/90_validation_checks.sql`.
4. Single-contract reports:
   - `sql/02_contract_details.sql`
   - `sql/03_contract_payments.sql`
   - `sql/04_contract_summary.sql`
5. Portfolio report:
   - `sql/05_portfolio_debt_summary.sql`

> Default `@reporting_date` in scripts: `2020-04-30`. Adjust `@merchant_id` / `@contract_number` for checks (e.g., 67/227, 84/228, 44/1229).

---

## SQL highlights
- Point-in-time logic with a parameterized `@reporting_date`
- Month arithmetic (`DATEDIFF`, capping expected installments at `qu_inst`)
- Reusable month generator: `util/my_period.sql`
- Clean aggregations for overdue **buckets 0/1/2/3/4+** (counts + debt)

---

## Repository structure

```
/sql
  01_schema.sql
  02_contract_details.sql
  03_contract_payments.sql
  04_contract_summary.sql
  05_portfolio_debt_summary.sql
  06_constraints_indexes.sql
/util
  my_period.sql
/scripts
  02_import_notes.md
  90_validation_checks.sql
/data
/images

```

## SQL files (quick links)
- [01_schema.sql](sql/01_schema.sql)
- [02_contract_details.sql](sql/02_contract_details.sql)
- [03_contract_payments.sql](sql/03_contract_payments.sql)
- [04_contract_summary.sql](sql/04_contract_summary.sql)
- [05_portfolio_debt_summary.sql](sql/05_portfolio_debt_summary.sql)
- [06_constraints_indexes.sql](sql/06_constraints_indexes.sql)
- [02_import_notes.md](scripts/02_import_notes.md)
- [90_validation_checks.sql](scripts/90_validation_checks.sql)

---

<h2>Screenshots</h2>
<img src="images/contract_details.png" alt="Contract details" width="800">
<img src="images/contract_summary.png" alt="Contract summary" width="800">
<img src="images/portfolio_summary.png" alt="Portfolio summary" width="800">

---

## Environment
- SQL Server 2019+ (tested on 2019/2022; compatible with Azure SQL)
- SSMS 20.x (or 19+)

## License
MIT.

## Credits
Implementation and documentation by **Liudmyla Sibikovska**.
