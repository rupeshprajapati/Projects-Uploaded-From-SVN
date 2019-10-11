IF EXISTS(SELECT [NAME] FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='USP_REP_Pharma_TB_PURCHASES')
BEGIN
	DROP PROCEDURE USP_REP_Pharma_TB_PURCHASES
END
GO

CREATE PROCEDURE [USP_REP_Pharma_TB_PURCHASES]
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
,@VMAINFILE='m',@VITFILE='i',@VACFILE=' '
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT

print @FCON

DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(4000)

Select 0 as srno,it_mast.it_name,i.batchno,i.qty,ac.state,ac.city,cast('' as varchar) as others
into #tbpurchases
from ptmain m
inner join ptitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)
inner join ac_mast ac on (m.ac_id=ac.ac_id)
inner join it_mast on (i.it_code=it_mast.it_code)
--inner join pretsalt_master ps on (it_mast.prSalt=ps.Salt)
inner join lcode l on (m.entry_ty=l.entry_ty)
where 1=2

SET @SQLCOMMAND='INSERT INTO #tbpurchases 
	Select 0 as srno,it_mast.it_name,i.batchno,i.qty,ac.state,ac.city
	,(case when upper(ac.st_type) in (''INTERSTATE'',''OUT OF COUNTRY'') then cast(i.qty as varchar) else '''' end)  as others
	from ptmain m
	inner join ptitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)
	inner join ac_mast ac on (m.ac_id=ac.ac_id)
	inner join it_mast on (i.it_code=it_mast.it_code)
	--inner join pretsalt_master ps on (it_mast.prSalt=ps.Salt)
	inner join lcode l on (m.entry_ty=l.entry_ty)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' and m.entry_ty=''PK'' and it_mast.prdisease=''TB'''
--and ps.schedule=''TB'''
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

select srno,batchno,it_name,count(batchno) as totbatches,sum(qty) as totqty,state,city,others from #tbpurchases 
group by srno,it_name,batchno,state,city,others
order by it_name

--EXECUTE USP_REP_Pharma_TB_PURCHASES '','','','04/01/2018','03/31/2019','','','Crocin                                            ','Paracetamol                                       ',0,0,'','','','','','','','','2018-2019',''