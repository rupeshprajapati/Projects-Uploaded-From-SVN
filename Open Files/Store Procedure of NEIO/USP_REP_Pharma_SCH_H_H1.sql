IF EXISTS(SELECT [NAME] FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='USP_REP_Pharma_SCH_H_H1')
BEGIN
	DROP PROCEDURE [USP_REP_Pharma_SCH_H_H1]
END
GO

CREATE PROCEDURE [USP_REP_Pharma_SCH_H_H1]
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
 ,@VEDATE=@EDATE
,@VSAC ='',@VEAC =''
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=0.00,@VEAMT=0.00
,@VSDEPT='',@VEDEPT=''
,@VSCATE ='',@VECATE =''
,@VSWARE ='',@VEWARE =''
,@VSINV_SR ='',@VEINV_SR =''
,@VMAINFILE='MVW',@VITFILE='IVW',@VACFILE=' '
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT

print @FCON

DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(4000)

select l.code_nm as tran_name,ps.schedule,m.inv_no,m.date,ac.ac_name as partyname,cast('' as varchar(200)) as paddress,i.item as medicinename
,i.gpunit,i.qty, i.batchno,i.mfgdt,i.expdt
,cast('' as varchar(200)) as prManufacturer
into #SCH_1	
from ptmain m
inner join ptitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)
inner join ac_mast ac on (m.ac_id=ac.ac_id)
inner join it_mast on (i.it_code=it_mast.it_code)
inner join pretsalt_master ps on (it_mast.prSalt=ps.Salt)
inner join lcode l on (m.entry_ty=l.entry_ty)
where 1=2

SET @SQLCOMMAND = ''
SET @SQLCOMMAND = 'INSERT INTO #SCH_1 SELECT rtrim(lcode.code_nm) as tran_name,ps.schedule,mvw.inv_no,mvw.date,ac_mast.ac_name as partyname
,rtrim(ISNULL(rtrim(ac_mast.add1)+'' ''+rtrim(ac_mast.add2)
+'' ''+rtrim(ac_mast.add3)+'' ''+rtrim(ac_mast.city)+'' ''+rtrim(ac_mast.country),'''')) as paddress,it_mast.it_name as medicinename
,ivw.gpunit,ivw.qty,ivw.batchno,ivw.mfgdt,ivw.expdt,it_mast.prManufacturer
FROM STKL_VW_ITEM IVW (NOLOCK)
INNER JOIN AC_MAST (NOLOCK) ON (IVW.AC_ID = AC_MAST.AC_ID)
INNER JOIN IT_MAST (NOLOCK) ON (IVW.IT_CODE = IT_MAST.IT_CODE)
INNER JOIN STKL_VW_MAIN MVW (NOLOCK) ON (IVW.TRAN_CD = MVW.TRAN_CD AND IVW.ENTRY_TY = MVW.ENTRY_TY)
INNER JOIN LCODE (NOLOCK) ON (IVW.ENTRY_TY = LCODE.ENTRY_TY AND LCODE.INV_STK IN (''+'',''-''))
inner join pretsalt_master ps on (it_mast.prSalt=ps.Salt)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' AND it_mast.NONSTK=''Stockable'' and MVW.[RULE] NOT IN (''ANNEXURE III'',''ANNEXURE V'') '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' and IVW.DC_NO='' '' and ivw.entry_ty in (''PK'',''SK'',''HS'') and ps.schedule in (''H'',''H1'',''Narcotic'')'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' AND QTY <> 0 ORDER BY IT_MAST.IT_NAME,MVW.DATE'
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

SELECT SDATE=@SDATE,EDATE=@EDATE,* FROM #SCH_1 
ORDER BY SCHEDULE,TRAN_NAME
