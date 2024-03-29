DROP PROCEDURE [Salesman_outstanding_BR_detail]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [Salesman_outstanding_BR_detail]
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
begin
		
	SELECT entry_ty,Tran_cd,inv_no,date,party_nm,net_amt INTO #MAIN FROM dbo.lmain_vw WHERE 1=2

	INSERT INTO #MAIN
	SELECT entry_ty,Tran_cd,inv_no,date,party_nm,net_amt FROM STMAIN

	INSERT INTO #MAIN
	SELECT entry_ty,Tran_cd,inv_no,date,party_nm,net_amt FROM SBMAIN	
	
	SELECT 
	dbo.BRMAIN.SALESMAN,brmain.inv_no,brmain.date,brmain.cheq_no,dbo.BRMAIN.net_amt,
	dbo.BRMALL.entry_all,dbo.BRMALL.Main_tran,brmall.new_all,
	#MAIN.entry_ty,#MAIN.Tran_cd,#MAIN.inv_no,#MAIN.date,#MAIN.party_nm,#MAIN.net_amt
	FROM dbo.BRMAIN
	left JOIN dbo.BRMALL ON (dbo.BRMAIN.entry_ty = dbo.BRMALL.entry_ty AND dbo.BRMAIN.Tran_cd = dbo.BRMALL.Tran_cd)
	left JOIN #MAIN ON (dbo.BRMALL.entry_ALL = #MAIN.entry_ty AND dbo.BRMALL.Main_tran = #MAIN.Tran_cd)
	WHERE dbo.BRMAIN.date BETWEEN @sdate AND @edate and brmain.salesman between @sac and @eac
	ORDER BY brmain.salesman,brmain.date,BRMAIN.inv_no,#MAIN.date,#MAIN.inv_no
	
	
	DROP TABLE #MAIN
end 
--SET ANSI_NULLS OFF
--GO
--SET QUOTED_IDENTIFIER OFF
--go
--EXECUTE Salesman_outstanding_BR_detail '','','','04/01/2012','03/31/2013','LOKESH K                     ','LOKESH K                          ','','',0,0,'','','','','','','','','2012-2013','sanjay'
--
--
GO
