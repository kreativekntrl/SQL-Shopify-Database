USE [MF67ava.steimle]
GO

/****** Object:  StoredProcedure [dbo].[SPR26_spUpdateCategoriesTableAfterSale-Sept26]    Script Date: 10/1/2026 11:04:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [dbo].[SPR26_spUpdateCategoriesTableAfterSale-Sept26]
		@SalesID int

AS 
BEGIN
	
	BEGIN -- BEGIN ERROR CHECKING ->

	-- check not null
	IF @SalesID IS NULL OR @SalesID <= 0 
		BEGIN
			RAISERROR('Invalid sales ID input', 15, 1);
			RETURN
		END

	-- validate the sales ID
	IF NOT EXISTS (SELECT * FROM [dbo].[SPR26_SalesSummary] WHERE [SaleID] = @SalesID)
		BEGIN
			PRINT 'Invalid Sales ID'
			RETURN
		END
END -- end error checking 

	-- Update Categories table after a purchase has been completed
	UPDATE c
		SET
			c.[NumberSales] += subq1.NumberOfSalesCount,
			c.[TotalUnitsSold] += subq1.TotalUnits,
			c.[Revenue] += subq1.TotalRevenue,
			c.[Profit] += subq1.TotalProfit
		FROM [dbo].[SPR26_Categories] as c
		-- JOINS Categories table with the subquery summaries
		INNER JOIN (
				-- defines which columns we will summaries
				SELECT
					-- preforms functions to summarize data
					p.[CategoryID],
					SUM(sd.[Units]) AS TotalUnits,
					COUNT(DISTINCT sd.[SalesID]) as NumberOfSalesCount,
					SUM(sd.[LineTotal]) as TotalRevenue,
					SUM(sd.[LineTotal] * 0.33) as TotalProfit
				FROM [dbo].[SPR26_SalesDetails] as sd
				-- JOIN Products table and SalesDetails table on the product ID for the sale
				INNER JOIN [dbo].[SPR26_Products] as p
					ON sd.ProductID = p.ProductID
				-- filters line items to the sale specified
				WHERE sd.SalesID = @SalesID
				-- aggregates metrics into a single summary row per category present on the sale
				GROUP BY p.CategoryID
			) as subq1
				ON c.CategoryID = subq1.CategoryID;
END



GO


