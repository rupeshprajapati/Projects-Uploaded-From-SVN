IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='USP_ENT_GSTR9')
BEGIN
	DROP PROCEDURE [USP_ENT_GSTR9]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--set dateformat dmy EXECUTE USP_ENT_GSTR9'','','','01/04/2019 ','31/03/2020','','','','',0,0,'','','','','','','','','2019-2020',''

CREATE Procedure [USP_ENT_GSTR9]
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
	SELECT  Tran_cd =IDENTITY(INT,1,1),PART=0,PARTSR='AAAA',SRNO= SPACE(10)
	,ac_name = cast((CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END) as varchar(150))
	, gstin = space(30),SUPP_TYPE = SPACE(100),st_type= SPACE(100),StateCode=space(5)
	, D.QTY, cast(0.00 as numeric(18,2)) AS Taxableamt, D.CGST_AMT, D.SGST_AMT
	, D.IGST_AMT,D.IGST_AMT as Cess_Amt
	,cast(0.00 as numeric(18,2)) AS tax_payable,cast(0.00 as numeric(18,2)) AS tax_paid_cash
	,cast(0.00 as numeric(18,2)) AS interest,cast(0.00 as numeric(18,2)) AS penalty,cast(0.00 as numeric(18,2)) AS latefee_othrs
	,cast('' as varchar(15)) as hsncode,it.rateunit as uqc,d.qty as totqty,cast(0.00 as numeric(5,2)) as taxrate
	into #GSTR9
	FROM  STMAIN H 
	INNER JOIN STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) 
	INNER JOIN IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) 
	LEFT OUTER JOIN shipto ON (shipto.shipto_id = h.scons_id) 
	LEFT OUTER JOIN ac_mast ac ON (h.cons_id = ac.ac_id)  
	WHERE 1=2

	/* GSTR_VW DATA STORED IN TEMPORARY TABLE*/
	SELECT DISTINCT HSN_CODE, CAST(HSN_DESC AS VARCHAR(250)) AS HSN_DESC INTO #HSN FROM HSN_MASTER

	SELECT mEntry=case when l.Bcode_nm<>'' then l.Bcode_nm else (case when l.ext_vou=1 then '' else l.entry_ty end) end			
			,igst_amt1=ISNULL(a.igst_amt,0),cgst_amt1=ISNULL(a.cgst_amt,0),sGST_AMT1=isnull(a.sGST_AMT,0),CESS_AMT1 =isnull(a.CESS_AMT,0)
			,igsrt_amt1=ISNULL(a.IGSRT_AMT,0),cgsrt_amt1=ISNULL(a.CGSRT_AMT,0),sGSrT_AMT1=isnull(a.SGSRT_AMT,0),CESSR_AMT1 =isnull(a.CessR_amt,0)
			,Ecomgstin = isnull(ac.gstin,'')
			,A.*
			,HSN_DESC=ISNULL((SELECT TOP 1 HSN_DESC FROM #HSN WHERE HSN_CODE = A.HSNCODE),'')
	INTO #GSTR9TBL 
	FROM GSTR9_VW A
	left join ac_mast ac on (A.ecomac_id=ac.ac_id)
	inner join lcode l  on (a.entry_ty=l.entry_ty)
	WHERE (A.DATE BETWEEN @SDATE AND @EDATE) and A.AMENDDATE=''


	-----Amended Detail Temp table 
	SELECT mEntry=case when l.Bcode_nm<>'' then l.Bcode_nm else (case when l.ext_vou=1 then '' else l.entry_ty end) end
			,igst_amt1=ISNULL(a.igst_amt,0),cgst_amt1=ISNULL(a.cgst_amt,0),sGST_AMT1=isnull(a.sGST_AMT,0),CESS_AMT1 =isnull(a.CESS_AMT,0)
			,igsrt_amt1=ISNULL(a.IGSRT_AMT,0),cgsrt_amt1=ISNULL(a.CGSRT_AMT,0),sGSrT_AMT1=isnull(a.SGSRT_AMT,0),CESSR_AMT1 =isnull(a.CessR_amt,0)
			,Ecomgstin = isnull(ac.gstin,'')
			,A.*
			,HSN_DESC=ISNULL((SELECT TOP 1 HSN_DESC FROM #HSN WHERE HSN_CODE = A.HSNCODE),'')
	INTO #GSTR9AMD
	FROM GSTR9_VW A
	left join ac_mast ac on (A.ecomac_id=ac.ac_id)
	inner join lcode l  on (a.entry_ty=l.entry_ty)
	WHERE (A.AMENDDATE BETWEEN @SDATE AND @EDATE) AND A.HSNCODE <> ''
		
	Declare @amt1 decimal(18,2),@amt2 decimal(18,2),@amt3 decimal(18,2),@amt4 decimal(18,2),@from_srno varchar(30),@to_srno varchar(30)

	/*Pt. II Details of Outward and Inward supplies declared during the financial year*/
	/*4. Details of advances, inward and outward supplies on which tax is payable as declared in returns filed during the financial year*/
	/*A. Supplies made to un-registered persons (B2C)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 4 AS PART ,'4A' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	from #GSTR9TBL
	where (mEntry in ('ST','SB') and entry_ty<>'UB') and supp_type IN ('Unregistered')
	and gstin ='Unregistered' AND LineRule = 'Taxable' AND HSNCODE <> ''
	and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1 + cessr_amt1) = 0  and (SGST_AMT1 + CGST_AMT1  + IGST_AMT1 + cess_amt1) > 0  

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4A' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4A','A','',0,0,0,0,'',0,0)
	END

	/*B. Supplies made to registered persons (B2B)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 4 AS PART ,'4B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	,sum(CGST_AMT)CGST_AMT ,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM (
		SELECT 4 AS PART ,'4A' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
		,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
		from #GSTR9TBL
		where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type <> 'Out of country' 
		and supp_type IN ('Registered','Compounding','E-Commerce','') and gstin <>'' AND LineRule = 'Taxable' AND HSNCODE <> '' and Ecomgstin = ''
		and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1 + cessr_amt1) = 0  and (SGST_AMT1 + CGST_AMT1  + IGST_AMT1 + cess_amt1) > 0
		union all
		SELECT 4 AS PART ,'4C' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
		,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
		from #GSTR9TBL
		where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type <> 'Out of country' and Ecomgstin <> '' AND LineRule = 'Taxable' 
		AND HSNCODE <> '' and gstin not in('Unregistered') 
		and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1 + cessr_amt1) = 0  and (SGST_AMT1 + CGST_AMT1  + IGST_AMT1 + cess_amt1) > 0
		)AA
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4B' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4B','A','',0,0,0,0,'',0,0)
	END
	
	/*C. Zero rated supply (Export) on payment of tax (except supplies to SEZs)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 4 AS PART ,'4C' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,0.00,0.00,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	from #GSTR9TBL
	where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type = 'Out of Country' 
	and supp_type not IN ('SEZ') and expotype='WITH IGST' --and cgst_per+sgst_per+igst_per=0	

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4C' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4C','A','',0,0,0,0,'',0,0)
	END

	/*D. Supply to SEZs on payment of tax*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	select 4 AS PART ,'4D' AS PARTSR,'A' AS SRNO
	,sum(taxableamt)taxableamt,0.00,0.00,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	from #GSTR9TBL
	where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ')
	and expotype='With IGST'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4D' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4D','A','',0,0,0,0,'',0,0)
	END

	/*E. Deemed Exports*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	select 4 AS PART ,'4E' AS PARTSR,'A' AS SRNO
	,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	from #GSTR9TBL
	where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type in ('Export','EOU','IMPORT')
	and expotype='With IGST'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4E' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4E','A','',0,0,0,0,'',0,0)
	END
	
	/*F. Advances on which tax has been paid but invoice has not been issued (not covered under (A) to (E) above)*/
	SELECT * into #BANK_TMP 
	FROM (	SELECT DISTINCT TRAN_CD,ENTRY_TY,POS,pos_std_cd,DATE 
			FROM #GSTR9TBL 
			WHERE (mentry IN('CR','BR','ST','SB') and entry_ty<>'UB')
		)bb
		
	select A.*,B.POS,B.POS_STD_CD,C.DATE 
	INTO #TaxAlloc_tmp 
	from TaxAllocation A INNER JOIN #BANK_TMP B ON (A.Itref_tran =B.TRAN_CD AND A.REntry_ty =B.Entry_ty)
	INNER JOIN #BANK_TMP C ON (A.Entry_ty =C.Entry_ty AND A.Tran_cd =C.Tran_cd) 
	WHERE C.DATE BETWEEN @SDATE AND @EDATE
	
	SELECT * INTO #Tax_tmp 
	FROM (	select PKEY = '+', pos ,Taxableamt,CGST_AMT1,SGST_AMT1,IGST_AMT1,Cess_amt1 
			from #GSTR9TBL 
			where mentry in('BR','CR') and (CGST_AMT1 + SGST_AMT1+IGST_AMT1) > 0
			union all 
			SELECT PKEY = '-',POS,Taxable,CGST_AMT,SGST_AMT,IGST_AMT,COMPCESS 
			FROM #TaxAlloc_tmp
		)AA

	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	select 4 AS PART ,'4F' AS PARTSR,'A' AS SRNO
	,taxableamt = sum(case when pkey ='+' then +Taxableamt else -Taxableamt end )
	,CGST_AMT = sum(case when pkey ='+' then +CGST_AMT1 else -CGST_AMT1 end )
	,SGST_AMT = sum(case when pkey ='+' then +SGST_AMT1 else -SGST_AMT1 end )
	,IGST_AMT = sum(case when pkey ='+' then +IGST_AMT1 else -IGST_AMT1 end )
	,cess_amt = sum(case when pkey ='+' then +CESS_AMT1 else -CESS_AMT1 end )
	from #Tax_tmp 
	where (isnull(CGST_AMT1,0) + isnull(SGST_AMT1,0) + isnull(IGST_AMT1,0)) > 0  

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4F' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4F','A','',0,0,0,0,'',0,0)
	END
	
	/*G. Inward supplies on which tax is to be paid on reverse charge basis*/
	Declare @Taxableamt decimal(18,2),@CGST_AMT decimal(18,2),@SGST_AMT decimal(18,2),@IGST_AMT decimal(18,2) ,@CESS_AMT decimal(18,2)
	--,@TAX_PAID decimal(18,2),@CESS_PAID decimal(18,2),@INTEREST decimal(18,2), @LATE_FEE decimal(18,2)
	SET @Taxableamt =0.00
	SET @CGST_AMT =0.00
	SET @SGST_AMT =0.00
	SET @IGST_AMT =0.00
	SET @CESS_AMT =0.00

	SELECT @Taxableamt =isnull(SUM(Taxableamt),0)
	,@IGST_AMT =isnull(SUM(IGST_AMT),0)
	,@CGST_AMT =isnull(SUM(CGST_AMT ),0) 
	,@SGST_AMT =isnull(SUM(SGST_AMT),0)
	,@CESS_AMT =isnull(SUM(CESS_AMT),0)
	FROM #GSTR9TBL WHERE ENTRY_TY IN('UB')
	
	SELECT @Taxableamt = @Taxableamt +  isnull(SUM(Case when mEntry in ('BP','CP','EP','CN','PT') then +Taxableamt else -(Taxableamt) end),0)
	,@IGST_AMT = @IGST_AMT +  isnull(SUM(Case when mEntry in ('BP','CP','EP','CN','PT') then +IGSRT_AMT else -(IGSRT_AMT ) end),0)
	,@CGST_AMT = @CGST_AMT + isnull(SUM(Case when mEntry in ('BP','CP','EP','CN','PT') then +CGSRT_AMT else -(CGSRT_AMT ) end),0)
	,@SGST_AMT = @SGST_AMT + isnull(SUM(Case when mEntry in ('BP','CP','EP','CN','PT') then +SGSRT_AMT else -(SGSRT_AMT) end),0)
	,@CESS_AMT = @CESS_AMT + isnull(SUM(Case when mEntry in ('BP','CP','EP','CN','PT') then +CESSR_AMT else -(CESSR_AMT) end),0) 
	FROM #GSTR9TBL g WHERE mEntry IN ('BP','CP','EP','CN','DN','PR','PT') AND st_type IN ('INTRASTATE','INTERSTATE','OUT OF COUNTRY') 
	AND SUPP_TYPE not in ('Unregistered') AND AGAINSTGS in ('','PURCHASES','SERVICE PURCHASE BILL','GOODS','SERVICES')
	and LineRule not in('Nill Rated','Nil Rated','Exempted') AND (isnull(CGSRT_AMT,0) + isnull(SGSRT_AMT,0) + isnull(IGSRT_AMT,0)) > 0  
	AND GSTIN NOT IN ('Unregistered')
	and (g.entry_ty+quotename(g.tran_cd)) not in (select (m.entry_ty+quotename(m.tran_cd)) 
							from mainall_vw m where (g.entry_ty=m.entry_ty and g.tran_cd=m.tran_cd))

	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	select 4 AS PART ,'4G' AS PARTSR,'A' AS SRNO,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT,@CESS_AMT

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4G' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4G','A','',0,0,0,0,'',0,0)
	END

	/*H. Sub-total (A to G above)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 4 AS PART ,'4H' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4A','4B','4C','4D','4E','4F','4G') AND SRNO='A'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4H' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4H','A','',0,0,0,0,'',0,0)
	END

	/*I. Credit Notes issued in respect of transactions specified in (B) to (E) above (-)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 4 AS PART ,'4I' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	,sum(CGST_AMT)CGST_AMT ,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM (	
			SELECT 4 AS PART ,'4B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
			,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			from #GSTR9TBL
			where mEntry in ('CN') and st_type <> 'Out of country' 
			and supp_type IN ('Registered','Compounding','E-Commerce','') and gstin <>'' AND LineRule = 'Taxable' AND HSNCODE <> '' and Ecomgstin = ''
			and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1 + cessr_amt1) = 0  and (SGST_AMT1 + CGST_AMT1  + IGST_AMT1 + cess_amt1) > 0
			and againstgs='SALES'
			Union all
			SELECT 4 AS PART ,'4B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
			,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			from #GSTR9TBL
			where mEntry in ('CN') and st_type <> 'Out of country' and Ecomgstin <> '' AND LineRule = 'Taxable' 
			AND HSNCODE <> '' and gstin not in('Unregistered') 
			and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1 + cessr_amt1) = 0  and (SGST_AMT1 + CGST_AMT1  + IGST_AMT1 + cess_amt1) > 0
			and againstgs='SALES'
			Union all
			SELECT 4 AS PART ,'4C' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT
			,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			from #GSTR9TBL
			where mEntry in ('CN') and st_type = 'Out of Country' 
			and supp_type not IN ('SEZ') and expotype='WITH IGST' --and cgst_per+sgst_per+igst_per=0
			and againstgs='SALES'
			Union all
			select 4 AS PART ,'4D' AS PARTSR,'A' AS SRNO
			,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt 
			from #GSTR9TBL
			where mEntry in ('CN') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ') and expotype='WITH IGST'
			and againstgs='SALES'
			Union all
			select 4 AS PART ,'4E' AS PARTSR,'A' AS SRNO
			,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			from #GSTR9TBL
			where mEntry in ('CN') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type in ('Export','EOU','IMPORT') and expotype='WITH IGST'
			and againstgs='SALES'
		)AA

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4I' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4I','A','',0,0,0,0,'',0,0)
	END


	/*J. Debit Notes issued in respect of transactions specified in (B) to (E) above (+)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 4 AS PART ,'4J' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	,sum(CGST_AMT)CGST_AMT ,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM (
			SELECT 4 AS PART ,'4B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
			,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			from #GSTR9TBL
			where mEntry in ('DN') and st_type <> 'Out of country' 
			and supp_type IN ('Registered','Compounding','E-Commerce','') and gstin <>'' AND LineRule = 'Taxable' AND HSNCODE <> '' and Ecomgstin = ''
			and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1 + cessr_amt1) = 0  and (SGST_AMT1 + CGST_AMT1  + IGST_AMT1 + cess_amt1) > 0
			and againstgs='SALES'
			Union all
			SELECT 4 AS PART ,'4B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
			,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			from #GSTR9TBL
			where mEntry in ('DN') and st_type <> 'Out of country' and Ecomgstin <> '' AND LineRule = 'Taxable' 
			AND HSNCODE <> '' and gstin not in('Unregistered') 
			and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1 + cessr_amt1) = 0  and (SGST_AMT1 + CGST_AMT1  + IGST_AMT1 + cess_amt1) > 0
			and againstgs='SALES'
			Union all
			SELECT 4 AS PART ,'4C' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT
			,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			from #GSTR9TBL
			where mEntry in ('DN') and st_type = 'Out of Country' 
			and supp_type not IN ('SEZ') and expotype='WITH IGST' --and cgst_per+sgst_per+igst_per=0
			and againstgs='SALES'
			Union all
			select 4 AS PART ,'4D' AS PARTSR,'A' AS SRNO
			,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt 
			from #GSTR9TBL
			where mEntry in ('DN') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ') and expotype='WITH IGST'
			and againstgs='SALES'
			Union all
			select 4 AS PART ,'4E' AS PARTSR,'A' AS SRNO
			,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			from #GSTR9TBL
			where mEntry in ('DN') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type in ('Export','EOU','IMPORT') and expotype='WITH IGST'
			and againstgs='SALES'
		)AA

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4J' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4J','A','',0,0,0,0,'',0,0)
	END
	
	/*K. Supplies / tax declared through Amendments (+)*/
	--Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	--SELECT 4 AS PART ,'4K' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--,sum(CGST_AMT)CGST_AMT ,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	--FROM (
	--		SELECT 4 AS PART ,'4B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--		,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt 
	--		from #GSTR9AMD
	--		where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type <> 'Out of country' and Ecomgstin <> '' AND LineRule = 'Taxable' 
	--		AND HSNCODE <> '' and gstin not in('Unregistered') 
	--		and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1 + cessr_amt1) = 0  and (SGST_AMT1 + CGST_AMT1  + IGST_AMT1 + cess_amt1) > 0
	--		Union all
	--		SELECT 4 AS PART ,'4C' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT
	--		,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	--		from #GSTR9AMD
	--		where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type = 'Out of Country' 
	--		and supp_type not IN ('SEZ') --and cgst_per+sgst_per+igst_per=0
	--		Union all
	--		select 4 AS PART ,'4D' AS PARTSR,'A' AS SRNO
	--		,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt 
	--		from #GSTR9AMD
	--		where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ')
	--		Union all
	--		select 4 AS PART ,'4E' AS PARTSR,'A' AS SRNO
	--		,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	--		from #GSTR9AMD
	--		where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type in ('Export','EOU','IMPORT')
	--	)AA	

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4K' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4K','A','',0,0,0,0,'',0,0)
	END

	/*L. Supplies / tax reduced through Amendments (-)*/
	--Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	--SELECT 4 AS PART ,'4L' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--,sum(CGST_AMT)CGST_AMT ,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	--FROM (
	--		SELECT 4 AS PART ,'4B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--		,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt 
	--		from #GSTR9AMD
	--		where (mEntry in ('DN','CN') OR ENTRY_TY='RV') and st_type <> 'Out of country' and Ecomgstin <> '' AND LineRule = 'Taxable' 
	--		AND HSNCODE <> '' and gstin not in('Unregistered') 
	--		and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1 + cessr_amt1) = 0  and (SGST_AMT1 + CGST_AMT1  + IGST_AMT1 + cess_amt1) > 0
	--		Union all
	--		SELECT 4 AS PART ,'4C' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT
	--		,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	--		from #GSTR9AMD
	--		where (mEntry in ('DN','CN') OR ENTRY_TY='RV') and st_type = 'Out of Country' 
	--		and supp_type not IN ('SEZ') --and cgst_per+sgst_per+igst_per=0
	--		Union all
	--		select 4 AS PART ,'4D' AS PARTSR,'A' AS SRNO
	--		,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt 
	--		from #GSTR9AMD
	--		where (mEntry in ('DN','CN') OR ENTRY_TY='RV') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ')
	--		Union all
	--		select 4 AS PART ,'4E' AS PARTSR,'A' AS SRNO
	--		,sum(taxableamt)taxableamt,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	--		from #GSTR9AMD
	--		where (mEntry in ('DN','CN') OR ENTRY_TY='RV') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type in ('Export','EOU','IMPORT')
	--	)AA

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4L' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4L','A','',0,0,0,0,'',0,0)
	END
	
	/*M. Sub-total (I to L) above*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 4 AS PART ,'4M' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4I','4J','4K','4L') AND SRNO='A'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4M' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4M','A','',0,0,0,0,'',0,0)
	END

	/*N. Supplies and advances on which tax is to be paid (H+M) above*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 4 AS PART ,'4N' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4H','4M') AND SRNO='A'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '4N' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(4,'4N','A','',0,0,0,0,'',0,0)
	END

	/*5. Details of Outward supplies on which tax is not payable as declared in returns filed during the financial year*/
	/*A. Zero rated supply (Export) without payment of tax*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt)
	SELECT 5 AS PART ,'5A' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	from #GSTR9TBL
	where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type = 'Out of Country' 
	and supp_type not IN ('SEZ') and expotype='WITHOUT IGST' --and cgst_per+sgst_per+igst_per=0	

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5A' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5A','A','',0,0,0,0,'',0,0)
	END

	/*B. Supply to SEZs without payment of tax*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt)
	select 5 AS PART ,'5B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	from #GSTR9TBL
	where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ')
	and expotype='WITHOUT IGST'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5B' AND SRNO ='A')
	BEGIN		
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5B','A','',0,0,0,0,'',0,0)
	END
		
	/*C. Supplies on which tax is to be paid by the recipient on reverse charge basis*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 5 AS PART ,'5C' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	FROM #GSTR9TBL
	WHERE (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type <> 'Out of country' 
	and supp_type IN('Registered','Compounding','E-Commerce')
	and gstin <>'' AND LineRule = 'Taxable' AND HSNCODE <> '' and Ecomgstin = '' AND (SGSRT_AMT1 + CGSRT_AMT1 + IGSRT_AMT1 + cessr_amt1) > 0

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5C' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5C','A','',0,0,0,0,'',0,0)
	END

	/*Exempted, Nil Rated, Non-GST supply*/
	select linerule,NilAmt =(case when lineRule ='Nil Rated'  then sum(GRO_AMT) else 0.00 end)
	,ExemAmt =(case when lineRule ='Exempted'  then sum(GRO_AMT) else 0.00 end)
	,NonGstAmt =(case when (LineRule ='Non GST') then sum(GRO_AMT) else 0.00 end)
	into #Gstr9Tbl1
	from #Gstr9Tbl
	where (lineRule in('Nil Rated','Exempted','Non GST')) 
	--and st_type in('INTERSTATE','INTRASTATE') 
	AND (mentry in('ST','SB') and entry_ty<>'UB') 
	--AND Supp_type NOT IN ('EXPORT','SEZ','IMPORT','EOU')
	group by linerule

	/*D. Exempted*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt)
	SELECT 5 AS PART ,'5D' AS PARTSR,'A' AS SRNO,ExemAmt from #Gstr9Tbl1 where linerule='Exempted'	

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5D' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5D','A','',0,0,0,0,'',0,0)
	END

	/*E. Nil Rated*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt)
	SELECT 5 AS PART ,'5E' AS PARTSR,'A' AS SRNO,NilAmt from #Gstr9Tbl1 where linerule='Nil Rated'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5E' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5E','A','',0,0,0,0,'',0,0)
	END

	/*F. Non-GST supply*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt)
	SELECT 5 AS PART ,'5F' AS PARTSR,'A' AS SRNO,NonGstAmt from #Gstr9Tbl1 where linerule='Non GST'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5F' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5F','A','',0,0,0,0,'',0,0)
	END

	/*G. Sub-total (A to F) above*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 5 AS PART ,'5G' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PART IN (5) AND PARTSR IN ('5A','5B','5C','5D','5E','5F') AND SRNO='A'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5G' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5G','A','',0,0,0,0,'',0,0)
	END

	/*H. Credit Notes issued in respect of transactions specified in A to F above (-)*/
	select linerule,NilAmt =(case when lineRule ='Nil Rated'  then sum(GRO_AMT) else 0.00 end)
	,ExemAmt =(case when lineRule ='Exempted'  then sum(GRO_AMT) else 0.00 end)
	,NonGstAmt =(case when (LineRule ='Non GST') then sum(GRO_AMT) else 0.00 end),mentry 
	into #Gstr9Tbl2
	from #Gstr9Tbl
	where (lineRule in('Nil Rated','Exempted','Non GST')) 
	--and st_type in('INTERSTATE','INTRASTATE') 
	AND mentry in('CN','DN') 
	--AND Supp_type NOT IN ('EXPORT','SEZ','IMPORT','EOU') 
	and againstgs='SALES'
	group by linerule,mentry
	
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 5 AS PART ,'5H' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	,sum(CGST_AMT)CGST_AMT ,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM (
			SELECT 5 AS PART ,'5A' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,cgst_amt=0.00,sgst_amt=0.00,igst_amt=0.00,cess_amt=0.00
			from #GSTR9TBL
			where mEntry in ('CN') and st_type = 'Out of Country' and supp_type not IN ('SEZ') and againstgs='SALES'
			and expotype='WITHOUT IGST' and lineRule not in ('Nil Rated')
			Union all
			select 5 AS PART ,'5B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,0.00,0.00,0.00,0.00
			from #GSTR9TBL
			where mEntry in ('CN') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ') and againstgs='SALES'
			and expotype='WITHOUT IGST' and lineRule not in ('Nil Rated')
			Union all
			SELECT 5 AS PART ,'5C' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
			,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			FROM #GSTR9TBL
			WHERE mEntry in ('CN') and st_type <> 'Out of country' and supp_type IN('Registered','Compounding','E-Commerce') and gstin <>'' 
			AND LineRule = 'Taxable' AND HSNCODE <> '' and Ecomgstin = '' AND (SGSRT_AMT1 + CGSRT_AMT1 + IGSRT_AMT1 + cessr_amt1) > 0
			and againstgs='SALES'
			Union all
			SELECT 5 AS PART ,'5D' AS PARTSR,'A' AS SRNO,ExemAmt,0.00,0.00,0.00,0.00 from #Gstr9Tbl2 where linerule='Exempted' and mEntry in ('CN')
			Union all
			SELECT 5 AS PART ,'5E' AS PARTSR,'A' AS SRNO,NilAmt,0.00,0.00,0.00,0.00 from #Gstr9Tbl2 where linerule='Nil Rated' and mEntry in ('CN')
			Union all
			SELECT 5 AS PART ,'5F' AS PARTSR,'A' AS SRNO,NonGstAmt,0.00,0.00,0.00,0.00 from #Gstr9Tbl2 where linerule='Non GST' and mEntry in ('CN')
		)AA

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5H' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5H','A','',0,0,0,0,'',0,0)
	END

	/*I. Debit Notes issued in respect of transactions specified in A to F above (+)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 5 AS PART ,'5I' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	,sum(CGST_AMT)CGST_AMT ,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM (
			SELECT 5 AS PART ,'5A' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,cgst_amt=0.00,sgst_amt=0.00,igst_amt=0.00,cess_amt=0.00
			from #GSTR9TBL
			where mEntry in ('DN') and st_type = 'Out of Country' and supp_type not IN ('SEZ') and againstgs='SALES'
			and expotype='WITHOUT IGST' and lineRule not in ('Nil Rated')
			Union all
			select 5 AS PART ,'5B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,0.00,0.00,0.00,0.00
			from #GSTR9TBL
			where mEntry in ('DN') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ') and againstgs='SALES'
			and expotype='WITHOUT IGST' and lineRule not in ('Nil Rated')
			Union all
			SELECT 5 AS PART ,'5C' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
			,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
			FROM #GSTR9TBL
			WHERE mEntry in ('DN') and st_type <> 'Out of country' and supp_type IN('Registered','Compounding','E-Commerce') and gstin <>'' 
			AND LineRule = 'Taxable' AND HSNCODE <> '' and Ecomgstin = '' AND (SGSRT_AMT1 + CGSRT_AMT1 + IGSRT_AMT1 + cessr_amt1) > 0
			and againstgs='SALES'
			Union all
			SELECT 5 AS PART ,'5D' AS PARTSR,'A' AS SRNO,ExemAmt,0.00,0.00,0.00,0.00 from #Gstr9Tbl2 where linerule='Exempted' and mEntry in ('DN')
			Union all
			SELECT 5 AS PART ,'5E' AS PARTSR,'A' AS SRNO,NilAmt,0.00,0.00,0.00,0.00 from #Gstr9Tbl2 where linerule='Nil Rated' and mEntry in ('DN')
			Union all
			SELECT 5 AS PART ,'5F' AS PARTSR,'A' AS SRNO,NonGstAmt,0.00,0.00,0.00,0.00 from #Gstr9Tbl2 where linerule='Non GST' and mEntry in ('DN')
		)AA

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5I' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5I','A','',0,0,0,0,'',0,0)
	END

	/*J. Supplies declared through Amendments (+)*/
	--Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	--SELECT 5 AS PART ,'5J' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--,sum(CGST_AMT)CGST_AMT ,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	--FROM (
	--		SELECT 5 AS PART ,'5A' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--		,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	--		from #GSTR9AMD
	--		where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type = 'Out of Country' 
	--		and supp_type not IN ('SEZ') and expotype='WITHOUT IGST' --and cgst_per+sgst_per+igst_per=0	
	--		union all
	--		select 5 AS PART ,'5B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--		,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	--		from #GSTR9AMD
	--		where (mEntry in ('ST','SB') and entry_ty<>'UB') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ')
	--		and expotype='WITHOUT IGST'
	--	)AA

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5J' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5J','A','',0,0,0,0,'',0,0)
	END
	
	/*K. Supplies reduced through Amendments (-)*/
	--Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	--SELECT 5 AS PART ,'5K' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--,sum(CGST_AMT)CGST_AMT ,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	--FROM (
	--		SELECT 5 AS PART ,'5A' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--		,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	--		from #GSTR9AMD
	--		where (mEntry in ('DN','CN') OR ENTRY_TY='RV') and st_type = 'Out of Country' 
	--		and supp_type not IN ('SEZ') and expotype='WITHOUT IGST' --and cgst_per+sgst_per+igst_per=0	
	--		union all
	--		select 5 AS PART ,'5B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt
	--		,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt
	--		from #GSTR9AMD
	--		where (mEntry in ('DN','CN') OR ENTRY_TY='RV') and st_type IN ('INTERSTATE','INTRASTATE') and supp_type IN ('SEZ')
	--		and expotype='WITHOUT IGST'
	--	)AA

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5K' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5K','A','',0,0,0,0,'',0,0)
	END

	/*L. Sub-total (H to K above)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 5 AS PART ,'5L' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PART IN (5) AND PARTSR IN ('5H','5I','5J','5K') AND SRNO='A'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5L' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5L','A','',0,0,0,0,'',0,0)
	END

	/*M. Turnover on which tax is not to be paid (G + L above)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 5 AS PART ,'5M' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PART IN (5) AND PARTSR IN ('5G','5L') AND SRNO='A'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5M' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5M','A','',0,0,0,0,'',0,0)
	END

	/*N. Total Turnover (including advances) (4N + 5M - 4G above)*/
	SET @Taxableamt =0.00
	SET @CGST_AMT =0.00
	SET @SGST_AMT =0.00
	SET @IGST_AMT =0.00
	SET @CESS_AMT =0.00

	SELECT @taxableamt=((SELECT taxableamt FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4N') AND SRNO='A') + 
						(SELECT taxableamt FROM #GSTR9 WHERE PART IN (5) AND PARTSR IN ('5M') AND SRNO='A') - 
						(SELECT taxableamt FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4G') AND SRNO='A'))
	,@CGST_AMT=((SELECT CGST_AMT FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4N') AND SRNO='A') + 
						(SELECT CGST_AMT FROM #GSTR9 WHERE PART IN (5) AND PARTSR IN ('5M') AND SRNO='A') - 
						(SELECT CGST_AMT FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4G') AND SRNO='A'))
	,@SGST_AMT=((SELECT SGST_AMT FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4N') AND SRNO='A') + 
						(SELECT SGST_AMT FROM #GSTR9 WHERE PART IN (5) AND PARTSR IN ('5M') AND SRNO='A') - 
						(SELECT SGST_AMT FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4G') AND SRNO='A'))
	,@IGST_AMT=((SELECT IGST_AMT FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4N') AND SRNO='A') + 
						(SELECT IGST_AMT FROM #GSTR9 WHERE PART IN (5) AND PARTSR IN ('5M') AND SRNO='A') - 
						(SELECT IGST_AMT FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4G') AND SRNO='A'))
	,@CESS_AMT=((SELECT CESS_AMT FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4N') AND SRNO='A') + 
						(SELECT CESS_AMT FROM #GSTR9 WHERE PART IN (5) AND PARTSR IN ('5M') AND SRNO='A') - 
						(SELECT CESS_AMT FROM #GSTR9 WHERE PART IN (4) AND PARTSR IN ('4G') AND SRNO='A'))

--SELECT * FROM #GSTR9 WHERE PART IN (4,5) AND PARTSR IN ('4N','5M','4G') AND SRNO='A'
--SELECT @taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT,@cess_amt

	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 5 AS PART ,'5N' AS PARTSR,'A' AS SRNO, @taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT,@cess_amt
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '5N' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(5,'5N','A','',0,0,0,0,'',0,0)
	END
	
	/*Pt. III Details of ITC as declared in returns filed during the financial year*/
	/*6. Details of ITC availed as declared in returns filed during the financial year*/
	--IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6' AND SRNO ='')
	--BEGIN
	--	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	--	VALUES(6,'6','A','',0,0,0,0,'',0,0)
	--END

	/*A. Total amount of input tax credit availed through FORM GSTR-3B (sum total of Table 4A of FORM GSTR-3B)*/
	
	SELECT * INTO #PTEPRCMTBL FROM (select entry_ty,tran_cd,scons_id,DATE,u_cldt  from EPMAIN  union all select entry_ty,tran_cd,scons_id,DATE,u_cldt from PtMAIN )A  where entry_ty in('PT','P1','E1') AND u_cldt <= @EDATE
	SELECT * INTO #BPRCM FROM (select entry_ty,tran_cd,AC_ID,DATE,u_cldt  from CPMAIN union all select entry_ty,tran_cd,Ac_id, DATE,u_cldt from BPMAIN )A  where entry_ty in('CP','BP') AND u_cldt <= @EDATE

		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
---(1) Import of goods
Select taxableamt=sum(taxableamt),igst_amt=sum(igst_amt),cgst_amt=sum(cgst_amt),sgst_amt=sum(sgst_amt),cess_amt=sum(cess_amt) into #aa from (
	SELECT Taxableamt =isnull(SUM(Case when mEntry in('PT','CN') then +Taxableamt else -(Taxableamt) end),0.00)
	,IGST_AMT =isnull(SUM(Case when mEntry in('PT','CN') then +IGST_AMT else -(IGST_AMT) end),0.00)
	,CGST_AMT =isnull(SUM(Case when mEntry in('PT','CN') then +CGST_AMT else -(CGST_AMT) end),0.00)
	,SGST_AMT =isnull(SUM(Case when mEntry in('PT','CN') then +SGST_AMT else -(SGST_AMT) end),0.00)
	,CESS_AMT =isnull(SUM(Case when mEntry in('PT','CN') then +CESS_AMT else -(CESS_AMT) end),0.00)
	FROM #GSTR9TBL WHERE mEntry IN('PT','PR','CN','DN') 
	AND Isservice  ='GOODS'
	AND ((st_type ='OUT OF COUNTRY' AND SUPP_TYPE IN('IMPORT','')) OR ( st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE IN('SEZ','IMPORT','EOU','EXPORT'))) AND AGAINSTGS in('','PURCHASES','GOODS')  
	and isnull(ITCSEC,'') = ''
	Union all
---(2) Import of services
	Select 0.00,IGST_AMT = isnull(sum((case when b.typ = 'IGST Payable' then a.new_all else 0.00 end)),0.00)
	,0.00,0.00
	,CESS_AMT = isnull(sum((case when b.typ = 'COMP CESS PAYABLE' then a.new_all else 0.00 end)),0.00)
	from mainall_vw  a left outer join AC_MAST b on a.Ac_id = b.Ac_id  
	left outer join bpmain c on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd)
	where a.entry_ty = 'GB' 
	and c.u_cldt between @SDATE and @EDATE
	and b.typ in('CGST Payable','SGST Payable','IGST Payable','COMP CESS PAYABLE') and ((a.ENTRY_ALL+ quotename(a.Main_tran))  in (select  a.entry_ty+ quotename(a.Tran_cd)  from #PTEPRCMTBL a LEFT OUTER JOIN shipto c ON (c.shipto_id = a.scons_id) where c.Supp_type in('import','sez','Eou','','Export')) or  (a.ENTRY_ALL+ quotename(a.Main_tran)) in (select  a.entry_ty+ quotename(a.Tran_cd)  from #BPRCM a LEFT OUTER JOIN AC_MAST  c ON (c.Ac_id  = a.Ac_id ) where c.Supp_type in('import','sez','Eou','','Export')))
		Union all
 ----(3) Inward supplies liable to reverse charge (other than 1 & 2 above)
	select 0.00,IGST_AMT = isnull(sum((case when b.typ = 'IGST Payable' then a.new_all else 0.00 end)),0.00)
	,CGST_AMT = isnull(sum((case when b.typ = 'CGST Payable' then a.new_all else 0.00 end)),0.00) 
	,SGST_AMT = isnull(sum((case when b.typ = 'SGST Payable' then a.new_all else 0.00 end)),0.00) 
	,CESS_AMT = isnull(sum((case when b.typ = 'COMP CESS PAYABLE' then a.new_all else 0.00 end)),0.00)
	from mainall_vw  a left outer join AC_MAST b on a.Ac_id = b.Ac_id  
	left outer join bpmain c on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd)
	where a.entry_ty = 'GB' 
	and b.typ in('CGST Payable','SGST Payable','IGST Payable','COMP CESS PAYABLE') 
	and c.u_cldt between @SDATE and @EDATE
	and ((a.ENTRY_ALL+ quotename(a.Main_tran)) not in (select  a.entry_ty+ quotename(a.Tran_cd)  from #PTEPRCMTBL a LEFT OUTER JOIN shipto c ON (c.shipto_id = a.scons_id) where c.Supp_type in('import','sez','Eou','','Export')) and (a.ENTRY_ALL+ quotename(a.Main_tran)) not in (select  a.entry_ty+ quotename(a.Tran_cd)  from #BPRCM a LEFT OUTER JOIN AC_MAST  c ON (c.Ac_id  = a.Ac_id ) where c.Supp_type in('import','sez','Eou','','Export')))
		Union all   
-----(4) Inward Supplies from ISD		
	select 0.00
	,IGST_AMT=ISNULL(SUM(A.IGST_AMT),0) 
	,CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
	,SGST_AMT=ISNULL(SUM(A.SGST_AMT),0)
	,CESS_AMT=ISNULL(SUM(A.COMPCESS),0)
	from JVITEM a left outer join JVMAIN b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
	WHERE A.entry_ty IN('J6','J8') AND  (A.date BETWEEN @SDATE AND @EDATE)
	) a	
	
---(5)ALL OTHER ITC
	SELECT @Taxableamt =ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +Taxableamt else -(Taxableamt) end),0)
	,@IGST_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +IGST_AMT else -(IGST_AMT ) end),0)
		- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +IIGST_AMT else -(IIGST_AMT ) end),0))
	,@CGST_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +CGST_AMT else -(CGST_AMT ) end),0)
		- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +ICGST_AMT else -(ICGST_AMT ) end),0))
	,@SGST_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +SGST_AMT else -(SGST_AMT ) end),0)
		- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +ISGST_AMT else -(ISGST_AMT ) end),0))
	,@CESS_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +CESS_AMT else -(CESS_AMT ) end),0)
		- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +ICESS_AMT else -(ICESS_AMT ) end),0))
	FROM #GSTR9TBL A
	LEFT OUTER JOIN EPAYMENT B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL)
	WHERE A.mEntry IN ('EP','PT','CN')
	AND st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE in('Registered','Compounding','E-commerce') 
	AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')
	and LineRule not in('Nill Rated','Nil Rated','Exempted') AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 
		 	
