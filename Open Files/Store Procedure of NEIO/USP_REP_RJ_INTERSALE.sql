set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



/*
EXECUTE USP_REP_RJ_INTERSALE'','','','04/01/2008','03/31/2010','','','','',0,0,'','','','','','','','','2009-2010',''
*/

-- =============================================
-- Author:		Hetal L Patel
-- Create date: 01/06/2009
-- Description:	This Stored procedure is useful to generate Scrap Sales (VAT) Report.
-- Modified By: Dinesh
-- Modify date: 09/06/2009
-- Remark: 
-- =============================================
ALTER PROCEDURE [dbo].[USP_REP_RJ_INTERSALE] 
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

Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL
 ,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='STMAIN',@VITFILE='STITEM',@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000), @VCOND NVARCHAR(2000)

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		Set @MultiCo = 'YES'
		SET @SQLCOMMAND='SELECT STMAIN.ENTRY_TY,STMAIN.TRAN_CD,STMAIN.INV_NO,STMAIN.DATE,STMAIN.PARTY_NM,'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'AC_MAST.S_TAX,AC_MAST.CITY,STITEM.ITEM,TAX.TAX_NAME,TAX.[Level1],'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'TAXABLE=(STITEM.U_ASSEAMT+ISNULL(STITEM.TOT_EXAMT,0)+ISNULL(STITEM.TOT_TAX,0)+ISNULL(STITEM.TOT_ADD,0)-ISNULL(STITEM.TOT_DEDUC,0)),'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'STITEM.TAXAMT,STITEM.GRO_AMT,STMAIN.NET_AMT '
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'FROM STMAIN '
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD AND STMAIN.DBNAME=STITEM.DBNAME)'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'INNER JOIN STAX_MAS TAX ON (TAX.TAX_NAME=STITEM.TAX_NAME AND TAX.DBNAME=STITEM.DBNAME)'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'INNER JOIN AC_MAST ON (STMAIN.AC_ID=AC_MAST.AC_ID AND STMAIN.DBNAME=AC_MAST.DBNAME)'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+@FCON
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'AND STMAIN.ENTRY_TY=''ST'' AND (TAX.ENTRY_TY=''ST'' AND TAX.ST_TYPE=''OUT OF STATE'') '
	End
Else
	Begin	------Fetch Records from Single Co. Data
		Set @MultiCo = 'NO'
		SET @SQLCOMMAND='SELECT STMAIN.ENTRY_TY,STMAIN.TRAN_CD,STMAIN.INV_NO,STMAIN.DATE,STMAIN.PARTY_NM,'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'AC_MAST.S_TAX,AC_MAST.CITY,STITEM.ITEM,TAX.TAX_NAME,TAX.[Level1],'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'TAXABLE=(STITEM.U_ASSEAMT+ISNULL(STITEM.TOT_EXAMT,0)+ISNULL(STITEM.TOT_TAX,0)+ISNULL(STITEM.TOT_ADD,0)-ISNULL(STITEM.TOT_DEDUC,0)),'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'STITEM.TAXAMT,STITEM.GRO_AMT,STMAIN.NET_AMT '
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'FROM STMAIN '
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD)'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'INNER JOIN STAX_MAS TAX ON (TAX.TAX_NAME=STITEM.TAX_NAME)'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'INNER JOIN AC_MAST ON (STMAIN.AC_ID=AC_MAST.AC_ID)'
		SET @SQLCOMMAND=@SQLCOMMAND+' '+@FCON
		SET @SQLCOMMAND=@SQLCOMMAND+' '+'AND STMAIN.ENTRY_TY=''ST'' AND (TAX.ENTRY_TY=''ST'' AND TAX.ST_TYPE=''OUT OF STATE'') '
	End

PRINT  @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

set ANSI_NULLS OFF
set QUOTED_IDENTIFIER OFF



