USE [MF67ava.steimle]
GO

/****** Object:  Table [dbo].[SPR26_WarehouseDeliveryReceipts]    Script Date: 10/1/2026 11:02:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPR26_WarehouseDeliveryReceipts](
	[DeliveryID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[VendorID] [int] NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[StockQty] [numeric](8, 0) NOT NULL,
	[Cost] [numeric](8, 2) NOT NULL,
	[DeliveryDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[DeliveryID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SPR26_WarehouseDeliveryReceipts] ADD  DEFAULT (getdate()) FOR [DeliveryDate]
GO

ALTER TABLE [dbo].[SPR26_WarehouseDeliveryReceipts]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[SPR26_Products] ([ProductID])
GO

ALTER TABLE [dbo].[SPR26_WarehouseDeliveryReceipts]  WITH CHECK ADD FOREIGN KEY([VendorID])
REFERENCES [dbo].[SPR26_Vendors] ([VendorID])
GO


