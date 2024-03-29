DROP PROCEDURE [Usp_Ent_Emp_Pay_Head_Details]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Created By : Rupesh Prajapati
-- Create date: 19/03/2012
-- Description:	This Stored Procedure is used by Employee master for getting Earning & Deduction Details
-- Remark	  : 
-- Modified By and Date : 
-- =============================================
CREATE PROCEDURE [Usp_Ent_Emp_Pay_Head_Details]
@EmpCode VARCHAR(30),@edtype AS VARCHAR(2)
AS
BEGIN
	DECLARE @fld_nm VARCHAR(30),@SqlCommand NVARCHAR(4000),@FldVal NUMERIC(17,2),@FldSelYN bit
	DECLARE @ParmDefinition nvarchar(500);
	
	SELECT Head_Nm,Fld_Nm,b.HeadType,Amount=CAST(0 AS Decimal(17,2)),FldSel=cast(0 as bit)  INTO #EdDet FROM dbo.Emp_Pay_Head_MASTER  a
	inner join Emp_Pay_Head b on (a.HeadTypeCode=b.HeadTypeCode)
	--WHERE HEadTypeCode=@edtype 
	ORDER BY b.SortOrd,a.SortOrd
	--ORDER BY HeadTypeCode DESC,SortOrd
	
	SET @SqlCommand=''
	Declare cur_EdDet CURSOR FOR 
	SELECT fld_nm FROM #EdDet
	OPEN cur_EdDet
	FETCH NEXT FROM cur_EdDet INTO @fld_nm 
	WHILE(@@FETCH_STATUS =0)
	BEGIN
		SET @FldVal=0
		SET @SqlCommand='select @FldValOut='+@fld_nm+',@FldSelYNOut='+@fld_nm+'YN'+' FROM Emp_Pay_Head_Details where employeecode='+CHAR(39)+@EmpCode+CHAR(39)
		PRINT @SqlCommand
		SET @ParmDefinition = N' @FldValOut Decimal(17,2) OUTPUT , @FldSelYNOut bit OUTPUT'
		EXECUTE sp_executesql @SqlCommand,@ParmDefinition,@FldValOut=@FldVal OUTPUT,@FldSelYNOut=@FldSelYN OUTPUT
		PRINT @FldVal
		SET @SqlCommand='UPDATE #EdDet SET Amount='+CAST(@FldVal AS varchar)+', FldSel='+CAST(@FldSelYN AS varchar)+ ' where fld_nm=' +CHAR(39)+@fld_nm+CHAR(39)
		PRINT @SqlCommand
		EXECUTE sp_executesql  @SqlCommand
		FETCH NEXT FROM cur_EdDet INTO @fld_nm 
	END
	CLOSE cur_EdDet
	DEALLOCATE cur_EdDet
	SELECT * FROM #EdDet
END
GO
