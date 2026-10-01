USE [MF67ava.steimle]
GO

/****** Object:  Table [dbo].[SPR26_SalesDetails]    Script Date: 10/1/2026 11:01:37 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPR26_SalesDetails](
	[SalesID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[ProductName] [nvarchar](50) NOT NULL,
	[Units] [numeric](6, 0) NOT NULL,
	[SalesPrice] [numeric](8, 2) NOT NULL,
	[LineTotal]  AS ([Units]*[SalesPrice]) PERSISTED,
	[InvoiceDate] [datetime] NULL,
	[DayOfMonth]  AS (datepart(day,[InvoiceDate])),
	[DayOfWeek#]  AS (datepart(weekday,[InvoiceDate])),
	[DayName]  AS (datename(weekday,[InvoiceDate])),
	[WeekOfYear]  AS (datepart(day,[InvoiceDate])),
	[MonthNumber]  AS (datepart(month,[InvoiceDate])),
	[MonthName]  AS (datename(month,[InvoiceDate])),
	[Year]  AS (datepart(year,[InvoiceDate])),
	[YearMonth]  AS (datepart(year,[InvoiceDate])*(100)+datepart(month,[InvoiceDate])),
	[Delivered] [bit] NULL,
	[StockDeducted] [bit] NULL,
	[Shipped] [bit] NULL,
	[Summarized] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[SalesID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SPR26_SalesDetails] ADD  DEFAULT (getdate()) FOR [InvoiceDate]
GO

ALTER TABLE [dbo].[SPR26_SalesDetails] ADD  DEFAULT ((0)) FOR [StockDeducted]
GO

ALTER TABLE [dbo].[SPR26_SalesDetails] ADD  DEFAULT ((0)) FOR [Shipped]
GO

ALTER TABLE [dbo].[SPR26_SalesDetails] ADD  DEFAULT ((0)) FOR [Summarized]
GO

ALTER TABLE [dbo].[SPR26_SalesDetails]  WITH CHECK ADD FOREIGN KEY([CustomerID])
REFERENCES [dbo].[SPR26_Customers] ([CustomerID])
GO

ALTER TABLE [dbo].[SPR26_SalesDetails]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[SPR26_Products] ([ProductID])
GO


