USE [MF67ava.steimle]
GO

/****** Object:  StoredProcedure [dbo].[SPR26_spCreateNewSaleSummary-Aug26]    Script Date: 10/1/2026 11:06:29 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[SPR26_spCreateNewSaleSummary-Aug26]
@SalesID int, @Remarks nvarchar(255) = NULL OUTPUT 
AS
BEGIN

IF EXISTS (SELECT * FROM [dbo].[SPR26_SalesSummary] WHERE [SaleID] = @SalesID)
	BEGIN
		DELETE FROM [dbo].[SPR26_SalesSummary] WHERE [SaleID] = @SalesID
	END

DECLARE @NumberCategories int = 
	(SELECT COUNT(DISTINCT p.CategoryID)
	FROM [dbo].[SPR26_SalesDetails] sd
	INNER JOIN [dbo].[SPR26_Products] p
	ON sd.ProductID = p.ProductID
	WHERE sd.SalesID = @SalesID )

INSERT INTO [dbo].[SPR26_SalesSummary]
([SaleID], [CustomerID], [Invoice_Date], [TotalSale], [NumberSKU], [NumberUnits], [NumberCategories])

SELECT [SalesID], 
	[CustomerID],
	MAX([InvoiceDate]), 
	SUM([LineTotal]), 
	COUNT([ProductID]), 
	SUM([Units]), 
	@NumberCategories 
FROM [dbo].[SPR26_SalesDetails]
WHERE [SalesID] = @SalesID
GROUP BY [SalesID], [CustomerID] 
 
UPDATE [dbo].[SPR26_SalesDetails] 
SET [Summarized] = 1 
WHERE [SalesID] = @SalesID

SELECT * FROM [dbo].[SPR26_SalesSummary] WHERE [SaleID] = @SalesID

SET @Remarks = 'Generated and stored a new summary of invoice ' + convert(nvarchar(5), @SalesID)
PRINT @Remarks

END
GO


