/* Primary key on contracts, FK from payments, and useful index */
-- Make sure there are no duplicate (merchant_id, contract_number) in installment_plan before running.

ALTER TABLE dbo.installment_plan
  ADD CONSTRAINT PK_installment_plan
  PRIMARY KEY (merchant_id, contract_number);

ALTER TABLE dbo.payments
  ADD CONSTRAINT FK_payments_plan
  FOREIGN KEY (merchant_id, contract_number)
  REFERENCES dbo.installment_plan(merchant_id, contract_number);

CREATE INDEX IX_payments_contract
  ON dbo.payments(merchant_id, contract_number, date_payment);
