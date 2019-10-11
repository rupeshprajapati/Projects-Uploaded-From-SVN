If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_GET_OUTPUT_TAX_LIABILITY')
Begin
	Drop Procedure USP_REP_GET_OUTPUT_TAX_LIABILITY
End
/****** Object:  StoredProcedure [dbo].[USP_REP_GET_OUTPUT_TAX_LIABILITY]    Script Date: 05/05/2018 10:35:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* LineRule Column added by Suraj Kumawat date on 15-02-2018 for Bug-31248*/

Create Procedure [dbo].[USP_REP_GET_OUTPUT_TAX_LIABILITY]
@SDATE SMALLDATETIME,@EDATE SMALLDATETIME
As

/*		Creating Temporary  Table		*/
SELECT a.Inv_No,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=convert(varchar(2000),c.it_desc) 
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
	--,b.It_code,entry_ty= cast('' AS varchar(50)),a.Tran_cd		--Commented by Shrikant S. on 11/07/2018 for Bug-31701
	,b.It_code,TransType= cast('' AS varchar(50)),a.Tran_cd			--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	--,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end-- Commented By Prajakta B. on 06092017
	,Ac_id=a.Ac_id,sAc_id=a.sAc_id,cons_id=a.cons_id,scons_id=a.scons_id -- Added By Prajakta B. on 06092017
	,a.TranStatus
	,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	,[Payable Type]=Convert(Varchar(10),'')
    ,b.LineRule
    ,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	Into #tmptbl
	FROM STMAIN a 
	, Stitem b ,It_mast c  Where 1=2

/*		Inserting Goods Invoices			*/
Select Entry_ty,Tran_cd Into #stacdet From stacdet a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable')	Group by Entry_ty,Tran_cd

Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
	,b.It_code
	--,a.entry_ty
	,entry_ty= case when a.entry_ty='ST' then 'Sales' when a.entry_ty='UB' then 'Self Invoice' else 'Export Sales' end
	,a.Tran_cd
	--,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end-- Commented By Prajakta B. on 06092017
	,Ac_id=a.Ac_id,sAc_id=a.sAc_id,cons_id=a.cons_id,scons_id=a.scons_id -- Added By Prajakta B. on 06092017
	,a.TranStatus
	,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	--,[Payable Type]=Case when a.Entry_ty ='UB' then 'Under RCM' else '' End
	,[Payable Type]=Case when a.Entry_ty ='UB' then 'Under RCM' else '' End
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM STMAIN a 
	, stitem b ,It_mast c,#stacdet d  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and b.it_code=c.it_code and a.date between @SDATE and @EDATE
		---and a.Entry_ty in ('ST','UB') ---Commented by Suraj Kumawat for Bug-31130 
		and a.Entry_ty in ('ST','UB','EI')---Added by Suraj Kumawat for Bug-31130
Drop table #stacdet	

Select Entry_ty,Tran_cd Into #sracdet From sracdet a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable')	Group by Entry_ty,Tran_cd

Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	--,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT   --Commented by Prajakta B. for Installer on 27042018
	,b.CGST_PER,-(b.CGST_AMT),b.SGST_PER,-(b.SGST_AMT),b.IGST_PER,-(b.IGST_AMT)  --Modified by Prajakta B. for Installer on 27042018
	,b.It_code--,a.entry_ty
	,entry_ty= case when a.entry_ty='SR' then 'Sales Return' else '' end
	,a.Tran_cd
	--,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end-- Commented By Prajakta B. on 06092017
	,Ac_id=a.Ac_id,sAc_id=a.sAc_id,cons_id=a.cons_id,scons_id=a.scons_id -- Added By Prajakta B. on 06092017
	,a.TranStatus
	,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	--,[Comp. Cess]=b.compcess+b.comrpcess  --Commented by Prajakta B. for Installer on 27042018
	,[Comp. Cess]=-(b.compcess+b.comrpcess)  --Modified by Prajakta B. for Installer on 27042018
	,[Payable Type]=''
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM SRMAIN a 
	, SRitem b ,It_mast c,#sracdet d  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and b.it_code=c.it_code and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('SR')
Drop table #sracdet	

