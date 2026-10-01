USE [MF67ava.steimle]
GO

/****** Object:  Table [dbo].[SPR26_Vendors]    Script Date: 10/1/2026 11:02:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[SPR26_Vendors](
	[VendorID] [int] IDENTITY(1,1) NOT NULL,
	[VendorName] [nvarchar](100) NULL,
	[StreetAddress] [nvarchar](100) NULL,
	[ZipCodeT] [nvarchar](15) NULL,
	[NumberProducts] [numeric](8, 0) NULL,
	[NumberSales] [numeric](8, 0) NULL,
	[TotalRevenue] [numeric](8, 0) NULL,
	[TotalProfit] [numeric](8, 0) NULL,
	[TotalUnitsSold] [numeric](8, 0) NULL,
	[Remarks] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[VendorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[SPR26_Vendors] ADD  DEFAULT ((0)) FOR [NumberProducts]
GO

ALTER TABLE [dbo].[SPR26_Vendors] ADD  DEFAULT ((0)) FOR [NumberSales]
GO

ALTER TABLE [dbo].[SPR26_Vendors] ADD  DEFAULT ((0)) FOR [TotalRevenue]
GO

ALTER TABLE [dbo].[SPR26_Vendors] ADD  DEFAULT ((0)) FOR [TotalProfit]
GO

ALTER TABLE [dbo].[SPR26_Vendors] ADD  DEFAULT ((0)) FOR [TotalUnitsSold]
GO

ALTER TABLE [dbo].[SPR26_Vendors]  WITH CHECK ADD FOREIGN KEY([ZipCodeT])
REFERENCES [dbo].[SPR26_Geography] ([ZipCodeT])
GO


