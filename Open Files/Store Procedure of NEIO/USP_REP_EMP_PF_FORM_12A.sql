DROP PROCEDURE [USP_REP_EMP_PF_FORM_12A]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI.
-- CREATE DATE: 06/12/2012
-- DESCRIPTION:	This Stroed Procedure is useful for PF Foorm 12A Report
-- Modification Date/By/Reason: 
-- Remark: 
-- =============================================
Create PROCEDURE    [USP_REP_EMP_PF_FORM_12A]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= NULL
AS
Begin
	DECLARE @FCON AS NVARCHAR(2000),@SQLCOMMAND NVARCHAR(4000)
	EXECUTE   USP_REP_FILTCON 
	@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=@SDATE
	,@VEDATE=@EDATE
	,@VSAC =@SAC,@VEAC =@EAC
	,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT
	,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
	,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE
	,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='p',@VITFILE='',@VACFILE=''
	,@VDTFLD ='MnthLastDt'
	,@VLYN =NULL
	,@VEXPARA=@EXPARA
	,@VFCON =@FCON OUTPUT
	Declare @LastMonth SmallDateTime,@lMnthEmp int,@nMnthEmp int,@Empleft int,@tEmpNo int,@tContEmpNo int,@BankNm varchar(100),@BankAdd varchar(8000),@pDate SmallDateTime
	Select p.Tran_cd,p.EmployeeCode,p.Pay_Year,p.Pay_Month,p.BasicAmt,p.PFEmpE,p.PFEmpR,p.EPSAMT,p.PfAdChg,p.EDLIContr,p.EDLIAdChg,p.VEPFAmt,pPFEmpE=p.PFEmpE,pPFEmpR=p.PFEmpR,pEPSAMT=p.EPSAMT,pPfAdChg=p.PfAdChg,pEDLIContr=p.EDLIContr,pEDLIAdChg=p.EDLIAdChg,pVEPFAmt=p.VEPFAmt 
	,pDate=MnthLastDt,p.Fh_Trn_Cd--,lMnthEmp =Cast(0 as int),Empleft =Cast(0 as int)
	,Bank_Name=cast('' as varchar(4000)),BankAdd=cast('' as varchar(4000))
	into #Emp_Monthly_Payroll
	From Emp_Monthly_Payroll p where 1=2
	
	--EXECUTE USP_REP_EMP_PF_FORM_12A'','','','04/01/2012','05/31/2012','','','','',0,0,'','','','','','','','','2012-2013',''
	Set @SQLCOMMAND='Insert into #Emp_Monthly_Payroll Select p.Tran_cd,p.EmployeeCode,p.Pay_Year,p.Pay_Month,p.BasicAmt,p.PFEmpE,p.PFEmpR,p.EPSAMT,p.PfAdChg,p.EDLIContr,p.EDLIAdChg,p.VEPFAmt'
	Set @SQLCOMMAND=@SQLCOMMAND+' ,pPFEmpE =p.PFEmpE, pPFEmpR=p.PFEmpE,pEPSAMT=p.EPSAMT,pPfAdChg=p.PfAdChg,pEDLIContr=p.EDLIContr,pEDLIAdChg=p.EDLIAdChg,pVEPFAmt=p.VEPFAmt'
	Set @SQLCOMMAND=@SQLCOMMAND+' ,pDate=U_CHALDT,Fh_Trn_Cd=bpm.Tran_cd'
	Set @SQLCOMMAND=@SQLCOMMAND+' ,Bank_Name=acm.Ac_Name,BankAdd=rtrim(acm.Add1)+'',''+rtrim(acm.Add2)+'',''+rtrim(acm.Add3)+'',''+rtrim(acm.City)+''-''+rtrim(acm.Zip)'
	Set @SQLCOMMAND=@SQLCOMMAND+' From Emp_Monthly_Payroll p '
	Set @SQLCOMMAND=@SQLCOMMAND+' Left Join BpMain Bpm on (p.Fh_Ent_Ty=bpm.Entry_Ty and p.Fh_Trn_Cd=bpm.Tran_Cd)'--and bpm.Date between'+Char(39)+Cast(@sDate as Varchar)+Char(39)+' and '+Char(39)+Cast(@eDate as Varchar)+Char(39)+' )'
	Set @SQLCOMMAND=@SQLCOMMAND+' Left Join Ac_mast acm on (bpm.Bank_Nm=acm.Ac_Name)'
	Set @SQLCOMMAND=@SQLCOMMAND++@FCON
	Set @SQLCOMMAND=@SQLCOMMAND+' And p.PFEmpE<>0'
	print @SQLCOMMAND
	execute Sp_ExecuteSql @SQLCOMMAND
	Select distinct EmployeeCode into #EmpCode From #Emp_Monthly_Payroll
	
	Select @tEmpNo=count(EmployeeCode) From #EmpCode e
	Select top 1 @BankNm=Bank_Name,@BankAdd=BankAdd,@pDate=pDate From #Emp_Monthly_Payroll Where isnull(Bank_Name,'')<>''
	update #Emp_Monthly_Payroll set Bank_Name=@BankNm,BankAdd=@BankAdd,pDate=@pDate
	Select @tContEmpNo=count(e.EmployeeCode) From #EmpCode e inner join employeeMast e1 on (e.EmployeeCode=e1.EmployeeCode) where e1.IsContract=1

	update #Emp_Monthly_Payroll set pPFEmpE=0,pPFEmpR=0,pEPSAMT=0,pPfAdChg=0,pEDLIContr=0,pEDLIAdChg=0,pVEPFAmt=0 Where isnull(Fh_Trn_Cd	,0)=0

	Set @LastMonth=DATEADD (month , -1, @sDate )
	Print 	@LastMonth
	Select @lMnthEmp=count(EmployeeCode) From Emp_monthly_Payroll where PFEmpE<>0 and Pay_Year=year(@LastMonth) and Pay_Month=Month(@LastMonth)
	Set @lMnthEmp=isnull(@lMnthEmp,0)
	
	Select @Empleft=count(p.EmployeeCode) From Emp_monthly_Payroll p inner join EmployeeMast em on (p.EmployeeCode=em.EmployeeCode) where PFEmpE<>0 and Pay_Year=year(@LastMonth) and Pay_Month=Month(@LastMonth) and isnull(em.DOL,'')<>'' and p.EmployeeCode in (Select distinct EmployeeCode From Emp_monthly_Payroll where PFEmpE<>0)
	Set @Empleft=isnull(@Empleft,0)
	

	Select *,tEmpNo=@tEmpNo,tContEmpNo=@tContEmpNo,lMnthEmp=@lMnthEmp,Empleft=@Empleft From #Emp_Monthly_Payroll order by EmployeeCode
	

End
GO
