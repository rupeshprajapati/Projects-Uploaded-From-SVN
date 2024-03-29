DROP PROCEDURE [USP_REP_EMP_PT_DEDUCTION_DETAILS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Ramya
-- Create date: 05/03/2012
-- Description:	This is useful for Employee Pf Details Report
-- Modify date: 06/02/2013
-- Modify By : Archana K.
-- Description : Bug-8633- Added Statutory Details fields. 
-- Remark:
-- =============================================

CREATE PROCEDURE [USP_REP_EMP_PT_DEDUCTION_DETAILS]
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

Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)

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
,@VMAINFILE='e',@VITFILE='',@VACFILE=''
,@VDTFLD =''
,@VLYN=NULL 
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

if(@FCON='')
begin
	set @FCON=' where 1=1'
end 	
set @FCON=replace(@FCON,'Dept','Department')
set @FCON=replace(@FCON,'Cate','Category')
print @FCON

Declare @Pay_Year varchar(30),@Pay_Month int,@cPay_Month varchar(30),@EmpNm varchar(100)
Declare @POS INT
	
BEGIN
--Declare @Pay_Year varchar(30),@Pay_Month int,@cPay_Month varchar(30)
--Declare @POS INT
--Set @EXPARA='[Pay_Year=2012][Pay_Month=January]'
--SET @POS=CHARINDEX(']',@EXPARA)
--PRINT @POS
--SET @Pay_Year=SUBSTRING(@EXPARA,10,@POS-10)
--PRINT @Pay_Year
--SET @POS=CHARINDEX('[Pay_Month=',@EXPARA)
--SET @cPay_Month=SUBSTRING(@EXPARA,@POS+10,len(@EXPARA)-@pos)
--SET @cPay_Month=replace(@cPay_Month,']','')
--print @cPay_Month

