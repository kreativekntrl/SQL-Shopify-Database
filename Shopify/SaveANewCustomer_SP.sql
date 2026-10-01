USE [MF67ava.steimle]
GO

/****** Object:  StoredProcedure [dbo].[SPR26_spSaveANewCustomer-Aug-26]    Script Date: 10/1/2026 11:05:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[SPR26_spSaveANewCustomer-Aug-26]
@FirstName nvarchar(50), @LastName nvarchar(50), @StreetAddress nvarchar(50), @ZipCodeT nvarchar(15)
AS
BEGIN
DECLARE @BeginningNumCustomers int
DECLARE @EndingNumCustomers int

IF EXISTS (SELECT*FROM[dbo].[SPR26_Customers]
		WHERE [FirstName] = @FirstName AND [Lastname] = @LastName)
	BEGIN
		PRINT 'Already have a customer with that name'
		RETURN
	END

IF NOT EXISTS (SELECT*FROM[dbo].[SPR26_Customers]
		WHERE [FirstName] = @FirstName AND [Lastname] = @lastName)
	BEGIN

		SET @BeginningNumCustomers = (SELECT COUNT(*) FROM[dbo].[SPR26_Customers])

			INSERT [dbo].[SPR26_Customers]
			([FirstName], [LastName], [StreetAddress], [ZipCodeT])

			VALUES
			(@Firstname, @LastName, @StreetAddress, @ZipCodeT)

		SET @EndingNumCustomers = (SELECT COUNT(*) FROM [dbo].[SPR26_Customers])

	IF @EndingNumCustomers > @BeginningNumCustomers
			BEGIN
				PRINT 'New Customer Added' + char(13) + 'Now total # Customers ='
				+ CONVERT(NVARCHAR(4), @EndingNumCustomers)
			END
	ELSE
			BEGIN
				PRINT 'Whoops'
			END
	END
END
GO


