DROP PROCEDURE [USP_REP_GSP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ajay Jaiswal
-- Create date: 25/01/2011
-- Description:	This Stored procedure is useful to Generate data for Certificate of Origin Report.
-- Modified By: Priyanka Himane
-- Modified Date: 22/11/2011
-- =============================================

CREATE PROCEDURE  [USP_REP_GSP]
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
  
DECLARE @FCON AS NVARCHAR(1000)

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
,@VMAINFILE='STMAIN',@VITFILE=NULL,@VACFILE=NULL
,@VDTFLD ='AREDATE'
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000)
DECLARE @U_BASDUTY NUMERIC(12,2),@U_CESSPER NUMERIC(12,2),@U_HCESPER NUMERIC(12,2)	

--Commented by Priyanka B on 13072017 Start
/*SET @SQLCOMMAND='SELECT STMAIN.INV_SR,STMAIN.TRAN_CD,STMAIN.ENTRY_TY,STMAIN.INV_NO,STMAIN.DATE
,STMAIN.U_TIMEP,STMAIN.U_TIMEP1 ,STMAIN.U_REMOVDT,STMAIN.U_EXPLA,STMAIN.U_EXRG23II,STMAIN.U_RG2AMT
,STITEM.EXAMT,STITEM.U_BASDUTY,STITEM.U_CESSPER,STITEM.U_CESSAMT,STITEM.U_HCESSPER,STITEM.U_HCESAMT
,STMAIN.U_DELIVER,STMAIN.DUE_DT,STMAIN.U_CLDT,U_CHALNO=SPACE(1),U_CHALDT=STMAIN.DATE,STMAIN.U_PONO,STMAIN.U_PODT
,STMAIN.U_LRNO,STMAIN.U_LRDT,STMAIN.U_DELI,STMAIN.U_VEHNO,STMAIN.GRO_AMT GRO_AMT1,STMAIN.TAX_NAME,STMAIN.TAXAMT
,STMAIN.NET_AMT,STMAIN.U_PLASR,STMAIN.U_RG23NO,STMAIN.U_RG23CNO
,STITEM.U_PKNO,STITEM.QTY,STITEM.RATE,STITEM.U_ASSEAMT,STITEM.U_MRPRATE,STITEM.U_EXPDESC,STITEM.U_EXPMARK
,STITEM.U_EXPGWT,STITEM.U_EXPNWT
,STMAIN.u_fdesti,STITEM.FCRATE,STMAIN.FCGRO_AMT,CURR_MAST.CURRDESC
,cast(STITEM.u_pkno as int) as U_PKNO1,STMAIN.U_BLNO,STMAIN.U_BLDT,STMAIN.U_countain,STMAIN.U_COUNTAI2
,STMAIN.U_TSEAL,STMAIN.U_TSEAL2,STMAIN.U_PRECARRI,STMAIN.U_RECEIPT,STMAIN.U_LOADING
,STMAIN.U_PORT,''India'' as U_ORIGIN,STMAIN.U_EXPDEL,IT_MAST.IT_NAME
--,CAST(IT_MAST.IT_DESC AS VARCHAR(4000)) AS IT_DESC 
,It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)
,MailName=(CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)	
,IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.IDMARK,IT_MAST.RATEUNIT 
,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.S_TAX,AC_MAST.I_TAX
,AC_MAST.ECCNO ,AC_MAST1.ADD1 ADD11,AC_MAST1.ADD2 ADD22,AC_MAST1.ADD3 ADD33,AC_MAST1.CITY CITY1
,AC_MAST1.ZIP ZIP1,AC_MAST1.S_TAX S_TAX1,AC_MAST1.I_TAX I_TAX1,AC_MAST1.ECCNO ECCNO1,STITEM.ITSERIAL
,STMAIN.U_OTHREF,STMAIN.U_PAYMENT,STMAIN.U_VESSEL,STMAIN.U_SBNO,STMAIN.U_SBDT
,totqty = (select sum(qty) from stitem inner join stmain on stitem.tran_cd = stmain.tran_cd)
,stmain.u_cerofori --added u_cerofori by Priyanka Himane on 22/11/2011
FROM STMAIN  INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD) 
INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE) 
INNER JOIN CURR_MAST ON (STMAIN.FCID = CURR_MAST.CURRENCYID)
INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID) 
LEFT JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_NAME=STMAIN.U_DELIVER)'
*/
--Commented by Priyanka B on 13072017 End

