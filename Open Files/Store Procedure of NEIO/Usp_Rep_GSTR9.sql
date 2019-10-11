IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='Usp_Rep_GSTR9')
BEGIN
	DROP PROCEDURE [Usp_Rep_GSTR9]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--set dateformat dmy EXECUTE Usp_Rep_GSTR9

CREATE Procedure [Usp_Rep_GSTR9]
As
BEGIN
	select 	
	cast(SUBSTRING(a.section,
	PATINDEX('%[0-9]%', a.section),
	(CASE WHEN PATINDEX('%[^0-9]%', STUFF(a.section, 1, (PATINDEX('%[0-9]%', a.section) - 1), '')) = 0
	THEN LEN(a.section) ELSE (PATINDEX('%[^0-9]%', STUFF(a.section, 1, (PATINDEX('%[0-9]%', a.section) - 1), ''))) - 1
	END )) as int) as part,a.section as partsr,b.desctype,a.*
	,cast(0.00 as numeric(18,2)) as [I_cgst_amt],cast(0.00 as numeric(18,2)) as [CG_cgst_amt],cast(0.00 as numeric(18,2)) as [IS_cgst_amt]
	,cast(0.00 as numeric(18,2)) as [I_sgst_amt],cast(0.00 as numeric(18,2)) as [CG_sgst_amt],cast(0.00 as numeric(18,2)) as [IS_sgst_amt]
	,cast(0.00 as numeric(18,2)) as [I_igst_amt],cast(0.00 as numeric(18,2)) as [CG_igst_amt],cast(0.00 as numeric(18,2)) as [IS_igst_amt]
	,cast(0.00 as numeric(18,2)) as [I_cess_amt],cast(0.00 as numeric(18,2)) as [CG_cess_amt],cast(0.00 as numeric(18,2)) as [IS_cess_amt]
	into #TEMPGSTR9
	from gstr9_det a
	inner join gstr9_mast b on (a.section=b.section)
	
