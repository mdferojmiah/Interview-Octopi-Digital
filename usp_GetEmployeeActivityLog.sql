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
-- **special Note** : <1st I've solved the problem using join operation. But it was taking huge execution time. I solved this problem using temp table>
-- =============================================
-- table used Main.ActivityLog, Main.Employee

-- exec usp_GetEmployeeActivityLog '151', '2020-01-01'


CREATE OR ALTER PROCEDURE usp_GetEmployeeActivityLog 
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

	-- creating the Temp Table
	CREATE TABLE #EmployeeActivityLog (
		ActivityId BIGINT,
		ActivityType INT,
		Description NVARCHAR(250),
		ActivityDate DATETIME,
		Action INT,
		IP NVARCHAR(45),
		-- temp Ids for the update joins
		_EmpId BIGINT,
		_AccId BIGINT,
		_DocId BIGINT,
		_ProdId BIGINT,
		_VendId BIGINT,
		_CustId BIGINT,
		_LocId BIGINT,
		EmployeeName NVARCHAR(100),
		Email NVARCHAR(320),
		AccountName NVARCHAR(250),
		DocumentType NVARCHAR(500),
		ProductName NVARCHAR(200),
		VendorName NVARCHAR(300),
		CustomerName NVARCHAR(200),
		LocationName NVARCHAR(100)
	)

	-- inserting from Main.ActivityLog table data and Foreign Keys)
	INSERT INTO #EmployeeActivityLog (
		ActivityId, ActivityType, Description, ActivityDate, Action, IP, 
		_EmpId, _AccId, _DocId, _ProdId, _VendId, _CustId, _LocId
	)
	SELECT TOP (@MaxRow) 
		AL.Id, AL.ActivityType, AL.Description, AL.UpdatedOn, AL.Action, AL.IP,
		AL.UpdatedBy, AL.AccountId, AL.DocumentTypeId, AL.ProductId, AL.VendorId, AL.CustomerId, AL.LocationId
	FROM Main.ActivityLog AL
	WHERE (@EmployeeID IS NULL OR AL.UpdatedBy = @EmployeeID)
	  AND (@StartDate IS NULL OR AL.UpdatedOn >= @StartDate)
	  AND (@EndDate IS NULL OR AL.UpdatedOn <= @EndDate)
	ORDER BY AL.UpdatedOn DESC
	
	-- from Main.Employee table
	UPDATE #EmployeeActivityLog
	SET EmployeeName = E.FirstName + ' ' + ISNULL(E.LastName, ''),
	    Email = E.Email
	FROM #EmployeeActivityLog T
	INNER JOIN Main.Employee E ON T._EmpId = E.Id

	-- from Main.Account table
	UPDATE #EmployeeActivityLog
	SET AccountName = A.Name
	FROM #EmployeeActivityLog T
	INNER JOIN Main.Account A ON T._AccId = A.Id

	-- from Main.DocumentType table
	UPDATE #EmployeeActivityLog
	SET DocumentType = D.Name
	FROM #EmployeeActivityLog T
	INNER JOIN Main.DocumentType D ON T._DocId = D.Id

	-- from Main.Product table
	UPDATE #EmployeeActivityLog
	SET ProductName = P.Name
	FROM #EmployeeActivityLog T
	INNER JOIN Main.Product P ON T._ProdId = P.Id

	-- from Main.Vendor table
	UPDATE #EmployeeActivityLog
	SET VendorName = V.Name
	FROM #EmployeeActivityLog T
	INNER JOIN Main.Vendor V ON T._VendId = V.Id

	-- from Main.Customer table
	UPDATE #EmployeeActivityLog
	SET CustomerName = C.Name
	FROM #EmployeeActivityLog T
	INNER JOIN Main.Customer C ON T._CustId = C.Id

	-- from Main.Location table
	UPDATE #EmployeeActivityLog
	SET LocationName = L.Name
	FROM #EmployeeActivityLog T
	INNER JOIN Main.Location L ON T._LocId = L.Id

	-- final selection without the tempIds
	SELECT 
		ActivityId, ActivityType, Description, ActivityDate, Action, IP,
		EmployeeName, Email, AccountName, DocumentType, ProductName, 
		VendorName, CustomerName, LocationName
	FROM #EmployeeActivityLog
	ORDER BY ActivityDate DESC

	-- droping the temp table
	DROP TABLE #EmployeeActivityLog
	
END
GO