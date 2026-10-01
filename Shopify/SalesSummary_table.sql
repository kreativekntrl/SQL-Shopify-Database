USE [MF67ava.steimle]
GO

/****** Object:  Table [dbo].[SPR26_SalesSummary]    Script Date: 10/1/2026 11:01:59 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPR26_SalesSummary](
	[SaleID] [int] NOT NULL,
	[CustomerID] [int] NULL,
	[TotalSale] [numeric](8, 0) NOT NULL,
	[NumberSKU] [numeric](6, 0) NOT NULL,
	[NumberUnits] [numeric](6, 0) NOT NULL,
	[Invoice_Date] [datetime] NULL,
	[Paid] [bit] NULL,
	[Year]  AS (datepart(year,[Invoice_Date])),
	[YearT]  AS (CONVERT([nvarchar](4),datepart(year,[Invoice_Date]))),
	[Month]  AS (datepart(month,[Invoice_Date])),
	[MonthText]  AS (datename(month,[Invoice_Date])),
	[DaysAgo] [numeric](5, 0) NULL,
	[DaysAgoGroup] [nvarchar](30) NULL,
	[Shift]  AS (case when datepart(hour,[Invoice_Date])>=(0) AND datepart(hour,[Invoice_Date])<=(6) then 'Overnight' when datepart(hour,[Invoice_Date])>=(7) AND datepart(hour,[Invoice_Date])<=(12) then 'Morning' when datepart(hour,[Invoice_Date])>=(13) AND datepart(hour,[Invoice_Date])<=(18) then 'Afternoon' when datepart(hour,[Invoice_Date])>=(19) AND datepart(hour,[Invoice_Date])<=(24) then 'Night'  end),
	[Hour]  AS (case when datepart(hour,[Invoice_Date])=(0) then (8) else datepart(hour,[Invoice_Date]) end),
	[SCM_Impact]  AS (case when [NumberUnits]>=(0) AND [NumberUnits]<=(3) then 'Minimal' when [NumberUnits]>=(4) AND [NumberUnits]<=(10) then 'Blip' when [NumberUnits]>=(11) AND [NumberUnits]<=(20) then 'Small' when [NumberUnits]>=(21) AND [NumberUnits]<=(50) then 'Moderate' when [NumberUnits]>(50) then 'Strong'  end),
	[NumberCategories] [numeric](6, 0) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[SaleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[SPR26_SalesSummary] ADD  DEFAULT (getdate()) FOR [Invoice_Date]
GO

ALTER TABLE [dbo].[SPR26_SalesSummary] ADD  DEFAULT ((0)) FOR [Paid]
GO

ALTER TABLE [dbo].[SPR26_SalesSummary] ADD  DEFAULT ((0)) FOR [DaysAgo]
GO

ALTER TABLE [dbo].[SPR26_SalesSummary] ADD  DEFAULT ((0)) FOR [NumberCategories]
GO

ALTER TABLE [dbo].[SPR26_SalesSummary]  WITH CHECK ADD FOREIGN KEY([CustomerID])
REFERENCES [dbo].[SPR26_Customers] ([CustomerID])
GO


