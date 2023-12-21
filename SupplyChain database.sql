CREATE DATABASE SupplyChain;
USE SupplyChain
GO

-- Products table
CREATE TABLE DimProducts (
	[SKU] VARCHAR(50) NOT NULL,
	[Product type] VARCHAR(45) NULL,
	[Price] DECIMAL NULL,
	[Availability] INT NULL,
	PRIMARY KEY (SKU)
);
GO

-- Inventory
CREATE TABLE DimInventory (
	[SKU] VARCHAR(50) NOT NULL,
	[Stock levels] INT NULL,
	[Lead times] INT NULL,
	[Production volumes] INT NULL,
	[Manufacturing lead time] INT NULL,
	[Manufacturing costs] DECIMAL NULL,
	[Inspection results] VARCHAR(45) NULL,
	[Defect rates] DECIMAL NULL,
	PRIMARY KEY (SKU),
);
GO

-- Sales
CREATE TABLE FactSales (
	[SKU] VARCHAR(50) NOT NULL,
	[Supplier name] VARCHAR(50) NOT NULL,
	[Number of products sold] INT NULL,
	[Revenue generated] DECIMAL NULL,
	[Customer demographics] VARCHAR(45) NULL,
	[Order quantities] INT NULL,
	PRIMARY KEY (SKU),
);
GO

-- Shipping
CREATE TABLE DimShipping (
	[SKU] VARCHAR(50) NOT NULL,
	[Shipping times] INT NULL,
	[Shipping carriers] VARCHAR(45) NULL,
	[Shipping costs] DECIMAL NULL,
	[Location] VARCHAR(45) NULL,
	[Transportation modes] VARCHAR(45) NULL,
	[Routes] VARCHAR(45) NULL,
	[Costs] DECIMAL NULL,
	PRIMARY KEY (SKU)
);
GO


-- Suppliers
CREATE TABLE DimSuppliers (
	[Supplier name] VARCHAR(50) NOT NULL,
	[Location] VARCHAR(45) NULL,
	[Lead time] INT NULL,
	PRIMARY KEY ([Supplier name])
);
GO


