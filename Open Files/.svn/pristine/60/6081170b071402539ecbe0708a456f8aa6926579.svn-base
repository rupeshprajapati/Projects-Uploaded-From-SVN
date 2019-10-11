IF EXISTS (SELECT XTYPE,name FROM SYSOBJECTS WHERE XTYPE ='V' AND name = 'GSTR1_VW')
BEGIN
	DROP VIEW  GSTR1_VW
END
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[GSTR1_VW]
AS
---STMAIN
---this validation for third party sales considered for buyer h.ac_id = h.cons_id  
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D .CGST_AMT, d .SGST_PER,D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE,
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
                      ---,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
                      ,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
                      , location = h.gststate ---(CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
                      ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
                      ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
                      ,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,expotype,0.00 AS CGSRT_AMT, 0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT
                      ,h.inv_sr,h.l_yn,
                       gst_std_cd = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)
                      ,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
                      ,POS=(case when ((CASE WHEN isnull(H.scons_id, 0) > 0   THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)) <> H.GSTSTATE then H.GSTSTATE ELSE '' END )
                      ,RevCharge = '','' AS AGAINSTGS
                      ,AC.Merch_ID,EcomgsTin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
                      ,Ecomst_type = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type , '') ELSE isnull(ac.st_type , '') END)
                      ,poscode =h.GSTSCODE
                      ,0.00 as cess_amt,IT.s_unit as uqc,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
                      ,h.net_amt
					   	                      
FROM         STMAIN H INNER JOIN
                      STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.ac_id = ac.ac_id)
                      LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)
                      
                      

UNION ALL
---SRMAIN

SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d .u_asseamt AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
                      --,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'') THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
                      ,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
                      , location = (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
                      ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'') THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
                      ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'') THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
                      ,ORG_INVNO=SBILLNO, ORG_DATE=SBDATE,'' as  expotype,0.00 AS CGSRT_AMT, 0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT
					  ,h.inv_sr,h.l_yn,
					  gst_std_cd =(CASE WHEN isnull(H.scons_id, 0) > 0   THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)
					  ,'' as  u_VESSEL ,'' as U_SBDT 
					  ,D.LineRule ,'' as pos ,RevCharge = '','' AS AGAINSTGS,AC.Merch_ID
					  ,EcomgsTin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
					  ,Ecomst_type = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type , '') ELSE isnull(ac.st_type , '') END)
					  ,poscode =''
					  ,0.00 as cess_amt,IT.s_unit as uqc,'' as AMENDDATE,h.net_amt
					  

FROM         SRMAIN H INNER JOIN
                      SRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.ac_id = ac.ac_id) 
                      LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)



UNION ALL
---SBMAIN
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d .STAXAMT AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'') THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
                      --, gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
                      ,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
                      , location = h.GSTState ---(CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
                      ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'') THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
                      ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
                      ,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,expotype,d.CGSRT_AMT, d.SGSRT_AMT,d.IGSRT_AMT
					  ,h.inv_sr,h.l_yn
					  ,gst_std_cd =(CASE WHEN isnull(H.scons_id, 0) > 0  THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)
					  ,'' AS SBBILLNO  ,'' AS SBDATE,D.LineRule
					  ,POS=(case when (CASE WHEN isnull(H.scons_id, 0) > 0  THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END) <> H.GSTSTATE then H.GSTSTATE ELSE '' END )
					  ,RevCharge = ( Case when (ISNULL(D.CGSRT_AMT,0)+ ISNULL(D.SGSRT_AMT,0)+ISNULL(D.IGSRT_AMT,0)) > 0 THEN 'Yes' ELSE '' END ),'' AS AGAINSTGS,AC.Merch_ID
					  ,EcomgsTin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
					  ,Ecomst_type = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type , '') ELSE isnull(ac.st_type , '') END)
					  ,poscode =h.GSTSCODE
					  ,0.00 as cess_amt,IT.s_unit as uqc,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ),h.net_amt
					  
					  
FROM         SBMAIN H INNER JOIN
                      SBITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.ac_id = ac.ac_id) 
                      LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)
                      

UNION ALL
---Debit note for Goods 
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.U_ASSEAMT AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
                      --, gstin = (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'') THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
                      ,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
                      , location = h.GSTState ---(CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
                      ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'') THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
                      ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
                      ,SBILLNO ORGINV_NO,SBDATE AS ORG_DATE,'' as  expotype ,d.CGSRT_AMT,d.SGSRT_AMT,d.IGSRT_AMT
					  ,h.inv_sr,h.l_yn
					   ,gst_std_cd =(CASE WHEN isnull(H.scons_id, 0) > 0   THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)	
					  ,H.u_VESSEL ,H.U_SBDT 
					  ,D.LineRule,'' AS POS
					  ,RevCharge = ( Case when (ISNULL(D.CGSRT_AMT,0)+ ISNULL(D.SGSRT_AMT,0)+ISNULL(D.IGSRT_AMT,0)) > 0 THEN 'Yes' ELSE '' END ),H.AGAINSTGS,AC.Merch_ID
					  ,EcomgsTin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
					  ,Ecomst_type = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type , '') ELSE isnull(ac.st_type , '') END)
					  ,poscode =h.GSTSCODE
					  ,0.00 as cess_amt,IT.s_unit as uqc,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ) ,h.net_amt
					  
FROM         dnMAIN H INNER JOIN
                      dnITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.Ac_id = ac.ac_id) LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id)
                      WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE')
                      