Select Entry_ty,Tran_cd Into #bracdet From bracdet a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable')	Group by Entry_ty,Tran_cd

Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	--,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT  -- commented by Prajakta B. on 31102017
	,b.CGST_PER,CGST_AMT=b.CGST_AMT+b.CGSRT_AMT,b.SGST_PER,SGST_AMT=b.SGST_AMT+b.SGSRT_AMT,b.IGST_PER,IGST_AMT=b.IGST_AMT+b.IGSRT_AMT  -- commented by Prajakta B. on 31102017
	,b.It_code--,a.entry_ty
	,entry_ty= case when a.entry_ty='BR' then 'Bank Receipt' else '' end
	,a.Tran_cd,Ac_id=a.ac_id
	,sac_id=a.sAc_id
	,cons_id='',scons_is=''-- added by prajakta B. on 06092017
	,TranStatus=1
	,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	,[Payable Type]=''
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM BRMAIN a 
	, BRitem b ,It_mast c,#bracdet d  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and b.it_code=c.it_code and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('BR') AND a.tdspaytype=2
Drop table #bracdet	


Select Entry_ty,Tran_cd Into #bpacdet From bpacdet a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable')	Group by Entry_ty,Tran_cd

Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	--,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT  -- commented by Prajakta B. on 31102017
	,b.CGST_PER,CGST_AMT=b.CGST_AMT+b.CGSRT_AMT,b.SGST_PER,SGST_AMT=b.SGST_AMT+b.SGSRT_AMT,b.IGST_PER,IGST_AMT=b.IGST_AMT+b.IGSRT_AMT  -- commented by Prajakta B. on 31102017
	,b.It_code--,a.entry_ty
	,entry_ty= case when a.entry_ty='BP' then 'Bank Payment'  else '' end
	,a.Tran_cd,Ac_id=a.ac_id
	,sac_id=a.sAc_id
	,cons_id='',scons_is=''-- added by prajakta B. on 06092017
	,TranStatus=1,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	,[Payable Type]='Under RCM'
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM BPMAIN a 
	, BPitem b ,It_mast c,#bpacdet d  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and b.it_code=c.it_code and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('BP')
		 AND a.tdspaytype=2
		 
		 
Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	--,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT  -- commented by Prajakta B. on 31102017
	,b.CGST_PER,CGST_AMT=-(b.CGST_AMT+b.CGSRT_AMT),b.SGST_PER,SGST_AMT=-(b.SGST_AMT+b.SGSRT_AMT),b.IGST_PER,IGST_AMT=-(b.IGST_AMT+b.IGSRT_AMT)  -- commented by Prajakta B. on 31102017
	,b.It_code--,a.entry_ty
	,entry_ty= case when a.entry_ty='RV' then 'Refund Voucher' else '' end
	,a.Tran_cd,Ac_id=a.ac_id
	,sac_id=a.sAc_id
	,cons_id='',scons_is=''-- added by prajakta B. on 06092017
	,TranStatus=1,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=-(b.compcess+b.comrpcess)  -- Modified by Prajakta B. on 31102017
	,[Payable Type]=''
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM BPMAIN a 
	, BPitem b ,It_mast c,#bpacdet d  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and b.it_code=c.it_code and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('RV')
		 AND a.tdspaytype=2

Drop table #bpacdet
	
/*		Inserting Service Invoices			*/
Select Entry_ty,Tran_cd Into #sbacdet 
--From stacdet a-- Commented By Prajakta B. On 04092017
From sbacdet a -- Modified By Prajakta B. On 04092017
inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable')	Group by Entry_ty,Tran_cd

Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.staxamt as TaxableVal
	,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT
	,b.It_code--,a.entry_ty
	,entry_ty= case when a.entry_ty='S1' then 'Service Invoice' else '' end
	,a.Tran_cd
	--,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end-- Commented By Prajakta B. on 06092017
	,Ac_id=a.Ac_id,sAc_id=a.sAc_id,cons_id=a.cons_id,scons_id=a.scons_id -- Added By Prajakta B. on 06092017
	,a.TranStatus	,[Comp. Cess Rate]='',[Comp. Cess]=0
	,[Payable Type]=''
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM SBMAIN a 
	, sbitem b ,It_mast c ,#sbacdet d 
	Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and b.it_code=c.it_code and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('S1')
Drop Table #sbacdet

--/*		Inserting Debit Note Bills		*/
Select Entry_ty,Tran_cd Into #dnacdet From dnacdet a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable') Group by Entry_ty,Tran_cd

