DROP PROCEDURE [USP_REP_PARTYWISE_GOODS_RECEIPTS_REGISTER]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE  [USP_REP_PARTYWISE_GOODS_RECEIPTS_REGISTER]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= NULL
AS

DECLARE @FCON AS NVARCHAR(2000)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE='I',@VACFILE='AC'
,@VDTFLD ='date'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT


DECLARE @SQLCOMMAND NVARCHAR(4000)
PRINT @FCON
SET @SQLCOMMAND='Select M.Party_nm as [Party Name],m.tran_cd,M.Date,M.inv_no as [Invoice No.]' --,M.u_pono as [Order No.]'
--SET @SQLCOMMAND=@SQLCOMMAND+' '+',(case when year(M.u_podt)<=1900 then null else M.u_podt end) as [PO Date],M.u_lrno as [LR No.]'
--SET @SQLCOMMAND=@SQLCOMMAND+' '+',(case when year(M.u_lrdt)<=1900 then null else M.u_lrdt end) as [LR Date],M.gro_amt as [Gross Amount]'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',M.gro_amt as [Gross Amount],M.tot_deduc as [Deduction],m.tot_tax as [Taxable Charges]'
--SET @SQLCOMMAND=@SQLCOMMAND+' '+',m.u_cessamt as [CessAmt],m.u_hcesamt as [S&H Cess] '
SET @SQLCOMMAND=@SQLCOMMAND+' '+',M.tot_add as [Additional Charges]'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',M.tot_nontax as [Non-Taxable Charges],M.tot_fdisc as [Final Discount]'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',m.net_amt as [Net Amount],M.Salesman,M.[rule] as [Rule],M.cate As [Category]'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',M.dept as [Department],M.inv_sr as [Invoice Series]' --,M.u_choice As [Diff. Rate Inv.]'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',M.tran_cd,M.entry_ty,m.ac_id,M.cgst_amt,M.sgst_amt,M.igst_amt'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',it.it_name as [Item Description] ,it.[group] as [Group],i.Qty ,it.Rateper ,it.RateUnit as [Unit],it.hsncode as [HSN Code.],i.Rate, (i.Qty*i.rate) as [Amount],i.ware_nm as [Warehouse],it.Type     '
SET @SQLCOMMAND=@SQLCOMMAND+' '+',(case when AC.amt_ty=''DR'' then AC.amount else 0 end) as [Debit Amount],(case when AC.amt_ty=''CR'' then AC.amount else 0 end) as [Credit Amount],AC.Narr as [Narration],AC.amt_ty,AC.entry_ty as [Transaction Type]'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',ac.acserial,i.itserial,ac.ac_name,i.u_asseamt,i.cgsrt_amt,i.sgsrt_amt,i.igsrt_amt'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'FROM ARMAIN m'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'inner join ARITEM i ON (i.tran_cd=m.tran_Cd and i.entry_ty=m.entry_ty)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'INNER JOIN AC_MAST ON (AC_MAST.AC_ID=m.AC_ID)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'inner join it_mast it on (i.it_code=it.it_code)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'Left join ARacdet ac on (m.tran_cd=ac.tran_cd and m.entry_ty=ac.entry_ty)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+@FCON
SET @SQLCOMMAND=@SQLCOMMAND+' '+'ORDER BY M.Date,m.tran_cd'
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
