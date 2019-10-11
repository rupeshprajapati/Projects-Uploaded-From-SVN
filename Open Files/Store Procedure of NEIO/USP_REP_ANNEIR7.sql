set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI.
-- CREATE DATE: 16/05/2007
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO GENERATE EXCISE PROFORMA FOR MONTHLY RETURN UNDER RULE-7 (INPUT GOODS) REPORT.
-- Modification Date/By/Reason: 29/04/2009 Rupesh Prajapati. Part-II Input Goods Credit Entry.
-- Modification Date/By/Reason: 15/06/2009 Rupesh Prajapati. Modified for Consignor Details.
-- Modification Date/By/Reason: 11/08/2009 Rupesh Prajapati. Modified Principal Input.
-- Modification Date/By/Reason: 24/02/2010 Hetal L Patel. Modified Added Sales Entry With Purchase Return.--TKT 497
 --Modification Date/By/Reason: 08/03/2011 Sandeep Shah Modified for RG23 Part 2 Credit entry --TKT-6365
-- Remark: 
-- =============================================
ALTER PROCEDURE    [dbo].[USP_REP_ANNEIR7]
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
SET QUOTED_IDENTIFIER OFF
DECLARE @FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)


DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(2000),@FDATE VARCHAR(10)

SELECT @FDATE=CASE WHEN DBDATE=1 THEN 'DATE' ELSE 'U_CLDT' END FROM MANUFACT



SELECT PTMAIN.ENTRY_TY,STKL_VW_MAIN.DATE,PTMAIN.U_CLDT, PTMAIN.DOC_NO,PTMAIN.U_PINVNO,PTMAIN.U_PINVDT,STKL_VW_MAIN.U_RG23NO,PTMAIN.AC_ID,PTMAIN.NET_AMT,PTITEM.QTY,PTITEM.GRO_AMT,PTITEM.U_ASSEAMT,PTITEM.EXAMT,PTITEM.U_CESSAMT,PTMAIN.U_CVDAMT,PTITEM.U_HCESAMT,PTITEM.BCDAMT,IT_MAST.IT_NAME,IT_MAST.CHAPNO,PTITEM.TRAN_CD,PTMAIN.CONS_ID,PTMAIN.SCONS_ID,IT_MAST.PRIN_IN INTO #ANNEIR7 FROM PTMAIN INNER JOIN PTITEM  ON (PTMAIN.TRAN_CD=PTITEM.TRAN_CD) INNER JOIN STKL_VW_MAIN ON(PTMAIN.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND PTMAIN.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY) INNER JOIN IT_MAST ON (PTITEM.ITEM=IT_MAST.IT_NAME)  WHERE 1=2

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
,@VMAINFILE='PTMAIN',@VITFILE='PTTEM',@VACFILE=' '
,@VDTFLD =@FDATE
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

SET @SQLCOMMAND=' INSERT INTO #ANNEIR7 SELECT PTMAIN.ENTRY_TY,STKL_VW_MAIN.DATE,PTMAIN.U_CLDT, PTMAIN.DOC_NO,PTMAIN.U_PINVNO,PTMAIN.U_PINVDT,STKL_VW_MAIN.U_RG23NO,PTMAIN.AC_ID,PTMAIN.NET_AMT,PTITEM.QTY,PTITEM.GRO_AMT,PTITEM.U_ASSEAMT,PTmain.EXAMT,PTmain.U_CESSAMT,PTmain.U_CVDAMT,PTmain.U_HCESAMT,PTmain.BCDAMT,IT_MAST.IT_NAME,IT_MAST.CHAPNO,PTITEM.TRAN_CD,PTMAIN.CONS_ID,PTMAIN.SCONS_ID,IT_MAST.PRIN_IN  FROM PTMAIN INNER JOIN PTITEM  ON (PTMAIN.TRAN_CD=PTITEM.TRAN_CD) INNER JOIN STKL_VW_MAIN ON(PTMAIN.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND PTMAIN.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY) INNER JOIN IT_MAST ON (PTITEM.ITEM=IT_MAST.IT_NAME) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

--- Hetal Dt Sales Entry Of Purchase Return Dt 240210 ST --TKT 497
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
,@VMAINFILE='STMAIN',@VITFILE='STTEM',@VACFILE=' '
,@VDTFLD =@FDATE
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

