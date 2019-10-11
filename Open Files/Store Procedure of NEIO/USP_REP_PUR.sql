DROP PROCEDURE [USP_REP_PUR]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Created by :	Ramya.
-- Create date: 08/03/2011
-- Description:	This Stored procedure is useful to generate Purchase Audit report between particular amounts .
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
CREATE PROCEDURE   [USP_REP_PUR]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT NUMERIC(20,2),@EAMT NUMERIC(20,2)
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= NULL
AS
DECLARE @FCON AS NVARCHAR(2000),@SQLCOMMAND AS NVARCHAR(4000)
DECLARE @GRP AS VARCHAR(50),@TBLNM AS VARCHAR(50),@TBLNAME1 AS VARCHAR(50)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='LM',@VITFILE=NULL,@VACFILE='LM'
,@VDTFLD ='DATE'
,@VLYN=NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

SET @TBLNM = (SELECT SUBSTRING(RTRIM(LTRIM(STR(RAND( (DATEPART(MM, GETDATE()) * 100000 )
				+ (DATEPART(SS, GETDATE()) * 1000 )
				+ DATEPART(MS, GETDATE())) , 20,15))),3,20) AS NO)
SET @TBLNAME1 = '##TMP1'+@TBLNM
SET @GRP='SUNDRY DEBTORS'
SET @FCON=replace(@FCON,'LM.AMOUNT','LM.NET_AMT')
SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.S_TAX'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SUM(CASE WHEN (LC.ENTRY_TY IN (''PT'') OR LC.BCODE_NM IN (''PT'')) THEN LM.NET_AMT ELSE -LM.NET_AMT END) AS NET_AMT'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SUM(CASE WHEN (LC.ENTRY_TY IN (''PT'') OR LC.BCODE_NM IN (''PT'')) THEN LM.GRO_AMT ELSE -LM.GRO_AMT END) AS GRO_AMT'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SUM(CASE WHEN (LC.ENTRY_TY IN (''PT'') OR LC.BCODE_NM IN (''PT'')) THEN LM.TAXAMT ELSE -LM.TAXAMT END) AS TAXAMT'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SUM(CASE WHEN (LC.ENTRY_TY IN (''PT'') OR LC.BCODE_NM IN (''PT'')) THEN LM.TOT_TAX ELSE -LM.TOT_TAX END) AS TOT_TAX'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SUM(CASE WHEN (LC.ENTRY_TY IN (''PT'') OR LC.BCODE_NM IN (''PT'')) THEN LM.TOT_EXAMT ELSE -LM.TOT_EXAMT END) AS TOT_EXAMT'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SUM(CASE WHEN (LC.ENTRY_TY IN (''PT'') OR LC.BCODE_NM IN (''PT'')) THEN LM.TOT_ADD ELSE -LM.TOT_ADD END) AS TOT_ADD'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SUM(CASE WHEN (LC.ENTRY_TY IN (''PT'') OR LC.BCODE_NM IN (''PT'')) THEN LM.TOT_DEDUC ELSE -LM.TOT_DEDUC END) AS TOT_DEDUC'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SUM(CASE WHEN (LC.ENTRY_TY IN (''PT'') OR LC.BCODE_NM IN (''PT'')) THEN LM.TOT_NONTAX ELSE -LM.TOT_NONTAX END) AS TOT_NONTAX'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SUM(CASE WHEN (LC.ENTRY_TY IN (''PT'') OR LC.BCODE_NM IN (''PT'')) THEN LM.TOT_FDISC ELSE -LM.TOT_FDISC END) AS TOT_FDISC'

SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INTO '+@TBLNAME1
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM LMAIN_VW LM '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=LM.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN LCODE LC ON (LC.ENTRY_TY=LM.ENTRY_TY)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)+' AND (LC.ENTRY_TY IN (''PT'',''PR'') OR LC.BCODE_NM IN (''PT'',''PR''))'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'GROUP BY AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.S_TAX'
print @sqlcommand
EXECUTE SP_EXECUTESQL @SQLCOMMAND
 

SET @SQLCOMMAND=' '
SET @SQLCOMMAND = ' SELECT * FROM '+@TBLNAME1+' WHERE NET_AMT >='+CAST(@SAMT AS VARCHAR(25)) 
EXECUTE SP_EXECUTESQL @SQLCOMMAND


SET ANSI_NULLS OFF
GO
