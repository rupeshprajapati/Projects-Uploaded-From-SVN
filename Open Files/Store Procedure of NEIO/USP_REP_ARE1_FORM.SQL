IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='USP_REP_ARE1_FORM')
BEGIN
	DROP PROCEDURE USP_REP_ARE1_FORM
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
 -- Author:  Suraj Kumawat
 --EXECUTE USP_REP_ARE1_FORM '','','','04/01/2015','03/31/2016','','','','',0,0,'','','','','','','','','2015-2016','STMAIN.ARENO=''1''<YES>'
 -- Create date: 28/07/2015  Bug-26513
 -- Description: This Stored procedure is useful to generate ARE1FORM  
 -- Modify date: 
 -- Modified By: 
 -- =============================================
CREATE PROCEDURE [dbo].[USP_REP_ARE1_FORM]
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
BEGIN
 Declare @SQLCOMMAND AS NVARCHAR(4000),@FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2),@SHOW_EXICSE_AMT VARCHAR(3),@CONFLDS VARCHAR(100)
 Declare @U_BASDUTY  DECIMAL(17,2),@u_cessper   DECIMAL(17,2),@u_Hcessper   DECIMAL(17,2),@u_cessper3   DECIMAL(17,2),@u_Hcesper3   DECIMAL(17,2)
 EXECUTE USP_REP_FILTCON 
 @VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
 ,@VSDATE=@SDATE
 ,@VEDATE=@EDATE
 ,@VSAC =@SAC,@VEAC =@EAC
 ,@VSIT=@SIT,@VEIT=@EIT
 ,@VSAMT=@SAMT,@VEAMT=@EAMT
 ,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
 ,@VSCATE =@SCATE,@VECATE =@ECATE
 ,@VSWARE =@SWARE,@VEWARE  =@EWARE
 ,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
 ,@VMAINFILE='M',@VITFILE=NULL,@VACFILE=NULL
 ,@VDTFLD ='DATE'
 ,@VLYN=NULL
 ,@VEXPARA=@EXPARA
 ,@VFCON =@FCON OUTPUT
 SET @CONFLDS = ''
 --SET @SHOW_EXICSE_AMT =(CASE WHEN @EXPARA LIKE '%<YES>%' THEN 'YES' ELSE 'NO' END)
 SET @CONFLDS =REPLACE(@EXPARA,'<NO>','')
 SET @CONFLDS = REPLACE(@CONFLDS,'<YES>','')
 IF (@EXPARA LIKE '%<NO>%')
	BEGIN
		SET @SQLCOMMAND = ''
		SET @SQLCOMMAND =' SELECT STMAIN.TRAN_CD,STMAIN.AREDESC,STMAIN.U_TIMEP,STMAIN.U_EXPDEL,STMAIN.ARENO,STMAIN.AREDATE,STMAIN.U_EXPBNO '
		SET @SQLCOMMAND =@SQLCOMMAND + ', STMAIN.U_EXBDT,STMAIN.TAX_NAME, STMAIN.U_EXBAMT,STMAIN.U_VEHNO,STMAIN.U_TMODE,STMAIN.U_REMOVDT,STMAIN.U_TIMEP1'
		SET @SQLCOMMAND =@SQLCOMMAND + ',STMAIN.U_CESSAMT,STMAIN.U_CVDAMTA, STMAIN.U_HCESAMT,STMAIN.EXAMT,STMAIN.CTDESC,STMAIN.CTNO,STMAIN.CTDATE,STITEM.DATE'
		SET @SQLCOMMAND =@SQLCOMMAND + ',STITEM.INV_NO,STITEM.U_EXPDESC, STITEM.U_EXPGWT,STITEM.U_EXPMARK,STITEM.QTY,STITEM.GRO_AMT,STITEM.U_BASDUTY '
		SET @SQLCOMMAND =@SQLCOMMAND + ',STITEM.EXAMT AS ITEXAMT,STITEM.U_CESSPER, STITEM.U_CESSAMT AS ITCESSAMT,STITEM.U_HCESSPER,STITEM.U_HCESAMT AS ITHCESAMT '
		SET @SQLCOMMAND =@SQLCOMMAND + ',STITEM.U_CVDPER,  STITEM.U_CVDAMT AS ITCVDAMT,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.RANGE '
		SET @SQLCOMMAND =@SQLCOMMAND + ', AC_MAST.DIVISION,AC_MAST.COLL,AC_MAST.ECCNO,IT_MAST.CHAPNO,IT_MAST.CHAPNO,IT_MAST.IT_NAME,IT_MAST.IT_ALIAS,Stmain.lutno,stmain.lutdt ,stmain.lutvdt   '
		SET @SQLCOMMAND =@SQLCOMMAND + ' FROM STITEM INNER JOIN STMAIN ON (STITEM.TRAN_CD=STMAIN.TRAN_CD) '
		SET @SQLCOMMAND =@SQLCOMMAND + ' INNER JOIN IT_MAST ON (IT_MAST.IT_CODE=STITEM.IT_CODE) '
		SET @SQLCOMMAND =@SQLCOMMAND + ' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID)  '
		SET @SQLCOMMAND =@SQLCOMMAND + ' WHERE (STMAIN.AREDESC=''A.R.E.1'')  '
		SET @SQLCOMMAND =@SQLCOMMAND + '  AND (STMAIN.date  BETWEEN '+ CHAR(39)+CONVERT(VARCHAR(50),@SDATE)+CHAR(39) +' AND ' + CHAR(39)+CONVERT(VARCHAR(50),@EDATE)+CHAR(39) +' )'  + (CASE WHEN  @CONFLDS <> ''  THEN ' AND  ' +@CONFLDS ELSE '' END)
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		PRINT @SQLCOMMAND
	END

 IF (@EXPARA LIKE '%<YES>%')
	BEGIN
	--commented by suraj kumawat for bug-26513 start
