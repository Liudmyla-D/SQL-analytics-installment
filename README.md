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


---

## Screenshots
Add 2–4 PNGs into `/images` and reference them here:
- `![Contract details](images/contract_details.png)`
- `![Payments ledger](images/contract_payments.png)`
- `![Contract summary](images/contract_summary.png)`
- `![Portfolio summary](images/portfolio_summary.png)`

---

## License
MIT.

## Credits
Implementation and documentation by **Liudmyla Sibikovska**.

