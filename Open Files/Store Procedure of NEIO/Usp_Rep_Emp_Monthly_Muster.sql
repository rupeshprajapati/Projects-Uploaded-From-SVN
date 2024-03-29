DROP PROCEDURE [Usp_Rep_Emp_Monthly_Muster]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*=============================================
 Author:		Rupesh Prajapati.
 Create date: 
 Description:	This Stored procedure is useful to generate Monthly Muster Report.
 Modification Date/By/Reason:
 Remark: 
-- =============================================*/

Create Procedure [Usp_Rep_Emp_Monthly_Muster]
--@Pay_Month int
----@Empnm varchar(60) /*Ramya*/
--as
--Begin
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
BEGIN
	DECLARE @FCON AS NVARCHAR(2000)
	EXECUTE   USP_REP_FILTCON 
	@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=null
	,@VEDATE=null
	,@VSAC =@SAC,@VEAC =@EAC
	,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT
	,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
	,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE
	,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='e',@VITFILE='',@VACFILE=' '
	,@VDTFLD =''
	,@VLYN =NULL
	,@VEXPARA=@EXPARA
	,@VFCON =@FCON OUTPUT

	if(@FCON='')
	begin
		set @FCON=' where 1=1'
	end 	
	set @FCON=replace(@FCON,'Dept','Department')
	set @FCON=replace(@FCON,'Cate','Category')
	print @FCON



Declare @Pay_Year varchar(30),@Pay_Month varchar(30),@EmpNm varchar(100)
Declare @POS INT

