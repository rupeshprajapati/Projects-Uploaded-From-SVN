If Exists(Select [name] From SysObjects Where xType='V' and [name]='GSTR6_VW')
Begin
	Drop View GSTR6_VW
End
GO
CREATE VIEW [dbo].[GSTR6_VW]
AS
SELECT ST_TYPE = case when isnull(Cons_ST_TYPE,'')='' then isnull(buyer_ST_TYPE,'') else isnull(Cons_ST_TYPE,'') end
,SUPP_TYPE = case when isnull(Cons_SUPP_TYPE,'')='' then isnull(buyer_SUPP_TYPE,'') else isnull(Cons_SUPP_TYPE,'') end
,GSTIN = case when isnull(Cons_gstin,'')='' then isnull(buyer_gstin,'') else isnull(Cons_gstin,'') end
,* FROM (
---PTMAIN ORIGINAL DETAILS
SELECT a='2',H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.pinvno as inv_no, H.pinvdt as date,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO='', ORG_DATE='',isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,D.LineRule,h.inv_sr,h.l_yn
,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ),d.gstrate
--,buyer_ac.gstin
,gstype =(CASE WHEN ISNULL(D.ECredit,0) = 1 THEN (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Input Goods' end) else 'Input Services' end) else 'Ineligible for ITC' END)
,AVL_ITC = ISNULL(D.ECredit,0)
,0.00 as ICGST_AMT,0.00 as ISGST_AMT,0.00 as IIGST_AMT
,Consgstin=H.OLDGSTIN
--,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   --end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
--,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,Cons_gstin = (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN else  buyer_ac.GSTIN end) 
,H.U_IMPORM
,H.PARTY_NM
,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,ICOMPCESS=0.00
,'' AS AGAINSTGS
,'' as buyer_state
FROM PTMAINAM H 
INNER JOIN PTITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)

UNION ALL

---PTMAIN AMENDMENT DETAILS
SELECT a='1',H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.pinvno, H.pinvdt,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.pinvno,'') <> ''  then  AMD.pinvno else H.pinvno end), ORG_DATE=(case when ISNULL(AMD.Pinvdt,'') <> ''  then  AMD.Pinvdt else H.Pinvdt  end)
,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,D.LineRule,h.inv_sr,h.l_yn
,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ),d.gstrate
--,buyer_ac.gstin
,gstype =(CASE WHEN ISNULL(D.ECredit,0) = 1 THEN (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Input Goods' end) else 'Input Services' end) else 'Ineligible for ITC' END)
,AVL_ITC = ISNULL(D.ECredit,0)
,0.00 as ICGST_AMT,0.00 as ISGST_AMT,0.00 as IIGST_AMT
,Consgstin=H.OLDGSTIN
--,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
	--	   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
--,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,Cons_gstin = (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN else  buyer_ac.GSTIN end)
,H.U_IMPORM
,H.PARTY_NM
,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,ICOMPCESS=0.00
,'' AS AGAINSTGS
,'' as buyer_state
FROM PTMAIN H 
INNER JOIN PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
LEFT OUTER JOIN PTMAINAM AMD ON (H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD )

UNION ALL

---ISD INVOICE PASSING DETAILS
SELECT a='6',H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=H.inv_no, ORG_DATE=H.date,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate
,D.COMPCESS
,'' as LineRule,h.inv_sr,h.l_yn,'' as Amenddate,0 as gstrate
--,buyer_ac.gstin
,'' as gstype,0 as AVL_ITC
,isnull(D.ICGST_AMT,0) as ICGST_AMT,isnull(D.ISGST_AMT,0) as ISGST_AMT,isnull(D.IIGST_AMT,0) as IIGST_AMT
,Consgstin=''
--,Cons_gstin='',buyer_gstin=''
,Cons_gstin = ''
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN else  buyer_ac.GSTIN end)
,H.U_IMPORM
,H.PARTY_NM
,Cons_st_type =''
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_SUPP_TYPE =''
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,D.ICOMPCESS
,'' AS AGAINSTGS
,buyer_state =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end)
FROM IBMAIN H 
INNER JOIN IBITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)

