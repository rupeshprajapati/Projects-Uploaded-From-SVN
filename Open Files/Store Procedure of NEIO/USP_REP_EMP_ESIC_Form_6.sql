DROP PROCEDURE [USP_REP_EMP_ESIC_Form_6]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI.
-- CREATE DATE: 11/12/2012
-- DESCRIPTION:	This Stroed Procedure is useful for ESIC Form 6 Report
-- Modification Date/By/Reason: 
-- Remark: 
-- =============================================
Create PROCEDURE    [USP_REP_EMP_ESIC_Form_6]
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
	
	Declare @m1 int,@y1 int,@m2 int,@y2 int,@m3 int,@y3 int,@m4 int,@y4 int,@m5 int,@y5 int,@m6 int,@y6 int
	Select @m1=month(DateAdd(mm,0,@sDate)),@m2=month(DateAdd(mm,1,@sDate)),@m3=month(DateAdd(mm,2,@sDate)),@m4=month(DateAdd(mm,3,@sDate)),@m5=month(DateAdd(mm,4,@sDate)),@m6=month(DateAdd(mm,5,@sDate))
	Select @y1=Year(DateAdd(mm,0,@sDate)),@y2=Year(DateAdd(mm,1,@sDate)),@y3=Year(DateAdd(mm,2,@sDate)),@y4=Year(DateAdd(mm,3,@sDate)),@y5=Year(DateAdd(mm,4,@sDate)),@y6=Year(DateAdd(mm,5,@sDate))
	--Select @m1,@Y1,@m2,@Y2,@m3,@Y3,@m4,@Y4,@m5,@Y5,@m6,@Y6
	Select p.EmployeeCode,p.GrossPayment
	,m1Days=p.SalPaidDays,m1GroAmt=p.Grosspayment,m1AMt=p.ESICEmpE,m1AMtr=p.ESICEmpR
	,m2Days=p.SalPaidDays,m2GroAmt=p.Grosspayment,m2AMt=p.ESICEmpE,m2AMtr=p.ESICEmpR
	,m3Days=p.SalPaidDays,m3GroAmt=p.Grosspayment,m3AMt=p.ESICEmpE,m3AMtr=p.ESICEmpR
	,m4Days=p.SalPaidDays,m4GroAmt=p.Grosspayment,m4AMt=p.ESICEmpE,m4AMtr=p.ESICEmpR
	,m5Days=p.SalPaidDays,m5GroAmt=p.Grosspayment,m5AMt=p.ESICEmpE,m5AMtr=p.ESICEmpR
	,m6Days=p.SalPaidDays,m6GroAmt=p.Grosspayment,m6AMt=p.ESICEmpE,m6AMtr=p.ESICEmpR
	,ChalDt1=cast('' as smallDateTime)
	,ChalDt2=cast('' as smallDateTime)
	,ChalDt3=cast('' as smallDateTime)	
	,ChalDt4=cast('' as smallDateTime)
	,ChalDt5=cast('' as smallDateTime)
	,ChalDt6=cast('' as smallDateTime)
	into #ESIC6 
	From Emp_Monthly_Payroll p Where 1=2



	Insert into #ESIC6
	Select p.EmployeeCode,sum(p.GrossPayment)
	,m1Days=sum(Case When Pay_Year=@y1 and Pay_Month=@m1 Then p.SalPaidDays Else 0 End),m1GroAmt=sum(Case When Pay_Year=@y1 and Pay_Month=@m1 Then p.Grosspayment Else 0 End),m1AMt=sum(Case When Pay_Year=@y1 and Pay_Month=@m1 Then p.ESICEmpE Else 0 End),m1AMtR=sum(Case When Pay_Year=@y1 and Pay_Month=@m1 Then p.ESICEmpR Else 0 End)
	,m2Days=sum(Case When Pay_Year=@y2 and Pay_Month=@m2 Then p.SalPaidDays Else 0 End),m2GroAmt=sum(Case When Pay_Year=@y2 and Pay_Month=@m2 Then p.Grosspayment Else 0 End),m2AMt=sum(Case When Pay_Year=@y2 and Pay_Month=@m2 Then p.ESICEmpE Else 0 End),m2AMtR=sum(Case When Pay_Year=@y2 and Pay_Month=@m2 Then p.ESICEmpR Else 0 End)
	,m3Days=sum(Case When Pay_Year=@y3 and Pay_Month=@m3 Then p.SalPaidDays Else 0 End),m3GroAmt=sum(Case When Pay_Year=@y3 and Pay_Month=@m3 Then p.Grosspayment Else 0 End),m3AMt=sum(Case When Pay_Year=@y3 and Pay_Month=@m3 Then p.ESICEmpE Else 0 End),m3AMtR=sum(Case When Pay_Year=@y3 and Pay_Month=@m3 Then p.ESICEmpR Else 0 End)
	,m4Days=sum(Case When Pay_Year=@y4 and Pay_Month=@m4 Then p.SalPaidDays Else 0 End),m4GroAmt=sum(Case When Pay_Year=@y4 and Pay_Month=@m4 Then p.Grosspayment Else 0 End),m4AMt=sum(Case When Pay_Year=@y4 and Pay_Month=@m4 Then p.ESICEmpE Else 0 End),m4AMtR=sum(Case When Pay_Year=@y4 and Pay_Month=@m4 Then p.ESICEmpR Else 0 End)
	,m5Days=sum(Case When Pay_Year=@y5 and Pay_Month=@m5 Then p.SalPaidDays Else 0 End),m5GroAmt=sum(Case When Pay_Year=@y5 and Pay_Month=@m5 Then p.Grosspayment Else 0 End),m5AMt=sum(Case When Pay_Year=@y5 and Pay_Month=@m5 Then p.ESICEmpE Else 0 End),m5AMtR=sum(Case When Pay_Year=@y5 and Pay_Month=@m5 Then p.ESICEmpR Else 0 End)
	,m6Days=sum(Case When Pay_Year=@y6 and Pay_Month=@m6 Then p.SalPaidDays Else 0 End),m6GroAmt=sum(Case When Pay_Year=@y6 and Pay_Month=@m6 Then p.Grosspayment Else 0 End),m6AMt=sum(Case When Pay_Year=@y6 and Pay_Month=@m6 Then p.ESICEmpE Else 0 End),m6AMtR=sum(Case When Pay_Year=@y6 and Pay_Month=@m6 Then p.ESICEmpR Else 0 End)
	,ChalDt1=(Case When Pay_Year=@y1 and Pay_Month=@m1 Then m.u_ChalDt Else '' End)
	,ChalDt2=(Case When Pay_Year=@y2 and Pay_Month=@m2 Then m.u_ChalDt Else '' End)
	,ChalDt3=(Case When Pay_Year=@y3 and Pay_Month=@m3 Then m.u_ChalDt Else '' End)
	,ChalDt4=(Case When Pay_Year=@y4 and Pay_Month=@m4 Then m.u_ChalDt Else '' End)
	,ChalDt5=(Case When Pay_Year=@y5 and Pay_Month=@m5 Then m.u_ChalDt Else '' End)
	,ChalDt6=(Case When Pay_Year=@y6 and Pay_Month=@m6 Then m.u_ChalDt Else '' End)
	From Emp_Monthly_Payroll p
	Left Join BpMain m on (p.EH_Ent_Ty=m.Entry_TY and p.EH_Trn_Cd=m.Tran_cd)
	Where p.ESICEmpE<>0 and (MnthLastDt between @sDate and @eDate)
	Group By p.EmployeeCode,u_ChalDt,Pay_Year,Pay_Month



	Select Part=1,em.EmployeeCode,lm.ESIC_Code
	,pMailName=(Case when isnull(em.pMailName,'')='' Then em.EmployeeName Else em.pMailName End)
	,Dispensary=em.ESICDsp,em.Designation,em.Department,Shift='',em.ESICNo,p.GrossPayment
	,DOJ=(case when (em.DOJ between @sDate and @eDate) then 'DOJ-'+cast(day(em.DOJ) as varchar)+'/'+cast(Month(em.DOJ) as varchar)+'/'++cast(Year(em.DOJ) as varchar) Else ( (case when (em.DOL between @sDate and @eDate) then 'DOL-'+cast(day(em.DOL) as varchar)+'/'+cast(month(em.DOL) as varchar)+'/'++cast(Year(em.DOL) as varchar) Else '' End) ) End)
	,p.m1Days,p.m1GroAmt,p.m1Amt,p.m1AmtR
	,p.m2Days,p.m2GroAmt,p.m2Amt,p.m2AmtR
	,p.m3Days,p.m3GroAmt,p.m3Amt,p.m3AmtR
	,p.m4Days,p.m4GroAmt,p.m4Amt,p.m4AmtR
	,p.m5Days,p.m5GroAmt,p.m5Amt,p.m5AmtR
	,p.m6Days,p.m6GroAmt,p.m6Amt,p.m6AmtR
	,m1=DateName( month , DateAdd( month , cast(@m1 as int), 0 )-1  )+'-'+cast(@y1 as varchar(4))
	,m2=DateName( month , DateAdd( month , cast(@m2 as int), 0 )-1  )+'-'+cast(@y2 as varchar(4))
	,m3=DateName( month , DateAdd( month , cast(@m3 as int), 0 )-1  )+'-'+cast(@y3 as varchar(4))
	,m4=DateName( month , DateAdd( month , cast(@m4 as int), 0 )-1  )+'-'+cast(@y4 as varchar(4))
	,m5=DateName( month , DateAdd( month , cast(@m5 as int), 0 )-1  )+'-'+cast(@y5 as varchar(4))
	,m6=DateName( month , DateAdd( month , cast(@m6 as int), 0 )-1  )+'-'+cast(@y6 as varchar(4))
	,tDays=cast(0 as Decimal(17,2))
	,tGroAmt=cast(0 as Decimal(17,2))
	,tAMt=cast(0 as Decimal(17,2))
	,AvgSal=cast(0 as Decimal(17,2))
