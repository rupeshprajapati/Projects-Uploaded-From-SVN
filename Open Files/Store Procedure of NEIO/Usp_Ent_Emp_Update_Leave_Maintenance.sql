DROP PROCEDURE [usp_Ent_Emp_Update_Leave_Maintenance]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 30/05/2012
-- Description:	This Stored procedure is useful to generate processing Month in Entry Module.
-- Modification Date/By/Reason:
-- Modification Date/By/Reason:
-- Remark: 
-- =============================================
Create Procedure [usp_Ent_Emp_Update_Leave_Maintenance]
@Year varchar(30),@Month int,@Loc_Code varchar(10)
as
Begin
	Declare @SqlCommand nvarchar(4000)
	Declare @LvAutocr Decimal(12,3),@att_code varchar(3)
	declare cur_lvUpdate cursor for select att_code,LvAutocr from Emp_Attendance_Setting where isleave=1
	open cur_lvUpdate
	fetch next from cur_lvUpdate into @att_code,@LvAutocr
	while (@@fetch_status=0)
	begin
		Set @SqlCommand='update a set a.'+@att_code+'_Availed=b.'+@att_code+' From Emp_Leave_Maintenance a inner join Emp_Monthly_Muster b on (a.EmployeeCode=B.EmployeeCode and a.Pay_Year=b.Pay_Year and a.Pay_Month=b.Pay_Month) and b.Pay_Year='+char(39)+@Year+char(39)+' and b.Pay_Month='+cast(@Month as Varchar)
		print  @SqlCommand	
		execute Sp_ExecuteSql @SqlCommand

		Set @SqlCommand=''
		Set @SqlCommand=rtrim(@SqlCommand)+'update Emp_Leave_Maintenance Set '+@att_code+'_Balance='+@att_code+'_OpBal+'+@att_code+'_Credit-'+@att_code+'_Availed-'+@att_code+'_EnCash'
		print  @SqlCommand	
		execute Sp_ExecuteSql @SqlCommand
		fetch next from cur_lvUpdate into @att_code,@LvAutocr
		

	end
	close cur_lvUpdate
	deallocate cur_lvUpdate
End
GO