Select @taxableamt=sum(taxableamt),@igst_amt=sum(igst_amt),@cgst_amt=sum(cgst_amt),@sgst_amt=sum(sgst_amt),@cess_amt=sum(cess_amt) 
from (
	Select 0.00 as taxableamt
	,IGST_AMT = @IGST_AMT + ISNULL(SUM(A.IGST_AMT),0)
	,CGST_AMT = @CGST_AMT + ISNULL(SUM(A.CGST_AMT),0)
	,SGST_AMT = @SGST_AMT + ISNULL(SUM(A.SGST_AMT),0)	
	,CESS_AMT = @CESS_AMT + ISNULL(SUM(A.COMPCESS),0)
	From JVMAIN A WHERE A.entry_ty ='J7' 
	AND  A.AGAINSTTY in ('Excess','Addition')
	AND  (A.date BETWEEN @SDATE AND @EDATE) 
	Union all
	Select * from #aa
	) b 
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6A' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6A','A','',@taxableamt,@SGST_AMT,@CGST_AMT,@IGST_AMT,'',0,@cess_amt)
	END

	/*B. Inward supplies (other than imports and inward supplies liable to reverse charge but includes services received from SEZs)*/
	--SELECT *
	--/*A.GoodsType
	--	,IGST_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +(case when IGST_AMT>0 then IGST_AMT else IGSRT_AMT end)
	--	 else -(case when IGST_AMT>0 then IGST_AMT else IGSRT_AMT end) end),0)
	--		- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +IIGST_AMT else -(IIGST_AMT) end),0))
	--	,CGST_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +(case when CGST_AMT>0 then CGST_AMT else CGSRT_AMT end)
	--	 else -(case when CGST_AMT>0 then CGST_AMT else CGSRT_AMT end) end),0)
	--		- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +ICGST_AMT else -(ICGST_AMT ) end),0))
	--	,SGST_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +(case when SGST_AMT>0 then SGST_AMT else SGSRT_AMT end)
	--	 else -(case when SGST_AMT>0 then SGST_AMT else SGSRT_AMT end) end),0)
	--		- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +ISGST_AMT else -(ISGST_AMT ) end),0))
	--	,CESS_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +(case when CESS_AMT>0 then CESS_AMT else CESSR_AMT end)
	--	 else -(case when CESS_AMT>0 then CESS_AMT else CESSR_AMT end) end),0)
	--		- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +ICESS_AMT else -(ICESS_AMT ) end),0))
	--		*/
