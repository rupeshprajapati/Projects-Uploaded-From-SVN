DROP PROCEDURE [USP_REP_LST_PREP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 16/05/2007
-- Description:	This Strored procedure is useful for Excise stock list chapterwise report.
-- Modify date: 16/05/2007
-- Modify date:By:Reason: Rup 09/06/2010 TKT-1690 Rule field filteration Increase @EXPARA size.  
-- Remark:
-- =============================================

CREATE PROCEDURE [USP_REP_LST_PREP]
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
EXECUTE USP_REP_STK_LST 
@TMPAC ,@TMPIT,@SPLCOND ,@SDATE,@EDATE 
,@SAC ,@EAC
,@SIT ,@EIT 
,@SAMT ,@EAMT 
,@SDEPT ,@EDEPT 
,@SCATE ,@ECATE 
,@SWARE ,@EWARE 
,@SINV_SR ,@EINV_SR 
,@LYN 
,@EXPARA
,'CHAPNO'
GO
