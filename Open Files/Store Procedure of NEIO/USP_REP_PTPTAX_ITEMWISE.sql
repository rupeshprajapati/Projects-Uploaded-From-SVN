If Exists(Select [Name] from Sysobjects where xType='P' and Id=Object_Id(N'USP_REP_PTPTAX_ITEMWISE'))
Begin
	Drop Procedure USP_REP_PTPTAX_ITEMWISE
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
-- Modified By: Hetal Patel
-- Modify date: 11/09/2009
-- Modified by : Shrikant S. on 09 Apr, 2010
-- Modified by/date/remark : sandeep - 03/11/12 - bug-7217
-- Remark:
-- =============================================

CREATE PROCEDURE [dbo].[USP_REP_PTPTAX_ITEMWISE]
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

---select entry_ty,mon=month(date),yearr=year(date),monthh=datename(mm,date),date,ac_mast.ac_name,inv_no,gro_amt,tot_deduc,tot_tax,tot_examt,tot_add,tax_name,taxamt,tot_nontax,tot_fdisc,net_amt ,srno='a' into #ptstax from ptmain inner join ac_mast on (ac_mast.ac_id=ptmain.ac_id) where tax_name<>' ' and date between @sdate and @edate
----Changed by Sandeep for  bug-7217-- S
DECLARE @vatfltopt VARCHAR(25)
select @vatfltopt=vat_flt_opt from manufact
print @vatfltopt
----Changed by Sandeep for  bug-7217-- E

Select BHent=(CASE WHEN EXT_VOU=1 THEN BCODE_NM ELSE ENTRY_TY END),Entry_ty,Code_nm Into #L from Lcode Order by BHent

/* Calculating the ratio */ 
Select a.Entry_ty,a.tran_cd,Netratio=1/sum(b.qty * b.rate) 
Into #Netamtcal From Lmain_vw a Inner Join Litem_vw b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.Tran_cd) 
Inner join #L c on (a.entry_ty=c.Entry_ty)
Where c.bhent In ('PT','PR','EP') and b.tax_name<>' ' 
and  case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end  between @sdate and @edate --Changed by sandeep. for bug-7217
--and a.date between @sdate and @edate commented by sandeep. for bug-7217
Group by a.Entry_ty,a.tran_cd,a.net_amt,a.taxamt,c.bhent,c.Entry_ty


