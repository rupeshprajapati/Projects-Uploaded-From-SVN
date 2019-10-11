IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='USP_EXTRACTION_OUTWARD_BANKCASH_EXCEL_FILE')
BEGIN
	DROP PROCEDURE USP_EXTRACTION_OUTWARD_BANKCASH_EXCEL_FILE
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- AUTHOR	  :	PRIYANKA B.
-- CREATE DATE: 07/03/2018
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO GENERATE OUTWARD BANK & CASH EXCEL EXTRACTION FILE.
-- MODIFIED BY: 
-- MODIFY DATE: 
-- REMARK:
-- =============================================
--set dateformat dmy execute USP_EXTRACTION_OUTWARD_BANKCASH_EXCEL_FILE '01/01/2017','31/01/2018'

CREATE PROCEDURE  [dbo].[USP_EXTRACTION_OUTWARD_BANKCASH_EXCEL_FILE]
@LSTARTDATE  SMALLDATETIME,@LENDDATE SMALLDATETIME
AS
SET DATEFORMAT dmy	SELECT * FROM (
---BRMAIN
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,d.ccessrate ,d.compcess as cess_amt,d.comrpcess as cessrt_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = ''
,Cons_ac_name =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.mailname else  ac.ac_name end)
,Cons_State =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  ac.state end)
,Cons_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.Supp_type else  ac.Supp_type  end)
,buyer_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  ac.SUPP_TYPE end)
,Cons_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,buyer_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,Cons_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'')='' THEN  buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(ac.GSTIN,'')='' THEN ac.UID ELSE ac.GSTIN END ) end)
,buyer_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'')='' THEN  buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(ac.GSTIN,'')='' THEN ac.UID ELSE ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate
,Cons_pos =buyer_sp.state
,buyer_pos =buyer_sp.state
,Cons_PANNO = ac.i_tax,buyer_PANNO = ac.i_tax,pinvno=''
,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
,D.GSTRATE,InvoiceType ='Regular',lcode.Code_nm as TransType,Reason = '','' as portcode,U_IMPORM = '',category='Advance Receipt'
FROM BRMAIN H LEFT OUTER JOIN
BRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
ac_mast ac ON (h.Ac_id  = ac.ac_id)
LEFT OUTER JOIN lcode  ON (lcode.Entry_ty = h.Entry_ty) WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BR' AND  ( h.DATE BETWEEN @LStartDate AND @LEndDate)

---CRMAIN
union all 
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,d.CCESSRATE as cessrate,d.COMPCESS as cess_amt,d.COMRPCESS as cessrt_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = ''
,Cons_ac_name =Cons_ac.ac_name
,Cons_state =Cons_ac.state
,Cons_SUPP_TYPE =Cons_ac.SUPP_TYPE
,buyer_SUPP_TYPE =Cons_ac.SUPP_TYPE
,Cons_st_type =Cons_ac.st_type
,buyer_st_type =Cons_ac.st_type
,Cons_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,buyer_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,pos_std_cd =h.GSTSCODE,pos = h.gststate
,Cons_pos =Cons_ac.state
,buyer_pos =Cons_ac.state
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = Cons_ac.i_tax
,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
,D.GSTRATE,InvoiceType ='Advance Receipt',lcode.Code_nm as TransType,Reason = '','' as portcode,U_IMPORM = ''
,Category ='Advance Receipt'
FROM CRMAIN H LEFT OUTER JOIN
CRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
ac_mast Cons_ac ON (h.Ac_id = Cons_ac.ac_id)
LEFT OUTER JOIN lcode  ON (lcode.Entry_ty = h.Entry_ty)   WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CR' AND  ( h.DATE BETWEEN @LStartDate AND @LEndDate)

