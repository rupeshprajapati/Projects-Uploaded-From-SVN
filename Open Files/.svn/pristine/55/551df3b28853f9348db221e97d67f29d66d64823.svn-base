IF EXISTS(SELECT * FROM SYSOBJECTS WHERE [NAME]='GSTR9_VW' AND XTYPE='V')
BEGIN
	DROP VIEW [GSTR9_VW]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[GSTR9_VW]
AS
SELECT 
ST_TYPE = Cons_ST_TYPE
,SUPP_TYPE =Cons_SUPP_TYPE
,GSTIN = isnull(Cons_gstin,'')
,*  FROM (

--INWARD TRANSACTIONS START

--- Self Inovice 
SELECT  a=1,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER 
,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=H.inv_no, ORG_DATE=H.date 
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT,ISNULL(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt,isnull(D.COMRPCESS,0) As CessR_amt
,'Taxable' as LineRule  
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE ='' 
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =''
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN  end)
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN else  seller_ac.GSTIN  end)
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,h.OLDGSTIN,ecomac_id='',d.gstrate,ITCSEC =SPACE (50)
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM STMAIN H INNER JOIN
  STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) WHERE H.entry_ty ='UB'
  UNION ALL
  
  /* Amendment for self inovice details */
SELECT a=2, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER 
,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=H.inv_no, ORG_DATE=H.date  
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT,ISNULL(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt,isnull(D.COMRPCESS,0) As CessRT_amt
,'Taxable' as LineRule  
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE ='' 
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =''
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN  end)
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN else  seller_ac.GSTIN  end)
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,h.OLDGSTIN,ecomac_id='',d.gstrate,ITCSEC =SPACE (50)
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM STMAINAM H INNER JOIN
  STITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) WHERE H.entry_ty ='UB'
  union all 

--- Purchase Transaction
SELECT  a=3,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE 
,D.IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT
,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0)as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0)as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.pinvno,'') <> ''  then  AMD.pinvno else H.pinvno end), ORG_DATE=(case when ISNULL(AMD.Pinvdt,'') <> ''  then  AMD.Pinvdt else H.Pinvdt  end)
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT 
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0)as net_amt,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt
,isnull(D.COMRPCESS,0) As CessRT_amt,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin = (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN else  seller_ac.GSTIN end) 
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,h.OLDGSTIN,ecomac_id='',d.gstrate,ISNULL(d.ITCSEC,'')AS ITCSEC
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM PTMAIN H INNER JOIN
  PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) 
  LEFT OUTER JOIN PTMAINAM AMD ON(H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD )
    
/*Purchase Transaction Amend details */
 Union all
 SELECT  a=4,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE 
,D.IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT
,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0)as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0)as IGST_AMT
,ORG_INVNO=H.inv_no, ORG_DATE=H.date
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT 
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0)as net_amt,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt
,isnull(D.COMRPCESS,0) As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin = (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN else  seller_ac.GSTIN end) 
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,h.OLDGSTIN,ecomac_id='',d.gstrate,ISNULL(d.ITCSEC,'')AS ITCSEC
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM PTMAINAM H INNER JOIN
  PTITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id)
  
  ---Purchase Return Transaction
UNION ALL
SELECT  a=5,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D.IT_CODE,D.QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0)as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,(case when isnull(amd.inv_no,'') = '' then d.sbillno else amd.inv_no end ) as ORG_INVNO
,(case when isnull(amd.date,'') = '' then d.sbdate else amd.date end ) as ORG_DATE
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt,isnull(D.COMRPCESS,0) As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS
 ,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN else  seller_ac.GSTIN end)
 --,pos_std_cd =PT.GSTSCODE,pos = PT.gststate 
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate 
 ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,OLDGSTIN = (case when isnull(h.OLDGSTIN,'') = '' then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end) else h.OLDGSTIN end )
 ,ecomac_id='',d.gstrate,ITCSEC =SPACE (50)
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
 FROM PRMAIN H INNER JOIN
  PRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id)
  left outer join PRMAINAM amd on(h.Entry_ty = amd.entry_ty and h.Tran_cd =amd.tran_cd)
  UNION ALL

