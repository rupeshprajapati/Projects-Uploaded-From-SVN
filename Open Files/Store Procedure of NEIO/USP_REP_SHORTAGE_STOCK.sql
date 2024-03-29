DROP PROCEDURE [USP_REP_SHORTAGE_STOCK]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Lokesh.
-- Create date: 25/04/2012
-- Description:	This Stored procedure is useful to generate Sales vs Purchase details.
-- Modify date: 
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================

--EXECUTE USP_REP_SHORTAGE_STOCK '','','','04/01/2012','03/31/2013','','','','',0,0,'','','','','','','','','2012-2013',''

create procedure [USP_REP_SHORTAGE_STOCK]
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
Begin


SELECT SSMAIN.TRAN_CD,ssmain.DATE,ssmain.INV_NO,ssmain.[rule],AC_MAST.MAILNAME,
IT_MAST.[GROUP],ssitem.QTY,
ssitem.RATE,ssitem.GRO_AMT,ssitem.ITEM,ssitem.batchno,ssitem.MFGDT,ssitem.EXPDT  FROM ssmain INNER JOIN ssitem ON 
(ssmain.TRAN_CD=ssitem.TRAN_CD)INNER JOIN AC_MAST ON (AC_MAST.AC_ID=ssmain.AC_ID)
INNER JOIN IT_MAST ON (IT_MAST.IT_CODE=ssitem.IT_CODE)   
ORDER BY ssmain.DATE,ssmain.INV_NO

End

--set ANSI_NULLS Off
--go
--set QUOTED_IDENTIFIER Off
--go
--
--EXECUTE USP_REP_SHORTAGE_STOCK '','','','04/01/2012','03/31/2013','','','','',0,0,'','','','','','','','','2012-2013',''
GO
