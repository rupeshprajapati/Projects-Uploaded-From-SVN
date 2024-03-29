set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Excise Duty Available Report.
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================

ALTER PROCEDURE  [dbo].[USP_REP_PTSTAX3]
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
select a.entry_ty,mon=month(a.date),yearr=year(a.date),monthh=datename(mm,a.date),a.date,a.inv_no,a.gro_amt,a.tot_deduc,a.tot_tax,a.tot_examt,a.tot_add,a.tax_name,a.taxamt,a.u_pinvno,a.tot_nontax,a.tot_fdisc,a.net_amt ,srno='a' 
,tot_qty=sum(b.qty),a.examt,a.u_cessamt,a.u_hcesamt
into #ptstax 
from ptmain a 
inner join ptitem b on (a.tran_cd=b.tran_cd)
where a.tax_name<>' ' and a.date between @sdate and @edate
group by a.entry_ty,a.date,a.inv_no,a.gro_amt,a.tot_deduc,a.tot_tax,a.tot_examt,a.tot_add,a.tax_name,a.taxamt,a.tot_nontax,a.tot_fdisc,a.net_amt,a.examt,a.u_cessamt,a.u_hcesamt,a.u_pinvno
--union 
--select a.entry_ty,mon=month(a.date),yearr=year(a.date),monthh=datename(mm,a.date),a.date,a.inv_no,a.gro_amt,a.tot_deduc,a.tot_tax,a.tot_examt,a.tot_add,a.tax_name,a.taxamt,a.tot_nontax,a.tot_fdisc,a.net_amt ,srno='b' 
--,tot_qty=sum(b.qty),a.examt,a.u_cessamt,a.u_hcesamt
--from prmain a
--inner join pritem b on (a.tran_cd=b.tran_cd)
--where a.tax_name<>' ' and a.date between @sdate and @edate
--group by a.entry_ty,a.date,a.inv_no,a.gro_amt,a.tot_deduc,a.tot_tax,a.tot_examt,a.tot_add,a.tax_name,a.taxamt,a.tot_nontax,a.tot_fdisc,a.net_amt,a.examt,a.u_cessamt,a.u_hcesamt

select * from #ptstax order by yearr,mon,tax_name,srno,date