/*Amendment details of Purchase Return Transaction*/
SELECT a=6, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D.IT_CODE,D.QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0)as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,d.sbillno as ORG_INVNO, d.sbdate as ORG_DATE
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt,isnull(D.COMRPCESS,0) As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS
 ,AmendDate = ''
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN else  seller_ac.GSTIN end)
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
  ,OLDGSTIN =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN end)
 ,ecomac_id='',d.gstrate,ITCSEC =SPACE (50)
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
 FROM PRMAINAM H INNER JOIN
  PRITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id)

  ---Debit Note Transaction
UNION ALL
SELECT  a=7,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0)as CGST_AMT
,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO= (case when isnull(AMD.pinvno,'') = '' and isnull(AMD.inv_no,'')= '' then  d.sbillno else (case when ISNULL(amd.PINVNO,'') = '' then amd.inv_no else amd.PINVNO end ) end)
,ORG_DATE= (case when isnull(AMD.PINVDT,'') = '' and isnull(AMD.DATE,'')= '' then  d.sbdate else (case when ISNULL(amd.PINVDT,'') = '' then amd.DATE else amd.PINVDT end ) end)
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt ,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt,isnull(D.COMRPCESS,0) As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',H.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN  else  Cons_ac.GSTIN  end)
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN  else  seller_ac.GSTIN  end)
 ,pos_std_cd =H.GSTSCODE,pos = H.GSTState ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,h.OLDGSTIN  ,ecomac_id='' ,d.gstrate,ITCSEC =SPACE (50)
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
 FROM DNMAIN H INNER JOIN
  DNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id)
  LEFT OUTER JOIN DNMAINAM AMD ON (H.Tran_cd =AMD.TRAN_CD  AND H.entry_ty =AMD.ENTRY_TY)
  WHERE H.AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL')
    
/*Amendment table details for Debit Note Transaction*/
UNION ALL
SELECT  a=8,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0)as CGST_AMT
,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,d.sbillno as ORG_INVNO, d.sbdate as ORG_DATE
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt ,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt,isnull(D.COMRPCESS,0) As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',H.AGAINSTGS,AmendDate = ''
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN  else  Cons_ac.GSTIN  end)
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN  else  seller_ac.GSTIN  end)
 ,pos_std_cd =H.GSTSCODE,pos = H.GSTState ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,h.OLDGSTIN  ,ecomac_id='' ,d.gstrate,ITCSEC =SPACE (50)
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
 FROM DNMAINAM H INNER JOIN
  DNITEMAM D ON (H.ENTRY_TY = D.ENTRY_TY AND H.TRAN_CD = D.TRAN_CD) INNER JOIN
  IT_MAST IT ON (D.IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) WHERE H.AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL')
  
---Credit Note Transaction
UNION ALL
SELECT a=9, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO= (case when isnull(AMD.pinvno,'') = '' and isnull(AMD.inv_no,'')= '' then  d.sbillno else (case when ISNULL(amd.PINVNO,'') = '' then amd.inv_no else amd.PINVNO end ) end)
,ORG_DATE= (case when isnull(AMD.PINVDT,'') = '' and isnull(AMD.DATE,'')= '' then  d.sbdate else (case when ISNULL(amd.PINVDT,'') = '' then amd.DATE else amd.PINVDT end ) end)
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt,isnull(D.COMRPCESS,0) As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',H.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN  end)
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN else  seller_ac.GSTIN  end)
 ,pos_std_cd =H.GSTSCODE,pos = H.GSTState ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,h.OLDGSTIN  ,ecomac_id='' ,d.gstrate,ITCSEC =SPACE (50)
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM CNMAIN H INNER JOIN
  CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) 
  LEFT OUTER JOIN CNMAINAM AMD ON (H.Tran_cd =AMD.TRAN_CD AND H.entry_ty =amd.entry_ty)
  WHERE H.AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL')
