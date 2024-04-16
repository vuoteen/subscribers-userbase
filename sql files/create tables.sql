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

/* 'subscriptions' table */
CREATE TABLE subscriptions (
  AutomaticRenewal BOOLEAN,
  UserId VARCHAR(6),
  CancellationDate DATE,
  SubscriptionCountry VARCHAR(50),
  Device VARCHAR(10),   
  Id VARCHAR(6) PRIMARY KEY,
  Number VARCHAR(10),
  OriginalCreatedDate TIMESTAMP,
  SubscriptionType VARCHAR(20),
  Status ENUM('Active', 'Inactive') NOT NULL,
  EndDate DATE,
  StartDate DATE,
  TermType ENUM('DEFINED', 'UNDEFINED') NOT NULL,
  FOREIGN KEY(UserId) REFERENCES users(Id) ON DELETE SET NULL
);

/* 'subscriptionproducts' table */
CREATE TABLE subscriptionproducts (
  SubscriptionId VARCHAR(6),
  CreatedDate DATE,  
  Id VARCHAR(6) PRIMARY KEY,
  Name VARCHAR(50),
  CatalogueId VARCHAR(6),
  FOREIGN KEY(SubscriptionId) REFERENCES subscriptions(Id) ON DELETE SET NULL
);

/* 'productdetails' table */
CREATE TABLE productdetails (
  Model ENUM('FlatFee', 'DiscountPercentage') NOT NULL,
  Type ENUM('Recurring', 'NonRecurring') NOT NULL,  
  ChargedThroughDate DATE,
  CreatedDate TIMESTAMP, 
  EndDate DATE,
  StartDate DATE,
  Id VARCHAR(6) PRIMARY KEY,
  MonthlyPrice DECIMAL(20,10),
  SubscriptionId VARCHAR(6),
  ProductId VARCHAR(6),
  FOREIGN KEY(ProductId) REFERENCES subscriptionproducts(Id) ON DELETE SET NULL,
  FOREIGN KEY(SubscriptionId) REFERENCES subscriptions(Id) ON DELETE SET NULL
)