--	select a.tran_cd,*
--FROM #GSTR9TBL A
--		LEFT OUTER JOIN EPAYMENT B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL)
--		WHERE A.mEntry IN ('EP','PT','CN','DN')
--		AND st_type IN('INTRASTATE','INTERSTATE') AND ((SUPP_TYPE in('Registered','Compounding','E-commerce') and CGSRT_AMT +SGSRT_AMT + IGSRT_AMT=0))
--		--or (supp_type='SEZ' and goodstype='Input Services'))-- and (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) <> 0 ))
--		AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')
--		and LineRule not in('Nill Rated','Nil Rated','Exempted') --AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 
--		--group by A.GoodsType
--		and a.goodstype<>'Input Services'

--	select a.tran_cd,*
--		FROM #GSTR9TBL A
--		LEFT OUTER JOIN EPAYMENT B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL)
--		WHERE A.mEntry IN ('EP','PT','CN','DN')
--		AND st_type IN('INTRASTATE','INTERSTATE') 
--		--AND ((SUPP_TYPE in('Registered','Compounding','E-commerce') and CGSRT_AMT +SGSRT_AMT + IGSRT_AMT=0)
--		and ((supp_type='SEZ' and goodstype='Input Services'))-- and (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) <> 0 ))
--		AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')
--		--and LineRule not in('Nill Rated','Nil Rated','Exempted') --AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 
--		--group by A.GoodsType
--		and a.goodstype='Input Services'
--		return

		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
				
		SELECT A.GoodsType
		,IGST_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +(case when IGST_AMT>0 then IGST_AMT else IGSRT_AMT end)
		 else -(case when IGST_AMT>0 then IGST_AMT else IGSRT_AMT end) end),0)
			- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +IIGST_AMT else -(IIGST_AMT) end),0))
		,CGST_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +(case when CGST_AMT>0 then CGST_AMT else CGSRT_AMT end)
		 else -(case when CGST_AMT>0 then CGST_AMT else CGSRT_AMT end) end),0)
			- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +ICGST_AMT else -(ICGST_AMT ) end),0))
		,SGST_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +(case when SGST_AMT>0 then SGST_AMT else SGSRT_AMT end)
		 else -(case when SGST_AMT>0 then SGST_AMT else SGSRT_AMT end) end),0)
			- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +ISGST_AMT else -(ISGST_AMT ) end),0))
		,CESS_AMT =(ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +(case when CESS_AMT>0 then CESS_AMT else CESSR_AMT end)
		 else -(case when CESS_AMT>0 then CESS_AMT else CESSR_AMT end) end),0)
			- ISNULL(SUM(Case when A.mEntry in ('EP','PT','CN') then +ICESS_AMT else -(ICESS_AMT ) end),0))
			into #sec6b
		FROM #GSTR9TBL A
		LEFT OUTER JOIN EPAYMENT B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL)
		WHERE A.mEntry IN ('EP','PT','CN','DN')
		AND st_type IN('INTRASTATE','INTERSTATE') AND ((SUPP_TYPE in('Registered','Compounding','E-commerce') and CGSRT_AMT +SGSRT_AMT + IGSRT_AMT=0)
		or (supp_type='SEZ' and goodstype='Input Services'))-- and (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) <> 0 ))
		AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')
		and LineRule not in('Nill Rated','Nil Rated','Exempted') --AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 
		group by A.GoodsType
			
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6B1','A1','Inputs',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6b where goodstype='Inputs'
		
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6B1' AND SRNO ='A1')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6B1','A1','Inputs',0,0,0,0,'',0,0)
	END

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6B2','A2','Capital Goods',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6b where goodstype='Capital Goods'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6B2' AND SRNO ='A2')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6B2','A2','Capital Goods',0,0,0,0,'',0,0)
	END
		
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6B3','A3','Input Services',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6b where goodstype='Input Services'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6B3' AND SRNO ='A3')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6B3','A3','Input Services',0,0,0,0,'',0,0)
	END
	--select * from #gstr9 where part=6
	--return
	/*C. Inward supplies received from unregistered persons liable to reverse charge (other than B above) on which tax is paid & ITC availed*/
	select distinct d.goodstype,a.new_all,b.typ
	into #sec6c_1
	from mainall_vw  a left outer join AC_MAST b on a.Ac_id = b.Ac_id  
	left outer join bpmain c on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd)
	left outer join #gstr9tbl d on (d.entry_ty=a.entry_all and d.tran_cd=a.main_tran)
	where a.entry_ty = 'GB' 
	and b.typ in('CGST Payable','SGST Payable','IGST Payable','COMP CESS PAYABLE') 
	and c.u_cldt between @SDATE and @EDATE
	and a.entry_all='UB'
	and ((a.ENTRY_ALL+ quotename(a.Main_tran)) not in (select  a.entry_ty+ quotename(a.Tran_cd)  from #PTEPRCMTBL a LEFT OUTER JOIN shipto c ON (c.shipto_id = a.scons_id) where c.Supp_type in('import','sez','Eou','','Export')) and (a.ENTRY_ALL+ quotename(a.Main_tran)) not in (select  a.entry_ty+ quotename(a.Tran_cd)  from #BPRCM a LEFT OUTER JOIN AC_MAST  c ON (c.Ac_id  = a.Ac_id ) where c.Supp_type in('import','sez','Eou','','Export')))
	group by d.goodstype,b.typ,a.new_all

	select goodstype,IGST_AMT = isnull(sum((case when typ = 'IGST Payable' then new_all else 0.00 end)),0.00)
	,CGST_AMT = isnull(sum((case when typ = 'CGST Payable' then new_all else 0.00 end)),0.00) 
	,SGST_AMT = isnull(sum((case when typ = 'SGST Payable' then new_all else 0.00 end)),0.00) 
	,CESS_AMT = isnull(sum((case when typ = 'COMP CESS PAYABLE' then new_all else 0.00 end)),0.00)
	into #sec6c
	from #sec6c_1 group by goodstype	
	
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6C1','A1','Inputs',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6c where goodstype='Inputs'		

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6C1' AND SRNO ='A1')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6C1','A1','Inputs',0,0,0,0,'',0,0)
	END

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6C2','A2','Capital Goods',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6c where goodstype='Capital Goods'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6C2' AND SRNO ='A2')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6C2','A2','Capital Goods',0,0,0,0,'',0,0)
	END

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6C3','A3','Input Services',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6c where goodstype='Input Services'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6C3' AND SRNO ='A3')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6C3','A3','Input Services',0,0,0,0,'',0,0)
	END
	
	/*D. Inward supplies received from registered persons liable to reverse charge (other than B above) on which tax is paid & ITC availed*/

	select d.goodstype,IGST_AMT = isnull(sum((case when b.typ = 'IGST Payable' then a.new_all else 0.00 end)),0.00)
	,CGST_AMT = isnull(sum((case when b.typ = 'CGST Payable' then a.new_all else 0.00 end)),0.00) 
	,SGST_AMT = isnull(sum((case when b.typ = 'SGST Payable' then a.new_all else 0.00 end)),0.00) 
	,CESS_AMT = isnull(sum((case when b.typ = 'COMP CESS PAYABLE' then a.new_all else 0.00 end)),0.00)
	into #sec6d
	from mainall_vw  a left outer join AC_MAST b on a.Ac_id = b.Ac_id  
	left outer join bpmain c on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd)
	left outer join #gstr9tbl d on (d.entry_ty=a.entry_all and d.tran_cd=a.main_tran)
	where a.entry_ty = 'GB' 
	and b.typ in('CGST Payable','SGST Payable','IGST Payable','COMP CESS PAYABLE') 
	and c.u_cldt between @SDATE and @EDATE
	and a.entry_all<>'UB'
	and ((a.ENTRY_ALL+ quotename(a.Main_tran)) not in (select  a.entry_ty+ quotename(a.Tran_cd)  from #PTEPRCMTBL a LEFT OUTER JOIN shipto c ON (c.shipto_id = a.scons_id) where c.Supp_type in('import','sez','Eou','','Export')) and (a.ENTRY_ALL+ quotename(a.Main_tran)) not in (select  a.entry_ty+ quotename(a.Tran_cd)  from #BPRCM a LEFT OUTER JOIN AC_MAST  c ON (c.Ac_id  = a.Ac_id ) where c.Supp_type in('import','sez','Eou','','Export')))
	group by d.goodstype
	
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6D1','A1','Inputs',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6d where goodstype='Inputs'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6D1' AND SRNO ='A1')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6D1','A1','Inputs',0,0,0,0,'',0,0)
	END

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6D2','A2','Capital Goods',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6d where goodstype='Capital Goods'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6D2' AND SRNO ='A2')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6D2','A2','Capital Goods',0,0,0,0,'',0,0)
	END

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6D3','A3','Input Services',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6d where goodstype='Input Services'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6D3' AND SRNO ='A3')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6D3','A3','Input Services',0,0,0,0,'',0,0)
	END

	/*E. Import of goods (including supplies from SEZs)*/	

	SELECT goodstype
	,IGST_AMT =isnull(SUM(Case when mEntry in('PT','CN') then +IGST_AMT else -(IGST_AMT) end),0.00)
	,cgst_amt=0.00,sgst_amt=0.00
	,CESS_AMT =isnull(SUM(Case when mEntry in('PT','CN') then +CESS_AMT else -(CESS_AMT) end),0.00)
	into #sec6e 
	FROM #GSTR9TBL WHERE mEntry IN('PT','PR','CN','DN') 
	AND Isservice  ='GOODS'
	AND ((st_type ='OUT OF COUNTRY' AND SUPP_TYPE IN('IMPORT','')) OR ( st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE IN('SEZ','IMPORT','EOU','EXPORT'))) 
	AND AGAINSTGS in('','PURCHASES','GOODS')  
	and isnull(ITCSEC,'') = ''
	group by goodstype
		
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6E1','A1','Inputs',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6e where goodstype='Inputs'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6E1' AND SRNO ='A1')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6E1','A1','Inputs',0,0,0,0,'',0,0)
	END

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6E2','A2','Capital Goods',0,sgst_amt,cgst_amt,igst_amt,'',0,cess_amt
	from #sec6e where goodstype='Capital Goods'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6E2' AND SRNO ='A2')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6E2','A2','Capital Goods',0,0,0,0,'',0,0)
	END

	/*F. Import of services (excluding inward supplies from SEZs)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	Select 6,'6F','A','',0.00,sgst_amt=0.00,cgst_amt=0.00,IGST_AMT = isnull(sum((case when b.typ = 'IGST Payable' then a.new_all else 0.00 end)),0.00)
	,'',0
	,CESS_AMT = isnull(sum((case when b.typ = 'COMP CESS PAYABLE' then a.new_all else 0.00 end)),0.00)
	from mainall_vw  a left outer join AC_MAST b on a.Ac_id = b.Ac_id  
	left outer join bpmain c on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd)
	where a.entry_ty = 'GB' 
	and c.u_cldt between @SDATE and @EDATE
	and b.typ in('CGST Payable','SGST Payable','IGST Payable','COMP CESS PAYABLE') 
	and ((a.ENTRY_ALL+ quotename(a.Main_tran))  in (select  a.entry_ty+ quotename(a.Tran_cd)  
														from #PTEPRCMTBL a LEFT OUTER JOIN shipto c ON (c.shipto_id = a.scons_id) 
														where c.Supp_type in('import','Eou','','Export')) 
	or  (a.ENTRY_ALL+ quotename(a.Main_tran)) in (select  a.entry_ty+ quotename(a.Tran_cd)  
														from #BPRCM a LEFT OUTER JOIN AC_MAST  c ON (c.Ac_id  = a.Ac_id ) 
														where c.Supp_type in('import','Eou','','Export')))
	
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6F' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6F','A','',0,0,0,0,'',0,0)
	END

	/*G. Input Tax credit received from ISD*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	select 6,'6G','A','',0.00
	,SGST_AMT=ISNULL(SUM(A.SGST_AMT),0)
	,CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
	,IGST_AMT=ISNULL(SUM(A.IGST_AMT),0),'',0
	,CESS_AMT=ISNULL(SUM(A.COMPCESS),0)
	--SGST_AMT=isnull(SUM(Case when a.entry_ty in('PT','CN') then +IGST_AMT else -(IGST_AMT) end),0.00)
	--isnull(SUM(Case when mEntry in('PT','CN') then +IGST_AMT else -(IGST_AMT) end),0.00)
	from JVITEM a left outer join JVMAIN b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
	WHERE A.entry_ty IN('J6','J8') AND (A.date BETWEEN @SDATE AND @EDATE)
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6G' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6G','A','',0,0,0,0,'',0,0)
	END

	/*H. Amount of ITC reclaimed (other than B above) under the provisions of the Act*/
	--Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	--select 6,'6H','A','',0.00,SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
	--,IGST_AMT=ISNULL(SUM(A.IGST_AMT),0),'',0,CESS_AMT=ISNULL(SUM(A.COMPCESS),0) 
	--from JVMAIN A WHERE A.entry_ty ='J7' AND  (A.date BETWEEN @SDATE AND @EDATE) 

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6H' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6H','A','',0,0,0,0,'',0,0)
	END

	/*I. Sub-total (B to H above)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 6 AS PART ,'6I' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PART IN (6) AND PARTSR IN ('6B1','6B2','6B3','6C1','6C2','6C3','6D1','6D2','6D3','6E1','6E2','6F','6G','6H')	
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6I' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6I','A','',0,0,0,0,'',0,0)
	END

	/*J. Difference (I - A above)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	SELECT 6,'6J','A','',0.00,SGST_AMT =isnull(SUM(Case when PARTSR in('6I') then +SGST_AMT else -(SGST_AMT) end),0.00)
	,CGST_AMT =isnull(SUM(Case when PARTSR in('6I') then +CGST_AMT else -(CGST_AMT) end),0.00)	
	,IGST_AMT =isnull(SUM(Case when PARTSR in('6I') then +IGST_AMT else -(IGST_AMT) end),0.00)
	,'',0
	,CESS_AMT =isnull(SUM(Case when PARTSR in('6I') then +CESS_AMT else -(CESS_AMT) end),0.00)
	FROM #GSTR9 WHERE PART IN (6) AND PARTSR IN ('6I','6A')
		
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6J' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6J','A','',0,0,0,0,'',0,0)
	END

	/*K. Transition Credit through TRAN-I (including revisions if any)*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6K' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6K','A','',0,0,0,0,'',0,0)
	END

	/*L. Transition Credit through TRAN-II*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6L' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6L','A','',0,0,0,0,'',0,0)
	END

	/*M. Any other ITC availed but not specified above*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6M' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6M','A','',0,0,0,0,'',0,0)
	END

	/*N. Sub-total (K to M above)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 6 AS PART ,'6N' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PART IN (6) AND PARTSR IN ('6K','6L','6M')	
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6N' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6N','A','',0,0,0,0,'',0,0)
	END

	/*O. Total ITC availed (I + N above)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 6 AS PART ,'6O' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PART IN (6) AND PARTSR IN ('6I','6N')

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '6O' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(6,'6O','A','',0,0,0,0,'',0,0)
	END

	/*7. Details of ITC Reversed and Ineligible ITC as declared in returns filed during the financial year*/
	/*A. As per Rule 37*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	select 7,'7A','A','',0.00,SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
	,IGST_AMT=ISNULL(SUM(A.IGST_AMT),0),'',0,CESS_AMT=ISNULL(SUM(A.COMPCESS),0) 
	from JVMAIN A WHERE A.entry_ty ='J7' 
	and A.RevsType LIKE '%rule 37%'  
	AND  (A.date BETWEEN @SDATE AND @EDATE) 
	and A.RRGST='INPUT TAX'
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7A' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7A','A','',0,0,0,0,'',0,0)
	END

	/*B. As per Rule 39*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	select 7,'7B','A','',0.00,SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
	,IGST_AMT=ISNULL(SUM(A.IGST_AMT),0),'',0,CESS_AMT=ISNULL(SUM(A.COMPCESS),0) 
	from JVMAIN A WHERE A.entry_ty ='J7' 
	and A.RevsType LIKE '%rule 39%'
	AND  (A.date BETWEEN @SDATE AND @EDATE) 
	and A.RRGST='INPUT TAX'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7B' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7B','A','',0,0,0,0,'',0,0)
	END

	/*C. As per Rule 42*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	select 7,'7C','A','',0.00,SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
	,IGST_AMT=ISNULL(SUM(A.IGST_AMT),0),'',0,CESS_AMT=ISNULL(SUM(A.COMPCESS),0) 
	from JVMAIN A WHERE A.entry_ty ='J7' 
	and A.RevsType LIKE '%rule 42%'
	AND  (A.date BETWEEN @SDATE AND @EDATE) 
	and A.RRGST='INPUT TAX'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7C' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7C','A','',0,0,0,0,'',0,0)
	END

	/*D. As per Rule 43*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	select 7,'7D','A','',0.00,SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
	,IGST_AMT=ISNULL(SUM(A.IGST_AMT),0),'',0,CESS_AMT=ISNULL(SUM(A.COMPCESS),0) 
	from JVMAIN A WHERE A.entry_ty ='J7' 
	and A.RevsType LIKE '%rule 43%'
	AND  (A.date BETWEEN @SDATE AND @EDATE) 
	and A.RRGST='INPUT TAX'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7D' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7D','A','',0,0,0,0,'',0,0)
	END

	/*E. As per section 17(5)*/
	--Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	--select 7,'7E','A','',0.00,SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
	--,IGST_AMT=ISNULL(SUM(A.IGST_AMT),0),'',0,CESS_AMT=ISNULL(SUM(A.COMPCESS),0) 
	--from JVMAIN A WHERE A.entry_ty ='J7' 
	--and A.RevsType LIKE '%17(5)%'
	--AND  (A.date BETWEEN @SDATE AND @EDATE)
	--and A.RRGST='INPUT TAX' 

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7E' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7E','A','',0,0,0,0,'',0,0)
	END

	/*F. Reversal of TRAN-I credit*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7F' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7F','A','',0,0,0,0,'',0,0)
	END

	/*G. Reversal of TRAN-II credit*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7G' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7G','A','',0,0,0,0,'',0,0)
	END

	/*H. Other reversals (pl. specify)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	select 7,'7H','A','',0.00,SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),CGST_AMT = ISNULL(SUM(A.CGST_AMT),0)
	,IGST_AMT=ISNULL(SUM(A.IGST_AMT),0),'',0,CESS_AMT=ISNULL(SUM(A.COMPCESS),0) 
	from JVMAIN A WHERE A.entry_ty ='J7' 
	and A.RevsType = 'OTHERS'
	AND  (A.date BETWEEN @SDATE AND @EDATE) 
	and A.RRGST='INPUT TAX'

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7H' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7H','A','',0,0,0,0,'',0,0)
	END

	/*I. Total ITC Reversed (A to H above)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 7 AS PART ,'7I' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	FROM #GSTR9 WHERE PARTSR IN ('7A','7B','7C','7D','7E','7F','7G','7H')

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7I' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7I','A','',0,0,0,0,'',0,0)
	END

	/*J. Net ITC Available for Utilization (6O - 7I)*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 7 AS PART ,'7J' AS PARTSR,'A' AS SRNO,0.00
	,CGST_AMT =isnull(SUM(Case when PARTSR in('6O') then +CGST_AMT else -(CGST_AMT) end),0.00)	
	,SGST_AMT =isnull(SUM(Case when PARTSR in('6O') then +SGST_AMT else -(SGST_AMT) end),0.00)
	,IGST_AMT =isnull(SUM(Case when PARTSR in('6O') then +IGST_AMT else -(IGST_AMT) end),0.00)
	,CESS_AMT =isnull(SUM(Case when PARTSR in('6O') then +CESS_AMT else -(CESS_AMT) end),0.00)
	FROM #GSTR9 WHERE PARTSR IN ('6O','7I')

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '7J' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(7,'7J','A','',0,0,0,0,'',0,0)
	END

	/*8. Other ITC related information*/
	/*A. ITC as per GSTR-2A (Table 3 & 5 thereof)*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8A' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8A','A','',0,0,0,0,'',0,0)
	END

	/*B. ITC as per sum total of 6(B) and 6(H) above*/
	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	SELECT 8 AS PART ,'8B' AS PARTSR,'A' AS SRNO,sum(taxableamt)taxableamt,sum(CGST_AMT)CGST_AMT,sum(SGST_AMT)SGST_AMT,sum(IGST_AMT)IGST_AMT,sum(cess_amt)cess_amt
	from #gstr9 where partsr in ('6B1','6B2','6B3','6H')

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8B' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8B','A','',0,0,0,0,'',0,0)
	END

	/*C. ITC on inward supplies (other than imports and inward supplies liable to reverse charge but includes services received from SEZs) received during 2017-18 but availed during April to September, 2018*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8C' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8C','A','',0,0,0,0,'',0,0)
	END

	/*D. Difference [A-(B+C)]*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8D' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8D','A','',0,0,0,0,'',0,0)
	END

	/*E. ITC available but not availed (out of D)*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8E' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8E','A','',0,0,0,0,'',0,0)
	END

	/*F. ITC available but ineligible (out of D)*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8F' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8F','A','',0,0,0,0,'',0,0)
	END

	/*G. IGST paid on import of goods (including supplies from SEZ)*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8G' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8G','A','',0,0,0,0,'',0,0)
	END

	/*H. IGST credit availed on import of goods (as per 6(E) above)*/

	Insert Into #GSTR9(PART,PARTSR,SRNO,taxableamt,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt)
	Select 8,'8H','A',0.00,cgst_amt=0.00,sgst_amt=0.00,sum(igst_amt),sum(cess_amt)
	from #sec6e
	/*SELECT 8,'8H','A',0.00,cgst_amt=0.00,sgst_amt=0.00
	,IGST_AMT =isnull(SUM(Case when mEntry in('PT','CN') then +IGST_AMT else -(IGST_AMT) end),0.00)
	,CESS_AMT =isnull(SUM(Case when mEntry in('PT','CN') then +CESS_AMT else -(CESS_AMT) end),0.00)
	FROM #GSTR9TBL WHERE mEntry IN('PT','PR','CN','DN') 
	AND Isservice  ='GOODS'
	AND ((st_type ='OUT OF COUNTRY' AND SUPP_TYPE IN('IMPORT','')) OR ( st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE IN('SEZ','IMPORT','EOU','EXPORT'))) 
	AND AGAINSTGS in('','PURCHASES','GOODS')  
	and isnull(ITCSEC,'') = ''
	*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8H' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8H','A','',0,0,0,0,'',0,0)
	END

	/*I. Difference (G-H)*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8I' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8I','A','',0,0,0,0,'',0,0)
	END

	/*J. ITC available but not availed on import of goods (Equal to I)*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8J' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8J','A','',0,0,0,0,'',0,0)
	END

	/*K. Total ITC to be lapsed in current financial year (E + F + J)*/
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '8K' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(8,'8K','A','',0,0,0,0,'',0,0)
	END
	

	/*Pt. IV 9. Details of tax paid as declared in returns filed during the financial year*/
	DECLARE @IGST_PAY DECIMAL(18,2),@SGST_PAY DECIMAL(18,2),@CGST_PAY DECIMAL(18,2),@cess_PAY DECIMAL(18,2)
	SET @IGST_PAY = 0
	SET @CGST_PAY = 0
	SET @SGST_PAY = 0
	set @cess_PAY = 0 
	
	SELECT a=1,a.ac_id,a.ac_name,a.amount,a.amt_ty,a.entry_ty,a.date,a.u_cldt
	iNTO #TBL1
		FROM lac_vw a
		inner join lmain_vw b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.tran_cd)
		left outer join mainall_vw mv on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd)
		left join lcode l on (a.entry_ty=l.entry_ty)
		WHERE a.ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C')
		and ((case when l.Bcode_nm<>'' then l.Bcode_nm else (case when l.ext_vou=1 then '' else l.entry_ty end) end) not in ('GA','GB','PT','BP','CP') or a.entry_ty in ('RV','UB'))
		and l.entry_ty<>'GA'
		AND (Case when YEAR(a.u_cldt)>2000 then a.u_cldt else a.date end) <= @EDATE
		and (a.entry_ty+QUOTENAME(a.tran_cd)) not in (select (mv.entry_all+quotename(mv.main_tran)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
	UNION ALL
		SELECT a=2,a.ac_id,a.ac_name,a.amount,a.amt_ty
		,a.entry_ty,a.date,a.u_cldt
		FROM jvacdet a
		inner join jvmain b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.tran_cd)
		WHERE a.ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C') 
		and b.entry_ty IN ('GA')
		AND b.U_CLDT <  @SDATE AND YEAR(b.U_CLDT) > 2000
	UNION ALL
		SELECT a=3,a.ac_id,a.ac_name,a.amount,a.amt_ty
		,a.entry_ty,a.date,a.u_cldt
		FROM bpacdet a
		inner join bpmain b on (a.Entry_ty=b.Entry_ty and a.Tran_cd=b.tran_cd)
		WHERE a.ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C','Compensation Cess Payable A/C') 
		and b.entry_ty IN ('GB')
		AND b.date <= @EDATE
		and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
			
	SELECT @IGST_PAY= SUM(CASE WHEN ac_name ='Integrated GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end)  ELSE 0.00 END)
			,@SGST_PAY= SUM(CASE WHEN ac_name ='State GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
			,@CGST_PAY= SUM(CASE WHEN ac_name ='Central GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
			,@cess_PAY= SUM(CASE WHEN ac_name ='Compensation Cess Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
			FROM #TBL1 
 				
	DECLARE @IGST_IGST DECIMAL(18,3),@IGST_CGST DECIMAL(18,3),@IGST_SGST DECIMAL(18,3),@CGST_CGST_ADJ DECIMAL(18,3),@CGST_IGST_Adj  DECIMAL(18,3),@SGST_SGST_ADJ DECIMAL(18,3),@SGST_IGST_Adj DECIMAL(18,3),@CCESS_CCESS_Adj DECIMAL(18,3)
	---IGST ADJUSTMENT 
	SET @IGST_IGST = 0.00 
	SET @IGST_CGST = 0.00 
	SET @IGST_SGST = 0.00
	--- CGST ADJUSTMENT 
	SET @CGST_CGST_ADJ =0.00 
	SET @CGST_IGST_Adj =0.00 
	--- SGST ADJUSTMENT
	SET @SGST_SGST_ADJ = 0.00 
	SET @SGST_IGST_Adj = 0.00
	set @CCESS_CCESS_Adj = 0.00 

	select @IGST_IGST =ISNULL(SUM(IGST_IGST_ADJ),0),@IGST_CGST = ISNULL(SUM(CGST_IGST_Adj),0),@IGST_SGST = ISNULL(SUM(SGST_IGST_Adj),0)
	,@CGST_CGST_ADJ=ISNULL(SUM(CGST_CGST_ADJ),0),@CGST_IGST_Adj=ISNULL(SUM(IGST_CGST_Adj),0)
	---SGST ADJUSTMENT
	,@SGST_SGST_ADJ=ISNULL(SUM(SGST_SGST_ADJ),0),@SGST_IGST_Adj =ISNULL(SUM(IGST_SGST_Adj),0)  
	,@CCESS_CCESS_Adj=ISNULL(SUM(CCESS_CCESS_Adj),0)
	from JVMAIN    where entry_ty = 'GA'  and (u_cldt between @SDATE and @EDATE)
	
	----Interest & Fee Declaration variables 
	DECLARE @IGST_INT DECIMAL(18,2),@SGST_INT DECIMAL(18,2),@CGST_INT DECIMAL(18,2),@IGST_FEE DECIMAL(18,2),@SGST_FEE DECIMAL(18,2),@CGST_FEE DECIMAL(18,2)
	----Interest Payable A/c
	set @IGST_INT = 0
	set @SGST_INT = 0
	set @CGST_INT = 0
	select @IGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE)
	select @CGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE) 
	select @SGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Interest Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE) 
	  
	----Late fee Payable A/c
	set @IGST_FEE = 0
	set @SGST_FEE = 0
	set @CGST_FEE = 0
	select @IGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	select @CGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	select @SGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (b.u_cldt BETWEEN @SDATE AND @EDATE) 
	
	---TAX paid cess  
	DECLARE @IGST_TAX DECIMAL(18,2),@SGST_TAX DECIMAL(18,2),@CGST_TAX DECIMAL(18,2),@CCESS_TAX DECIMAL(18,2)
	set @IGST_TAX = 0
	set @SGST_TAX = 0
	set @CGST_TAX = 0
	SET @CCESS_TAX = 0
	  
	select @IGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
	select @CGST_TAX = isnull(sum(a.amount),0) from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
	select @SGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
	select @CCESS_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Compensation Cess Payable A/C' and a.entry_ty ='GB' AND (B.u_cldt BETWEEN @SDATE AND @EDATE) 
	and (b.entry_ty+QUOTENAME(b.tran_cd)) not in (select (mv.entry_ty+quotename(mv.tran_cd)) from mainall_vw mv inner join bpmain b on (b.entry_ty=mv.entry_ty and b.tran_cd=mv.tran_cd))
	
	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,tax_payable,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,tax_paid_cash)
	VALUES(9,'9A','A','Integrated Tax',@IGST_PAY,@IGST_CGST,@IGST_SGST,@IGST_IGST,0,@IGST_TAX)

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,tax_payable,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,tax_paid_cash)
	VALUES(9,'9B','A','Central Tax',@CGST_PAY,@CGST_CGST_ADJ,0,@CGST_IGST_Adj,0,@CGST_TAX)

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,tax_payable,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,tax_paid_cash)
	VALUES(9,'9C','A','State/UT Tax',@SGST_PAY,0,@SGST_SGST_ADJ,@SGST_IGST_ADJ,0,@SGST_TAX)

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,tax_payable,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,tax_paid_cash)
	VALUES(9,'9D','A','Cess',@CESS_PAY,0,0,0,@CCESS_CCESS_Adj,@CCESS_TAX)

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,tax_payable,tax_paid_cash)
	--VALUES(9,'9E','A','Interest',@CGST_PAY+@SGST_PAY+@IGST_PAY,@CGST_INT+@SGST_INT+@IGST_INT)
	VALUES(9,'9E','A','Interest',0.00,0.00)

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,tax_payable,tax_paid_cash)
	--VALUES(9,'9F','A','Late Fee',@CGST_PAY+@SGST_PAY+@IGST_PAY,@CGST_FEE+@SGST_FEE+@IGST_FEE)
	VALUES(9,'9F','A','Late Fee',0.00,0.00)

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,tax_payable,tax_paid_cash)
	VALUES(9,'9G','A','Penalty',0.00,0.00)

	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,tax_payable,tax_paid_cash)
	VALUES(9,'9H','A','Other',0.00,0.00)
			
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '9A' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(9,'9A','A','Integrated Tax',0,0,0,0,'',0,0)
	END
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '9B' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(9,'9B','A','Central Tax',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '9C' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(9,'9C','A','State/UT Tax',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '9D' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(9,'9D','A','Cess',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '9E' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(9,'9E','A','Interest',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '9F' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(9,'9F','A','Late Fee',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '9G' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(9,'9G','A','Penalty',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '9H' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(9,'9H','A','Other',0,0,0,0,'',0,0)
	END
	
	
	/*Pt. V Particulars of the transactions for the previous FY declared in returns of April to September of current FY or upto date of filing of annual return of previous FY whichever is earlier*/
	/*10. Supplies / tax declared through Amendments (+) (net of debit notes)*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '10' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(10,'10','A','',0,0,0,0,'',0,0)
	END

	/*11. Supplies / tax reduced through Amendments (-) (net of credit notes)*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '11' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(11,'11','A','',0,0,0,0,'',0,0)
	END

	/*12. Reversal of ITC availed during previous financial year*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '12' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(12,'12','A','',0,0,0,0,'',0,0)
	END
	
	/*13. ITC availed for the previous financial year*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '13' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(13,'13','A','',0,0,0,0,'',0,0)
	END

	/*14. Differential tax paid on account of declaration in 10 & 11 above*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '14A' AND SRNO ='A')
	BEGIN		
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(14,'14A','A','Integrated Tax',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '14B' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(14,'14B','A','Central Tax',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '14C' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(14,'14C','A','State/UT Tax',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '14D' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(14,'14D','A','Cess',0,0,0,0,'',0,0)
	END

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '14E' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(14,'14E','A','Interest',0,0,0,0,'',0,0)
	END

	/*Pt. VI Other Information*/
	/*15. Particulars of Demands and Refunds*/

	--IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '15' AND SRNO ='A')
	--BEGIN
	--	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,location,inv_no,date,gro_amt,taxableamt
	--		,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,cess_amt)
	--	VALUES(15,'15','A','','','','',0,0,0,0,0,0,0,0,'','','','',0)
	--END

	/*A. Total Refund claimed*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '15A' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(15,'15A','A','',0,0,0,0,'',0,0)
	END

	/*B. Total Refund sanctioned*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '15B' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(15,'15B','A','',0,0,0,0,'',0,0)
	END

	/*C. Total Refund Rejected*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '15C' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(15,'15C','A','',0,0,0,0,'',0,0)
	END

	/*D. Total Refund Pending*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '15D' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(15,'15D','A','',0,0,0,0,'',0,0)
	END

	/*E. Total demand of taxes*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '15E' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(15,'15E','A','',0,0,0,0,'',0,0)
	END

	/*F. Total taxes paid in respect of E above*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '15F' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(15,'15F','A','',0,0,0,0,'',0,0)
	END

	/*G. Total demands pending out of E above*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '15G' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(15,'15G','A','',0,0,0,0,'',0,0)
	END

	/*16. Information on supplies received from composition taxpayers, deemed supply under section 143 and goods sent on approval basis*/

	--IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '16' AND SRNO ='A')
	--BEGIN
	--	Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
	--	VALUES(16,'16','A','',0,0,0,0,'',0,0)
	--END

	/*A. Supplies received from Composition taxpayers*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '16A' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(16,'16A','A','',0,0,0,0,'',0,0)
	END

	/*B. Deemed supply under Section 143*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '16B' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(16,'16B','A','',0,0,0,0,'',0,0)
	END

	/*C. Goods sent on approval basis but not returned*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '16C' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(16,'16C','A','',0,0,0,0,'',0,0)
	END

	/*17. HSN Wise Summary of outward supplies*/
	select A.*,isnull(B.SERVTCODE,'') as SERVTCODE,B.SERTY INTO #GSTR1TBL_HSN  from #GSTR9TBL A INNER JOIN IT_MAST B  ON (A.IT_CODE=B.IT_CODE)
	where  (A.mentry In('ST','SR','CN','DN','SB')  and entry_ty<>'UB') and A.againstgs in ('SALES','')
    UPDATE #GSTR1TBL_HSN SET SERVTCODE=ISNULL((select top 1 code from sertax_mast  where serty = #GSTR1TBL_HSN.Serty),'')  where isnull(#GSTR1TBL_HSN.SERVTCODE,'') = '' AND Isservice = 'services'

    ---------------------
	Insert into #GSTR9(PART,PARTSR,SRNO,HSNCODE,uqc,totqty,taxableamt,taxrate,CGST_AMT,SGST_AMT,IGST_AMT,Cess_Amt)
		SELECT * FROM (
		  select 17 AS PART ,'17' AS PARTSR,SRNO=row_number() over (order by hsncode,uqc) 
		  ,HSNCODE=(case when Isservice = 'services' then SERVTCODE else HSNCODE end ),uqc
		  ,SUM(CASE WHEN mentry IN('ST','DN','SB') THEN +QTY ELSE -QTY END) AS QTY
          ,SUM(CASE WHEN mentry IN('ST','DN','SB') THEN +Taxableamt ELSE -Taxableamt END)Taxableamt
		  ,gstrate
          ,SUM(CASE WHEN mentry IN('ST','DN','SB') THEN +(ISNULL(CGST_AMT,0)) ELSE -(ISNULL(CGST_AMT,0)) END)CGST_AMT
		  ,SUM(CASE WHEN mentry IN('ST','DN','SB') THEN +(ISNULL(SGST_AMT,0)) ELSE -(ISNULL(SGST_AMT,0)) END)SGST_AMT
		  ,SUM(CASE WHEN mentry IN('ST','DN','SB') THEN +(ISNULL(IGST_AMT,0)) ELSE -(ISNULL(IGST_AMT,0)) END)IGST_AMT
		  ,SUM(CASE WHEN mentry IN('ST','DN','SB') THEN +(ISNULL(CESS_AMT,0)) ELSE -(ISNULL(CESS_AMT,0)) END)CESS_AMT
		FROM #GSTR1TBL_HSN
		WHERE (mentry In('ST','SR','CN','DN','SB') and entry_ty<>'UB')
		and HSNCODE <>'' 
		group by HSNCODE,SERVTCODE,Isservice,uqc,gstrate
		)AA order by srno

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '17')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(17,'17','1','',0,0,0,0,'',0,0)
	END	

	/*18. HSN Wise Summary of inward supplies*/
	select A.*,isnull(B.SERVTCODE,'') as SERVTCODE,B.SERTY INTO #GSTR2TBL_HSN  from #GSTR9TBL A INNER JOIN IT_MAST B  ON (A.IT_CODE=B.IT_CODE)
	where (A.SUPP_TYPE <> 'unregistered' AND (A.mEntry In('PT','PR','CN','DN','EP') OR A.Entry_ty = 'UB')) and A.againstgs in ('PURCHASES','')
    UPDATE #GSTR2TBL_HSN SET SERVTCODE=ISNULL((select top 1 code from sertax_mast  where serty = #GSTR2TBL_HSN.Serty),'')  where isnull(#GSTR2TBL_HSN.SERVTCODE,'') = '' AND Isservice = 'services'

        ---------------------
		Insert into #GSTR9(PART,PARTSR,SRNO,HSNCODE,uqc,totqty,taxableamt,taxrate,CGST_AMT,SGST_AMT,IGST_AMT,Cess_Amt)
		SELECT * FROM (SELECT 18 AS PART ,'18' AS PARTSR,SRNO=row_number() over (order by hsncode,uqc) 
		,HSNCODE=(case when Isservice = 'services' then SERVTCODE else HSNCODE end ),uqc
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +QTY ELSE -QTY END) AS QTY
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +Taxableamt ELSE -Taxableamt END)Taxableamt
		,gstrate
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +(ISNULL(CGST_AMT,0)+ISNULL(CGSRT_AMT,0)) ELSE -(ISNULL(CGST_AMT,0)+ISNULL(CGSRT_AMT,0)) END)CGST_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +(ISNULL(SGST_AMT,0)+ISNULL(SGSRT_AMT,0)) ELSE -(ISNULL(SGST_AMT,0)+ISNULL(SGSRT_AMT,0)) END)SGST_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +(ISNULL(IGST_AMT,0)+ISNULL(IGSRT_AMT,0)) ELSE -(ISNULL(IGST_AMT,0)+ISNULL(IGSRT_AMT,0)) END)IGST_AMT
		,SUM(CASE WHEN (mENTRY IN('PT','CN','EP') or Entry_ty='UB') THEN +(ISNULL(CESS_AMT,0)+ISNULL(CessR_amt,0)) ELSE -(ISNULL(CESS_AMT,0)+ISNULL(CessR_amt,0)) END)CESS_AMT
		FROM #GSTR2TBL_HSN
		WHERE (mEntry IN('PT','PR','CN','DN','EP') or Entry_ty='UB')
		and ltrim(rtrim((case when Isservice = 'services' then SERVTCODE else HSNCODE end ))) <>'' 
		group by HSNCODE,SERVTCODE,Isservice,uqc,gstrate 
		)AA order by srno
		

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '18')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(18,'18','1','',0,0,0,0,'',0,0)
	END
	
	/*19. Late fee payable and paid*/

	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '19A' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(19,'19A','A','Central Tax',0,0,0,0,'',0,0)
	END
	
	IF NOT EXISTS(SELECT PART FROM #GSTR9 WHERE PARTSR = '19B' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR9(PART,PARTSR,SRNO,gstin,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,AC_NAME,StateCode,cess_amt)
		VALUES(19,'19B','A','State Tax',0,0,0,0,'',0,0)
	END

	Update #gstr9 set 
	ac_name = isnull(ac_name,''), gstin = isnull(gstin,''),SUPP_TYPE = isnull(SUPP_TYPE,''),st_type= isnull(st_type,'')
	,StateCode=isnull(StateCode,0), QTY=isnull(QTY,0.00), Taxableamt=isnull(Taxableamt,0.00)
	, CGST_AMT=isnull(CGST_AMT,0.00), SGST_AMT=isnull(SGST_AMT,0.00), IGST_AMT=isnull(IGST_AMT,0.00),Cess_Amt=isnull(Cess_Amt,0.00)
	,tax_payable=isnull(tax_payable,0.00),tax_paid_cash=isnull(tax_paid_cash,0.00)
	,interest=isnull(interest,0.00),penalty=isnull(penalty,0.00),latefee_othrs=isnull(latefee_othrs,0.00)
	,hsncode=isnull(hsncode,''),uqc=isnull(uqc,''),totqty=isnull(totqty,0.00),taxrate=isnull(taxrate,0.00)

	IF ISNULL(@EXPARA,'') = ''
	BEGIN
		SELECT b.*,a.* FROM #GSTR9 a
		inner join gstr9_mast b on (a.partsr=b.section)
		order by PART,partsr ,tran_cd
	END
END