IF EXISTS(SELECT [NAME] FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='USP_REP_STK_LST_BATCH_AGEINGWISE_NF')
BEGIN
	DROP PROCEDURE USP_REP_STK_LST_BATCH_AGEINGWISE_NF
END
GO
-- =============================================
-- Author:		Birendra Prasad
-- Create date: 14/08/2012
-- Description:	This is useful for Itemwise Batchwise Stock List(Agingwise) for item type exclude finish and semi-finish.
-- Modify date: 
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
CREATE PROCEDURE [USP_REP_STK_LST_BATCH_AGEINGWISE_NF]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
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
Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL
,@VEDATE=@SDATE							--Changed by Shrikant S. on 19/09/2018 for Installer ENT 2.0.0
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='STKL_VW_MAIN',@VITFILE='STKL_VW_ITEM',@VACFILE=' '
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT


DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(4000)
declare @days1 int,@days2 int,@days3 int,@days4 int
DECLARE @COLCAP1 AS VARCHAR(50),@COLCAP2 AS VARCHAR(50),@COLCAP3 AS VARCHAR(50),@COLCAP4 AS VARCHAR(50),@COLCAP5 AS VARCHAR(50)

SET @DAYS1=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS1
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
--print @EXPARA
SET @DAYS2=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS2
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
--print @EXPARA
SET @DAYS3=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS3
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
--print @EXPARA
SET @DAYS4=@EXPARA
--print @DAYS4

SELECT  STKL_VW_ITEM.ENTRY_TY,STKL_VW_ITEM.tran_cd,BEH='  ',STKL_VW_ITEM.DATE,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.ITGRID,IT_MAST.[GROUP],IT_MAST.IT_NAME,IT_MAST.CHAPNO,IT_MAST.TYPE,IT_MAST.RATEUNIT,STKL_VW_ITEM.BATCHNO,STKL_VW_ITEM.MFGDT,STKL_VW_ITEM.EXPDT 
INTO #TITEM FROM STKL_VW_ITEM 
INNER JOIN STKL_VW_MAIN  ON (STKL_VW_ITEM.TRAN_CD=STKL_VW_MAIN.TRAN_CD )
INNER JOIN IT_MAST  ON (IT_MAST.IT_CODE=STKL_VW_ITEM.IT_CODE)
INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=STKL_VW_MAIN.AC_ID)
INNER JOIN LCODE  ON (STKL_VW_ITEM.ENTRY_TY=LCODE.ENTRY_TY)
WHERE 1=2

--Added by Shrikant S. on 19/09/2018 for Installer ENT 2.0.0		--Start
SELECT  STKL_VW_ITEM.ENTRY_TY,STKL_VW_ITEM.tran_cd,BEH='  ',STKL_VW_ITEM.DATE,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.ITGRID,IT_MAST.[GROUP],IT_MAST.IT_NAME,IT_MAST.CHAPNO,IT_MAST.TYPE,IT_MAST.RATEUNIT,STKL_VW_ITEM.BATCHNO,STKL_VW_ITEM.MFGDT,STKL_VW_ITEM.EXPDT 
INTO #TITEM2 FROM STKL_VW_ITEM 
INNER JOIN STKL_VW_MAIN  ON (STKL_VW_ITEM.TRAN_CD=STKL_VW_MAIN.TRAN_CD )
INNER JOIN IT_MAST  ON (IT_MAST.IT_CODE=STKL_VW_ITEM.IT_CODE)
INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=STKL_VW_MAIN.AC_ID)
INNER JOIN LCODE  ON (STKL_VW_ITEM.ENTRY_TY=LCODE.ENTRY_TY)
WHERE 1=2
--Added by Shrikant S. on 19/09/2018 for Installer ENT 2.0.0		--End

SET @SQLCOMMAND='INSERT INTO  #TITEM SELECT  STKL_VW_ITEM.ENTRY_TY,STKL_VW_ITEM.tran_cd,BEH=(CASE WHEN LCODE.EXT_VOU=1 THEN LCODE.BCODE_NM ELSE LCODE.ENTRY_TY END),STKL_VW_ITEM.DATE,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.ITGRID,IT_MAST.[GROUP],IT_MAST.IT_NAME,IT_MAST.CHAPNO,IT_MAST.TYPE,IT_MAST.RATEUNIT'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',BATCHNO=case when it_mast.type in (''Raw Material'',''Machinery/Stores'',''Packing Material'')then STKL_VW_ITEM.supbatchno else STKL_VW_ITEM.BATCHNO end,
		MFGDT=case when it_mast.type in (''Raw Material'',''Machinery/Stores'',''Packing Material'')then STKL_VW_ITEM.supMFGDT else STKL_VW_ITEM.MFGDT end
	,EXPDT=case when it_mast.type in (''Raw Material'',''Machinery/Stores'',''Packing Material'')then STKL_VW_ITEM.supEXPDT else STKL_VW_ITEM.EXPDT end'