if(charindex('[Pay_Year=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX(']',@EXPARA)
	SET @Pay_Year=SUBSTRING(@EXPARA,11,@POS-11)
	print @Pay_Year
end 	

if(charindex('[Pay_Month=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX('[Pay_Month=',@EXPARA)
	SET @cPay_Month=SUBSTRING(@EXPARA,@POS+11,len(@EXPARA)-@pos)
	SET @cPay_Month=replace(@cPay_Month,'[Pay_Month=','')
	SET @POS=CHARINDEX(']',@cPay_Month)
	SET @cPay_Month=SUBSTRING(@cPay_Month,1,@pos)
	SET @cPay_Month=replace(@cPay_Month,']','')
	print @cPay_Month
end

if(charindex('[EmpNm=',@EXPARA)>0)
begin
	SET @POS=CHARINDEX('[EmpNm=',@EXPARA)
	SET @EmpNm=SUBSTRING(@EXPARA,@POS+7,len(@EXPARA)-@pos)
	SET @EmpNm=replace(@EmpNm,']','')
	Print @EmpNm
end

PRINT @Pay_Year
print @cPay_Month
print @EmpNm

Select @Pay_Month =
     case  @cPay_Month 
        when 'January' then 1 
        when 'February' then 2	
		when 'March' then 3 
		when 'April' then 4 
		when 'May' then 5 
		when 'June' then 6 
		when 'July' then 7 
		when 'August' then 8 
		when 'September' then 9 
		when 'October' then 10 
		when 'November' then 11
		when 'December' then 12 end

--	case when @cPay_Month='January' then 1 
--	case when @cPay_Month='February' then 2	
--	case when @cPay_Month='March' then 3 
--	case when @cPay_Month='April' then 4 
--	case when @cPay_Month='May' then 5 
--    case when @cPay_Month='June' then 6 
--    case when @cPay_Month='July' then 7 
--    case when @cPay_Month='August' then 8 
--    case when @cPay_Month='September' then 9 
--    case when @cPay_Month='October' then 10 
--    case when @cPay_Month='November' then 11 
--    case when @cPay_Month='December' then 12 end





--Set @Pay_Year='2012'
--Set @Pay_Month=4

--select  EmployeeCode,EmployeeName,GRossSal=PackageSal,pTaxAmt=PackageSal  into #EmpPTax from EmployeeMast where 1=2
--select  E.EmployeeCode,E.EmployeeName,GRossSal=E.PackageSal,pTaxAmt=E.PackageSal,P.Pay_Month,p.Pay_Year  into #EmpPTax from EmployeeMast E --Commented by Archana K. on 07/02/13 for Bug-8633
select  E.EmployeeCode,E.EmployeeName,GRossSal=E.PackageSal,pTaxAmt=E.PackageSal,P.Pay_Month,p.Pay_Year,E.Loc_code into #EmpPTax from EmployeeMast E  --Changes by Archana K. on 05/02/13 for Bug-8633(add Loc_code field)
Inner Join emp_monthly_payroll P on(E.EmployeeCode=P.EmployeeCode)
where 1=2

--select P.EmployeeCode,P.Pay_Month,p.Pay_Year,P.BasicAmt,P.PfEmpE,P.PfEmpR,P.EPSAmt,E.PFNO,E.EmployeeName,M.LOP from  emp_monthly_payroll P 
--Left Join Employeemast E on(P.EmployeeCode=E.EmployeeCode)
--Left Join emp_monthly_muster M on(P.EmployeeCode=M.EmployeeCode and m.Pay_Year=p.Pay_Year and m.Pay_Month=p.Pay_Month)
--WHERE p.Pay_Year=@EXPARA,p.Pay_Month= and ORDER BY Pay_Year ,sdate

declare @HeadNm VARCHAR(30)
declare @Earnings varchar(500)
set  @Earnings='0'
 declare c1 cursor for select fld_nm from emp_pay_head_master where HeadTypeCode='E'
 open c1
	 fetch next from c1 into @HeadNm
        while(@@fetch_status=0)
		begin
          set @Earnings=@Earnings+'+'+@HeadNm
          fetch next from c1 into @HeadNm
        end
   
close c1
deallocate c1
print '@Earnings '+@Earnings
print @HeadNm
--select @HeadNm as HeadName 
--

Set @SqlCommand='insert into #EmpPTax (EmployeeCode,EmployeeName,GrossSal,pTaxAmt,Pay_Month,Pay_Year,Loc_Code)'
Set @SqlCommand=Rtrim(@SqlCommand)+' '+'Select p.EmployeeCode,e.EmployeeName,'+@Earnings+',PTaxAmt,p.Pay_Month,p.Pay_Year,E.Loc_code' --Changes by Archana K. on 05/02/13 for Bug-8633(add Loc_code field)
Set @SqlCommand=Rtrim(@SqlCommand)+' '+'From Emp_Monthly_Payroll p inner join EmployeeMast E on (e.EmployeeCode=p.EmployeeCode)'
Set @SqlCommand=Rtrim(@SqlCommand)+' '+RTRIM(@FCON)
Set @SqlCommand=Rtrim(@SqlCommand)+' '+' and (PTaxAmt<>0) '--and (Pay_Year='+char(39)+@Pay_Year+''') and (Pay_Month='+Cast(@Pay_Month as varchar)+')'

if(@Pay_Year<>'')
begin
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+'and (p.Pay_Year='+char(39)+@Pay_Year+char(39)+')'
end	
if(@Pay_Month<>0)
begin
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+'and (p.Pay_Month='+Cast(@Pay_Month as varchar)+')'
end	
if(@EmpNm<>'')
begin
	Set @SqlCommand=Rtrim(@SqlCommand)+' '+'and (e.EmployeeName='+char(39)+@EmpNm+char(39)+')'
end	
--Set @SqlCommand=Rtrim(@SqlCommand)+' '+'ORDER BY p.Pay_Year'


print @SqlCommand
Execute Sp_ExecuteSql @SqlCommand
--select  * from emp_monthly_payroll
--Select * From #EmpPTax ORDER BY Pay_Year,Pay_Month,EmployeeCode-- Commeted By Archana K. on 06/02/13 for Bug-8633
--
Select e.*,l.Loc_desc,l.PT_Code,l.PT_Sign
From #EmpPTax e
Left Join loc_master l on(e.loc_code=l.loc_code) ORDER BY Pay_Year,Pay_Month,EmployeeCode,PT_Code--Changes by Archana K. on 05/02/13 for Bug-8633(add Loc_desc,PT_Code,PT_Sign fields)
END
GO