Insert Into #tmptbl
SELECT a.Inv_no,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,case when a.Entry_ty='D6' then b.staxamt else b.U_ASSEAMT end  as TaxableVal
	,b.CGST_PER,CGST_AMT=Case When a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL') then -b.CGST_AMT-b.CGSRT_AMT else b.CGST_AMT+b.CGSRT_AMT end
	,b.SGST_PER,SGST_AMT=Case When a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL') then -b.SGST_AMT-b.SGSRT_AMT else b.SGST_AMT+b.SGSRT_AMT end
	,b.IGST_PER,IGST_AMT=Case When a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL') then -b.IGST_AMT-b.IGSRT_AMT else b.IGST_AMT+b.IGSRT_AMT end
	,b.It_code--,a.entry_ty
	,entry_ty= case when a.entry_ty='GD' then 'Debit Note for GST' when a.entry_ty='D6' then 'Debit Note for Service' else '' end
	,a.Tran_cd
	--,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end-- Commented By Prajakta B. on 06092017
	,Ac_id=a.Ac_id,sAc_id=a.sAc_id,cons_id=a.cons_id,scons_id=a.scons_id -- Added By Prajakta B. on 06092017
	,a.TranStatus
	,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	,[Payable Type]=Case when (b.CGSRT_AMT+b.SGSRT_AMT+b.IGSRT_AMT)>0 then 'Under RCM' else '' End
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM DNMAIN a 
	, DNitem b ,It_mast c,#dnacdet d Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code 
		and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and a.pinvdt between @SDATE and @EDATE
		and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('GD','D6')

DROP TABLE #dnacdet		
	--Delete from #tmptbl Where TranStatus<>1
	
Select Entry_ty,Tran_cd Into #cnacdet From cnacdet a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable') Group by Entry_ty,Tran_cd

Insert Into #tmptbl
SELECT a.Inv_no,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,case when a.Entry_ty='C6' then b.staxamt else b.U_ASSEAMT end  as TaxableVal
	,b.CGST_PER,CGST_AMT=Case When a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL') then b.CGST_AMT+b.CGSRT_AMT else -b.CGST_AMT-b.CGSRT_AMT end
	,b.SGST_PER,SGST_AMT=Case When a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL') then b.SGST_AMT+b.SGSRT_AMT else -b.SGST_AMT-b.SGSRT_AMT end
	,b.IGST_PER,IGST_AMT=Case When a.againstgs in ('PURCHASES','SERVICE PURCHASE BILL') then b.IGST_AMT+b.IGSRT_AMT else -b.IGST_AMT-b.IGSRT_AMT end
	,b.It_code--,a.entry_ty
	,entry_ty= case when a.entry_ty='GC' then 'Credit Note for GST' when a.entry_ty='C6' then 'Credit Note for Service' else '' end
	,a.Tran_cd
	--,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end-- Commented By Prajakta B. on 06092017
	,Ac_id=a.Ac_id,sAc_id=a.sAc_id,cons_id=a.cons_id,scons_id=a.scons_id -- Added By Prajakta B. on 06092017
	,a.TranStatus
	,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	,[Payable Type]=Case when (b.CGSRT_AMT+b.SGSRT_AMT+b.IGSRT_AMT)>0 then 'Under RCM' else '' End
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM CNMAIN a 
	, CNitem b ,It_mast c,#cnacdet d Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code 
		and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and a.pinvdt between @SDATE and @EDATE
		and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('GC','C6')

DROP TABLE #cnacdet	


Select Entry_ty,Tran_cd Into #epacdet From epacdet a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable') Group by Entry_ty,Tran_cd
		
Insert Into #tmptbl
SELECT a.Inv_No,a.Date
    --,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.staxamt as TaxableVal
	,b.CGST_PER,CGST_AMT=b.CGST_AMT+b.CGSRT_AMT,b.SGST_PER,SGST_AMT=b.SGST_AMT+b.SGSRT_AMT,b.IGST_PER,IGST_AMT=b.IGST_AMT+b.IGSRT_AMT
	,b.It_code--,a.entry_ty
	,entry_ty= case when a.entry_ty='E1' then 'Service Purchase Bill' else '' end
	,a.Tran_cd
	--,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end-- Commented By Prajakta B. on 06092017
	,Ac_id=a.Ac_id,sAc_id=a.sAc_id,cons_id=a.cons_id,scons_id=a.scons_id -- Added By Prajakta B. on 06092017.
	,a.TranStatus
	,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	,[Payable Type]=Case when (b.CGSRT_AMT+b.SGSRT_AMT+b.IGSRT_AMT)>0 then 'Under RCM' else '' End
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM EPMAIN a 
	, EPitem b ,It_mast c ,#epacdet d Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		 and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('E1')

Drop Table #epacdet