/*Amendment details of Credit Note Transaction*/
UNION ALL
SELECT a=10, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,d.sbillno as ORG_INVNO, d.sbdate as ORG_DATE
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,D.CCESSRATE as Cess_per,isnull(D.COMPCESS,0) as Cess_amt,isnull(D.COMRPCESS,0) As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',H.AGAINSTGS,AmendDate = ''
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 ,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 ,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN else  Cons_ac.GSTIN  end) 	
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN else  seller_ac.GSTIN  end) 	
 ,pos_std_cd =H.GSTSCODE,pos = H.GSTState ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,h.OLDGSTIN  ,ecomac_id='' ,d.gstrate,ITCSEC =SPACE (50)
 ,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM CNMAINAM H INNER JOIN
  CNITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) WHERE H.AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL')
  ---Service Purchase Bill
UNION ALL
SELECT  a=11,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY
,isnull(d.u_asseamt,0)  AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=case when isnull(amd.pinvno,'')= '' then  H.Pinvno else amd.pinvno end , ORG_DATE=case when isnull(amd.pinvdt,'')= '' then  H.pinvdt else amd.pinvdt end
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0)as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,'' as Cess_per,0.00 as Cess_amt,0.00 As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN  else  Cons_ac.GSTIN end)
,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN  else  seller_ac.GSTIN end)
,pos_std_cd =H.GSTSCODE,pos = H.GSTState ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
,h.OLDGSTIN,ecomac_id='',d.gstrate,ISNULL(d.ITCSEC,'')AS ITCSEC
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM EPMAIN H INNER JOIN
EPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id)
left outer join epmainam amd on (h.Tran_cd =amd.tran_cd and h.entry_ty = amd.entry_ty)
  
/* Amend details of Service Purchase Bill*/ 
UNION ALL
SELECT  a=12,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY
,isnull(d.u_asseamt,0)  AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=H.inv_no, ORG_DATE=H.date  
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0)as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,'' as Cess_per,0.00 as Cess_amt,0.00 As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.GSTIN  else  Cons_ac.GSTIN end)
,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.GSTIN  else  seller_ac.GSTIN end)
,pos_std_cd =H.GSTSCODE,pos = H.GSTState ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
,h.OLDGSTIN,ecomac_id='',d.gstrate,ISNULL(d.ITCSEC,'')AS ITCSEC
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM EPMAINAM H INNER JOIN
EPITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id)
  
  
--- ISD RECEIPT & Credit Note 
UNION ALL 
SELECT  a=13,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,0.00  AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0)as CGST_AMT ,isnull(d.SGST_PER,0)as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,'' as ORG_INVNO, '' as ORG_DATE
,EXPOTYPE=''
,0.00 AS CGSRT_AMT, 0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,'' as Cess_per,isnull(d.COMPCESS,0)  as Cess_amt,0.00 As CessRT_amt,'' AS LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
,Cons_ac_name = AC.ac_name
,Cons_SUPP_TYPE =ac.SUPP_TYPE
,seller_SUPP_TYPE =ac.SUPP_TYPE
,Cons_st_type =ac.st_type
,seller_st_type =ac.st_type
,Cons_gstin = ac.GSTIN  ,seller_gstin = ac.GSTIN  	
,pos_std_cd ='',pos = '',Cons_pos =''
,seller_pos =''
,Cons_PANNO = ac.i_tax,seller_PANNO = ac.i_tax
,'' as OLDGSTIN,ecomac_id='',d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM JVMAIN H INNER JOIN
JVITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
ac_mast ac ON (h.Ac_id = ac.ac_id)  WHERE H.entry_ty IN('J6','J8')
union all 
---Bank Payment Amendment Transaction
SELECT  a=14,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0)as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT 
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt,'' as Cess_per,isnull(d.COMPCESS,0) as Cess_amt,isnull(d.COMRPCESS,0) As CessRT_amt,D.LineRule   --Added By Prajakta b. On 12082017
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS
,AmendDate =(case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.mailname else  ac.ac_name end)
,Cons_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.Supp_type else  ac.Supp_type  end)
,buyer_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  ac.SUPP_TYPE end)
,Cons_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,buyer_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,Cons_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then buyer_sp.GSTIN  else  ac.GSTIN  end)
,buyer_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then buyer_sp.GSTIN else  ac.GSTIN end) 
,pos_std_cd =h.GSTSCODE,pos = h.gststate 
,Cons_pos =buyer_sp.state 
,buyer_pos =buyer_sp.state
,Cons_PANNO = ac.i_tax,buyer_PANNO = ac.i_tax
,h.OLDGSTIN,ecomac_id='',d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM BPMAIN H INNER JOIN
BPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN	  
ac_mast ac ON (h.Ac_id  = ac.ac_id) WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BP'

