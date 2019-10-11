IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='p' AND name = 'USP_REP_ISD_INVOICE_REG')
BEGIN
	DROP PROCEDURE USP_REP_ISD_INVOICE_REG
END
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[USP_REP_ISD_INVOICE_REG]
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
 Begin
    declare @sqlstr1 nvarchar(4000),@Tax_Befor_GST  varchar(max),@GST_Befor_GST  varchar(max),@Add_Befor_GST  varchar(max),@NonTax_Befor_GST  varchar(max)
    ,@Fdisc_Befor_GST  varchar(max),@Ded_Befor_GST  varchar(max),@Tax_Aft_GST  varchar(max),@GST_Aft_GST  varchar(max),@Add_Aft_GST  varchar(max),@NonTax_Aft_GST  varchar(max)
    ,@Fdisc_Aft_GST  varchar(max) ,@Ded_Aft_GST  varchar(max),@bcode_nm varchar(2),@entry_ty varchar(2)
/*
"T" ="Taxable Charges", "E" ="GST" ,"A"="Additional Charges" ,"N" ="Non-taxable Charges","F" ="Final Discount","D" ="Deductions"
*/ 
/*Temporary Table for dcmast charges*/
select  d.tran_cd ,d.entry_ty ,d.itserial, h.net_amt as Tax_Befor_GST, h.net_amt as GST_Befor_GST  , h.net_amt as Add_Befor_GST  , h.net_amt as NonTax_Befor_GST
, h.net_amt as Fdisc_Befor_GST , h.net_amt as Ded_Befor_GST , h.net_amt as Tax_Aft_GST  , h.net_amt as GST_Aft_GST  , h.net_amt as Add_Aft_GST  , h.net_amt as NonTax_Aft_GST 
, h.net_amt as Fdisc_Aft_GST  , h.net_amt as Ded_Aft_GST into #tmpChrgtbl from STITEM  d  LEFT OUTER JOIN STMAIN H ON (D.ENTRY_TY= H.ENTRY_TY AND D.TRAN_CD =H.TRAN_CD )  where 1=2

	/*ISD INVOICE PASSING*/
	
	Select srno = 1 , ORD = 'A', c.code_nm,c.code_nm AS code_nm1 , mon=month(b.date),yearr=year(b.date),monthh=datename(mm,b.date),b.date,b.inv_no,b.Entry_ty,b.Tran_cd
	,u_asseamt=isnull(sum(a.qty * a.Rate),0)
	,taxname =(case when ISNULL(SUM(a.igst_amt),0) > 0  then 'IGST '+ CAST((CASE WHEN ISNULL(A.IGST_PER,0) = 0 THEN ISNULL(A.GSTRATE,0) ELSE ISNULL(A.IGST_PER,0) END)AS varchar(20))+'%' WHEN ISNULL(SUM(ISNULL(A.CGST_AMT,0)+ ISNULL(a.SGST_AMT,0)),0) > 0 THEN 'CGST+SGST ' + CAST((CASE WHEN (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) = 0  THEN ISNULL(A.GSTRATE,0) ELSE (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) END) AS varchar(20))+'%' ELSE '' END)
	,a.cgst_per,a.sgst_per,a.igst_per,A.GSTRATE
	,isnull(sum(a.CGST_AMT),0) as CGST_AMT ,isnull(sum(a.SGST_AMT),0)as SGST_AMT,isnull(sum(a.IGST_AMT),0) as IGST_AMT,isnull(sum(a.COMPCESS),0)as COMPCESS,isnull(SUM(A.GRO_AMT),0) AS ITGRO_AMT
	,pkey = '+' 
	,isnull(sum(a.ICGST_AMT),0) as ICGST_AMT ,isnull(sum(a.ISGST_AMT),0)as ISGST_AMT,isnull(sum(a.IIGST_AMT),0) as IIGST_AMT,isnull(sum(a.ICOMPCESS),0)as ICOMPCESS
	Into #Gstsummary from IBITEM a left outer join IBMAIN b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
	left outer join lcode c on (b.entry_ty = c.entry_ty)
	where a.entry_ty in('IB') and (a.CGST_AMT+a.SGST_AMT+a.IGST_AMT) > 0  and b.date between @sdate and @edate
	group by a.cgst_per,a.sgst_per,a.igst_per,a.gstrate,b.date,b.inv_no,b.Entry_ty,b.Tran_cd,c.code_nm
		
  	/*DEBIT NOTE FOR ISD INVOICE PASSING*/
  	
	insert into #Gstsummary 
	Select srno = 2 ,ORD = 'A', c.code_nm,c.code_nm AS code_nm1, mon=month(b.date),yearr=year(b.date),monthh=datename(mm,b.date),b.date,b.inv_no,b.Entry_ty,b.Tran_cd
	,u_asseamt=isnull(sum(a.qty * a.Rate),0)
	,taxname =(case when ISNULL(SUM(a.igst_amt),0) > 0  then 'IGST '+ CAST((CASE WHEN ISNULL(A.IGST_PER,0) = 0 THEN ISNULL(A.GSTRATE,0) ELSE ISNULL(A.IGST_PER,0) END)AS varchar(20))+'%' WHEN ISNULL(SUM(ISNULL(A.CGST_AMT,0)+ ISNULL(a.SGST_AMT,0)),0) > 0 THEN 'CGST+SGST ' + CAST((CASE WHEN (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) = 0  THEN ISNULL(A.GSTRATE,0) ELSE (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) END) AS varchar(20))+'%' ELSE '' END)
	,a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,isnull(sum(a.CGST_AMT),0) as CGST_AMT ,isnull(sum(a.SGST_AMT),0)as SGST_AMT,isnull(sum(a.IGST_AMT),0) as IGST_AMT,isnull(sum(a.COMPCESS),0)as COMPCESS,isnull(SUM(A.GRO_AMT),0) AS ITGRO_AMT
	,pkey = '+'
	,CAST(0.00 as numeric(10,2)) as ICGST_AMT ,CAST(0.00 as numeric(10,2)) as ISGST_AMT,CAST(0.00 as numeric(10,2)) as IIGST_AMT,CAST(0.00 as numeric(10,2)) as ICOMPCESS
	from DNITEM a left outer join DNMAIN b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
	left outer join lcode c on (b.entry_ty = c.entry_ty)
	where b.AGAINSTGS in('ISD INVOICE PASSING') AND B.ENTRY_TY IN('GD')
	and (a.CGST_AMT+a.SGST_AMT+a.IGST_AMT) > 0  and b.date between @sdate and @edate
	group by a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,b.date,b.inv_no,b.Entry_ty,b.Tran_cd,c.code_nm
		
	/*CREDIT NOTE FOR ISD INVOICE PASSING*/

	insert into #Gstsummary 
	Select srno = 3 ,ORD = 'B', c.code_nm,c.code_nm AS code_nm1, mon=month(b.date),yearr=year(b.date),monthh=datename(mm,b.date),b.date,b.inv_no,b.Entry_ty,b.Tran_cd
	,u_asseamt=isnull(sum(a.qty * a.Rate),0)
	,taxname =(case when ISNULL(SUM(a.igst_amt),0) > 0  then 'IGST '+ CAST((CASE WHEN ISNULL(A.IGST_PER,0) = 0 THEN ISNULL(A.GSTRATE,0) ELSE ISNULL(A.IGST_PER,0) END)AS varchar(20))+'%' WHEN ISNULL(SUM(ISNULL(A.CGST_AMT,0)+ ISNULL(a.SGST_AMT,0)),0) > 0 THEN 'CGST+SGST ' + CAST((CASE WHEN (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) = 0  THEN ISNULL(A.GSTRATE,0) ELSE (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) END) AS varchar(20))+'%' ELSE '' END)
	,a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,isnull(sum(a.CGST_AMT),0) as CGST_AMT ,isnull(sum(a.SGST_AMT),0)as SGST_AMT,isnull(sum(a.IGST_AMT),0) as IGST_AMT,isnull(sum(a.COMPCESS),0)as COMPCESS,isnull(SUM(A.GRO_AMT),0) AS ITGRO_AMT
	,pkey = '-' 
	,CAST(0.00 as numeric(10,2)) as ICGST_AMT ,CAST(0.00 as numeric(10,2)) as ISGST_AMT,CAST(0.00 as numeric(10,2)) as IIGST_AMT,CAST(0.00 as numeric(10,2)) as ICOMPCESS
	from CNITEM a left outer join CNMAIN b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
	left outer join lcode c on (b.entry_ty = c.entry_ty)
	where b.AGAINSTGS in('ISD INVOICE PASSING')  AND B.ENTRY_TY IN('GC')
	and (a.CGST_AMT+a.SGST_AMT+a.IGST_AMT) > 0  and b.date between @sdate and @edate
	group by a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,b.date,b.inv_no,b.Entry_ty,b.Tran_cd,c.code_nm	
    
	select *,TAXABLE=(u_asseamt)
	,GST_AMT=(CGST_AMT + SGST_AMT + IGST_AMT)
	,I_GST_AMT=(ICGST_AMT + ISGST_AMT + IIGST_AMT)
	,total=(CGST_AMT +SGST_AMT + IGST_AMT + COMPCESS + ICGST_AMT +ISGST_AMT + IIGST_AMT + ICOMPCESS)
	from #Gstsummary
	order by yearr,mon,gstrate,taxname,date,ORD,srno 
	 
 drop table #Gstsummary
end



