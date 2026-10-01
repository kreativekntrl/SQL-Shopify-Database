USE [MF67ava.steimle]
GO

/****** Object:  StoredProcedure [dbo].[SPR26_spSaveALineItem-Aug26]    Script Date: 10/1/2026 11:05:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [dbo].[SPR26_spSaveALineItem-Aug26]
-- Input parameters required for SP
@CustomerID int, @ProductID int, @Units numeric(8, 0), @ExistingSaleID int = NULL 
AS 
BEGIN 

DECLARE @SalesID int, @ProductName nvarchar(50), @SalesPrice numeric(8, 2), 
@QtyInStock numeric(6, 0), @IntCountBefore int, @IntCountAfter int, @CustomerOnInvoice int 

BEGIN --Error Checking 

-- Checks to ensure that there are units available 
IF @Units IS NULL OR @Units <= 0 
	BEGIN 
		RAISERROR('Check units thanks.', 15, 1); 
		RETURN 
	END 

-- Checks to ensure that the customer ID exists 
IF NOT EXISTS (SELECT * FROM [dbo].[SPR26_Customers] WHERE [CustomerID] = @CustomerID) 
	BEGIN 
		RAISERROR('Check Customer ID#, thanks.', 15, 1) 
		RETURN 
	END 

-- Checks to ensure that the product ID exists 
IF NOT EXISTS (SELECT * FROM [dbo].[SPR26_Products] WHERE [ProductID] = @ProductID) 
	BEGIN 
		RAISERROR('Check Product ID#, thanks.', 15, 1) 
		RETURN 
	END

-- First we check that the product being order has stock by retreiving the stock qty from products table 
SET @QtyInStock = (SELECT [StockQty] FROM [dbo].[SPR26_Products] WHERE [ProductID] = @ProductID)

-- Then if there is NO stock, we throw an error message and exit the SP 
IF @QtyInStock <= 0 
	BEGIN 
		RAISERROR('OSWO- No stock for this product, suggest an alternative or process back-order. Program ended.', 15, 1) 
		RETURN 
	END

-- Check to see if selected order already exists on the invoice. If so, exit SP. 
IF EXISTS (SELECT * FROM [dbo].[SPR26_SalesDetails] WHERE [ProductID] = @ProductID AND [SalesID] = @SalesID) 
	BEGIN 
		PRINT 'Product ' + convert(nvarchar(6), @ProductID) + ' already exists on invoice ' 
		+ convert(nvarchar(6), @SalesID) + char(13) 
		+ 'Use the editing invoice line SP if you want to change units for an existing line item,' 
		+ char(13) + 'or to delete an existing line item.' + char(13) 
		RETURN 
	END
END 

BEGIN -- Data processing - Code here down ONLY runs if the product is NOT already on the invoice 

IF @ExistingSaleID > 0 

-- By adding an extra input parameter for SaleID, SP can both add new line items to an invoice AND add new line items to an existing invoice 
	BEGIN 
-- We retrieve the customer ID that is on the existing invoice and confirm that it is correct 
		SET @CustomerOnInvoice = 
		(SELECT TOP 1 [CustomerID] FROM [dbo].[SPR26_SalesDetails] WHERE [SalesID] = @ExistingSaleID) 

		IF @CustomerID <> @CustomerOnInvoice 
			BEGIN 
				PRINT 'The Customer ID# provided is incorrect for this invoice, it should be CustomerID ' 
				+ CONVERT(nvarchar(5), @CustomerOnInvoice) + char(13) 
				RAISERROR('Sorry that customer ID# is not correct for this invoice, please check. Processing ended.', 15, 1) 
				RETURN 
		END 

		IF EXISTS (SELECT * FROM [dbo].[SPR26_SalesDetails] WHERE [SalesID] = @ExistingSaleID) 
			BEGIN 
				SET @SalesID = @ExistingSaleID 
			END 
		END

-- If the user did not specify a invoice number to add a line item to, then a new invoice is being created. 
IF @ExistingSaleID IS NULL OR @ExistingSaleID = 0 
-- IF there are no existing invoices then we set the sales ID to 1, the first invoice 
	BEGIN 
		IF (SELECT COUNT(*) FROM [SPR26_SalesDetails]) IN (NULL, 0) 
			SET @SalesID = 1 
		-- IF there are existing invoices then we set the Sales ID to the next number from the last invoice 
		IF (SELECT COUNT(*) FROM [SPR26_SalesDetails]) >= 1 
			SET @SalesID = (SELECT MAX(SalesID) FROM [SPR26_SalesDetails]) + 1 
	END 

-- Next we check the current stock level to see if there is enough stock to satisfy the order 
IF @QtyInStock < @Units 
	BEGIN 
		PRINT 'Insufficient stock, partial fulfillment only. Order quantity reduced to ' 
		+ CONVERT(nvarchar(25), @QtyInStock) + ' units.' 
		
	-- here the units for the line item are reduced down to the available stock. 
		SET @Units = @QtyInStock 
	END

-- Now that data entry has been validated, we save the line item

SELECT 
	-- We set local variables for product name and sales price so that sales clerks are not able to input these values 
	@ProductName = ProductName,
	@SalesPrice = SalesPrice
	FROM [dbo].[SPR26_Products]
	WHERE ProductID = @ProductID;

	SET @IntCountBefore = (select count(*) FROM [SPR26_SalesDetails])

	INSERT [SPR26_SalesDetails]	
		([SalesID], [ProductID], [ProductName], [CustomerID], [Units], [SalesPrice], [StockDeducted], [Shipped])
	VALUES
		(@SalesID, @ProductID, @ProductName, @CustomerID, @Units, @SalesPrice, 'True', 'False')
		-- The InvoiceDate and many date/time dimensions are auto-generated as persisted columns of the table 

	SET @IntCountAfter = (SELECT COUNT(*) FROM [SPR26_SalesDetails])

		-- Verifies that we have added the line item 
		IF @IntCountAfter > @IntCountBefore
			PRINT 'Line item was added'
		ELSE 
			BEGIN
				PRINT 'Line item was not added.'
				RETURN
			END
-- Now we update the products tables to reduce inventory and update metrics for the product sold 

UPDATE [dbo].[SPR26_Products]

SET [StockQty] -= @Units,
	[LastSale] = GETDATE(),
	[TotalUnitsSold] += @Units,
	[NumberTimesSold] += 1,
	[RevenueGenerated] += (@Units * @SalesPrice),
	[TotalProfitMade] += (@Units * @SalesPrice) * 0.33
WHERE [ProductID] = @ProductID

UPDATE	[dbo].[SPR26_SalesDetails]

SET [StockDeducted] = 'True' WHERE [SalesID] = @SalesID AND [ProductID] = @ProductID

-- Even if its just first line item on an invoice - generate a SalesSummary
EXEC [dbo].[SPR26_spCreateNewSaleSummary-Aug26] @SalesID
PRINT 'SalesSummary updated for invoice ' + convert(nvarchar(8), @SalesID)

SELECT * FROM [SPR26_SalesDetails] WHERE SalesID = @SalesID

	END
END
GO


