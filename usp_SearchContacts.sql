SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Feroj Miah>
-- Create date: <07 Feb 2026>
-- Description:	<searches for contacts based on name or email address, incorporating support for pagination. Returns both the search results and the total count of matching records>
-- =============================================
-- table used Main.Contact

-- exec usp_SearchContacts 'ABC', '3'

CREATE OR ALTER PROCEDURE usp_SearchContacts
	@Query NVARCHAR(150) = null,
	@PageNo INT = 1,
	@PageSize INT = 20
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- handling '' empty parameters
	if @Query = '' set @Query = null
	if @PageNo = '' set @PageNo = 1

	select 
		C.Id,
		C.Name,
		C.Email,
		C.Phone,
		C.Title,
		Cust.Name as CustomerName,
		V.Name as VendorName,
		C.Blocked,
		C.Archived,
		count(*) over() as TotalCount
	from Main.Contact C
	left join Main.Customer Cust on Cust.Id = C.CustomerId
	left join Main.Vendor V on V.Id = C.VendorId
	where 
		(@Query is null
		or C.Name like '%' + @Query + '%'
		or C.Email like '%' + @Query + '%')
	order by C.Id ASC
	offset (@PageNo - 1) * @PageSize rows
	fetch next @PageSize rows only
END
GO
