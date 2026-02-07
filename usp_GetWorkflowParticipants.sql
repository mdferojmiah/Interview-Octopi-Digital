SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- =============================================
-- Author:		<Feroj Miah>
-- Create date: <07 Feb 2026>
-- Description:	<Retrieves the participants associated with a given workflow, including their corresponding employee details, and orders the output according to the participant order.>
-- =============================================
-- table used Workflow.Participant, Workflow.Workflow, Main.Employee

-- exec usp_GetWorkflowParticipants '1'

CREATE OR ALTER PROCEDURE usp_GetWorkflowParticipants
	@WorkflowId BIGINT = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- handling '' empty parameter
	if @WorkflowId = '' set @WorkflowId = null

	select 
	WP.Id as ParticipantId,
	WP.Name as ParticipantName,
	WW.Name as WorkFlowName,
	WP.WorkflowType,
	WP.[Order],
	ME.FirstName as EmpFirstName,
	ME.LastName as EmpLastName,
	ME.Email as EmpEmail,
	WP.Archived
	from Workflow.Participant WP
	left join Workflow.Workflow WW on WW.Id = WP.WorkflowId
	left join Main.Employee ME on ME.Id = WP.UserId
	where (@WorkflowId is null or WP.WorkflowId = @WorkflowId)
	order by WP.[Order] asc
    
END
GO
