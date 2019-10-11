IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='USP_EXTRACTION_OUTWARD_EXCEL_FILE')
BEGIN
	DROP PROCEDURE USP_EXTRACTION_OUTWARD_EXCEL_FILE
END
Go
-- =============================================
-- AUTHOR	  :	PRIYANKA B.
-- CREATE DATE: 17/01/2018
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO GENERATE OUTWARD EXCEL EXTRACTION FILE.
-- MODIFIED BY: 
-- MODIFY DATE: 
-- REMARK:
-- =============================================
--set dateformat dmy execute USP_EXTRACTION_OUTWARD_EXCEL_FILE '01/01/2018','31/03/2019'

CREATE PROCEDURE  [dbo].[USP_EXTRACTION_OUTWARD_EXCEL_FILE]
@LSTARTDATE  SMALLDATETIME,@LENDDATE SMALLDATETIME
AS

--	SELECT * INTO #TMPTBL FROM (SELECT Tran_cd,entry_ty,EXPOTYPE,INV_NO  FROM STMAIN  WHERE entry_ty = 'ST' UNION ALL SELECT Tran_cd,entry_ty,EXPOTYPE,INV_NO  FROM SBMAIN  WHERE entry_ty = 'S1')AA   --Commented by Priyanka B on 02012018 for Bug-31114
SELECT * INTO #TMPTBL FROM (SELECT Tran_cd,entry_ty,EXPOTYPE,INV_NO  FROM STMAIN  WHERE entry_ty in ('ST','EI') UNION ALL SELECT Tran_cd,entry_ty,EXPOTYPE,INV_NO  FROM SBMAIN  WHERE entry_ty = 'S1')AA  --Modified by Priyanka B on 02012018 for Bug-31114
--SET DATEFORMAT dmy SELECT * FROM (  --Commented by Priyanka B on 03012018 for Bug-31114
SET DATEFORMAT dmy SELECT * into #TMPTBL_1 FROM (  --Modified by Priyanka B on 03012018 for Bug-31114
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D.IT_CODE,D.QTY
	--,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue  --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,h.EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,d.CCESSRATE as CCESSRATE,d.compcess as cess_amt,d.comrpcess as Cessrt_amt
	,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
	--	, IT.HSNCODE  --Commented by Priyanka B on 03012018 for Bug-31114
	, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 03012018 for Bug-31114
	,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
	,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	,SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
	,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	,st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
	,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 
	,ORG_GSTIN=''
	,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
	,pos_std_cd =h.GSTSCODE,pos = h.gststate 
	,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	,D.GSTRATE,InvoiceType ='Regular',TransType ='Sales',Reason = '',ISNULL(h.portcode,'') as portcode,H.U_IMPORM 
	, CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC,OrgTransType ='',gs_type ='Goods',HSN_CD='00'
	,Cons_location =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end)
	,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else  buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM STMAIN H LEFT OUTER JOIN
	  STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id) 
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206	
	  --		  where h.entry_ty = 'ST' AND  ( h.DATE BETWEEN @LStartDate AND @LEndDate)  --Commented by Priyanka B on 02012018 for Bug-31114
	  	  --where h.entry_ty in ('ST','EI') AND  ( h.DATE BETWEEN @LStartDate AND @LEndDate)  --Modified by Priyanka B on 02012018 for Bug-31114  --Commented by Priyanka B on 23042019 for Bug-32425
		  where ( h.DATE BETWEEN @LStartDate AND @LEndDate)  --Modified by Priyanka B on 02012018 for Bug-31114  --Modified by Priyanka B on 23042019 for Bug-32425

