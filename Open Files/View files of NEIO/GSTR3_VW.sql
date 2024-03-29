DROP VIEW [GSTR3_VW]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [GSTR3_VW]
AS
---- Outward details 
SELECT tranType ='OUTWARD',
	rate1 =(case when (ISNULL(CGST_PER,0) +ISNULL(SGST_PER,0)) > 0  THEN (ISNULL(CGST_PER,0) +ISNULL(SGST_PER,0)) 
	when (ISNULL(IGST_PER,0)) >  0  THEN ISNULL(IGST_PER,0) when (ISNULL(IGST_PER,0)+ISNULL(CGST_PER,0) +ISNULL(SGST_PER,0)) = 0  THEN ISNULL(GSTRATE,0)	END) ,
ST_TYPE = (case when Cons_st_type IN('INTRASTATE','INTERSTATE') and Cons_SUPP_TYPE  not in('Export','Import','SEZ','EOU') AND  ISNULL(POS,'') = (select TOP 1 state from vudyog..co_mast where dbname = DB_NAME()) THEN 'INTRASTATE'
when Cons_st_type IN('INTRASTATE','INTERSTATE') and Cons_SUPP_TYPE not in('Export','Import','SEZ','EOU') AND  (ISNULL(POS,'') <> (select state from vudyog..co_mast where dbname = DB_NAME())) THEN 'INTERSTATE' ELSE Cons_ST_TYPE  END)
,SUPP_TYPE =Cons_SUPP_TYPE,GSTIN = Cons_gstin  ,ADJ_TAXABLE =(Taxableamt * RIO)
,ADJ_CGST_AMT =(CGST_AMT * RIO),ADJ_SGST_AMT =(SGST_AMT * RIO),ADJ_IGST_AMT =(IGST_AMT * RIO),ADJ_CESS_AMT =(cess_amt * RIO)
,ADJ_CGSRT_AMT =(CGSRT_AMT * RIO),ADJ_SGSRT_AMT =(SGSRT_AMT * RIO),ADJ_IGSRT_AMT =(IGSRT_AMT * RIO),ADJ_CESSRT_AMT =(cessr_amt * RIO),ADJ_GRO_AMT =(GRO_AMT * RIO)
,*  FROM (
---STMAIN
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,h.EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,ccessrate as cessrate,compcess as cess_amt,comrpcess as cessr_amt  --Added by Priyanka B on 03082017
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
 ,RIO =case when (isnull((select sum(new_all)  from  STMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd and (( STMALL.entry_all + CAST(STMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then  isnull((select sum(new_all)  from  STMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( STMALL.entry_all + CAST(STMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) / h.net_amt  else 0 end 
 ,D.GSTRATE
FROM STMAIN H INNER JOIN
  STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) where h.entry_ty <> 'UB'
union all
---SRMAIN
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,''as expotype,0.00 as CGSRT_AMT, 0.00 as SGSRT_AMT,0.00 as IGSRT_AMT ,D.GRO_AMT,h.net_amt
--,0.00 as cess_amt  --Commented by Priyanka B on 03082017
,ccessrate as cessrate,compcess as cess_amt,0.00 as cessr_amt  --Added by Priyanka B on 03082017
,H.u_VESSEL as SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017 
 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (case when ISNULL(Cons_sp.GSTIN,'')= '' then Cons_sp.UID else Cons_sp.GSTIN end ) else  (case when ISNULL(Cons_ac.GSTIN,'')='' then Cons_ac.UID else Cons_ac.GSTIN end) end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (case when ISNULL(buyer_sp.GSTIN,'')='' then buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
 ,pos_std_cd = ST.GSTSCODE,pos = ST.GSTState 
  ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
 ,RIO =0
 ,D.GSTRATE
FROM  SRMAIN H INNER JOIN
  SrITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
  inner join srITREF  ref on (d.entry_ty =ref.entry_ty and ref.Tran_cd =d.Tran_cd and ref.Itserial =d.itserial )
  inner join STMAIN  ST on (ST.entry_ty =ref.rentry_ty and ref.Itref_tran =st.Tran_cd)
union all
---SBMAIN
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,h.EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
--,0.00 as cess_amt --Commented by Priyanka B on 03082017
,'0' as cessrate,0.00 as cess_amt,0.00 as cessr_amt  --Added by Priyanka B on 03082017
,'' AS SBBILLNO ,'' as SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'')='' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN  END) end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
 ,RIO =case when (isnull((select sum(new_all)  from  SBMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd and (( SBMALL.entry_all + CAST(SBMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then  isnull((select sum(new_all)  from  SBMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( SBMALL.entry_all + CAST(SBMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) / h.net_amt  else 0 end 
 ,D.GSTRATE
FROM  SBMAIN H INNER JOIN
  SBITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)

union all 
---DNMAIN
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0 as QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,ccessrate as cessrate,compcess as cess_amt,comrpcess as cessr_amt
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'')='' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END ) end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'') = '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'') = '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
  ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
 ,RIO =0
 ,D.GSTRATE
FROM DNMAIN H INNER JOIN
  DNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE')
union all 
---CNMAIN
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,0 as QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,ccessrate as cessrate,compcess as cess_amt,comrpcess as cessr_amt 
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) --Modified by Priyanka B on 09092017 
 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'')= '' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')= '' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END ) end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
 ,RIO =0
 ,D.GSTRATE
FROM CNMAIN H INNER JOIN
  CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE')

union all 
---BRMAIN
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,ccessrate as cessrate,compcess as cess_amt,comrpcess as cessr_amt 
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
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
 ,Cons_PANNO = ac.i_tax,buyer_PANNO = ac.i_tax,pinvno='' 
 ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
 ,RIO =0
 ,D.GSTRATE
FROM BRMAIN H INNER JOIN
	  BRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	 shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN	  
	  ac_mast ac ON (h.Ac_id  = ac.ac_id) WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BR'

union all
---CRMAIN 
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,ccessrate as cessrate,compcess as cess_amt,comrpcess as cessr_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
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
 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
 ,RIO =0
 ,D.GSTRATE
FROM CRMAIN H INNER JOIN
      CRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
      ac_mast Cons_ac ON (h.Ac_id = Cons_ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CR'
--- Refund Voucher
union all 
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,D.ccessrate as cessrate,D.compcess as cess_amt,comrpcess as cessr_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
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
,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
,RIO =0
,D.GSTRATE
FROM BPMAIN H INNER JOIN
 BPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
 IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
 shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN	  
 ac_mast ac ON (h.Ac_id  = ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='RV'  and h.paymentno in(select inv_no from BRMAIN WHERE entry_ty = 'BR'  union all select inv_no from cRMAIN WHERE entry_ty = 'CR' ))aa 
---- Inward details  
union all 
SELECT TranType ='INWARD',
  rate1 =(case when (ISNULL(CGST_PER,0) +ISNULL(SGST_PER,0)) > 0  THEN (ISNULL(CGST_PER,0) +ISNULL(SGST_PER,0)) when (ISNULL(IGST_PER,0)) >  0  THEN ISNULL(IGST_PER,0)
 when (ISNULL(IGST_PER,0)+ISNULL(CGST_PER,0) +ISNULL(SGST_PER,0)) = 0  THEN ISNULL(GSTRATE,0) END) ,
 /*
ST_TYPE = (case when Cons_st_type IN('INTRASTATE','INTERSTATE') and Cons_SUPP_TYPE  not in('Export','Import','SEZ','EOU') AND  ISNULL(POS,'') = (select TOP 1 state from vudyog..co_mast where dbname = DB_NAME()) THEN 'INTRASTATE'
when Cons_st_type IN('INTRASTATE','INTERSTATE') and Cons_SUPP_TYPE not in('Export','Import','SEZ','EOU') AND  (ISNULL(POS,'') <> (select state from vudyog..co_mast where dbname = DB_NAME())) THEN 'INTERSTATE' ELSE Cons_ST_TYPE  END)
*/
ST_TYPE = Cons_ST_TYPE,SUPP_TYPE =Cons_SUPP_TYPE,GSTIN = Cons_gstin  ,ADJ_TAXABLE =(Taxableamt * RIO)
,ADJ_CGST_AMT =(CGST_AMT * RIO),ADJ_SGST_AMT =(SGST_AMT * RIO),ADJ_IGST_AMT =(IGST_AMT * RIO),ADJ_CESS_AMT =(cess_amt * RIO)
,ADJ_CGSRT_AMT =(CGSRT_AMT * RIO),ADJ_SGSRT_AMT =(SGSRT_AMT * RIO),ADJ_IGSRT_AMT =(IGSRT_AMT * RIO),ADJ_CESSRT_AMT =(CessRT_amt * RIO),ADJ_GRO_AMT =(GRO_AMT * RIO)
,*  FROM (
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt,D.CCESSRATE as Cess_per,D.COMPCESS as Cess_amt,D.COMRPCESS As CessRT_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end)
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt,H.TRANSTATUS 
 ,gstype =case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end
 ,AVL_ITC = ISNULL(D.ECredit,0)
 ,RIO =case when (isnull((select sum(new_all)  from  PTMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd and (( PTMALL.entry_all + CAST(PTMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then  isnull((select sum(new_all)  from  ptMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( PTMALL.entry_all + CAST(PTMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0) / h.net_amt  else 0 end 
 ,D.GSTRATE
FROM PTMAIN H INNER JOIN
  PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) WHERE H.entry_ty IN('PT','P1')
---Purchase Return 
UNION ALL
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,d.sbillno as ORG_INVNO,d.sbdate as ORG_DATE,'' as EXPOTYPE ,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt,D.CCESSRATE as Cess_per,D.COMPCESS as Cess_amt,D.COMRPCESS As CessRT_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end)
 ,pos_std_cd =PT.GSTSCODE,pos = PT.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt,H.TRANSTATUS 
 ,gstype =case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end
 ,AVL_ITC = ISNULL(D.ECredit,0)
 ,RIO =0
 ,D.GSTRATE
FROM PRMAIN H INNER JOIN
  PRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id)
  INNER JOIN PRITREF REF ON (D.entry_ty = REF.entry_ty AND D.Tran_cd = REF.Tran_cd AND D.itserial =REF.Itserial)
  INNER JOIN PTMAIN PT ON (REF.Itref_tran =PT.Tran_cd AND REF.rentry_ty=PT.entry_ty)
---Service Purchase Bill
UNION ALL
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,'' as ORG_INVNO, '' as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt,'' as Cess_per,0.00 as Cess_amt,0.00 As CessRT_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end)
 ,pos_std_cd =H.GSTSCODE,pos = H.GSTState ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt,H.TRANSTATUS 
 ,gstype =case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end
 ,AVL_ITC = ISNULL(D.ECredit,0)
 ,RIO =case when (isnull((select sum(new_all)  from  EPMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd and (( EPMALL.entry_all + CAST(EPMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then  isnull((select sum(new_all)  from  EPMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( EPMALL.entry_all + CAST(EPMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0) / h.net_amt  else 0 end 
 ,D.GSTRATE
FROM EPMAIN H INNER JOIN
  EPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) 
--- ISD RECEIPT & Credit Note 
UNION ALL 
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,0.00  AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,'' as ORG_INVNO, '' as ORG_DATE,'' as EXPOTYPE,0.00 AS CGSRT_AMT, 0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT ,D.GRO_AMT,h.net_amt,'' as Cess_per,d.COMPCESS as Cess_amt,0.00 As CessRT_amt
,'' AS SBBILLNO ,'' SBDATE,'' AS LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
 ,Cons_ac_name = AC.ac_name
 ,Cons_SUPP_TYPE =ac.SUPP_TYPE
 ,seller_SUPP_TYPE =ac.SUPP_TYPE
 ,Cons_st_type =ac.st_type
 ,seller_st_type =ac.st_type
 ,Cons_gstin =(CASE WHEN ISNULL(ac.GSTIN,'') = '' THEN ac.UID  ELSE ac.GSTIN  END )
 ,seller_gstin = (CASE WHEN ISNULL(ac.GSTIN,'') = '' THEN ac.UID  ELSE ac.GSTIN  END )
 ,pos_std_cd ='',pos = '',Cons_pos =''
 ,seller_pos =''
 ,Cons_PANNO = ac.i_tax,seller_PANNO = ac.i_tax
 ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt,0 as TRANSTATUS 
 ,gstype =case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end
 ,AVL_ITC = ISNULL(D.ECredit,0)
 ,RIO =0
 ,D.GSTRATE
FROM JVMAIN H INNER JOIN
  JVITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  ac_mast ac ON (h.Ac_id = ac.ac_id)  WHERE H.entry_ty IN('J6','J8')
union all 
---DNMAIN
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,ccessrate as cessrate,compcess as cess_amt,comrpcess as cessr_amt
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'')='' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')='' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END ) end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then (CASE WHEN ISNULL(seller_sp.GSTIN,'') = '' THEN seller_sp.UID ELSE seller_sp.GSTIN END ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'') = '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end)
  ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = ISNULL(D.ECredit,0)
 ,RIO =0
 ,D.GSTRATE
FROM DNMAIN H INNER JOIN
  DNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) WHERE H.AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL')
union all 
---CNMAIN
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
,ccessrate as cessrate,compcess as cess_amt,comrpcess as cessr_amt 
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'')= '' THEN Cons_sp.UID ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'')= '' THEN Cons_ac.UID ELSE Cons_ac.GSTIN END ) end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(seller_sp.GSTIN,'')= '' THEN seller_sp.UID ELSE seller_sp.GSTIN END ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')='' THEN seller_ac.UID ELSE seller_ac.GSTIN END ) end)
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = ISNULL(D.ECredit,0)
 ,RIO =0
 ,D.GSTRATE
FROM CNMAIN H INNER JOIN
  CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id)WHERE H.AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL')
---Bank Payment Transaction
Union all
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt,'' as Cess_per,0.00 as Cess_amt,0.00 As CessRT_amt
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '',h.AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
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
 ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt,0 as TRANSTATUS 
 ,gstype =case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end
 ,AVL_ITC = 1
 ,RIO =0
 ,D.GSTRATE
FROM BPMAIN H INNER JOIN
	  BPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	 shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN	  
	  ac_mast ac ON (h.Ac_id  = ac.ac_id) WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BP'
---Cash Payment Transaction
union all
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt,'' as Cess_per,0.00 as Cess_amt,0.00 As CessRT_amt 
,'' AS SBBILLNO ,'' SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
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
 ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt, 0 as TRANSTATUS 
 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end
 ,AVL_ITC = 1
 ,RIO =0
 ,D.GSTRATE
FROM CPMAIN H INNER JOIN
      CPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
      ac_mast Cons_ac ON (h.Ac_id = Cons_ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CP'
---Self Invoice      
union all 
SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,h.EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
--,0.00 as cess_amt  --Commented by Priyanka B on 03082017
,ccessrate as cessrate,compcess as cess_amt,comrpcess as cessr_amt  --Added by Priyanka B on 03082017
,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
,h.inv_sr,h.l_yn
,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE
,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
 ,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
 --,Cons_SUPP_TYPE =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else  Cons_ac.SUPP_TYPE end)  --Commented by Priyanka B on 09092017
 ,Cons_SUPP_TYPE =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end) end )  --Modified by Priyanka B on 09092017
 ,seller_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.SUPP_TYPE else  seller_ac.SUPP_TYPE end)
 --,Cons_st_type =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end)  --Commented by Priyanka B on 09092017
 ,Cons_st_type =(case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end) end) --Modified by Priyanka B on 09092017
 ,seller_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.st_type else  seller_ac.st_type end)
 --,Cons_gstin =(case WHEN isnull(H.scons_id, 0) > 0 then  (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else  (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )end)  --Commented by Priyanka B on 09092017
 ,Cons_gstin = (case when seller_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  --Modified by Priyanka B on 09092017
			   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end) end) --Modified by Priyanka B on 09092017 
 ,seller_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(seller_sp.GSTIN,'') = ''  then seller_sp.UID else seller_sp.GSTIN end ) else  (CASE WHEN ISNULL(seller_ac.GSTIN,'')= '' THEN seller_ac.UID ELSE seller_ac.GSTIN END) end)
 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
 ,seller_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  seller_sp.state else  seller_ac.state  end)
 ,Cons_PANNO = Cons_ac.i_tax,seller_PANNO = seller_ac.i_tax
 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = ISNULL(D.ECredit,0)
 ,RIO =case when (isnull((select sum(new_all)  from  STMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd and (( STMALL.entry_all + CAST(STMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then  isnull((select sum(new_all)  from  STMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( STMALL.entry_all + CAST(STMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0) / h.net_amt  else 0 end 
 ,D.GSTRATE
FROM STMAIN H INNER JOIN
  STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
  shipto seller_sp ON (seller_sp.ac_id = h.Ac_id and seller_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
  ac_mast seller_ac ON (h.Ac_id = seller_ac.ac_id) where h.entry_ty = 'UB'
      
      )BB
GO
