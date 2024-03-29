If Exists(Select [Name] from Sysobjects where xType='P' and Id=Object_Id(N'USP_REP_PTPTAX'))
Begin
	Drop Procedure USP_REP_PTPTAX
end 
go 

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go



-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Excise Duty Available Report.
-- Modify date: 16/05/2007
-- Modified By: sandeephah
-- Modify date: 01/03/2011
-- Remark:      Add Expenses Purchases Transaction for TKT-6204  
-- Modified By: sandeephah
-- Modify date: 10/11/2011
-- Remark:      add Ambiguous column name for Bug-407 
-- Modified by/date/remark : sandeep - 03/11/12 - bug-7217
-- Modified By: 
-- Modify date: 
-- Remark:      

-- =============================================

CREATE PROCEDURE [dbo].[USP_REP_PTPTAX]
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


----Changed by Sandeep for  bug-7217-- S
DECLARE @vatfltopt VARCHAR(25)
select @vatfltopt=vat_flt_opt from manufact
print @vatfltopt
----Changed by Sandeep for  bug-7217-- E

Select BHent=(CASE WHEN EXT_VOU=1 THEN BCODE_NM ELSE ENTRY_TY END),Entry_ty,Code_nm Into #L from Lcode Order by BHent

Select a.Entry_ty,a.Tran_cd,tot_deduc=sum(a.tot_deduc),tot_tax=sum(a.tot_tax)
,tot_add=sum(a.tot_add),tot_nontax=sum(a.tot_nontax),tot_fdisc=sum(a.tot_fdisc),u_asseamt=sum(a.qty * a.Rate)
Into #ptstax2 from ptitem a inner join ptmain b on a.tran_cd=b.tran_cd and a.entry_Ty=b.entry_ty
--where a.tax_name<>' ' and a.date between @sdate and @edate --commented by Sandeep for  bug-7217
where a.tax_name<>' ' and  case when (@vatfltopt)='Bill Date      ' then b.U_PINVDT else a.date end  between @sdate and @edate
group by a.Entry_ty,a.Tran_cd
Union all
Select a.Entry_ty,a.Tran_cd,tot_deduc=sum(a.tot_deduc),tot_tax=sum(a.tot_tax)
,tot_add=sum(a.tot_add),tot_nontax=sum(a.tot_nontax),tot_fdisc=sum(a.tot_fdisc),u_asseamt=sum(a.qty * a.Rate)
from pritem a inner join prmain b on a.tran_cd=b.tran_cd and a.entry_Ty=b.entry_ty
--where a.tax_name<>' ' and a.date between @sdate and @edate ---add Ambiguous column name for Bug-407 ----commented by Sandeep for  bug-7217
where a.tax_name<>' ' and  case when (@vatfltopt)='Bill Date      ' then b.U_PINVDT else a.date end  between @sdate and @edate --change by Sandeep for  bug-7217
Group by a.Entry_ty,a.Tran_cd
Union all
Select a.Entry_ty,a.Tran_cd,tot_deduc=sum(a.tot_deduc),tot_tax=sum(a.tot_tax)
,tot_add=sum(a.tot_add),tot_nontax=sum(a.tot_nontax),tot_fdisc=sum(a.tot_fdisc),u_asseamt=sum(a.qty * a.Rate)
from epitem a inner join epmain b on a.tran_cd=b.tran_cd and a.entry_Ty=b.entry_ty
--where a.tax_name<>' ' and a.date between @sdate and @edate --add Ambiguous column name for Bug-407 --commented by Sandeep for  bug-7217 ----commented by Sandeep for  bug-7217
where a.tax_name<>' ' and  case when (@vatfltopt)='Bill Date      ' then b.U_PINVDT else a.date end  between @sdate and @edate
Group by a.Entry_ty,a.Tran_cd


