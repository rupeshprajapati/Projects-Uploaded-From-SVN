IF EXISTS (SELECT XTYPE,name FROM SYSOBJECTS WHERE XTYPE ='V' AND name = 'GSTR2_VW')
BEGIN
	DROP VIEW  GSTR2_VW
END
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[GSTR2_VW]
AS
---PTMAIN
SELECT     H.Entry_ty, H.Tran_cd, D.ITSERIAL ,h.INV_NO ,h.date , D .IT_CODE, D.QTY, d.u_asseamt AS Taxableamt, d.CGST_PER, D.CGST_AMT, d.SGST_PER, D.SGST_AMT, d.IGST_PER,D.IGST_AMT, 
                      D.GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END)
                      , gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') ELSE isnull(ac.gstin, '') END)
                      , location = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
                      ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
                      ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
                      ,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' as  expotype,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT
					  ,h.inv_sr,h.l_yn
					  ,gst_std_cd =(CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)
					  ,'' AS SBBILLNO  ,'' AS SBDATE,D.LineRule	
					  ,POS=(case when (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END) <> H.GSTSTATE then H.GSTSTATE ELSE '' END )
					  ,RevCharge = '','' AS AGAINSTGS,gstype =(case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end),H.TRANSTATUS 
					  ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt
					  ,h.net_amt,it.p_unit as uqc,0.00 AS CESS_AMT,0.00 AS CESS_PER,AmendDate =(case when DATEDIFF(MM,H.date,H.AmendDate)> 0 THEN H.AmendDate ELSE '' END)
					  
FROM         PTMAIN H INNER JOIN
                      PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.cons_id = ac.ac_id)

UNION ALL
---PRMAIN
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL,h.inv_No, h.date, D .IT_CODE, D .QTY, d .u_asseamt AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END), gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') 
                      ELSE isnull(ac.gstin, '') END), location = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
					,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
					,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
					,SBILLNO ORGINV_NO,SBDATE AS ORG_DATE,'' as  expotype,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT
					,h.inv_sr,h.l_yn
					,gst_std_cd =(CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)
					,d.SBILLNO  ,d.SBDATE ,d.LineRule ,'' as pos 
					  ,RevCharge = '','' AS AGAINSTGS,gstype=(case when it.type='Machinery/Stores' then 'Capital Goods' else 'Inputs' end) ,H.TRANSTATUS 
					  ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt
					  ,h.net_amt,it.p_unit as uqc ,0.00 AS CESS_AMT,0.00 AS CESS_PER,AmendDate =''
FROM         PRMAIN H INNER JOIN
                      PRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.cons_id = ac.ac_id) 
					

UNION ALL
---Debit note for Goods 
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.U_ASSEAMT AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END), gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') 
                      ELSE isnull(ac.gstin, '') END), location = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
                      ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
                      ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
                      ,SBILLNO ORGINV_NO,SBDATE AS ORG_DATE,'' as  expotype ,d.CGSRT_AMT,d.SGSRT_AMT,d.IGSRT_AMT
					  ,h.inv_sr,h.l_yn
					   ,gst_std_cd =(CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)	
					  ,d.SBILLNO  ,d.SBDATE ,d.LineRule,'' AS POS
					  ,RevCharge = ( Case when (ISNULL(D.CGSRT_AMT,0)+ ISNULL(D.SGSRT_AMT,0)+ISNULL(D.IGSRT_AMT,0)) > 0 THEN 'Yes' ELSE '' END ),H.AGAINSTGS 
					  ,gstype = (case when IT.Isservice = 0 and it.type='Machinery/Stores' then 'Capital Goods' when IT.Isservice = 0 and it.type !='Machinery/Stores' then 'Inputs' when IT.Isservice = 1 then 'Input Services' else '' end ),H.TRANSTATUS 
					  ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt
					  ,h.net_amt,it.p_unit as uqc ,0.00 AS CESS_AMT,0.00 AS CESS_PER,AmendDate =(case when DATEDIFF(MM,H.date,H.AmendDate)> 0 THEN H.AmendDate ELSE '' END)  
