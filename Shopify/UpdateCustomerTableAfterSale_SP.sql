USE [MF67ava.steimle]
GO

/****** Object:  StoredProcedure [dbo].[SPR26_spUpdateCustomerTableAfterSale-Sept26]    Script Date: 10/1/2026 11:03:55 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[SPR26_spUpdateCustomerTableAfterSale-Sept26]
		@CustomerID int, @SalesID int
AS
BEGIN
	DECLARE @CustomerID_OnSale int

	BEGIN -- BEGIN ERROR CHECKING ->

	-- Validate the customer ID
	IF NOT EXISTS (SELECT * FROM [dbo].[SPR26_Customers] WHERE [CustomerID] = @CustomerID)
		BEGIN
			PRINT 'Invalid Customer ID'
			RETURN
		END

	-- Validate the Sales ID
	IF NOT EXISTS (SELECT * FROM [dbo].[SPR26_SalesSummary] WHERE [SaleID] = @SalesID)
		BEGIN
			PRINT 'Invalid Sales ID'
			RETURN
		END 

	-- sets local variable
	SET @CustomerID_OnSale = (SELECT [CustomerID] FROM [dbo].[SPR26_SalesSummary] WHERE [SaleID] = @SalesID)

	-- Checks to make sure that the Customer ID  inputted matches the customer ID on the specific sale 
	IF @CustomerID <> @CustomerID_OnSale
		BEGIN
			PRINT 'Check customer ID for Sales Order. My records show that CustomerID should be: '
				+ convert(nvarchar(6), @CustomerID_OnSale)
			RETURN
		END
	END

	-- Update Customers table after a purchase has been completed using SalesDetails table
	UPDATE [dbo].[SPR26_Customers]
		SET [LastPurchase] = subq1.[InvoiceDateFromSD],
			[FirstPurchase] = IIF([NumberSales] = 0, subq1.[InvoiceDateFromSD], [FirstPurchase]),
			[TotalRevenue] += subq1.[InvoiceTotal],
			[TotalProfit] += subq1.[InvoiceProfit],
			[NumberSales] += 1,
			[TotalLineItems] += subq1.[NumberLineItems],
			[TotalUnits] += subq1.[InvoiceTotalUnits]

		FROM (
				SELECT [SalesID], [CustomerID],
					MAX([InvoiceDate]) as [InvoiceDateFromSD],
					SUM([LineTotal]) as [InvoiceTotal],
					SUM([LineTotal]) * 0.33 as [InvoiceProfit],
					COUNT([ProductID]) as [NumberLineItems],
					SUM([Units]) as [InvoiceTotalUnits]
				FROM [dbo].[SPR26_SalesDetails]
				WHERE [SalesID] = @SalesID
				GROUP BY SalesID, CustomerID
			)
			as subq1

		WHERE [SPR26_Customers].CustomerID = subq1.CustomerID

END

GO