UNION ALL 
/*Bank Payment Original details*/
SELECT  a=15,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0)as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT 
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt,'' as Cess_per,isnull(d.COMPCESS,0) as Cess_amt,isnull(d.COMRPCESS,0) As CessRT_amt,D.LineRule   --Added By Prajakta b. On 12082017
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS
,AmendDate = ''
,Cons_ac_name =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.mailname else  ac.ac_name end)
,Cons_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.Supp_type else  ac.Supp_type  end)
,buyer_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  ac.SUPP_TYPE end)
,Cons_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,buyer_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,Cons_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then buyer_sp.GSTIN  else  ac.GSTIN  end)
,buyer_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then buyer_sp.GSTIN else  ac.GSTIN end) 
,pos_std_cd =h.GSTSCODE,pos = h.gststate 
,Cons_pos =buyer_sp.state 
,buyer_pos =buyer_sp.state
,Cons_PANNO = ac.i_tax,buyer_PANNO = ac.i_tax
,h.OLDGSTIN,ecomac_id='',d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM BPMAINAM H INNER JOIN
BPITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN	  
ac_mast ac ON (h.Ac_id  = ac.ac_id) WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BP'

union all
---Cash Payment Amendment Transaction
SELECT  a=16,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT
,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0)as SGST_AMT ,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0)as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0)as SGSRT_AMT ,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,'' as Cess_per,isnull(d.COMPCESS,0) as Cess_amt,isnull(d.COMRPCESS,0) As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =Cons_ac.ac_name
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
,h.OLDGSTIN,ecomac_id='',d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM CPMAIN H INNER JOIN
CPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
ac_mast Cons_ac ON (h.Ac_id = Cons_ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CP'

/* Original Cash payment advance */
Union all
SELECT a=17, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT
,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0)as SGST_AMT ,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0)as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE
,EXPOTYPE=''
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0)as SGSRT_AMT ,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,'' as Cess_per,isnull(d.COMPCESS,0) as Cess_amt,isnull(d.COMRPCESS,0) As CessRT_amt,D.LineRule
,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = ''
,Cons_ac_name =Cons_ac.ac_name
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
,h.OLDGSTIN,ecomac_id='',d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM CPMAINam H INNER JOIN
CPITEMam D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
ac_mast Cons_ac ON (h.Ac_id = Cons_ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CP'

--INWARD TRANSACTIONS END

UNION ALL

--OUTWARD TRANSACTIONS START
---STMAIN Original Details
SELECT  a=18,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=H.inv_no, ORG_DATE=H.date,h.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt 
--,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE
,D.LineRule,h.inv_sr,h.l_yn,IT.rateunit as uqc,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = ''
,'' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM STMAINAM H 
INNER JOIN STITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
WHERE H.ENTRY_TY<>'UB'

UNION ALL

---STMAIN Amendment details
SELECT a=19, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=(case when ISNULL(AMD.inv_no,'') <> ''  then  AMD.inv_no else H.inv_no end)
,ORG_DATE=(case when ISNULL(AMD.date,'') <> ''  then  AMD.date else H.date  end),h.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT 
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt
,isnull(d.comrpcess,0) as cessr_amt
--,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM STMAIN H 
INNER JOIN STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
LEFT OUTER JOIN STMAINAM AMD ON (H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD )
WHERE H.ENTRY_TY<>'UB'

UNION ALL

---SRMAIN Original details
SELECT  a=20,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,''as expotype
,0.00 as CGSRT_AMT, 0.00 as SGSRT_AMT,0.00 as IGSRT_AMT,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt
,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,0.00 as cessr_amt
--,H.u_VESSEL as SBBILLNO ,H.U_SBDT AS SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '','' AS AGAINSTGS
,AmendDate = ''
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end ) 
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END ) 
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (case when ISNULL(buyer_sp.GSTIN,'')='' then buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd = ST.GSTSCODE,pos = ST.GSTState 
,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM  SRMAINAM H 
INNER JOIN SrITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
inner join srITREF  ref on (d.entry_ty =ref.entry_ty and ref.Tran_cd =d.Tran_cd and ref.Itserial =d.itserial )
inner join STMAIN  ST on (ST.entry_ty =ref.rentry_ty and ref.Itref_tran =st.Tran_cd)

UNION ALL

---SRMAIN Amendment details
SELECT a=21, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,''as expotype
,0.00 as CGSRT_AMT, 0.00 as SGSRT_AMT,0.00 as IGSRT_AMT,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt
,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,0.00 as cessr_amt
--,H.u_VESSEL as SBBILLNO ,H.U_SBDT AS SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end ) 
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END ) 
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (case when ISNULL(buyer_sp.GSTIN,'')='' then buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd = ST.GSTSCODE,pos = ST.GSTState 
,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM  SRMAIN H 
INNER JOIN SrITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
inner join srITREF  ref on (d.entry_ty =ref.entry_ty and ref.Tran_cd =d.Tran_cd and ref.Itserial =d.itserial )
inner join STMAIN  ST on (ST.entry_ty =ref.rentry_ty and ref.Itref_tran =st.Tran_cd)
LEFT OUTER JOIN SRMAINAM AMD ON (H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD )

UNION ALL

---SBMAIN Original details
SELECT  a=22,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0)as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=H.inv_no, ORG_DATE=H.date,h.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,'0' as cessrate,0.00 as cess_amt,0.00 as cessr_amt
--,'' AS SBBILLNO ,'' as SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM SBMAINAM H 
INNER JOIN SBITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)

