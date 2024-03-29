DROP PROCEDURE [USP_REP_PETTY_CASH_REG]
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

--EXECUTE USP_REP_PETTY_CASH_REG '','','','04/01/2012','03/31/2013','','','','',0,0,'','','','','','','','','2012-2013',''

CREATE procedure [USP_REP_PETTY_CASH_REG]
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


SELECT PCMAIN.TRAN_CD,PCMAIN.AC_ID,PCMAIN.DATE,PCMAIN.INV_NO,PCMAIN.NET_AMT,MAIN_NARR=SUBSTRING(PCMAIN.NARR,1,4000) ,PCMAIN.INV_SR, 
PCACDET.TRAN_CD,PCACDET.AC_ID,PCACDET.DATE,PCACDET.INV_NO,PCACDET.AC_NAME,PCACDET.AMOUNT,AC_NARR=SUBSTRING(PCACDET.NARR,1,4000) ,PCACDET.INV_SR,PCACDET.AMT_TY
 FROM PCMAIN  INNER JOIN PCACDET ON 
PCMAIN.TRAN_CD=PCACDET.TRAN_CD

End

--set ANSI_NULLS Off
--go
--set QUOTED_IDENTIFIER Off
--go
--
--EXECUTE USP_REP_PETTY_CASH '','','','04/01/2012','03/31/2013','','','','',0,0,'','','','','','','','','2012-2013',''
GO