--	,ChalDt1=(Select Top 1 u_ChalDt From BpMain Where month(u_Cldt)=@m1 and Year(u_Cldt)=@y1 and Entry_Ty='EH' and ESICEmpE+ESICEmpR<>0)
--	,ChalDt2=(Select Top 1 u_ChalDt From BpMain Where month(u_Cldt)=@m2 and Year(u_Cldt)=@y2 and Entry_Ty='EH' and ESICEmpE+ESICEmpR<>0)
--	,ChalDt3=(Select Top 1 u_ChalDt From BpMain Where month(u_Cldt)=@m3 and Year(u_Cldt)=@y3 and Entry_Ty='EH' and ESICEmpE+ESICEmpR<>0)
--	,ChalDt4=(Select Top 1 u_ChalDt From BpMain Where month(u_Cldt)=@m4 and Year(u_Cldt)=@y4 and Entry_Ty='EH' and ESICEmpE+ESICEmpR<>0)
--	,ChalDt5=(Select Top 1 u_ChalDt From BpMain Where month(u_Cldt)=@m5 and Year(u_Cldt)=@y5 and Entry_Ty='EH' and ESICEmpE+ESICEmpR<>0)
--	,ChalDt6=(Select Top 1 u_ChalDt From BpMain Where month(u_Cldt)=@m6 and Year(u_Cldt)=@y6 and Entry_Ty='EH' and ESICEmpE+ESICEmpR<>0)
	,ChalDt1,ChalDt2,ChalDt3,ChalDt4,ChalDt5,ChalDt6
	into #ESIC6_1
	From #ESIC6 p 
	inner join EmployeeMast em on (em.EmployeeCode=p.EmployeeCode)
    Left Join loc_master lm on (em.loc_code=lm.loc_code)  /*Ramya for Esic_Code*/ 
    
	
    Declare @count int                        /*Ramya 25/03/13*/
    select @count=count(*) from #ESIC6_1
	if(@count=0)
	begin
	insert into #ESIC6_1 values(1,'','','','','','','','',0,'',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'','','','','','',0,0,0,0, '','','','','','') /*Ramya Bug-7617*/