--Modified by Priyanka B on 13072017 Start
SET @SQLCOMMAND='SELECT STMAIN.INV_SR,STMAIN.TRAN_CD,STMAIN.ENTRY_TY,STMAIN.INV_NO,STMAIN.DATE
,STMAIN.U_TIMEP,STMAIN.U_TIMEP1 ,STMAIN.U_REMOVDT'
--,STMAIN.U_EXPLA,STMAIN.U_EXRG23II,STMAIN.U_RG2AMT,STITEM.EXAMT,STITEM.U_BASDUTY,STITEM.U_CESSPER,STITEM.U_CESSAMT,STITEM.U_HCESSPER,STITEM.U_HCESAMT
SET @SQLCOMMAND=@SQLCOMMAND+',STMAIN.U_DELIVER,STMAIN.DUE_DT,STMAIN.U_CLDT,U_CHALNO=SPACE(1),U_CHALDT=STMAIN.DATE,STMAIN.U_PONO,STMAIN.U_PODT
,STMAIN.U_LRNO,STMAIN.U_LRDT,STMAIN.U_DELI,STMAIN.U_VEHNO,STMAIN.GRO_AMT GRO_AMT1,STMAIN.TAX_NAME,STMAIN.TAXAMT
,STMAIN.NET_AMT'
--,STMAIN.U_PLASR,STMAIN.U_RG23NO,STMAIN.U_RG23CNO
SET @SQLCOMMAND=@SQLCOMMAND+',STITEM.U_PKNO,STITEM.QTY,STITEM.RATE,STITEM.U_ASSEAMT,STITEM.U_MRPRATE,STITEM.U_EXPDESC,STITEM.U_EXPMARK
,STITEM.U_EXPGWT,STITEM.U_EXPNWT,STMAIN.u_fdesti,STITEM.FCRATE,STMAIN.FCGRO_AMT,CURR_MAST.CURRDESC
,cast(STITEM.u_pkno as int) as U_PKNO1,STMAIN.U_BLNO,STMAIN.U_BLDT,STMAIN.U_countain,STMAIN.U_COUNTAI2
,STMAIN.U_TSEAL,STMAIN.U_TSEAL2,STMAIN.U_PRECARRI,STMAIN.U_RECEIPT,STMAIN.U_LOADING
,STMAIN.U_PORT,''India'' as U_ORIGIN,STMAIN.U_EXPDEL,IT_MAST.IT_NAME
--,CAST(IT_MAST.IT_DESC AS VARCHAR(4000)) AS IT_DESC 
,It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)
,MailName=(CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)	
,IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.IDMARK,IT_MAST.RATEUNIT 
,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP'
--,AC_MAST.S_TAX,AC_MAST.ECCNO 
SET @SQLCOMMAND=@SQLCOMMAND+',AC_MAST.I_TAX,AC_MAST1.ADD1 ADD11,AC_MAST1.ADD2 ADD22,AC_MAST1.ADD3 ADD33,AC_MAST1.CITY CITY1,AC_MAST1.ZIP ZIP1'
--,AC_MAST1.S_TAX S_TAX1,AC_MAST1.ECCNO ECCNO1
SET @SQLCOMMAND=@SQLCOMMAND+',AC_MAST1.I_TAX I_TAX1,STITEM.ITSERIAL
,STMAIN.U_OTHREF,STMAIN.U_PAYMENT,STMAIN.U_VESSEL,STMAIN.U_SBNO,STMAIN.U_SBDT
,totqty = (select sum(qty) from stitem inner join stmain on stitem.tran_cd = stmain.tran_cd)
,stmain.u_cerofori --added u_cerofori by Priyanka Himane on 22/11/2011
FROM STMAIN  INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD) 
INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE) 
INNER JOIN CURR_MAST ON (STMAIN.FCID = CURR_MAST.CURRENCYID)
INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID) 
LEFT JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_NAME=STMAIN.U_DELIVER)'
--Modified by Priyanka B on 13072017 End

SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON) ------added by Priyanka Himane on 25012012
SET @SQLCOMMAND=@SQLCOMMAND+' '+'AND STMAIN.ENTRY_TY=''EI'''

EXEC SP_EXECUTESQL @SQLCOMMAND
GO
