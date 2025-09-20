/* Installment Plans — SQL Analytics Project
   Schema (DDL). Engine: SQL Server.
*/
CREATE TABLE dbo.installment_plan (
  contract_number INT NOT NULL,
  client_id       INT NOT NULL,
  phone_id        INT NOT NULL,
  color_id        TINYINT NOT NULL,
  merchant_id     TINYINT NOT NULL,
  price           NUMERIC(10,2) NULL,
  date_purch      DATE NULL,             -- first payment date
  qu_inst         INT NOT NULL,          -- number of installments (months)
  inst            INT NULL               -- monthly installment amount (UAH)
);
GO

CREATE TABLE dbo.payments (
  merchant_id     TINYINT NOT NULL,
  contract_number INT NOT NULL,
  date_payment    DATE NULL,
  payment         INT NULL
);
GO

-- Optional index:
-- CREATE INDEX IX_payments_contract ON dbo.payments(merchant_id, contract_number, date_payment);

