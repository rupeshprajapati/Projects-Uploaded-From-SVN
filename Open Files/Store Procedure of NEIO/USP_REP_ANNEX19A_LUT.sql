DROP PROCEDURE [USP_REP_ANNEX19A_LUT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI.
-- CREATE DATE: 16/05/2007
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO GENERATE EXCISE EXPORT ANNEXEURE19A PART-I REPORT.
-- MODIFY DATE: 16/05/2007
-- MODIFIED BY/DATE/REMARK: Sandeep on 10/03/2012 for bug-1582,1587 to added Proof of export date.

-- =============================================
create PROCEDURE  [USP_REP_ANNEX19A_LUT] 
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
/*
SELECT @U_BASDUTY=DEF_PERT FROM DCMAST WHERE ENTRY_TY='ST' AND FLD_NM='EXAMT'
SELECT @U_CESSPER=DEF_PERT FROM DCMAST WHERE ENTRY_TY='ST' AND FLD_NM='U_CESSAMT'
SELECT @U_HCESPER=DEF_PERT FROM DCMAST WHERE ENTRY_TY='ST' AND FLD_NM='U_HCESAMT'

SET @U_BASDUTY=CASE WHEN @U_BASDUTY IS NOT NULL THEN @U_BASDUTY ELSE 0 END
SET @U_CESSPER=CASE WHEN @U_CESSPER IS NOT NULL THEN @U_CESSPER ELSE 0 END
SET @U_HCESPER=CASE WHEN @U_HCESPER IS NOT NULL THEN @U_HCESPER ELSE 0 END
*/
--SELECT  @U_BASDUTY,@U_CESSPER,@U_HCESPER

SELECT STMAIN.TRAN_CD,STMAIN.ARENO,STMAIN.AREDATE
,U_EXBAMT=STMAIN.TOT_EXAMT,STMAIN.U_SBDT,STMAIN.U_PODT,STMAIN.U_POED --Changes by sandeep to added u_poed,tot_examt for bug-1582,1587 on 10/03/2012
,STMAIN.DATE, STMAIN.INV_NO,AC_MAST.AC_NAME 
FROM STMAIN INNER JOIN AC_MAST ON (STMAIN.AC_ID=AC_MAST.AC_ID) 
WHERE (STMAIN.AREDESC='A.R.E.1') AND (STMAIN.AREDATE BETWEEN @SDATE AND @EDATE) 
ORDER BY STMAIN.AREDATE,STMAIN.TRAN_CD
GO
