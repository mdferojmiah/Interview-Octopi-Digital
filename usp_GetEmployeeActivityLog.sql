USE [DCN-Miju]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetEmployeeActivityLog]    Script Date: 2/8/2026 4:36:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Feroj Miah>
-- Create date: <07 Feb 2026>
-- Description:	<Retrieves employee activity records based on Employee ID, a defined date range, and a maximum row limit. The parameters are optional>
-- =============================================
-- table used Main.ActivityLog, Main.Employee

-- exec usp_GetEmployeeActivityLog '151', '2020-01-01'

ALTER   PROCEDURE [dbo].[usp_GetEmployeeActivityLog] 
	@EmployeeID BIGINT = null,
	@StartDate DATETIME = null,
	@EndDate DATETIME = null,
	@MaxRow INT = 100
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- handling  '' empty parameters
	if @EmployeeID = '' set @EmployeeID = null
	if @StartDate = '' set @StartDate = null
	if @EndDate = '' set @EndDate = null
	if @MaxRow = '' set @MaxRow = 100

    select top (@MaxRow)
		AL.Id as ActivityId,
		AL.ActivityType,
		AL.Description,
		AL.UpdatedOn as ActivityDate,
		AL.Action,
		E.FirstName + ' ' + isnull(E.LastName, '') as EmployeeName,
		E.Email,
		AL.IP,
		A.Name as AccountName,
		D.Name as DocumentType,
		P.Name as ProductName,
		V.Name as VendorName,
		C.Name as CustomerName,
		L.Name as LocationName
	from Main.ActivityLog AL
	left join Main.Employee E on AL.UpdatedBy = E.Id
	left join Main.Account A on A.Id = AL.AccountId
	left join Main.DocumentType D on D.Id = AL.DocumentTypeId
	left join Main.[Product] P on P.Id = AL.ProductId
	left join Main.Vendor V on V.Id = AL.VendorId
	left join Main.Customer C on C.Id = AL.CustomerId
	left join Main.[Location] L on L.Id = AL.LocationId
	where 
		(@EmployeeID is null or AL.UpdatedBy = @EmployeeID)
		and (@StartDate is null or AL.UpdatedOn >= @StartDate)
		and (@EndDate is null or AL.UpdatedOn <= @EndDate)
	order by AL.UpdatedOn desc
END
