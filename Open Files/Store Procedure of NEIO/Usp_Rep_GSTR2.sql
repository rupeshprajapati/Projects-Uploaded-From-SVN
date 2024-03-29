IF EXISTS(SELECT name,XTYPE  FROM SYSOBJECTS WHERE XTYPE = 'p' AND name = 'Usp_Rep_GSTR2')
BEGIN
	DROP PROCEDURE [Usp_Rep_GSTR2]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Author : Suraj Kumawat 
	Date created : 08-06-2017	
	Modify By : Changed by Suraj K. for Bug-31094 date on 06-01-2018. 
*/
create Procedure [Usp_Rep_GSTR2]
	@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
	,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
	,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
	,@SAMT FLOAT,@EAMT FLOAT
	,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
	,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
	,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
	,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
	,@LYN VARCHAR(20)
	,@EXPARA  AS VARCHAR(60)= NULL
As
BEGIN
	Declare @FCON as NVARCHAR(2000),@fld_list NVARCHAR(2000)
	EXECUTE   USP_REP_FILTCON 
		@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
		,@VSDATE=@SDATE,@VEDATE=@EDATE
		,@VSAC =@SAC,@VEAC =@EAC
		,@VSIT=@SIT,@VEIT=@EIT
		,@VSAMT=@SAMT,@VEAMT=@EAMT
		,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
		,@VSCATE =@SCATE,@VECATE =@ECATE
		,@VSWARE =@SWARE,@VEWARE  =@EWARE
		,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
		,@VMAINFILE='M',@VITFILE=Null,@VACFILE='i'
		,@VDTFLD ='DATE'
		,@VLYN=Null
		,@VEXPARA=@EXPARA
		,@VFCON =@FCON OUTPUT

	-------Temporary Table Creation ----
	SELECT  PART=0,PARTSR='AAAA',SRNO= SPACE(2),INV_NO=SPACE(40) , H.DATE,ORG_INVNO=SPACE(40), H.DATE AS ORG_DATE, D.QTY,RATE =D.RATE,d.u_asseamt AS Taxableamt
	, D.CGST_AMT, D.SGST_AMT, D.IGST_AMT, D.IGST_AMT AS CESS_AMT, D.GRO_AMT, h.Net_Amt , IT.IT_NAME, cast(IT.IT_DESC as varchar(250)) as IT_DESC
	, IT.HSNCODE, gstin = space(40), location = ac.state,Inputtype =space(80),descr =space(250),uqc =space(30),org_gstin=space(40)
	  ,D.CGST_AMT as Av_CGST_AMT, D.SGST_AMT as Av_sGST_AMT, D.IGST_AMT as Av_iGST_AMT, D.IGST_AMT AS av_CESS_AMT
	  ,rptmonth=SPACE(20),rptyear =SPACE(20) ,Amenddate into #GSTR2 FROM  PTMAIN H INNER JOIN
						  PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
						  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
						  ac_mast ac ON (h.cons_id = ac.ac_id)  WHERE 1=2

	Declare @amt1 decimal(18,2),@amt2 decimal(18,2),@amt3 decimal(18,2),@amt4 decimal(18,2),@amt5 decimal(18,2),@amt6 decimal(18,2),@AgainstType varchar(50),@amenddate smalldatetime
	SELECT mEntry=case when l.Bcode_nm<>'' then l.Bcode_nm else (case when l.ext_vou=1 then '' else l.entry_ty end) end,
	RATE1= (case when (isnull(A.CGST_PER,0)+isnull(A.SGST_PER,0)) >0  then (isnull(A.CGST_PER,0)+isnull(A.SGST_PER,0))when (isnull(A.IGST_PER,0)) > 0 then (isnull(A.IGST_PER,0))else isnull(A.gstrate,0) end)
		,iigst_amt=(case when gstype <> 'Ineligible for ITC' and avl_itc = 1 then ((ISNULL(a.igst_amt,0)+ ISNULL(a.IGSRT_AMT,0))-ISNULL(b.iigst_amt,0)) else 0 end)
		,icgst_amt=(case when gstype <> 'Ineligible for ITC' and avl_itc = 1 then ((ISNULL(a.cgst_amt,0) + ISNULL(a.CGSRT_AMT,0)) - ISNULL(b.icgst_amt,0)) else 0 end)
		,isGST_AMT=(case when gstype <> 'Ineligible for ITC' and avl_itc = 1 then ((isnull(a.sGST_AMT,0)+ isnull(a.SGSRT_AMT,0))-isnull(b.isGST_AMT,0)) else 0 end)
		,ICESS_AMT =(case when gstype <> 'Ineligible for ITC' and avl_itc = 1 then ((isnull(a.CESS_AMT,0)+ isnull(a.CessRT_amt,0)) - isnull(B.ICESS_AMT,0)) else 0 end)
		,A.* 
		INTO #GSTR2TBL 
		FROM GSTR2_VW A  
		LEFT OUTER JOIN Epayment B ON (A.Tran_cd =B.tran_cd AND A.Entry_ty =B.entry_ty AND A.ITSERIAL =B.itserial)  
		inner join lcode l  on (a.entry_ty=l.entry_ty)
		WHERE (A.DATE BETWEEN @SDATE AND @EDATE) and A.AmendDate=''
		
		SELECT mEntry=case when l.Bcode_nm<>'' then l.Bcode_nm else (case when l.ext_vou=1 then '' else l.entry_ty end) end,
		RATE1= (case when (isnull(A.CGST_PER,0)+isnull(A.SGST_PER,0)) >0  then (isnull(A.CGST_PER,0)+isnull(A.SGST_PER,0))when (isnull(A.IGST_PER,0)) > 0 then (isnull(A.IGST_PER,0))else isnull(A.gstrate,0) end)
		,iigst_amt=(case when gstype <> 'Ineligible for ITC' and avl_itc = 1 then ((ISNULL(a.igst_amt,0)+ ISNULL(a.IGSRT_AMT,0))-ISNULL(b.iigst_amt,0)) else 0 end)
		,icgst_amt=(case when gstype <> 'Ineligible for ITC' and avl_itc = 1 then ((ISNULL(a.cgst_amt,0) + ISNULL(a.CGSRT_AMT,0)) - ISNULL(b.icgst_amt,0)) else 0 end)
		,isGST_AMT=(case when gstype <> 'Ineligible for ITC' and avl_itc = 1 then ((isnull(a.sGST_AMT,0)+ isnull(a.SGSRT_AMT,0))-isnull(b.isGST_AMT,0)) else 0 end)
		,ICESS_AMT =(case when gstype <> 'Ineligible for ITC' and avl_itc = 1 then ((isnull(a.CESS_AMT,0)+ isnull(a.CessRT_amt,0)) - isnull(B.ICESS_AMT,0)) else 0 end)
		,A.* 
		INTO #GSTR2AMD 
		FROM GSTR2_VW A 
		LEFT OUTER JOIN Epayment B  ON(A.Entry_ty =B.entry_ty AND A.Tran_cd=B.tran_cd AND A.ITSERIAL =B.itserial ) 
		inner join lcode l  on (a.entry_ty=l.entry_ty)
		WHERE (A.AmendDate BETWEEN @SDATE AND @EDATE)

	/*Temporary Table for Amended and not amended recoreds End */		
	
	Alter table #gstr2 add id int identity(1, 1) primary key 
	
	/*3.Inward supplies received from a registered person other than the supplies attracting reverse charge*/
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 3 as part,'3' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1
	,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT)CGST_AMT,SUM(SGST_AMT)SGST_AMT,SUM(IGST_AMT)IGST_AMT,SUM(Cess_amt)Cess_amt
	,gstin,pos,gstype
	,Av_CGST_AMT=SUM(icgst_amt)
	,Av_sGST_AMT=SUM(isGST_AMT)
	,Av_iGST_AMT=SUM(iigst_amt)
	,av_CESS_AMT = SUM(ICESS_AMT)
	FROM #GSTR2TBL 
	where mENTRY IN ('EP','PT') 
	AND ST_TYPE <> 'Out of Country' and SUPP_TYPE in('Registered','E-commerce')
	and ltrim(rtrim(HSNCODE)) <>'' 
	And gstin not in('Unregistered')AND (CGSRT_AMT + SGSRT_AMT + IGSRT_AMT) = 0 
	AND (CGST_AMT + SGST_AMT + IGST_AMT) > 0  AND LineRule = 'Taxable'
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,pos,gstype,oldgstin
	ORDER BY gstin,pinvdt,pinvno,Rate1  
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '3' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(3,'3','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	/* 4.Inward supplies on which tax is to be paid on reverse charge*/
	
	/* 4A. Inward supplies received from a registered supplier (attracting reverse charge) */
	
	select ENTRY_ALL=case when l.Bcode_nm<>'' then l.Bcode_nm else (case when l.ext_vou=1 then '' else l.entry_ty end) end,
	Main_tran,ENTRY_ALL as mENTRY_ALL 
	into #rcmpay 
	from mainall_vw a
	inner join lcode l  on (a.entry_all=l.entry_ty)
	where a.entry_ty ='gb' and date<=@EDATE 
	group by  Main_tran,ENTRY_ALL,bcode_nm,ext_vou,l.entry_ty

	select A.*,isnull(b.main_tran,0) as pay  into #GSTR2TBL_RCM from  #GSTR2TBL A 
	left outer join #rcmpay b on (a.tran_cd =b.main_tran and a.entry_ty =b.entry_all)
	
	SELECT A.ENTRY_ALL,A.Main_tran ,SUM((CASE WHEN B.AC_NAME = 'Central GST Payable A/C '  THEN A.new_all ELSE 0 END ))  AS CGST,
	SUM((CASE WHEN B.AC_NAME = 'State GST Payable A/C '  THEN A.new_all ELSE 0 END ))  AS SGST ,
	SUM((CASE WHEN B.AC_NAME = 'Integrated GST Payable A/C '  THEN A.new_all ELSE 0 END ))  AS IGST 
	,SUM(CASE WHEN B.AC_NAME = 'Compensation Cess Payable A/C '  THEN A.new_all ELSE 0 END )  AS CESS
	INTO #RMCPAYMENT from mainall_vw A LEFT OUTER JOIN AC_MAST  B ON (A.Ac_id =B.Ac_id) where A.ENTRY_TY = 'GB' AND A.DATE BETWEEN @SDATE AND @EDATE  AND (A.ENTRY_ALL+QUOTENAME(A.Main_tran)) IN (SELECT (ENTRY_TY+QUOTENAME(Tran_cd)) FROM #GSTR2TBL_RCM )
	GROUP BY A.ENTRY_ALL,A.Main_tran 
	ORDER BY A.ENTRY_ALL,A.Main_tran	 

	DELETE FROM #RMCPAYMENT WHERE ENTRY_ALL NOT IN('PT','P1','E1','UB','PK')

	DECLARE @ENTRY_ALL VARCHAR(2),@MAIN_TRAN INT,@CGST DECIMAL(18,2),@SGST DECIMAL(18,2),@IGST DECIMAL(18,2),@CESS DECIMAL(18,2)
	,@ENTRY_TY VARCHAR(2),@TRAN_CD INT,@CGST1 DECIMAL(18,2),@SGST1 DECIMAL(18,2),@IGST1 DECIMAL(18,2),@CESS1 DECIMAL(18,2),@itserial varchar(20)
	,@CGST2 DECIMAL(18,2),@SGST2 DECIMAL(18,2),@IGST2 DECIMAL(18,2),@CESS2 DECIMAL(18,2)
	DECLARE CUR_RCM CURSOR FOR SELECT  ENTRY_ALL,MAIN_TRAN,CGST,SGST,IGST,CESS FROM #RMCPAYMENT
	OPEN CUR_RCM
	FETCH CUR_RCM INTO @ENTRY_ALL,@MAIN_TRAN,@CGST,@SGST,@IGST,@CESS
	WHILE(@@FETCH_STATUS =0)
	BEGIN
		SET @CGST2 = 0
		SET @SGST2 = 0
		SET @IGST2 = 0
		SET @CESS2 = 0
		DECLARE M_RCM CURSOR FOR SELECT Entry_ty,Tran_cd,icgst_amT,isGST_AMT,iigst_amt,ICESS_AMT,itserial FROM  #GSTR2TBL_RCM WHERE Entry_ty = @ENTRY_ALL AND Tran_cd = @MAIN_TRAN ORDER BY Entry_ty,Tran_cd,Rate1  
		OPEN M_RCM
		FETCH M_RCM INTO @ENTRY_TY,@TRAN_CD,@CGST1,@SGST1,@IGST1,@CESS1,@itserial
		WHILE(@@FETCH_STATUS =0)
		BEGIN
			
		    if @CGST <> 0  OR  @CGST  = 0
				BEGIN
				   SET @CGST2 = @CGST - @CGST1
				   update  #GSTR2TBL_RCM set icgst_amT = CASE WHEN @CGST2 < 0  THEN (CASE WHEN @CGST <=0  THEN 0 ELSE @CGST END )  ELSE @CGST1 END WHERE Tran_cd = @TRAN_CD AND Entry_ty =@ENTRY_TY AND ITSERIAL =@itserial
				   SET @CGST = @CGST- @CGST1
				END 
		    if @SGST <> 0  OR  @SGST  = 0
				BEGIN
				   SET @SGST2 = @SGST - @SGST1
				   update  #GSTR2TBL_RCM set isGST_AMT = CASE WHEN @SGST2 < 0  THEN  (CASE WHEN @SGST <= 0  THEN 0 ELSE @SGST END ) ELSE @SGST1 END WHERE Tran_cd = @TRAN_CD AND Entry_ty =@ENTRY_TY AND ITSERIAL =@itserial 
				   SET @SGST = @SGST- @SGST1
				END 
		    if @IGST <> 0  OR  @IGST  = 0
				BEGIN
				   SET @IGST2 = @IGST - @IGST1
				   update  #GSTR2TBL_RCM set iigst_amt = CASE WHEN @IGST2 < 0  THEN (CASE WHEN @IGST  <= 0  THEN 0 ELSE @IGST  END )ELSE @IGST1 END WHERE Tran_cd = @TRAN_CD AND Entry_ty =@ENTRY_TY AND ITSERIAL =@itserial 
				   SET @IGST = @IGST-@IGST1

				END 
     				
		    if @CESS <> 0  OR  @CESS  = 0
				BEGIN
				   SET @CESS2 = @CESS - @CESS1
				   update  #GSTR2TBL_RCM set ICESS_AMT = CASE WHEN @CESS2 < 0   THEN (CASE WHEN @CESS   <= 0  THEN 0 ELSE @CESS   END )ELSE @CESS1 END WHERE Tran_cd = @TRAN_CD AND Entry_ty =@ENTRY_TY AND ITSERIAL =@itserial 
				   SET @CESS = @CESS- @CESS1

				END
			FETCH  M_RCM INTO @ENTRY_TY,@TRAN_CD,@CGST1,@SGST1,@IGST1,@CESS1,@itserial
		END
		CLOSE M_RCM
		DEALLOCATE M_RCM
		FETCH CUR_RCM INTO @ENTRY_ALL,@MAIN_TRAN,@CGST,@SGST,@IGST,@CESS	
	END
	CLOSE CUR_RCM
	DEALLOCATE CUR_RCM
	
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 4 as part,'4A' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1
	,SUM(TaxableAmt)TaxableAmt  
	,SUM(CGSRT_AMT)CGSRT_AMT,SUM(SGSRT_AMT)SGSRT_AMT,SUM(IGSRT_AMT)IGSRT_AMT
	,sum(CessRt_Amt) as CessRt_Amt,gstin
	,pos,gstype
	,Av_CGST_AMT=SUM(case when pay > 0 then  icgst_amt else 0 end)
	,Av_sGST_AMT=SUM(case when pay > 0 then  isGST_AMT else 0 end)
	,Av_iGST_AMT=SUM(case when pay > 0 then  iigst_amt else 0 end)
	,av_CESS_AMT = SUM(case when pay > 0 then  ICESS_AMT else 0 end)
	FROM #GSTR2TBL_RCM
	where mENTRY IN ('EP','PT')
	AND ST_TYPE <> 'Out of Country' and SUPP_TYPE = 'Registered'
	and ltrim(rtrim(HSNCODE)) <>'' 
	And gstin not in('Unregistered') AND LineRule = 'Taxable'
	AND (CGSRT_AMT + SGSRT_AMT + IGSRT_AMT > 0)
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,pos,gstype,oldgstin	
	ORDER BY gstin,pinvdt,pinvno,Rate1  
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '4A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(4,'4A','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	
	/*4B. Inward supplies received from an unregistered supplier*/
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 4 as part,'4B' as partsr ,'A' srno,INV_NO,DATE,Net_amt,Rate1
	,SUM(TaxableAmt)TaxableAmt,SUM(CGST_AMT)CGST_AMT,SUM(SGST_AMT)SGST_AMT,SUM(IGST_AMT)IGST_AMT
	,sum(Cess_amt)as Cess_amt 
	,'' AS GSTINNO,pos,gstype
	,Av_CGST_AMT1=SUM((case when pay > 0 then  icgst_amt else 0 end))
	,Av_sGST_AMT1=SUM((case when pay > 0 then  isGST_AMT else 0 end))
	,Av_iGST_AMT1=SUM((case when pay > 0 then  iigst_amt else 0 end))
	,av_CESS_AMT1 = SUM((case when pay > 0 then  ICESS_AMT else 0 end))
	FROM #GSTR2TBL_RCM
	where ENTRY_TY IN ('UB') GROUP BY INV_NO,DATE,Net_amt,Rate1,gstin,pos,gstype order by DATE,INV_NO

	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '4B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(4,'4B','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END

	/*4C. Import of service*/
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 4 as part,'4C' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1,
	SUM(TaxableAmt)TaxableAmt 
	,SUM(CGSRT_AMT)CGSRT_AMT,SUM(SGSRT_AMT)SGSRT_AMT,SUM(IGSRT_AMT)IGSRT_AMT,sum(CessRt_amt) as CessRt_amt
	,gstin,pos,gstype
	,Av_CGST_AMT=SUM(case when pay > 0 then  icgst_amt else 0 end)
	,Av_sGST_AMT=SUM(case when pay > 0 then  isGST_AMT else 0 end)
	,Av_iGST_AMT=SUM(case when pay > 0 then  iigst_amt else 0 end)
	,av_CESS_AMT = SUM(case when pay > 0 then  ICESS_AMT else 0 end)

	FROM #GSTR2TBL_RCM 
	where mENTRY IN ('EP','PT')
	and Isservice = 'Services'
	AND ST_TYPE IN('Out of Country','Interstate','Intrastate') and SUPP_TYPE in('Import','SEZ','EOU','','EXPORT')
	AND (CGSRT_AMT + SGSRT_AMT + IGSRT_AMT) > 0
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,pos,gstype,oldgstin 
	ORDER BY gstin,pinvdt,pinvno,Rate1  
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '4C' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(4,'4C','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END

	/*5. Inputs/Capital goods received from Overseas or from SEZ units on a Bill of Entry*/
	 -----5A. Imports
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
	Select 5 as part,'5A' as partsr ,'A' srno,isnull(beno,'')as beno,isnull(bedt,'')as bedt
	,Net_amt,Rate1,SUM(TaxableAmt)TaxableAmt ,SUM(CGST_AMT)CGST_AMT,SUM(SGST_AMT)SGST_AMT,SUM(IGST_AMT)IGST_AMT
	,sum(Cess_amt)
	,gstin,pos,gstype
	,Av_CGST_AMT=SUM(icgst_amt)
	,Av_sGST_AMT=SUM(isGST_AMT)
	,Av_iGST_AMT=SUM(iigst_amt)
	,av_CESS_AMT = SUM(ICESS_AMT)
	,portcode
	FROM #GSTR2TBL 
	where mENTRY IN ('EP','PT')
	AND ((ST_TYPE ='Out of Country') OR (ST_TYPE IN('INTERSTATE','INTRASTATE') and SUPP_TYPE in('IMPORT','EOU','EXPORT')))
	AND ISSERVICE='GOODS' 
	GROUP BY INV_NO,DATE,Net_amt,Rate1,gstin,pos,gstype,beno,bedt,portcode,oldgstin order by isnull(beno,''),isnull(bedt,'')
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '5A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(5,'5A','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
		
	-----5B. Received from SEZ
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT
	,descr)
	Select 5 as part,'5B' as partsr ,'A' srno,beno,bedt,Net_amt,Rate1
	,SUM(TaxableAmt)TaxableAmt,SUM(CGST_AMT)CGST_AMT,SUM(SGST_AMT)SGST_AMT,SUM(IGST_AMT)IGST_AMT
	,sum(Cess_amt) AS Cess_amt
	,gstin,pos,gstype
	,Av_CGST_AMT=SUM(icgst_amt)
	,Av_sGST_AMT=SUM(isGST_AMT)
	,Av_iGST_AMT=SUM(iigst_amt)
	,av_CESS_AMT = SUM(ICESS_AMT)
	,portcode
	FROM #GSTR2TBL 
	where mENTRY IN ('EP','PT')
	AND ST_TYPE IN('Interstate','Intrastate') and SUPP_TYPE ='SEZ'
	AND ISSERVICE='GOODS'
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,pos,gstype,beno,bedt,oldgstin ,portcode order by bedt,beno
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '5B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(5,'5B','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	----- Port code +No of BE=13 digits (This section will be use for Details section in report)
	Insert into #GSTR2(PART,PARTSR,SRNO,Taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
   SELECT 
		5 as part,'5B' as partsr ,'B' AS srno,SUM(Taxableamt)TaxableAmt
		,0.00 AS CGST_AMT1
		,0.00 AS SGST_AMT1
		,0.00 AS IGST_AMT1
		,0.00 AS Cess_amt1
		,0.00 AS  Av_CGST_AMT1
		,0.00 AS Av_sGST_AMT1
		,Av_iGST_AMT1=SUM(Av_iGST_AMT)
		,av_CESS_AMT1 = SUM(av_CESS_AMT)
		,cast(rtrim(isnull(DESCR,'')) as varchar)+cast(rtrim(isnull(INV_NO,'')) as varchar)
   FROM #GSTR2 WHERE PARTSR in('5B','5A' ) 
   GROUP BY cast(rtrim(isnull(DESCR,'')) as varchar)+cast(rtrim(isnull(INV_NO,'')) as varchar)  
   HAVING SUM(Taxableamt) > 0
   ORDER BY cast(rtrim(isnull(DESCR,'')) as varchar)+cast(rtrim(isnull(INV_NO,'')) as varchar)  
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '5B' AND SRNO ='B')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(5,'5B','B','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END

	/*6. Amendments to details of inward supplies furnished in returns for earlier tax periods in Tables 3, 4 and 5 
		[including debit notes/credit notes issued and their subsequent amendments]*/
		SELECT *  into #gstr2amd3 FROM (
		-----Section 3a
		SELECT * FROM #GSTR2AMD 
		where mENTRY IN ('EP','PT')
		AND ST_TYPE <> 'Out of Country' 
		and SUPP_TYPE in('Registered','E-commerce')
		and ltrim(rtrim(HSNCODE)) <>'' 
		And gstin not in('Unregistered') 
				AND (CGSRT_AMT + SGSRT_AMT + IGSRT_AMT ) = 0 AND (CGST_AMT + SGST_AMT + IGST_AMT) > 0 AND LineRule = 'Taxable'
		----Section 4a
		UNION ALL 
		SELECT * FROM #GSTR2AMD 
		where mENTRY IN ('EP','PT')
		AND ST_TYPE <> 'Out of Country' and SUPP_TYPE = 'Registered'
		and ltrim(rtrim(HSNCODE)) <>''
		And gstin not in('Unregistered') AND LineRule = 'Taxable'
			AND (CGSRT_AMT + SGSRT_AMT + IGSRT_AMT ) > 0 
		----Section 4b
		UNION ALL 
	    SELECT  * 	FROM #GSTR2AMD where ENTRY_TY IN ('UB')
	   ---- Section 4c
		UNION ALL 
		select * FROM #GSTR2AMD where ENTRY_TY ='E1' AND ST_TYPE IN('Out of Country','Interstate','Intrastate') and SUPP_TYPE in('Import','SEZ','EOU','','Export')
		AND (CGSRT_AMT + SGSRT_AMT + IGSRT_AMT ) > 0 
		)AA


	 ----6A. Supplies other than import of goods or goods received from SEZ [Information furnished in Table 3 and 4 of earlier returns]-If details furnished earlier were incorrect
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,ORG_INVNO,ORG_DATE,org_gstin)
	Select 6 as part,'6A' as partsr ,'A' srno,pinvno
	,pinvdt  
	,Net_amt,Rate1
	,SUM(TaxableAmt)TaxableAmt
	,SUM(isnull(CGST_AMT,0)+isnull(CGSRT_AMT,0)) as CGST_AMT1
	,SUM(isnull(SGST_AMT,0)+ ISNULL(SGSRT_AMT,0)) as SGST_AMT1
	,SUM(isnull(IGST_AMT,0)+ (ISNULL(IGSRT_AMT,0)))IGST_AMT1
	,sum(isnull(Cess_amt,0)+(ISNULL(CessRT_amt,0))) AS Cess_amt1
	,gstin,pos,gstype
	,Av_CGST_AMT=SUM(icgst_amt)
	,Av_sGST_AMT=SUM(isGST_AMT)
	,Av_iGST_AMT=SUM(iigst_amt)
	,av_CESS_AMT = SUM(ICESS_AMT)
	,ORG_INVNO,ORG_DATE,oldgstin = (case when ISNULL(oldgstin,'')='' then GSTIN else oldgstin end)
	FROM #gstr2amd3 
	where mENTRY IN ('EP','PT')
	and ltrim(rtrim(HSNCODE)) <>'' 
	and SUPP_TYPE NOT IN('SEZ','IMPORT','EOU','Export') and ST_TYPE <> 'Out of Country' 
	and ((CGST_AMT + SGST_AMT + IGST_AMT )>0
	or (CGSRT_AMT + SGSRT_AMT + IGSRT_AMT) > 0 ) 
	
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,pos,gstype,net_amt,ORG_INVNO,ORG_DATE,oldgstin
	union all	
	Select 6 as part,'6A' as partsr ,'A' srno,pinvno
	,pinvdt 
	,Net_amt,Rate1
	,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT)CGST_AMT,SUM(isnull(SGST_AMT,0))SGST_AMT,SUM(IGST_AMT)IGST_AMT
	,sum(Cess_amt) AS Cess_amt,gstin,pos,gstype
	,Av_CGST_AMT=SUM(icgst_amt)
	,Av_sGST_AMT=SUM(isGST_AMT)
	,Av_iGST_AMT=SUM(iigst_amt)
	,av_CESS_AMT = SUM(ICESS_AMT)
	,ORG_INVNO,ORG_DATE,gstin1= (case when ISNULL(oldgstin,'') <> '' then oldgstin else GSTIN  end)
	FROM #gstr2amd3 where ENTRY_TY IN ('UB')  
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,pos,gstype,net_amt,ORG_INVNO,ORG_DATE,oldgstin
	order by pinvdt,pinvno
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '6A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(6,'6A','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END	
	/*6B. Supplies by way of import of goods or goods received from SEZ [Information furnished in Table 5 of earlier returns]-If details furnished earlier were incorrect*/	
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,ORG_INVNO,ORG_DATE,org_gstin)
	Select 6 as part,'6B' as partsr ,'A' srno,isnull(beno,'')as beno,BEDT ,Net_amt,Rate1
	,SUM(TaxableAmt)TaxableAmt
	,SUM(CGST_AMT)CGST_AMT,SUM(SGST_AMT)SGST_AMT,SUM(IGST_AMT)IGST_AMT
	,sum(Cess_Amt) as Cess_Amt,gstin,pos,gstype
	,Av_CGST_AMT=SUM(icgst_amt)
	,Av_sGST_AMT=SUM(isGST_AMT)
	,Av_iGST_AMT=SUM(iigst_amt)
	,av_CESS_AMT = SUM(ICESS_AMT)
	,orgbeno,orgbedt
	,oldgstin=(case when ISNULL(oldgstin,'')='' then GSTIN else oldgstin end)
	FROM #GSTR2AMD 
	where mENTRY IN ('PT')
	AND ST_TYPE IN('Out of Country','Interstate','Intrastate')
	and SUPP_TYPE in('IMPORT','EOU','EXPORT','SEZ','') 
	AND Isservice = 'GOODS'
	
	GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,pos,gstype,net_amt,orgbeno,orgbedt,oldgstin,BEDT,beno  order by BEDT,beno
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '6B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(6,'6B','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END

	/*6C. Debit Notes/Credit Notes [original]*/
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,ORG_INVNO,ORG_DATE,org_gstin)
	select 
	6 as part,'6C' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1
	,SUM(TaxableAmt) AS  TaxableAmt
	,SUM(CGSRT_AMT) AS CGSRT_AMT,SUM(SGSRT_AMT)AS SGSRT_AMT
	,SUM(IGSRT_AMT) AS IGSRT_AMT
	,sum(CessRt_Amt) AS CessRt_Amt
	,gstin,pos,gstype
	,SUM(Av_CGST_AMT) as Av_CGST_AMT
	,SUM(Av_sGST_AMT) as Av_sGST_AMT
	,SUM(Av_iGST_AMT) as Av_iGST_AMT
	,SUM(av_CESS_AMT)  as av_CESS_AMT 
	,ORG_INVNO,ORG_DATE,org_gstin
	 from (Select pinvno,pinvdt,Net_amt,Rate1
	,(TaxableAmt) as TaxableAmt
	,(case when CGST_AMT>0 then CGST_AMT else CGSRT_AMT end) as CGSRT_AMT
	,(case when SGST_AMT>0 then SGST_AMT else SGSRT_AMT end) as SGSRT_AMT
	,(case when IGST_AMT>0 then IGST_AMT else IGSRT_AMT end) as IGSRT_AMT
	,(case when Cess_Amt>0 then Cess_Amt else CessRt_Amt end) as CessRt_Amt
	,gstin,pos,gstype
	,Av_CGST_AMT=isnull(icgst_amt,0)
	,Av_sGST_AMT=isnull(isGST_AMT,0)
	,Av_iGST_AMT=isnull(iigst_amt,0)
	,av_CESS_AMT = isnull(ICESS_AMT,0)
	,ORG_INVNO,ORG_DATE
	,gstin AS org_gstin FROM #GSTR2TBL 
	--where mENTRY IN ('GC','GD','PR')  --Commented by Priyanka B on 23072019 for Bug-32704
	where mENTRY IN ('CN','DN','PR')  --Modified by Priyanka B on 23072019 for Bug-32704
	and SUPP_TYPE in('IMPORT','EOU','EXPORT','')
	union all
	Select pinvno,pinvdt,Net_amt,Rate1
	,(TaxableAmt) as TaxableAmt
	,(case when CGST_AMT>0 then CGST_AMT else CGSRT_AMT end) as CGSRT_AMT
	,(case when SGST_AMT>0 then SGST_AMT else SGSRT_AMT end) as SGSRT_AMT
	,(case when IGST_AMT>0 then IGST_AMT else IGSRT_AMT end) as IGSRT_AMT
	,(case when Cess_Amt>0 then Cess_Amt else CessRt_Amt end) as CessRt_Amt
	,gstin,pos,gstype
	,Av_CGST_AMT=isnull(icgst_amt,0)
	,Av_sGST_AMT=isnull(isGST_AMT,0)
	,Av_iGST_AMT=isnull(iigst_amt,0)
	,av_CESS_AMT = isnull(ICESS_AMT,0)
	,ORG_INVNO,ORG_DATE
	,gstin  AS org_gstin  FROM #GSTR2TBL 
	--where mENTRY IN ('GC','GD','PR')  --Commented by Priyanka B on 23072019 for Bug-32704
	where mENTRY IN ('CN','DN','PR')  --Modified by Priyanka B on 23072019 for Bug-32704
	and SUPP_TYPE not in('Compounding','IMPORT','EOU','EXPORT','') and LineRule in('Taxable') and HSNCODE <> '' )aa
	 GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,pos,gstype,net_amt,ORG_INVNO,ORG_DATE,org_gstin 
	ORDER BY gstin,pinvdt,pinvno,Rate1
	 
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '6C' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(6,'6C','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	/*6D. Debit Notes/ Credit Notes [amendment of debit notes/credit notes furnished in earlier tax periods]*/
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,ORG_INVNO,ORG_DATE,org_gstin)
	select 
	6 as part,'6D' as partsr ,'A' srno,pinvno,pinvdt,Net_amt,Rate1
	,SUM(TaxableAmt) AS  TaxableAmt
	,SUM(CGSRT_AMT) AS CGSRT_AMT
	,SUM(SGSRT_AMT)AS SGSRT_AMT
	,SUM(IGSRT_AMT) AS IGSRT_AMT
	,sum(CessRt_Amt) AS CessRt_Amt
	,gstin,pos,gstype
	,SUM(Av_CGST_AMT) as Av_CGST_AMT
	,SUM(Av_sGST_AMT) as Av_sGST_AMT
	,SUM(Av_iGST_AMT) as Av_iGST_AMT
	,SUM(av_CESS_AMT)  as av_CESS_AMT 
	,ORG_INVNO,ORG_DATE,org_gstin
	 from (Select pinvno,pinvdt,Net_amt,Rate1
	,(TaxableAmt) as TaxableAmt
	,(case when CGST_AMT>0 then CGST_AMT else CGSRT_AMT end) as CGSRT_AMT
	,(case when SGST_AMT>0 then SGST_AMT else SGSRT_AMT end) as SGSRT_AMT
	,(case when IGST_AMT>0 then IGST_AMT else IGSRT_AMT end) as IGSRT_AMT
	,(case when Cess_Amt>0 then Cess_Amt else CessRt_Amt end) as CessRt_Amt
	,gstin,pos,gstype
	,Av_CGST_AMT=isnull(icgst_amt,0)
	,Av_sGST_AMT=isnull(isGST_AMT,0)
	,Av_iGST_AMT=isnull(iigst_amt,0)
	,av_CESS_AMT = isnull(ICESS_AMT,0)
	,ORG_INVNO,ORG_DATE,(case when ISNULL(oldgstin,'') <> '' then oldgstin else GSTIN  end) as org_gstin,AmendDate  
	 FROM #GSTR2AMD 
	 --where mENTRY IN ('GC','GD','PR')  --Commented by Priyanka B on 23072019 for Bug-32704
	where mENTRY IN ('CN','DN','PR')  --Modified by Priyanka B on 23072019 for Bug-32704
	 and SUPP_TYPE in('IMPORT','EOU','EXPORT','')
	union all
	Select pinvno,pinvdt,Net_amt,Rate1
	,(TaxableAmt) as TaxableAmt
	,(case when CGST_AMT>0 then CGST_AMT else CGSRT_AMT end) as CGSRT_AMT
	,(case when SGST_AMT>0 then SGST_AMT else SGSRT_AMT end) as SGSRT_AMT
	,(case when IGST_AMT>0 then IGST_AMT else IGSRT_AMT end) as IGSRT_AMT
	,(case when Cess_Amt>0 then Cess_Amt else CessRt_Amt end) as CessRt_Amt
	,gstin,pos,gstype
	,Av_CGST_AMT=isnull(icgst_amt,0)
	,Av_sGST_AMT=isnull(isGST_AMT,0)
	,Av_iGST_AMT=isnull(iigst_amt,0)
	,av_CESS_AMT = isnull(ICESS_AMT,0)
	,ORG_INVNO,ORG_DATE,oldgstin=(case when ISNULL(oldgstin,'')='' then GSTIN else oldgstin end),AmendDate 
	FROM #GSTR2AMD 
	--where ENTRY_TY IN('C6','D6','GC','GD','PR') --Commented by Priyanka B on 23072019 for Bug-32704
	where mENTRY IN ('CN','DN','PR')  --Modified by Priyanka B on 23072019 for Bug-32704
	and SUPP_TYPE not in('Compounding','IMPORT','EOU','EXPORT','') and LineRule in('Taxable') and HSNCODE <> '' )aa
	 GROUP BY pinvno,pinvdt,Net_amt,Rate1,gstin,pos,gstype,net_amt,ORG_INVNO,ORG_DATE,org_gstin,amenddate  order by pinvdt,pinvno

	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '6D' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(6,'6D','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	
	/*7. Supplies received from composition taxable person and other exempt/Nil rated/Non GST supplies received*/
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '7' AND SRNO ='A')
	BEGIN
		SET @amt1 = 0
		SET @amt2 = 0
		SET @amt3 = 0
		SET @amt4 = 0
		SELECT 
		---Compounding 
		@amt1 =isnull(sum((case when supp_type = 'Compounding' then 
			--(CASE WHEN mEntry in('PT','EP','GC') THEN +GRO_AMT ELSE -GRO_AMT END) --Commented by Priyanka B on 23072019 for Bug-32704
			(CASE WHEN mEntry in('PT','EP','CN') THEN +GRO_AMT ELSE -GRO_AMT END)  --Modified by Priyanka B on 23072019 for Bug-32704
			else
		 0.00  end)),0)
		 ---Exempted
		,@amt2  =isnull(sum((case when supp_type <> 'Compounding' and LINERULE ='Exempted' AND hsncode <> '' then  
			--(CASE WHEN mEntry in('PT','EP','GC') THEN +GRO_AMT ELSE -GRO_AMT END) --Commented by Priyanka B on 23072019 for Bug-32704
			(CASE WHEN mEntry in('PT','EP','CN') THEN +GRO_AMT ELSE -GRO_AMT END)  --Modified by Priyanka B on 23072019 for Bug-32704
			else
		 0.00  end)),0)
		 ---NillRAted	
		,@amt3  =isnull(sum((case when supp_type <> 'Compounding' and LINERULE in('Nill Rated','Nil Rated') AND hsncode <> '' then  
			--(CASE WHEN mEntry in('PT','EP','GC') THEN +GRO_AMT ELSE -GRO_AMT END)  --Commented by Priyanka B on 23072019 for Bug-32704
			(CASE WHEN mEntry in('PT','EP','CN') THEN +GRO_AMT ELSE -GRO_AMT END)  --Modified by Priyanka B on 23072019 for Bug-32704
			else
		 0.00  end)),0)
		 ---nongst
		,@amt4  =isnull(sum((case when supp_type <> 'Compounding'  AND  ( hsncode = '' or LINERULE ='Non GST') and LINERULE NOT IN('Nill Rated','Nil Rated','Exempted') then
			--(CASE WHEN mEntry in('PT','EP','GC') THEN +GRO_AMT ELSE -GRO_AMT END)  --Commented by Priyanka B on 23072019 for Bug-32704
			(CASE WHEN mEntry in('PT','EP','CN') THEN +GRO_AMT ELSE -GRO_AMT END)  --Modified by Priyanka B on 23072019 for Bug-32704
			else
		 0.00  end)),0)
		 FROM #GSTR2TBL  
		 --WHERE mEntry in('PT','PR','EP','GD','GC') --Commented by Priyanka B on 23072019 for Bug-32704
		 WHERE mEntry in('PT','EP','CN','DN','PR') --Modified by Priyanka B on 23072019 for Bug-32704
		 AND  st_type ='Interstate'  and SUPP_TYPE not in('SEZ','EOU','IMPORT')
		
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(7,'7','A','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','',0,0,0,0,'7A. Inter-State supplies')
	END
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '7' AND SRNO ='B')
	BEGIN
		SET @amt1 = 0
		SET @amt2 = 0
		SET @amt3 = 0
		SET @amt4 = 0
		SELECT 
		---Compounding 
		@amt1 =isnull(sum((case when supp_type = 'Compounding' then
			--(CASE WHEN mEntry in('PT','EP','GC') THEN +GRO_AMT ELSE -GRO_AMT END) --Commented by Priyanka B on 23072019 for Bug-32704
			(CASE WHEN mEntry in('PT','EP','CN') THEN +GRO_AMT ELSE -GRO_AMT END)  --Modified by Priyanka B on 23072019 for Bug-32704
			else
		 0.00  end)),0)
		 ---Exempted
		,@amt2  =isnull(sum((case when supp_type <> 'Compounding' and LINERULE ='Exempted' AND hsncode <> '' then
			--(CASE WHEN mEntry in('PT','EP','GC') THEN +GRO_AMT ELSE -GRO_AMT END) --Commented by Priyanka B on 23072019 for Bug-32704
			(CASE WHEN mEntry in('PT','EP','CN') THEN +GRO_AMT ELSE -GRO_AMT END)  --Modified by Priyanka B on 23072019 for Bug-32704
			else
		 0.00  end)),0)
		 ---NillRAted	
		,@amt3  =isnull(sum((case when supp_type <> 'Compounding' and LINERULE in('Nill Rated','Nil Rated') AND hsncode <> '' then
			--(CASE WHEN mEntry in('PT','EP','GC') THEN +GRO_AMT ELSE -GRO_AMT END) --Commented by Priyanka B on 23072019 for Bug-32704
			(CASE WHEN mEntry in('PT','EP','CN') THEN +GRO_AMT ELSE -GRO_AMT END)  --Modified by Priyanka B on 23072019 for Bug-32704
			else
		 0.00  end)),0)
		 ---nongst
		,@amt4  =isnull(sum((case when supp_type <> 'Compounding'  AND (hsncode = '' or LINERULE ='Non GST') and LINERULE NOT IN('Nill Rated','Nil Rated','Exempted') then 
			--(CASE WHEN mEntry in('PT','EP','GC') THEN +GRO_AMT ELSE -GRO_AMT END) --Commented by Priyanka B on 23072019 for Bug-32704
			(CASE WHEN mEntry in('PT','EP','CN') THEN +GRO_AMT ELSE -GRO_AMT END)  --Modified by Priyanka B on 23072019 for Bug-32704
			else
		 0.00  end)),0)
		 FROM #GSTR2TBL
		 --WHERE mEntry in('PT','PR','EP','GD','GC') --Commented by Priyanka B on 23072019 for Bug-32704
		  WHERE mEntry in('PT','EP','CN','DN','PR')  --Modified by Priyanka B on 23072019 for Bug-32704
		 AND  st_type ='Intrastate'  and SUPP_TYPE not in('SEZ','EOU','IMPORT')
		 
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(7,'7','B','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','',0,0,0,0,'7B. Intra-state supplies')
	END
	-----8. ISD credit received
	----8A. ISD Invoice

	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 8 as part,'8A' as partsr ,'A' srno,pinvno,pinvdt,0.00 as Net_amt,0 as Rate1,SUM(TaxableAmt) as TaxableAmt 
	,SUM(CGST_AMT)as CGST_AMT1,SUM(SGST_AMT) as SGSRT_AMT1,SUM(IGST_AMT)as IGST_AMT1,sum(Cess_Amt) as Cess_Amt1
	,'' as gstin,'' as location,'' as gstype
	,Av_CGST_AMT=SUM(icgst_amt)
	,Av_sGST_AMT=SUM(isGST_AMT)
	,Av_iGST_AMT=SUM(iigst_amt)
	,av_CESS_AMT = SUM(ICESS_AMT)
	FROM #GSTR2TBL
	where ENTRY_TY ='J6'
	GROUP BY pinvno,pinvdt

	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '8A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(8,'8A','A','','','','',0,0,0,0,0,0,0,0,'','','',0,0,0,0,'')
	END
	---8B. ISD Credit Note
	Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,net_amt,RATE,Taxableamt,
	CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,gstin,location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
	Select 8 as part,'8B' as partsr ,'A' srno
	,inv_no,[DATE]
	,0.00 as Net_amt,0 as Rate1,SUM(TaxableAmt) as TaxableAmt 
	,SUM(CGST_AMT)as CGST_AMT1,SUM(SGST_AMT) as SGSRT_AMT1,SUM(IGST_AMT)as IGST_AMT1,sum(Cess_Amt) as Cess_Amt1 --Modified By Prajakta B. on 19082017
	,'' as gstin,'' as location,'' as gstype
	,Av_CGST_AMT=SUM(icgst_amt)
	,Av_sGST_AMT=SUM(isGST_AMT)
	,Av_iGST_AMT=SUM(iigst_amt)
	,av_CESS_AMT =SUM(ICESS_AMT)
	FROM #GSTR2TBL 
	where ENTRY_TY ='J8'
	GROUP BY 
	INV_NO,[Date] 
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '8B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(8,'8B','A','','','','',0,0,0,0,0,0,0,0,'','','',0,0,0,0,'')
	END
	----9. TDS and TCS Credit received 
	----9A. TDS
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '9A' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(9,'9A','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	---9B. TCS
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '9B' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(9,'9B','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	----10.Consolidated Statement of Advances paid/Advance adjusted on account of receipt of supply
		-----10A. Advance amount paid for reverse charge supplies in the tax period (tax amount to be added to output tax liability)
	/* Taxallocation details */
	SELECT DISTINCT TRAN_CD,ENTRY_TY,POS,pos_std_cd,DATE INTO #BANK_TMP FROM #GSTR2TBL
	WHERE mEntry in('PT','CP','EP','BP')
	select A.*,B.POS,B.POS_STD_CD,C.DATE INTO #TaxAlloc_tmp from TaxAllocation A INNER JOIN #BANK_TMP B ON (A.Itref_tran =B.TRAN_CD AND A.REntry_ty =B.Entry_ty)
	INNER JOIN #BANK_TMP C ON (A.Entry_ty =C.Entry_ty AND A.Tran_cd =C.Tran_cd) WHERE C.DATE BETWEEN @SDATE AND @EDATE
	SELECT * INTO #Tax_tmp FROM (select PKEY = '+', rate1,pos ,Taxableamt,CGSRT_AMT,SGSRT_AMT,IGSRT_AMT,CessRT_amt from #GSTR2TBL 
	WHERE mEntry in('BP','CP') and (CGSRT_AMT + SGSRT_AMT+IGSRT_AMT) > 0
	union all 
	SELECT PKEY = '-',TaxRate,POS,Taxable,CGST_AMT,SGST_AMT,IGST_AMT,COMPCESS FROM #TaxAlloc_tmp )AA
	
  ---10A (1). Intra-State supplies (Rate Wise)
   Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt,av_CGST_AMT,AV_SGST_AMT,AV_IGST_AMT,AV_cess_amt ,Amenddate)
   SELECT * FROM(select 10 AS PART ,'10AA' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no
   , '' as date ,pos,0.00 AS net_amt,rate1
	,taxableamt = sum(CASE WHEN PKEY = '+' THEN +Taxableamt ELSE -Taxableamt END)
	,CGSRT_AMT = sum(CASE WHEN PKEY = '+' THEN +CGSRT_AMT ELSE -CGSRT_AMT END)
	,SGSRT_AMT = sum(CASE WHEN PKEY = '+' THEN +SGSRT_AMT ELSE -SGSRT_AMT END)
	,IGST_AMT = 0
	,cess_amt = sum(CASE WHEN PKEY = '+' THEN +CessRT_amt ELSE -CessRT_amt END)
	,'' as Amenddate  from #Tax_tmp where (CGSRT_AMT + SGSRT_AMT) > 0
	group by rate1,pos )AA  WHERE (CGSRT_AMT + SGSRT_AMT) > 0 ORDER BY rate1,pos
		
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10AA' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(10,'10AA','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	----10A (2). Inter-State Supplies (Rate Wise)

		Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,AV_CGST_AMT,AV_SGST_AMT,AV_IGST_AMT,AV_cess_amt,Amenddate)
		 SELECT * FROM (select 10 AS PART ,'10AB' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no
		 , '' as date ,pos,0.00 AS net_amt ,rate1
		 ,taxableamt = sum(CASE WHEN PKEY = '+' THEN +taxableamt ELSE -taxableamt END)
		 ,CGST_AMT = 0
		 ,SGST_AMT = 0
		 ,IGSRT_AMT = sum(CASE WHEN PKEY = '+' THEN +IGSRT_AMT ELSE -IGSRT_AMT END)
		 ,cess_amt = sum(CASE WHEN PKEY = '+' THEN +CessRT_amt ELSE -CessRT_amt END)
		,'' as Amenddate
		from #Tax_tmp where (IGSRT_AMT) > 0
		group by rate1,pos)SS WHERE   (IGSRT_AMT) > 0 order by Rate1,pos
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10AB' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(10,'10AB','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	
	---10B. Advance amount on which tax was paid in earlier period but invoice has been received in the current period [ reflected in Table 4 above]
	   SELECT A.*,b.pos,b.pos_std_cd ,b.date into #TaxTemp2 FROM TaxAllocation A inner join  #BANK_TMP b ON (A.Entry_ty =B.Entry_ty AND A.Tran_cd =b.Tran_cd)  where (a.REntry_ty+QUOTENAME(a.Itref_tran) not IN(select (Entry_ty + quotename(Tran_cd))  from #BANK_TMP where Entry_ty in('cp','bp') and DATE between @SDATE and @EDATE)) and (b.date between @sdate and @edate) and a.REntry_ty  in('BP','CP')
	---10B (1). Intra-State Supplies (Rate Wise)
		Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt,AV_CGST_AMT,AV_SGST_AMT,AV_IGST_AMT,AV_cess_amt,Amenddate)
		 select 10 AS PART ,'10BA' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no, '' as date ,POS,0.00 AS net_amt
		,TAXRATE 
		,taxableamt = sum(Taxable),CGST_AMT = sum(CGST_AMT),SGST_AMT = sum(SGST_AMT),IGST_AMT = sum(IGST_AMT),cess_amt = sum(COMPCESS)
		,'' as Amenddate 
		from #TaxTemp2 where (CGST_AMT  + SGST_AMT) > 0 
		group by TaxRate,POS 
		order by TaxRate,POS
	
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10BA' AND SRNO ='A')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(10,'10BA','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	-----10B (2). Intre-State Supplies (Rate Wise)
		Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt,AV_CGST_AMT,AV_SGST_AMT,AV_IGST_AMT,AV_cess_amt,Amenddate)  
		 select 10 AS PART ,'10BB' AS PARTSR,'B' AS SRNO,'' as gstin, '' as inv_no, '' as date,pos,0.00 AS net_amt 
		,taxrate 
		,taxableamt = sum(Taxable),CGST_AMT = sum(CGST_AMT),SGST_AMT = sum(SGST_AMT),IGST_AMT = sum(IGST_AMT),cess_amt = sum(COMPCESS)
		,'' as Amenddate 
		from #TaxTemp2 where (iGST_AMT) > 0 
		group by TaxRate,POS 
		order by TaxRate,POS
		
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10BB' AND SRNO ='B')
	BEGIN
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
		values(10,'10BB','B','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
	END
	
	----II Amendments of information furnished in Table No. 10 (I) in an earlier month [Furnish revised information]
	SELECT *  INTO #TEMP2 FROM (SELECT TRAN_CD,ENTRY_TY, gststate as  POS, GSTSCODE as pos_std_cd,DATE,AmendDate FROM PTMAIN 
	UNION ALL SELECT TRAN_CD,ENTRY_TY,gststate,GSTSCODE ,DATE,AmendDate FROM EPMAIN )AA
	SELECT DISTINCT TRAN_CD,ENTRY_TY,POS,pos_std_cd,DATE,AmendDate INTO #BANK_AMD_TMP FROM #GSTR2AMD 
	WHERE mEntry in('PT','EP','CP','BP')
	SELECT * INTO #TaxAlloc_tmp1 FROM (select a.*,B.DATE AS B,b.AmendDate,C.date,C.POS,C.pos_std_cd from TaxAllocation a inner join #BANK_AMD_TMP b on (a.Itref_tran =b.Tran_cd and a.rEntry_ty = b.Entry_ty)
	INNER JOIN #TEMP2 C  on (C.Entry_ty =A.entry_ty AND C.Tran_cd =A.Tran_cd and (quotename(month(c.date))+QUOTENAME(YEAR(c.date)))= (quotename(month(B.date))+QUOTENAME(YEAR(B.date)))))AA

	SELECT * INTO #Tax_AMD_tmp FROM (select PKEY = '+', rate1,pos ,Taxableamt,CGSRT_AMT,SGSRT_AMT,IGSRT_AMT,CessRT_amt,DATE,AmendDate  from #GSTR2AMD 
	WHERE mEntry in('BP','CP')
	and (CGSRT_AMT + SGSRT_AMT+IGSRT_AMT) > 0
	union all 
	SELECT PKEY = '-',TaxRate,POS,Taxable,CGST_AMT,SGST_AMT,IGST_AMT,COMPCESS,DATE,AmendDate FROM #TaxAlloc_tmp1 )AA

	---Section 10A (1). Intra-State supplies (Rate Wise)
  			Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
			,av_CGST_AMT,AV_SGST_AMT,AV_IGST_AMT,AV_cess_amt,Inputtype,Amenddate,descr)
			 select 10 AS PART ,'10CA' AS PARTSR,'' AS SRNO,'' as gstin, '' as inv_no
			 , '' as date 
			 ,pos,0.00 AS net_amt 
			,rate1
			,taxableamt = sum(CASE WHEN PKEY = '+' THEN +Taxableamt ELSE -Taxableamt END )
			,CGSRT_AMT = sum(CASE WHEN PKEY = '+' THEN +CGSRT_AMT ELSE -CGSRT_AMT END)
			,SGST_AMT = sum(CASE WHEN PKEY = '+' THEN +SGSRT_AMT ELSE -SGSRT_AMT END)
			,IGST_AMT = 0
			,cess_amt = sum(CASE WHEN PKEY = '+' THEN +CessRT_amt ELSE -CessRT_amt END)
			,'AA' as Inputtype,'' as Amenddate
			,datename(mm,isnull(date,''))as AmdMth
			from #Tax_AMD_tmp where (SGSRT_AMT + CGSRT_AMT) > 0
			group by rate1,pos,datename(mm,isnull(date,''))
			order by datename(mm,isnull(date,''))

	----Section 10A (2). Inter-State Supplies (Rate Wise)
	
		Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,AV_CGST_AMT,AV_SGST_AMT,AV_IGST_AMT,AV_cess_amt,Inputtype,Amenddate,descr)	
		 select 10 AS PART ,'10CA' AS PARTSR,'' AS SRNO,'' as gstin, '' as inv_no
		, '' as date,pos,0.00 AS net_amt,rate1
		,taxableamt = sum(CASE WHEN PKEY = '+' THEN +Taxableamt ELSE -Taxableamt END)
		,CGST_AMT = 0
		,SGST_AMT = 0
		,IGST_AMT = sum(CASE WHEN PKEY = '+' THEN +IGSRT_AMT ELSE -IGSRT_AMT END)
		,cess_amt = sum(CASE WHEN PKEY = '+' THEN +CessRT_amt ELSE -cessrt_amt END)
		,'AB' as Inputtype
		,'' as Amenddate  
		,datename(mm,isnull(date,''))as AmdMth
		from #Tax_AMD_tmp where (IGSRT_AMT ) > 0 
		group by rate1,pos ,datename(mm,isnull(date,''))
		order by datename(mm,isnull(date,''))
		
	---10B. Advance amount on which tax was paid in earlier period but invoice has been received in the current period [ reflected in Table 4 above]
	
	---Section 10B (1). Intra-State Supplies (Rate Wise)
	
	-----Section 10B (2). Intra-State Supplies (Rate Wise)
		
	IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PARTSR = '10CA' AND SRNO ='')
	BEGIN
		Insert Into #GSTR2(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,AV_CGST_AMT,AV_SGST_AMT,AV_IGST_AMT,AV_cess_amt,Inputtype,Amenddate,descr)
				VALUES(10,'10CA','','','','','',0,0,0,0,0,0,0,'','','')
	END

	-----11. Input Tax Credit Reversal / Reclaim 
		 SELECT * into #jvmain FROM (select tran_cd,ENTRY_TY,AGAINSTTY,RRGST,RevsType,DATE,Amenddate,CGST_AMT,SGST_AMT,IGST_AMT,COMPCESS from JVMAIN  WHERE entry_ty = 'J7'
		 UNION ALL 
		 select tran_cd,ENTRY_TY,AGAINSTTY,RRGST,RevsType,DATE,'' as Amenddate,CGST_AMT,sGST_AMT,IGST_AMT,COMPCESS from JVMAINAM  WHERE entry_ty = 'J7' )ad
		---(a) Amount in terms of rule 37(2)
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00
		
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 37(2)'  and isnull(amenddate,'')='' 
		and AGAINSTTY = 'Addition'
		and RRGST = 'Input Tax'
		
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','A','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','To be added',0,0,0,0,'(a) Amount in terms of rule 37(2)')
		---(b) Amount in terms of rule 39(1)(j)(ii)
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 39(1)(j)(ii)'  and isnull(amenddate,'')='' 
		and AGAINSTTY = 'Addition'  
		and RRGST = 'Input Tax'  
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','B','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','To be added',0,0,0,0,'(b) Amount in terms of rule 39(1)(j)(ii)') 
		---(c) Amount in terms of rule 42 (1) (m)
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 42 (1) (m)'  and isnull(amenddate,'')='' 
		and AGAINSTTY = 'Addition'  
		and RRGST = 'Input Tax'  
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','C','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','To be added',0,0,0,0,'(c) Amount in terms of rule 42 (1) (m)') 
		---(d) Amount in terms of rule 43(1) (h) 
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 43(1) (h) '  and isnull(amenddate,'')='' 
		and AGAINSTTY = 'Addition'
		and RRGST = 'Input Tax'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','D','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','To be added',0,0,0,0,'(d) Amount in terms of rule 43(1) (h) ') 
		---(e) Amount in terms of rule 42 (2)(a)
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 42 (2)(a)'  and isnull(amenddate,'')='' 
		and AGAINSTTY = 'Addition'
		and RRGST = 'Input Tax'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','E','','','','',0,0,0,@amt1 ,@amt2,@amt3,@amt4,0,'','','To be added',0,0,0,0,'(e) Amount in terms of rule 42 (2)(a)') 
		---(f) Amount in terms of rule 42(2)(b)
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Amount in terms of rule 42(2)(b)'  and isnull(amenddate,'')='' 
		and AGAINSTTY = 'Reduction'  
		and RRGST = 'Input Tax'
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','F','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','To be reduced',0,0,0,0,'(f) Amount in terms of rule 42(2)(b)')
		---(g) On account of amount paid subsequent to reversal of ITC 
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'On account of amount paid subsequent to reversal of ITC'  and isnull(amenddate,'')='' 
		and AGAINSTTY = 'Reduction'
		and RRGST = 'Input Tax'

		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','G','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','To be reduced',0,0,0,0,'(g) On account of amount paid subsequent to reversal of ITC') 
		----(h) Any other liability (Specify)
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00
		set @AgainstType = ''
		select @AgainstType = isnull(AGAINSTTY,''), @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain 
		where entry_ty = 'j7' and ( date between @SDATE and @EDATE ) and RevsType = 'Any other liability (Specify)' and isnull(amenddate,'') = '' 
		and RRGST = 'Input Tax'  
		group by  AGAINSTTY

		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(11,'11A','H','','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','',case when @AgainstType = 'Reduction' then 'To be reduced' else 'To be added' end ,0,0,0,0,'(h) Any other liability (Specify)')

		----B. Amendment of information furnished in Table No 11 at S. No A in an earlier return
		declare @RevsType varchar(500),@date smalldatetime,@cgst_amt numeric(12,2),@sgst_amt numeric(12,2),@igst_amt numeric(12,2),@compcess numeric(12,2)
		declare @srno int,@alfanum varchar(10),@againstty varchar(50)
		IF EXISTS(Select * From #jvmain Where entry_ty = 'j7'
				and RevsType in ('Amount in terms of rule 37(2)','Amount in terms of rule 39(1)(j)(ii)','Amount in terms of rule 42 (1) (m)'
								,'Amount in terms of rule 43(1) (h) '
								,'Amount in terms of rule 42 (2)(a)'
								,'Amount in terms of rule 42(2)(b)'
								,'On account of amount paid subsequent to reversal of ITC'
								,'Any other liability (Specify)') 
				and AGAINSTTY IN ('Addition','Reduction') and (amenddate between @SDATE and @EDATE)
				and (DATEDIFF(MM,DATE,AmendDAte) > 0)
				and RRGST = 'Input Tax')
		BEGIN
			declare curAmend cursor for 
			Select RevsType,Amenddate,date,cgst_amt,sgst_amt,igst_amt,compcess,againstty From #jvmain  Where entry_ty = 'j7' 
			and RevsType in ('Amount in terms of rule 37(2)','Amount in terms of rule 39(1)(j)(ii)','Amount in terms of rule 42 (1) (m)'
											,'Amount in terms of rule 43(1) (h)'
											,'Amount in terms of rule 42 (2)(a)'
											,'Amount in terms of rule 42(2)(b)'
											,'On account of amount paid subsequent to reversal of ITC'
											,'Any other liability (Specify)') 
			and AGAINSTTY IN ('Addition','Reduction')
			and (amenddate between @SDATE and @EDATE)
			and (DATEDIFF(MM,DATE,AmendDAte) > 0)
			and RRGST = 'Input Tax'
			order by date
			declare @srno1 varchar(4)
			OPEN curAmend
			FETCH NEXT FROM curAmend INTO @RevsType,@Amenddate,@date,@cgst_amt,@sgst_amt,@igst_amt,@compcess,@againstty
			WHILE @@FETCH_STATUS=0
			BEGIN
			set @againstType = ''
			 set @againstType = case 
			    when @RevsType = 'Amount in terms of rule 37(2)' then '(a) '
			    when @RevsType = 'Amount in terms of rule 39(1)(j)(ii)' then '(b) '
			    when @RevsType = 'Amount in terms of rule 42 (1) (m)' then '(c) '
			    when @RevsType = 'Amount in terms of rule 43(1) (h)' then '(d) '
			    when @RevsType = 'Amount in terms of rule 42 (2)(a)' then '(e) '
			    when @RevsType = 'Amount in terms of rule 42(2)(b)' then '(f) '
			    when @RevsType = 'On account of amount paid subsequent to reversal of ITC' then '(g) '
			    when @RevsType = 'Any other liability (Specify)' then '(h) '
			    else '' end 
			set @srno1 = ''	
			set @srno1 = substring(rtrim(ltrim(replace(replace(@againstType,'(',''),')',''))),0,4)
			Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
						CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Amenddate,IT_NAME)
			select 11,'11B',@srno1,'','','','',0,0,0,@cgst_amt,@sgst_amt,@igst_amt,@compcess,0,'',''
			
			,(case when @againstty='Addition' then 'To be added' else 'To be reduced' end)
			,@RevsType,'',datename(mm,ISNULL(@date,''))
			
			FETCH NEXT FROM curAmend INTO @RevsType,@Amenddate,@date,@cgst_amt,@sgst_amt,@igst_amt,@compcess,@againstty
			END
			close curAmend
			deallocate curAmend
		END
		ELSE
		BEGIN
			Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
			CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr,amenddate)		
			values(11,'11B','','','','','',0,0,0,0,0,0,0,0,'','','',0,0,0,0,'','')
		END
		---12. Addition and reduction of amount in output tax for mismatch and other reasons			
		---ITC claimed on mismatched/duplication of invoices/debit notes
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00 
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain 
		where entry_ty = 'j7' and (date between @SDATE and @EDATE ) and RevsType = 'ITC claimed on mismatched/duplication of invoices/debit notes' 
		and AGAINSTTY = 'Addition' and RRGST = 'Output Tax' and isnull(amenddate,'') = '' 
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','A','(a)','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','Add',0,0,0,0,' ITC claimed on mismatched/duplication of invoices/debit notes')  --Modified by Priyanka B on 21082017
		
		 --- Tax liability on mismatched credit notes
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00  
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain 
		where entry_ty = 'j7' and (date between @SDATE and @EDATE ) and RevsType = 'Tax liability on mismatched credit notes' 
		and AGAINSTTY = 'Addition' and RRGST = 'Output Tax' and isnull(amenddate,'') = '' 
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','B','(b)','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','Add',0,0,0,0,'Tax liability on mismatched credit notes')  
		----Reclaim on account of rectification of mismatched invoices/debit notes
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain
		where entry_ty = 'j7' and (date between @SDATE and @EDATE ) and RevsType = 'Reclaim on account of rectification of mismatched invoices/debit notes' 
		and AGAINSTTY = 'Reduction' and RRGST = 'Output Tax' and isnull(amenddate,'') = '' 
		
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','C','(c)','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','Reduce',0,0,0,0,'Reclaim on account of rectification of mismatched invoices/debit notes')
		
		---) Reclaim on account of rectification of mismatched credit note
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00
		
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain
		where entry_ty = 'j7' and (date between @SDATE and @EDATE ) and RevsType = 'Reclaim on account of rectification of mismatched credit note' 
		and AGAINSTTY = 'Reduction' and RRGST = 'Output Tax' and isnull(amenddate,'') = '' 

		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','D','(d)','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','Reduce',0,0,0,0,'Reclaim on account of rectification of mismatched credit note')
		
		----) Negative tax liability from previous tax periods
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain
		where entry_ty = 'j7' and (date between @SDATE and @EDATE ) and RevsType = 'Negative tax liability from previous tax periods' 
		and AGAINSTTY = 'Reduction' and RRGST = 'Output Tax' and isnull(amenddate,'') = '' 
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','E','(e)','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','Reduce',0,0,0,0,'Negative tax liability from previous tax periods')
		----Tax paid on advance in earlier tax periods and adjusted with tax on supplies made in current tax period
		set @amt1 = 0.00 
		set @amt2 = 0.00 
		set @amt3 = 0.00  
		set @amt4 = 0.00
		select @amt1= isnull(sum(CGST_AMT),0),@amt2 =isnull(sum(SGST_AMT),0),@amt3=isnull(sum(IGST_AMT),0),@amt4 =isnull(sum(COMPCESS),0) from #jvmain
		where entry_ty = 'j7' and (date between @SDATE and @EDATE ) and RevsType = 'Tax paid on advance in earlier tax periods and adjusted with tax on supplies made in current tax period' 
		and AGAINSTTY = 'Reduction' and RRGST = 'Output Tax' and isnull(amenddate,'') = '' 
		Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
		CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT,descr)
		values(12,'12','F','(f)','','','',0,0,0,@amt1,@amt2,@amt3,@amt4,0,'','','Reduce',0,0,0,0,'Tax paid on advance in earlier tax periods and adjusted with tax on supplies made in current tax period') 
		
		----13. HSN summary of inward supplies
		select A.*,isnull(B.SERVTCODE,'') as SERVTCODE,B.SERTY INTO #GSTR2TBL_HSN  from #GSTR2TBL A INNER JOIN IT_MAST B  ON (A.IT_CODE=B.IT_CODE)
		where (A.SUPP_TYPE <> 'unregistered' 
		--AND A.mEntry In('PT','PR','GC','GD','EP')) OR A.Entry_ty = 'UB'  --Commented by Priyanka B on 23072019 for Bug-32704
		AND A.mEntry In('PT','PR','CN','DN','EP')) OR A.Entry_ty = 'UB'  --Modified by Priyanka B on 23072019 for Bug-32704
        UPDATE #GSTR2TBL_HSN SET SERVTCODE=ISNULL((select top 1 code from sertax_mast  where serty = #GSTR2TBL_HSN.Serty),'')  where isnull(#GSTR2TBL_HSN.SERVTCODE,'') = '' AND Isservice = 'services'
        ---------------------
		Insert into #GSTR2(PART,PARTSR,SRNO,QTY,Taxableamt,GRO_AMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,HSNCODE,uqc)
		SELECT * FROM (SELECT 13 AS PART ,'13' AS PARTSR ,'A'AS SRNO
		--Commented by Priyanka B on 23072019 for Bug-32704 Start
		/*,SUM(CASE WHEN (mENTRY IN('PT','GC','EP') or Entry_ty='UB') THEN +QTY ELSE -QTY END) AS QTY
		,SUM(CASE WHEN (mENTRY IN('PT','GC','EP') or Entry_ty='UB') THEN +Taxableamt ELSE -Taxableamt END)Taxableamt
		,SUM(CASE WHEN (mENTRY IN('PT','GC','EP') or Entry_ty='UB') THEN +GRO_AMT ELSE -GRO_AMT END)GRO_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','GC','EP') or Entry_ty='UB') THEN +(ISNULL(CGST_AMT,0)+ISNULL(CGSRT_AMT,0)) ELSE -(ISNULL(CGST_AMT,0)+ISNULL(CGSRT_AMT,0)) END)CGST_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','GC','EP') or Entry_ty='UB') THEN +(ISNULL(SGST_AMT,0)+ISNULL(SGSRT_AMT,0)) ELSE -(ISNULL(SGST_AMT,0)+ISNULL(SGSRT_AMT,0)) END)SGST_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','GC','EP') or Entry_ty='UB') THEN +(ISNULL(IGST_AMT,0)+ISNULL(IGSRT_AMT,0)) ELSE -(ISNULL(IGST_AMT,0)+ISNULL(IGSRT_AMT,0)) END)IGST_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','GC','EP') or Entry_ty='UB') THEN +(ISNULL(CESS_AMT,0)+ISNULL(CessRT_amt,0)) ELSE -(ISNULL(CESS_AMT,0)+ISNULL(CessRT_amt,0)) END)CESS_AMT,
		*/--Commented by Priyanka B on 23072019 for Bug-32704 End

		--Modified by Priyanka B on 23072019 for Bug-32704 Start
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +QTY ELSE -QTY END) AS QTY
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +Taxableamt ELSE -Taxableamt END)Taxableamt
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +GRO_AMT ELSE -GRO_AMT END)GRO_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +(ISNULL(CGST_AMT,0)+ISNULL(CGSRT_AMT,0)) ELSE -(ISNULL(CGST_AMT,0)+ISNULL(CGSRT_AMT,0)) END)CGST_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +(ISNULL(SGST_AMT,0)+ISNULL(SGSRT_AMT,0)) ELSE -(ISNULL(SGST_AMT,0)+ISNULL(SGSRT_AMT,0)) END)SGST_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +(ISNULL(IGST_AMT,0)+ISNULL(IGSRT_AMT,0)) ELSE -(ISNULL(IGST_AMT,0)+ISNULL(IGSRT_AMT,0)) END)IGST_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +(ISNULL(CESS_AMT,0)+ISNULL(CessRT_amt,0)) ELSE -(ISNULL(CESS_AMT,0)+ISNULL(CessRT_amt,0)) END)CESS_AMT,
		--Modified by Priyanka B on 23072019 for Bug-32704 End
		HSNCODE=(case when Isservice = 'services' then SERVTCODE else HSNCODE end ) ,uqc 
		FROM #GSTR2TBL_HSN
		--WHERE (mEntry IN('PT','PR','GC','GD','EP') or Entry_ty='UB')  --Commented by Priyanka B on 23072019 for Bug-32704
		WHERE (mEntry IN('PT','PR','CN','DN','EP') or Entry_ty='UB')  --Modified by Priyanka B on 23072019 for Bug-32704
		and ltrim(rtrim((case when Isservice = 'services' then SERVTCODE else HSNCODE end ))) <>'' 
		group by HSNCODE,SERVTCODE,Isservice,uqc )AA order by HSNCODE,uqc
		
		IF NOT EXISTS(SELECT PART FROM #GSTR2 WHERE PART = 13 AND PARTSR = '13' AND SRNO = 'A')
		BEGIN
			Insert into #GSTR2(PART,PARTSR,SRNO,INV_NO,DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,
			CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,GRO_AMT,gstin, location,Inputtype,descr,Av_CGST_AMT,Av_sGST_AMT,Av_iGST_AMT,av_CESS_AMT)
			values(13,'13','A','','','','',0,0,0,0,0,0,0,0,'','','','',0,0,0,0)
		END
	update #gstr2 set rptmonth =datename(mm,@SDATE),rptyear =year(@SDATE),GSTIN =(CASE WHEN ISNULL(gstin,'')='UNREGISTERED' THEN '' ELSE isnull(gstin,'') END ),ORG_GSTIN =(CASE WHEN ISNULL(ORG_GSTIN,'')='UNREGISTERED' THEN '' ELSE isnull(ORG_GSTIN,'') END )

