USE [MF67ava.steimle]
GO

/****** Object:  StoredProcedure [dbo].[SPR26_spUpdateStockAfterDelivery-Sept26]    Script Date: 10/1/2026 11:03:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   PROCEDURE [dbo].[SPR26_spUpdateStockAfterDelivery-Sept26]
	@DeliveryID int

AS
BEGIN 

	IF NOT EXISTS (SELECT * FROM [dbo].[SPR26_WarehouseDeliveryReceipts] WHERE [DeliveryID] = @DeliveryID)
		BEGIN 
			PRINT 'Invalid DeliveryID. Procedure ended.'
			RETURN;
		END

	UPDATE p
	SET p.[StockQty] += r.[StockQty]

	FROM [dbo].[SPR26_Products] as p
	JOIN [dbo].[SPR26_WarehouseDeliveryReceipts] as r
	ON p.[ProductID] = r.[ProductID]

	WHERE r.[DeliveryID] = @DeliveryID

END
GO