--Added by Prajakta B. on 04092017 Start
Select Entry_ty,Tran_cd Into #Cracdet From cracdet a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable')	Group by Entry_ty,Tran_cd

Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	--,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT  -- commented by Prajakta B. on 31102017
	,b.CGST_PER,CGST_AMT=b.CGST_AMT+b.CGSRT_AMT,b.SGST_PER,SGST_AMT=b.SGST_AMT+b.SGSRT_AMT,b.IGST_PER,IGST_AMT=b.IGST_AMT+b.IGSRT_AMT  -- commented by Prajakta B. on 31102017
	,b.It_code
	--,a.entry_ty
	,entry_ty= case when a.entry_ty='CR' then 'Cash Receipt' else '' end
	,a.Tran_cd,Ac_id=a.ac_id 
	,sac_id=a.Ac_id
	,cons_id='',scons_is=''-- added by prajakta B. on 06092017
	,TranStatus=1,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	,[Payable Type]=''
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM CRMAIN a 
	, Critem b ,It_mast c,#cracdet d  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and b.it_code=c.it_code and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('CR') AND a.tdspaytype=2
Drop table #Cracdet	




Select Entry_ty,Tran_cd Into #Cpacdet From Cpacdet a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable')	Group by Entry_ty,Tran_cd

Insert Into #tmptbl
SELECT a.Inv_No,a.Date
	--,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	--,b.CGST_PER,b.CGST_AMT,b.SGST_PER,b.SGST_AMT,b.IGST_PER,b.IGST_AMT  -- commented by Prajakta B. on 31102017
	,b.CGST_PER,CGST_AMT=b.CGST_AMT+b.CGSRT_AMT,b.SGST_PER,SGST_AMT=b.SGST_AMT+b.SGSRT_AMT,b.IGST_PER,IGST_AMT=b.IGST_AMT+b.IGSRT_AMT  -- commented by Prajakta B. on 31102017
	,b.It_code
	--,a.entry_ty
	,entry_ty= case when a.entry_ty='CP' then 'Cash Payment' else '' end
	,a.Tran_cd,Ac_id=a.ac_id
	,sac_id=a.Ac_id,
	cons_id='',scons_is=''-- added by prajakta B. on 06092017
	,TranStatus=1,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	,[Payable Type]='Under RCM'	
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM CPMAIN a 
	, CPitem b ,It_mast c,#Cpacdet d  Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		--and b.it_code=c.it_code and a.pinvdt between @SDATE and @EDATE
		and b.it_code=c.it_code and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('CP')
		 AND a.tdspaytype=2
Drop table #Cpacdet


--Added by Prajakta B. on 04092017 end

----Added by Prajakta B. on 05052018 for Installer start
Select Entry_ty,Tran_cd Into #PTACDET From PTACDET a inner join ac_mast b on (a.ac_id=b.ac_id) Where (b.typ Like '_GST Payable' or b.typ Like '%Cess Payable') Group by Entry_ty,Tran_cd
		
Insert Into #tmptbl
SELECT a.Inv_No,a.Date
    --,c.hsncode -- Commented By Prajakta B. On 04092017
	,hsncode=case when c.isService=1 then c.ServTCode else c.HSNCODE end -- Modified By Prajakta B. On 04092017
	,SupplyType=Case when c.isService=1 then 'Services' else 'Goods' End
	,Descript=Case when c.isService=1 then c.serty else case when len(convert(varchar(2000),c.it_desc))>0 then convert(varchar(2000),c.it_desc) else c.it_name end end
	,a.Net_amt
	,b.U_ASSEAMT as TaxableVal
	,b.CGST_PER,CGST_AMT=b.CGST_AMT+b.CGSRT_AMT,b.SGST_PER,SGST_AMT=b.SGST_AMT+b.SGSRT_AMT,b.IGST_PER,IGST_AMT=b.IGST_AMT+b.IGSRT_AMT
	,b.It_code
	--,a.entry_ty
	,entry_ty= case when a.entry_ty='PT' then 'Purchase' when a.entry_ty='P1' then 'Import Purchase' else '' end
	,a.Tran_cd
	--,Ac_id=case when a.cons_id >0 then a.cons_id else a.ac_id end,sac_id=Case when a.scons_id>0 then a.scons_id else a.sAc_id end-- Commented By Prajakta B. on 06092017
	,Ac_id=a.Ac_id,sAc_id=a.sAc_id,cons_id=a.cons_id,scons_id=a.scons_id -- Added By Prajakta B. on 06092017.
	,a.TranStatus
	,[Comp. Cess Rate]=b.ccessrate
	--,[Comp. Cess]=b.compcess  -- Commented by Prajakta B. on 31102017
	,[Comp. Cess]=b.compcess+b.comrpcess  -- Modified by Prajakta B. on 31102017
	,[Payable Type]=Case when (b.CGSRT_AMT+b.SGSRT_AMT+b.IGSRT_AMT)>0 then 'Under RCM' else '' End
	,b.LineRule
	,a.Entry_ty						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	FROM PTMAIN a 
	, ptitem b ,It_mast c ,#PTACDET d Where (a.Entry_ty=b.Entry_ty and a.tran_cd=b.Tran_cd)
		and b.it_code=c.it_code  and a.Tran_cd=d.tran_cd and a.entry_ty=d.Entry_ty 
		 and a.date between @SDATE and @EDATE
		and a.Entry_ty in ('PT','P1')