/* Calculating the voucherwise taxes & charges for itemwise */ 
Select a.Entry_ty,a.Tran_cd,b.itserial
--,mon=month(a.date),yearr=year(a.date),monthh=datename(mm,a.date),a.date,a.inv_no,b.gro_amt commented by sandeep. for bug-7217
,mon=month(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end),yearr=year(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end),monthh=datename(mm,case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end),a.date,a.inv_no,b.gro_amt --change by sandeep - 03/11/12 - bug-7217
,mtot_deduc=a.tot_deduc,mtot_tax=a.tot_tax,mtot_add=a.tot_add,mtot_nontax=a.tot_nontax,mtot_fdisc=a.tot_fdisc  
,itot_deduc=abs(b.tot_deduc),itot_tax=b.tot_tax,itot_add=b.tot_add,itot_nontax=b.tot_nontax,itot_fdisc=abs(b.tot_fdisc  )
,tot_deduc=round(a.tot_deduc * (b.qty * b.rate) * c.Netratio,2)
,tot_tax=round(a.tot_tax * (b.qty * b.rate) * c.Netratio,2)
,tot_add=round(a.tot_add * (b.qty * b.rate) * c.Netratio,2)
,tot_nontax=round(a.tot_nontax * (b.qty * b.rate) * c.Netratio,2)
,tot_fdisc=round(a.tot_fdisc * (b.qty * b.rate) * c.Netratio,2)
,tot_examt=b.examt+b.u_cessamt+b.u_hcesamt+b.u_cvdamt,b.tax_name,b.taxamt,Net_amt=b.qty * b.rate,Net_amt2=b.qty * b.rate,u_asseamt=b.qty * b.rate,srno='a'
,ac.vend_type
Into #ptstax From ptmain a
Inner Join ptitem b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.Tran_cd) 
Inner Join ac_mast ac on (ac.ac_id=a.ac_id)
Inner Join #Netamtcal c on (a.Entry_ty = c.Entry_ty and a.Tran_cd = c.Tran_cd)
Where b.tax_name<>' '
--and a.date between @sdate and @edate --commented by sandeep. for bug-7217
and  case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end  between @sdate and @edate --Changed by sandeep. for bug-7217
Union all
Select a.Entry_ty,a.Tran_cd,b.itserial
--,mon=month(a.date),yearr=year(a.date),monthh=datename(mm,a.date),a.date,a.inv_no,b.gro_amt  --commented by sandeep. for bug-7217
,mon=month(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end),yearr=year(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end),monthh=datename(mm,case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end),a.date,a.inv_no,b.gro_amt --change by sandeep - 03/11/12 - bug-7217
,mtot_deduc=a.tot_deduc,mtot_tax=a.tot_tax,mtot_add=a.tot_add,mtot_nontax=a.tot_nontax,mtot_fdisc=a.tot_fdisc  
,itot_deduc=abs(b.tot_deduc),itot_tax=b.tot_tax,itot_add=b.tot_add,itot_nontax=b.tot_nontax,itot_fdisc=abs(b.tot_fdisc)
,tot_deduc=round(a.tot_deduc * (b.qty * b.rate) * c.Netratio,2)
,tot_tax=round(a.tot_tax * (b.qty * b.rate) * c.Netratio,2)
,tot_add=round(a.tot_add * (b.qty * b.rate) * c.Netratio,2)
,tot_nontax=round(a.tot_nontax * (b.qty * b.rate) * c.Netratio,2)
,tot_fdisc=round(a.tot_fdisc * (b.qty * b.rate) * c.Netratio,2)
,tot_examt=b.examt+b.u_cessamt+b.u_hcesamt+b.u_cvdamt,b.tax_name,b.taxamt,Net_amt=b.qty * b.rate,Net_amt2=b.qty * b.rate,u_asseamt=b.qty * b.rate,srno='b'
,ac.vend_type
From prmain a
Inner Join pritem b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.Tran_cd) 
Inner Join ac_mast ac on (ac.ac_id=a.ac_id)
Inner Join #Netamtcal c on (a.Entry_ty = c.Entry_ty and a.Tran_cd = c.Tran_cd)
Where b.tax_name<>' '
--and a.date between @sdate and @edate --commented by sandeep. for bug-7217
and  case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end  between @sdate and @edate --Changed by sandeep. for bug-7217
Union all
Select a.Entry_ty,a.Tran_cd,b.itserial
,mon=month(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end),yearr=year(case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end),monthh=datename(mm,case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end),a.date,a.inv_no,b.gro_amt --change by sandeep - 03/11/12 - bug-7217
,mtot_deduc=a.tot_deduc,mtot_tax=a.tot_tax,mtot_add=a.tot_add,mtot_nontax=a.tot_nontax,mtot_fdisc=a.tot_fdisc  
,itot_deduc=abs(b.tot_deduc),itot_tax=b.tot_tax,itot_add=b.tot_add,itot_nontax=b.tot_nontax,itot_fdisc=abs(b.tot_fdisc)  
,tot_deduc=round(a.tot_deduc * (b.qty * b.rate) * c.Netratio,2)
,tot_tax=round(a.tot_tax * (b.qty * b.rate) * c.Netratio,2)
,tot_add=round(a.tot_add * (b.qty * b.rate) * c.Netratio,2)
,tot_nontax=round(a.tot_nontax * (b.qty * b.rate) * c.Netratio,2)
,tot_fdisc=round(a.tot_fdisc * (b.qty * b.rate) * c.Netratio,2)
,tot_examt=b.examt+b.u_cessamt+b.u_hcesamt+b.u_cvdamt,b.tax_name,b.taxamt,Net_amt=b.qty * b.rate,Net_amt2=b.qty * b.rate,u_asseamt=b.qty * b.rate,srno='c'
,ac.vend_type
From epmain a
Inner Join epitem b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.Tran_cd) 
Inner Join ac_mast ac on (ac.ac_id=a.ac_id)
Inner Join #Netamtcal c on (a.Entry_ty = c.Entry_ty and a.Tran_cd = c.Tran_cd)
Where b.tax_name<>' '
--and a.date between @sdate and @edate --commented by sandeep. for bug-7217
and  case when (@vatfltopt)='Bill Date      ' then a.U_PINVDT else a.date end  between @sdate and @edate --Changed by sandeep. for bug-7217
/* Calculating the sum of taxes & charges except 1st item */
Select a.Entry_ty,a.Tran_cd,tot_deduc=sum(tot_deduc),tot_tax=sum(tot_tax),tot_add=sum(tot_add),tot_nontax=sum(tot_nontax)
,tot_fdisc=sum(tot_fdisc) Into #ptstax2 from #ptstax a
inner join (Select entry_ty,tran_cd,itserial=min(itserial) from #ptstax group by entry_ty,tran_cd) c 
on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd and a.itserial!=c.itserial)
Group by a.Entry_ty,a.Tran_cd


/* Updating the 1st item -taxes & charges */
Update #ptstax set tot_deduc=(a.mtot_deduc-b.tot_deduc)
,tot_tax=(a.mtot_tax-b.tot_tax)
,tot_add=(a.mtot_add-b.tot_add)
,tot_nontax=(a.mtot_nontax-b.tot_nontax)
,tot_fdisc=(a.mtot_fdisc-b.tot_fdisc)
from #ptstax a 
inner join #ptstax2 b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)
inner join (Select entry_ty,tran_cd,itserial=min(itserial) from #ptstax group by entry_ty,tran_cd) c 
on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd and a.itserial=c.itserial)

/* Updating all taxes & charges -both (itemwise) & (calculated voucherwise for item)*/
Update #ptstax set tot_deduc=tot_deduc+itot_deduc,tot_tax=tot_tax+itot_tax,tot_add=tot_add+itot_add
,tot_nontax=tot_nontax+itot_nontax,tot_fdisc=tot_fdisc+itot_fdisc
,Net_amt=Net_amt -(tot_deduc+itot_deduc)+(tot_tax+itot_tax)+(tot_add+itot_add)-(tot_fdisc+itot_fdisc)
				+tot_examt+taxamt+(tot_nontax+itot_nontax)
,Net_amt2=Net_amt2 -itot_deduc+itot_tax+itot_add-itot_fdisc
				+tot_examt+taxamt+itot_nontax



alter table #ptstax add duty_add bit
Update a set duty_add=Case when gro_amt=Net_amt2 and lcode.stax_item=1 then 1 else 
	(Case when gro_amt=Net_amt2-taxamt and lcode.stax_tran=1 then 1 else 0 end) End
from #ptstax a inner join lcode on (a.entry_ty=lcode.entry_ty) 


Update #ptstax set Net_amt=case when duty_add=1 then Net_amt else Net_amt-tot_examt end 

select * from #ptstax order by yearr,mon,tax_name,srno,date,Inv_no

DROP TABLE #ptstax
DROP TABLE #ptstax2
DROP TABLE #L
DROP TABLE #Netamtcal