--Birendra:End:
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  FROM STKL_VW_ITEM '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN STKL_VW_MAIN  ON (STKL_VW_ITEM.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND STKL_VW_ITEM.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN IT_MAST  ON (IT_MAST.IT_CODE=STKL_VW_ITEM.IT_CODE)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=STKL_VW_MAIN.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN LCODE  ON (STKL_VW_ITEM.ENTRY_TY=LCODE.ENTRY_TY)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND STKL_VW_ITEM.BATCHNO<>'+CHAR(39)+SPACE(1)+CHAR(39)+' AND STKL_VW_ITEM.DC_NO=SPACE(1)'
--Birendra :Start:
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND (STKL_VW_ITEM.BATCHNO<>'+CHAR(39)+SPACE(1)+CHAR(39)+' or STKL_VW_ITEM.SupBATCHNO<>'+CHAR(39)+SPACE(1)+CHAR(39)+') AND STKL_VW_ITEM.DC_NO=SPACE(1)'+'AND IT_MAST.[TYPE] NOT LIKE '+CHAR(39)+'%FINISHED%'+CHAR(39)
--Birendra :Start:

--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' AND IT_MAST.[TYPE] LIKE '+CHAR(39)+'%FINISHED%'+CHAR(39)+' AND STKL_VW_ITEM.ENTRY_TY NOT IN('+CHAR(39)+'ST'+CHAR(39)+','+CHAR(39)+'DC'+CHAR(39)+') '
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

