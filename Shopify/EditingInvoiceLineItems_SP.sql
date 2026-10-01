USE [MF67ava.steimle]
GO

/****** Object:  StoredProcedure [dbo].[SPR26_spEditingInvoiceLineItems-Aug26]    Script Date: 10/1/2026 11:06:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [dbo].[SPR26_spEditingInvoiceLineItems-Aug26]
-- INPUT PARAMETERS (@FinalUnitsForLI is optional)
@TAType nvarchar(12), @SalesID int, @ProductID int, @FinalUnitsForLI numeric(8, 0) = NULL

AS 
BEGIN

	DECLARE @ProductName nvarchar(40), @SalesPrice numeric(8, 0), @QtyInStock numeric(6, 0),
			@UnitsOnLI numeric(8, 0), @IncreaseInLIUnits numeric(8, 0), @DecreaseInLIUnits numeric(8, 0),
			@StockAlreadyDeducted bit

	BEGIN -- ERROR CHECKING

	--We make sure that the user input is an expected action and if not we exit
		IF UPPER(@TAType) NOT IN ('INCREASE', 'DECREASE', 'DELETE')
			BEGIN
				RAISERROR('TAType must be Increase, Decrease, or Delete. Please Rectify.', 16, 1);
				RETURN;
			END
	-- We validate the sales ID and exit if not found
		IF NOT EXISTS (SELECT * FROM [dbo].[SPR26_SalesDetails] WHERE [SalesID] = @SalesID)
			BEGIN
				RAISERROR('Please check the SalesID #', 16, 1);
				RETURN;
			END
	-- We validate the product ID and exit if not found
		IF NOT EXISTS (SELECT * FROM [dbo].[SPR26_Products] WHERE [ProductID] = @ProductID)
			BEGIN 
				RAISERROR('Please check the ProductID #', 16, 1);
				RETURN;
			END
	-- We check to make sure that the input ProductID is actually on the input Sales Invoice
		IF NOT EXISTS (SELECT * FROM [dbo].[SPR26_SalesDetails] WHERE [ProductID] = @ProductID AND [SalesID] = @SalesID)
			BEGIN
				-- We declare a local variable to hold the products that are on the invoice
				DECLARE @ProductsOnOrder nvarchar(100)

				-- We use an assignment operator to create a string form of the products that are on the invoice
				SELECT @ProductsOnOrder = STRING_AGG(CONVERT(nvarchar(300), subq1.ProductID), N', ')
				FROM 
					(	SELECT [ProductID] FROM [dbo].[SPR26_SalesDetails]
						WHERE [SalesID] = @SalesID
					) as subq1

				SET @ProductName = (SELECT [ProductName] FROM [dbo].[SPR26_Products]
				WHERE [ProductID] = @ProductID)

				-- We concact a sentance to alert the user that the ProductID they entered does not exist on the SalesID they are attempting to edit
				PRINT 'Product # ' + CONVERT(nvarchar(20), @ProductID) + ' ' + @ProductName
					+ ' was not sold on SalesID ' + CONVERT(nvarchar(6), @SalesID) + char(13)
					+ char(13) + 'The product(s) for that invoice are ' + @ProductsOnOrder + char(13)
					+ 'Use the SaveLineItem procedure if you want to add a new product to the invoice. '
					+ char(13)

				RAISERROR('Please check the ProductID and read the error message ' , 16, 1)
				RETURN;
			END

		-- If a user does not specify or inputs 0 as the final # of units when either increasing or decreasing, we alert them and exit. 
		IF UPPER(@TAType) IN ('INCREASE', 'DECREASE')
			IF @FinalUnitsForLI IS NULL or @FinalUnitsForLI <= 0
				BEGIN
					RAISERROR(
						'Please specify a positive number of the final unit amount.
						If you want to set zero out (remove) the line item, then use the DELETE action.', 16, 1);
					RETURN;
				END

		-- IF the order has already shipped we cannot delete or alter. Exit SP
		IF EXISTS (SELECT 1 FROM [dbo].[SPR26_SalesDetails] WHERE [SalesID] = @SalesID AND [Shipped] = 1)
			BEGIN
				RAISERROR('That invoice has already shipped. Start new invoice as needed. Processing ended.', 16, 1);
				RETURN;
			END
	END -- END of error-checking section 

IF UPPER(@TAType) = 'DELETE'
	BEGIN -- DELETE HANDLING
		
		-- We check to see if the stock has been deducted and set the local variable to the value of the table value 
		SET @StockAlreadyDeducted = (SELECT [StockDeducted] FROM [dbo].[SPR26_SalesDetails]
			WHERE [SalesID] = @SalesID AND [ProductID] = @ProductID )
		-- We set the local variable units of LI to the table value 
		SET @UnitsOnLI = (SELECT [Units] FROM [dbo].[SPR26_SalesDetails]
			WHERE [ProductID] = @ProductID AND [SalesID] = @SalesID )
		-- IF the stock HAS been deducted than we can reverse the transaction by UPDATING the product
		IF @StockAlreadyDeducted = 1
			BEGIN
				UPDATE [dbo].[SPR26_Products]
					SET [StockQty] += @UnitsOnLI,
						[NumberTimesSold] -= 1,
						[TotalUnitsSold] -= @UnitsOnLI,
						[RevenueGenerated] -= (@UnitsOnLI * [SalesPrice]),
						[TotalProfitMade] -= (@UnitsOnLI * [SalesPrice]) * 0.33
					-- ONLY update the specific product 
					WHERE [dbo].[SPR26_Products].[ProductID] = @ProductID

					PRINT('Products table inventory levels and marketing 
						metrics have been updated to reflect the deleted line item');
			END

	-- Delete the line item from the sales details table 
	DELETE FROM [dbo].[SPR26_SalesDetails] WHERE [ProductID] = @ProductID AND [SalesID] = @SalesID

	-- We delete the current salesSummary and call the SP to create a new salesSummary 
	EXECUTE [dbo].[SPR26_spCreateNewSaleSummary-Aug26] @SalesID
	PRINT('Line item deleted. SalesSummary updated for invoice ' + CONVERT(nvarchar(8), @SalesID))
	
	SELECT * FROM [dbo].[SPR26_SalesDetails] WHERE [SalesID] = @SalesID
END -- END of DELETE section

IF UPPER(@TAType) = 'INCREASE'
	BEGIN -- INCREASE HANDLING

		-- Setting local stock variable 
		SET @QtyInStock = (SELECT [StockQty] FROM [dbo].[SPR26_Products] WHERE [ProductID] = @ProductID)

		-- IF the stock is 0 on the specified product - alert the user and exit.
		IF @QtyInStock = 0
			BEGIN 
				RAISERROR(
						'OSWO - No stock, cannot increase units for this line item.
						Keep line item unchanged. Exited. ', 16, 1);
				RETURN;
			END
		-- Set the local units variable 
		SET @UnitsOnLI = (SELECT [Units] FROM [dbo].[SPR26_SalesDetails] 
			WHERE [ProductID] = @ProductID AND [SalesID] = @SalesID)
		-- IF the existing units is greater than the desired units - alert the user an exit.
		IF @UnitsOnLI > @FinalUnitsForLI
			BEGIN
				RAISERROR('If you want to decrease # of units please use DECREASE action.', 16, 1)
				RETURN;
			END
		-- Set the # of units to increase by variable (final units desired LESS the existing units)
		SET @IncreaseInLIUnits = @FinalUnitsForLI - @UnitsOnLI
		-- IF the # of units to increase by is NULL - alert the user and exit
		IF @IncreaseInLIUnits IS NULL
			BEGIN 
				PRINT('Value to increase by cannot be NULL. Exiting Procedure.')
				RETURN;
			END 
		-- IF the stock is greater than or equal to the # of units requested - proceed to update.
		IF @QtyInStock >= @IncreaseInLIUnits
			PRINT(
				'Line item increased to full amount requested. Products table, SalesDetails table, 
				and SalesSummary tables have been updated. ')
		-- IF the stock is less than the # of requested units - Fulfill a partial order and alert user. 
		IF @QtyInStock < @IncreaseInLIUnits 
			BEGIN 
				SET @IncreaseInLIUnits = @QtyInStock
				
				PRINT( 
					'Partial order - shipped short. Only ' + CONVERT(nvarchar(6), @QtyInStock)
					+ ' units in stock for this product ' + CONVERT(nvarchar(20), @ProductID)
					+ char(13) + 'All available stock assigned to this order.' + char(13)
					+ 'Line item updated, and product record updated. Inquire about 2nd shipment.'
					+ char(13))
			END 

				-- UPDATE the sales details table
				UPDATE [dbo].[SPR26_SalesDetails]
				SET [Units] += @IncreaseInLIUnits,
					[InvoiceDate] = GETDATE()
				WHERE [ProductID] = @ProductID AND [SalesID] = @SalesID

				-- UPDATE the products table
				UPDATE [dbo].[SPR26_Products]
				SET [StockQty] -= @IncreaseInLIUnits,
					[TotalUnitsSold] += @IncreaseInLIUnits,
					[RevenueGenerated] += (@IncreaseInLIUnits * [SalesPrice]),
					[TotalProfitMade] += (@IncreaseInLIUnits * [SalesPrice]) * 0.33,
					[LastSale] = GETDATE()
				WHERE [dbo].[SPR26_Products].[ProductID] = @ProductID

				-- Show the updated invoice
				SELECT * FROM [dbo].[SPR26_SalesDetails] WHERE [SalesID] = @SalesID

				-- Update the sales summary record for this invoice
				EXECUTE [dbo].[SPR26_spCreateNewSaleSummary-Aug26] @SalesID
				PRINT('SalesSummary updated for invoice: ' + CONVERT(nvarchar(8), @SalesID))

END -- End of INCREASE section

IF UPPER(@TAType) = 'DECREASE'
	BEGIN -- DECREASE HANDLING

		-- We set the local units variable to the actual units on the line item 
		SET @UnitsOnLI = (SELECT [Units] FROM [dbo].[SPR26_SalesDetails]
							WHERE [ProductID] = @ProductID AND [SalesID] = @SalesID)
		-- IF the desired units is greater than the existing units, alert user and exit.
		IF @FinalUnitsForLI > @UnitsOnLI
			BEGIN
				RAISERROR('If you want to increase # of units please use INCREASE action. ', 16, 1)
				RETURN;
			END 

		-- We set the # of units to decrease by to (current units - final desired units) 
		SET @DecreaseInLIUnits = @UnitsOnLI - @FinalUnitsForLI
		-- Set the local sales price variable to the actual sales price
		SET @SalesPrice = (SELECT [SalesPrice] FROM [dbo].[SPR26_Products] WHERE [ProductID] = @ProductID)

	
		PRINT(
			CONVERT(nvarchar(20), @UnitsOnLI) + ' units currently on order for product '
			+ CONVERT(nvarchar(25), @ProductID) + ' Decreasing to ' + CONVERT(nvarchar(25), @FinalUnitsForLI ))

			-- UPDATE sales details table
			UPDATE [SPR26_SalesDetails]
			SET [Units] = @FinalUnitsForLI
			WHERE [ProductID] = @ProductID AND [SalesID] = @SalesID

			-- UPDATE Products table
			UPDATE [dbo].[SPR26_Products]
			SET [StockQty] += @DecreaseInLIUnits, -- puts the units back in stock
				[TotalUnitsSold] -= @DecreaseInLIUnits,
				[RevenueGenerated] -= (@DecreaseInLIUnits * [SalesPrice]),
				[TotalProfitMade] -= (@DecreaseInLIUnits * [SalesPrice]) * 0.33
			WHERE [ProductID] = @ProductID

			-- Show updated line item
			SELECT * FROM [dbo].[SPR26_SalesDetails] WHERE [SalesID] = @SalesID

			-- Update SalesSummary record for this invoice 
			EXECUTE [dbo].[SPR26_spCreateNewSaleSummary-Aug26] @SalesID
			PRINT('SalesSummary updated for invoice: ' + CONVERT(nvarchar(8), @SalesID))

	END -- End of DECREASE section

END -- END 












				











GO