SET @SQLCOMMAND='INSERT INTO #ANNEIR7'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' SELECT STMAIN.ENTRY_TY,STKL_VW_MAIN.DATE,STMAIN.U_CLDT, STMAIN.DOC_NO,STMAIN.U_PINVNO,STMAIN.U_PINVDT,STKL_VW_MAIN.U_RG23NO,STMAIN.AC_ID,STMAIN.NET_AMT,STITEM.QTY,STITEM.GRO_AMT,STITEM.U_ASSEAMT,STmain.EXAMT,STmain.U_CESSAMT,STmain.U_CVDAMT,STmain.U_HCESAMT,BCDAMT=0,IT_MAST.IT_NAME,IT_MAST.CHAPNO,STITEM.TRAN_CD,STMAIN.CONS_ID,STMAIN.SCONS_ID,IT_MAST.PRIN_IN FROM STMAIN INNER JOIN STITEM  ON (STMAIN.TRAN_CD=STITEM.TRAN_CD) INNER JOIN STKL_VW_MAIN ON(STMAIN.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND STMAIN.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY) INNER JOIN IT_MAST ON (STITEM.ITEM=IT_MAST.IT_NAME) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON) + ' And STMAIN.U_IMPORM = ''PURCHASE RETURN'''
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

--- Hetal Dt Sales Entry Of Purchase Return Dt 240210 ED --TKT 497

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
,@VMAINFILE='SRMAIN',@VITFILE='SRTEM',@VACFILE=' '
,@VDTFLD =@FDATE
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

SET @SQLCOMMAND='INSERT INTO #ANNEIR7'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' SELECT SRMAIN.ENTRY_TY,STKL_VW_MAIN.DATE,SRMAIN.U_CLDT, SRMAIN.DOC_NO,SRMAIN.U_PINVNO,SRMAIN.U_PINVDT,STKL_VW_MAIN.U_RG23NO,SRMAIN.AC_ID,SRMAIN.NET_AMT,SRITEM.QTY,SRITEM.GRO_AMT,SRITEM.U_ASSEAMT,SRmain.EXAMT,SRmain.U_CESSAMT,SRmain.U_CVDAMT,SRmain.U_HCESAMT,BCDAMT=0,IT_MAST.IT_NAME,IT_MAST.CHAPNO,SRITEM.TRAN_CD,SRMAIN.CONS_ID,SRMAIN.SCONS_ID,IT_MAST.PRIN_IN FROM SRMAIN INNER JOIN SRITEM  ON (SRMAIN.TRAN_CD=SRITEM.TRAN_CD) INNER JOIN STKL_VW_MAIN ON(SRMAIN.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND SRMAIN.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY) INNER JOIN IT_MAST ON (SRITEM.ITEM=IT_MAST.IT_NAME) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

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
,@VMAINFILE='IRMAIN',@VITFILE='IRTEM',@VACFILE=' '
,@VDTFLD =@FDATE
,@VLYN=@LYN
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

SET @SQLCOMMAND='INSERT INTO #ANNEIR7'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' SELECT IRMAIN.ENTRY_TY,STKL_VW_MAIN.DATE,IRMAIN.U_CLDT, IRMAIN.DOC_NO,IRMAIN.U_PINVNO,IRMAIN.U_PINVDT,STKL_VW_MAIN.U_RG23NO,IRMAIN.AC_ID,IRMAIN.NET_AMT,IRITEM.QTY,IRITEM.GRO_AMT,IRITEM.U_ASSEAMT,IRmain.EXAMT,IRmain.U_CESSAMT,IRmain.U_CVDAMT,IRmain.U_HCESAMT,IRMAIN.BCDAMT,IT_MAST.IT_NAME,IT_MAST.CHAPNO,IRITEM.TRAN_CD,IRMAIN.CONS_ID,IRMAIN.SCONS_ID,IT_MAST.PRIN_IN FROM IRMAIN LEFT JOIN IRITEM  ON (IRMAIN.TRAN_CD=IRITEM.TRAN_CD AND IRMAIN.ENTRY_TY=IRITEM.ENTRY_TY) INNER JOIN STKL_VW_MAIN ON(IRMAIN.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND IRMAIN.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY) LEFT JOIN IT_MAST ON (IRITEM.ITEM=IT_MAST.IT_NAME) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
print  'A '+@SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

DELETE FROM #ANNEIR7 WHERE PRIN_IN=0 AND ENTRY_TY+CAST(TRAN_CD AS VARCHAR) IN (
SELECT DISTINCT ENTRY_TY+CAST(TRAN_CD AS VARCHAR) FROM #ANNEIR7 WHERE PRIN_IN=1)

SELECT ENTRY_TY
,A.DATE,A.U_CLDT,A.DOC_NO,A.U_PINVNO,A.U_PINVDT,A.U_RG23NO,A.AC_Id,A.NET_AMT,A.QTY,A.GRO_AMT,A.U_ASSEAMT,A.EXAMT,A.U_CESSAMT,A.U_HCESAMT,A.BCDAMT,A.U_CVDAMT,A.IT_NAME,A.CHAPNO
,AC_NAME=(CASE WHEN ISNULL(s.shipto_id,0)=0 then B.ac_name else s.location_id end)
,ECCNO=(CASE WHEN ISNULL(s.shipto_id,0)=0 then b.[ECCNO] else s.[ECCNO] end)
,VEND_TYPE=(CASE WHEN ISNULL(s.shipto_id,0)=0 then b.[VEND_TYPE] else s.[VEND_TYPE] end)
,A.TRAN_CD,A.AC_ID,A.CONS_ID,A.SCONS_ID,PRIN_IN
FROM #ANNEIR7  A
INNER JOIN AC_MAST B ON (B.AC_ID=A.CONS_ID)
LEFT JOIN SHIPTO S ON  (A.SCONS_ID=S.SHIPTO_ID)
ORDER BY A.DATE,A.TRAN_CD

DROP TABLE #ANNEIR7
SET QUOTED_IDENTIFIER ON