IF EXISTS(SELECT * FROM #TEMPGSTR9 WHERE section in ('6B1','6B2','6B3','6C1','6C2','6C3','6D1','6D2','6D3','6E1','6E2'))
BEGIN
	SELECT * INTO #TEMPGSTR9_1
	FROM(
		select 
		'6' as part,'6B' as partsr,'' as desctype,0 as primaryid,'' as Fin_Year,'' as GSTIN,'6B' as Section,'' as srno,'6I,8B' as SubSection
		,0 as taxableamt,0 as tax_payable,0 as tax_paid_cash,0 as CGST_AMT,0 as SGST_AMT,0 as IGST_AMT,0 as cess_amt,0 as interest,0 as penalty,
		0 as latefee_othrs,'' as hsncode,'' as uqc,0 as totqty,0 as taxrate,'' as legal_name,'' as trade_name
		,[I_cgst_amt] = max(case when desctype= 'Inputs' then cgst_amt end),[CG_cgst_amt] = max(case when desctype= 'Capital Goods' then cgst_amt end)
		,[IS_cgst_amt] = max(case when desctype= 'Input services' then cgst_amt end)
  
		,[I_sgst_amt] = max(case when desctype= 'Inputs' then sgst_amt end),[CG_sgst_amt] = max(case when desctype= 'Capital Goods' then sgst_amt end)
		,[IS_sgst_amt] = max(case when desctype= 'Input services' then sgst_amt end)
  
		,[I_igst_amt] = max(case when desctype= 'Inputs' then igst_amt end),[CG_igst_amt] = max(case when desctype= 'Capital Goods' then igst_amt end)
		,[IS_igst_amt] = max(case when desctype= 'Input services' then igst_amt end)

		,[I_cess_amt] = max(case when desctype= 'Inputs' then cess_amt end),[CG_cess_amt] = max(case when desctype= 'Capital Goods' then cess_amt end)
		,[IS_cess_amt] = max(case when desctype= 'Input services' then cess_amt end)
		from #TEMPGSTR9
		where section in ('6B1','6B2','6B3')
	union all
		select 
		'6' as part,'6C' as partsr,'' as desctype,0 as primaryid,'' as Fin_Year,'' as GSTIN,'6C' as Section,'' as srno,'6I' as SubSection
		,0 as taxableamt,0 as tax_payable,0 as tax_paid_cash,0 as CGST_AMT,0 as SGST_AMT,0 as IGST_AMT,0 as cess_amt,0 as interest,0 as penalty,
		0 as latefee_othrs,'' as hsncode,'' as uqc,0 as totqty,0 as taxrate,'' as legal_name,'' as trade_name
		,[I_cgst_amt] = max(case when desctype= 'Inputs' then cgst_amt end),[CG_cgst_amt] = max(case when desctype= 'Capital Goods' then cgst_amt end)
		,[IS_cgst_amt] = max(case when desctype= 'Input services' then cgst_amt end)
  
		,[I_sgst_amt] = max(case when desctype= 'Inputs' then sgst_amt end),[CG_sgst_amt] = max(case when desctype= 'Capital Goods' then sgst_amt end)
		,[IS_sgst_amt] = max(case when desctype= 'Input services' then sgst_amt end)
  
		,[I_igst_amt] = max(case when desctype= 'Inputs' then igst_amt end),[CG_igst_amt] = max(case when desctype= 'Capital Goods' then igst_amt end)
		,[IS_igst_amt] = max(case when desctype= 'Input services' then igst_amt end)

		,[I_cess_amt] = max(case when desctype= 'Inputs' then cess_amt end),[CG_cess_amt] = max(case when desctype= 'Capital Goods' then cess_amt end)
		,[IS_cess_amt] = max(case when desctype= 'Input services' then cess_amt end)
		from #TEMPGSTR9
		where section in ('6C1','6C2','6C3')
	union all
		select 
		'6' as part,'6D' as partsr,'' as desctype,0 as primaryid,'' as Fin_Year,'' as GSTIN,'6D' as Section,'' as srno,'6I' as SubSection
		,0 as taxableamt,0 as tax_payable,0 as tax_paid_cash,0 as CGST_AMT,0 as SGST_AMT,0 as IGST_AMT,0 as cess_amt,0 as interest,0 as penalty,
		0 as latefee_othrs,'' as hsncode,'' as uqc,0 as totqty,0 as taxrate,'' as legal_name,'' as trade_name
		,[I_cgst_amt] = max(case when desctype= 'Inputs' then cgst_amt end),[CG_cgst_amt] = max(case when desctype= 'Capital Goods' then cgst_amt end)
		,[IS_cgst_amt] = max(case when desctype= 'Input services' then cgst_amt end)
  
		,[I_sgst_amt] = max(case when desctype= 'Inputs' then sgst_amt end),[CG_sgst_amt] = max(case when desctype= 'Capital Goods' then sgst_amt end)
		,[IS_sgst_amt] = max(case when desctype= 'Input services' then sgst_amt end)
  
		,[I_igst_amt] = max(case when desctype= 'Inputs' then igst_amt end),[CG_igst_amt] = max(case when desctype= 'Capital Goods' then igst_amt end)
		,[IS_igst_amt] = max(case when desctype= 'Input services' then igst_amt end)

		,[I_cess_amt] = max(case when desctype= 'Inputs' then cess_amt end),[CG_cess_amt] = max(case when desctype= 'Capital Goods' then cess_amt end)
		,[IS_cess_amt] = max(case when desctype= 'Input services' then cess_amt end)
		from #TEMPGSTR9
		where section in ('6D1','6D2','6D3')
	union all
		select 
		'6' as part,'6E' as partsr,'' as desctype,0 as primaryid,'' as Fin_Year,'' as GSTIN,'6E' as Section,'' as srno,'6I' as SubSection
		,0 as taxableamt,0 as tax_payable,0 as tax_paid_cash,0 as CGST_AMT,0 as SGST_AMT,0 as IGST_AMT,0 as cess_amt,0 as interest,0 as penalty,
		0 as latefee_othrs,'' as hsncode,'' as uqc,0 as totqty,0 as taxrate,'' as legal_name,'' as trade_name
		,[I_cgst_amt] = max(case when desctype= 'Inputs' then cgst_amt end),[CG_cgst_amt] = max(case when desctype= 'Capital Goods' then cgst_amt end)
		,[IS_cgst_amt] = max(case when desctype= 'Input services' then cgst_amt end)
  
		,[I_sgst_amt] = max(case when desctype= 'Inputs' then sgst_amt end),[CG_sgst_amt] = max(case when desctype= 'Capital Goods' then sgst_amt end)
		,[IS_sgst_amt] = max(case when desctype= 'Input services' then sgst_amt end)
  
		,[I_igst_amt] = max(case when desctype= 'Inputs' then igst_amt end),[CG_igst_amt] = max(case when desctype= 'Capital Goods' then igst_amt end)
		,[IS_igst_amt] = max(case when desctype= 'Input services' then igst_amt end)

		,[I_cess_amt] = max(case when desctype= 'Inputs' then cess_amt end),[CG_cess_amt] = max(case when desctype= 'Capital Goods' then cess_amt end)
		,[IS_cess_amt] = max(case when desctype= 'Input services' then cess_amt end)
		from #TEMPGSTR9
		where section in ('6E1','6E2')
	) aa
	order by part,partsr

	Select * into #TEMPGSTR9_2 From 
	(
	  select * from #TEMPGSTR9 where section not in ('6B1','6B2','6B3','6C1','6C2','6C3','6D1','6D2','6D3','6E1','6E2')
	  union all
	  select * from #TEMPGSTR9_1
	) BB order by part,partsr

	Update #TEMPGSTR9_2 set 
	 Taxableamt=isnull(Taxableamt,0.00),tax_payable=isnull(tax_payable,0.00),tax_paid_cash=isnull(tax_paid_cash,0.00)
	, CGST_AMT=isnull(CGST_AMT,0.00), SGST_AMT=isnull(SGST_AMT,0.00), IGST_AMT=isnull(IGST_AMT,0.00),Cess_Amt=isnull(Cess_Amt,0.00)
	,interest=isnull(interest,0.00),penalty=isnull(penalty,0.00),latefee_othrs=isnull(latefee_othrs,0.00)
	,hsncode=isnull(hsncode,0.00),uqc=isnull(uqc,0.00),totqty=isnull(totqty,0.00),taxrate=isnull(taxrate,0.00)
	,[I_cgst_amt]=isnull([I_cgst_amt],0.00),[CG_cgst_amt]=isnull([CG_cgst_amt],0.00), [IS_cgst_amt]=isnull([IS_cgst_amt],0.00)
	,[I_sgst_amt]=isnull([I_sgst_amt],0.00),[CG_sgst_amt]=isnull([CG_sgst_amt],0.00),[IS_sgst_amt]=isnull([IS_sgst_amt],0.00)
    ,[I_igst_amt]=isnull([I_igst_amt],0.00),[CG_igst_amt]=isnull([CG_igst_amt],0.00), [IS_igst_amt]=isnull([IS_igst_amt],0.00)
	,[I_cess_amt]=isnull([I_cess_amt],0.00),[CG_cess_amt]=isnull([CG_cess_amt],0.00),[IS_cess_amt]=isnull([IS_cess_amt],0.00)

	select * from #TEMPGSTR9_2
	order by part,partsr

	drop table #TEMPGSTR9_1
	drop table #TEMPGSTR9_2

END
ELSE
BEGIN
	Update #TEMPGSTR9 set 
	 Taxableamt=isnull(Taxableamt,0.00),tax_payable=isnull(tax_payable,0.00),tax_paid_cash=isnull(tax_paid_cash,0.00)
	, CGST_AMT=isnull(CGST_AMT,0.00), SGST_AMT=isnull(SGST_AMT,0.00), IGST_AMT=isnull(IGST_AMT,0.00),Cess_Amt=isnull(Cess_Amt,0.00)
	,interest=isnull(interest,0.00),penalty=isnull(penalty,0.00),latefee_othrs=isnull(latefee_othrs,0.00)
	,hsncode=isnull(hsncode,0.00),uqc=isnull(uqc,0.00),totqty=isnull(totqty,0.00),taxrate=isnull(taxrate,0.00)

	select * from #TEMPGSTR9
	order by part,partsr
END


drop table #TEMPGSTR9

END