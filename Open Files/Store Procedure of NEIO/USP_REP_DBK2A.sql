DROP PROCEDURE [USP_REP_DBK2A]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR     :	PRIYANKA.H
-- CREATE DATE: 28/12/2011
-- DESCRIPTION:	THIS STORE PROCEDURE IS USED TO GENERATE STATEMENT DBK2A REPORTS.
-- MODIFIED DATE : 
-- MODIFIED REMARK:
-- =============================================

create PROCEDURE [USP_REP_DBK2A]
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
DECLARE @FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)
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
,@VMAINFILE='PTMAIN',@VITFILE='PTITEM',@VACFILE=''
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000), @VCOND NVARCHAR(2000)
--,PTITEM.U_BASDUTY,PTITEM.U_CVDAMT,PTITEM.U_CVDPER,PTITEM.U_CUSTAMT,PTITEM.HCDAMT,PTITEM.HCDPER,PTITEM.U_CUSTPER,PTITEM.U_CESSAMT,PTITEM.U_CESSPER,PTITEM.U_HCESAMT,PTITEM.U_HCESSPER,PTITEM.CCDAMT,PTITEM.CCDPER,PTITEM.EXAMT
SET @SQLCOMMAND='
DECLARE @BOMSERIAL AS VARCHAR(200),@Balqty numeric(10,2)
select @Balqty=0
SELECT PTMAIN.Entry_ty,PTMAIN.Tran_cd,PTMAIN.INV_NO,PTITEM.IT_CODE,PTMAIN.DATE,IT_DESC=(CASE WHEN ISNULL(IT_MAST.IT_ALIAS,'''')='''' THEN IT_MAST.IT_NAME ELSE IT_MAST.IT_ALIAS END)
,PTMAIN.BENO,PTMAIN.BEDT,PTMAIN.U_ISASSFL,PTMAIN.U_CHANAME,PTITEM.QTY,IT_MAST.RATEUNIT,PTITEM.RATE
,PTITEM.BCDAMT,PTITEM.BCDPER
,PTITEM.ITSERIAL,IT_MAST.EIT_NAME
,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.COUNTRY
,AC_MAST1.AC_NAME AS AC_NAME1,AC_MAST1.ADD1 AS ADD11,AC_MAST1.ADD2 AS ADD12,AC_MAST1.ADD3 AS ADD13,AC_MAST1.COUNTRY AS COUNTRY1
,@BOMSERIAL AS BOMSERIAL,@Balqty as [Bal_qty]
INTO #TBL1
FROM PTITEM 
INNER JOIN PTMAIN ON (PTITEM.ENTRY_TY=PTMAIN.ENTRY_TY and PTITEM.TRAN_CD=PTMAIN.TRAN_CD) 
INNER JOIN IT_MAST ON (PTITEM.IT_CODE=IT_MAST.IT_CODE) 
INNER JOIN AC_MAST ON (PTMAIN.AC_ID=AC_MAST.AC_ID)
INNER JOIN AC_MAST AC_MAST1 ON (PTMAIN.CONS_ID=AC_MAST1.AC_ID)
WHERE PTMAIN.ENTRY_TY = ''P1''

SELECT DISTINCT A.BOMID,C.IT_CODE,(rtrim(A.Bomid)+''-''+rtrim(B.BOMDETID)) as bomdetid
INTO #Tmp2	
FROM BOMHEAD A
INNER JOIN BOMDET B ON (A.BOMID=B.BOMID AND A.BOMLEVEL=B.BOMLEVEL)
INNER JOIN #TBL1 C ON (B.RMITEMID=C.IT_CODE)

select e.Entry_ty,e.Tran_cd,e.itserial,(isnull(e.qty,0)-isnull(sum(a.qty),0)) as [Bal_qty]
into #tmp3
from ipitem a
Inner Join Othitref c ON (c.Entry_ty = a.Entry_ty AND c.Tran_cd = a.Tran_cd And c.Itserial = a.Itserial)
Inner Join PTItem d ON (c.REntry_ty = d.Entry_ty AND c.Itref_tran = d.Tran_cd And c.RItserial = d.Itserial)
Inner Join PTMain b ON (b.Entry_ty = d.Entry_ty AND b.Tran_cd = d.Tran_cd)
inner join #tbl1 e on (e.Entry_ty = b.Entry_ty AND e.Tran_cd = b.Tran_cd And e.Itserial = d.Itserial)
where b.entry_ty=''P1''
group by e.Entry_ty,e.Tran_cd,e.itserial,e.qty

Declare @It_code int
Declare TCursor Cursor for select Distinct It_code from #TBL1 
Open TCursor
fetch next from TCursor into @It_code
while @@fetch_status=0
Begin
	SELECT @Bomserial = (SELECT Rtrim([Bomdetid])+'','' FROM #Tmp2
		   Where It_code = @It_code FOR XML PATH('''') )
	Select @Bomserial = ISNULL(@Bomserial,'''')
	IF @Bomserial <> ''''
	BEGIN
		SELECT @Bomserial = Left(@Bomserial,Len(@Bomserial)-1)
	END	
	Update #Tbl1 SET Bomserial = @Bomserial Where It_code = @It_code
	fetch next from TCursor into @It_code
End
close TCursor
deallocate TCursor

Update #tbl1 set [Bal_qty]=  0
Declare @_Entry_ty Varchar(2),@_Tran_cd Int,@_Itserial Varchar(5)
Declare BCursor Cursor for select Entry_ty,Tran_cd,Itserial from #TBL1 group by Entry_ty,Tran_cd,Itserial
Open BCursor
fetch next from BCursor into @_Entry_ty,@_Tran_cd,@_Itserial
while @@fetch_status=0
Begin
	Update #tbl1 set [Bal_qty]= ((select [Bal_qty] from #tmp3 Where Entry_ty = @_Entry_ty AND Tran_cd = @_Tran_cd AND Itserial = @_Itserial))
		Where Entry_ty = @_Entry_ty AND Tran_cd = @_Tran_cd AND Itserial = @_Itserial
	fetch next from BCursor into @_Entry_ty,@_Tran_cd,@_Itserial
End
close BCursor
deallocate BCursor

Select * FROM #Tbl1
Drop table #Tbl1
Drop table #Tmp2
Drop table #Tmp3'

PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND



--
--SET @SQLCOMMAND='DECLARE @BOMSERIAL AS VARCHAR(MAX),@Balqty numeric(10,2)
--SELECT PTMAIN.INV_NO,PTITEM.IT_CODE,PTMAIN.DATE,IT_DESC=(CASE WHEN ISNULL(IT_MAST.IT_ALIAS,'''')='''' THEN IT_MAST.IT_NAME ELSE IT_MAST.IT_ALIAS END)'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',PTMAIN.BENO,PTMAIN.BEDT,PTMAIN.U_ISASSFL,PTMAIN.U_CHANAME,PTITEM.QTY,IT_MAST.RATEUNIT,PTITEM.RATE,PTITEM.U_CUSTAMT,PTITEM.U_CUSTPER
--,PTITEM.BCDAMT,PTITEM.BCDPER,PTITEM.U_CESSAMT,PTITEM.U_CESSPER,PTITEM.U_HCESAMT,PTITEM.U_HCESSPER,PTITEM.CCDAMT,PTITEM.CCDPER'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',PTITEM.HCDAMT,PTITEM.HCDPER,PTITEM.U_CVDAMT,PTITEM.U_CVDPER
--,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.COUNTRY'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',AC_MAST1.AC_NAME AS AC_NAME1,AC_MAST1.ADD1 AS ADD11,AC_MAST1.ADD2 AS ADD12,AC_MAST1.ADD3 AS ADD13,AC_MAST1.COUNTRY AS COUNTRY1
--,@BOMSERIAL AS BOMSERIAL,@Balqty as [Bal_qty]'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INTO #TBL1 FROM PTITEM INNER JOIN PTMAIN ON (PTITEM.TRAN_CD=PTMAIN.TRAN_CD) INNER JOIN IT_MAST ON (PTITEM.IT_CODE=IT_MAST.IT_CODE) '
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN AC_MAST ON (PTMAIN.AC_ID=AC_MAST.AC_ID)
--INNER JOIN AC_MAST AC_MAST1 ON (PTMAIN.CONS_ID=AC_MAST1.AC_ID)WHERE PTMAIN.ENTRY_TY = ''P1'''
--
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT DISTINCT A.BOMID,C.IT_CODE,(rtrim(A.Bomid)+''-''+rtrim(B.BOMDETID)) as bomdetid
--INTO #Tmp2	FROM BOMHEAD A INNER JOIN BOMDET B ON (A.BOMID=B.BOMID AND A.BOMLEVEL=B.BOMLEVEL) INNER JOIN #TBL1 C ON (B.RMITEMID=C.IT_CODE) '
--
--select #tbl1.beno,(isnull(#tbl1.qty,0)-isnull(sum(a.qty),0)) as [Bal_qty]
--into #tmp3
--from ipitem a
--Inner Join Othitref c ON (c.Entry_ty = a.Entry_ty AND c.Tran_cd = a.Tran_cd And c.Itserial = a.Itserial)
--Inner Join PTItem d ON (c.REntry_ty = d.Entry_ty AND c.Itref_tran = d.Tran_cd And c.RItserial = d.Itserial)
--Inner Join PTMain b ON (b.Entry_ty = d.Entry_ty AND b.Tran_cd = d.Tran_cd)
--inner join #tbl1 on (#tbl1.it_code=a.it_code and #tbl1.beno=b.beno)
--where b.entry_ty=''P1''
--group by #tbl1.beno,#tbl1.qty
--
--
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Declare @It_code int Declare TCursor Cursor for select Distinct It_code from #TBL1 Open TCursor
--fetch next from TCursor into @It_code while @@fetch_status=0 Begin	SELECT @Bomserial = (SELECT Rtrim([Bomdetid])+'','' FROM #Tmp2
--		   Where It_code = @It_code FOR XML PATH('''') )'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Select @Bomserial = ISNULL(@Bomserial,'''')IF @Bomserial <> '''' BEGIN	SELECT @Bomserial = Left(@Bomserial,Len(@Bomserial)-1)
--	END	Update #Tbl1 SET Bomserial = @Bomserial Where It_code = @It_code fetch next from TCursor into @It_code'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'End close TCursor deallocate TCursor Select * FROM #Tbl1 Drop table #Tbl1 Drop table #Tmp2'
--
--PRINT @SQLCOMMAND
--EXECUTE SP_EXECUTESQL @SQLCOMMAND

--EXECUTE USP_REP_DBK2 '','','','04/01/2011','03/31/2012','','','','',0,0,'','','','','','','','','2011-2012',''
GO
