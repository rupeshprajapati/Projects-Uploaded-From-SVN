set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
 -- Author:  Hetal L. Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate TN CAPI ANNX 
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
ALTER PROCEDURE [dbo].[USP_REP_TN_VAT_ANNEXURE_TO_CAPITAL_GOODS] 
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
,@VSDATE=@SDATE
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='m',@VITFILE='',@VACFILE='ac'
,@VDTFLD ='DATE'
,@VLYN=@LYN
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(1000)

declare @fld_list NVARCHAR(2000)
execute usp_rep_Taxable_Amount_Itemwise 'PT','i',@fld_list =@fld_list OUTPUT
set @fld_list=rtrim(@fld_list)

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		Set @MultiCo = 'YES'
		SET @SQLCOMMAND=' select  m.entry_ty,m.tran_cd,m.date'
		set @sqlcommand=@sqlcommand+' '+',gro_amt=sum(i.qty*i.rate'+@fld_list+')'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',st.tax_name,st.level1,vatpaid=sum(case when ac_mast.typ='+'''Input Vat'''+' and amt_ty='+'''dr'''+' then amount else 0 end)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,vatpayable=sum(case when ac_mast.typ='+'''Input Vat Payable'''+' and amt_ty='+'''dr'''+' then amount else 0 end)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,pdate=dateadd(yyyy,3,m.date)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' from ptacdet ac'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join ptmain m on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd And m.dbname = ac.dbname)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join ptitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd And m.dbname = i.dbname)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join stax_mas st on (m.tax_name=st.tax_name And m.dbname = st.dbname)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join ac_mast on (ac_mast.ac_id=ac.ac_id And ac_mast.dbname = ac.dbname)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join it_mast on (it_mast.it_code=i.it_code And it_mast.dbname = i.dbname)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' and ac_mast.typ in('+'''Input Vat Payable'''+','+'''Input Vat'''+') and amt_ty='+'''dr'''
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' and ac_mast.typ in('+'''Input Vat Payable'''+','+'''Input Vat'''+') and amt_ty='+'''dr'''
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' and it_mast.type in('+'''Machinery/Stores'''+') and amt_ty='+'''dr'''
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' and st.set_app=1'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' group by m.entry_ty,m.tran_cd,m.date,m.gro_amt,st.tax_name,st.level1'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ORDER BY m.tran_cd '
	End
Else
	Begin	------Fetch Records from Single Co. Data
		Set @MultiCo = 'NO'
		SET @SQLCOMMAND=' Select  m.entry_ty,m.tran_cd,m.date'
		set @sqlcommand=@sqlcommand+' '+',gro_amt=sum(i.qty*i.rate'+@fld_list+')'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',st.tax_name,st.level1,vatpaid=sum(case when ac_mast.typ='+'''Input Vat'''+' and amt_ty='+'''dr'''+' then amount else 0 end)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,vatpayable=sum(case when ac_mast.typ='+'''Input Vat Payable'''+' and amt_ty='+'''dr'''+' then amount else 0 end)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,pdate=dateadd(yyyy,3,m.date)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' from ptacdet ac'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join ptmain m on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join ptitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join stax_mas st on (m.tax_name=st.tax_name)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join ac_mast on (ac_mast.ac_id=ac.ac_id)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join it_mast on (it_mast.it_code=i.it_code)'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' and ac_mast.typ in('+'''Input Vat Payable'''+','+'''Input Vat'''+') and amt_ty='+'''dr'''
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' and ac_mast.typ in('+'''Input Vat Payable'''+','+'''Input Vat'''+') and amt_ty='+'''dr'''
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' and it_mast.type in('+'''Machinery/Stores'''+') and amt_ty='+'''dr'''
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' and st.set_app=1'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' group by m.entry_ty,m.tran_cd,m.date,m.gro_amt,st.tax_name,st.level1'
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ORDER BY m.tran_cd '
	End


--print @SQLCOMMAND
EXEC SP_EXECUTESQL  @SQLCOMMAND
--Print 'RJ VAT FORM 01 ANNEXURE TO CAPITAL'