FROM  dnMAIN H INNER JOIN
                      dnITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.cons_id = ac.ac_id)  WHERE H.AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL')

---UNION ALL
UNION ALL
---Credit note for Goods 
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.U_ASSEAMT  AS Taxableamt, d.CGST_PER, D.CGST_AMT, d .SGST_PER, D.SGST_AMT, d .IGST_PER, D.IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END), gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') 
                      ELSE isnull(ac.gstin, '') END), location = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
                      ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
                      ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
                      ,SBILLNO ORGINV_NO,SBDATE AS ORG_DATE,'' as  expotype,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT
					  ,h.inv_sr,h.l_yn
					  ,gst_std_cd =(CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)
					  ,d.SBILLNO  ,d.SBDATE,d.LineRule,'' AS POS
					  ,RevCharge = ( Case when (ISNULL(D.CGSRT_AMT,0)+ ISNULL(D.SGSRT_AMT,0)+ISNULL(D.IGSRT_AMT,0)) > 0 THEN 'Yes' ELSE '' END ),H.AGAINSTGS
					  ,gstype =(case when IT.Isservice = 0 and it.type='Machinery/Stores' then 'Capital Goods' when IT.Isservice = 0 and it.type !='Machinery/Stores' then 'Inputs' when IT.Isservice = 1 then 'Input Services' else '' end ),H.TRANSTATUS 
					  ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt
					  ,h.net_amt,it.p_unit as uqc,0.00 AS CESS_AMT,0.00 AS CESS_PER ,AmendDate =(case when DATEDIFF(MM,H.date,H.AmendDate)> 0 THEN H.AmendDate ELSE '' END)  
FROM         CNMAIN H INNER JOIN
                      CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.cons_id = ac.ac_id)    WHERE H.AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL')

                      
union all --- Bank Payment
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac.ac_name , gstin = ac.gstin
                      ,location = ac.state,ac.SUPP_TYPE,st_type= ac.st_type,'' AS ORGINV_NO,'' AS ORG_DATE,'' as  expotype,d.CGSRT_AMT,d.SGSRT_AMT,d.IGSRT_AMT
					  ,h.inv_sr,h.l_yn 
					  ,gst_std_cd =isnull(ac.statecode, '') 
					  ,'' AS SBBILLNO  ,'' AS SBDATE ,d.LineRule,'' as pos ,RevCharge = '','' AS AGAINSTGS,gstype =(case when IT.Isservice = 0 and it.type='Machinery/Stores' then 'Capital Goods' when IT.Isservice = 0 and it.type !='Machinery/Stores' then 'Inputs' when IT.Isservice = 1 then 'Input Services' else '' end ),0 AS TRANSTATUS 
					  ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt
					  ,h.net_amt,it.p_unit as uqc,0.00 AS CESS_AMT,0.00 AS CESS_PER ,AmendDate =''
