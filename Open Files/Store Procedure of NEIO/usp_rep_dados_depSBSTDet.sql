DROP PROCEDURE [usp_rep_dados_depSBSTDet]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [usp_rep_dados_depSBSTDet]
@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)

AS
begin
	PRINT @sdate
	PRINT @edate
	PRINT @SDEPT
	PRINT @EDEPT

	SELECT stmain.l_yn,datename(mm,stmain.date) AS 'MONTH',stmain.dept AS Department,stmain.salesman,dbo.STITEM.party_nm AS 'Client Name',dbo.STITEM.item AS 'Product',stmain.entry_ty,stmain.inv_no,stmain.date,stitem.gro_amt AS 'Value' INTO #STSB FROM dbo.STITEM
	INNER JOIN dbo.STMAIN ON(dbo.STITEM.entry_ty = dbo.STMAIN.entry_ty AND dbo.STITEM.Tran_cd = dbo.STMAIN.Tran_cd)
	WHERE 1=2 
	
	INSERT INTO #STSB
	SELECT stmain.l_yn,datename(mm,stmain.date) AS 'MONTH',stmain.dept AS Department,stmain.salesman,dbo.STITEM.party_nm,dbo.STITEM.item,stmain.entry_ty,stmain.inv_no,stmain.date,stitem.gro_amt FROM dbo.STITEM
	INNER JOIN dbo.STMAIN ON(dbo.STITEM.entry_ty = dbo.STMAIN.entry_ty AND dbo.STITEM.Tran_cd = dbo.STMAIN.Tran_cd)
	
	INSERT INTO #STSB
	SELECT sbmain.l_yn,datename(mm,sbmain.date),sbmain.dept,sbmain.salesman,dbo.SbITEM.party_nm,dbo.SbITEM.item,sbmain.entry_ty,sbmain.inv_no,sbmain.date,sbitem.gro_amt FROM dbo.SbITEM
	INNER JOIN dbo.SbMAIN ON(dbo.SbITEM.entry_ty = dbo.SbMAIN.entry_ty AND dbo.SbITEM.Tran_cd = dbo.SbMAIN.Tran_cd)

SELECT 
CASE datename(mm,#STSB.date)
WHEN 'April' THEN '1'
WHEN 'May' THEN '1'
WHEN 'June' THEN '1'
WHEN 'July' THEN '2'
WHEN 'August' THEN '2'
WHEN 'September' THEN '2'
WHEN 'October' THEN '3'
WHEN 'November' THEN '3'
WHEN 'December' THEN '3'
WHEN 'January' THEN '4'
WHEN 'February' THEN '4'
WHEN 'March' THEN '4'
Else 'XXX'
END AS 'Quarter',
Department,Salesman,Product,[Client Name],[Value],DATE,inv_no FROM #STSB 
WHERE (DATE BETWEEN @SDATE AND @EDATE) AND (Department between @SDEPT and @EDEPT)
ORDER BY date

DROP TABLE #STSB
end 
--
--SET ANSI_NULLS Off
--GO
--SET QUOTED_IDENTIFIER Off
--GO
--
--EXECUTE usp_rep_dados_depSBSTDet '04/24/2012','04/24/2013','','Z'
GO
