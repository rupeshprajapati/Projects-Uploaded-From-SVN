IF Exists(SELECT TYPE,NAME FROM SYSOBJECTS WHERE TYPE='V' AND name ='GSTR1_VW')
BEGIN
	DROP VIEW GSTR1_VW
END
GO 
/****** Object:  View [dbo].[GSTR1_VW]    Script Date: 12/29/2017 17:11:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[GSTR1_VW]
AS
SELECT 
/* --- commented by Suraj Kumawat for Bug-31075 date on 29-12-2017 
ST_TYPE = (case when Cons_st_type IN('INTRASTATE','INTERSTATE') and Cons_SUPP_TYPE  not in('Export','Import','SEZ','EOU') AND  ISNULL(POS,'') = (select TOP 1 state from vudyog..co_mast where dbname = DB_NAME()) THEN 'INTRASTATE'
when Cons_st_type IN('INTRASTATE','INTERSTATE') and Cons_SUPP_TYPE not in('Export','Import','SEZ','EOU') AND  (ISNULL(POS,'') <> (select state from vudyog..co_mast where dbname = DB_NAME())) THEN 'INTERSTATE' ELSE Cons_ST_TYPE  END)
,SUPP_TYPE =Cons_SUPP_TYPE,GSTIN =Cons_gstin */
--- Added by Suraj Kumawat for Bug-31075 date on 29-12-2017 
ST_TYPE = (case when buyer_st_type  IN('INTRASTATE','INTERSTATE') and buyer_SUPP_TYPE  not in('Export','Import','SEZ','EOU') AND  ISNULL(POS,'') = (select TOP 1 state from vudyog..co_mast where dbname = DB_NAME()) THEN 'INTRASTATE'
when buyer_st_type IN('INTRASTATE','INTERSTATE') and buyer_SUPP_TYPE not in('Export','Import','SEZ','EOU') AND  (ISNULL(POS,'') <> (select top 1 state from vudyog..co_mast where dbname = DB_NAME())) THEN 'INTERSTATE' ELSE buyer_ST_TYPE  END)
,SUPP_TYPE =buyer_SUPP_TYPE ,GSTIN =buyer_gstin 
,*  FROM (

---STMAIN Original Details
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=H.inv_no, ORG_DATE=H.date,h.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt 
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = ''
,'' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
-- ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)--Commented by Prajakta B. on 18082017
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )--Modified by Prajakta B. on 18082017
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)--Commented by Prajakta B. on 18082017
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)--Modified by Prajakta B. on 18082017	
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )end)--Commented by Prajakta B. on 18082017	
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )--Modified by Prajakta B. on 18082017	
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)--Modified by Prajakta B. on 18082017
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
--,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate
FROM STMAINAM H 
INNER JOIN STITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)

UNION ALL

---STMAIN Amendment details
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=(case when ISNULL(AMD.inv_no,'') <> ''  then  AMD.inv_no else H.inv_no end)
,ORG_DATE=(case when ISNULL(AMD.date,'') <> ''  then  AMD.date else H.date  end),h.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT 
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt
,isnull(d.comrpcess,0) as cessr_amt,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
-- ,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)--Commented by Prajakta B. on 18082017
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )--Modified by Prajakta B. on 18082017
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)--Commented by Prajakta B. on 18082017
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)--Modified by Prajakta B. on 18082017	
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )end)--Commented by Prajakta B. on 18082017	
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )--Modified by Prajakta B. on 18082017	
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)--Modified by Prajakta B. on 18082017
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
--,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate
FROM STMAIN H 
INNER JOIN STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
LEFT OUTER JOIN STMAINAM AMD ON (H.entry_ty =AMD.ENTRY_TY AND H.Tran_cd =AMD.TRAN_CD )

UNION ALL

---SRMAIN Original details
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,''as expotype
,0.00 as CGSRT_AMT, 0.00 as SGSRT_AMT,0.00 as IGSRT_AMT,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt
,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,0.00 as cessr_amt,H.u_VESSEL as SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = '','' AS AGAINSTGS
--,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,AmendDate = ''
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
--,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end ) 
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (case when ISNULL(Cons_sp.GSTIN,'')= '' then Cons_sp.UID else Cons_sp.GSTIN end ) else  (case when ISNULL(Cons_ac.GSTIN,'')='' then Cons_ac.UID else Cons_ac.GSTIN end) end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END ) 
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (case when ISNULL(buyer_sp.GSTIN,'')='' then buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd = ST.GSTSCODE,pos = ST.GSTState 
,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end) ---Added by Suraj kumawat date date on 26-08-2017 
,h.ecomac_id,d.gstrate
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
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,''as expotype
,0.00 as CGSRT_AMT, 0.00 as SGSRT_AMT,0.00 as IGSRT_AMT,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt
,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,0.00 as cessr_amt,H.u_VESSEL as SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
--,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end ) 
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (case when ISNULL(Cons_sp.GSTIN,'')= '' then Cons_sp.UID else Cons_sp.GSTIN end ) else  (case when ISNULL(Cons_ac.GSTIN,'')='' then Cons_ac.UID else Cons_ac.GSTIN end) end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END ) 
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (case when ISNULL(buyer_sp.GSTIN,'')='' then buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd = ST.GSTSCODE,pos = ST.GSTState 
,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end) ---Added by Suraj kumawat date date on 26-08-2017 
,h.ecomac_id,d.gstrate
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
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0)as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=H.inv_no, ORG_DATE=H.date,h.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,'0' as cessrate,0.00 as cess_amt,0.00 as cessr_amt,'' AS SBBILLNO ,'' as SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
--,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end) 
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'')='' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN  END) end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
--,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate
FROM SBMAINAM H 
INNER JOIN SBITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)

