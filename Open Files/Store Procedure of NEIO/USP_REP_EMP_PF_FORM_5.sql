DROP PROCEDURE [USP_REP_EMP_PF_FORM_5]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI.
-- CREATE DATE: 06/12/2012
-- DESCRIPTION:	This Stroed Procedure is useful for PF Form 5 Report
-- Modification Date/By/Reason: 
-- Remark: 
-- =============================================
Create PROCEDURE    [USP_REP_EMP_PF_FORM_5]
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

	Select EmployeeCode,FullNm into #fm From Emp_Family_Details where  Relation='Husband'            /*Ramya 05/02/13*/
	insert into #fm (EmployeeCode,FullNm) Select EmployeeCode,FullNm From Emp_Family_Details 
	where  Relation='Father'
	and EmployeeCode not in (Select EmployeeCode From #Fm)

	Select em.EmployeeCode,pMailName=(Case when isnull(em.pMailName,'')='' Then em.Employeename Else em.pMailName End),mName=isnull(#fm.FullNm,''),em.PFNO,em.DOB,em.Sex,em.DOJ  
	From EmployeeMast em 
    Left join #fm on(em.EmployeeCode=#fm.EmployeeCode)
	Where (em.DOJ between @sDate and @eDate) 
	and em.EmployeeCode in (Select distinct EmployeeCode From Emp_monthly_Payroll where PFEmpE<>0 and  (MnthLastDt between @sDate and @eDate))
	Order by (Case when isnull(em.pMailName,'')='' Then em.Employeename Else em.pMailName End)
	--EXECUTE USP_REP_EMP_PF_FORM_5'','','','04/01/2012','03/31/2013','','','','',0,0,'','','','','','','','','2012-2013',''

End
GO