/*Amend Details for Sales*/
	Union all 
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO
	----h.DATE --Commented by  Suraj K. for bug-31288
	, DATE=h.AmendDate  ---Added by  Suraj K. for bug-31288 
	,D.IT_CODE,D.QTY
	--,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue  --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=H.INV_NO, ORG_DATE=H.DATE,h.EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,d.CCESSRATE as CCESSRATE,d.compcess as cess_amt,d.comrpcess as Cessrt_amt
	,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
	--	, IT.HSNCODE  --Commented by Priyanka B on 03012018 for Bug-31114
	, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 03012018 for Bug-31114
	,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
	,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	,SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
	,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	,st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
	,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 
	,ORG_GSTIN=(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 			   
	,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
	,pos_std_cd =h.GSTSCODE,pos = h.gststate 
	,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	,D.GSTRATE,InvoiceType ='Amendments to earlier tax periods Invoice (including post supply discounts)',TransType ='Sales',Reason = '',ISNULL(h.portcode,'') as portcode,H.U_IMPORM 
	, CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC,OrgTransType ='Sales',gs_type ='Goods',HSN_CD='00'
	,Cons_location =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end)
	,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else  buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM STMAIN H LEFT OUTER JOIN
	  STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206 	  
	  --		  where h.entry_ty = 'ST' AND  ( (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ) BETWEEN @LStartDate AND @LEndDate)   --Commented by Priyanka B on 02012018 for Bug-31114
	  	  --where h.entry_ty in ('ST','EI') AND  ( (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ) BETWEEN @LStartDate AND @LEndDate)   --Modified by Priyanka B on 02012018 for Bug-31114  --Commented by Priyanka B on 23042019 for Bug-32425
		  where ( (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ) BETWEEN @LStartDate AND @LEndDate)   --Modified by Priyanka B on 02012018 for Bug-31114  --Modified by Priyanka B on 23042019 for Bug-32425

	union all 
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY
	--,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue   --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,expotype=ISNULL(st.EXPOTYPE,''),0.00 as CGSRT_AMT, 0.00 as SGSRT_AMT,0.00 as IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,d.CCESSRATE as cessrate,d.COMPCESS as cess_amt,0.00 as cessrt_amt 
	,H.u_VESSEL as SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
	--	, IT.HSNCODE  --Commented by Priyanka B on 03012018 for Bug-31114
	, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 03012018 for Bug-31114
	,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
	 ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	 ,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )  
	 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) 
	 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 
	,ORG_GSTIN = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 			   
	 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (case when ISNULL(buyer_sp.GSTIN,'')='' then buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
	 --,pos_std_cd = ST.GSTSCODE,pos = ST.GSTState  --Commented by Priyanka B on 16022018 for Bug-31199
	 ,pos_std_cd = h.GSTSCODE,pos = h.GSTState  --Modified by Priyanka B on 16022018 for Bug-31199
	  ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	 ,D.GSTRATE,InvoiceType ='Regular',TransType ='Credit Note for Sales',Reason = 'Sales Return',ST.portcode,U_IMPORM = ''
	 , CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC,OrgTransType ='Sales',gs_type ='Goods',HSN_CD='00'
	  ,Cons_location =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end)
	  ,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	  ,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	  ,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	  ,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM  SRMAIN H LEFT OUTER JOIN
	  SrITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
	  LEFT OUTER  join srITREF  ref on (d.entry_ty =ref.entry_ty and ref.Tran_cd =d.Tran_cd and ref.Itserial =d.itserial )
	  LEFT OUTER  join STMAIN  ST on (ST.entry_ty =ref.rentry_ty and ref.Itref_tran =st.Tran_cd)
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206
	  where ( h.DATE BETWEEN @LStartDate AND @LEndDate)
	/*Amend Details for Sales RETURN */
		Union all 
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO
	----h.DATE --Commented by  Suraj K. for bug-31288
	, DATE=h.AmendDate  ---Added by  Suraj K. for bug-31288 
	,D .IT_CODE,D.QTY
	--,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue   --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,expotype=ISNULL(st.EXPOTYPE,''),0.00 as CGSRT_AMT, 0.00 as SGSRT_AMT,0.00 as IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,d.CCESSRATE as cessrate,d.COMPCESS as cess_amt,0.00 as cessrt_amt 
	,H.u_VESSEL as SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice
	--	, IT.HSNCODE  --Commented by Priyanka B on 03012018 for Bug-31114
	, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END)  --Modified by Priyanka B on 03012018 for Bug-31114
	,RevCharge = '','' AS AGAINSTGS,AmendDate = ''
	 ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	 ,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )  
	 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) 
	 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 
	,ORG_GSTIN	=(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 		   
	 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (case when ISNULL(buyer_sp.GSTIN,'')='' then buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
	 --,pos_std_cd = ST.GSTSCODE,pos = ST.GSTState  --Commented by Priyanka B on 16022018 for Bug-31199
	 ,pos_std_cd = h.GSTSCODE,pos = h.GSTState  --Modified by Priyanka B on 16022018 for Bug-31199
	  ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	 ,D.GSTRATE,InvoiceType ='Amendments to earlier tax periods Invoice (including post supply discounts)',TransType ='Credit Note for Sales',Reason = 'Sales Return',ST.portcode,U_IMPORM = ''
	 , CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC,OrgTransType ='Credit Note for Sales',gs_type ='Goods',HSN_CD='00'
	 ,Cons_location =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end )
	 ,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	 ,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	 ,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	 ,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM  SRMAIN H LEFT OUTER JOIN
	  SrITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
	  LEFT OUTER join srITREF  ref on (d.entry_ty =ref.entry_ty and ref.Tran_cd =d.Tran_cd and ref.Itserial =d.itserial )
	  LEFT OUTER  join STMAIN  ST on (ST.entry_ty =ref.rentry_ty and ref.Itref_tran =st.Tran_cd)
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206
	  where ((case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ) BETWEEN @LStartDate AND @LEndDate)

	 ---sbmain 
	 union all
	 SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE,D.QTY
	 --,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue  --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	 ,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=SPACE(50), cast('' as datetime ) as ORG_DATE,h.EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,'0' as cessrate,0.00 as cess_amt,0.00 as cessrt_amt 
	,'' AS SBBILLNO ,'' as SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.ServTCode
	,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
	  --,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
	  ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	 ,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
	 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
	  ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
	,ORG_GSTIN = ''
	 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
	 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	 ,D.GSTRATE,InvoiceType ='Regular',TransType='Sales',Reason = '','' as portcode,U_IMPORM = ''
	 , CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC,OrgTransType ='',gs_type ='Services',HSN_CD='9999'
	 ,Cons_location =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end )
	 ,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	 ,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	 ,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else  buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	 ,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM  SBMAIN H LEFT OUTER JOIN
	  SBITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206
	  where  ( h.DATE BETWEEN @LStartDate AND @LEndDate)

	/*Amend Details for Service invoice */
		Union all 
	 SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO
	 ----h.DATE --Commented by  Suraj K. for bug-31288
	, DATE=h.AmendDate  ---Added by  Suraj K. for bug-31288 
	 ,D .IT_CODE,D.QTY
	 --,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue  --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	 ,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=H.INV_NO, ORG_DATE=H.DATE,h.EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,'0' as cessrate,0.00 as cess_amt,0.00 as cessrt_amt 
	,'' AS SBBILLNO ,'' as SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, IT.ServTCode
	,RevCharge = '','' AS AGAINSTGS,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end )
	  --,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
	  ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	 ,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
	 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end)
	  ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
	,ORG_GSTIN = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
	 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
	 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	 ,D.GSTRATE,InvoiceType ='Amendments to earlier tax periods Invoice (including post supply discounts)',TransType='Sales',Reason = '','' as portcode,U_IMPORM = ''
	 , CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC,OrgTransType ='Sales',gs_type ='Services',HSN_CD='9999'
	 ,Cons_location =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end )
	 ,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	 ,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	 ,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	 ,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM  SBMAIN H LEFT OUTER JOIN
	  SBITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206
	  where  ( (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ) BETWEEN @LStartDate AND @LEndDate) 
	  

	 union all  
	  ---(Debit Note )DNMAIN 
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE
	--,d.QTY  --Commented by Priyanka B on 16022018 for Bug-31199
	,Qty=0  --Modified by Priyanka B on 16022018 for Bug-31199
	--,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue  --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,EXPOTYPE=ISNULL((SELECT TOP 1 EXPOTYPE FROM #TMPTBL WHERE INV_NO =D.SBILLNO),''),D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,d.ccessrate as cessrate,d.compcess as cess_amt,d.comrpcess as cessrt_amt
	,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END) 
	,RevCharge = '',h.AGAINSTGS,AmendDate =''
	 ---,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
	 ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	 ,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )  
	 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) 
	 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 
	 ,org_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 
	 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'') = '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'') = '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
	  ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	 ,D.GSTRATE,InvoiceType ='Regular',TransType='Debit Note for Sales',Reason = (case when isnull(H.u_gprice,'')<>'' then substring(H.u_gprice,charindex('-',H.u_gprice)+1,len(H.u_gprice)) else '' end)
	 ,'' as portcode,U_IMPORM = ''
	 , CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC ,OrgTransType ='Sales'
	 ,gs_type = (CASE WHEN H.AGAINSTGS='SALES' THEN 'Goods' WHEN H.AGAINSTGS='SERVICE INVOICE' THEN 'Services' else '' end )  
	 ,HSN_CD=(CASE WHEN H.AGAINSTGS='SALES' THEN '00' WHEN H.AGAINSTGS='SERVICE INVOICE' THEN '9999' else '' end )  
	 ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end )
	 ,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	 ,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	 ,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else  buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	 ,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM DNMAIN H LEFT OUTER JOIN
	  DNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206
	  WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE') AND  ( h.DATE BETWEEN @LStartDate AND @LEndDate)

	/*Amend Details for Debit Note*/
		Union all 
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO
	----h.DATE --Commented by  Suraj K. for bug-31288
	, DATE=h.AmendDate  ---Added by  Suraj K. for bug-31288 
	,D .IT_CODE
	--,d.QTY  --Commented by Priyanka B on 16022018 for Bug-31199
	,Qty=0  --Modified by Priyanka B on 16022018 for Bug-31199
	--,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue  --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,'' as EXPOTYPE,D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,d.ccessrate as cessrate,d.compcess as cess_amt,d.comrpcess as cessrt_amt
	,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END) 
	,RevCharge = '',h.AGAINSTGS,AmendDate =''
	 ---,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
	 ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	 ,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )  
	 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) 
	 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 
	 ,org_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )  
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end) 

	 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then (CASE WHEN ISNULL(buyer_sp.GSTIN,'') = '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'') = '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end)
	  ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	 ,D.GSTRATE,InvoiceType ='Amendments to earlier tax periods Invoice (including post supply discounts)',TransType='Debit Note for Sales'
	 ,Reason = (case when isnull(H.u_gprice,'')<>'' then substring(H.u_gprice,charindex('-',H.u_gprice)+1,len(H.u_gprice)) else '' end)
	 ,'' as portcode  ,U_IMPORM = ''
	 , CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC,OrgTransType ='Debit Note for Sales'
	 ,gs_type = (CASE WHEN H.AGAINSTGS='SALES' THEN 'Goods' WHEN H.AGAINSTGS='SERVICE INVOICE' THEN 'Services' else '' end )  
	 ,HSN_CD=(CASE WHEN H.AGAINSTGS='SALES' THEN '00' WHEN H.AGAINSTGS='SERVICE INVOICE' THEN '9999' else '' end )  
	 ,Cons_location =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end )
	 ,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	 ,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	 ,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else  buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	 ,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM DNMAIN H LEFT OUTER JOIN
	  DNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206
	  WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE') AND  ( (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ) BETWEEN @LStartDate AND @LEndDate) 
	 

	 union all
	---CNMAIN
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO, H.DATE,D .IT_CODE
	--,d.QTY  --Commented by Priyanka B on 16022018 for Bug-31199
	,Qty=0  --Modified by Priyanka B on 16022018 for Bug-31199
	--,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue  --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,EXPOTYPE=ISNULL((SELECT TOP 1 EXPOTYPE FROM #TMPTBL WHERE INV_NO =D.SBILLNO),''),D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,d.CCESSRATE as cessrate,d.COMPCESS as cess_amt,d.COMRPCESS as cessrt_amt 
	,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END) 
	,RevCharge = '',h.AGAINSTGS,AmendDate = ''
	 ---,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
	 ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	 ,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
	 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) 
	 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
	 ,org_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
	 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
	 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	 ,D.GSTRATE,InvoiceType ='Regular',TransType='Credit Note for Sales'
	 ,Reason = (case when isnull(H.u_gprice,'')<>'' then substring(H.u_gprice,charindex('-',H.u_gprice)+1,len(H.u_gprice)) else '' end)
	 ,'' as portcode,U_IMPORM = ''
	 , CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC,OrgTransType ='Sales'
	 ,gs_type = (CASE WHEN H.AGAINSTGS='SALES' THEN 'Goods' WHEN H.AGAINSTGS='SERVICE INVOICE' THEN 'Services' else '' end )  
	 ,HSN_CD=(CASE WHEN H.AGAINSTGS='SALES' THEN '00' WHEN H.AGAINSTGS='SERVICE INVOICE' THEN '9999' else '' end )  
	 ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end )
	 ,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	 ,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	 ,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else  buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	 ,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM CNMAIN H LEFT OUTER JOIN
	  CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206
	  WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE') AND  ( h.DATE BETWEEN @LStartDate AND @LEndDate)

	/*Amend Details for credit note*/
		Union all 
	---CNMAIN
	SELECT  H.Entry_ty, H.Tran_cd, D.ITSERIAL, H.INV_NO
		----h.DATE --Commented by  Suraj K. for bug-31288
	, DATE=h.AmendDate  ---Added by  Suraj K. for bug-31288 
	,D .IT_CODE
	--,d.QTY  --Commented by Priyanka B on 16022018 for Bug-31199
	,Qty=0  --Modified by Priyanka B on 16022018 for Bug-31199
	--,(ISNULL(d.qty,0) * ISNULL(d.Rate,0)) as GrossValue  --Commented by Priyanka B on 07042018 for Bug-31432
	,isnull(d.gro_amt,0) as GrossValue   --Modified by Priyanka B on 07042018 for Bug-31432
	,d.u_asseamt AS Taxableamt,d.CGST_PER,D.CGST_AMT,d.SGST_PER,D.SGST_AMT,d.IGST_PER,D.IGST_AMT
	,ORG_INVNO=d.SBILLNO, d.SBDATE  as ORG_DATE,EXPOTYPE=ISNULL((SELECT TOP 1 EXPOTYPE FROM #TMPTBL WHERE INV_NO =D.SBILLNO),''),D.CGSRT_AMT, D.SGSRT_AMT,D.IGSRT_AMT ,D.GRO_AMT,h.net_amt
	,d.CCESSRATE as cessrate,d.COMPCESS as cess_amt,d.COMRPCESS as cessrt_amt 
	,rtrim(ltrim(H.u_VESSEL)) AS SBBILLNO ,H.U_SBDT AS SBDATE,D.LineRule
	,IT.s_unit as uqc ,IT.IT_NAME,(CASE WHEN IT.Isservice = 0 THEN 'Goods' WHEN IT.Isservice = 1 THEN 'Services' ELSE '' END) AS Isservice, hsncode =(CASE WHEN IT.Isservice = 0 THEN IT.HSNCODE  WHEN IT.Isservice = 1 THEN IT.ServTCode ELSE '' END) 
	,RevCharge = '',h.AGAINSTGS,AmendDate = ''
	 ---,Cons_ac_name =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end)
	 ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.mailname else  Cons_ac.ac_name end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.ac_name else  buyer_ac.ac_name end) end )
	 ,Cons_State =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state end) end )
	 ,Cons_SUPP_TYPE =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.SUPP_TYPE else Cons_ac.SUPP_TYPE end ) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end) end )
	 ,buyer_SUPP_TYPE =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.SUPP_TYPE else  buyer_ac.SUPP_TYPE end)
	 ,Cons_st_type =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.st_type else  Cons_ac.st_type end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end) end) 
	 ,buyer_st_type =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.st_type else  buyer_ac.st_type end)
	 ,Cons_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)
	 ,org_gstin = (case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then (CASE WHEN ISNULL(Cons_sp.GSTIN,'') = '' THEN Cons_sp.UID  ELSE Cons_sp.GSTIN END ) else (CASE WHEN ISNULL(Cons_ac.GSTIN,'') = '' THEN Cons_ac.UID  ELSE Cons_ac.GSTIN  END )
				   end) else (case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE When isnull(buyer_sp.GSTIN,'') = ''  then buyer_sp.UID else buyer_sp.GSTIN end ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')= '' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END) end) end)

	 ,buyer_gstin =(case WHEN isnull(H.sAc_id, 0) > 0 then  (CASE WHEN ISNULL(buyer_sp.GSTIN,'')= '' THEN buyer_sp.UID ELSE buyer_sp.GSTIN END ) else  (CASE WHEN ISNULL(buyer_ac.GSTIN,'')='' THEN buyer_ac.UID ELSE buyer_ac.GSTIN END ) end)
	 ,pos_std_cd =h.GSTSCODE,pos = h.gststate ,Cons_pos =(case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.state else  Cons_ac.state end)
	 ,buyer_pos =(case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.state else  buyer_ac.state  end)
	 ,Cons_PANNO = Cons_ac.i_tax,buyer_PANNO = buyer_ac.i_tax
	 ,pinvno='' ,CAST('' as SMALLDATETIME) AS pinvdt,TRANSTATUS =0 ,gstype = case when IT.Isservice = 0  then (case when IT.type = 'Machinery/Stores' then 'Capital Goods' else 'Inputs' end) else 'Input Services' end ,AVL_ITC = 0
	 ,D.GSTRATE,InvoiceType ='Amendments to earlier tax periods Invoice (including post supply discounts)',TransType='Credit Note for Sales'
	 ,Reason = (case when isnull(H.u_gprice,'')<>'' then substring(H.u_gprice,charindex('-',H.u_gprice)+1,len(H.u_gprice)) else '' end)
	 ,'' as portcode,U_IMPORM = ''
	 , CAST(IT.IT_DESC AS VARCHAR(250)) AS IT_DESC,OrgTransType ='Credit Note for Sales'
	 ,gs_type = (CASE WHEN H.AGAINSTGS='SALES' THEN 'Goods' WHEN H.AGAINSTGS='SERVICE INVOICE' THEN 'Services' else '' end )  
	 ,HSN_CD=(CASE WHEN H.AGAINSTGS='SALES' THEN '00' WHEN H.AGAINSTGS='SERVICE INVOICE' THEN '9999' else '' end )  
	 ,Cons_ac_name =(case when buyer_ac.i_tax=Cons_ac.i_tax then (case WHEN isnull(H.scons_id, 0) > 0 then  Cons_sp.Location_Id else  Cons_ac.city end) else( case WHEN isnull(H.sAc_id, 0) > 0 then  buyer_sp.Location_Id else  buyer_ac.city end) end )
	 ,ECOMMAC_NM=isnull(e.gstin,'')  --Added by Priyanka B on 07032018 for Bug-31206
	 ,cast(0 as decimal(3,2)) as Diff_Per  --Added by Priyanka B on 01082018 for Bug-31736
	 ,buyer_ac_name=case WHEN isnull(H.sAc_id, 0) > 0 then (case WHEN isnull(H.scons_id, 0) > 0 then buyer_sp.mailname else  buyer_sp.ac_name end) else  buyer_ac.ac_name end  --Added by Priyanka B on 30102018 for Bug-32024
	 ,hsn_desc=cast('' as varchar(4000))  --Added by Priyanka B on 03042019 for Bug-32352
	FROM CNMAIN H LEFT OUTER JOIN
	  CNITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) LEFT OUTER JOIN
	  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
	  shipto Cons_sp ON (Cons_sp.ac_id = h.Cons_id and Cons_sp.shipto_id = h.scons_id ) LEFT OUTER JOIN
	  ac_mast Cons_ac ON (h.cons_id = Cons_ac.ac_id) LEFT OUTER JOIN
	  shipto buyer_sp ON (buyer_sp.ac_id = h.Ac_id and buyer_sp.shipto_id = h.sAc_id) LEFT OUTER JOIN
	  ac_mast buyer_ac ON (h.Ac_id = buyer_ac.ac_id)
	  left join ac_mast e on (h.ECOMMAC_NM=e.ac_name)  --Added by Priyanka B on 07032018 for Bug-31206
	  WHERE H.AGAINSTGS IN('SALES','SERVICE INVOICE') AND  ( (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''  end ) BETWEEN @LStartDate AND @LEndDate)) AA  Order by date,inv_No
