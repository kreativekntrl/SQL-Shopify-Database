USE [MF67ava.steimle]
GO

/****** Object:  Table [dbo].[SPR26_Customers]    Script Date: 10/1/2026 11:00:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPR26_Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[Lastname] [nvarchar](50) NOT NULL,
	[FullName]  AS (concat([LastName],', ',[FirstName])) PERSISTED NOT NULL,
	[FirstContactDate] [date] NULL,
	[StreetAddress] [nvarchar](100) NULL,
	[ZipCodeT] [nvarchar](15) NULL,
	[Rank] [numeric](4, 0) NULL,
	[RevenueCategory] [nvarchar](50) NULL,
	[LastPurchase] [datetime] NULL,
	[FirstPurchase] [datetime] NULL,
	[TotalRevenue] [numeric](8, 0) NULL,
	[TotalProfit] [numeric](8, 0) NULL,
	[NumberSales] [numeric](8, 0) NULL,
	[TotalLineItems] [numeric](8, 0) NULL,
	[AvgRevenuePerSale] [numeric](8, 2) NULL,
	[AvgProfitPerSale] [numeric](8, 2) NULL,
	[AvgLineItemsPerSale] [numeric](8, 1) NULL,
	[CustomerSegmentation_AvgLineItems] [numeric](8, 1) NULL,
	[AvgRevenuePerLineItem] [numeric](8, 2) NULL,
	[AvgProfitPerLineItem] [numeric](8, 2) NULL,
	[LifetimeValue] [numeric](8, 0) NULL,
	[TotalUnits] [numeric](6, 0) NULL,
PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT (getdate()) FOR [FirstContactDate]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [TotalRevenue]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [TotalProfit]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [NumberSales]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [TotalLineItems]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [AvgRevenuePerSale]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [AvgProfitPerSale]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [AvgLineItemsPerSale]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [CustomerSegmentation_AvgLineItems]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [AvgRevenuePerLineItem]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [AvgProfitPerLineItem]
GO

ALTER TABLE [dbo].[SPR26_Customers] ADD  DEFAULT ((0)) FOR [LifetimeValue]
GO

ALTER TABLE [dbo].[SPR26_Customers]  WITH CHECK ADD FOREIGN KEY([ZipCodeT])
REFERENCES [dbo].[SPR26_Geography] ([ZipCodeT])
GO


