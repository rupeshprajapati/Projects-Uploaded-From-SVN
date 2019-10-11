DROP PROCEDURE [USP_REP_EPCG_INV_REG]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Created By    : Ajay Jaiswal
-- Create Date   : 13/08/2012
-- Description   : This Stored procedure is useful to Generate data for EPCG Invoice Register.
-- Modified By   :
-- Modified Date :
-- =============================================

CREATE PROCEDURE  [USP_REP_EPCG_INV_REG]
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
DECLARE @FCON AS NVARCHAR(1000)

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
,@VMAINFILE='STMAIN',@VITFILE=NULL,@VACFILE=NULL
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

IF @FCON IS NOT NULL OR @FCON <> ''
BEGIN
	SET @FCON = @FCON 
END

DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(2000)
DECLARE @U_BASDUTY NUMERIC(12,2),@U_CESSPER NUMERIC(12,2),@U_HCESPER NUMERIC(12,2)	

SET @SQLCOMMAND='SELECT STMAIN.INV_SR, STMAIN.TRAN_CD, STMAIN.ENTRY_TY, STMAIN.INV_NO, STMAIN.DATE, STMAIN.U_SBNO'
SET @SQLCOMMAND=@SQLCOMMAND+', STMAIN.U_SBDT, STMAIN.FCNET_AMT, STMAIN.NET_AMT, STITEM.U_FRT, STITEM.U_INS'
SET @SQLCOMMAND=@SQLCOMMAND+', STMAIN.U_FOBSB, STMAIN.U_FOBBRC, Narr = CAST(STMAIN.NARR as Varchar(2000)), Curr_mast.currencycd'
SET @SQLCOMMAND=@SQLCOMMAND+' FROM STMAIN  INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD)'
SET @SQLCOMMAND=@SQLCOMMAND+' INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE)'
SET @SQLCOMMAND=@SQLCOMMAND+' INNER JOIN CURR_MAST ON (STMAIN.FCID = CURR_MAST.CURRENCYID)'
SET @SQLCOMMAND=@SQLCOMMAND+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID)'
SET @SQLCOMMAND=@SQLCOMMAND+' LEFT JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_NAME=STMAIN.U_DELIVER)'
SET @SQLCOMMAND=@SQLCOMMAND+RTRIM(@FCON)
SET @SQLCOMMAND=@SQLCOMMAND+' and STMAIN.ENTRY_TY = ''EI'''

print @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
