SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Feroj Miah>
-- Create date: <08 Feb 2026>
-- Description:	<A comprehensive dashboard showcasing activity metrics per employee, encompassing activity counts, the timestamp of the last activity, and the distribution of activity types>
-- =============================================
-- table used Main.Employee, Main.ActivityLog

-- exec usp_GenerateActivityDashboard

CREATE OR ALTER PROCEDURE usp_GenerateActivityDashboard 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select 
		e.Id,
		e.FirstName + ' ' + isnull(e.LastName, '') as EmployeeName,
		count(a.Id) as TotalActivityCount,
		max(a.UpdatedOn) as LastActivity,
		sum(case when a.ActivityType = 5 then 1 else 0 end) as SecurityLogIns,
		sum(case when a.ActivityType in (1,2)  then 1 else 0 end) as ProductjOperation,
		sum(case when a.ActivityType = 3 then 1 else 0 end) as VendorMgmt,
		sum(case when a.ActivityType = 4 then 1 else 0 end) as Cust_DocMgmt,
		sum(case when a.ActivityType = 6 then 1 else 0 end) as EmailOps,
		sum(case when a.ActivityType = 7 then 1 else 0 end) as DashboardMgmt
	from Main.Employee e
	inner join Main.ActivityLog a on a.UpdatedBy = e.Id
	group by 
		e.Id, 
		e.FirstName, 
		e.LastName
	having count(a.Id) > 0
	order by TotalActivityCount desc
    
END
GO
