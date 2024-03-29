DROP PROCEDURE [USP_REP_COMP_ANAL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [USP_REP_COMP_ANAL]
@TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),
@SDATE SMALLDATETIME,@EDATE SMALLDATETIME,
@SNAME NVARCHAR(60),@ENAME NVARCHAR(60),
@SITEM NVARCHAR(60),@EITEM NVARCHAR(60),
@SAMT NUMERIC,@EAMT NUMERIC,
@SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),
@SCAT NVARCHAR(60),@ECAT NVARCHAR(60),@SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),
@SWARE NVARCHAR(60),@EWARE NVARCHAR(60),
@FINYR NVARCHAR(20), @EXTPAR NVARCHAR(60)
AS
	SET NOCOUNT ON
	---TAKING OUTPUT FROM USP_ACDET_VW

	IF @TMPAC<>''
	BEGIN
		DECLARE @strQ NVARCHAR(1000)
		SET @strQ='SELECT AC_NAME FROM '+@TMPAC

		SELECT AC_NAME INTO #ACNAMES FROM AC_MAST WHERE 1=2
		INSERT #ACNAMES EXECUTE(@strQ)		---TABLE IN @TMPAC SHIFTED IN #ACNAMES

		SELECT VW.AC_NAME,	
			APR=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=4 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=4 THEN AMOUNT END),0),
			MAY=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=5 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=5 THEN AMOUNT END),0),
			JUN=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=6 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=6 THEN AMOUNT END),0),
			JUL=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=7 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=7 THEN AMOUNT END),0),
			AUG=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=8 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=8 THEN AMOUNT END),0),
			SEP=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=9 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=9 THEN AMOUNT END),0),
			OCT=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=10 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=10 THEN AMOUNT END),0),
			NOV=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=11 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=11 THEN AMOUNT END),0),
			DEC=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=12 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=12 THEN AMOUNT END),0),
			JAN=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=1 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=1 THEN AMOUNT END),0),
			FEB=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=2 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=2 THEN AMOUNT END),0),
			MAR=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=3 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=3 THEN AMOUNT END),0)
		FROM UVW_ACDET VW
		WHERE VW.DATE BETWEEN @SDATE AND @EDATE AND 
			ENTRY_TY<>'OB'
		GROUP BY VW.AC_NAME
		HAVING VW.AC_NAME IN (SELECT AC_NAME FROM #ACNAMES)					---#ACNAMES USED HERE
		ORDER BY AC_NAME
	END
	ELSE
	BEGIN
		SELECT VW.AC_NAME,	
			APR=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=4 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=4 THEN AMOUNT END),0),
			MAY=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=5 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=5 THEN AMOUNT END),0),
			JUN=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=6 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=6 THEN AMOUNT END),0),
			JUL=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=7 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=7 THEN AMOUNT END),0),
			AUG=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=8 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=8 THEN AMOUNT END),0),
			SEP=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=9 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=9 THEN AMOUNT END),0),
			OCT=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=10 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=10 THEN AMOUNT END),0),
			NOV=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=11 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=11 THEN AMOUNT END),0),
			DEC=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=12 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=12 THEN AMOUNT END),0),
			JAN=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=1 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=1 THEN AMOUNT END),0),
			FEB=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=2 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=2 THEN AMOUNT END),0),
			MAR=	isnull(sum(CASE WHEN VW.AMT_TY='DR' AND month(VW.DATE)=3 THEN AMOUNT END),0)
				-	isnull(sum(CASE WHEN VW.AMT_TY='CR' AND month(VW.DATE)=3 THEN AMOUNT END),0)
		FROM UVW_ACDET VW
		WHERE VW.DATE BETWEEN @SDATE AND @EDATE AND 
			ENTRY_TY<>'OB'
		GROUP BY VW.AC_NAME
		HAVING VW.AC_NAME BETWEEN @SNAME AND @ENAME
		ORDER BY AC_NAME
	END
GO