UNION ALL

---CNMAIN ORIGINAL DETAILS
SELECT a='7',H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=H.inv_no, ORG_DATE=H.date,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,0.00 as cess_amt,D.LineRule,h.inv_sr,h.l_yn
,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ),d.gstrate
--,buyer_ac.gstin
,'' as gstype,0 as AVL_ITC,0.00 as ICGST_AMT,0.00 as ISGST_AMT,0.00 as IIGST_AMT
,Consgstin = H.OLDGSTIN
--,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
	--	   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
--,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,Cons_gstin = (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN else  buyer_ac.GSTIN end)
,H.U_IMPORM
,H.PARTY_NM
,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,ICOMPCESS=0.00
,H.AGAINSTGS
,'' as buyer_state
FROM CNMAINAM H 
INNER JOIN CNITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) 

UNION ALL

---CNMAIN AMENDMENT DETAILS
SELECT a='7',H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.SBILLNO,'') <> ''  then  AMD.SBILLNO else D.SBILLNO end)
,ORG_DATE=(case when ISNULL(AMD.SBDATE,'') <> ''  then  AMD.SBDATE else D.SBDATE  end)
,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,0.00 as cess_amt,D.LineRule,h.inv_sr,h.l_yn
,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ),d.gstrate
--,buyer_ac.gstin
,'' as gstype,0 as AVL_ITC,0.00 as ICGST_AMT,0.00 as ISGST_AMT,0.00 as IIGST_AMT
,Consgstin = H.OLDGSTIN
--,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
	--	   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
--,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,Cons_gstin = (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN else  buyer_ac.GSTIN end)
,H.U_IMPORM
,H.PARTY_NM
,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,ICOMPCESS=0.00
,H.AGAINSTGS
,'' as buyer_state
FROM CNMAIN H 
INNER JOIN CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) 
LEFT OUTER JOIN CNITEMAM AMD ON (H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD )

UNION ALL

---DNMAIN ORIGINAL DETAILS
SELECT a='7',H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=H.inv_no, ORG_DATE=H.date,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,0.00 as cess_amt,D.LineRule,h.inv_sr,h.l_yn
,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ),d.gstrate
--,buyer_ac.gstin
,'' as gstype,0 as AVL_ITC,0.00 as ICGST_AMT,0.00 as ISGST_AMT,0.00 as IIGST_AMT
,Consgstin = H.OLDGSTIN
--,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
	--	   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
--,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,Cons_gstin = (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN else  buyer_ac.GSTIN end)
,H.U_IMPORM
,H.PARTY_NM
,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,ICOMPCESS=0.00
,H.AGAINSTGS
,'' as buyer_state
FROM DNMAINAM H 
INNER JOIN DNITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) 

UNION ALL

---DNMAIN AMENDMENT DETAILS
SELECT a='7',H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.SBILLNO,'') <> ''  then  AMD.SBILLNO else D.SBILLNO end)
,ORG_DATE=(case when ISNULL(AMD.SBDATE,'') <> ''  then  AMD.SBDATE else D.SBDATE  end)
,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,0.00 as cess_amt,D.LineRule,h.inv_sr,h.l_yn
,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ),d.gstrate
--,buyer_ac.gstin
,'' as gstype,0 as AVL_ITC,0.00 as ICGST_AMT,0.00 as ISGST_AMT,0.00 as IIGST_AMT
,Consgstin = H.OLDGSTIN
--,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
	--	   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
--,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,Cons_gstin = (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN else  buyer_ac.GSTIN end)
,H.U_IMPORM
,H.PARTY_NM
,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,ICOMPCESS=0.00
,H.AGAINSTGS
,'' as buyer_state
FROM DNMAIN H 
INNER JOIN DNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) 
LEFT OUTER JOIN DNITEMAM AMD ON (H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD )
)AA

--select * from GSTR6_VW