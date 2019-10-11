DROP PROCEDURE [USP_REP_EMP_PF_FORM_3A]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI.
-- CREATE DATE: 06/12/2012
-- DESCRIPTION:	This Stroed Procedure is useful for PF Form 3A Report
-- Modification Date/By/Reason: 
-- Remark: 
-- =============================================
Create PROCEDURE    [USP_REP_EMP_PF_FORM_3A]
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
	
	Declare @tDate SmallDateTime	
	Select em.EmployeeCode,em.pMailName,em.mName,em.PFNO,p.Pay_Year,p.Pay_Month,p.BasicAmt,p.PFEmpE,p.PFEmpR,p.EPSAmt,Refund=p.EPSAmt,p.SalpaidDays,em.DOL into #PF3A From Emp_Monthly_Payroll p inner join EmployeeMast em on (em.EmployeeCode=p.EmployeeCode) Where 1=2
	
	Set @tDate=@sDate
	While (@tDate<=@eDate)
	Begin
		Print @tDate
		Set @tDate=DateAdd(month,1,@tDate)
		Insert into #PF3A
		Select em.EmployeeCode,em.pMailName,em.mName,em.PFNO,p.Pay_Year,p.Pay_Month,p.BasicAmt,p.PFEmpE,p.PFEmpR,p.EPSAmt,Refund=p.EPSAmt,p.SalpaidDays,em.DOL 
		From Emp_Monthly_Payroll p 
		inner join BpMain m on (m.Entry_Ty=p.Fh_Ent_Ty and m.Tran_Cd=p.Fh_Trn_Cd)
		inner join EmployeeMast em on (em.EmployeeCode=p.EmployeeCode) 
		Where (u_Cldt Between @sDate and @eDate)
		and Pay_Year=Year(@tDate) and Pay_Month=Month(@tDate) and p.PFEmpE<>0
	End 
	
	Select * From #PF3A Order by pMailName,Pay_Year,pay_Month
	
	--Declare @LastMonth SmallDateTime,@lMnthEmp int,@nMnthEmp int,@Empleft int
--	Select p.EmployeeCode,p.Pay_Year,p.Pay_Month,p.BasicAmt,p.PFEmpE,PFEmpR=p.PFEmpR+p.EPSAMT,p.EDLIContr,p.EDLIAdChg,p.VEPFAmt ,pPFEmpE =cast (0 as Decimal(17,2)), pPFEmpR=cast (0 as Decimal(17,2)) 
--	,pDate=MnthLastDt--,lMnthEmp =Cast(0 as int),Empleft =Cast(0 as int)
--	into #Emp_Monthly_Payroll
--	From Emp_Monthly_Payroll p where 1=2

--EXECUTE USP_REP_EMP_PF_FORM_3A'','','','04/01/2012','03/31/2013','','','','',0,0,'','','','','','','','','2012-2013',''
	Drop Table #PF3A
End
GO
