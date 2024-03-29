DROP PROCEDURE [USP_REP_FRINGEBENEFIT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Fringe Benefit Report .
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
CREATE PROCEDURE [USP_REP_FRINGEBENEFIT]  
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
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=null,@VEDATE=@EDATE
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


SELECT 
AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY
,MN.L_YN
,AC_MAST.AC_ID,AC_MAST.AC_NAME
,AC_mast.FBTSEC,AC_mast.FBEXPPER
INTO #AC_BAL1
FROM LAC_VW AC
INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID)
INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY) 
WHERE 1=2

SET @SQLCOMMAND='INSERT INTO #AC_BAL1 SELECT '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',MN.L_YN'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',AC_MAST.AC_ID,AC_MAST.AC_NAME'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',AC_MAST.FBTSEC,FBEXPPER=ISNULL(AC_MAST.FBEXPPER,0)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'FROM LAC_VW AC'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'AND AC_MAST.FBEXPPER<>0'

PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

DELETE FROM #AC_BAL1 WHERE 
DATE < (SELECT TOP 1 DATE FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN)
AND AC_NAME IN (SELECT AC_NAME FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN GROUP BY AC_NAME) 

declare @sdate1 smalldatetime,@sdate2 smalldatetime,@sdate3 smalldatetime,@sdate4 smalldatetime,@edate1 smalldatetime,@edate2 smalldatetime,@edate3 smalldatetime,@edate4 smalldatetime

select @sdate1=@sdate,@sdate2=dateadd(mm,3,@sdate),@sdate3=dateadd(mm,6,@sdate),@sdate4=dateadd(mm,9,@sdate)
select @edate1=dateadd(day,-1,@sdate2),@edate2=dateadd(day,-1,@sdate3),@edate3=dateadd(day,-1,@sdate4),@edate4=dateadd(day,-1,dateadd(mm,12,@sdate))


--select @sdate1,@edate1,@sdate2,@edate2,@sdate3,@edate3,@sdate4,@edate4

select ac_name,fbtsec,fbexpper
,amt1=SUM(case when date between @sdate1 and @edate1 then (case when amt_ty='dr' then amount else -amount end) else 0 end) 
,amt2=SUM(case when date between @sdate2 and @edate2 then (case when amt_ty='dr' then amount else -amount end) else 0 end) 
,amt3=SUM(case when date between @sdate3 and @edate3 then (case when amt_ty='dr' then amount else -amount end) else 0 end) 
,amt4=SUM(case when date between @sdate4 and @edate4 then (case when amt_ty='dr' then amount else -amount end) else 0 end) 
from #AC_BAL1
group by ac_name,fbtsec,fbexpper
GO