UNION ALL

---SBMAIN Amendment details
SELECT  a=23,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0)as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.inv_no,'') <> ''  then  AMD.inv_no else H.inv_no end)
,ORG_DATE=(case when ISNULL(AMD.date,'') <> ''  then  AMD.date else H.date  end),h.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,'0' as cessrate,0.00 as cess_amt,0.00 as cessr_amt
--,'' AS SBBILLNO ,'' as SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM  SBMAIN H 
INNER JOIN SBITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
LEFT OUTER JOIN SBMAINAM AMD ON (H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD )

UNION ALL

---DNMAIN Original Details
SELECT  a=24,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE
--,'' as EXPOTYPE
,H.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT,isnull(D.GRO_AMT,0)as GRO_AMT 
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
--,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'') = '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'') = '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM DNMAINAM H 
INNER JOIN DNITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) 
WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE')

UNION ALL

---DNMAIN Amendment Details
SELECT a=25, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.SBILLNO,'') <> ''  then  AMD.SBILLNO else D.SBILLNO end)
,ORG_DATE=(case when ISNULL(AMD.SBDATE,'') <> ''  then  AMD.SBDATE else D.SBDATE  end)
--,'' as EXPOTYPE
,H.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT,isnull(D.GRO_AMT,0)as GRO_AMT 
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
--,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'') = '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'') = '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM DNMAIN H 
INNER JOIN DNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) 
LEFT OUTER JOIN DNITEMAM AMD ON (H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD AND D.ITSERIAL=AMD.ITSERIAL)
WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE')

