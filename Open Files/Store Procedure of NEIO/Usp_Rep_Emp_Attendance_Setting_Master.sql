DROP PROCEDURE [Usp_Rep_Emp_Attendance_Setting_Master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: pratap
-- Create date: 
-- Description:	This is useful for Attendance Setting Report
-- Modify date: 
-- Remark:
-- =============================================
Create PROCEDURE [Usp_Rep_Emp_Attendance_Setting_Master]
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
begin
Declare @FCON as NVARCHAR(2000)
SELECT A.*, L.Loc_desc FROM EMP_ATTENDANCE_SETTING A left join Loc_Master L on (a.Loc_code=l.loc_code)
END
GO
