SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Feroj Miah>
-- Create date: <07 Feb 2026>
-- Description:	<Returns recent login dates with an option to filter for inactive employees>
-- =============================================
-- table used Main.Employee, Main.LoginHistory

-- exec usp_GetEmployeeLoginHistory '2024-01-01', '2026-02-08'

CREATE OR ALTER PROCEDURE usp_GetEmployeeLoginHistory 
	@FromDate DATETIME = null,
	@ToDate DATETIME = null,
	@ShowInactiveOnly BIT = 0,
	@InactiveThresholdDate DATETIME = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- handling '' missing parameters
	if @FromDate = '' set @FromDate = null
	if @ToDate = '' set @ToDate = null
	if @ShowInactiveOnly = '' set @ShowInactiveOnly = 0
	-- the user who have not logged in in 30 days to be filtered using @InactiveThresholdDate
	if (@InactiveThresholdDate is null or @InactiveThresholdDate = '') set @InactiveThresholdDate =  dateadd(day, -30, GETDATE())

	select 
		e.Id AS Id,
        e.FirstName,
        e.LastName,
        e.Email,
        MAX(l.[Date]) AS LastLoginDate
	from Main.Employee e
	left join Main.LoginHistory l on l.UserId = e.Id
	where 
		(@FromDate is null or l.[Date] >= @FromDate)
		and (@ToDate is null or l.[Date] <= @ToDate)
	group by
		e.Id, e.FirstName, e.LastName, e.Email
	having 
		(@ShowInactiveOnly = 0)
		or (@ShowInactiveOnly = 1 and max(l.[Date]) < @InactiveThresholdDate)
		or (@ShowInactiveOnly = 1 and max(l.[Date]) is null)
	order by LastLoginDate desc
    
END
GO