--Added by Priyanka B on 03012018 for Bug-31114 Start	  
	  Update #TMPTBL_1 set uqc='NOS' where IsService='Services'
	  
	  Update #TMPTBL_1 set IGST_PER=isnull(gstrate,0) where expotype='Without IGST'  --Added by Priyanka B on 17012018 for Bug-31191
	  	
	  --Added by Priyanka B on 03042019 for Bug-32352 Start
	  Update a 
	  set hsn_desc = rtrim(ltrim(case when cast(b.it_desc as varchar(4000))<>'' then cast(b.it_desc as varchar(4000)) 
					else (case when c.hsn_desc<>'' then c.hsn_desc 
					else (case when c.hsn_code<>'' then c.hsn_code else '' end) end) end))
	  from #TMPTBL_1 a
	  inner join it_mast b on (a.it_name=b.it_name)
	  inner join hsn_master c on (b.hsncode=c.hsn_code)

	  Update a 
	  set hsn_desc = rtrim(ltrim(case when cast(b.it_desc as varchar(4000))<>'' then cast(b.it_desc as varchar(4000)) 
					else (case when c.name<>'' then c.name 
					else (case when c.accountingcode<>'' then c.accountingcode else '' end) end) end))
	  from #TMPTBL_1 a
	  inner join it_mast b on (a.it_name=b.it_name)
	  inner join sertax_mast c on (c.accountingcode=b.hsncode and c.code=b.servtcode)
	  --Added by Priyanka B on 03042019 for Bug-32352 End

	  select * from #TMPTBL_1	  
	  drop table #TMPTBL_1
	  drop table #TMPTBL
--Added by Priyanka B on 03012018 for Bug-31114 End