DROP PROCEDURE [USP_REP_EMP_HOLIDAY_MASTER]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Ramya
-- Create date: 05/03/2012
-- Description:	This is useful for Employee Holiday Master Report
-- Modify date: 
-- Remark:
-- =============================================

Create PROCEDURE [USP_REP_EMP_HOLIDAY_MASTER]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(1000)
AS

Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)
	
BEGIN

SELECT LOC_DESC=isnull(LOC_MASTER.LOC_DESC,''),Emp_Holiday_Master.*,mnth=datename(month,sdate)
FROM Emp_Holiday_Master
Left JOIN LOC_MASTER ON Emp_Holiday_Master.LOC_CODE=LOC_MASTER.LOC_CODE
WHERE Pay_Year=@EXPARA ORDER BY Pay_Year ,sdate

-- (
--(month(sDate) between Month(@sdate) and month(@eDate)) or (month(eDate) between Month(@sdate) and month(@eDate))
--)


END
GO