--select 'a',* from #ESIC6_1
	End                                      /*Ramya 25/03/13*/

	Insert into #ESIC6_1
	Select Part=2,EmployeeCode,ESIC_Code
	,pMailName
	,Dispensary='',Designation='',Department='',Shift='',ESICNo='',GrossPayment=0
	,DOJ=''
	,m1Days=0,m1GroAmt=0,m1AMt=0,m1AmtR=0
	,m2Days,m2GroAmt,m2AMt,m2AmtR
	,m3Days,m3GroAmt,m3AMt,m3AmtR
	,m4Days,m4GroAmt,m4AMt,m4AmtR
	,m5Days=0,m5GroAmt=0,m5AMt=0,m5AmtR=0
	,m6Days=0,m6GroAmt=0,m6AMt=0,m6AmtR=0
	,m1=''
	,m2
	,m3
	,m4
	,m5=''
	,m6=''
	,tDays=0
	,tGroAmt=0
	,tAMt=0
	,AvgSal=0
	--,ChalDt1='',ChalDt2='',ChalDt3='',ChalDt4='',ChalDt5='',ChalDt6=''
,ChalDt1,ChalDt2,ChalDt3,ChalDt4,ChalDt5,ChalDt6
	From #ESIC6_1 p 


   
	

	Insert into #ESIC6_1
	Select Part=3,EmployeeCode,ESIC_Code
	,pMailName
	,Dispensary='',Designation='',Department='',Shift='',ESICNo='',GrossPayment=0
	,DOJ=''
	,m1Days=0,m1GroAmt=0,m1AMt=0,m1AmtR=0
	,m2Days=0,m2GroAmt=0,m2AMt=0,m2AmtR=0
	,m3Days=0,m3GroAmt=0,m3AMt=0,m3AmtR=0
	,m4Days=0,m4GroAmt=0,m4AMt=0,m4AmtR=0
	,m5Days,m5GroAmt,m5AMt,m5AmtR
	,m6Days,m6GroAmt,m6AMt,m6AmtR
	,m1=''
	,m2=''
	,m3=''
	,m4=''
	,m5
	,m6
	,tDays=m1Days+m2Days+m3Days+m4Days+m5Days++m6Days
	,tGroAmt=m1GroAmt+m2GroAmt+m3GroAmt+m4GroAmt+m5GroAmt+m6GroAmt
	,tAMt=m1AMt+m2AMt+m3AMt+m4AMt+m5AMt+m6AMt
	,AvgSal=(m1GroAmt+m2GroAmt+m3GroAmt+m4GroAmt+m5GroAmt+m6GroAmt)/(case when  m1Days+m2Days+m3Days+m4Days+m5Days++m6Days =0 then 1 else m1Days+m2Days+m3Days+m4Days+m5Days+m6Days end)
	--,ChalDt1='',ChalDt2='',ChalDt3='',ChalDt4='',ChalDt5='',ChalDt6=''
,ChalDt1,ChalDt2,ChalDt3,ChalDt4,ChalDt5,ChalDt6
	From #ESIC6_1 p  Where Part=1
	
	

	Select  * From #ESIC6_1 order By ESIC_Code,Part,pMailName
----    Select  lm.ESIC_Code,es.* From #ESIC6_1 es
----	inner join EmployeeMast em on (em.EmployeeCode=es.EmployeeCode) /*Ramya for Esic_Code*/
----	Left Join loc_master lm on (em.loc_code=lm.loc_code)  /*Ramya for Esic_Code*/ 
----    order By lm.ESIC_Code,es.Part,es.pMailName  /*Ramya 23/02/13*/



	--EXECUTE USP_REP_EMP_ESIC_FORM_6'','','','04/01/2012','03/31/2013','','','','',0,0,'','','','','','','','','2012-2013',''

	Drop Table #ESIC6
End
GO