UNION ALL 

---CNMAIN Original Details
SELECT a=26, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER ,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE
--,'' as EXPOTYPE
,H.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT,isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
--,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = ''
,h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM CNMAINAM H 
INNER JOIN CNITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) 
WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE')

UNION ALL 

---CNMAIN Amendment Details
SELECT  a=27,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER ,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.SBILLNO,'') <> ''  then  AMD.SBILLNO else D.SBILLNO end)
,ORG_DATE=(case when ISNULL(AMD.SBDATE,'') <> ''  then  AMD.SBDATE else D.SBDATE  end)
--,'' as EXPOTYPE
,H.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT,isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
--,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = ''
,h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM CNMAIN H 
INNER JOIN CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) 
LEFT OUTER JOIN CNITEMAM AMD ON (H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD AND D.ITSERIAL=AMD.ITSERIAL)
WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE')

UNION ALL

---BRMAIN Original Details
SELECT a=28, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT , isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt
,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
--,'' AS SBBILLNO ,'' SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '',h.AGAINSTGS
,AmendDate = ''
,Cons_ac_name =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.mailname else  ac.ac_name end)
,Cons_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.Supp_type else  ac.Supp_type  end)
,buyer_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  ac.SUPP_TYPE end)
,Cons_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,buyer_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,Cons_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'')='' THEN  buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(ac.GSTIN,'')='' THEN ac.UID ELSE ac.GSTIN END ) end)
,buyer_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'')='' THEN  buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(ac.GSTIN,'')='' THEN ac.UID ELSE ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate 
,Cons_pos =buyer_sp.state 
,buyer_pos =buyer_sp.state
,Cons_PANNO = ac.i_tax,buyer_PANNO = ac.i_tax
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM BRMAINAM H 
INNER JOIN BRITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast ac ON (h.Ac_id  = ac.ac_id) 
WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BR'

UNION ALL 

---BRMAIN Amendment Details
SELECT a=29, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT , isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt
,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
--,'' AS SBBILLNO ,'' SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '',h.AGAINSTGS
,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.mailname else  ac.ac_name end)
,Cons_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.Supp_type else  ac.Supp_type  end)
,buyer_SUPP_TYPE =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  ac.SUPP_TYPE end)
,Cons_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,buyer_st_type =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.st_type else  ac.st_type end)
,Cons_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'')='' THEN  buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(ac.GSTIN,'')='' THEN ac.UID ELSE ac.GSTIN END ) end)
,buyer_gstin =(case WHEN isnull(h.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'')='' THEN  buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(ac.GSTIN,'')='' THEN ac.UID ELSE ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate 
,Cons_pos =buyer_sp.state 
,buyer_pos =buyer_sp.state
,Cons_PANNO = ac.i_tax,buyer_PANNO = ac.i_tax
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM BRMAIN H 
INNER JOIN BRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast ac ON (h.Ac_id  = ac.ac_id) 
WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BR'


union all
---CRMAIN Original Details
SELECT  a=30,H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0)as CGST_AMT ,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,isnull(D.CGSRT_AMT,0) as CGSRT_AMT
, isnull(D.SGSRT_AMT,0)as SGSRT_AMT ,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0)as GRO_AMT 
,isnull(h.net_amt,0) as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
--,'' AS SBBILLNO ,'' SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc 
,IT.IT_NAME,
(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '',h.AGAINSTGS,AmendDate = ''
,Cons_ac_name =Cons_ac.ac_name,Cons_SUPP_TYPE =Cons_ac.SUPP_TYPE,buyer_SUPP_TYPE =Cons_ac.SUPP_TYPE,Cons_st_type =Cons_ac.st_type
,buyer_st_type =Cons_ac.st_type
,Cons_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,buyer_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,pos_std_cd =h.GSTSCODE,pos = h.gststate,Cons_pos =Cons_ac.state,buyer_pos =Cons_ac.state,Cons_PANNO = Cons_ac.i_tax
,buyer_PANNO = Cons_ac.i_tax
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM CRMAINAM H 
INNER JOIN CRITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.Ac_id = Cons_ac.ac_id)  
WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CR'