--select a.tran_cd,a.entry_ty,mon=month(a.date),yearr=year(a.date),monthh=datename(mm,a.date) --commented by Sandeep for  bug-7217
select a.tran_cd,a.entry_ty,mon=month(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end ),yearr=year(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end ),monthh=datename(mm,case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end )--change by Sandeep for  bug-7217
,a.date,a.inv_no,a.gro_amt,tot_deduc=a.tot_deduc+abs(b.tot_deduc),tot_tax=a.tot_tax+b.tot_tax
,a.tot_examt,tot_add=a.tot_add+b.tot_add,a.tax_name,a.taxamt
,tot_nontax=a.tot_nontax+b.tot_nontax,tot_fdisc=a.tot_fdisc+abs(b.tot_fdisc),a.net_amt 
,b.u_asseamt
,Net_amt2=b.u_asseamt-(a.tot_deduc+abs(b.tot_deduc))+(a.tot_tax+b.tot_tax)+a.tot_examt
		+a.taxamt+(a.tot_add+b.tot_add)+(a.tot_nontax+b.tot_nontax)-(a.tot_fdisc+abs(b.tot_fdisc))
,srno='a' ,ac.vend_type into #ptstax 
from ptmain a 
left Join #ptstax2 b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)
Inner Join ac_mast ac on (ac.ac_id=a.ac_id)
--where A.tax_name<>' ' and date between @sdate and @edate ----commented by Sandeep for  bug-7217
where a.tax_name<>' ' and  case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT  else  a.date end  between @sdate and @edate --change by Sandeep for  bug-7217
union 

--select a.tran_cd,a.entry_ty,mon=month(a.date),yearr=year(a.date),monthh=datename(mm,a.date) --commented by Sandeep for  bug-7217
select a.tran_cd,a.entry_ty,mon=month(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end ),yearr=year(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end ),monthh=datename(mm,case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end )--change by Sandeep for  bug-7217
,a.date,a.inv_no,a.gro_amt,tot_deduc=a.tot_deduc+abs(b.tot_deduc),tot_tax=a.tot_tax+b.tot_tax
,a.tot_examt,tot_add=a.tot_add+b.tot_add,a.tax_name,a.taxamt
,tot_nontax=a.tot_nontax+b.tot_nontax,tot_fdisc=a.tot_fdisc+abs(b.tot_fdisc),a.net_amt 
,b.u_asseamt
,Net_amt2=b.u_asseamt-(a.tot_deduc+b.tot_deduc)+(a.tot_tax+b.tot_tax)+a.tot_examt
		+a.taxamt+(a.tot_add+b.tot_add)+(a.tot_nontax+b.tot_nontax)-(a.tot_fdisc+abs(b.tot_fdisc))
,srno='b' ,ac.vend_type
from Prmain a
left Join #ptstax2 b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)
Inner Join ac_mast ac on (ac.ac_id=a.ac_id)
--where a.tax_name<>' ' and date between @sdate and @edate ----commented by Sandeep for  bug-7217
where a.tax_name<>' ' and  case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT  else  a.date end  between @sdate and @edate --change by Sandeep for  bug-7217
union 
--select a.tran_cd,a.entry_ty,mon=month(a.date),yearr=year(a.date),monthh=datename(mm,a.date) --commented by Sandeep for  bug-7217
select a.tran_cd,a.entry_ty,mon=month(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end ),yearr=year(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end ),monthh=datename(mm,case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end )--change by Sandeep for  bug-7217
,a.date,a.inv_no,a.gro_amt,tot_deduc=a.tot_deduc+abs(b.tot_deduc),tot_tax=a.tot_tax+b.tot_tax
,a.tot_examt,tot_add=a.tot_add+b.tot_add,a.tax_name,a.taxamt
,tot_nontax=a.tot_nontax+b.tot_nontax,tot_fdisc=a.tot_fdisc+abs(b.tot_fdisc),a.net_amt 
,b.u_asseamt
,Net_amt2=b.u_asseamt-(a.tot_deduc+abs(b.tot_deduc))+(a.tot_tax+b.tot_tax)+a.tot_examt
		+a.taxamt+(a.tot_add+b.tot_add)+(a.tot_nontax+b.tot_nontax)-(a.tot_fdisc+abs(b.tot_fdisc))
,srno='c' ,ac.vend_type
from epmain a
left Join #ptstax2 b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)
Inner Join ac_mast ac on (ac.ac_id=a.ac_id)
--where a.tax_name<>' ' and date between @sdate and @edate----commented by Sandeep for  bug-7217
where a.tax_name<>' ' and  case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT  else  a.date end  between @sdate and @edate --change by Sandeep for  bug-7217
alter table #ptstax add duty_add bit
Update #ptstax set duty_add=Case when Net_amt=Net_amt2 then 1 else 0 End


select * from #ptstax order by yearr,mon,tax_name,srno,date

Drop table #ptstax
Drop table #ptstax2












