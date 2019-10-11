DROP PROCEDURE [USP_REP_EMP_DESIGNATION_MASTER]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Ramya
-- Create date: 26/12/2011
-- Description:	This is useful for Employee Designation Master Report
-- Modify date: 
-- Remark:
-- =============================================

CREATE PROCEDURE [USP_REP_EMP_DESIGNATION_MASTER]
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

Declare @FCON as NVARCHAR(2000)
	
	EXECUTE USP_REP_FILTCON 
		@VTMPAC=null,@VTMPIT=@TMPIT,@VSPLCOND=@SPLCOND,
		@VSDATE=@SDATE,@VEDATE=@EDATE,
		@VSAC =null,@VEAC =null,
		@VSIT=@SIT,@VEIT=@EIT,
		@VSAMT=null,@VEAMT=null,
		@VSDEPT=@SDEPT,@VEDEPT=@EDEPT,
		@VSCATE =@SCATE,@VECATE =@ECATE,
		@VSWARE =@SWARE,@VEWARE  =@EWARE,
		@VSINV_SR =@SINV_SR,@VEINV_SR =@EINV_SR,
		@VMAINFILE='',@VITFILE='',@VACFILE=null,
		@VDTFLD = 'DATE',@VLYN=null,@VEXPARA=@EXPARA,
		@VFCON =@FCON OUTPUT
BEGIN
SELECT * FROM EMP_DESIGNATION_MASTER ORDER BY DesNm
END
GO