IF ISNULL(@EXPARA,'') = ''
	BEGIN
		Select PART,PARTSR,SRNO,INV_NO, DATE,ORG_INVNO,ORG_DATE,QTY,RATE,Taxableamt,CGST_AMT, SGST_AMT, IGST_AMT, CESS_AMT,GRO_AMT
		,Net_Amt,IT_NAME,IT_DESC,HSNCODE, gstin, location,Inputtype,descr,uqc,org_gstin,Av_CGST_AMT, Av_sGST_AMT, Av_iGST_AMT, av_CESS_AMT
		,rptmonth,rptyear ,Amenddate From #GSTR2
		order by PART,PARTSR,SRNO 

	END
ELSE 
	BEGIN
	---Section 3.
	
	Select * into #Temp11b  From #GSTR2  where part = 11 and PARTSR = '11B'  order by MONTH(case when isnull(it_name,'')='' then 'January ' else it_name end + '01 1900'),SRNO 
	SELECT 3 AS SECTION  ,'GSTIN of supplier' + '|' + 'Invoice No' + '|' + 'Invoice Date' + '|' + 'Invoice value' 
	 + '|' + 'Rate' + '|'  + 'Taxable Value' + '|' 
	+ 'Integrated Tax' + '|' + 'Central Tax' + '|' + 'State/UT Tax' + '|' + 'Cess' + '|'
	 + 'Place of supply(Name of State/UT)' + '|'
	+ 'Whether input or input service/Capital goods(incl plant and machinery) Ineligible for ITC' + '|'
	+ 'Amount of ITC available Integrated Tax' + '|' 
	+ 'Amount of ITC available Central Tax' + '|' + 'Amount of ITC available State/UT Tax' + '|'  
	+ 'Amount of ITC available Cess'   as ColumnDetails
	union all 
	Select 3 as Section ,RTRIM(LTRIM(isnull(GSTIN,''))) + '|' + RTRIM(LTRIM(isnull(inv_no,''))) + '|'  + 
	----CONVERT(VARCHAR,DATE,103) + '|'  
	CASE WHEN YEAR(ISNULL(DATE,''))<=1900 THEN '' ELSE  CONVERT(VARCHAR,isnull(DATE,''),103) END  + '|'  
	+ CAST(isnull(Net_amt,0) AS VARCHAR) + '|'  + CAST(isnull(RATE,0) AS VARCHAR) + '|'
	+ CAST(isnull(taxableamt,0) AS VARCHAR) + '|'  + CAST(isnull(IGST_amt,0) AS VARCHAR) + '|'  
	+ CAST(isnull(CGST_amt,0) AS VARCHAR) + '|'  + CAST(isnull(SGST_amt,0) AS VARCHAR) + '|'  
	+ CAST(isnull(cess_amt,0) AS VARCHAR) + '|'  + RTRIM(LTRIM(isnull(Location,''))) + '|' 
	+ RTRIM(LTRIM(isnull(Inputtype,''))) + '|'  + 	CAST(isnull(Av_CGST_AMT,0) AS VARCHAR) + '|'  
	+ CAST(isnull(Av_sGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(Av_iGST_AMT,0) AS VARCHAR) + '|'  
	+ CAST(isnull(av_CESS_AMT,0) AS VARCHAR)  From #GSTR2  where part = 3
	---Section 4.
	union all 
	SELECT  4 AS SECTION  ,'Section' + '|' + 'GSTIN of supplier' + '|' + 'Invoice No' + '|' 
	+ 'Invoice Date' + '|' + 'Invoice value'  + '|' + 'Rate' + '|'  + 'Taxable Value' + '|' 
	+ 'Integrated Tax' + '|' + 'Central Tax' + '|' + 'State /UT Tax' + '|' + 'Cess' + '|' 
	+ 'Place of supply(Name of State/UT)' + '|'
	+ 'Whether input or input service/Capital goods(incl plant and machinery) Ineligible for ITC' + '|'
	+ 'Amount of ITC available Integrated Tax' + '|' + 'Amount of ITC available Central Tax' + '|' 
	+ 'Amount of ITC available State/UT Tax' + '|' + 'Amount of ITC available Cess'   as ColumnDetails
	union all 
	Select 4 as Section , RTRIM(LTRIM(ISNULL(PARTSR,'')))  + '|'  + RTRIM(LTRIM(isnull(GSTIN,''))) + '|'
	+ RTRIM(LTRIM(isnull(inv_no,''))) + '|'  + 
	CASE WHEN YEAR(ISNULL(DATE,''))<=1900 THEN '' ELSE CONVERT(VARCHAR,ISNULL(DATE,''),103) END  + '|' 
	+ CAST(isnull(Net_amt,0) AS VARCHAR) + '|'  + CAST(isnull(RATE,0) AS VARCHAR) + '|'
	+ CAST(isnull(taxableamt,0) AS VARCHAR) + '|'  + CAST(isnull(IGST_amt,0) AS VARCHAR) + '|'  
	+ CAST(isnull(CGST_amt,0) AS VARCHAR) + '|'  + CAST(isnull(SGST_amt,0) AS VARCHAR) + '|'  
	+ CAST(isnull(cess_amt,0) AS VARCHAR) + '|'  + RTRIM(LTRIM(isnull(Location,''))) + '|'
	+ RTRIM(LTRIM(isnull(Inputtype,''))) + '|'  + 	CAST(isnull(Av_CGST_AMT,0) AS VARCHAR) + '|'  
	+ CAST(isnull(Av_sGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(Av_iGST_AMT,0) AS VARCHAR) + '|'  
	+ CAST(isnull(av_CESS_AMT,0) AS VARCHAR)  From #GSTR2  where part = 4
	---Section 5.
	union all 
	SELECT 5 AS SECTION  ,'Section' + '|' + 'GSTIN of supplier' + '|' + 'Bill of Entry No' + '|'
	+ 'Bill of Entry Date' + '|' 
	+ 'Bill of Entry value'  + '|' + 'Rate' + '|'  + 'Taxable Value' + '|' 
	+ 'Integrated Tax' + '|' + 'Cess' + '|' 
	+ 'Whether input/Capital goods(incl. plant and machinery) Ineligible for ITC' + '|'
	+ 'Amount of ITC available Integrated Tax' + '|' + 'Amount of ITC available Cess'   as ColumnDetails
	union all 
	Select 5 as Section , RTRIM(LTRIM(ISNULL(PARTSR,'')))  + '|'  + RTRIM(LTRIM(isnull(GSTIN,''))) + '|' + RTRIM(LTRIM(isnull(inv_no,''))) + '|'  
	+ case when year(isnull(date,''))<=1900 then '' else  CONVERT(VARCHAR,isnull(DATE,''),103) end   + '|'
	+ CAST(isnull(Net_amt,0) AS VARCHAR) + '|'  + CAST(isnull(RATE,0) AS VARCHAR) + '|'  
	+ CAST(isnull(taxableamt,0) AS VARCHAR) + '|'  + CAST(isnull(IGST_amt,0) AS VARCHAR) + '|'  
	+ CAST(isnull(cess_amt,0) AS VARCHAR) + '|' 
	+ RTRIM(LTRIM(isnull(Inputtype,''))) + '|'  + 	CAST(isnull(Av_iGST_AMT,0) AS VARCHAR) + '|'  
	+ CAST(isnull(av_CESS_AMT,0) AS VARCHAR)  From #GSTR2  where part = 5 AND PARTSR IN('5A','5B')and srno = 'A' 
	---Section 5 B.
	union all 
	SELECT 5.2 AS SECTION  , 'Port code+No of BE' + '|' + 'Assessable Value' + '|'
	+ 'Amount of ITC available Integrated Tax' + '|' 
	+ 'Amount of ITC available CESS'  as ColumnDetails
	union all 
	Select 5.2 as Section ,RTRIM(LTRIM(isnull(DESCR,'')))+ '|' +
	CAST(isnull(TaxableAmt,0) AS VARCHAR)+ '|' +
	CAST(isnull(Av_iGST_AMT,0) AS VARCHAR)+ '|' +
	CAST(isnull(av_CESS_AMT,0) AS VARCHAR)
	  From #GSTR2  where part = 5 AND PARTSR = '5B'and srno = 'B' 
	
	---Section 6.
	union all 
	SELECT 6 AS SECTION  ,'Section' + '|' + 'Original Invoice/Bill of entry GSTIN' + '|' 
	+ 'Original Invoice/Bill of entry No' + '|' 
	+ 'Original Invoice/Bill of entry Date' + '|' 
	+ 'Revised Invoice GSTIN'  + '|' + 'Revised Invoice No'  + '|'  
	+ 'Revised Invoice Date'  + '|'  + 'Revised Invoice Value'	+ '|' 
	+ 'Rate' + '|'  + 'Taxable Value' + '|'  + 'Integrated Tax' + '|' + 'Central Tax' + '|'
	+ 'State/UT Tax' + '|' + 'Cess' + '|' + 'Place of Supply' + '|' 
	+ 'Whether input or input service/Capital goods Ineligible for ITC' + '|' 	
	+ 'Amount of ITC available Integrated Tax' + '|' + 'Amount of ITC available Central Tax' + '|' 
	+ 'Amount of ITC available State/UT Tax' + '|' + 'Amount of ITC available Cess'   as ColumnDetails
	union all 
	Select 6 as Section , RTRIM(LTRIM(ISNULL(PARTSR,'')))  + '|'  + RTRIM(LTRIM(isnull(org_gstin,''))) + '|' + RTRIM(LTRIM(isnull(ORG_INVNO,''))) + '|'  
	+ case when year(isnull(ORG_DATE,'')) <=1900 THEN '' ELSE CONVERT(VARCHAR,ISNULL(ORG_DATE,''),103)  END  + '|'
	+ RTRIM(LTRIM(isnull(gstin,''))) + '|' + RTRIM(LTRIM(isnull(inv_no,''))) + '|'  
	+ CASE WHEN YEAR(ISNULL(DATE,''))<=1900 THEN '' ELSE CONVERT(VARCHAR,ISNULL(DATE,''),103) END + '|'
	+ CAST(isnull(Net_amt,0) AS VARCHAR) + '|'  + CAST(isnull(RATE,0) AS VARCHAR) + '|'
	+ CAST(isnull(taxableamt,0) AS VARCHAR) + '|'  + CAST(isnull(IGST_amt,0) AS VARCHAR) + '|'  
	+ CAST(isnull(CGST_amt,0) AS VARCHAR) + '|'  + CAST(isnull(SGST_amt,0) AS VARCHAR) + '|'  
	+ CAST(isnull(cess_amt,0) AS VARCHAR) + '|'  + RTRIM(LTRIM(isnull(Location,''))) + '|'  
	+ RTRIM(LTRIM(isnull(Inputtype,''))) + '|' + CAST(isnull(Av_iGST_AMT,0) AS VARCHAR) + '|'  
	+ CAST(isnull(Av_CGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(Av_sGST_AMT,0) AS VARCHAR) + '|' 
	+ CAST(isnull(av_CESS_AMT,0) AS VARCHAR)  From #GSTR2  where part = 6
	---Section 7.
	union all 
	SELECT 7 AS SECTION  ,'Description' + '|' + 'Value of composition Taxable Person' + '|'  
	+ 'Value of Exempt supply' + '|' + 'Value of Nil Rated supply' + '|' + 'Non GST Supply'   as ColumnDetails
	union all 
	Select 7 as Section , RTRIM(LTRIM(isnull(descr,''))) + '|' + CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(cess_amt,0) AS VARCHAR)  From #GSTR2  where part = 7
	---Section 8.
	union all 
	SELECT 8 AS SECTION  ,'Section' + '|' + 'GSTIN of ISD' + '|' + 'ISD Document No.' + '|' 
	+ 'ISD Document Date' + '|'  + 'ISD Credit received Integrated Tax' + '|'  
	+ 'ISD Credit received Central Tax' + '|' + 'ISD Credit received State/UT Tax' + '|' 
	+ 'ISD Credit received Cess'  + '|' + 'Amount of eligible ITC Integated Tax' + '|' 
	+ 'Amount of eligible ITC Central Tax' + '|' + 'Amount of eligible ITC State/UT Tax' + '|' 
	+ 'Amount of eligible ITC Cess Tax'  as ColumnDetails
	union all 
	Select 8 as Section , RTRIM(LTRIM(ISNULL(PARTSR,'')))  + '|'  + RTRIM(LTRIM(isnull(gstin,''))) + '|' 
	+ RTRIM(LTRIM(isnull(inv_no,''))) + '|' 
	+ CASE WHEN YEAR(ISNULL(DATE,''))<=1900 THEN '' ELSE  CONVERT(VARCHAR,ISNULL(DATE,''),103)  END + '|'  
	+ CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  
	+ CAST(isnull(cess_amt,0) AS VARCHAR) + '|' + CAST(isnull(Av_iGST_AMT,0) AS VARCHAR) + '|' 
	+ CAST(isnull(Av_CGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(Av_sGST_AMT,0) AS VARCHAR) + '|' 
	+ CAST(isnull(av_CESS_AMT,0) AS VARCHAR)  From #GSTR2  where part = 8
	---Section 9.
	union all 
	SELECT 9 AS SECTION  ,'Section' + '|' + 'GSTIN of Deductor/GSTIN of e-Commerce Operator' + '|' 
	+ 'Gross Value' + '|'  + 'Sales Return' + '|' + 'Net Value' + '|' + 'Integrated Tax'  + '|' 
	+ 'Central Tax' + '|' + 'State Tax/UT Tax'  as ColumnDetails
	union all 
	Select 9 as Section , RTRIM(LTRIM(ISNULL(PARTSR,'')))  + '|'  + RTRIM(LTRIM(isnull(gstin,''))) + '|' + CAST(isnull(gro_amt,0) AS VARCHAR) + '|' + CAST(isnull(CESS_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(net_amt,0) AS VARCHAR) + '|'  + CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(SGST_AMT,0) AS VARCHAR)  From #GSTR2  where part = 9
	---Section 10.
	union all 
	SELECT 10 AS SECTION  ,'Section' + '|' + 'Rate' + '|' + 'Gross Advance Paid' + '|'
	+ 'Place of Supply(Name of State/UT)' + '|' + 'Integrated Tax'  + '|' + 'Central Tax' + '|'
	+ 'State Tax/UT Tax' + '|' + 'Cess' as ColumnDetails
	union all 
	Select 10 as Section , RTRIM(LTRIM(ISNULL(CASE WHEN PARTSR ='10AA' THEN '10A(1)' WHEN PARTSR = '10AB' THEN '10A(2)' WHEN PARTSR ='10BA' THEN '10B(1)' WHEN  PARTSR = '10BB' THEN '10B(2)' ELSE PARTSR  END ,'')))  + '|'  
	+ CAST(isnull(RATE,0) AS VARCHAR) + '|' + CAST(isnull(Taxableamt,0) AS VARCHAR) + '|'+ rtrim(ltrim(isnull(location,''))) + '|' + CAST(isnull(Av_iGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(Av_CGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(Av_SGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(Av_CESS_AMT,0) AS VARCHAR)   From #GSTR2  where part = 10 and PARTSR in('10AA','10AB','10BA','10BB')

---Section 10(II).
	--union all 
	--SELECT 10.1 AS SECTION  , ' Month ' + '|' + 'Amendment relating to information furnished is in S.No.(Select)' + '|'  + 
	--' 10A(1)' + '|' + ' 10A(2)'  + '|' + ' 10B(1)' + '|' + ' 10B(2)'  as ColumnDetails
	--union all 
	--Select 10.1 as Section ,+ SPACE(5) + '|' + SPACE(15)  + '|'+ ' 0.00 ' + '|' + ' 0.00 ' + '|'  + ' 0.00 ' + '|' + '0.00 '
		UNION ALL 
		Select 10.1 as Section,'Month' + '|' + 'Rate' + '|' + 'Gross Advance Received/adjusted' + '|' 
		+ 'Place of supply(Name of State)' + '|' + 'Integrated Tax' + '|' + 'Central Tax' + '|' + 'State/UT Tax' + '|' + 'Cess' +'|'+ '11A(1)' +'|'+ '11A(2)' +'|'+ '11B(1)' +'|'+ '11B(2)' as ColumnDetails
		UNION ALL 
	    SELECT 10.1 as Section 
	    ,rtrim(ltrim(isnull(descr,''))) + '|' 
	    +CAST(isnull(RATE,0) AS VARCHAR) + '|'  + CAST(isnull(Taxableamt,0) AS VARCHAR) + '|'  + isnull(RTRIM(Location),'')  + '|'   + CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|'  +CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(cess_AMT,0) AS VARCHAR) + '|'  + (case when Inputtype = 'AA' THEN 'Yes' else '' end) +'|'+
	    (case when Inputtype = 'AB' THEN 'Yes' else '' end) +'|'+
	    (case when Inputtype = 'BA' THEN 'Yes' else '' end) +'|'+ 
	    (case when Inputtype = 'BB' THEN 'Yes' else '' end)  
	    FROM  #GSTR2  WHERE PARTSR IN('10CA')

	
	---Section 11 A.
	union all 
	SELECT 11 AS SECTION  ,'Section' + '|' + 'Description for reversal of ITC' + '|' 
	+ 'To be added to orreduced fromoutput liability' + '|'  + 'Amount of ITC Integrated Tax'  
	+ '|' + 'Amount of ITC Central Tax' + '|' + 'Amount of ITC State Tax/UT Tax' + '|' 
	+ 'Amount of ITC Cess' as ColumnDetails
	union all 
	Select 11 as Section , RTRIM(LTRIM(ISNULL(PARTSR,''))) + '|'+ rtrim(ltrim(isnull(descr,''))) + '|' + rtrim(ltrim(isnull(Inputtype,''))) + '|' + CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(CESS_AMT,0) AS VARCHAR)   From #GSTR2  where part = 11  and PARTSR = '11A'
	
	---Section 11 B.
	union all 
	SELECT 11.2 AS SECTION  ,'Month' + '|' + 'Description for reversal of ITC' + '|'
	+ 'To be added to orreduced fromoutput liability' + '|'  + 'Amount of ITC Integrated Tax'
	+ '|' + 'Amount of ITC Central Tax' + '|' + 'Amount of ITC State Tax/UT Tax' + '|' 
	+ 'Amount of ITC Cess' as ColumnDetails
	union all 
	Select 11.2 as Section , RTRIM(LTRIM(ISNULL(it_name,''))) + '|'+ (case when isnull(srno,'')= ''  then '' else '('+rtrim(ltrim(srno))+')' end )+' '+ rtrim(ltrim(isnull(descr,''))) + '|' + rtrim(ltrim(isnull(Inputtype,''))) + '|' + CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(CESS_AMT,0) AS VARCHAR)   From #Temp11b  where part = 11 and PARTSR = '11B' 
	
	
	---Section 12.
	union all 
	SELECT  12 SECTION  , 'Description' + '|' + 'Add to orreduce fromoutput liability' + '|'  
	+ 'Integrated Tax'  + '|' + 'Central Tax' + '|' + 'State Tax/UT Tax' + '|' + 'CESS' as ColumnDetails
	union all 
	Select 12 as Section , (RTRIM(LTRIM(ISNULL(inv_no,''))) + ' ' + RTRIM(LTRIM(ISNULL(descr,'')))) + '|' + rtrim(ltrim(isnull(Inputtype,''))) + '|' + CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(CESS_AMT,0) AS VARCHAR)   From #GSTR2  where part = 12 
	---Section 13.
	union all 
	SELECT 13 as  SECTION  ,'Sr. No.' + '|'+ 'HSN' + '|' + 'Description(Optional if HSN IS Furnished)' + '|' 
	+ 'UQC' + '|' +
	 'Total Quantity' + '|' +
	  'Total Value' + '|' + 
	  'Total Taxable Value' + '|'   + 
	  'Integrated Tax'  + '|' + 
	  'Central Tax' + '|' + 'State Tax/UT Tax' 
	  + '|' + 'CESS' as ColumnDetails
	union all 
	Select 13 as Section ,cast((ROW_NUMBER()over( order by HSNCODE )) as varchar) + '|' + RTRIM(LTRIM(ISNULL(HSNCODE,''))) + '|'+ RTRIM(LTRIM(ISNULL(descr,''))) + '| ' + RTRIM(LTRIM(ISNULL(uqc,''))) + '|' 
	+ CAST(isnull(qty,0) AS VARCHAR) + '|' + CAST(isnull(gro_amt,0) AS VARCHAR) + '|'+ CAST(isnull(Taxableamt,0) AS VARCHAR) + '|'  + CAST(isnull(IGST_AMT,0) AS VARCHAR) + '|'  + CAST(isnull(CGST_AMT,0) AS VARCHAR) + '|' + CAST(isnull(SGST_AMT,0) AS VARCHAR) + '|' +  CAST(isnull(CESS_AMT,0) AS VARCHAR)   From #GSTR2  where part = 13 
	END	
END
GO