FROM         BPMAIN H INNER JOIN
                      BPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      ac_mast ac ON (h.Ac_id = ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BP'

union all --- Cash Payment
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac.ac_name , gstin = ac.gstin
                      ,location = ac.state,ac.SUPP_TYPE,st_type= ac.st_type,'' AS ORGINV_NO,'' AS ORG_DATE,'' as  expotype,d.CGSRT_AMT,d.SGSRT_AMT,d.IGSRT_AMT
					  ,h.inv_sr,h.l_yn 
					  ,gst_std_cd =isnull(ac.statecode, '') 
					  ,'' AS SBBILLNO  ,'' AS SBDATE ,d.LineRule,'' as pos ,RevCharge = '','' AS AGAINSTGS,gstype =(case when IT.Isservice = 0 and it.type='Machinery/Stores' then 'Capital Goods' when IT.Isservice = 0 and it.type !='Machinery/Stores' then 'Inputs' when IT.Isservice = 1 then 'Input Services' else '' end ),0 AS TRANSTATUS 
					  ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt
					  ,h.net_amt,it.p_unit as uqc ,0.00 AS CESS_AMT,0.00 AS CESS_PER,AmendDate =''
FROM         CPMAIN H INNER JOIN
                      CPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      ac_mast ac ON (h.Ac_id = ac.ac_id)  WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CP'

--- Services Bill 
UNION ALL 
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D .IT_CODE, D .QTY, d .STAXAMT AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, (CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.HSNCODE, 
                      ac_name = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END), gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') 
                      ELSE isnull(ac.gstin, '') END)
                      , location = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
                      ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
                      ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
                      ,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' AS expotype,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT
					  ,h.inv_sr,h.l_yn
					  ,gst_std_cd =(CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.statecode, '') ELSE isnull(ac.statecode, '') END)
					  ,'' AS SBILLNO  ,'' AS SBDATE,d.LineRule,POS=(case when (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END) <> H.GSTSTATE then H.GSTSTATE ELSE '' END )
					  ,RevCharge = ( Case when (ISNULL(D.CGSRT_AMT,0)+ ISNULL(D.SGSRT_AMT,0)+ISNULL(D.IGSRT_AMT,0)) > 0 THEN 'Yes' ELSE '' END ),'' AS AGAINSTGS ,gstype ='Input Services',H.TRANSTATUS 
					  ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt
					  ,h.net_amt,it.p_unit as uqc ,0.00 AS CESS_AMT,0.00 AS CESS_PER,AmendDate =(case when DATEDIFF(MM,H.date,H.AmendDate)> 0 THEN H.AmendDate ELSE '' END)  
FROM         EPMAIN H INNER JOIN
                      EPITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
                      IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
                      shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
                      ac_mast ac ON (h.cons_id = ac.ac_id)  WHERE H.entry_ty = 'E1'

--- ISD RECEIPT 
UNION ALL 
SELECT     H.Entry_ty, H.Tran_cd, D .ITSERIAL, H.INV_NO, H.DATE, D.IT_CODE, D.QTY, 0.00 AS Taxableamt, d.CGST_PER, D.CGST_AMT, d.SGST_PER, D.SGST_AMT, d.IGST_PER, D.IGST_AMT, 
                      D .GRO_AMT, IT.IT_NAME, IT.IT_DESC, '' AS Isservice,  IT.HSNCODE, 
                      ac_name = isnull(ac.ac_name, '') , gstin = isnull(ac.gstin, '') 
                      , location = isnull(ac.state, '')
                      ,SUPP_TYPE = isnull(ac.SUPP_TYPE, '') 
                      ,st_type= isnull(ac.st_type, '') 
                      ,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,'' AS expotype,0.00 AS CGSRT_AMT,0.00 AS SGSRT_AMT,0.00 AS IGSRT_AMT
					  ,h.inv_sr,h.l_yn
					  ,gst_std_cd =isnull(ac.statecode, '') 
					  ,'' AS SBBILLNO  ,'' AS SBDATE,'' AS LineRule,POS=''
					  ,RevCharge = '','' AS AGAINSTGS ,gstype ='',0 AS TRANSTATUS 
					  ,(case when h.pinvno <> ''  then  h.pinvno else H.INV_NO end) as pinvno ,(case when h.pinvdt <> ''  then  h.pinvdt else H.date end) as pinvdt
					  ,h.net_amt,it.p_unit as uqc,0.00 AS CESS_AMT,0.00 AS CESS_PER,AmendDate =''
FROM         JVMAIN H INNER JOIN
                      JVITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
                      IT_MAST IT ON (D.IT_CODE = IT.IT_CODE)  LEFT OUTER JOIN
                      ac_mast ac ON (h.AC_ID = ac.ac_id)  WHERE H.entry_ty = 'J6'


 GO
 
 

