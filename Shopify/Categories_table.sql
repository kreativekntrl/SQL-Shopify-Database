USE [MF67ava.steimle]
GO

/****** Object:  Table [dbo].[SPR26_Categories]    Script Date: 10/1/2026 10:59:06 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPR26_Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](50) NULL,
	[NumberProducts] [numeric](8, 0) NULL,
	[NumberSales] [numeric](8, 0) NULL,
	[Revenue] [numeric](8, 0) NULL,
	[Profit] [numeric](8, 0) NULL,
	[TotalUnitsSold] [numeric](8, 0) NULL,
	[PercentProductLine] [numeric](5, 2) NULL,
	[PercentSales] [numeric](5, 2) NULL,
	[PercentRevenue] [numeric](5, 2) NULL,
	[PercentProfit] [numeric](5, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SPR26_Categories] ADD  DEFAULT ((0)) FOR [NumberProducts]
GO

ALTER TABLE [dbo].[SPR26_Categories] ADD  DEFAULT ((0)) FOR [NumberSales]
GO

ALTER TABLE [dbo].[SPR26_Categories] ADD  DEFAULT ((0)) FOR [Revenue]
GO

ALTER TABLE [dbo].[SPR26_Categories] ADD  DEFAULT ((0)) FOR [Profit]
GO

ALTER TABLE [dbo].[SPR26_Categories] ADD  DEFAULT ((0)) FOR [TotalUnitsSold]
GO

ALTER TABLE [dbo].[SPR26_Categories] ADD  DEFAULT ((0)) FOR [PercentProductLine]
GO

ALTER TABLE [dbo].[SPR26_Categories] ADD  DEFAULT ((0)) FOR [PercentSales]
GO

ALTER TABLE [dbo].[SPR26_Categories] ADD  DEFAULT ((0)) FOR [PercentRevenue]
GO

ALTER TABLE [dbo].[SPR26_Categories] ADD  DEFAULT ((0)) FOR [PercentProfit]
GO


