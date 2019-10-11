DROP PROCEDURE [USP_REP_FORMRT5]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Excise Form RT-5 Report.
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================


Create     PROCEDURE [USP_REP_FORMRT5]
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


Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL
 ,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='STKL_VW_MAIN',@VITFILE='STKL_VW_ITEM',@VACFILE='EX_VW_ACDET '
,@VDTFLD ='DATE'
,@VLYN=NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @ENTRY_TY CHAR(2),@DATE SMALLDATETIME,@DOC_NO CHAR(5),@AC_ID INT,@IT_CODE NUMERIC(19,0),@QTY DECIMAL(17,4),@U_LQTY DECIMAL(17,4),@ITSERIAL CHAR(5),@PMKEY CHAR(1),@CHAPNO CHAR(10),@ITGRID INT,@TRAN_CD INT,@U_PAGENO CHAR(10)
DECLARE @OPBAL DECIMAL(17,4),@LOPBAL DECIMAL(17,4),@RECEIPT DECIMAL(17,4),@LRECEIPT DECIMAL(17,4),@ISSUE DECIMAL(17,4),@LISSUE DECIMAL(17,4),@BALANCE DECIMAL(17,4),@LBALANCE DECIMAL(17,4),@CURRDT SMALLDATETIME, @V1 NUMERIC(8)
DECLARE @MIT_CODE NUMERIC(19,0),@MITGRID INT,@MCHAPNO CHAR(10),@OBACID INT,@TFCOND CHAR(1) ,@TFCOND1 CHAR(1),@MOPBAL DECIMAL(17,4),@MLOPBAL DECIMAL(17,4)

SELECT @OBACID=AC_ID FROM AC_MAST WHERE AC_NAME='OPENING STOCK'


SELECT ENTRY_TY,DATE,DOC_NO,AC_ID,STKL_VW_ITEM.IT_CODE,OPBAL=QTY,RECEIPT=QTY,ISSUE=QTY,BALANCE=QTY,LOPBAL=U_LQTY,LRECEIPT=U_LQTY,LISSUE=U_LQTY,LBALANCE=U_LQTY,ITSERIAL,PMKEY,CHAPNO,ITGRID,TRAN_CD INTO #LSTEXC FROM  STKL_VW_ITEM INNER JOIN IT_MAST ON(IT_MAST.IT_CODE=STKL_VW_ITEM.IT_CODE) WHERE 1=2


SELECT STKL_VW_ITEM.ENTRY_TY,BEH='  ',STKL_VW_ITEM.DATE,STKL_VW_ITEM.DOC_NO,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.CHAPNO,IT_MAST.ITGRID,STKL_VW_ITEM.TRAN_CD 
INTO #LSTEXC1
FROM STKL_VW_ITEM 
INNER JOIN STKL_VW_MAIN  ON (STKL_VW_ITEM.TRAN_CD=STKL_VW_MAIN.TRAN_CD)
INNER JOIN IT_MAST  ON (IT_MAST.IT_CODE=STKL_VW_ITEM.IT_CODE) 
INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=STKL_VW_ITEM.AC_ID) 
WHERE  1=2

DECLARE @SQLCOMMAND NVARCHAR(4000), @VCOND NVARCHAR(2000)
SET @SQLCOMMAND='INSERT INTO #LSTEXC1 SELECT STKL_VW_ITEM.ENTRY_TY,BEH=(CASE WHEN LCODE.EXT_VOU=1 THEN  LCODE.BCODE_NM ELSE STKL_VW_ITEM.ENTRY_TY END),STKL_VW_ITEM.DATE,STKL_VW_ITEM.DOC_NO,STKL_VW_ITEM.AC_ID,STKL_VW_ITEM.IT_CODE,STKL_VW_ITEM.QTY,STKL_VW_ITEM.U_LQTY,STKL_VW_ITEM.ITSERIAL,STKL_VW_ITEM.PMKEY,IT_MAST.CHAPNO,IT_MAST.ITGRID,STKL_VW_ITEM.TRAN_CD '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'FROM STKL_VW_ITEM '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN STKL_VW_MAIN  ON (STKL_VW_ITEM.TRAN_CD=STKL_VW_MAIN.TRAN_CD AND STKL_VW_ITEM.ENTRY_TY=STKL_VW_MAIN.ENTRY_TY)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN IT_MAST  ON (IT_MAST.IT_CODE=STKL_VW_ITEM.IT_CODE) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN LCODE  ON (STKL_VW_ITEM.ENTRY_TY=LCODE.ENTRY_TY) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=STKL_VW_ITEM.AC_ID) '



SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)

PRINT  @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

--SELECT ENTRY_TY,DATE,DOC_NO,AC_ID,IT_CODE,QTY,U_LQTY,ITSERIAL,PMKEY,CHAPNO,ITGRID,TRAN_CD,U_PAGENO 

SELECT C.IT_NAME,C.RATEUNIT,C.[GROUP],C.TYPE,C.CHAPNO
,OPBAL =SUM(CASE WHEN A.BEH ='OS' OR  A.DATE<@SDATE THEN (CASE WHEN A.PMKEY ='+'  THEN A.QTY ELSE -A.QTY END) ELSE 0 END)
,OPQTY =SUM(CASE WHEN A.BEH  IN ('OP') AND  A.DATE > =@SDATE  AND A.PMKEY ='+' THEN A.QTY ELSE 0 END)
,CPQTY =SUM(CASE WHEN A.BEH NOT IN ('OS','OP') AND  A.DATE > =@SDATE  AND A.PMKEY ='+' THEN A.QTY ELSE 0 END)
,IPQTY =SUM(CASE WHEN  A.DATE > =@SDATE  AND A.PMKEY ='-' THEN A.QTY ELSE 0 END)
,BALANCE=SUM(CASE  WHEN A.PMKEY ='+' THEN A.QTY ELSE -A.QTY END)
INTO #LSTEXC2
FROM  #LSTEXC1 A
INNER JOIN IT_MAST C ON (A.IT_CODE=C.IT_CODE)
GROUP BY C.IT_NAME,C.RATEUNIT,C.[GROUP],C.TYPE,C.CHAPNO
ORDER BY C.IT_NAME


UPDATE #LSTEXC2 SET OPBAL=0,CPQTY=0,IPQTY=0,BALANCE=0 WHERE OPQTY<>0
SELECT * FROM #LSTEXC2

DROP TABLE #LSTEXC1
DROP TABLE #LSTEXC2
GO
