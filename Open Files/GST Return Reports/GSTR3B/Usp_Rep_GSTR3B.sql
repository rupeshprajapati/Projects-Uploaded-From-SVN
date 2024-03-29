IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE ='p' AND NAME ='Usp_Rep_GSTR3B')
BEGIN
	DROP PROCEDURE Usp_Rep_GSTR3B
END
GO 

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
	Author : Suraj Kumawat 
	--Date created : 02-02-2017
	Modify By :  
	Modify Date : 
	set dateformat dmy EXECUTE Usp_Rep_GSTR3B'','','','01/07/2017 ','30/07/2017','','','','',0,0,'','','','','','','','','2017-2018',''
	
*/

Create Procedure [dbo].[Usp_Rep_GSTR3B]
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
	SELECT  PART=0,PARTSR=D.RATE,srno ='A',descr=SPACE(200),D.gro_amt  AS NET_AMT,D.gro_amt AS TAXABLEAMT,D.CGST_AMT,D.SGST_AMT,D.IGST_AMT ,D.IGST_AMT AS CESS_AMT
	,D.IGST_AMT AS TAX_PAID,D.IGST_AMT AS CESS_PAID,D.IGST_AMT AS INTEREST,D.IGST_AMT AS LATE_FEE,LOCATION =SPACE(100),RPT_YEAR=SPACE(25),RPT_MTH=SPACE(25) into #GSTR3B FROM  PTMAIN H INNER JOIN
	PTITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) WHERE 1=2
	Declare @Taxableamt decimal(18,2),@CGST_AMT decimal(18,2),@SGST_AMT decimal(18,2),@IGST_AMT decimal(18,2) ,@CESS_AMT decimal(18,2),@TAX_PAID decimal(18,2),@CESS_PAID decimal(18,2),@INTEREST decimal(18,2), @LATE_FEE decimal(18,2)
	--- Views data in Temporary Table
	SELECT ADJ_TAXABLE =(Taxableamt * RIO),ADJ_CGST_AMT =(CGST_AMT * RIO),ADJ_SGST_AMT =(SGST_AMT * RIO),ADJ_IGST_AMT =(IGST_AMT * RIO),* INTO #GSTR3BTBL FROM GSTR3B_VW   WHERE DATE BETWEEN @SDATE AND @EDATE 
	--- Eligiable or Eneligiable for ITC
	SELECT * INTO #Enelig_REC FROM (select A.DATE,A.ENTRY_TY,A.Pinvno,B.avl,isnull(B.ITCSEC,'') as ITCSEC  from PTMAIN A INNER JOIN PTITEM B ON (A.entry_ty =B.entry_ty AND A.Tran_cd =b.Tran_cd)
	union all 
	select A.DATE,A.ENTRY_TY,A.Pinvno,B.avl,isnull(B.ITCSEC,'') as ITCSEC  from EPMAIN A INNER JOIN EPITEM B ON (A.entry_ty =B.entry_ty AND A.Tran_cd =b.Tran_cd))AA  WHERE ISNULL(ITCSEC,'') <> ''  AND ( DATE BETWEEN @SDATE AND @EDATE ) AND entry_ty IN('PT','P1','E1')
	/* 3.1 Details of Outward Supplies and inward supplies liable to reverse charge*/
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		SELECT @Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +Taxableamt else -Taxableamt end) - ADJ_TAXABLE)
		,@IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT )
		,@CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +CGST_AMT else - CGST_AMT end)- ADJ_CGST_AMT )
		,@SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +SGST_AMT else - SGST_AMT end) - ADJ_SGST_AMT )
		FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR') AND st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE not IN('SEZ','EXPORT','EOU') and LineRule not in('Nill Rated','Exempted')
		and AGAINSTGS in('','SALES','SERVICE INVOICE') and hsncode <> ''  AND (IGST_AMT + CGST_AMT +SGST_AMT ) > 0
		----AND (st_type ='INTRASTATE' OR (st_type ='INTERSTATE' AND SUPP_TYPE not IN('Unregistered','SEZ','Compounding') and UID = '')) and LineRule not in('Nill Rated','Exempted')
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
		VALUES(3,3.1,'A','(a) Outward taxable supplies (other than zero rated,'+char(10)+SPACE(5)+' nil rated and exempted)',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,0,0,0,0,0)
		---(b) Outward taxable supplies (zero rated )
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		SELECT @Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +Taxableamt else -Taxableamt end) - ADJ_TAXABLE)
		,@IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT )
		,@CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +CGST_AMT else - CGST_AMT end)- ADJ_CGST_AMT )
		,@SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +SGST_AMT else - SGST_AMT end) - ADJ_SGST_AMT )
		FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR') and st_type IN('OUT OF COUNTRY','INTERSTATE','INTRASTATE') and SUPP_TYPE IN('Export','SEZ','EOU') AND LineRule not in('Exempted','Nill Rated') and HSNCODE <> '' and AGAINSTGS IN('SALES', 'SERVICE INVOICE','') ----AND (IGST_AMT + CGST_AMT +SGST_AMT )  > 0
		  -----and(( st_type ='OUT OF COUNTRY')  OR(st_type ='INTERSTATE' and SUPP_TYPE IN('Export','SEZ','EOU'))) and uid = ''  AND LineRule not in('Exempted','Nill Rated') and HSNCODE <> '' and AGAINSTGS IN('SALES', 'SERVICE INVOICE','')
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(3,3.1,'B','(b) Outward taxable supplies (zero rated )',0,@Taxableamt,@CGST_AMT,@sGST_AMT,@IGST_AMT ,0,0,0,0,0)
		---(c) Other outward supplies (Nil rated, exempted)
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		SELECT @Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +Taxableamt else -Taxableamt end) - ADJ_TAXABLE)
		,@IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT )
		,@CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +CGST_AMT else - CGST_AMT end)- ADJ_CGST_AMT )
		,@SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +SGST_AMT else - SGST_AMT end) - ADJ_SGST_AMT )
		FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR')  AND LineRule in('Exempted','Nill Rated') and AGAINSTGS IN('SALES', 'SERVICE INVOICE','') AND HSNCODE <> '' AND (IGST_AMT + CGST_AMT +SGST_AMT )  = 0
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(3,3.1,'C','(c) Other outward supplies (Nil rated, exempted)',0,@Taxableamt,@IGST_AMT,@CGST_AMT,@SGST_AMT ,0,0,0,0,0)
		----(d) Inward supplies (liable to reverse charge)
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
			SELECT @Taxableamt =SUM(Taxableamt)
			,@IGST_AMT =SUM(IGST_AMT)
			,@CGST_AMT =SUM(CGST_AMT ) 
			,@SGST_AMT =SUM(SGST_AMT)
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('UB')
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(3,3.1,'D','(d) Inward supplies (liable to reverse charge)',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT,0,0,0,0,0)
		----(e) Non-GST outward supplies					
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		SELECT @Taxableamt =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +Taxableamt else -Taxableamt end) - ADJ_TAXABLE)
		,@IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT )
		,@CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +CGST_AMT else - CGST_AMT end)- ADJ_CGST_AMT )
		,@SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +SGST_AMT else - SGST_AMT end) - ADJ_SGST_AMT )
		FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','CR','BR') and HSNCODE = '' and AGAINSTGS IN('SALES', 'SERVICE INVOICE','')
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(3,3.1,'E','(e) Non-GST outward supplies',@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,@CESS_AMT,0,0,0,0)

	/* 3.2*/--- Of the supplies shown in 3.1 (a) above, details of inter-State supplies made to unregistered persons, composition taxable persons and UIN holders
		----Supplies made to Unregistered Persons	
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,location )
		 SELECT 3 AS PART,3.2 AS PARTSR,'A' AS SRNO,'Supplies made to Unregistered Persons' AS DESCR, Taxableamt =SUM(Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +Taxableamt else -(Taxableamt + ADJ_TAXABLE) end)
		,CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +CGST_AMT else -CGST_AMT end)-ADJ_CGST_AMT)
		,SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +SGST_AMT else -SGST_AMT end)-ADJ_SGST_AMT)
		,IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +IGST_AMT else -IGST_AMT end)-ADJ_IGST_AMT)
		,CESS_AMT =0.00,location FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR') and uid = ''  AND LineRule not in('Exempted','Nill Rated')  and AGAINSTGS IN('SALES', 'SERVICE INVOICE','')
		 AND st_type ='INTERSTATE' AND  SUPP_TYPE = 'Unregistered' AND gstin = 'Unregistered' AND UID = ''  AND (IGST_AMT + CGST_AMT +SGST_AMT )  > 0 group by location 
		IF NOT EXISTS(SELECT SRNO FROM #GSTR3B WHERE PART = 3 AND PARTSR = 3.2 AND srno = 'A')
		begin
			Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
						VALUES(3,3.2,'A','Supplies made to Unregistered Persons',0,0,0,0,0 ,0,0,0,0,0)
		end
		----Supplies made to Composition Taxable Persons
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,location )
		 SELECT 3 AS PART,3.2 AS PARTSR,'B' AS SRNO,'Supplies made to Composition Taxable Persons' AS DESCR, Taxableamt =SUM(Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +Taxableamt else -(Taxableamt + ADJ_TAXABLE) end)
		,CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +CGST_AMT else -CGST_AMT end)-ADJ_CGST_AMT)
		,SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +SGST_AMT else -SGST_AMT end)- ADJ_SGST_AMT)
		,IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +IGST_AMT else -IGST_AMT end) -ADJ_IGST_AMT )
		,CESS_AMT =0.00,location FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR') and uid = ''  AND LineRule not in('Exempted','Nill Rated') AND (IGST_AMT + CGST_AMT +SGST_AMT )  > 0
		 and AGAINSTGS IN('SALES', 'SERVICE INVOICE','') AND st_type ='INTERSTATE' AND  SUPP_TYPE = 'Compounding' group by location 
		IF NOT EXISTS(SELECT SRNO FROM #GSTR3B WHERE PART = 3 AND PARTSR = 3.2 AND srno = 'B')
		begin
			Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
						VALUES(3,3.2,'B','Supplies made to Composition Taxable Persons',0,0,0,0,0 ,0,0,0,0,0)
		end
		
		----Supplies Supplies made to UIN holders
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT,CESS_AMT,location )
		 SELECT 3 AS PART,3.2 AS PARTSR,'C' AS SRNO,'Supplies Supplies made to UIN holders' AS DESCR, Taxableamt =SUM(Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +Taxableamt else -(Taxableamt + ADJ_TAXABLE) end)
		,CGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +CGST_AMT else -CGST_AMT end) -ADJ_CGST_AMT)
		,SGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +SGST_AMT else -SGST_AMT end)- ADJ_SGST_AMT)
		,IGST_AMT =SUM((Case when Entry_ty in('ST','GD','D6','S1','BR','CR') then +IGST_AMT else -IGST_AMT end)- ADJ_IGST_AMT)
		,CESS_AMT =0.00,location FROM #GSTR3BTBL WHERE ENTRY_TY IN('ST','SR','GC','GD','C6','D6','S1','BR','CR') and uid <> ''  AND LineRule not in('Exempted','Nill Rated')  and AGAINSTGS IN('SALES', 'SERVICE INVOICE','')
		 AND st_type ='INTERSTATE'  AND (IGST_AMT + CGST_AMT +SGST_AMT )  > 0  group by location 
		IF NOT EXISTS(SELECT SRNO FROM #GSTR3B WHERE PART = 3 AND PARTSR = 3.2 AND srno = 'C')
		begin
			Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
						VALUES(3,3.2,'C','Supplies Supplies made to UIN holders',0,0,0,0,0 ,0,0,0,0,0)
		end
		
	/* 4.Eligible ITC*/
		---(A) ITC Available (whether in full or part)
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A','(A) ITC Available (whether in full or part)',0,0,0,0,0 ,0,0,0,0,0)
		---(1) Import of goods
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
			SELECT @Taxableamt =SUM(Case when Entry_ty in('PT','P1','GC') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when Entry_ty in('PT','P1','GC') then +IGST_AMT else -(IGST_AMT ) end)
			,@CGST_AMT =SUM(Case when Entry_ty in('PT','P1','GC') then +CGST_AMT else -(CGST_AMT ) end)
			,@SGST_AMT =SUM(Case when Entry_ty in('PT','P1','GC') then +SGST_AMT else -(SGST_AMT) end)
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('PT','P1','PR','GC','GD') 
			AND ((st_type ='OUT OF COUNTRY' AND SUPP_TYPE IN('SEZ','IMPORT')) OR ( st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE IN('SEZ','IMPORT'))) AND AGAINSTGS in('','PURCHASES','GOODS') 
			and LineRule not in('Nill Rated','Exempted') AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 and isnull(ITCSEC,'') = '' AND (rentry_ty + org_no) NOT IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') <>'')
		    Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(1) Import of goods',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT,0,0,0,0,0)
		---(2) Import of services
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
			SELECT @Taxableamt =SUM(Case when Entry_ty in('E1','C6') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when Entry_ty in('E1','C6') then +IGST_AMT else -(IGST_AMT ) end)
			,@CGST_AMT =SUM(Case when Entry_ty in('E1','C6') then +CGST_AMT else -(CGST_AMT ) end)
			,@SGST_AMT =SUM(Case when Entry_ty in('E1','C6') then +SGST_AMT else -(SGST_AMT) end)
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('E1','C6','D6') 
			AND ((st_type ='OUT OF COUNTRY' AND SUPP_TYPE IN('SEZ','IMPORT')) OR ( st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE IN('SEZ','IMPORT'))) AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')
			and LineRule not in('Nill Rated','Exempted') AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 AND (rentry_ty + org_no) not IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') <> '')

		   Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(2) Import of services',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,0,0,0,0,0)
					
		 ----(3) Inward supplies liable to reverse charge (other than 1 & 2 above)
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
			SELECT @Taxableamt =SUM(Taxableamt)
			,@IGST_AMT =SUM(IGST_AMT)
			,@CGST_AMT =SUM(CGST_AMT ) 
			,@SGST_AMT =SUM(SGST_AMT)
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('UB') AND (Entry_ty + CAST(Tran_cd AS VARCHAR)) IN (SELECT (ENTRY_ALL + CAST(MAIN_TRAN AS VARCHAR)) FROM BPMALL WHERE  Entry_ALL ='UB') 
				 
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(3) Inward supplies liable to reverse charge (other than 1 & 2 above)',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT,0,0,0,0,0)
		-----(4) Inward Supplies  from ISD
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		select @CGST_AMT = ISNULL(SUM(A.CGST_AMT),0),@SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),@IGST_AMT=ISNULL(SUM(A.IGST_AMT),0) from JVITEM a left outer join JVMAIN b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
		WHERE A.entry_ty IN('J6' ,'J8') AND  (A.date BETWEEN @SDATE AND @EDATE)
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(4) Inward supplies from ISD',0,0 ,@CGST_AMT,@SGST_AMT,@IGST_AMT,0,0,0,0,0)
		---(5)ALL OTHER ITC
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
			SELECT @Taxableamt =SUM(Case when Entry_ty in('PT','P1','GC') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +IGST_AMT else -(IGST_AMT ) end)
			,@CGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +CGST_AMT else -(CGST_AMT ) end)
			,@SGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +SGST_AMT else -(SGST_AMT) end)
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6') AND st_type IN('INTRASTATE','INTERSTATE') AND SUPP_TYPE in('Registered','Compounding') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL') 
			and LineRule not in('Nill Rated','Exempted') AND (CGSRT_AMT +SGSRT_AMT + IGSRT_AMT) = 0 and (rentry_ty + org_no) NOT IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') <>'')
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'A',space(4)+'(5) All other ITC',0,0,@CGST_AMT,@SGST_AMT,@IGST_AMT ,0,0,0,0,0)
		-----(B) ITC Reversed					
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'B','(B) ITC Reversed',0,0,0,0,0 ,0,0,0,0,0)
		----(1) As per rules 42 & 43 of CGST Rules
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		select @CGST_AMT = ISNULL(SUM(A.CGST_AMT),0),@SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),@IGST_AMT=ISNULL(SUM(A.IGST_AMT),0) from JVMAIN A WHERE A.entry_ty ='J7' AND  (A.date BETWEEN @SDATE AND @EDATE) and RevsType = 'GST Rules 42 & 43 '
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'B',space(4)+'(1) As per rules 42 & 43 of CGST Rules',0,0,@CGST_AMT,@SGST_AMT,@iGST_AMT ,0,0,0,0,0)
		----(2) Others					
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		select @CGST_AMT = ISNULL(SUM(A.CGST_AMT),0),@SGST_AMT=ISNULL(SUM(A.SGST_AMT),0),@IGST_AMT=ISNULL(SUM(A.IGST_AMT),0) from JVMAIN A WHERE A.entry_ty ='J7' AND  (A.date BETWEEN @SDATE AND @EDATE) and RevsType = 'Others'
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'B',space(4)+'(2) Others',0,0,@CGST_AMT,@SGST_AMT,@IGST_AMT ,0,0,0,0,0)
		----(C) Net ITC Available (A) – (B)
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		SELECT @CGST_AMT =isnull(sum(case when srno = 'A' then +CGST_AMT else -CGST_AMT end),0)
		,@SGST_AMT =isnull(sum(case when srno = 'A' then +SGST_AMT else -SGST_AMT end),0)
		,@IGST_AMT =isnull(sum(case when srno = 'A' then +IGST_AMT else -IGST_AMT end),0)   FROM #GSTR3B WHERE PART = 4 AND PARTSR = 4  and srno IN('A','B') 
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'C','(C) Net ITC Available (A) – (B)',0,0,@CGST_AMT,@SGST_AMT,@IGST_AMT ,0,0,0,0,0)
		----Ineligible ITC
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'D','(D) Ineligible ITC',0,0,0,0,0 ,0,0,0,0,0)
		----As per section 17(5)
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
			SELECT @Taxableamt =SUM(Case when Entry_ty in('PT','P1','GC') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +IGST_AMT else -(IGST_AMT ) end)
			,@CGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +CGST_AMT else -(CGST_AMT ) end)
			,@SGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +SGST_AMT else -(SGST_AMT) end)
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6') AND st_type IN('INTRASTATE','INTERSTATE','OUT OF COUNTRY') AND SUPP_TYPE in('SEZ','IMPORT','Registered','Compounding') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')
			AND (rentry_ty + org_no) IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') = 'Section 17(5)')
			
			Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'D',space(4)+'(1) As per section 17(5)',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,0,0,0,0,0)
		---(2) Others
			SET @Taxableamt =0.00
			SET @CGST_AMT =0.00
			SET @SGST_AMT =0.00
			SET @IGST_AMT =0.00
			SET @CESS_AMT =0.00
			SELECT @Taxableamt =SUM(Case when Entry_ty in('PT','P1','GC') then +Taxableamt else -(Taxableamt) end)
			,@IGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +IGST_AMT else -(IGST_AMT ) end)
			,@CGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +CGST_AMT else -(CGST_AMT ) end)
			,@SGST_AMT =SUM(Case when Entry_ty in('E1','PT','P1','GC','C6') then +SGST_AMT else -(SGST_AMT) end)
			FROM #GSTR3BTBL WHERE ENTRY_TY IN('E1','PT','P1','GC','C6','PR','GD','D6') AND st_type IN('INTRASTATE','INTERSTATE','OUT OF COUNTRY') AND SUPP_TYPE in('IMPORT','SEZ','Registered','Compounding') AND AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL')  
			AND (rentry_ty + org_no) IN(SELECT (Entry_ty + PINVNO) FROM #Enelig_REC  where isnull(ITCSEC,'') = 'Others')
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(4,4,'D',space(4)+'(2) Others',0,@Taxableamt,@CGST_AMT,@SGST_AMT,@IGST_AMT ,0,0,0,0,0)

	/* 5*/
		----From a supplier under composition scheme, Exempt and Nil rated supply
		SET @Taxableamt =0.00
		SET @CGST_AMT =0.00
		SET @SGST_AMT =0.00
		SET @IGST_AMT =0.00
		SET @CESS_AMT =0.00
		SELECT @Taxableamt =SUM(Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +Taxableamt else -(Taxableamt + ADJ_TAXABLE) end)
		,@IGST_AMT =SUM(Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +IGST_AMT else -(IGST_AMT + ADJ_IGST_AMT) end)
		,@CGST_AMT =SUM(Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +CGST_AMT else -(CGST_AMT + ADJ_CGST_AMT) end)
		,@SGST_AMT =SUM(Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +SGST_AMT else -( SGST_AMT + ADJ_SGST_AMT) end)
		FROM #GSTR3BTBL WHERE ENTRY_TY IN('PT','P1','PR','GC','GD','C6','D6','E1','CP','BP') AND st_type in('INTRASTATE','INTERSTATE') and LineRule in('Nill Rated','Exempted') AND (IGST_AMT + SGST_AMT + CGST_AMT) = 0
		and AGAINSTGS in('','PURCHASES','SERVICE PURCHASE BILL') and hsncode <> '' 
		---From a supplier under composition scheme, Exempt and Nil rated supply
		SET @CGST_AMT = 0
		SET @IGST_AMT = 0
		select @IGST_AMT=SUM((Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +(CASE WHEN ST_TYPE = 'INTERSTATE' THEN GRO_AMT ELSE 0.00 END) ELSE -(CASE WHEN ST_TYPE = 'INTERSTATE' THEN GRO_AMT ELSE 0.00 END) END)) ,
		@CGST_AMT =SUM((Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +(CASE WHEN ST_TYPE = 'INTRASTATE' THEN GRO_AMT ELSE 0.00 END) ELSE -(CASE WHEN ST_TYPE = 'INTRASTATE' THEN GRO_AMT ELSE 0.00 END) END))
		from #GSTR3BTBL  where ENTRY_TY IN('PT','P1','PR','GC','GD','C6','D6','E1','CP','BP') AND  st_type in('INTERSTATE','INTRASTATE' ) AND (LineRule IN('Exempted','Nill Rated') OR SUPP_TYPE ='COMPOUNDING') AND HSNCODE <> '' AND AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL','')	
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(5,5,'A','From a supplier under composition scheme, Exempt and Nil rated supply',0,0,@CGST_AMT,0,@IGST_AMT ,0,0,0,0,0)
		SET @CGST_AMT = 0
		SET @IGST_AMT = 0
		select @IGST_AMT=SUM((Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +(CASE WHEN ST_TYPE = 'INTERSTATE' THEN GRO_AMT ELSE 0.00 END) ELSE -(CASE WHEN ST_TYPE = 'INTERSTATE' THEN GRO_AMT ELSE 0.00 END) END)) ,
		@CGST_AMT =SUM((Case when Entry_ty in('PT','P1','GC','C6','E1','BP','CP') then +(CASE WHEN ST_TYPE = 'INTRASTATE' THEN GRO_AMT ELSE 0.00 END) ELSE -(CASE WHEN ST_TYPE = 'INTRASTATE' THEN GRO_AMT ELSE 0.00 END) END))
		from #GSTR3BTBL  where ENTRY_TY IN('PT','P1','PR','GC','GD','C6','D6','E1','CP','BP') AND  st_type in('INTERSTATE','INTRASTATE' )  AND HSNCODE = '' AND AGAINSTGS IN('PURCHASES','SERVICE PURCHASE BILL','')	
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(5,5,'B','Non GST supply',0,0,@CGST_AMT,0,@IGST_AMT,0,0,0,0,0)

	/* 6.1*/
	---- SALES 
	
		DECLARE @IGST_PAY DECIMAL(18,2),@SGST_PAY DECIMAL(18,2),@CGST_PAY DECIMAL(18,2)
		SET @IGST_PAY = 0
		SET @CGST_PAY = 0
		SET @SGST_PAY = 0
		SELECT @IGST_PAY= SUM(CASE WHEN ac_name ='Integrated GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end)  ELSE 0.00 END)
				,@SGST_PAY= SUM(CASE WHEN ac_name ='State GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
				,@CGST_PAY= SUM(CASE WHEN ac_name ='Central GST Payable A/C' THEN (case when amt_ty ='cr'  then + AMOUNT else -AMOUNT  end) ELSE 0.00 END)
				FROM lac_vw WHERE ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C') 
				and entry_ty not in(select entry_ty FROM lac_vw WHERE ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C') AND entry_ty  IN('GA','GB')  and date between @SDATE and @EDATE) AND DATE < = @EDATE 
	---GST adjasutment   
	SET @IGST_AMT = 0
	SET @SGST_AMT = 0
	SET @CGST_AMT = 0
	SELECT @IGST_AMT= SUM((CASE WHEN ac_name ='Integrated GST Payable A/C' THEN AMOUNT ELSE 0.00 END))
				,@SGST_AMT= SUM((CASE WHEN ac_name ='State GST Payable A/C' THEN AMOUNT ELSE 0.00 END))
				,@CGST_AMT= SUM((CASE WHEN ac_name ='Central GST Payable A/C' THEN AMOUNT ELSE 0.00 END) )
		  FROM lac_vw WHERE ac_name IN('Central GST Payable A/C','State GST Payable A/C','Integrated GST Payable A/C') AND entry_ty  IN('GA','GB') and (date between @SDATE and @EDATE)
   ----Interest & Fee Declaration variables 
      DECLARE @IGST_INT DECIMAL(18,2),@SGST_INT DECIMAL(18,2),@CGST_INT DECIMAL(18,2),@IGST_FEE DECIMAL(18,2),@SGST_FEE DECIMAL(18,2),@CGST_FEE DECIMAL(18,2)
	  ----Interest Payable A/c
	  set @IGST_INT = 0
	  set @SGST_INT = 0
	  set @CGST_INT = 0
	  select @IGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Interest Payable A/C' and a.entry_ty ='GB' AND (a.DATE BETWEEN @SDATE AND @EDATE) and b.DepoType ='INTEREST'
	  select @CGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Interest Payable A/C' and a.entry_ty ='GB' AND (a.DATE BETWEEN @SDATE AND @EDATE) and b.DepoType ='INTEREST'
	  select @SGST_INT = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Interest Payable A/C' and a.entry_ty ='GB' AND (a.DATE BETWEEN @SDATE AND @EDATE) and b.DepoType ='INTEREST'
	  ----Late fee Payable A/c
	  set @IGST_FEE = 0
	  set @SGST_FEE = 0
	  set @CGST_FEE = 0
	  select @IGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (a.DATE BETWEEN @SDATE AND @EDATE) and b.DepoType ='Fee'
	  select @CGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (a.DATE BETWEEN @SDATE AND @EDATE) and b.DepoType ='Fee'
	  select @SGST_FEE = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Late Fee Payable A/C' and a.entry_ty ='GB' AND (a.DATE BETWEEN @SDATE AND @EDATE) and b.DepoType ='Fee'
	 ---TAX paid cess  
     DECLARE @IGST_TAX DECIMAL(18,2),@SGST_TAX DECIMAL(18,2),@CGST_TAX DECIMAL(18,2)
	  set @IGST_TAX = 0
	  set @SGST_TAX = 0
	  set @CGST_TAX = 0
	  select @IGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Integrated GST Payable A/C' and a.entry_ty ='GB' AND (a.DATE BETWEEN @SDATE AND @EDATE) and b.DepoType ='Tax'
	  select @CGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='Central GST Payable A/C' and a.entry_ty ='GB' AND (a.DATE BETWEEN @SDATE AND @EDATE) and b.DepoType ='Tax'
	  select @SGST_TAX = isnull(sum(a.amount),0)  from lac_vw a INNER JOIN BPMAIN B ON(A.entry_ty =B.entry_ty AND A.Tran_cd=B.Tran_cd) where a.ac_name ='State GST Payable A/C' and a.entry_ty ='GB' AND (a.DATE BETWEEN @SDATE AND @EDATE) and b.DepoType ='Tax'
	  Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,'A','Integrated Tax',0,@IGST_PAY,0,0,@IGST_AMT ,0,0,@IGST_TAX,@IGST_INT,@IGST_FEE)
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,'B','Central Tax',0,@SGST_PAY,@CGST_AMT,0,0 ,0,0,@CGST_TAX,@CGST_INT,@CGST_FEE)
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,'C','State/UT Tax',0,@CGST_PAY,0,@SGST_AMT,0 ,0,0,@SGST_TAX,@SGST_INT,@SGST_FEE)
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.1,'D','Cess',0,0,0,0,0 ,0,0,0,0,0)

	/* 6.2*/
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.2,'A','TDS',0,0,0,0,0 ,0,0,0,0,0)
		Insert Into #GSTR3B(PART,PARTSR,srno,descr,NET_AMT,TAXABLEAMT,CGST_AMT,SGST_AMT,IGST_AMT ,CESS_AMT,TAX_PAID,CESS_PAID,INTEREST,LATE_FEE)
					VALUES(6,6.2,'B','TCS',0,0,0,0,0 ,0,0,0,0,0)

		UPDATE #GSTR3B SET RPT_YEAR =YEAR(@SDATE),RPT_MTH=DATENAME(MM,@SDATE) 
		SELECT  * FROM #GSTR3B ORDER BY PART,PARTSR,srno

		END
		GO 