UNION ALL

---SBMAIN Amendment details
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0) as SGST_PER,isnull(D.SGST_AMT,0)as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.inv_no,'') <> ''  then  AMD.inv_no else H.inv_no end)
,ORG_DATE=(case when ISNULL(AMD.date,'') <> ''  then  AMD.date else H.date  end),h.EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,'0' as cessrate,0.00 as cess_amt,0.00 as cessr_amt,'' AS SBBILLNO ,'' as SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
--,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'')='' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN  END) end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
--,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate
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
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,'' as EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT,isnull(D.GRO_AMT,0)as GRO_AMT 
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
--,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'')='' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END ) end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'') = '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'') = '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
--,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate
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
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0)as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.SBILLNO,'') <> ''  then  AMD.SBILLNO else D.SBILLNO end)
,ORG_DATE=(case when ISNULL(AMD.SBDATE,'') <> ''  then  AMD.SBDATE else D.SBDATE  end),'' as EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT,isnull(D.GRO_AMT,0)as GRO_AMT 
,isnull(h.net_amt,0) as net_amt,d.CCESSRATE as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
--,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'')='' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END ) end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'') = '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'') = '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
--,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate
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
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER ,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,'' as EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT,isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = ''
,h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
--,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'')= '' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')= '' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END ) end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
--,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate
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
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0.00 as QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0)as CGST_PER ,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT
,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=(case when ISNULL(AMD.SBILLNO,'') <> ''  then  AMD.SBILLNO else D.SBILLNO end)
,ORG_DATE=(case when ISNULL(AMD.SBDATE,'') <> ''  then  AMD.SBDATE else D.SBDATE  end),'' as EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT,isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT,isnull(D.GRO_AMT,0) as GRO_AMT
,isnull(h.net_amt,0) as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = ''
,h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
--,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)
,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
--,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)
,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
--,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'')= '' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')= '' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END ) end)
,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
		   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
--,Consgstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then Cons_sp.GSTIN  else Cons_ac.GSTIN  END ) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.GSTIN  else  buyer_ac.GSTIN END) end)
,Consgstin = H.OLDGSTIN
,h.ecomac_id,d.gstrate
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
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT , isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt
,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
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
--,Consgstin = (case WHEN isnull(h.sAc_id, 0) > 0 then buyer_sp.GSTIN  else  ac.GSTIN  end)
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate
FROM BRMAINAM H 
INNER JOIN BRITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast ac ON (h.Ac_id  = ac.ac_id) 
WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BR'

UNION ALL 

---BRMAIN Amendment Details
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER ,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE
,isnull(D.CGSRT_AMT,0) as CGSRT_AMT , isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0) as net_amt
,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
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
--,Consgstin = (case WHEN isnull(h.sAc_id, 0) > 0 then buyer_sp.GSTIN  else  ac.GSTIN  end)
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate
FROM BRMAIN H 
INNER JOIN BRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN ac_mast ac ON (h.Ac_id  = ac.ac_id) 
WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BR'


union all
---CRMAIN Original Details
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0)as CGST_AMT ,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,isnull(D.CGSRT_AMT,0) as CGSRT_AMT
, isnull(D.SGSRT_AMT,0)as SGSRT_AMT ,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0)as GRO_AMT 
,isnull(h.net_amt,0) as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME,
(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = '',h.AGAINSTGS,AmendDate = ''
,Cons_ac_name =Cons_ac.ac_name,Cons_SUPP_TYPE =Cons_ac.SUPP_TYPE,buyer_SUPP_TYPE =Cons_ac.SUPP_TYPE,Cons_st_type =Cons_ac.st_type
,buyer_st_type =Cons_ac.st_type
,Cons_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,buyer_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,pos_std_cd =h.GSTSCODE,pos = h.gststate,Cons_pos =Cons_ac.state,buyer_pos =Cons_ac.state,Cons_PANNO = Cons_ac.i_tax
,buyer_PANNO = Cons_ac.i_tax
--,Consgstin = Cons_ac.GSTIN
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate
FROM CRMAINAM H 
INNER JOIN CRITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.Ac_id = Cons_ac.ac_id)  
WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CR'

