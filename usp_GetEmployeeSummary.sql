SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Feroj Miah>
-- Create date: <07 Feb 2026>
-- Description:	<Furnishes employee statistical data, including the total number of employees, active employees, and archived employees, with optional filtering capability by account>
-- =============================================
-- table used Main.Employee

-- exec usp_GetEmployeeSummary

CREATE OR ALTER PROCEDURE usp_GetEmployeeSummary
	@AccountId BIGINT = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select count(Id) as TotalEmployees,
		sum(case when E.Archived = 0 then 1 else 0 end) as ActiveEmployees,
		sum(case when E.Archived = 1 then 1 else 0 end) as ArchievedEmployess
	from Main.Employee E
	where @AccountId is null or E.AccountId = @AccountId
END
GO
