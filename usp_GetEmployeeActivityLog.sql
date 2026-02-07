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

CREATE OR ALTER PROCEDURE usp_GetEmployeeActivityLog 
	@EmployeeID INT = null,
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
		E.FirstName,
		E.LastName,
		E.Email,
		AL.ActivityType,
		AL.Description,
		AL.UpdatedOn as ActivityDate,
		AL.Action,
		AL.IP
	from Main.ActivityLog AL
	left join Main.Employee E on AL.UpdatedBy = E.Id
	where 
		(@EmployeeID is null or AL.UpdatedBy = @EmployeeID)
		and (@StartDate is null or AL.UpdatedOn >= @StartDate)
		and (@EndDate is null or AL.UpdatedOn <= @EndDate)
	order by AL.UpdatedOn desc
END
GO