--SET @SQLCOMMAND='INSERT INTO  #TITEM SELECT  STKL_VW_ITEM.ENTRY_TY,STKL_VW_ITEM.tran_cd,BEH=(CASE WHEN LCODE.EXT_VOU=1 THEN LCODE.BCODE_NM ELSE LCODE.ENTRY_TY END),STKL_VW_ITEM.DATE,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.ITGRID,IT_MAST.[GROUP],IT_MAST.IT_NAME,IT_MAST.CHAPNO,IT_MAST.TYPE,IT_MAST.RATEUNIT,PROJECTITREF.BATCHNO,PROJECTITREF.MFGDT,PROJECTITREF.EXPDT'		--Commented by Shrikant S. on 19/09/2018 for Installer ENT 2.0.0
SET @SQLCOMMAND='INSERT INTO  #TITEM2 SELECT  STKL_VW_ITEM.ENTRY_TY,STKL_VW_ITEM.tran_cd,BEH=(CASE WHEN LCODE.EXT_VOU=1 THEN LCODE.BCODE_NM ELSE LCODE.ENTRY_TY END),STKL_VW_ITEM.DATE,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,PROJECTITREF.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.ITGRID,IT_MAST.[GROUP],IT_MAST.IT_NAME,IT_MAST.CHAPNO,IT_MAST.TYPE,IT_MAST.RATEUNIT,PROJECTITREF.BATCHNO,PROJECTITREF.MFGDT,PROJECTITREF.EXPDT'			--Added by Shrikant S. on 19/09/2018 for Installer ENT 2.0.0
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'  FROM PROJECTITREF '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN STKL_VW_ITEM  ON (STKL_VW_ITEM.TRAN_CD=PROJECTITREF.TRAN_CD AND STKL_VW_ITEM.ENTRY_TY=PROJECTITREF.ENTRY_TY AND STKL_VW_ITEM.ITSERIAL=PROJECTITREF.ITSERIAL)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN STKL_VW_MAIN  ON (STKL_VW_ITEM.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND STKL_VW_ITEM.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN IT_MAST  ON (IT_MAST.IT_CODE=STKL_VW_ITEM.IT_CODE)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=STKL_VW_MAIN.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN LCODE  ON (STKL_VW_ITEM.ENTRY_TY=LCODE.ENTRY_TY)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND PROJECTITREF.BATCHNO<>'+CHAR(39)+SPACE(1)+CHAR(39)+' AND STKL_VW_ITEM.DC_NO=SPACE(1)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' AND IT_MAST.[TYPE] Not LIKE '+CHAR(39)+'%FINISHED%'+CHAR(39)+' AND PROJECTITREF.ENTRY_TY IN('+CHAR(39)+'ST'+CHAR(39)+','+CHAR(39)+'DC'+CHAR(39)+') '

PRINT @SQLCOMMAND
--Birendra :Start:
EXECUTE SP_EXECUTESQL @SQLCOMMAND
--Birendra :End:


--Added by Shrikant S. on 19/09/2018 for Installer ENT 2.0.0		--Start
Delete FROM #TITEM  WHERE ENTRY_TY+QUOTENAME(TRAN_CD)+ITSERIAL IN (SELECT ENTRY_TY+QUOTENAME(TRAN_CD)+ITSERIAL FROM #TITEM2 )
iNSERT INTO #TITEM SELECT * FROM #TITEM2

--Added by Shrikant S. on 19/09/2018 for Installer ENT 2.0.0		--End

--Added by Shrikant S. on 21/09/2018 for Installer ENT 2.0.0		--Start
Update #TITEM set MFGDT=a.MFGDT,EXPDT=a.EXPDT,batchno=a.Batchno from #TITEM b
	inner join othitref c  on (b.entry_ty=c.entry_ty and b.Tran_cd=c.Tran_cd and b.itserial=c.itserial)
	inner join STKL_VW_ITEM a on (a.entry_ty=c.rentry_ty and a.Tran_cd=c.Itref_tran and a.itserial=c.RItserial)
	Where a.It_code=b.It_code 
--Added by Shrikant S. on 21/09/2018 for Installer ENT 2.0.0		--End

--Birendra :Start:
select a.ENTRY_TY,a.tran_cd,a.BEH,a.DATE,STKL.AC_ID,a.IT_CODE,QTY=B.rqty,a.U_LQTY,a.ITSERIAL,a.PMKEY,a.ITGRID,
a.[GROUP],a.IT_NAME,a.CHAPNO,a.TYPE,a.RATEUNIT,
BATCHNO = case when a.type in ('Raw Material','Machinery/Stores','Packing Material')then isnull(STKL.supbatchno,'') else isnull(STKL.BATCHNO,'') end,
MFGDT = case when a.type in ('Raw Material','Machinery/Stores','Packing Material')then isnull(STKL.supMFGDT,'') else isnull(STKL.MFGDT,'') end,
EXPDT = case when a.type in ('Raw Material','Machinery/Stores','Packing Material')then isnull(STKL.supEXPDT,'') else isnull(STKL.EXPDT,'') end
into #titem1
from #titem a left join othitref b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd and a.itserial=b.itserial)
left join (select x.Entry_ty,x.tran_cd,x.itserial,x.batchno,x.mfgdt,x.expdt,x.supbatchno,x.supmfgdt,x.supexpdt,x.ac_id from stkl_vw_item x inner join lcode y on (x.entry_ty=y.entry_ty) where y.inv_stk='+'  ) stkl on (stkl.entry_ty=b.rentry_ty and stkl.tran_cd=b.itref_tran and stkl.itserial=b.ritserial)
where a.entry_ty='IP'

delete from #titem  
where rtrim(entry_ty)+ltrim(rtrim(cast(tran_cd as varchar(10))))+rtrim(ltrim(itserial)) in (select rtrim(entry_ty)+ltrim(rtrim(cast(tran_cd as varchar(10))))+rtrim(ltrim(itserial)) from othitref where entry_ty='IP')

insert into #titem select * from #titem1

--Birendra :End:


SELECT DESCRIPTION=A.IT_NAME,A.RATEUNIT,a.ac_id,A.BATCHNO,A.MFGDT,A.EXPDT
,CLBAL =SUM(CASE WHEN  A.PMKEY='+' THEN A.QTY ELSE -A.QTY END),pdays=abs(datediff(d,a.Expdt,@Sdate))			--Added by Shrikant S. on 25/09/2018 for Installer ENT 2.0.0	
--,CLBAL =SUM(CASE WHEN  A.PMKEY='+' THEN A.QTY ELSE -A.QTY END),pdays=datediff(d,a.Expdt,@Edate)		--Commented by Shrikant S. on 25/09/2018 for Installer ENT 2.0.0
,BATCHSTATUS=CASE WHEN a.Expdt < @Sdate THEN 'Expired' ELSE 'Not Expired' END				--Added by Shrikant S. on 25/09/2018 for Installer ENT 2.0.0	
Into #tmpItem FROM #TITEM A
GROUP BY A.IT_NAME,A.RATEUNIT,a.ac_id,A.BATCHNO,A.MFGDT,A.EXPDT
ORDER BY A.IT_NAME,A.RATEUNIT,A.BATCHNO


IF LTRIM(RTRIM(@DAYS1))<>'0' AND LTRIM(RTRIM(@DAYS2))<>'0' AND LTRIM(RTRIM(@DAYS3))<>'0' AND LTRIM(RTRIM(@DAYS4))<>'0'
BEGIN
	SET @COLCAP1='<='+LTRIM(RTRIM(@DAYS1))+' '+'DAYS'
	SET @COLCAP2='>'+LTRIM(RTRIM(@DAYS1))+' AND '+'<='+LTRIM(RTRIM(@DAYS2))+' '+'DAYS'
	SET @COLCAP3='>'+LTRIM(RTRIM(@DAYS2))+' AND '+'<='+LTRIM(RTRIM(@DAYS3))+' '+'DAYS'
	SET @COLCAP4='>'+LTRIM(RTRIM(@DAYS3))+' AND '+'<='+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP5='>'+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
END
IF LTRIM(RTRIM(@DAYS1))='0' AND LTRIM(RTRIM(@DAYS2))<>'0' AND LTRIM(RTRIM(@DAYS3))<>'0' AND LTRIM(RTRIM(@DAYS4))<>'0'
BEGIN
	SET @COLCAP1='<='+LTRIM(RTRIM(@DAYS2))+' '+'DAYS'
	SET @COLCAP2='>'+LTRIM(RTRIM(@DAYS2))+' AND '+'<='+LTRIM(RTRIM(@DAYS3))+' '+'DAYS'
	SET @COLCAP3='>'+LTRIM(RTRIM(@DAYS3))+' AND '+'<='+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP4='>'+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP5=' '
END
IF LTRIM(RTRIM(@DAYS1))='0' AND LTRIM(RTRIM(@DAYS2))='0' AND LTRIM(RTRIM(@DAYS3))<>'0' AND LTRIM(RTRIM(@DAYS4))<>'0'
BEGIN
	SET @COLCAP1='<='+LTRIM(RTRIM(@DAYS3))+' '+'DAYS'
	SET @COLCAP2='>'+LTRIM(RTRIM(@DAYS3))+' AND '+'<='+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP3='>'+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP4=' '
	SET @COLCAP5=' '
END
IF LTRIM(RTRIM(@DAYS1))='0' AND LTRIM(RTRIM(@DAYS2))='0' AND LTRIM(RTRIM(@DAYS3))='0' AND LTRIM(RTRIM(@DAYS4))<>'0'
BEGIN
	SET @COLCAP1='<='+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP2='>'+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP3=' '
	SET @COLCAP4=' '
	SET @COLCAP5=' '
END

SELECT DESCRIPTION,RATEUNIT,BATCHNO,MFGDT,EXPDT
,DAYS1=@COLCAP1
,DAYS2=@COLCAP2
,DAYS3=@COLCAP3
,DAYS4=@COLCAP4
,DAYS5=@COLCAP5
,cldays1=sum(case when pdays<=@days1 then CLBAL else 0 end)
,cldays2=sum(case when pdays>@days1 and pdays<=@days2 then CLBAL else 0 end)
,cldays3=sum(case when pdays>@days2 and pdays<=@days3 then CLBAL else 0 end)
,cldays4=sum(case when pdays>@days3 and pdays<=@days4 then CLBAL else 0 end)
,cldays5=sum(case when pdays>@days4 then clbal else 0 end)
,BATCHSTATUS													--Added by Shrikant S. on 25/09/2018 for Installer ENT 2.0.0	
FROM #tmpItem
GROUP BY DESCRIPTION,RATEUNIT,BATCHNO,MFGDT,EXPDT,BATCHSTATUS			--Changed by Shrikant S. on 25/09/2018 for Installer ENT 2.0.0	
ORDER BY DESCRIPTION,RATEUNIT,BATCHNO


DROP TABLE #TITEM
DROP TABLE #tmpItem 
drop table #titem1
DROP TABLE #TITEM2
GO
