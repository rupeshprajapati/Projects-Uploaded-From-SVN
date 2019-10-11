IF EXISTS (SELECT XTYPE,name FROM SYSOBJECTS WHERE XTYPE ='V' AND name = 'GSTR3B_VW')
BEGIN
	DROP VIEW  GSTR3B_VW
END
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[GSTR3B_VW]
AS
	--- stmain
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D .CGST_AMT, d .SGST_PER,D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
	D .GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE,
	ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
	,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
	, location = h.gststate ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
	,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
	,0.00 AS CGSRT_AMT, 0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT ,gst_std_cd = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END),
	D.LineRule,'' AS AGAINSTGS
	,0.00 as cess_amt,h.net_amt ,UID = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.UID, '') ELSE isnull(ac.UID, '') END)
	---,adjust_amt =case when ((ROW_NUMBER()OVER(partition by  h.Inv_no order by h.inv_no ))) = 1  then isnull((select sum(new_all)  from  STMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( STMALL.entry_all + CAST(STMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) else 0 end 
	--,adjust_amt =isnull((select sum(new_all)  from  STMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( STMALL.entry_all + CAST(STMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) 
	,RIO =case when (isnull((select sum(new_all)  from  STMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd and (( STMALL.entry_all + CAST(STMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then  isnull((select sum(new_all)  from  STMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( STMALL.entry_all + CAST(STMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) / h.net_amt  else 0 end 
	,avl = 1,ITCSEC =SPACE (50),org_no=SPACE(50),org_date =cast('' as smalldatetime ),rentry_ty='',H.EXPOTYPE
	FROM STMAIN H INNER JOIN STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
    IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
    ac_mast ac ON (h.ac_id = ac.ac_id) LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)
	Union all 
	---srmain
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D .CGST_AMT, d .SGST_PER,D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
	D .GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE,
	ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
	,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
	, location = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.state, '') ELSE isnull(ac.state , '') END),SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
	,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
	,0.00 AS CGSRT_AMT, 0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT ,gst_std_cd = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END),
	D.LineRule,'' AS AGAINSTGS
	,0.00 as cess_amt,h.net_amt ,UID = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.UID, '') ELSE isnull(ac.UID, '') END)
	---,adjust_amt =case when ((ROW_NUMBER()OVER(partition by  h.Inv_no order by h.inv_no ))) = 1  then isnull((select sum(new_all)  from  SRMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( SRMALL.entry_all + CAST(SRMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) else 0 end 
	,RIO =case when (isnull((select sum(new_all)  from  SRMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( SRMALL.entry_all + CAST(SRMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then( isnull((select sum(new_all)  from  SRMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( SRMALL.entry_all + CAST(SRMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0)) / H.net_amt  else 0 end 
	,avl = 1,ITCSEC =SPACE (50),org_no=SPACE(50),org_date =cast('' as smalldatetime ),rentry_ty='',EXPOTYPE = ''
	FROM SRMAIN H INNER JOIN SRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
    IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
    ac_mast ac ON (h.ac_id = ac.ac_id) LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)
    Union all 
	--SBMAIN 
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D .CGST_AMT, d .SGST_PER,D.SGST_AMT, d .IGST_PER, D.IGST_AMT,
	D .GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE,
	ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
	,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
	,location = h.gststate ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
	,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
	,0.00 AS CGSRT_AMT, 0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT ,gst_std_cd = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END),
	D.LineRule,'' AS AGAINSTGS
	,0.00 as cess_amt,h.net_amt,UID = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.UID, '') ELSE isnull(ac.UID, '') END)
	---,adjust_amt =case when ((ROW_NUMBER()OVER(partition by  h.Inv_no order by h.inv_no ))) = 1  then isnull((select sum(new_all)  from  SBMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( SBMALL.entry_all + CAST(SBMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) else 0 end 
	,RIO =case when (isnull((select sum(new_all)  from  SBMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( SBMALL.entry_all + CAST(SBMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then isnull((select sum(new_all)  from  SBMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( SBMALL.entry_all + CAST(SBMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0)/h.net_amt else 0 end 
	,avl = 1,ITCSEC =SPACE (50),org_no=SPACE(50),org_date =cast('' as smalldatetime ),rentry_ty='',EXPOTYPE = ''
	FROM SBMAIN H INNER JOIN SBITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
    IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
    ac_mast ac ON (h.ac_id = ac.ac_id) LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)
	--DNMAIN 
	Union all 
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D .CGST_AMT, d .SGST_PER,D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
	D .GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE,
	ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
	,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
	,location = h.gststate ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
	,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
	,0.00 AS CGSRT_AMT, 0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT ,gst_std_cd = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END),
	D.LineRule,H.AGAINSTGS,0.00 as cess_amt,h.net_amt,UID = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.UID, '') ELSE isnull(ac.UID, '') END)
	---,adjust_amt =case when ((ROW_NUMBER()OVER(partition by  h.Inv_no order by h.inv_no ))) = 1  then isnull((select sum(new_all)  from  DNMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( DNMALL.entry_all + CAST(DNMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) else 0 end 
	,RIO =case when (isnull((select sum(new_all)  from  DNMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( DNMALL.entry_all + CAST(DNMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0)) > 1  then  isnull((select sum(new_all)  from  DNMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and (( DNMALL.entry_all + CAST(DNMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) /H.net_amt else 0 end 
	,avl = 1,ITCSEC =SPACE (50),org_no=d.SBILLNO,org_date =d.SBDATE ,rentry_ty=(select top 1 rentry_ty  from OTHITREF where entry_ty = h.entry_ty  and Tran_cd = h.tran_cd)
	,EXPOTYPE = ''
	FROM DNMAIN H INNER JOIN DNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
    IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
    ac_mast ac ON (h.ac_id = ac.ac_id) LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)
	---CNMAIN
	Union all 
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D .CGST_AMT, d .SGST_PER,D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
	D .GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE,
	ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
	,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
	,location = h.gststate ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
	,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
	,0.00 AS CGSRT_AMT, 0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT ,gst_std_cd = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END),
	D.LineRule,H.AGAINSTGS
	,0.00 as cess_amt,h.net_amt,UID = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.UID, '') ELSE isnull(ac.UID, '') END)
	---,adjust_amt =case when ((ROW_NUMBER()OVER(partition by  h.Inv_no order by h.inv_no ))) = 1  then isnull((select sum(new_all)  from  CNMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((CNMALL.entry_all + CAST(CNMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) else 0 end 
	,RIO =case when (isnull((select sum(new_all)  from  CNMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((CNMALL.entry_all + CAST(CNMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then  isnull((select sum(new_all)  from  CNMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((CNMALL.entry_all + CAST(CNMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BRMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CRMAIN where TDSPAYTYPE = 2)a)),0) /H.net_amt  else 0 end 
	,avl = 1,ITCSEC =SPACE (50),org_no=d.SBILLNO,org_date =d.SBDATE ,rentry_ty=(select top 1 rentry_ty  from OTHITREF where entry_ty = h.entry_ty  and Tran_cd = h.tran_cd)
	,EXPOTYPE = ''
	FROM CNMAIN H INNER JOIN CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
    IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
    ac_mast ac ON (h.ac_id = ac.ac_id) LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)
	---PTMAIN
	UNION ALL 
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D .CGST_AMT, d .SGST_PER,D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
	D .GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE,
	ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
	,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
	, location = h.gststate ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
	,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
	,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,gst_std_cd = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END),
	D.LineRule,'' AS AGAINSTGS
	,0.00 as cess_amt,h.net_amt ,UID = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.UID, '') ELSE isnull(ac.UID, '') END) 
	---,adjust_amt =case when ((ROW_NUMBER()OVER(partition by  h.Inv_no order by h.inv_no ))) = 1  then isnull((select sum(new_all)  from  PTMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((PTMALL.entry_all + CAST(PTMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0) else 0 end 
	,RIO =case when (isnull((select sum(new_all)  from  PTMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((PTMALL.entry_all + CAST(PTMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0)) >0  then  isnull((select sum(new_all)  from  PTMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((PTMALL.entry_all + CAST(PTMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0)/  H.net_amt else 0 end 
	,d.avl,ISNULL(d.ITCSEC,'')AS ITCSEC,org_no=H.Pinvno ,org_date =H.Pinvdt,rentry_ty=H.ENTRY_TY
	,EXPOTYPE = ''
	FROM PTMAIN H INNER JOIN PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
    IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
    ac_mast ac ON (h.ac_id = ac.ac_id) LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id) WHERE H.entry_ty IN('PT','P1')
	Union all 
	---PRMAIN
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D .CGST_AMT, d .SGST_PER,D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
	D .GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE,
	ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
	,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
	, location = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.state, '') ELSE isnull(ac.state , '') END),SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
	,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
	,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,gst_std_cd = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END),
	D.LineRule,'' AS AGAINSTGS
	,0.00 as cess_amt,h.net_amt ,UID = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.UID, '') ELSE isnull(ac.UID, '') END)
	---,adjust_amt =case when ((ROW_NUMBER()OVER(partition by  h.Inv_no order by h.inv_no ))) = 1  then isnull((select sum(new_all)  from  PRMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((PRMALL.entry_all + CAST(PRMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0) else 0 end 
	,RIO =case when (isnull((select sum(new_all)  from  PRMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((PRMALL.entry_all + CAST(PRMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0)) > 0  then isnull((select sum(new_all)  from  PRMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((PRMALL.entry_all + CAST(PRMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0) / H.net_amt else 0 end 
	,avl = 1,ITCSEC =SPACE (50),org_no=d.SBILLNO,org_date =d.SBDATE ,rentry_ty=(select top 1 rentry_ty  from PRITREF where entry_ty = h.entry_ty  and Tran_cd = h.tran_cd)
	,EXPOTYPE = ''
	FROM PRMAIN H INNER JOIN PRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
    IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
    ac_mast ac ON (h.ac_id = ac.ac_id) LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)
	---      
	--EPMAIN 
	Union all
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D .CGST_AMT, d .SGST_PER,D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
	D .GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE,
	ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
	,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
	,location = h.gststate ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
	,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
	,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,gst_std_cd = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END),
	D.LineRule,'' AS AGAINSTGS,0.00 as cess_amt,h.net_amt,UID = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.UID, '') ELSE isnull(ac.UID, '') END)
	---,adjust_amt =case when ((ROW_NUMBER()OVER(partition by  h.Inv_no order by h.inv_no ))) = 1  then isnull((select sum(new_all)  from  EPMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((EPMALL.entry_all + CAST(EPMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0) / h.net_amt else 0 end 
	,RIO =case when (isnull((select sum(new_all)  from  EPMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((EPMALL.entry_all + CAST(EPMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0)) >0  then H.net_amt / isnull((select sum(new_all)  from  EPMALL where entry_ty = h.entry_ty and Tran_cd =h.Tran_cd  and ((EPMALL.entry_all + CAST(EPMALL.MAIN_TRAN as varchar))) IN (select(entry_ty + CAST(Tran_cd  as varchar)) from (select Tran_cd ,entry_ty from BPMAIN where TDSPAYTYPE = 2 union all select Tran_cd,entry_ty  from CPMAIN where TDSPAYTYPE = 2)a)),0) else 0 end 
	,d.avl,ISNULL(d.ITCSEC,'')AS ITCSEC ,org_no=H.Pinvno ,org_date =H.Pinvdt,rentry_ty=H.ENTRY_TY
	,EXPOTYPE = ''
	FROM EPMAIN H INNER JOIN EPITEM  D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
    IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
    ac_mast ac ON (h.ac_id = ac.ac_id) LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id) WHERE H.entry_ty = 'E1' 
    
    
	---Bank Recipt
  union all 
   SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
   D.GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
   ac.ac_name , gstin = (case when isnull(ac.gstin,'')<> '' then isnull(ac.gstin,'') else isnull(ac.uid,'') end) 
   ,location = h.gststate,ac.SUPP_TYPE,st_type= ac.st_type
   ,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT,gst_std_cd = isnull(ac.statecode, '') ,d.LineRule,'' AS AGAINSTGS,0.00 as cess_amt,h.net_amt
   ,UID = isnull(ac.UID, '')
   --,adjust_amt = 0
   ,rio = 0 ,avl = 1,ITCSEC =SPACE (50),org_no=SPACE(50),org_date =cast('' as smalldatetime ),rentry_ty=''
   ,EXPOTYPE = ''
   FROM BRMAIN H INNER JOIN BRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
   IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN ac_mast ac ON (h.Ac_id = ac.ac_id)
   WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BR' 
   ----and ((h.entry_ty + CAST(h.Tran_cd  as varchar)))not IN (select(entry_all + CAST(main_tran  as varchar)) from mainall_vw  group by entry_all ,main_tran )
	---Cash Bank Receipt
  union all
  SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
  D.GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
  ac.ac_name , gstin = (case when isnull(ac.gstin,'')<> '' then isnull(ac.gstin,'') else isnull(ac.uid,'') end) 
  ,location = h.gststate,ac.SUPP_TYPE,st_type= ac.st_type,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT,gst_std_cd = isnull(ac.statecode, '') ,d.LineRule,'' AS AGAINSTGS,0.00 as cess_amt,h.net_amt
  ,UID = isnull(ac.UID, '')
     --,adjust_amt = 0
   ,rio = 0,avl = 1,ITCSEC =SPACE (50),org_no=SPACE(50),org_date =cast('' as smalldatetime ),rentry_ty=''
  ,EXPOTYPE = ''
  FROM CRMAIN H INNER JOIN CRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN ac_mast ac ON (h.Ac_id = ac.ac_id)
  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CR' 
  ---and ((h.entry_ty + CAST(h.Tran_cd  as varchar)))not IN (select(entry_all + CAST(main_tran  as varchar)) from mainall_vw  group by entry_all ,main_tran  )
	    
 ---Bank Payment
  union all
  SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
  D.GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
  ac.ac_name , gstin = (case when isnull(ac.gstin,'')<> '' then isnull(ac.gstin,'') else isnull(ac.uid,'') end) 
  ,location = h.gststate,ac.SUPP_TYPE,st_type= ac.st_type,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT,gst_std_cd = isnull(ac.statecode, '') ,d.LineRule,H.AGAINSTGS,0.00 as cess_amt,h.net_amt
  ,UID = isnull(ac.UID, '')
     --,adjust_amt = 0
   ,rio = 0,avl = 1,ITCSEC =SPACE (50),org_no=SPACE(50),org_date =cast('' as smalldatetime ),rentry_ty=''
   ,EXPOTYPE = ''
  FROM BPMAIN H INNER JOIN BPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN ac_mast ac ON (h.Ac_id = ac.ac_id)
  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BP' and ((h.entry_ty + CAST(h.Tran_cd  as varchar)))not IN (select(entry_all + CAST(main_tran  as varchar)) from mainall_vw  group by entry_all ,main_tran  )

---Cash Payment
  union all
  SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
  D.GRO_AMT, IT.IT_NAME, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
  ac.ac_name , gstin = (case when isnull(ac.gstin,'')<> '' then isnull(ac.gstin,'') else isnull(ac.uid,'') end) 
  ,location = h.gststate,ac.SUPP_TYPE,st_type= ac.st_type,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT,gst_std_cd = isnull(ac.statecode, '') ,d.LineRule,H.AGAINSTGS,0.00 as cess_amt,h.net_amt
  ,UID = isnull(ac.UID, '')
     --,adjust_amt = 0
   ,rio = 0,avl = 1,ITCSEC =SPACE (50),org_no=SPACE(50),org_date =cast('' as smalldatetime ),rentry_ty=''
   ,EXPOTYPE = ''
  FROM CPMAIN H INNER JOIN CPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN ac_mast ac ON (h.Ac_id = ac.ac_id)
  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CP' and ((h.entry_ty + CAST(h.Tran_cd  as varchar)))not IN (select(entry_all + CAST(main_tran  as varchar)) from mainall_vw  group by entry_all ,main_tran  )
