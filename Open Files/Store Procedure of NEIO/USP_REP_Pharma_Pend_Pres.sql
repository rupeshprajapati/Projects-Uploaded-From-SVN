IF EXISTS(SELECT * from sysobjects where [name]='USP_REP_Pharma_Pend_Pres' and xtype='P')
BEGIN
	Drop procedure USP_REP_Pharma_Pend_Pres
END
GO
Create procedure USP_REP_Pharma_Pend_Pres
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),
@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= null

AS
SET QUOTED_IDENTIFIER OFF
Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4),@SFLDNM VARCHAR(10)

EXECUTE  USP_REP_FILTCON 
@VTMPAC ='',@VTMPIT ='',@VSPLCOND =''
,@VSDATE=@SDATE
 ,@VEDATE=''
,@VSAC ='',@VEAC =''
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=0.00,@VEAMT=0.00
,@VSDEPT='',@VEDEPT=''
,@VSCATE ='',@VECATE =''
,@VSWARE ='',@VEWARE =''
,@VSINV_SR ='',@VEINV_SR =''
,@VMAINFILE='m',@VITFILE='i',@VACFILE=' '
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT

print @fcon 

select pm.prescno,pm.prescdate,pm.fday,presduedate=DATEADD(day, pm.fday, pm.prescdate),pm.drprescno,pm.drcode,da.name as drname
,pm.pentcode,pa.name as patientname,pm.drprescdate,pa.resmobile,cast('' as varchar(20)) as lastbillno,cast('' as smalldatetime) as lastbilldt
,lastbillvalue=cast(0.00 as numeric(12,2))
into #a
from pRetPrescMast pm
inner join pRetPrescDet pd on (pm.PrescNo=pd.PrescNo)
inner join pRetPatientMast pa on (pm.pentcode=pa.PentCode)
inner join pRetDrMast da on (pm.drcode=da.DrCode)

select a.prescno,a.prescdate,a.DrPrescNo,a.drname,a.patientname,a.resmobile,a.fday
,lastbillno = max(m.inv_no),lastbilldt = max(m.date),lastbillvalue=max(m.net_amt)
into #b
from #a a
left outer join dcmain m on (a.drprescno+a.drname+a.patientname = m.drprescno+m.drname+m.patientnm)
where entry_ty='HS'
group by a.DrPrescNo,a.drname,a.patientname,a.prescno,a.prescdate,a.resmobile,a.fday

select a.prescno,a.prescdate,a.DrPrescNo,a.drname,a.patientname,a.resmobile,a.fday,a.lastbillno,a.lastbilldt,a.lastbillvalue
into #c
from #a a
where (a.drprescno+a.drname+a.patientname) not in (select m.drprescno+m.drname+m.patientnm from dcmain m where entry_ty='HS' and m.date<=@sdate)
and a.prescdate <= @sdate

Select * From 
	(Select * from #c
	Union
	Select * from #b a where dateadd(day,fday,lastbilldt) <= @sdate
	) pendpres order by prescno

drop table #a
drop table #b
drop table #c
--go
--EXECUTE USP_REP_PHARMA_PEND_PRES'','','','11/21/2018','','','','','',0,0,'','','','','','','','','2018-2019',''