union all
---CRMAIN Amendment Details
SELECT a=31, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0)as CGST_AMT ,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,isnull(D.CGSRT_AMT,0) as CGSRT_AMT
, isnull(D.SGSRT_AMT,0)as SGSRT_AMT ,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0)as GRO_AMT 
,isnull(h.net_amt,0) as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
--,'' AS SBBILLNO ,'' SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME,
(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =Cons_ac.ac_name,Cons_SUPP_TYPE =Cons_ac.SUPP_TYPE,buyer_SUPP_TYPE =Cons_ac.SUPP_TYPE,Cons_st_type =Cons_ac.st_type
,buyer_st_type =Cons_ac.st_type
,Cons_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,buyer_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,pos_std_cd =h.GSTSCODE,pos = h.gststate,Cons_pos =Cons_ac.state,buyer_pos =Cons_ac.state,Cons_PANNO = Cons_ac.i_tax
,buyer_PANNO = Cons_ac.i_tax
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM CRMAIN H 
INNER JOIN CRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.Ac_id = Cons_ac.ac_id)  
WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CR'

union all 

--- Refund Voucher Original Details
SELECT a=32, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=h.paymentno
, ORG_DATE=(Select date from brmain where inv_no=h.paymentno union all Select date from crmain where inv_no=h.paymentno)
,'' as EXPOTYPE,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT  
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0)as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt
,isnull(d.comrpcess,0) as cessr_amt
--,'' AS SBBILLNO ,'' SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '',h.AGAINSTGS,AmendDate = ''
,Cons_ac_name =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.mailname else  ac.ac_name end)
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
,Consgstin = ac.gstin
,0 as ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM BPMAINAM H 
INNER JOIN BPITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN	ac_mast ac ON (h.Ac_id  = ac.ac_id)  
WHERE H.ENTRY_TY ='RV'  
and h.paymentno in(select inv_no from BRMAIN WHERE entry_ty = 'BR'  union all select inv_no from cRMAIN WHERE entry_ty = 'CR' ) 

Union all

--- Refund Voucher Amendment Details
SELECT a=33, H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=h.paymentno
, ORG_DATE=(Select date from brmain where inv_no=h.paymentno union all Select date from crmain where inv_no=h.paymentno)
,'' as EXPOTYPE,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT  
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0)as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt
,isnull(d.comrpcess,0) as cessr_amt
--,'' AS SBBILLNO ,'' SBDATE
,D.LineRule,h.inv_sr,h.l_yn
,IT.rateunit as uqc
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(h.sAc_id, 0) > 0 then  buyer_sp.mailname else  ac.ac_name end)
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
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate,ITCSEC =SPACE (50)
,GoodsType = (case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) 
						else 'Input Services' end)
FROM BPMAIN H 
INNER JOIN BPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN	ac_mast ac ON (h.Ac_id  = ac.ac_id)  
WHERE H.ENTRY_TY ='RV'  
and h.paymentno in(select inv_no from BRMAIN WHERE entry_ty = 'BR'  union all select inv_no from cRMAIN WHERE entry_ty = 'CR' ) 

--OUTWARD TRANSACTIONS END
)AA
GO


