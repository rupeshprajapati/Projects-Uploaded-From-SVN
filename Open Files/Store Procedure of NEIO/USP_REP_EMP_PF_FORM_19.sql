DROP PROCEDURE [USP_REP_EMP_PF_FORM_19]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ramya.
-- Create date: 02/02/2013
-- Description:	This Stored Procedure is useful for PF form 19.
-- =============================================
CREATE PROCEDURE    [USP_REP_EMP_PF_FORM_19]
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

Set @tDate=@sDate

Select EmployeeCode,FullNm into #fm From Emp_Family_Details where  Relation='Husband'
insert into #fm (EmployeeCode,FullNm) Select EmployeeCode,FullNm From Emp_Family_Details 
where  Relation='Father'
and EmployeeCode not in (Select EmployeeCode From #Fm)




Select p.pay_month,em.EmployeeCode,pMailName=(Case when isnull(em.pMailName,'')='' Then em.EmployeeName Else em.pMailName End),em.DOB,em.PFNO,em.DOL,em.CAdd1,em.CAdd2,em.CAdd3,em.CCity,em.CState,em.CCountry,em.CPin
,lc.pf_code,em.DOLReason,Dependon=#fm.FullNm,em.DOJ,em.DOL
,em.BankAccNo
,em.BankName
,em.Branch
,cast(0 as decimal(17,2)) as FP
,MarEPFAmtE=(case when p.pay_month=3 and p.pay_year=cast(year(@sdate)+1 as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,AprEPFAmtE=(case when p.pay_month=4 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,MayEPFAmtE=(case when p.pay_month=5 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,JunEPFAmtE=(case when p.pay_month=6 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,JulEPFAmtE=(case when p.pay_month=7 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,AugEPFAmtE=(case when p.pay_month=8 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,SepEPFAmtE=(case when p.pay_month=9 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,OctEPFAmtE=(case when p.pay_month=10 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,NovEPFAmtE=(case when p.pay_month=11 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,DecEPFAmtE=(case when p.pay_month=12 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,JanEPFAmtE=(case when p.pay_month=1 and p.pay_year=cast(year(@sdate)+1 as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)
,FebEPFAmtE=(case when p.pay_month=2 and p.pay_year=cast(year(@sdate)+1 as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0) else cast(0 as decimal(17,2)) end)

,MarEPFAmtR=(case when p.pay_month=3 and p.pay_year=cast(year(@sdate)+1 as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2))end)
,AprEPFAmtR=(case when p.pay_month=4 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,MayEPFAmtR=(case when p.pay_month=5 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,JunEPFAmtR=(case when p.pay_month=6 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,JulEPFAmtR=(case when p.pay_month=7 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,AugEPFAmtR=(case when p.pay_month=8 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,SepEPFAmtR=(case when p.pay_month=9 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,OctEPFAmtR=(case when p.pay_month=10 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,NovEPFAmtR=(case when p.pay_month=11 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,DecEPFAmtR=(case when p.pay_month=12 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,JanEPFAmtR=(case when p.pay_month=1 and p.pay_year=cast(year(@sdate)+1 as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,FebEPFAmtR=(case when p.pay_month=2 and p.pay_year=cast(year(@sdate)+1 as varchar) then isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)

,MarTotPFAmt=(case when p.pay_month=3 and p.pay_year=cast(year(@sdate)+1 as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,AprTotPFAmt=(case when p.pay_month=4 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,MayTotPFAmt=(case when p.pay_month=5 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,JunTotPFAmt=(case when p.pay_month=6 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,JulTotPFAmt=(case when p.pay_month=7 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,AugTotPFAmt=(case when p.pay_month=8 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,SepTotPFAmt=(case when p.pay_month=9 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,OctTotPFAmt=(case when p.pay_month=10 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,NovTotPFAmt=(case when p.pay_month=11 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,DecTotPFAmt=(case when p.pay_month=12 and p.pay_year=cast(year(@sdate) as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,JanTotPFAmt=(case when p.pay_month=1 and p.pay_year=cast(year(@sdate)+1 as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)
,FebTotPFAmt=(case when p.pay_month=2 and p.pay_year=cast(year(@sdate)+1 as varchar) then isnull(p.PFEmpE,0)+isnull(p.VEPFAmt,0)+isnull(p.PFEmpR,0)+isnull(p.EPSAmt,0) else cast(0 as decimal(17,2)) end)




From Emp_Monthly_Payroll p inner join EmployeeMast em on (em.EmployeeCode=p.EmployeeCode)
inner Join BpMain bp on (bp.entry_ty=p.FH_Ent_Ty and bp.entry_ty='FH' and bp.tran_cd=p.FH_Trn_Cd  ) 
Left join #fm on(em.EmployeeCode=#fm.EmployeeCode)
Left join Loc_Master lc on(em.loc_code=lc.loc_code)
order by lc.pf_code,em.employeecode
 
--	Where (p.MnthLastDt BetWeen @sDate and @eDate) and p.PFEmpE+p.VEPFAmt<>0
--
--select * from emp_monthly_payroll
--	Group By em.EmployeeCode,(Case when isnull(em.pMailName,'')='' Then em.EmployeeName Else em.pMailName End),em.PFNO

--select * from Emp_Family_Details


End
GO
