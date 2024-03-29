If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_Pharma_TB_Return')
Begin
	Drop Procedure USP_REP_Pharma_TB_Return
End
GO
/****** Object:  StoredProcedure [dbo].[USP_REP_Pharma_TB_Return]    Script Date: 12/20/2018 17:26:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[USP_REP_Pharma_TB_Return]
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
Declare @FCON as NVARCHAR(max),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4),@SFLDNM VARCHAR(10)

EXECUTE  USP_REP_FILTCON 
@VTMPAC ='',@VTMPIT ='',@VSPLCOND =''
,@VSDATE=@SDATE
 ,@VEDATE=@EDATE
,@VSAC ='',@VEAC =''
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=0.00,@VEAMT=0.00
,@VSDEPT='',@VEDEPT=''
,@VSCATE ='',@VECATE =''
,@VSWARE ='',@VEWARE =''
,@VSINV_SR ='',@VEINV_SR =''
,@VMAINFILE='mvw',@VITFILE='ivw',@VACFILE=' '
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT

print @FCON

DECLARE @SQLCOMMAND NVARCHAR(max),@VCOND NVARCHAR(4000)

select cast('' as varchar(200)) as patientname,cast('' as varchar(200)) as sw,cast('' as varchar(10)) as age,cast('' as varchar(1)) as gen
,cast('' as varchar(300)) as paddress,cast('' as varchar(10)) as pin,cast('' as varchar(15)) as resmobile,cast('' as varchar(50)) as pan_aadhar
,cast('' as smalldatetime) as dtdiagno,cast('' as smalldatetime) as dttreat,cast('' as varchar(200)) as docname,cast('' as varchar(300)) as daddress
,i.batchno,i.qty,m.inv_no,it_mast.it_name as drugname
,cast('' as varchar(100)) as HpNm   --added by Prajakta B. on 18-12-2018 for Bug 32062
,cast('' as varchar(50)) as drprescno,cast('' as varchar(100)) as drname,cast('' as varchar(50)) as patientnm
into #tb_1
from stmain m
inner join stitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)
inner join ac_mast ac on (m.ac_id=ac.ac_id)
inner join it_mast on (i.it_code=it_mast.it_code)
inner join pretsalt_master ps on (it_mast.prSalt=ps.Salt)
inner join lcode l on (m.entry_ty=l.entry_ty)
where 1=2

select isnull(pm.drprescno,'') as drprescno,isnull(pa.name,'') as patientname,isnull(pa.sw,'') as sw,isnull(cast(pa.age as varchar),'') as age
,isnull(pa.gen,'') as gen,(isnull(pa.Add1,'')+' '+isnull(pa.Add2,'')+' '+isnull(pa.Add3,'')) as paddress,isnull(pa.pin,'') as pin
,isnull(pa.resmobile,'') as resmobile,isnull(pa.panno,'')+char(13)+isnull(pa.aadharno,'') as pan_aadhar,isnull(pa.dtdiagno,'') as dtdiagno
,isnull(pa.dttreat,'') as dttreat,isnull(da.name,'') as drname,(isnull(da.Add1,'')+' '+isnull(da.Add2,'')+' '+isnull(da.Add3,'')) as daddress
,isnull(pd.gname,'') as drugname,pd.*
,ISNULL(pa.HpNm,'') as hpnm   --added by Prajakta B. on 18-12-2018 for Bug 32062
into #a
from pRetPrescMast pm
inner join pRetPrescDet pd on (pm.PrescNo=pd.PrescNo)
inner join pRetPatientMast pa on (pm.pentcode=pa.PentCode)
inner join pRetDrMast da on (pm.drcode=da.DrCode)
inner join IT_MAST im on(pd.GName=im.it_name)   --added by Prajakta B. on 18-12-2018 for Bug 32062
where im.prDisease='TB'   --added by Prajakta B. on 18-12-2018 for Bug 32062

SET @SQLCOMMAND='INSERT INTO #tb_1
Select distinct
cast('''' as varchar(200)) as patientname,cast('''' as varchar(100)) as sw,cast('''' as varchar(10)) as age,cast('''' as varchar(1)) as gen
,cast('''' as varchar(300)) as paddress,cast('''' as varchar(10)) as pin,cast('''' as varchar(15)) as resmobile,cast('''' as varchar(50)) as pan_aadhar
,convert(datetime,'''',103) as dtdiagno,convert(datetime,'''',103) as dttreat,cast('''' as varchar(200)) as docname
,cast('''' as varchar(300)) as daddress,ivw.batchno,ivw.qty,ivw.inv_no,it_mast.it_name as drugname,cast('''' as varchar(100)) as hpnm
,dcm.drprescno,dcm.drname,dcm.patientnm
FROM STKL_VW_ITEM IVW (NOLOCK)
INNER JOIN AC_MAST (NOLOCK) ON (IVW.AC_ID = AC_MAST.AC_ID)
INNER JOIN IT_MAST (NOLOCK) ON (IVW.IT_CODE = IT_MAST.IT_CODE)
INNER JOIN STKL_VW_MAIN MVW (NOLOCK) ON (IVW.TRAN_CD = MVW.TRAN_CD AND IVW.ENTRY_TY = MVW.ENTRY_TY)
INNER JOIN LCODE (NOLOCK) ON (IVW.ENTRY_TY = LCODE.ENTRY_TY AND LCODE.INV_STK IN (''+'',''-''))
left join pretsalt_master ps on (it_mast.prSalt=ps.Salt)
left outer join dcmain dcm on (dcm.entry_ty=mvw.entry_ty and dcm.tran_cd=mvw.tran_cd)
left outer JOIN STMAINadd stm (NOLOCK) ON (stm.TRAN_CD = MVW.TRAN_CD AND stm.ENTRY_TY = MVW.ENTRY_TY)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' and mvw.entry_ty in (''SK'' ,''HS'') and it_mast.prDisease=''TB'' and ivw.dc_no='''''
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

SET @SQLCOMMAND='Update b set b.patientname=a.patientname,b.sw=a.sw,b.age=a.age,b.gen=a.gen,b.paddress=a.paddress,b.pin=a.pin,b.resmobile=a.resmobile
,b.pan_aadhar=a.pan_aadhar,b.dtdiagno=a.dtdiagno,b.dttreat=a.dttreat,b.docname=a.drname,b.daddress=a.daddress,b.hpnm=a.hpnm
from #a a inner join #tb_1 b on (rtrim(a.drprescno)+rtrim(a.drname)+rtrim(a.patientname) = rtrim(b.drprescno)+rtrim(b.drname)+rtrim(b.patientnm))'
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Select * from #tb_1

drop table #a
drop table #tb_1