UNION ALL
---Credit note for Goods 
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.U_ASSEAMT  AS Taxableamt, d.CGST_PER, D.CGST_AMT, d .SGST_PER, D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
                      --, gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
                      ,gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')   THEN (case when isnull(shipto.gstin, '') <> '' then isnull(shipto.gstin,'')  else shipto.uid end) ELSE (case when isnull(ac.gstin, '') <> ''  then isnull(ac.gstin, '') else isnull(ac.UID,'') end) END)
                      , location = h.GSTState --- (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
                      ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0  AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'') THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
                      ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 AND ISNULL(AC.i_tax,'') = ISNULL(CN.i_tax,'')  THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
                      ,SBILLNO AS ORGINV_NO,SBDATE AS ORG_DATE,'' as  expotype,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT
					  ,h.inv_sr,h.l_yn
					  ,gst_std_cd =(CASE WHEN isnull(H.scons_id, 0) > 0  THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)
					  ,H.u_VESSEL ,H.U_SBDT 
					  ,D.LineRule,'' AS POS
					  ,RevCharge = ( Case when (ISNULL(D.CGSRT_AMT,0)+ ISNULL(D.SGSRT_AMT,0)+ISNULL(D.IGSRT_AMT,0)) > 0 THEN 'Yes' ELSE '' END ),H.AGAINSTGS
					  ,AC.Merch_ID
					  ,EcomgsTin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
					  ,Ecomst_type = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type , '') ELSE isnull(ac.st_type , '') END)
					  ,poscode =h.GSTSCODE
					  ,0.00 as cess_amt,IT.s_unit as uqc,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ),h.net_amt
					  
FROM         CNMAIN H INNER JOIN
                      CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.Ac_id = ac.ac_id)   
                      LEFT OUTER JOIN AC_MAST CN ON (H.cons_id = CN.Ac_id) 
                      WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE')
                      
union all --- BAnk Recepit
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D.GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac.ac_name , gstin = (case when isnull(ac.gstin,'')<> '' then isnull(ac.gstin,'') else isnull(ac.uid,'') end) 
                      ,location = h.gststate---ac.state
                      ,ac.SUPP_TYPE,st_type= ac.st_type,'' AS ORGINV_NO,'' AS ORG_DATE,'' as  expotype,0 AS CGSRT_AMT,0 AS SGSRT_AMT,0 AS IGSRT_AMT
					   ,h.inv_sr,h.l_yn
					   ,gst_std_cd =isnull(ac.statecode, '')
					  ,'' AS SBILLNO  ,'' AS SBDATE ,'' as LineRule ,'' as ops ,RevCharge = '','' AS AGAINSTGS,AC.Merch_ID
					  ,'' as  EcomgsTin
					  ,Ecomst_type = '',poscode =h.GSTSCODE
					  ,0.00 as cess_amt,IT.s_unit as uqc,'' AS AMENDDATE,h.net_amt
					  
					  
FROM         BRMAIN H INNER JOIN
                      BRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      ac_mast ac ON (h.Ac_id = ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BR'

union all --- Cash Recepit
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D.GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac.ac_name , gstin = (case when isnull(ac.gstin,'')<> '' then isnull(ac.gstin,'') else isnull(ac.uid,'') end) 
                      ,location = h.GSTState ---ac.state
                      ,ac.SUPP_TYPE,st_type= ac.st_type,'' AS ORGINV_NO,'' AS ORG_DATE,'' as  expotype,0 AS CGSRT_AMT,0 AS SGSRT_AMT,0 AS IGSRT_AMT
					   ,h.inv_sr,h.l_yn
					   ,gst_std_cd =isnull(ac.statecode, '')
					  ,'' AS SBILLNO  ,'' AS SBDATE ,'' as LineRule ,'' as ops ,RevCharge = '','' AS AGAINSTGS,AC.Merch_ID
					  ,'' as  EcomgsTin
					  ,Ecomst_type = '',poscode =h.GSTSCODE
					  ,0.00 as cess_amt,IT.s_unit as uqc,'' AS AMENDDATE,h.net_amt
					  
					  
FROM         CRMAIN H INNER JOIN
                      CRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      ac_mast ac ON (h.Ac_id = ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CR'
                      


union all --- Refund Voucher
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D.GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac.ac_name , gstin = (case when isnull(ac.gstin,'')<> '' then isnull(ac.gstin,'') else isnull(ac.uid,'') end) 
                      ,location = h.gststate---ac.state
                      ,ac.SUPP_TYPE,st_type= ac.st_type,'' AS ORGINV_NO,'' AS ORG_DATE,'' as  expotype,0 AS CGSRT_AMT,0 AS SGSRT_AMT,0 AS IGSRT_AMT
					   ,h.inv_sr,h.l_yn
					   ,gst_std_cd =isnull(ac.statecode, '')
					  ,'' AS SBILLNO  ,'' AS SBDATE ,LineRule ,'' as ops ,RevCharge = '','' AS AGAINSTGS,AC.Merch_ID
					  ,'' as  EcomgsTin
					  ,Ecomst_type = '',poscode =h.GSTSCODE
					  ,0.00 as cess_amt,IT.s_unit as uqc,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ),h.net_amt
					  
					  
FROM         BpMAIN H INNER JOIN
                      BpITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      ac_mast ac ON (h.Ac_id = ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='RV' and h.paymentno in(select inv_no from BRMAIN WHERE entry_ty = 'BR'  union all select inv_no from cRMAIN WHERE entry_ty = 'CR' ) 


 GO

