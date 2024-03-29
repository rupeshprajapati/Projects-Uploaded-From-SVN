set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Hetal L Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate MH VAT Computation
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
ALTER PROCEDURE [dbo].[USP_REP_MHVATCOMPUTATION]
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

BEGIN
DECLARE @FCON AS NVARCHAR(2000)
EXECUTE   USP_REP_FILTCON 

@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='MN',@VITFILE=Null,@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000)

SELECT DISTINCT AC_NAME=REPLACE(AC_NAME1,'"',''),LEVEL1,PART=1 
INTO #STAX_MAS
FROM STAX_MAS WHERE SET_APP=1 AND AC_NAME1 LIKE '%VAT%' AND ST_TYPE='LOCAL'
--UNION 
--SELECT DISTINCT AC_NAME=REPLACE(AC_NAME3,'"',''),LEVEL1,PART=2 
--FROM STAX_MAS WHERE SET_APP=1 AND AC_NAME3 LIKE '%VAT%' AND ST_TYPE='LOCAL'

SELECT 
AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY
,MN.L_YN
,AC_MAST.AC_ID,AC_MAST.AC_NAME,#STAX_MAS.LEVEL1
INTO #AC_BAL1 
FROM LAC_VW AC
INNER JOIN #STAX_MAS ON (AC.AC_NAME=#STAX_MAS.AC_NAME)
INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID)
INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		Set @MultiCo = 'YES'

		SET @SQLCOMMAND = 'INSERT INTO #AC_BAL1
		SELECT 
		AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY
		,MN.L_YN
		,AC_MAST.AC_ID,AC_MAST.AC_NAME,#STAX_MAS.LEVEL1
		FROM LAC_VW AC
		INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID And Ac.Dbname = Ac_mast.Dbname)
		INNER JOIN #STAX_MAS ON (AC.AC_NAME=#STAX_MAS.AC_NAME)
		INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY And Ac.Dbname = MN.Dbname) '+RTRIM(@FCON) + ' And Ac_Mast.S_tax <> '' '''
--		PRINT @SQLCOMMAND
		EXECUTE SP_EXECUTESQL @SQLCOMMAND

		DELETE FROM #AC_BAL1 WHERE 
		DATE < (SELECT TOP 1 DATE FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN)
		AND AC_NAME IN (SELECT AC_NAME FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN GROUP BY AC_NAME) 

	End
Else
	Begin	------Fetch Records from Single Co. Data
		Set @MultiCo = 'NO'

		SET @SQLCOMMAND = 'INSERT INTO #AC_BAL1
		SELECT 
		AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY
		,MN.L_YN
		,AC_MAST.AC_ID,AC_MAST.AC_NAME,#STAX_MAS.LEVEL1
		FROM LAC_VW AC
		INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY) And Mn.U_Imporm = '' ''
		INNER JOIN AC_MAST AM ON (AM.AC_ID = MN.AC_ID) 
		INNER JOIN #STAX_MAS ON (AC.AC_NAME=#STAX_MAS.AC_NAME)
		INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID)'+RTRIM(@FCON) + ' And AM.S_tax <> '' '''
--		PRINT @SQLCOMMAND
		EXECUTE SP_EXECUTESQL @SQLCOMMAND

		DELETE FROM #AC_BAL1 WHERE 
		DATE < (SELECT TOP 1 DATE FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN)
		AND AC_NAME IN (SELECT AC_NAME FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN GROUP BY AC_NAME) 

	End
SELECT LEVEL1
,OPBAL=SUM(CASE WHEN (ENTRY_TY='OB' OR DATE<@SDATE) THEN (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END)
,DAMT=SUM(CASE WHEN NOT (ENTRY_TY='OB' OR DATE<@SDATE) AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
,CAMT=SUM(CASE WHEN NOT (ENTRY_TY='OB' OR DATE<@SDATE) AND AMT_TY='CR' THEN AMOUNT ELSE 0 END)
,BALAMT=SUM(CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END)
INTO #VATCOMP
FROM #AC_BAL1
GROUP BY LEVEL1
ORDER BY LEVEL1

SELECT OPBAL,LEVEL1,INPUTAMT=DAMT,OUTAMT=CAMT,PAYAMT=
(CASE WHEN  (isnull(CAMT,0)+isnull(DAMT,0)) > 0 and CAMT>(DAMT+OPBAL) THEN CAMT-(DAMT+OPBAL) ELSE 0 END)
,EXESSAMT=(CASE WHEN (isnull(CAMT,0)+isnull(DAMT,0)) > 0 and(DAMT+OPBAL)>CAMT THEN (DAMT+OPBAL)-CAMT ELSE 0 END)
FROM #VATCOMP

END
--Print 'MH VAT COMPUTATION'
--Go
-------
--Print 'MH STORED PROCEDURE UPDATION COMPLETED'
--Go