--Set @EXPARA='[pay_year=2012][pay_month=January][EmpNm=Rup]'
if(charindex('[Pay_Year=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX(']',@EXPARA)
	SET @Pay_Year=SUBSTRING(@EXPARA,11,@POS-11)
end 	

if(charindex('[Pay_Month=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX('[Pay_Month=',@EXPARA)
	SET @Pay_Month=SUBSTRING(@EXPARA,@POS+11,len(@EXPARA)-@pos)
	SET @Pay_Month=replace(@Pay_Month,'[Pay_Month=','')
	SET @POS=CHARINDEX(']',@Pay_Month)
	SET @Pay_Month=SUBSTRING(@Pay_Month,1,@pos)
	SET @Pay_Month=replace(@Pay_Month,']','')
end

if(charindex('[EmpNm=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX('[EmpNm=',@EXPARA)
	SET @EmpNm=SUBSTRING(@EXPARA,@POS+7,len(@EXPARA)-@pos)
	SET @EmpNm=replace(@EmpNm,']','')
end


Declare @mth int
SELECT @mth=DATEPART(mm,CAST(@Pay_Month+ ' 1900' AS DATETIME))

	Declare @SqlCommand nvarchar(4000),@Att_Code Varchar(30),@Empcode varchar(10)
	Declare @ExpFileNm varchar(60),@EMailSub varchar(1000),@EmailBody varchar(8000)
--
--Select e.EmployeeCode,e.EmployeeName,et.Att_Code,et.Att_Nm,TotDays=cast(0 as Decimal(8,3)),L.Loc_Desc,e.Department,e.Category
--,@ExpFileNm as  ExpFileNm,@EMailSub as EMailSub,@EmailBody as EmailBody
--into ##EmpMuster 
--From Emp_Attendance_Setting et
--cross join EmployeeMast E
--Left Join Loc_Master L  on(e.Loc_Code=L.Loc_Code)
--	

Select e.EmployeeCode,e.EmployeeName,et.Att_Code,et.Att_Nm,TotDays=cast(0 as Decimal(8,3)),L.Loc_Desc,e.Department,e.Category, @ExpFileNm as  ExpFileNm,@EMailSub as EMailSub,@EmailBody as EmailBody  into #EmpMuster From Emp_Attendance_Setting et cross join EmployeeMast E Left Join Loc_Master L  on(e.Loc_Code=L.Loc_Code)   WHERE 1=2
Select @ExpFileNm=ExpFileNm,@EMailSub=EMailSub,@EmailBody=EmailBody From R_Status where Rep_Nm='EmpMonMust'


Set @SqlCommand='insert into #EmpMuster Select e.EmployeeCode,e.EmployeeName,et.Att_Code,et.Att_Nm,TotDays=cast(0 as Decimal(8,3)),L.Loc_Desc,e.Department,e.Category,'
--Set @SqlCommand=Rtrim(@SqlCommand)+' '+char(39)+@ExpFileNm+char(39) +',EMailSub='+char(39)+@EMailSub+char(39)+',EmailBody='+char(39)+@EmailBody+char(39)+'   From Emp_Attendance_Setting et'
Set @SqlCommand=Rtrim(@SqlCommand)+' '+char(39)+@ExpFileNm+char(39)+' as  ExpFileNm,'+char(39)+@EMailSub+char(39)+' as EMailSub,'+char(39)+@EmailBody+char(39)+' as EmailBody '
Set @SqlCommand=Rtrim(@SqlCommand)+' '+'From Emp_Attendance_Setting et '
Set @SqlCommand=Rtrim(@SqlCommand)+' '+'cross join EmployeeMast E'
Set @SqlCommand=Rtrim(@SqlCommand)+' '+'Left Join Loc_Master L  on(e.Loc_Code=L.Loc_Code)'
--Set @SqlCommand=Rtrim(@SqlCommand)+' '+'Select e.EmployeeCode,e.EmployeeName,et.Att_Code,et.Att_Nm,TotDays=cast(0 as Decimal(8,3)),L.Loc_Desc,e.Department,e.Category,@ExpFileNm as ExpFileNm,@EMailSub as EMailSub,@EmailBody as EmailBody  into ##EmpMuster From EmployeeMast e,Emp_Attendance_Setting et,Loc_Master L '
Set @SqlCommand=Rtrim(@SqlCommand)+' '+ @FCON
Set @SqlCommand=Rtrim(@SqlCommand)+' '+' and ActiveStatus=1 and IsNull(EmployeeCode,'''')<>'''' and (L.Loc_Code=e.Loc_Code)'
Set @SqlCommand=Rtrim(@SqlCommand)+' '+' order By EmployeeCode '  /*and e.Employeecode=@Empcode  Ramya*/
print 'hi'
print @SqlCommand
execute Sp_ExecuteSql @SqlCommand
--Select e.EmployeeCode,e.EmployeeName,et.Att_Code,et.Att_Nm,TotDays=cast(0 as Decimal(8,3)),L.Loc_Desc,e.Department,e.Category,ExpFileNm='+char(39)+@ExpFileNm+char(39) +',EMailSub='+char(39)+@EMailSub+char(39)+',EmailBody='+char(39)+@EmailBody+char(39)+'  into ##EmpMuster From EmployeeMast e,Emp_Attendance_Setting et,Loc_Master L 
--where ActiveStatus=1 and IsNull(EmployeeCode,'''')<>'''' and (L.Loc_Code=e.Loc_Code)


--Set @SqlCommand='exec tempdb..sp_help #EmpMuster'
--print @SqlCommand
--execute Sp_ExecuteSql @SqlCommand

	Declare  curMuster Cursor for
	Select Att_Code From Emp_Attendance_Setting order by SortOrd
	open curMuster 
	fetch next from curMuster into @Att_Code
	while(@@fetch_Status=0)
	begin
		set @SqlCommand='update a set a.TotDays=b.'+@Att_Code+' From #EmpMuster a inner join Emp_Monthly_Muster b on (a.EmployeeCode=b.EmployeeCode and pay_year='+char(39)+@Pay_Year+char(39)+' and pay_month='+cast(@mth as varchar)+') and Att_Code='+char(39)+@Att_Code+Char(39)
		print @SqlCommand
		execute Sp_ExecuteSql @SqlCommand
		fetch next from curMuster into @Att_Code
	end	
	Close curMuster
	DeAllocate curMuster


update #EmpMuster set EMailSub=replace(EMailSub,'@@Month',DateName( month , DateAdd( month , cast(@mth as int), 0 )-1  )),EmailBody=replace(EmailBody,'@@Month',DateName( month , DateAdd( month , cast(@mth as int), 0 )-1  ))  
update #EmpMuster set EMailSub=replace(EMailSub,'@@Year',@Pay_Year),EmailBody=replace(EmailBody,'@@Year',@Pay_Year)
update p set p.EmailBody=replace(p.EmailBody,'@@EmployeeName',(case when isnull(e.pMailName,'')='' then rtrim(e.EmployeeName) else rtrim(e.pMailName) end)) From #EmpMuster p inner join EmployeeMast e on (e.EmployeeCode=p.EmployeeCode)

	set @SqlCommand='Select a.* From #EmpMuster a inner join Emp_Monthly_Muster b on (a.EmployeeCode=b.EmployeeCode and pay_month='+cast(@mth as varchar)+')where TotDays<>0 '
	if isnull(@Pay_Year,'')<>''
	begin
	set @SqlCommand=rtrim(@SqlCommand)+' '+'and b.Pay_Year='+char(39)+@Pay_Year+char(39)
	end

	if isnull(@mth,'')<>''
	begin
	set @SqlCommand=rtrim(@SqlCommand)+' '+' and b.Pay_Month='+cast(@mth as varchar)
	end

	if isnull(@EmpNm,'')<>''
	begin
		set @SqlCommand=rtrim(@SqlCommand)+' '+' and a.EmployeeName='+char(39)+@EmpNm+char(39)
	end

set @SqlCommand=rtrim(@SqlCommand)+' '+'order by b.pay_year,b.pay_month,a.EmployeeName '

print @SqlCommand
execute Sp_ExecuteSql @SqlCommand
	--Execute Usp_Rep_Emp_monthly_Muster 4
 Drop table #EmpMuster
End



--EXECUTE USP_REP_MONTHLY_MUSTER'','','','','','','','','',0,0,'','TANKHWA             ','','TEMPORARY           ','','','','','2012-2013','[Pay_Year=2012][Pay_Month=April]'
GO
