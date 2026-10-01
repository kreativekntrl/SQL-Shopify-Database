USE [MF67ava.steimle]
GO

/****** Object:  StoredProcedure [dbo].[SPR26_spSaveANewProduct-Aug-26]    Script Date: 10/1/2026 11:05:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [dbo].[SPR26_spSaveANewProduct-Aug-26]
@ProductName nvarchar(50), @CategoryID int, @StockQty numeric(8,0),
@Cost numeric(8,2), @PreferredVendorID int, @Feedback nvarchar(100)= NULL OUTPUT
AS
BEGIN

	DECLARE @BeginningNumProducts int, @EndingNumProducts int

	IF EXISTS (SELECT * FROM[dbo].[SPR26_Products]
			WHERE [ProductName] LIKE @ProductName)
		BEGIN
			SET @Feedback = 'Woops. Already have a product named that'
			PRINT 'Woops. Already have a product named that'
			RETURN
		END

	IF NOT EXISTS (SELECT * FROM[dbo].[SPR26_Products]
			WHERE [ProductName] LIKE @ProductName)
		BEGIN
			SET @BeginningNumProducts = (SELECT COUNT(*) FROM[dbo].[SPR26_Products])
			INSERT [dbo].[SPR26_Products]	
				([ProductName],[CategoryID],[StockQty],[Cost],[SalesPrice],[PreferredVendorID])
			VALUES
				(@ProductName, @CategoryID, @StockQty, @Cost, (@Cost*1.5), @PreferredVendorID)

			SET @EndingNumProducts = (SELECT COUNT(*) FROM[dbo].[SPR26_Products])

			IF @EndingNumProducts  > @BeginningNumProducts
			SET @Feedback = 'Product Added'
				PRINT 'Product Added'
		END
END
GO


