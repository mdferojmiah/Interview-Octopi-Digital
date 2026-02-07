SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Feroj Miah>
-- Create date: <07 Feb 2026>
-- Description:	<Generates a report detailing activity counts stratified by type and action within a specified date range, with aggregation performed by activity type>
-- =============================================
-- table used Main.ActivityLog

-- exec usp_GetActivityReport

CREATE OR ALTER PROCEDURE usp_GetActivityReport
	@FromDate DATETIME = null,
	@ToDate DATETIME = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- handling '' empty parameters
	if @FromDate = '' set @FromDate = null
	if @ToDate = '' set @ToDate = null

	select 
		ActivityType,
		Action,
		count(*) as ActivityCount,
		min(UpdatedOn) as FirstRecorded,
		max(UpdatedOn) as LastRecorded
	from Main.ActivityLog AL
	where 
		(@FromDate is null or AL.UpdatedOn >= @FromDate)
		and (@ToDate is null or AL.UpdatedOn <= @ToDate)
	group by
		AL.ActivityType,
		AL.Action
	order by
		AL.ActivityType ASC,
		AL.Action ASC
END
GO
