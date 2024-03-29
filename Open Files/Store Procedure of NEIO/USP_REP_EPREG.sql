DROP PROCEDURE [USP_REP_EPREG]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_REP_EPREG]  
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

DECLARE @AC_ID NUMERIC(9),@AC_GROUP_ID1 NUMERIC(9),@GNAME1 VARCHAR(60),@AC_GROUP_ID2 NUMERIC(9),@GNAME2 VARCHAR(60),@AC_GROUP_ID3 NUMERIC(9),@GNAME3 VARCHAR(60)

SELECT M.TRAN_CD, A.AC_NAME,M.Date,M.Inv_no,M.PINVNO as U_PINVNO,M.PINVDT as U_PINVDT
,M.net_amt ,CONVERT(VARCHAR(2000),M.Narr) AS Narr ,m.dept,m.cate,m.inv_sr
,AC.AC_NAME AS ACDET_NM,AC.AMOUNT AS AC_AMT,AC.AMT_TY  
FROM EPMAIN M 
INNER JOIN EPACDET AC ON (M.ENTRY_TY=AC.ENTRY_TY AND M.TRAN_CD=AC.TRAN_CD)
INNER JOIN AC_MAST A ON (M.AC_ID=A.AC_ID) 
--WHERE (M.DATE BETWEEN @SDATE AND @EDATE) AND (A.AC_NAME BETWEEN @SAC AND @EAC) --commented for GST on 28/01/2017 by Ruchit Shah
WHERE (M.DATE BETWEEN @SDATE AND @EDATE) AND (A.AC_NAME BETWEEN @SAC AND @EAC) and m.entry_ty='EP' --added for GST on 28/01/2017 by Ruchit Shah
ORDER BY M.DATE,M.TRAN_CD,AC.AMT_TY
GO
