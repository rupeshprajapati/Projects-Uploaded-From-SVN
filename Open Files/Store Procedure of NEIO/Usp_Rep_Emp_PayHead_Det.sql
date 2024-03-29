DROP PROCEDURE [Usp_Rep_Emp_PayHead_Det]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Created By : Rupesh Prajapati
-- Create date: 19/03/2012
-- Description:	This Stored Procedure is used by Employee Report for getting Earning & Deduction Details
-- Remark	  : 
-- Modified By and Date : [Usp_Rep_Emp_Pay_Head_Details]'',''
-- =============================================
CREATE PROCEDURE [Usp_Rep_Emp_PayHead_Det]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(1000)
AS

Declare @FCON as NVARCHAR(2000)

BEGIN
	DECLARE @fld_nm VARCHAR(30),@EmployeeCode varchar(30),@SqlCommand NVARCHAR(4000),@FldVal NUMERIC(17,2),@FldSelYN bit
	DECLARE @ParmDefinition nvarchar(500);
	Select a.EmployeeCode,b.Head_Nm,b.Fld_Nm,Appl='Yes',Amount=BasicAmt into #EmpPayHead From Emp_Pay_Head_Details a,Emp_Pay_Head_MASTER b where (b.IsDeactive=0) order by A.EmployeeCode
	Declare cur_EmpPayHead cursor for Select EmployeeCode,Fld_Nm From #EmpPayHead order by EmployeeCode
	open cur_EmpPayHead
	Fetch next from cur_EmpPayHead into @EmployeeCode,@Fld_Nm	
	while(@@Fetch_Status=0)
	begin
		set @SqlCommand='Update a set Appl=(case when b.'+rtrim(@Fld_Nm)+'Yn=1 then ''Yes'' else ''No'' end) From  #EmpPayHead a inner join Emp_Pay_Head_Details b on (a.EmployeeCode=B.EmployeeCode) where a.EmployeeCode='+Char(39)+@EmployeeCode+Char(39) +' and Fld_Nm='+char(39)+@Fld_Nm+char(39)
		print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand
		set @SqlCommand='Update a set Amount= b.'+rtrim(@Fld_Nm)+' From  #EmpPayHead a inner join Emp_Pay_Head_Details b on (a.EmployeeCode=B.EmployeeCode) where a.EmployeeCode='+Char(39)+@EmployeeCode+Char(39) +' and Fld_Nm='+char(39)+@Fld_Nm+char(39)
		print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand

		Fetch next from cur_EmpPayHead into @EmployeeCode,@Fld_Nm	
	end
	Close cur_EmpPayHead
	Deallocate  cur_EmpPayHead
	DELETE FROM #EmpPayHead WHERE APPL='No'
	Select a.*,E.EmployeeName,E.DepartMent,E.Category,L.Loc_Desc From #EmpPayHead a inner join EmployeeMast e on (a.EmployeeCode=e.EmployeeCode) left join Loc_Master l on (e.Loc_Code=l.Loc_Code) order by l.Loc_Desc,E.Department,E.Category,E.EmployeeName
	
END
GO