union all
---CRMAIN Amendment Details
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,isnull(d.u_asseamt,0) AS Taxableamt
,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0)as CGST_AMT ,isnull(d.SGST_PER,0) as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0)as IGST_PER ,isnull(D.IGST_AMT,0) as IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,isnull(D.CGSRT_AMT,0) as CGSRT_AMT
, isnull(D.SGSRT_AMT,0)as SGSRT_AMT ,isnull(D.IGSRT_AMT,0) as IGSRT_AMT ,isnull(D.GRO_AMT,0)as GRO_AMT 
,isnull(h.net_amt,0) as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt,isnull(d.comrpcess,0) as cessr_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME,
(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
,Cons_ac_name =Cons_ac.ac_name,Cons_SUPP_TYPE =Cons_ac.SUPP_TYPE,buyer_SUPP_TYPE =Cons_ac.SUPP_TYPE,Cons_st_type =Cons_ac.st_type
,buyer_st_type =Cons_ac.st_type
,Cons_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,buyer_gstin =(CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END)
,pos_std_cd =h.GSTSCODE,pos = h.gststate,Cons_pos =Cons_ac.state,buyer_pos =Cons_ac.state,Cons_PANNO = Cons_ac.i_tax
,buyer_PANNO = Cons_ac.i_tax
--,Consgstin = Cons_ac.GSTIN
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate
FROM CRMAIN H 
INNER JOIN CRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN ac_mast Cons_ac ON (h.Ac_id = Cons_ac.ac_id)  
WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CR'

union all 

--- Refund Voucher Original Details
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=h.paymentno
, ORG_DATE=(Select date from brmain where inv_no=h.paymentno union all Select date from crmain where inv_no=h.paymentno)
,'' as EXPOTYPE,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT  
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0)as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt
,isnull(d.comrpcess,0) as cessr_amt,'' AS SBBILLNO ,'' SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
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
--- ,Cons_PANNO = ac.i_tax,buyer_PANNO = ac.i_tax
,Cons_PANNO = '',buyer_PANNO = ''
--,Consgstin = buyer_sp.GSTIN
,Consgstin = ac.gstin --H.OLDGSTIN
,0 as ecomac_id,d.gstrate
FROM BPMAINAM H 
INNER JOIN BPITEMAM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN	ac_mast ac ON (h.Ac_id  = ac.ac_id)  
WHERE H.ENTRY_TY ='RV'  
and h.paymentno in(select inv_no from BRMAIN WHERE entry_ty = 'BR'  union all select inv_no from cRMAIN WHERE entry_ty = 'CR' ) 

Union all

--- Refund Voucher Amendment Details
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY
,isnull(d.u_asseamt,0) AS Taxableamt,isnull(d.CGST_PER,0) as CGST_PER,isnull(D.CGST_AMT,0) as CGST_AMT,isnull(d.SGST_PER,0)as SGST_PER
,isnull(D.SGST_AMT,0) as SGST_AMT,isnull(d.IGST_PER,0) as IGST_PER,isnull(D.IGST_AMT,0) as IGST_AMT,ORG_INVNO=h.paymentno
, ORG_DATE=(Select date from brmain where inv_no=h.paymentno union all Select date from crmain where inv_no=h.paymentno)
,'' as EXPOTYPE,isnull(D.CGSRT_AMT,0) as CGSRT_AMT, isnull(D.SGSRT_AMT,0) as SGSRT_AMT,isnull(D.IGSRT_AMT,0) as IGSRT_AMT  
,isnull(D.GRO_AMT,0) as GRO_AMT,isnull(h.net_amt,0)as net_amt,d.ccessrate as cessrate,isnull(d.compcess,0) as cess_amt
,isnull(d.comrpcess,0) as cessr_amt,'' AS SBBILLNO ,'' SBDATE,D.LineRule,h.inv_sr,h.l_yn
--,IT.s_unit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.rateunit as uqc --Commented by Priyanka B on 11012019 for Bug-32062
,IT.IT_NAME
,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
--, IT.HSNCODE  --Commented by Priyanka B on 04012018 for Bug-31111
, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 04012018 for Bug-31111
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
--- ,Cons_PANNO = ac.i_tax,buyer_PANNO = ac.i_tax
,Cons_PANNO = '',buyer_PANNO = ''
--,Consgstin = buyer_sp.GSTIN
,Consgstin = H.OLDGSTIN
,0 as ecomac_id,d.gstrate
FROM BPMAIN H 
INNER JOIN BPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
LEFT OUTER JOIN shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) 
LEFT OUTER JOIN	ac_mast ac ON (h.Ac_id  = ac.ac_id)  
WHERE H.ENTRY_TY ='RV'  
and h.paymentno in(select inv_no from BRMAIN WHERE entry_ty = 'BR'  union all select inv_no from cRMAIN WHERE entry_ty = 'CR' ) 

)AA



GO