--- Refund Voucher
union all
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D.IT_CODE,D.QTY,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,d.CCESSRATE as cessrate,d.COMPCESS as cess_amt,d.COMRPCESS as cessrt_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate =''
,Cons_ac_name =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.mailname else  ac.ac_name end)
,Cons_state =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.state else  ac.state  end)
,Cons_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  ac.SUPP_TYPE end)
,buyer_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  ac.SUPP_TYPE end)
,Cons_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,buyer_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,Cons_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')='' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else (CASE WHEN ISNULL(ac.GSTIN,'')='' THEN ac.UID ELSE ac.GSTIN END)  end)
,buyer_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')='' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else (CASE WHEN ISNULL(ac.GSTIN,'')='' THEN ac.UID ELSE ac.GSTIN END)  end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate
,Cons_pos =(case WHEN isnull(h.sAc_id , 0) > 0 then  buyer_sp.state  else  ac.state  end)
,buyer_pos =(case WHEN isnull(h.sAc_id , 0) > 0 then  buyer_sp.state  else  ac.state  end)
,Cons_PANNO = '',buyer_PANNO = ''
,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
,D.GSTRATE,InvoiceType ='Regular',lcode.Code_nm as TransType,Reason = '','' as portcode,U_IMPORM = '' ,Category ='Refund voucher'
FROM BPMAIN H LEFT OUTER JOIN
BPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
ac_mast ac ON (h.Ac_id  = ac.ac_id)
LEFT OUTER JOIN lcode  ON (lcode.Entry_ty = h.Entry_ty)
WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='RV'  and h.paymentno in(select inv_no from BRMAIN WHERE entry_ty = 'BR'  union all select inv_no from cRMAIN WHERE entry_ty = 'CR' )
AND  ( h.DATE BETWEEN @LStartDate AND @LEndDate)
/*Advance adjustment*/
union all
SELECT  H.Entry_ty, H.Tran_cd, ITSERIAL=Row_number()over(partition  by h.tran_cd,h.entry_ty,h.inv_no  order by h.tran_cd,h.entry_ty,h.inv_no ), H.INV_NO, H.DATE,0 as IT_CODE,0 as QTY,d.Taxable as GrossValue,d.Taxable AS Taxableamt
,case when (ISNULL(D.CGST_AMT,0) + ISNULL(d.SGST_AMT,0)) > 0 THEN  (CASE WHEN ISNULL(D.TAXRATE,0)> 0 THEN (ISNULL(D.TAXRATE,0) / 2) ELSE 0 END  ) ELSE 0 END as CGST_PER,D.CGST_AMT
,case when (ISNULL(D.CGST_AMT,0) + ISNULL(d.SGST_AMT,0)) > 0 THEN  (CASE WHEN ISNULL(D.TAXRATE,0)> 0 THEN (ISNULL(D.TAXRATE,0) / 2) ELSE 0 END )  ELSE 0 END as SGST_PER,D.SGST_AMT
,case when (ISNULL(D.IGST_AMT,0)) > 0 THEN  (ISNULL(D.TAXRATE,0))  ELSE 0 END as IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE, 0 as CGSRT_AMT, 0 as SGSRT_AMT,0 as IGSRT_AMT ,0 as GRO_AMT
,net_amt=(select SUM(isnull(Taxable,0)+isnull(cgst_amt,0)+isnull(SGST_AMT ,0)+isnull(IGST_AMT ,0)) from TaxAllocation  where entry_ty = h.entry_ty and Tran_cd =h.tran_cd) 	,replace(d.ccessrate,'SELECT','') as cessrate,d.compcess as cess_amt,0 as cessrt_amt
,'' AS SBBILLNO ,'' SBDATE,'' as LineRule
,''  as uqc , ''as IT_NAME,'' AS Isservice, '' as HSNCODE
,RevCharge = '','' as AGAINSTGS,AmendDate = ''
,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
,SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate
,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = Cons_ac.i_tax
,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype =  '' ,AVL_ITC = 0
,0 as GSTRATE,InvoiceType ='Advance Adjustment'
,'' TransType,Reason = '','' as portcode,U_IMPORM = ''
,Category ='Advance Adjustment'
FROM STMAIN  H INNER JOIN
TaxAllocation D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
--where  H.entry_ty = 'ST' AND ( h.DATE BETWEEN @LStartDate AND @LEndDate)  --Commented by Priyanka B on 06012018 for Bug-31145
where H.entry_ty in ('ST','EI') AND ( h.DATE BETWEEN @LStartDate AND @LEndDate)  --Modified by Priyanka B on 06012018 for Bug-31145
uNION ALL
SELECT  H.Entry_ty, H.Tran_cd, ITSERIAL=Row_number()over(partition  by h.tran_cd,h.entry_ty,h.inv_no  order by h.tran_cd,h.entry_ty,h.inv_no ), H.INV_NO, H.DATE,0 as IT_CODE,0 as QTY,d.Taxable as GrossValue,d.Taxable AS Taxableamt
,case when (ISNULL(D.CGST_AMT,0) + ISNULL(d.SGST_AMT,0)) > 0 THEN  (CASE WHEN ISNULL(D.TAXRATE,0)> 0 THEN (ISNULL(D.TAXRATE,0) / 2) ELSE 0 END  ) ELSE 0 END as CGST_PER,D.CGST_AMT
,case when (ISNULL(D.CGST_AMT,0) + ISNULL(d.SGST_AMT,0)) > 0 THEN  (CASE WHEN ISNULL(D.TAXRATE,0)> 0 THEN (ISNULL(D.TAXRATE,0) / 2) ELSE 0 END )  ELSE 0 END as SGST_PER,D.SGST_AMT
,case when (ISNULL(D.IGST_AMT,0)) > 0 THEN  (ISNULL(D.TAXRATE,0))  ELSE 0 END as IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE, 0 as CGSRT_AMT, 0 as SGSRT_AMT,0 as IGSRT_AMT ,0 as GRO_AMT
,net_amt=(select SUM(isnull(Taxable,0)+isnull(cgst_amt,0)+isnull(SGST_AMT ,0)+isnull(IGST_AMT ,0)) from TaxAllocation  where entry_ty = h.entry_ty and Tran_cd =h.tran_cd) 	,replace(d.ccessrate,'SELECT','') as cessrate,d.compcess as cess_amt,0 as cessrt_amt
,'' AS SBBILLNO ,'' SBDATE,'' as LineRule
,''  as uqc , ''as IT_NAME,'' AS Isservice, '' as HSNCODE
,RevCharge = '','' as AGAINSTGS,AmendDate = ''
,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
,SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate
,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = Cons_ac.i_tax
,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype =  '' ,AVL_ITC = 0
,0 as GSTRATE,InvoiceType ='Advance Adjustment'
,'' TransType,Reason = '','' as portcode,U_IMPORM = ''
,Category ='Advance Adjustment'
FROM SBMAIN  H INNER JOIN
TaxAllocation D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)  where  H.entry_ty = 'S1' AND ( h.DATE BETWEEN @LStartDate AND @LEndDate))bb
where ((CGST_AMT + SGST_AMT + IGST_AMT) > 0) or ((CGSRT_AMT + SGSRT_AMT + IGSRT_AMT) > 0)  --Added by Priyanka B on 06012018 for Bug-31145
order by date,inv_no