Drop Table #PTACDET

	
/*		Fetching all records by summarizing GSTIN AND HSN/SAC,PARTY AND BILL NO.		*/		
	select GSTIN=(case when a.sac_id> 0 then c.gstin else b.gstin end)--modified by prajakta b. on 13092017
	--case when ISNULL(c.gstin,'')='' then b.gstin else c.gstin end --commented by prajakta b. on 13092017
	,Party_nm=(CASE WHEN a.sac_id> 0 THEN c.mailname ELSE b.mailname END)--modified by prajakta b. on 13092017
	,Cons_Party_Name=(CASE WHEN a.scons_id> 0 THEN c1.mailname ELSE b1.mailname END)--modified by prajakta b. on 13092017
	,Cons_GSTIN=(case when a.scons_id> 0 then c1.gstin else b1.gstin end)---- added by prajakta B. on 06092017
	,a.inv_no,a.date
	,StateCode=case when ISNULL(c.StateCode,'')='' then b.StateCode else c.StateCode end
	,[State]=case when ISNULL(c.[State],'')='' then b.[State] else c.[State] end
	,hsncode,SupplyType,Descript,Net_amt,TaxableVal=SUM(TaxableVal),CGST_PER,CGST_AMT=sum(CGST_AMT)
	,SGST_PER,SGST_AMT=sum(SGST_AMT),IGST_PER,IGST_AMT=sum(IGST_AMT),a.TransType ,a.Tran_cd,a.Ac_id,a.sac_id,a.[Comp. Cess Rate],[Comp. Cess]=sum(a.[Comp. Cess]),a.[Payable Type]		--Added by Shrikant S. on 11/07/2018 for Bug-31701
	--,SGST_PER,SGST_AMT=sum(SGST_AMT),IGST_PER,IGST_AMT=sum(IGST_AMT),entry_ty ,a.Tran_cd,a.Ac_id,a.sac_id,a.[Comp. Cess Rate],[Comp. Cess]=sum(a.[Comp. Cess]),a.[Payable Type]	--Commented by Shrikant S. on 11/07/2018 for Bug-31701
	,a.cons_id,a.scons_id---- added by prajakta B. on 06092017
	,a.LineRule
	,a.Entry_ty 			--Added by Shrikant S. on 11/07/2018 for Bug-31701	
	 from #tmptbl a
		Inner join AC_MAST b on (a.Ac_id=b.Ac_id)
		Left Join SHIPTO c on (a.sac_id=c.shipto_id and a.Ac_id=c.Ac_id)
		left join AC_MAST b1 on (a.cons_id=b1.Ac_id)-- added by prajakta B. on 06092017
		LEFT JOIN SHIPTO c1 ON (a.CONS_ID=c1.AC_ID AND a.SCONS_ID=c1.SHIPTO_ID)-- added by prajakta B. on 06092017
		Group by b.gstin,c.GSTIN,b.mailname,a.inv_no,a.date,hsncode,SupplyType,Descript,Net_amt,CGST_PER
			,SGST_PER,IGST_PER,entry_ty,a.Tran_cd,a.Ac_id,a.sac_id,c.[State],b.[State],c.statecode,b.statecode,a.[Payable Type],a.[Comp. Cess Rate]
			,a.cons_id,a.scons_id,b1.mailname,b1.gstin,c1.GSTIN,c.mailname,c1.mailname  -- added by prajakta B. on 06092017
			,a.LineRule
			,a.TransType						--Added by Shrikant S. on 11/07/2018 for Bug-31701	
		Order by a.inv_no,a.date
		
Drop Table #tmptbl