--SET @U_BASDUTY = (SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty ='ST' AND pert_name ='U_BASDUTY ' AND att_file=0)
--	SET @u_cessper = (SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty ='ST' AND pert_name ='U_CESSPER'  AND att_file=0) 
--	SET @u_Hcessper = (SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty ='ST' AND pert_name ='U_HCESSPER' AND att_file=0)
 --commented by suraj kumawat for bug-26513 start
	SET @u_cessper3= 0
	SET @u_Hcesper3= 0
		SET @SQLCOMMAND = ''
		SET @SQLCOMMAND =' SELECT STMAIN.TRAN_CD,STMAIN.AREDESC,STMAIN.U_TIMEP,STMAIN.U_EXPDEL,STMAIN.ARENO,STMAIN.AREDATE,STMAIN.U_EXPBNO '
		SET @SQLCOMMAND =@SQLCOMMAND + ', STMAIN.U_EXBDT,STMAIN.TAX_NAME, STMAIN.U_EXBAMT,STMAIN.U_VEHNO,STMAIN.U_TMODE,STMAIN.U_REMOVDT,STMAIN.U_TIMEP1'
		SET @SQLCOMMAND =@SQLCOMMAND + ',STMAIN.U_CESSAMT,STMAIN.U_CVDAMTA, STMAIN.U_HCESAMT,STMAIN.EXAMT,STMAIN.CTDESC,STMAIN.CTNO,STMAIN.CTDATE,STITEM.DATE'
		SET @SQLCOMMAND =@SQLCOMMAND + ',STITEM.INV_NO,STITEM.U_EXPDESC, STITEM.U_EXPGWT,STITEM.U_EXPMARK,STITEM.QTY,STITEM.GRO_AMT,U_BASDUTY=(SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty =''ST'' AND pert_name =''U_BASDUTY '' AND att_file=0) '
		SET @SQLCOMMAND =@SQLCOMMAND + ',ROUND((CASE WHEN STITEM.u_asseamt <> 0 THEN (STITEM.u_asseamt * (SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty =''ST'' AND pert_name =''U_BASDUTY '' AND att_file=0)/100 ) ELSE 0 END),17,2)  AS ITEXAMT '
		SET @SQLCOMMAND =@SQLCOMMAND + ',U_CESSPER= 0 '   --(SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty =''ST'' AND pert_name =''U_CESSPER''  AND att_file=0)' -- commented by suraj kumawat for bug-26513
		SET @SQLCOMMAND =@SQLCOMMAND + ', ITCESSAMT = 0 ' --(ROUND((CASE WHEN STITEM.u_asseamt <> 0 THEN (STITEM.u_asseamt * (SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty =''ST'' AND pert_name =''U_BASDUTY '' AND att_file=0)/100 ) ELSE 0 END),17,2) * (SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty =''ST'' AND pert_name =''U_CESSPER''  AND att_file=0)/100) AS ITCESSAMT ' -- commented by suraj kumawat for bug-26513
		SET @SQLCOMMAND =@SQLCOMMAND + ',U_HCESSPER= 0 '  --(SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty =''ST'' AND pert_name =''U_HCESSPER'' AND att_file=0)'
		SET @SQLCOMMAND =@SQLCOMMAND + ',ITHCESAMT= 0 ' --(ROUND((CASE WHEN STITEM.u_asseamt <> 0 THEN (STITEM.u_asseamt * (SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty =''ST'' AND pert_name =''U_BASDUTY '' AND att_file=0)/100 ) ELSE 0 END),17,2) * (SELECT ISNULL(DEF_PERT,0) FROM DCMAST WHERE Entry_ty =''ST'' AND pert_name =''U_HCESSPER'' AND att_file=0)/100) ' -- commented by suraj kumawat for bug-26513
		SET @SQLCOMMAND =@SQLCOMMAND + ',STITEM.U_CVDPER,  STITEM.U_CVDAMT AS ITCVDAMT,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.RANGE '
		SET @SQLCOMMAND =@SQLCOMMAND + ', AC_MAST.DIVISION,AC_MAST.COLL,AC_MAST.ECCNO,IT_MAST.CHAPNO,IT_MAST.CHAPNO,IT_MAST.IT_NAME,IT_MAST.IT_ALIAS,Stmain.lutno,stmain.lutdt ,stmain.lutvdt   '
		SET @SQLCOMMAND =@SQLCOMMAND + ' FROM STITEM INNER JOIN STMAIN ON (STITEM.TRAN_CD=STMAIN.TRAN_CD) '
		SET @SQLCOMMAND =@SQLCOMMAND + ' INNER JOIN IT_MAST ON (IT_MAST.IT_CODE=STITEM.IT_CODE) '
		SET @SQLCOMMAND =@SQLCOMMAND + ' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID)  '
		SET @SQLCOMMAND =@SQLCOMMAND + ' WHERE (STMAIN.AREDESC=''A.R.E.1'')  '
		SET @SQLCOMMAND =@SQLCOMMAND + '  AND ( STMAIN.date  BETWEEN '+ CHAR(39)+CONVERT(VARCHAR(50),@SDATE)+CHAR(39) +' AND ' + CHAR(39)+CONVERT(VARCHAR(50),@EDATE)+CHAR(39) +' ) '  + (CASE WHEN @CONFLDS <> '' THEN ' AND  ' +@CONFLDS ELSE '' END)
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		PRINT @SQLCOMMAND
	END
 END
