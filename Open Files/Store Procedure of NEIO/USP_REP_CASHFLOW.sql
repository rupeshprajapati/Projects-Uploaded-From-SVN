DROP PROCEDURE [USP_REP_CASHFLOW]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 10/01/2009
-- Description:	This Stored procedure is useful to generate Accounts Cash Flow Report.
-- Modify date: 13/06/12 
-- Modified By: Sandeep 
-- Remark:      Changes done for the bug-4311
-- Modify date: 
-- Remark:
-- =============================================
create PROCEDURE [USP_REP_CASHFLOW] 
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
Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)
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
,@VMAINFILE='M',@VITFILE=NULL,@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

declare @sqlcommand nvarchar(4000)
select Mnth=99,Yr=9999,a.ac_name,ac.ac_id
,[Inflow]=ac.amount
,[Outflow]=ac.amount
,[NettFlow]=ac.amount
into #cashflow
from lac_vw ac 
inner join ac_mast a on (a.ac_id=ac.ac_id) 
where 1=2

set @sqlcommand='insert into #cashflow '
set @sqlcommand=rtrim(@sqlcommand)+' '+' select Month=month(ac.date),Year=year(ac.date),ac_mast.ac_name,ac.ac_id '
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,sum(case when ac1.amt_ty='+'''CR'''+' then ac1.amount else 0 end) as [Inflow]'
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,sum(case when ac1.amt_ty='+'''DR'''+' then ac1.amount else 0 end) as [Outflow]'
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,sum(case when ac1.amt_ty='+'''CR'''+' then ac1.amount else 0 end)-sum(case when ac1.amt_ty='+'''DR'''+' then ac1.amount else 0 end) as [Nett Flow]'
set @sqlcommand=rtrim(@sqlcommand)+' '+' from lac_vw ac '
set @sqlcommand=rtrim(@sqlcommand)+' '+' inner join lmain_vw m on (ac.entry_ty=m.entry_ty and ac.tran_cd=m.tran_cd) '
set @sqlcommand=rtrim(@sqlcommand)+' '+' inner join ac_mast on (ac_mast.ac_id=ac.ac_id)' 
set @sqlcommand=rtrim(@sqlcommand)+' '+' inner join lac_vw ac1 on (ac1.entry_ty=ac.entry_ty and ac.tran_cd=ac1.tran_cd) '
set @sqlcommand=rtrim(@sqlcommand)+' '+' inner join ac_mast a1 on (a1.ac_id=ac1.ac_id) '
set @sqlcommand=rtrim(@sqlcommand)+' '+@fcon
set @sqlcommand=rtrim(@sqlcommand)+' '+' and ac_mast.typ in ('+'''CASH'''+','+'''BANK'''+')  and a1.typ not in ('+'''CASH'''+','+'''BANK'''+')'
set @sqlcommand=rtrim(@sqlcommand)+' '+' and ac.ac_id<>ac1.ac_id and m.entry_ty<>''CO''' -- Changes by sandeep for BUG-4311 
set @sqlcommand=rtrim(@sqlcommand)+' '+' group by month(ac.date),year(ac.date),ac_mast.ac_name,ac.ac_id'
print @sqlcommand
execute sp_executesql @sqlcommand
select yr,mnth,ac_id,ac_name,inflow,outflow
,nettflow=nettflow*(case when nettflow<0 then -1 else 1 end)
,net_typ=(case when nettflow<0 then 'Cr' else 'Dr' end)
from #cashflow order by yr,mnth,ac_name
GO
