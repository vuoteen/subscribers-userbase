/* 'users' table */
CREATE TABLE users (
  AccountBalance DECIMAL(8,2),
  IsTestUser BOOLEAN,
  InvoicedOnDay VARCHAR(2),
  CreatedDate DATE,
  Currency VARCHAR(3),
  Id VARCHAR(6) PRIMARY KEY,
  LatestInvoiceDate DATE,
  Name VARCHAR(32)
);