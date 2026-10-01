USE [MF67ava.steimle]
GO

/****** Object:  Table [dbo].[SPR26_Products]    Script Date: 10/1/2026 11:01:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPR26_Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [nvarchar](100) NOT NULL,
	[CategoryID] [int] NULL,
	[StockQty] [numeric](8, 0) NULL,
	[Cost] [numeric](8, 2) NULL,
	[SalesPrice] [numeric](8, 2) NULL,
	[LastSale] [datetime] NULL,
	[PreferredVendorID] [int] NULL,
	[TotalUnitsSold] [numeric](8, 0) NULL,
	[NumberTimesSold] [numeric](8, 0) NULL,
	[RevenueGenerated] [numeric](8, 2) NULL,
	[TotalProfitMade] [numeric](8, 2) NULL,
	[Rank] [numeric](4, 0) NULL,
	[Sales Category] [nvarchar](30) NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SPR26_Products] ADD  DEFAULT ((0)) FOR [TotalUnitsSold]
GO

ALTER TABLE [dbo].[SPR26_Products] ADD  DEFAULT ((0)) FOR [NumberTimesSold]
GO

ALTER TABLE [dbo].[SPR26_Products] ADD  DEFAULT ((0)) FOR [RevenueGenerated]
GO

ALTER TABLE [dbo].[SPR26_Products] ADD  DEFAULT ((0)) FOR [TotalProfitMade]
GO

ALTER TABLE [dbo].[SPR26_Products]  WITH CHECK ADD FOREIGN KEY([CategoryID])
REFERENCES [dbo].[SPR26_Categories] ([CategoryID])
GO

ALTER TABLE [dbo].[SPR26_Products]  WITH CHECK ADD FOREIGN KEY([PreferredVendorID])
REFERENCES [dbo].[SPR26_Vendors] ([VendorID])
GO


