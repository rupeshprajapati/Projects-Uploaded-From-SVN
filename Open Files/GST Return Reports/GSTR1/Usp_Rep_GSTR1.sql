IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE ='p' AND NAME ='Usp_Rep_GSTR1')
BEGIN
	DROP PROCEDURE Usp_Rep_GSTR1
END
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
	Author : Suraj Kumawat
	Date created : 05-06-2017
	-- set dateformat mdy EXECUTE Usp_Rep_GSTR1'','','','06/01/2017','06/30/2017','','','','',0,0,'','','','','','','','','2015-2016',''
	set dateformat dmy EXECUTE Usp_Rep_GSTR1'','','','01/06/2017 ','30/06/2017','','','','',0,0,'','','','','','','','','2017-2018',''
*/
CREATE Procedure [dbo].[Usp_Rep_GSTR1]
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
	SELECT  PART=0,PARTSR='AAAA',SRNO= SPACE(2),H.INV_NO, H.DATE, h.INV_NO as ORG_INVNO, H.DATE AS ORG_DATE, D .QTY, d.u_asseamt AS Taxableamt, d.CGST_PER AS RATE, d.CGST_PER, D.CGST_AMT, d.SGST_PER, D.SGST_AMT, d.IGST_PER,D.IGST_AMT,D.IGST_AMT as Cess_Amt,
						  D.GRO_AMT, IT.IT_NAME, cast(IT.IT_DESC as varchar(250)) as IT_DESC , Isservice=SPACE(150), IT.HSNCODE, 
						  ac_name = cast((CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.Mailname, '') ELSE isnull(ac.ac_name, '') END) as varchar(150)), gstin = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.gstin, '') 
						  ELSE isnull(ac.gstin, '') END), location = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.state, '') ELSE isnull(ac.state, '') END)
						  ,SUPP_TYPE = (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.SUPP_TYPE, '') ELSE isnull(ac.SUPP_TYPE, '') END)
						  ,st_type= (CASE WHEN isnull(H.scons_id, 0) > 0 THEN isnull(shipto.st_type, '') ELSE isnull(ac.st_type, '') END)
						  ,StateCode=space(5),Ecomgstin =space(30),from_srno =space(30),to_srno =space(30),ORG_GSTIN =space(30) ,SBBILLNO=space(50),SBDATE=H.DATE,rptmonth=SPACE(15),rptyear =SPACE(15)
						  into #GSTR1
	FROM  STMAIN H INNER JOIN
						  STITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN
						  IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN
						  shipto ON (shipto.shipto_id = h.scons_id) LEFT OUTER JOIN
						  ac_mast ac ON (h.cons_id = ac.ac_id)  WHERE 1=2

/* GSTR_VW DATA STORED IN TEMPORARY TABLE*/
SELECT * INTO #gstr1tmp FROM GSTR1_VW WHERE (date BETWEEN @SDATE AND @EDATE)
------Percentage wise details  
select * into #GSTR1TBL from (
select *,Taxtype ='',GRO_AMT1 =GRO_AMT,TAXABLEAMT1 =taxableamt,  RATE1 = CGST_PER,CGST_AMT1=CGST_AMT,sGST_AMT1=0,iGST_AMT1=0,cess_amt1 = 0,cgsrt_amt1 = cgsrt_amt,sgsrt_amt1 = 0,igsrt_amt1 = 0  from #gstr1tmp where (cgst_amt + cgsrt_amt ) > 0
UNion all 
select *,Taxtype ='',GRO_AMT1 =0,TAXABLEAMT1 = 0, RATE1 = sGST_PER,CGST_AMT1=0,sGST_AMT1=sGST_AMT,iGST_AMT1=0,cess_amt1 = 0 ,cgsrt_amt1 = 0,sgsrt_amt1 = sgsrt_amt,igsrt_amt1 = 0 from #gstr1tmp where (sgst_amt + sgsrt_amt) > 0
UNion all 
select *,Taxtype ='',GRO_AMT1 =GRO_AMT,TAXABLEAMT1 =taxableamt, RATE1 = iGST_PER,CGST_AMT1=0,sGST_AMT1=0,iGST_AMT1=iGST_AMT,cess_amt1 = 0,cgsrt_amt1 = 0,sgsrt_amt1 = 0,igsrt_amt1 = igsrt_amt from #gstr1tmp where (igst_amt + igsrt_amt) > 0
UNion all 
select *,Taxtype ='',GRO_AMT1 =GRO_AMT,TAXABLEAMT1 =taxableamt,RATE1 = 0,CGST_AMT1=0,sGST_AMT1=0,iGST_AMT1=iGST_AMT,cess_amt1 = 0,cgsrt_amt1 = 0,sgsrt_amt1 = 0,igsrt_amt1 = igsrt_amt from #gstr1tmp where (igst_amt + igsrt_amt + sgst_amt + sgsrt_amt + cgst_amt + cgsrt_amt) = 0 )aa order by date,tran_cd,entry_ty

-----Amended Detail Temp table 
SELECT * INTO #GSTR1AMD1 FROM GSTR1_VW WHERE (AMENDDATE BETWEEN @SDATE AND @EDATE) AND HSNCODE <> ''
select * into #GSTR1AMD from (
select *,Taxtype ='',GRO_AMT1 =GRO_AMT,TAXABLEAMT1 =taxableamt,RATE1 = CGST_PER,CGST_AMT1=CGST_AMT,sGST_AMT1=0,iGST_AMT1=0,cess_amt1 = 0,cgsrt_amt1 = cgsrt_amt,sgsrt_amt1 = 0,igsrt_amt1 = 0  from #GSTR1AMD1 where (cgst_amt + cgsrt_amt ) > 0
UNion all 
select *,Taxtype ='',GRO_AMT1 =0,TAXABLEAMT1 =taxableamt,RATE1 = sGST_PER,CGST_AMT1=0,sGST_AMT1=sGST_AMT,iGST_AMT1=0,cess_amt1 = 0 ,cgsrt_amt1 = 0,sgsrt_amt1 = sgsrt_amt,igsrt_amt1 = 0 from #GSTR1AMD1 where (sgst_amt + sgsrt_amt) > 0
UNion all 
select *,Taxtype ='',GRO_AMT1 =GRO_AMT,TAXABLEAMT1 =taxableamt,RATE1 = iGST_PER,CGST_AMT1=0,sGST_AMT1=0,iGST_AMT1=iGST_AMT,cess_amt1 = 0,cgsrt_amt1 = 0,sgsrt_amt1 = 0,igsrt_amt1 = igsrt_amt from #GSTR1AMD1 where (igst_amt + igsrt_amt) > 0
UNion all 
select *,Taxtype ='',GRO_AMT1 =GRO_AMT,TAXABLEAMT1 =taxableamt,RATE1 = 0,CGST_AMT1=0,sGST_AMT1=0,iGST_AMT1=iGST_AMT,cess_amt1 = 0,cgsrt_amt1 = 0,sgsrt_amt1 = 0,igsrt_amt1 = igsrt_amt from #GSTR1AMD1 where (igst_amt + igsrt_amt + sgst_amt + sgsrt_amt + cgst_amt + cgsrt_amt) = 0 )aa order by date,tran_cd,entry_ty
Declare @amt1 decimal(18,2),@amt2 decimal(18,2),@amt3 decimal(18,2),@amt4 decimal(18,2),@from_srno varchar(30),@to_srno varchar(30)

/* 4. Taxable outward supplies made to registered persons (including UIN-holders) other than supplies covered by Table 6 */ 
/*4A. Supplies other than those (i) attracting reverse charge and (ii) supplies made through e-commerce operator*/
Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
select 4 AS PART ,'4A' AS PARTSR,'A' AS SRNO,gstin,inv_no,date,location,net_amt,rate1,sum(taxableamt1)taxableamt1
,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt ,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE from #GSTR1TBL
where Entry_ty in('ST','S1') and st_type <> 'Out of country' and supp_type IN('Registered','Compounding') and gstin <>'' AND LineRule = 'Taxable' AND HSNCODE <> ''
and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1) = 0 
group by gstin,inv_no,date,location,rate1,net_amt,Taxtype order by date
IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '4A' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,location,inv_no,date,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,cess_amt)
				VALUES(4,'4A','A','','','','',0,0
	,0,0,0,0,0,0,'','','','',0)
END
/*4B. Supplies attracting tax on reverse charge basis*/
Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
	select 4 AS PART ,'4B' AS PARTSR,'A' AS SRNO,gstin,inv_no,date,location,net_amt,rate1,sum(taxableamt1)taxableamt1
	,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT
	,sum(cess_amt1)cess_amt ,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE from #GSTR1TBL
	where Entry_ty in('ST','S1') and st_type <> 'Out of country' and supp_type IN('Registered','Compounding') and gstin <>'' AND LineRule = 'Taxable' AND HSNCODE <> '' 
	and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1) > 0
group by gstin,inv_no,date,location,rate1,net_amt,Taxtype order by date,inv_no,rate1

IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '4B' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(4,'4B','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END
/*4C. Supplies made through e-commerce operator attracting TCS (operator wise, rate wise) */
Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE,Ecomgstin)
	select 4 AS PART ,'4C' AS PARTSR,'A' AS SRNO,EcomgsTin,inv_no,date,location,net_amt,rate1,sum(taxableamt1)taxableamt1
	,sum(CGST_AMT1)CGST_AMT ,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt ,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE,gstin from #GSTR1TBL
	where Entry_ty in('ST','S1') and ecomst_type <> 'Out of country' and supp_type = 'E-Commerce' and EcomgsTin <>'Unregistered' AND LineRule = 'Taxable' AND HSNCODE <> '' 
	and (SGSRT_AMT1 + CGSRT_AMT1  + IGSRT_AMT1) = 0
group by EcomgsTin,gstin,inv_no,date,net_amt,rate1,location,Taxtype order by date,inv_no,rate1

IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '4C' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(4,'4C','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END

/* 5. Taxable outward inter-State supplies to un-registered persons where the invoice value is more than Rs 2.5 lakh */
--- 5A. Outward supplies (other than supplies made through e-commerce operator, rate wise)
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
			,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
		select 5 AS PART ,'5A' AS PARTSR,'A' AS SRNO,gstin,inv_no,date,location,net_amt,rate1,sum(taxableamt1)taxableamt1
		,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt ,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE from #GSTR1TBL
		where Entry_ty in('ST','S1') and st_type = 'InterState' and supp_type = 'UnRegistered' and gstin ='UnRegistered' AND LineRule = 'Taxable' AND HSNCODE <> '' and net_amt >250000
        group by gstin,inv_no,date,location,net_amt,rate1,Taxtype  order by date,INV_NO,rate1   

IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '5A' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(5,'5A','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END
--- 5B. Supplies made through e-commerce operator attracting TCS (operator wise, rate wise) GSTIN of e-commerce operator
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
			,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE,Ecomgstin)
		select 5 AS PART ,'5B' AS PARTSR,'A' AS SRNO,'' as Ecomgstin,inv_no,date,location,net_amt,rate1,sum(taxableamt1)taxableamt1
		,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt ,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE,gstin from #GSTR1TBL
		where Entry_ty in('ST','S1') and ecomst_type = 'InterState' and supp_type = 'E-Commerce' and Ecomgstin In('UnRegistered','') AND LineRule = 'Taxable' AND HSNCODE <> ''  and net_amt >250000
        group by gstin,inv_no,DATE,net_amt,location,rate1,Taxtype  order by date,rate1,gstin
IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '5B' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(5,'5B','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END


/* 	6.Zero rated supplies and Deemed Exports */
  ---6A. Exports
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE,sbbillno,sbdate)
	select 6 AS PART ,'6A' AS PARTSR,'A' AS SRNO,gstin,inv_no,date,location,net_amt,rate1,sum(taxableamt1)taxableamt1
	,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt ,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE,sbbillno,sbdate from #GSTR1TBL
	where Entry_ty in('ST','S1') and st_type = 'Out of Country' and supp_type iN('Export','EOU') 
	--- AND LineRule = 'Taxable' AND HSNCODE <> '' 
    group by gstin,inv_no,date,location,rate1,sbbillno,sbdate,net_amt,Taxtype order by date,inv_no,rate1  

IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '6A' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(6,'6A','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END
---6B. Supplies made to SEZ unit or SEZ Developer
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE,sbbillno,sbdate)
	select 6 AS PART ,'6B' AS PARTSR,'A' AS SRNO,gstin,inv_no,date,location,net_amt,rate1,sum(taxableamt1)taxableamt1
	,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt ,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE,sbbillno,sbdate from #GSTR1TBL
	where Entry_ty in('ST','S1') and st_type iN('Interstate') and supp_type IN('SEZ')  AND LineRule = 'Taxable' AND HSNCODE <> '' 
    group by gstin,inv_no,date,location,rate1,sbbillno,sbdate,net_amt,Taxtype  order by date,inv_no ,rate1
    
IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '6B' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(6,'6B','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END
----6C. Deemed exports
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE,sbbillno,sbdate)
	select 6 AS PART ,'6C' AS PARTSR,'A' AS SRNO,gstin,inv_no,date,location,net_amt,rate1,sum(taxableamt1)taxableamt1
	,sum(CGST_AMT1)CGST_AMT,sum(SGST_AMT1)SGST_AMT,sum(IGST_AMT1)IGST_AMT,sum(cess_amt1)cess_amt ,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE,sbbillno,sbdate from #GSTR1TBL
	where Entry_ty in('ST','S1') and st_type iN('Interstate') and supp_type  in('Export','EOU')  ---AND LineRule = 'Taxable' AND HSNCODE <> '' 
    group by gstin,inv_no,date,location,rate1,sbbillno,sbdate,net_amt,Taxtype  order by date ,rate1  

IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '6C' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(6,'6C','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END
/*7. Taxable supplies (Net of debit notes and credit notes) to unregistered persons other than the supplies covered in Table 5 */
  ---7A. Intra-State supplies
  ---7A (1). Consolidated rate wise outward supplies [including supplies made through e-commerce operator attracting TCS]
    
  	select * into #GSTR17aa from (
	select entry_ty, gstin,inv_no,date,location,net_amt, gro_amt,taxableamt1,rate1,CGST_AMT1,SGST_AMT1,IGST_AMT1,cess_amt1,st_type,supp_type,LineRule,Taxtype,'' as EcomSup   from #GSTR1TBL 
	where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and st_type ='Intrastate' and supp_type ='Unregistered'  AND LineRule = 'Taxable' AND HSNCODE <> '' 
	union all 
	select entry_ty,gstin,inv_no,date,location,net_amt,gro_amt,taxableamt1,rate1,CGST_AMT1,SGST_AMT1,IGST_AMT1,cess_amt1,Ecomst_type,Ecomgstin,LineRule,Taxtype,supp_type from #GSTR1TBL 
	where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and Ecomst_type ='Intrastate' and supp_type ='E-commerce'  AND LineRule = 'Taxable' and Ecomgstin='Unregistered' AND HSNCODE <> '' )aa  

	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
	select 7 AS PART ,'7AA' AS PARTSR,'A' AS SRNO,'' as gstin,'' as inv_no,'' as date,'' as location
	,0 as GRO_AMT
	,rate1,
	 taxableamt =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(taxableamt1)ELSE - (taxableamt1) END ))
	,CGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(CGST_AMT1) ELSE - (CGST_AMT1) END ))
	,SGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(SGST_AMT1) ELSE - (SGST_AMT1) END ))
	,IGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(IGST_AMT1) ELSE - (IGST_AMT1) END ))
	,cess_amt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(cess_amt1) ELSE - (cess_amt1) END ))
	,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE
	from #GSTR17aa where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and st_type ='Intrastate' and supp_type ='Unregistered'
	AND LineRule = 'Taxable' 
    group by rate1,Taxtype order by rate1 
  
IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '7AA' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(7,'7AA','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END
 ----7A (2). Out of supplies mentioned at 7A(1), value of supplies made through e-Commerce Operators attracting TCS (operator wise, rate wise) 
 ---GSTIN of e-commerce operator
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE,ecomgstin)
	select 7 AS PART ,'7AB' AS PARTSR,'B' AS SRNO,'' as gstin1,'' as inv_no,'' as date,'' as location
	,0.00 as GRO_AMT
	,rate1,
	 taxableamt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(taxableamt1)ELSE - (taxableamt1) END ))
	,CGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(CGST_AMT1) ELSE - (CGST_AMT1) END ))
	,SGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(SGST_AMT1) ELSE - (SGST_AMT1) END ))
	,IGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(IGST_AMT1) ELSE - (IGST_AMT1) END ))
	,cess_amt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(cess_amt1) ELSE - (cess_amt1) END ))
	,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE,gstin
	from #GSTR1TBL where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and Ecomst_type ='Intrastate' and EcomgsTin ='Unregistered'
	AND LineRule = 'Taxable'  and SUPP_TYPE = 'E-commerce'
    group by gstin,rate1,Taxtype order by gstin,rate1 
IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '7AB' AND SRNO ='B')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(7,'7AB','B','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END
----7B. Inter-State Supplies where invoice value is upto Rs 2.5 Lakh [Rate wise]
  	select * into #GSTR17ba from (
	select entry_ty, gstin,inv_no,date,location,net_amt, gro_amt,taxableamt1,rate1,CGST_AMT1,SGST_AMT1,IGST_AMT1,cess_amt1,st_type,supp_type,LineRule,Taxtype,'' as EcomSup   from #GSTR1TBL 
	where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and st_type ='Interstate' and supp_type ='Unregistered'  AND LineRule = 'Taxable' AND HSNCODE <> '' 
	union all 
	select entry_ty,gstin,inv_no,date,location,net_amt,gro_amt,taxableamt1,rate1,CGST_AMT1,SGST_AMT1,IGST_AMT1,cess_amt1,Ecomst_type,Ecomgstin,LineRule,Taxtype,supp_type from #GSTR1TBL 
	where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and Ecomst_type ='Interstate' and supp_type ='E-commerce'  AND LineRule = 'Taxable' and Ecomgstin='Unregistered' AND HSNCODE <> '' )aa where net_amt <=250000  


-----7B (1). Place of Supply (Name of State)
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
	  select 7 AS PART ,'7BA' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no, '' as date,location
	,0.00 as GRO_AMT
	,rate1,
	 taxableamt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(taxableamt1)ELSE - (taxableamt1) END ))
	,CGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(CGST_AMT1) ELSE - (CGST_AMT1) END ))
	,SGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(SGST_AMT1) ELSE - (SGST_AMT1) END ))
	,IGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(IGST_AMT1) ELSE - (IGST_AMT1) END ))
	,cess_amt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(cess_amt1) ELSE - (cess_amt1) END ))
	,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE
	from #GSTR17ba where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and st_type ='Interstate' and supp_type ='Unregistered'  AND LineRule = 'Taxable'
    group by rate1,location,Taxtype
   
IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '7BA' AND SRNO ='A')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(7,'7BA','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END
----7B (2). Out of the supplies mentioned in 7B (1), the supplies made through e-Commerce Operators (operator wise,rate wise)
-----GSTIN of e-commerce operator
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE,ecomgstin)
	select 7 AS PART ,'7BB' AS PARTSR,'B' AS SRNO,'' as gstin, '' as inv_no, '' as date,'' as location
	,0.00 as GRO_AMT
	,rate1,
	 taxableamt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(taxableamt1)ELSE - (taxableamt1) END ))
	,CGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(CGST_AMT1) ELSE - (CGST_AMT1) END ))
	,SGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(SGST_AMT1) ELSE - (SGST_AMT1) END ))
	,IGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(IGST_AMT1) ELSE - (IGST_AMT1) END ))
	,cess_amt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(cess_amt1) ELSE - (cess_amt1) END ))
	,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE,gstin as ecomgstin
	from #GSTR1TBL where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and Ecomst_type ='Interstate' and supp_type ='E-commerce'  AND LineRule = 'Taxable' and ecomgstin = 'Unregistered' 
	AND HSNCODE <> '' and net_amt <=250000
    group by rate1,gstin,Taxtype
IF NOT EXISTS(SELECT PART FROM #GSTR1 WHERE PARTSR = '7BB' AND SRNO ='B')
BEGIN
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(7,'7BB','B','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
END
----8. Nil rated, exempted and non GST outward supplies
select * into #Gstr1Tbl1 from (
		select Taxtype,gstin,Entry_ty,Supp_type ,St_type ,linerule,NilAmt =(case when lineRule ='Nill rated'  then GRO_AMT else 0.00 end),ExemAmt =(case when lineRule ='Exempted'  then GRO_AMT else 0.00 end),NonGstAmt =(case when HSNCODE  =' '  then GRO_AMT else 0.00 end)    from #GSTR1TBL  where (lineRule in('Nill rated','Exempted') or HSNCODE = '' ) and st_type in('INTERSTATE','INTRASTATE') AND Entry_ty in('st','s1','gc','c6','gd','d6','sr')
		Union all 
		select Taxtype,EcomgsTin,Entry_ty,Supp_type ,EcomSt_type ,linerule,NilAmt =(case when lineRule ='Nill rated'  then GRO_AMT else 0.00 end),ExemAmt =(case when lineRule ='Exempted'  then GRO_AMT else 0.00 end),NonGstAmt =(case when HSNCODE  =' '  then GRO_AMT else 0.00 end)    from #GSTR1TBL  where (lineRule in('Nill rated','Exempted') or HSNCODE = '' ) and Ecomst_type in('INTERSTATE','INTRASTATE') AND Entry_ty in('st','s1','gc','c6','gd','d6','sr') and Supp_type = 'E-Commerce' )aa 
---8A. Inter-State supplies to registered persons
    set @AMT1 = 0.00 
    set @AMT2 = 0.00
    set @AMT3 = 0.00
	SELECT @AMT1 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(NilAmt) ELSE - (NilAmt) END )),
	@AMT2 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(ExemAmt) ELSE - (ExemAmt) END )) ,
	@AMT3 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(NonGstAmt) ELSE - (NonGstAmt) END )) 
	  FROM  #Gstr1Tbl1 WHERE st_type = 'Interstate' and gstin <>'Unregistered'
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(8,'8','A','','','','','','','','',0,0
	,0,@AMT1,0,@AMT2,0,@AMT3,'8A. Inter-State supplies to registered persons','','','')
-----8B. Intra- State supplies to registered persons
	set @AMT1 = 0.00 
    set @AMT2 = 0.00
    set @AMT3 = 0.00
	SELECT @AMT1 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(NilAmt) ELSE - (NilAmt) END )),
	@AMT2 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(ExemAmt) ELSE - (ExemAmt) END )) ,
	@AMT3 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(NonGstAmt) ELSE - (NonGstAmt) END )) 
	FROM  #Gstr1Tbl1 WHERE st_type = 'Intrastate' and gstin <>'Unregistered'
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(8,'8','B','','','','','','','','',0,0
	,0,@AMT1,0,@AMT2,0,@AMT3,'8B. Intra- State supplies to registered persons','','','')
-----8C. Inter-State supplies to unregistered persons
	set @AMT1 = 0.00 
    set @AMT2 = 0.00
    set @AMT3 = 0.00
	SELECT @AMT1 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(NilAmt) ELSE - (NilAmt) END )),
	@AMT2 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(ExemAmt) ELSE - (ExemAmt) END )) ,
	@AMT3 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(NonGstAmt) ELSE - (NonGstAmt) END )) 
	FROM  #Gstr1Tbl1 WHERE st_type = 'Interstate' and gstin ='Unregistered'
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(8,'8','C','','','','','','','','',0,0
	,0,@AMT1,0,@AMT2,0,@AMT3,'8C. Inter-State supplies to unregistered persons','','','')
-----8D. Intra-State supplies to unregistered persons
	set @AMT1 = 0.00 
    set @AMT2 = 0.00
    set @AMT3 = 0.00
	SELECT @AMT1 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(NilAmt) ELSE - (NilAmt) END )),
	@AMT2 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(ExemAmt) ELSE - (ExemAmt) END )) ,
	@AMT3 =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(NonGstAmt) ELSE - (NonGstAmt) END )) 
	FROM  #Gstr1Tbl1 WHERE st_type = 'Intrastate' and gstin ='Unregistered'
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(8,'8','D','','','','','','','','',0,0
	,0,@AMT1,0,@AMT2,0,@AMT3,'8D. Intra-State supplies to unregistered persons','','','')

----9. Amendments to taxable outward supply details furnished in returns for earlier tax periods in Table 4, 5 and 6 [including debit notes, credit notes, refund vouchers issued during current period and amendments thereof]
	---9A. If the invoice/Shipping bill details furnished earlier were incorrect
    select * into #gstr19AA from (
		---Section (4A)Details
		select  * from #gstr1amd where Entry_ty in('ST','S1') and st_type <> 'Out of country' and supp_type IN('Registered','Compounding') and gstin <>'' AND LineRule = 'Taxable'  
		union all 
		---Section (4B)Details
		select * from #gstr1amd where Entry_ty in('ST','S1') and ecomst_type <> 'Out of country' and supp_type = 'E-Commerce' and EcomgsTin <>'Unregistered' AND LineRule = 'Taxable' 
		union all 
		---Section (5) Details
		select * from #gstr1amd  where Entry_ty in('ST','S1') and st_type = 'InterState' and supp_type = 'UnRegistered' and gstin ='UnRegistered' AND LineRule = 'Taxable'  and net_amt > 250000 
		union all 
		---Section(6A)
		select * from #gstr1amd  where Entry_ty in('ST','S1') and st_type = 'Out of Country' and supp_type iN('Export','EOU')  ----AND LineRule = 'Taxable' 
		---Section(6B)
		union all 
		select * from #gstr1amd where Entry_ty in('ST','S1') and st_type = 'Interstate' and supp_type IN('SEZ')  AND LineRule = 'Taxable' 
		---Section(6C)
		union all 
		select * from #gstr1amd where Entry_ty in('ST','S1') and st_type iN( 'Interstate') and supp_type IN('SEZ','EOU')  AND LineRule = 'Taxable' )aa  order by DATE ,INV_NO
	
	Insert Into #GSTR1(PART,PARTSR,SRNO,ORG_GSTIN,ORG_INVNO,ORG_DATE,gstin,inv_no,date,SBBILLNO,SBDATE,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,Cess_Amt,location,AC_NAME,SUPP_TYPE,ST_TYPE)
	select 9 AS PART,'9AA' AS PARTSR,'A' AS SRNO,GSTIN AS org_gstin,ORG_INVNO,ORG_DATE,GSTIN,INV_NO,DATE,SBBILLNO,SBDATE
	,net_amt,rate1,SUM(taxableamt1)taxableamt1,SUM(CGST_AMT1)CGST_AMT,SUM(SGST_AMT1)SGST_AMT,SUM(IGST_AMT1)IGST_AMT,SUM(cess_amt1)cess_amt,location
	,'' as AC_NAME,'' as SUPP_TYPE,'' as ST_TYPE
	from #gstr19AA  where entry_ty in('ST','S1') GROUP BY ORG_INVNO,ORG_DATE,GSTIN,INV_NO,DATE,SBBILLNO,SBDATE,location,rate1,net_amt,Taxtype ORDER BY DATE,INV_NO 

	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = 9 AND PARTSR = '9AA' AND SRNO = 'A')	
	BEGIN
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(9,'9AA','A','','','','','','','','',0,0
		,0,0,0,0,0,0,'','','','')
	END
	---9B. Debit Notes/Credit Notes/Refund voucher [original]
	Insert Into #GSTR1(PART,PARTSR,SRNO,ORG_GSTIN,ORG_INVNO,ORG_DATE,gstin,inv_no,date,SBBILLNO,SBDATE,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,Cess_Amt,location,AC_NAME,SUPP_TYPE,ST_TYPE)
	select 9 AS PART,'9AB' AS PARTSR,'B' AS SRNO,gstin AS org_gstin,ORG_INVNO,ORG_DATE,GSTIN,INV_NO,DATE,SBBILLNO,SBDATE
	,net_amt ,rate1,SUM(taxableamt1)taxableamt1,SUM(CGST_AMT1)CGST_AMT,SUM(SGST_AMT1)SGST_AMT,SUM(IGST_AMT1)IGST_AMT,SUM(cess_amt1)cess_amt,location
	,'' as AC_NAME,'' as SUPP_TYPE,'' as ST_TYPE
	from #GSTR1TBL  where entry_ty in('C6','D6','GD','GC','RV','SR') GROUP BY ORG_INVNO,ORG_DATE,GSTIN,INV_NO,DATE,SBBILLNO,SBDATE,location,rate1,net_amt,Taxtype ORDER BY DATE,INV_NO 
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART ='9' AND PARTSR = '9AB' AND SRNO = 'B' )
	BEGIN
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(9,'9AB','B','','','','','','','','',0,0
		,0,0,0,0,0,0,'','','','')
	END
	---9C.Debit Notes/Credit Notes/Refund voucher [amendments thereof]
	Insert Into #GSTR1(PART,PARTSR,SRNO,ORG_GSTIN,ORG_INVNO,ORG_DATE,gstin,inv_no,date,SBBILLNO,SBDATE,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,Cess_Amt,location,AC_NAME,SUPP_TYPE,ST_TYPE)
	select 9 AS PART,'9AC' AS PARTSR,'C' AS SRNO,GSTIN AS org_gstin,ORG_INVNO,ORG_DATE,GSTIN,INV_NO,DATE,SBBILLNO,SBDATE
	,net_amt ,rate1,SUM(taxableamt1)taxableamt1,SUM(CGST_AMT1)CGST_AMT,SUM(SGST_AMT1)SGST_AMT,SUM(IGST_AMT1)IGST_AMT,SUM(cess_amt1)cess_amt,location
	,'' as AC_NAME,'' as SUPP_TYPE,'' as ST_TYPE
	from #GSTR1AMD  where entry_ty in('C6','D6','GD','GC','RV','SR') GROUP BY ORG_INVNO,ORG_DATE,GSTIN,INV_NO,DATE,SBBILLNO,SBDATE,location,rate1,net_amt,Taxtype  ORDER BY DATE,INV_NO 
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART ='9' AND PARTSR = '9AC' AND SRNO = 'C' )
	BEGIN
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(9,'9AC','C','','','','','','','','',0,0
		,0,0,0,0,0,0,'','','','')
	END
 -----10. Amendments to taxable outward supplies to unregistered persons furnished in returns for earlier tax periods in Table 7
	---10A. Intra-State Supplies [including supplies made through e-commerce operator attracting TCS] [Rate wise]
  	select * into #GSTR110AA from (
	select entry_ty, gstin,inv_no,date,location,Net_amt,taxableamt1,Rate1  as rate,CGST_AMT1 as CGST_AMT,SGST_AMT1 as SGST_AMT,IGST_AMT1 as IGST_AMT,cess_amt1 as cess_amt,st_type,supp_type,LineRule,Taxtype from #GSTR1AMD
	where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and st_type ='Intrastate' and supp_type ='Unregistered'  AND LineRule = 'Taxable'
	union all 
	select entry_ty, gstin,inv_no,date,location,Net_amt,taxableamt1,Rate1  as rate,CGST_AMT1 as CGST_AMT,SGST_AMT1 as SGST_AMT,IGST_AMT1 as IGST_AMT,cess_amt1 as cess_amt,Ecomst_type,Ecomgstin,LineRule,Taxtype from #GSTR1AMD
	where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and Ecomst_type ='Intrastate' and supp_type ='E-commerce'  AND LineRule = 'Taxable' and Ecomgstin='Unregistered')aa
	
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
	select 10 AS PART ,'10AA' AS PARTSR,'A' AS SRNO,'' as gstin,'' as inv_no,'' as date,'' as location
	,0.00 as Net_amt
	,rate,
	 taxableamt =sum((case when entry_ty in('ST','S1','D6','GD') THEN +(taxableamt1)ELSE - (taxableamt1) END ))
	,CGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(CGST_AMT) ELSE - (CGST_AMT) END ))
	,SGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(SGST_AMT) ELSE - (SGST_AMT) END ))
	,IGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(IGST_AMT) ELSE - (IGST_AMT) END ))
	,cess_amt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(cess_amt) ELSE - (cess_amt) END ))
	,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE
	from #GSTR110AA where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and st_type ='Intrastate' and supp_type ='Unregistered'  AND LineRule = 'Taxable'
    group by rate,Taxtype order by rate 
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = 10 AND PARTSR = '10AA' AND SRNO ='A')
	BEGIN
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(10,'10AA','A','','','','','','','','',0,0
		,0,0,0,0,0,0,'','','','')
	END
	---10A (1). Out of supplies mentioned at 10A, value of supplies made through e-Commerce Operators attracting TCS (operator wise, rate wise)
		---GSTIN of e-commerce operator
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE,ecomgstin)
	select 10 AS PART ,'10AB' AS PARTSR,'B' AS SRNO,'' as gstin1,'' as inv_no,'' as date,'' as location
	,GRO_AMT=sum((case when entry_ty in('ST','S1','D6','GD') THEN +(GRO_AMT)ELSE -(GRO_AMT) END ))
	,rate1,
	 taxableamt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(taxableamt1)ELSE - (taxableamt1) END ))
	,CGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(CGST_AMT1) ELSE - (CGST_AMT1) END ))
	,SGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(SGST_AMT1) ELSE - (SGST_AMT1) END ))
	,IGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(IGST_AMT1) ELSE - (IGST_AMT1) END ))
	,cess_amt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(cess_amt1) ELSE - (cess_amt1) END ))
	,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE,gstin
	from #GSTR1AMD where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and Ecomst_type ='Intrastate' and EcomgsTin ='Unregistered'  AND LineRule = 'Taxable' and supp_type ='E-commerce' 
    group by gstin,rate1,Taxtype order by gstin,rate1 
	if not exists(select srno from #GSTR1 where part = 10 and partsr = '10AB' and srno='B' )
	begin
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(10,'10AB','B','','','','','','','','',0,0
		,0,0,0,0,0,0,'','','','')
	end
	-----10B. Inter-State Supplies [including supplies made through e-commerce operator attracting TCS] [Rate wise]
  	select * into #GSTR110BA from (
	select entry_ty, gstin,inv_no,date,location,Net_amt,taxableamt1,Rate1 ,CGST_AMT1,SGST_AMT1,IGST_AMT1,cess_amt1,st_type,supp_type,LineRule,Taxtype from #GSTR1AMD
	where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and st_type ='Interstate' and supp_type ='Unregistered'  AND LineRule = 'Taxable' and net_amt <=250000
	union all 
	select entry_ty, gstin,inv_no,date,location,Net_amt,taxableamt1,Rate1,CGST_AMT1,SGST_AMT1,IGST_AMT1,cess_amt1,st_type,Ecomgstin,LineRule,Taxtype from #GSTR1AMD
	where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and Ecomst_type ='Interstate' and supp_type ='E-commerce'  AND LineRule = 'Taxable' and Ecomgstin='Unregistered' and net_amt <=250000 )aa
	
	--Place of Supply (Name of State)
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
	  select 10 AS PART ,'10BA' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no, '' as date,location
	,0.00 AS GRO_AMT
	,rate1,
	 taxableamt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(taxableamt1)ELSE - (taxableamt1) END ))
	,CGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(CGST_AMT1) ELSE - (CGST_AMT1) END ))
	,SGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(SGST_AMT1) ELSE - (SGST_AMT1) END ))
	,IGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(IGST_AMT1) ELSE - (IGST_AMT1) END ))
	,cess_amt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(cess_amt1) ELSE - (cess_amt1) END ))
	,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE
	from #GSTR110BA where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and st_type ='Interstate'
    group by rate1,location,Taxtype
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = 10 AND PARTSR = '10BA' AND SRNO='A')
	BEGIN
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(10,'10BA','A','','','','','','','','',0,0
		,0,0,0,0,0,0,'','','','')
	END
	----10B (1). Out of supplies mentioned at 10B, value of supplies made through e-Commerce Operators attracting TCS (operator wise, rate wise)
	 ----GSTIN of e-commerce operator
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
	,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE,ecomgstin)
	 select 10 AS PART ,'10BB' AS PARTSR,'B' AS SRNO,'' as gstin, '' as inv_no, '' as date,'' as location
	,0.00 as net_amt 
	,rate1,
	 taxableamt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(taxableamt1)ELSE - (taxableamt1) END ))
	,CGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(CGST_AMT1) ELSE - (CGST_AMT1) END ))
	,SGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(SGST_AMT1) ELSE - (SGST_AMT1) END ))
	,IGST_AMT = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(IGST_AMT1) ELSE - (IGST_AMT1) END ))
	,cess_amt = sum((case when entry_ty in('ST','S1','D6','GD') THEN +(cess_amt1) ELSE - (cess_amt1) END ))
	,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE,gstin as ecomgstin
	from #GSTR1AMD where Entry_ty in('st','s1','gc','c6','gd','d6','sr') and Ecomst_type ='Interstate' and supp_type ='E-commerce'  AND LineRule = 'Taxable' and ecomgstin = 'Unregistered'
	AND net_amt <= 250000  group by rate1,gstin,Taxtype  order by GSTIN,rate1
	 
	 IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = 10 AND PARTSR = '10BB' AND SRNO='B')
		BEGIN
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
			,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
						VALUES(10,'10BB','B','','','','','','','','',0,0
			,0,0,0,0,0,0,'','','','')
		END	
	-----11. Consolidated Statement of Advances Received/Advance adjusted in the current tax period/ Amendments of information furnished in earlier tax period
        ---I Information for the current tax period
	 SELECT * INTO #BkRecDet FROM 
		(SELECT ENTRY_TY,TRAN_CD,DATE,DATE_ALL ,ENTRY_ALL ,MAIN_TRAN  FROM STMALL 
		UNION ALL 
		SELECT ENTRY_TY,TRAN_CD,DATE,DATE_ALL ,ENTRY_ALL ,MAIN_TRAN FROM SBMALL)AA WHERE AA.entry_ty IN('ST','S1') and AA.date between @SDATE and @EDATE 
          -----11A. Advance amount received in the tax period for which invoice has not been issued (tax amount to be added to output tax liability)
           -----11A (1). Intra-State supplies (Rate Wise)
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
		 select 11 AS PART ,'11AA' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no, '' as date,location,0.00 AS net_amt 
		,rate1,taxableamt = sum(Gro_amt1),CGST_AMT = sum(CGST_AMT1),SGST_AMT = sum(SGST_AMT1),IGST_AMT = sum(IGST_AMT1),cess_amt = sum(cess_amt1)
		,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE
		from #GSTR1TBL where Entry_ty in('BR','CR') and st_type ='Intrastate' AND (ENTRY_TY+CAST(TRAN_CD AS VARCHAR)) NOT IN(SELECT (ENTRY_ALL+CAST(MAIN_TRAN AS VARCHAR))  FROM #BkRecDet where DATE BETWEEN @SDATE AND @EDATE )
		group by rate1,location,Taxtype order by Rate1,location
           
		IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = 11 AND PARTSR ='11AA' AND SRNO = 'A')
		BEGIN
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(11,'11AA','A','','','','','','','','',0,0
		,0,0,0,0,0,0,'','','','')
	   END
      ---- 11A (2). Inter-State Supplies (Rate Wise)
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
		 select 11 AS PART ,'11AB' AS PARTSR,'B' AS SRNO,'' as gstin, '' as inv_no, '' as date,location,0.00 AS nET_AMT
		,rate1,taxableamt = sum(Gro_amt1),CGST_AMT = sum(CGST_AMT1),SGST_AMT = sum(SGST_AMT1),IGST_AMT = sum(IGST_AMT1),cess_amt = sum(cess_amt1)
		,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE
		from #GSTR1TBL where Entry_ty in('BR','CR') and st_type ='Interstate' AND (ENTRY_TY+CAST(TRAN_CD AS VARCHAR)) NOT IN(SELECT (ENTRY_ALL+CAST(MAIN_TRAN AS VARCHAR))  FROM #BkRecDet where DATE BETWEEN @SDATE AND @EDATE)
		group by rate1,location,Taxtype order by Rate1,location
		
		IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = 11 AND PARTSR ='11AB' AND SRNO = 'B')
			BEGIN
				Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
				,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(11,'11AB','B','','','','','','','','',0,0
			,0,0,0,0,0,0,'','','','')
		End
	-----11B. Advance amount received in earlier tax period and adjusted against the supplies being shown in this tax period in Table Nos. 4, 5, 6 and 7
		select *  into #EarlierBkDtl from (SELECT     H.Entry_ty, H.Tran_cd, H.INV_NO, H.DATE, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT,D.GRO_AMT,location = h.GSTState,ac.SUPP_TYPE,st_type= ac.st_type,h.net_amt,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT
					FROM BRMAIN H INNER JOIN BRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
					IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN  ac_mast ac ON (h.Ac_id = ac.ac_id)  
		WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='BR'
		union all 
		SELECT     H.Entry_ty, H.Tran_cd, H.INV_NO, H.DATE, d.AMTEXCGST AS Taxableamt, d .CGST_PER, D .CGST_AMT, d .SGST_PER, D .SGST_AMT, d .IGST_PER, D .IGST_AMT,D.GRO_AMT,location = h.GSTState,ac.SUPP_TYPE,st_type= ac.st_type,h.net_amt,D.CGSRT_AMT,D.SGSRT_AMT,D.IGSRT_AMT  
					FROM CRMAIN H INNER JOIN CRITEM D ON (H.ENTRY_TY = D .ENTRY_TY AND H.TRAN_CD = D .TRAN_CD) INNER JOIN 
					IT_MAST IT ON (D .IT_CODE = IT.IT_CODE) LEFT OUTER JOIN  ac_mast ac ON (h.Ac_id = ac.ac_id)  
		WHERE H.TDSPAYTYPE = 2 AND H.ENTRY_TY ='CR' ) aa where (aa.ENTRY_TY+CAST(aa.TRAN_CD AS VARCHAR)) IN (SELECT (entry_all +CAST(Main_tran AS VARCHAR))  FROM  #BkRecDet where Date_all < @sdate AND ENTRY_ALL IN('BR','CR') and DATE BETWEEN @SDATE AND @EDATE)
		
		SELECT * into #EarlierBkDtl1 FROM (
		 ----- suraj ddd
			select *,Taxtype ='',GRO_AMT1 =GRO_AMT,TAXABLEAMT1 =taxableamt,RATE1 = CGST_PER,CGST_AMT1=CGST_AMT,sGST_AMT1=0,iGST_AMT1=0,cess_amt1 = 0,cgsrt_amt1 = cgsrt_amt,sgsrt_amt1 = 0,igsrt_amt1 = 0  from #EarlierBkDtl where (cgst_amt + cgsrt_amt ) > 0
			UNion all 
			select *,Taxtype ='',GRO_AMT1 =0,TAXABLEAMT1 =0,RATE1 = sGST_PER,CGST_AMT1=0,sGST_AMT1=sGST_AMT,iGST_AMT1=0,cess_amt1 = 0 ,cgsrt_amt1 = 0,sgsrt_amt1 = sgsrt_amt,igsrt_amt1 = 0 from #EarlierBkDtl where (sgst_amt + sgsrt_amt) > 0
			UNion all 
			select *,Taxtype ='',GRO_AMT1 =GRO_AMT,TAXABLEAMT1 =taxableamt,RATE1 = iGST_PER,CGST_AMT1=0,sGST_AMT1=0,iGST_AMT1=iGST_AMT,cess_amt1 = 0,cgsrt_amt1 = 0,sgsrt_amt1 = 0,igsrt_amt1 = igsrt_amt from #EarlierBkDtl where (igst_amt + igsrt_amt) > 0
			UNion all 
			select *,Taxtype ='',GRO_AMT1 =GRO_AMT,TAXABLEAMT1 =taxableamt,RATE1 = 0,CGST_AMT1=0,sGST_AMT1=0,iGST_AMT1=iGST_AMT,cess_amt1 = 0,cgsrt_amt1 = 0,sgsrt_amt1 = 0,igsrt_amt1 = igsrt_amt from #EarlierBkDtl where (igst_amt + igsrt_amt + sgst_amt + sgsrt_amt + cgst_amt + cgsrt_amt) = 0 )a order by a.date,a.tran_cd,a.entry_ty 
			
	---11B (1). Intra-State Supplies (Rate Wise)
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
		 select 11 AS PART ,'11BA' AS PARTSR,'A' AS SRNO,'' as gstin, '' as inv_no, '' as date,location,0.00 Net_amt
		,rate1,taxableamt = sum(GRO_AMT1),CGST_AMT = sum(CGST_AMT1),SGST_AMT = sum(SGST_AMT1),IGST_AMT = sum(IGST_AMT1),cess_amt = sum(cess_amt1)
		,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE
		from #EarlierBkDtl1 where Entry_ty in('CR','BR') and st_type ='Intrastate'
		group by rate1,location,Taxtype order by Rate1,location

		IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = 11 AND PARTSR ='11BA' AND SRNO = 'A')
			BEGIN
				Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
			,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
						VALUES(11,'11BA','A','','','','','','','','',0,0
			,0,0,0,0,0,0,'','','','')
			End				
	---11B (2). Inter-State Supplies (Rate Wise)
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,inv_no,date,location,gro_amt,rate,taxableamt
		,CGST_AMT,SGST_AMT,IGST_AMT,cess_amt,AC_NAME,SUPP_TYPE,ST_TYPE)
		 select 11 AS PART ,'11BB' AS PARTSR,'B' AS SRNO,'' as gstin, '' as inv_no, '' as date,location,0.00 as net_amt
		,rate1,taxableamt = sum(GRO_AMT1),CGST_AMT = sum(CGST_AMT1),SGST_AMT = sum(SGST_AMT1),IGST_AMT = sum(IGST_AMT1),cess_amt = sum(cess_amt1)
		,'' as AC_NAME,''as SUPP_TYPE,'' as ST_TYPE
		from #EarlierBkDtl1 where Entry_ty in('BR','CR') and st_type ='Interstate'
		group by rate1,location,Taxtype order by Rate1,location
		IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = 11 AND PARTSR ='11BB' AND SRNO = 'B')
			BEGIN
				Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
			,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
						VALUES(11,'11BB','B','','','','','','','','',0,0
			,0,0,0,0,0,0,'','','','')
			eND
	------II Amendment of information furnished in Table No. 11[1] in GSTR-1 statement for earlier tax periods [Furnish revised information]
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(11,'11CA','A','','','','','','','','',0,0
	,0,0,0,0,0,0,'','','','')
	-----12. HSN-wise summary of outward supplies
	Insert into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,inv_no,date,gro_amt,taxableamt,SGST_AMT,CGST_AMT,IGST_AMT,Cess_Amt,qty,AC_NAME,SUPP_TYPE,ST_TYPE,location)
	select 12 AS PART ,'12' AS PARTSR,'A' AS SRNO,'' as gstin,HSNCODE,'' as inv_no,'' as date
	,GRO_AMT=sum((case when entry_ty in('ST') THEN +(GRO_AMT)ELSE -(GRO_AMT) END ))
	,taxableamt =sum((case when entry_ty in('ST') THEN +(TAXABLEAMT)ELSE - (TAXABLEAMT) END ))
	,CGST_AMT = sum((case when entry_ty in('ST') THEN +(CGST_AMT) ELSE - (CGST_AMT) END ))
	,SGST_AMT = sum((case when entry_ty in('ST') THEN +(SGST_AMT) ELSE - (SGST_AMT) END ))
	,IGST_AMT = sum((case when entry_ty in('ST') THEN +(IGST_AMT) ELSE - (IGST_AMT) END ))
	,cess_amt = sum((case when entry_ty in('ST') THEN +(cess_amt) ELSE - (cess_amt) END ))
	,qty = sum((case when entry_ty in('ST') THEN +(qty) ELSE - (qty) END ))
	,'' as AC_NAME,''as SUPP_TYPE,uqc as ST_TYPE ,'' as location
	from #gstr1tmp where Entry_ty in('st','sr') AND HSNCODE <> '' 
    group by HSNCODE,uqc  order by HSNCODE ,uqc 
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = 12 AND PARTSR ='12' AND SRNO = 'A')
	BEGIN
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,SGST_PER,SGST_AMT,CGST_PER,CGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(12,'12','A','','','','','','','','',0,0
		,0,0,0,0,0,0,'','','','')
	end
----13. Documents issued during the tax period
	---1.Invoices for outward supply
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'A' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,1 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Invoices for outward supply(Sales)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	FROM STMAIN WHERE ENTRY_TY IN('ST') and ( date between @sdate and @edate ) GROUP BY INV_SR
	---For Services
	---1.Invoices for outward supply
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'A' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,1 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Invoices for outward supply (Service Invoice)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
    FROM SBMAIN WHERE ENTRY_TY IN('S1') and ( date between @sdate and @edate ) GROUP BY INV_SR
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = '13' AND PARTSR = '13' AND SRNO = 'A')
	BEGIN
		 Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
					VALUES(13,'13','A','','','','','','','','',0,0
		,1,0,0,0,0,0,'Invoices for outward supply','','','','','')
	END 
    -----2 Invoices for inward supply from unregistered person		
    	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'B' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,1 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Invoices for inward supply from unregistered person' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	FROM STMAIN WHERE ENTRY_TY IN('UB') and ( date between @sdate and @edate ) GROUP BY INV_SR
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = '13' AND PARTSR = '13' AND SRNO = 'B')
	BEGIN
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
				VALUES(13,'13','B','','','','','','','','',0,0
	,2,0 ,0,0,0,0,'Invoices for inward supply from unregistered person','','','',@from_srno,@to_srno)
	End
    -----3 Revised Invoice
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
				VALUES(13,'13','C','','','','','','','','',0,0
	,3,0,0,0,0,0,'Revised Invoice','','','')
    -----4 Debit Note
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'D' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,4 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Debit Note (DEBIT NOTE SUPPLY OF GOODS)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	FROM DNMAIN WHERE ENTRY_TY IN('GD') and ( date between @sdate and @edate )  AND AGAINSTGS ='SALES'  GROUP BY INV_SR
	---FOR Services
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'D' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,4 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Debit Note (DEBIT NOTE SUPPLY OF SERVICES)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	FROM DNMAIN WHERE ENTRY_TY IN('D6') and ( date between @sdate and @edate )  AND AGAINSTGS ='SERVICE INVOICE'  GROUP BY INV_SR
	 IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = '13' AND PARTSR = '13' AND SRNO = 'D')
	 BEGIN
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
		VALUES(13,'13','D','','','','','','','','',0,0,4,0,0,0,0,0,'Debit Note','','','','','')
	end
-----5 Credit Note
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'E' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,5 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Credit Note(CREDIT NOTE SUPPLY OF GOODS)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	FROM CNMAIN  WHERE ENTRY_TY IN('GC') and ( date between @sdate and @edate )  AND AGAINSTGS ='SALES' GROUP BY INV_SR
	----- 
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'E' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,5 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Credit Note(CREDIT NOTE SUPPLY OF SERVICES)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	FROM CNMAIN  WHERE ENTRY_TY IN('C6') and ( date between @sdate and @edate ) AND AGAINSTGS ='SERVICE INVOICE' GROUP BY INV_SR
	 IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = '13' AND PARTSR = '13' AND SRNO = 'E')
	 BEGIN
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
				VALUES(13,'13','E','','','','','','','','',0,0,5,0,0,0,0,0,'Credit Note','','','','','')
    end 
    -----6 Receipt voucher
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'F' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,6 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Receipt voucher (BANK RECEIPT)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	 FROM BRMAIN WHERE ENTRY_TY IN('BR') and ( date between @sdate and @edate ) GROUP BY inv_sr 
		----Cash Receipt 
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'F' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,6 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Receipt voucher (CASH RECEIPT)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	FROM BRMAIN WHERE ENTRY_TY IN('CR') and ( date between @sdate and @edate ) GROUP BY inv_sr 
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = '13' AND PARTSR = '13' AND SRNO = 'F')	
	BEGIN
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
					VALUES(13,'13','F','','','','','','','','',0,0
		,6,0,0,0,0,0,'Receipt voucher','','','','','')
	END
    -----7 Payment Voucher
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'G' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,7 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Payment Voucher(BANK PAYMENT)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	 FROM BPMAIN WHERE ENTRY_TY IN('BP') and ( date between @sdate and @edate ) GROUP BY inv_sr
	--------
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'G' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,7 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Payment Voucher(CASH PAYMENT)' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	 FROM BPMAIN WHERE ENTRY_TY IN('CP') and ( date between @sdate and @edate ) GROUP BY inv_sr
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = '13' AND PARTSR = '13' AND SRNO = 'G')	 
	BEGIN
		Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
					VALUES(13,'13','G','','','','','','','','',0,0
		,7,0,0,0,0,0,'Payment Voucher','','','','','')
	END

     -----8 Refund voucher
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'H' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,8 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Refund voucher' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	 FROM BPMAIN WHERE ENTRY_TY IN('RV') and ( date between @sdate and @edate ) GROUP BY inv_sr
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = '13' AND PARTSR = '13' AND SRNO = 'H')	 
	BEGIN
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
					VALUES(13,'13','H','','','','','','','','',0,0
		,8,0,0,0,0,0,'Refund voucher','','','','','')
	END
        -----9 Delivery Challan for job work
        
	Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
	,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode,from_srno,to_srno)
	SELECT 13 AS PART,'13' AS PARTSR,'I' AS SRNO,'' AS gstin,'' AS HSNCODE,'' AS isService,'' AS location,'' AS inv_no,'' AS date,'' AS ORG_INVNO,
	'' AS ORG_DATE,0 AS gro_amt,0 AS taxableamt,9 AS CGST_PER,CGST_AMT =(sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)))
	,0 AS SGST_PER,SGST_AMT =(sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,0 AS IGST_PER,IGST_AMT = (sum((Case when PARTY_NM !='CANCELLED.' then 1 else 0 end)) - sum((Case when PARTY_NM ='CANCELLED.' then 1 else 0 end)))
	,'Delivery Challan for job work' AS AC_NAME,'' AS SUPP_TYPE,'' AS ST_TYPE,'' AS StateCode,from_srno=MIN(inv_no),to_srno = max(inv_no)
	 FROM IIMAIN WHERE ENTRY_TY IN('IL') and ( date between @sdate and @edate ) GROUP BY inv_sr
	 
	IF NOT EXISTS(SELECT SRNO FROM #GSTR1 WHERE PART = '13' AND PARTSR = '13' AND SRNO = 'I')	 
	BEGIN
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(13,'13','I','','','','','','','','',0,0
		,9,0,0,0,0,0,'Delivery Challan for job work','','','')
	END
        -----10 Delivery Challan for supply on approval
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(13,'13','J','','','','','','','','',0,0
		,10,0,0,0,0,0,'Delivery Challan for supply on approval','','','')
        -----11 Delivery Challan in case of liquid gas
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(13,'13','K','','','','','','','','',0,0
		,11,0,0,0,0,0,'Delivery Challan in case of liquid gas','','','')
		-----12 Delivery Challan in cases other than by way of supply (excluding at S no. 9 to 11)
			Insert Into #GSTR1(PART,PARTSR,SRNO,gstin,HSNCODE,isService,location,inv_no,date,ORG_INVNO,ORG_DATE,gro_amt,taxableamt
		,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,AC_NAME,SUPP_TYPE,ST_TYPE,StateCode)
					VALUES(13,'13','L','','','','','','','','',0,0
		,12,0,0,0,0,0,'Delivery Challan in cases other than by way of supply (excluding at S no. 9 to 11)','','','')
	
	update #gstr1 set rptmonth =datename(mm,@SDATE),rptyear =year(@SDATE) 

IF ISNULL(@EXPARA,'') = ''
    BEGIN
		SELECT * FROM #GSTR1 ORDER BY PART,PARTSR,SRNO
	END
ELSE 
	begin 
	---- Below code for Csv file Geration...  
		---Sectiona 4A
		SELECT * INTO #GSTR_CSV FROM #GSTR1 ORDER BY PART,PARTSR,SRNO,date
		SELECT * FROM ( 
		Select 4 as Section,
		'Section ' + ' | ' +  
		'GSTIN/UIN ' + ' | ' +  
		'Invoice No. ' + ' | ' +
		'Invoice Date ' + ' | ' +
		'Invoice Value ' + ' | ' +
		'Rate ' + ' | ' +
		'Taxable value' + ' | ' +
		'Integrated Tax ' + ' | ' +
		'Central Tax ' + ' | ' +
		'State/UT Tax' + ' | ' +
		'Cess' + ' | ' +
		'Place of Supply (Name of State) '   as ColumnDetails
	    UNION ALL 
	    SELECT 4 as Section ,
	    '4A' + ' | '  + 
	    RTRIM(LTRIM(isnull(GSTIN,''))) + ' | '  + 
	    RTRIM(LTRIM(isnull(inv_no,''))) + ' | '  + 
	    CONVERT(VARCHAR,DATE,103) + ' | '  + 
	    CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(CGST_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(SGST_amt,0) AS VARCHAR) + ' | '  + 
		CAST(isnull(cess_amt,0) AS VARCHAR) + ' | '  +
		RTRIM(LTRIM(isnull(Location,''))) 
	    FROM  #GSTR_CSV WHERE PARTSR = '4A' AND SRNO = 'A'
	    UNION ALL 
		---Section 4b
	    SELECT 4 as Section ,
	    '4B' + ' | '  + 
	    RTRIM(LTRIM(isnull(GSTIN,''))) + ' | '  + 
	    RTRIM(LTRIM(isnull(inv_no,''))) + ' | '  + 
	    CONVERT(VARCHAR,DATE,103) + ' | '  + 
	    CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(CGST_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(SGST_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(cess_amt,0) AS VARCHAR) + ' | ' +  
		RTRIM(LTRIM(isnull(Location,''))) 
	    FROM  #GSTR_CSV WHERE PARTSR = '4B' AND SRNO = 'A'
		---4C
	    UNION ALL 
	    SELECT 4 as Section ,
	    '4C' + ' | '  + 
	    RTRIM(LTRIM(isnull(GSTIN,''))) + ' | '  + 
	    RTRIM(LTRIM(isnull(inv_no,''))) + ' | '  + 
	    CONVERT(VARCHAR,DATE,103) + ' | '  + 
	    CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(CGST_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(SGST_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(cess_amt,0) AS VARCHAR) + ' | '   +
		RTRIM(LTRIM(isnull(Location,''))) 
	    FROM  #GSTR_CSV WHERE PARTSR = '4C' AND SRNO = 'A'
	
		---Section 5
		UNION ALL 
		Select '5' as Section,
		'Section ' + ' | ' +  
		'GSTIN/UIN ' + ' | ' +  
		'Place of Supply (Name of State) ' + ' | ' +  
		'Invoice No. ' + ' | ' +
		'Invoice Date ' + ' | ' +
		'Invoice Value ' + ' | ' +
		'Rate ' + ' | ' +
		'Taxable value' + ' | ' +
		'Integrated Tax ' + ' | ' +
		'Cess'   as ColumnDetails
	    UNION ALL 
	    SELECT 5 as Section ,
	    '5A' +' | '  + 
		space(5) +' | '  + 
	    RTRIM(LTRIM(isnull(Location,''))) + ' | '  + 
	    RTRIM(LTRIM(isnull(inv_no,''))) + ' | '  + 
	    CONVERT(VARCHAR,DATE,103) + ' | '  + 
	    CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) + ' | '  + 
		CAST(isnull(cess_amt,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR = '5A' AND SRNO = 'A' 
	    UNION ALL 
	    SELECT 5 as Section ,
	    '5B ' + ' | ' +  
	    RTRIM(LTRIM(isnull(ecomgstin,''))) + ' | '  + 
	    RTRIM(LTRIM(isnull(Location,''))) + ' | '  + 
	    RTRIM(LTRIM(isnull(inv_no,''))) + ' | '  + 
	    CONVERT(VARCHAR,DATE,103) + ' | '  + 
	    CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) + ' | '  + 
		CAST(isnull(cess_amt,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR = '5B' AND SRNO = 'A' 
		UNION ALL 
		----6A
		Select 6 as Section,
		'Section ' + ' | ' +  
		'GSTIN of recipient ' + ' | ' +  
		'Invoice No. ' + ' | ' +
		'Invoice Date ' + ' | ' +
		'Invoice Value ' + ' | ' +
		'Shipping Bill No. of export ' + ' | ' +
		'Shipping Bill Date. of export ' + ' | ' +
		'Rate ' + ' | ' +
		'Integrated Taxable value' + ' | ' +
		'Integrated Tax Amt'  as ColumnDetails
	    UNION ALL 
	    SELECT 6 as Section ,
	    '6A ' + ' | ' +  
		space(2) +' | '  + 
	    RTRIM(LTRIM(isnull(inv_no,''))) + ' | '  + 
	    CONVERT(VARCHAR,DATE,103) + ' | '  + 
	    CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  + 
	    RTRIM(LTRIM(isnull(SBBILLNO,''))) + ' | '  + 
	    CONVERT(VARCHAR,ISNULL(SBDATE,''),103) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR = '6A' AND SRNO = 'A' 
	    UNION ALL 
	    SELECT 6 as Section ,
	    '6B ' + ' | ' +  
		RTRIM(LTRIM(isnull(gstin,''))) + ' | '  + 
	    RTRIM(LTRIM(isnull(inv_no,''))) + ' | '  + 
	    CONVERT(VARCHAR,DATE,103) + ' | '  + 
	    CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  + 
	    RTRIM(LTRIM(isnull(SBBILLNO,''))) + ' | '  + 
	    CONVERT(VARCHAR,ISNULL(SBDATE,''),103) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR = '6B' AND SRNO = 'A' 
	    UNION ALL 
	    SELECT 6 as Section ,
	    '6C ' + ' | ' +  
		RTRIM(LTRIM(isnull(gstin,''))) + ' | '  + 
	    RTRIM(LTRIM(isnull(inv_no,''))) + ' | '  + 
	    CONVERT(VARCHAR,DATE,103) + ' | '  + 
	    CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  + 
	    RTRIM(LTRIM(isnull(SBBILLNO,''))) + ' | '  + 
	    CONVERT(VARCHAR,ISNULL(SBDATE,''),103) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR)
	    FROM  #GSTR_CSV WHERE PARTSR = '6C' AND SRNO = 'A' 
		--- 7a
		Union all
		Select 7 as Section,
		'Section ' + ' | ' +  
		'GSTIN/POS ' + ' | ' +  
		'Rate of Tax ' + ' | ' +
		'Total Taxable Value' + ' | ' +
		'Integrated Amount ' + ' | ' +
		'Central Tax Amount ' + ' | ' +
		'State Tax/UT Tax Amount ' + ' | ' +
		'Cess Amount '  as ColumnDetails
		UNION ALL 
	    SELECT 7 as Section ,
	    '7A(1) ' + ' | ' + 
		space(2) +' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(Cess_Amt,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR = '7AA' AND SRNO = 'A' 
		UNION ALL 
	    SELECT 7 as Section ,
	    '7A(2) ' + ' | ' +  
		CAST(isnull(Ecomgstin,'') AS VARCHAR) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(Cess_Amt,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR = '7AB' AND SRNO = 'B' 
		--- 7b
		UNION ALL 
	    SELECT 7 as Section ,
	    '7B(1)' + + ' | '  + 
		isnull(RTRIM(location),'')  + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(Cess_Amt,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR = '7BA' AND SRNO = 'A' 
		UNION ALL 
	    SELECT '7' as Section ,
	    '7B(2)' + + ' | '  +
		CAST(isnull(Ecomgstin,'') AS VARCHAR) + ' | '  + 
	    CAST(isnull(RATE,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(taxableamt,0) AS VARCHAR) + ' | '  + 
	    CAST(isnull(IGST_amt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(Cess_Amt,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR = '7BB' AND SRNO = 'B' 
		--- 8
		Union all
		Select 8 as Section,
		'Description ' + ' | ' +  
		'Nil Rated Supplies ' + ' | ' +  
		'Exempted(Other than Nil rated/non-GST supply)' + ' | ' +  
		'Non-GST supplies'   as ColumnDetails
		UNION ALL 
	    SELECT 8 as Section ,
		isnull(RTRIM(ac_name),'')  + ' | '  + 
	    CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR = '8'  and SRNO in('A','B','C','D')
		--- 9
		Union all
		Select 9 as Section,
		'Section' + + ' | '  +
		'Original GSTIN' + ' | ' +  
		'Original Inv. No.' + ' | ' +  
		'Original Inv. Date' + ' | ' +  
		'GSTIN' + ' | ' + 
		'Invoice No.' + ' | ' + 
		'Invoice Date.' + ' | ' + 
		'Shipping bill No.' + ' | ' + 
		'Shipping bill Date.' + ' | ' + 
		'Value' + ' | ' + 
		'Rate' + ' | ' + 
		'Taxable Value' + ' | ' + 
		'Integrated Tax' + ' | ' + 
		'Central Tax' + ' | ' + 
		'State/UT Tax' + ' | ' + 
		'Cess' + ' | ' + 
		'Place of supply'   as ColumnDetails
		
		UNION ALL 
	    SELECT 9 as Section ,
	    '9A' + + ' | '  +
		isnull(RTRIM(ORG_GSTIN),'')  + ' | '  + 
		isnull(RTRIM(ORG_INVNO),'')  + ' | '  + 
		CONVERT(VARCHAR,ISNULL(ORG_DATE,'') ,103) + ' | '  + 
		isnull(RTRIM(GSTIN),'')  + ' | '  + 
		isnull(RTRIM(inv_no),'')  + ' | '  + 
		CONVERT(VARCHAR,ISNULL(DATE,'') ,103) + ' | '  + 
		isnull(RTRIM(SBBILLNO),'')  + ' | '  + 
		CONVERT(VARCHAR,ISNULL(SBDATE,'') ,103) + ' | '  + 
		CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  +
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) + ' | '  +
		isnull(RTRIM(Location),'')  
	    FROM  #GSTR_CSV WHERE PARTSR IN('9AA')
		UNION ALL 
	    SELECT 9 as Section ,
	    '9B' + + ' | '  +
		isnull(RTRIM(ORG_GSTIN),'')  + ' | '  + 
		isnull(RTRIM(ORG_INVNO),'')  + ' | '  + 
		CONVERT(VARCHAR,ISNULL(ORG_DATE,'') ,103) + ' | '  + 
		isnull(RTRIM(GSTIN),'')  + ' | '  + 
		isnull(RTRIM(inv_no),'')  + ' | '  + 
		CONVERT(VARCHAR,ISNULL(DATE,'') ,103) + ' | '  + 
		isnull(RTRIM(SBBILLNO),'')  + ' | '  + 
		CONVERT(VARCHAR,ISNULL(SBDATE,'') ,103) + ' | '  + 
		CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  +
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) + ' | '  +
		isnull(RTRIM(Location),'')  
	    FROM  #GSTR_CSV WHERE PARTSR IN('9AB','9AC' )
		UNION ALL 
	    SELECT 9 as Section ,
	    '9C' + + ' | '  +
		isnull(RTRIM(ORG_GSTIN),'')  + ' | '  + 
		isnull(RTRIM(ORG_INVNO),'')  + ' | '  + 
		CONVERT(VARCHAR,ISNULL(ORG_DATE,'') ,103) + ' | '  + 
		isnull(RTRIM(GSTIN),'')  + ' | '  + 
		isnull(RTRIM(inv_no),'')  + ' | '  + 
		CONVERT(VARCHAR,ISNULL(DATE,'') ,103) + ' | '  + 
		isnull(RTRIM(SBBILLNO),'')  + ' | '  + 
		CONVERT(VARCHAR,ISNULL(SBDATE,'') ,103) + ' | '  + 
		CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  +
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) + ' | '  +
		isnull(RTRIM(Location),'')  
	    FROM  #GSTR_CSV WHERE PARTSR IN('9AC' )
		---Section 10
		Union all
		Select 10 as Section,
		'Section' + + ' | '  +
		'GSTIN/POS' + ' | ' +  
		'Rate of Tax' + ' | ' +  
		'Total Taxable Value' + ' | ' + 
		'Integrated Tax' + ' | ' + 
		'Central Tax' + ' | ' + 
		'State/UT Tax' + ' | ' + 
		'Cess '  as ColumnDetails
		UNION ALL 
	    SELECT '10' as Section ,
	    '10A'  + ' | '  + 
		SPACE(2)  + ' | '  + 
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR IN('10AA')
		UNION ALL 
	    SELECT 10 as Section ,
	    '10A(1)'  + ' | '  + 
		isnull(RTRIM(Ecomgstin),'')  + ' | '    + 
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR IN('10AB')
		UNION ALL 
	    SELECT 10 as Section ,
	    '10B'  + ' | '  + 
		isnull(RTRIM(location),'')  + ' | '    + 
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR IN('10BA')
		UNION ALL 
	    SELECT 10 as Section ,
	    '10B(1)'  + ' | '  + 
		isnull(RTRIM(Ecomgstin),'')  + ' | '    + 
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR IN('10BB')
		--- 11
		Union all
		Select 11 as Section,
		'Section' + ' | ' + 
		'Rate' + ' | ' + 
		'Gross Advance Received/adjusted' + ' | ' + 
		'Place of supply(Name of State)' + ' | ' + 
		'Integrated Tax' + ' | ' + 
		'Central Tax' + ' | ' + 
		'State/UT Tax' + ' | ' + 
		'Cess'   as ColumnDetails
		UNION ALL 
	    SELECT '11' as Section ,
	    '11A(1)' + ' | '  +
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
		isnull(RTRIM(Location),'')  + ' | '   +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR IN('11AA')

		UNION ALL 
	    SELECT 11 as Section ,
	    '11A(1)' + ' | '  +
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
		isnull(RTRIM(Location),'')  + ' | '   +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR IN('11AB')

		UNION ALL 
	    SELECT 11 as Section ,
	    '11B(1)' + ' | '  +
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
		isnull(RTRIM(Location),'')  + ' | '   +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR IN('10BA')

		UNION ALL 
	    SELECT 11 as Section ,
	    '11B(2)' + ' | '  +
		CAST(isnull(RATE,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
		isnull(RTRIM(Location),'')  + ' | '   +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR IN('10BB')

		--- 12
		Union all
		Select 12 as Section,
		'HSN' + ' | ' + 
		'Description(Optional if HSN is provided' + ' | ' + 
		'UQC' + ' | ' + 
		'Total Quantity' + ' | ' + 
		'Total Value' + ' | ' + 
		'Gross Advance Received/adjusted' + ' | ' + 
		'Integrated Tax' + ' | ' + 
		'Central Tax' + ' | ' + 
		'State/UT Tax' + ' | ' + 
		'Cess'   as ColumnDetails
		UNION ALL 
	    SELECT 12 as Section ,
		isnull(HSNCODE,'') + ' | '  +
		SPACE(2) + ' | '  +
		isnull(st_TYPE,'') + ' | '  +
		CAST(isnull(qty,0) AS VARCHAR) + ' | '  +
		CAST(isnull(gro_amt,0) AS VARCHAR) + ' | '  +
		CAST(isnull(Taxableamt,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(IGST_AMT,0) AS VARCHAR) + ' | '  +
		CAST(isnull(CGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(SGST_AMT,0) AS VARCHAR) + ' | '  +
	    CAST(isnull(cess_AMT,0) AS VARCHAR) 
	    FROM  #GSTR_CSV WHERE PARTSR IN('12')
		--- 13
		Union all
		Select 13 as Section,
		'Sr. No.' + ' | ' + 
		'Nature of document' + ' | ' + 
		'Sr. No. From' + ' | ' + 
		'To' + ' | ' + 
		'Total number' + ' | ' + 
		'Cancelled' + ' | ' + 
		'Net issued'  as ColumnDetails
		UNION ALL 
	    SELECT 13 as Section ,
		CAST(isnull(cast(CGST_PER as integer) ,0) AS VARCHAR) + ' | '  +
		isnull(rtrim(ac_name),'') + ' | '  +
		isnull(rtrim(from_srno),'') + ' | '  +
		isnull(rtrim(to_srno),'') + ' | '  +
		CAST(isnull(cast(CGST_AMT as integer) ,0) AS VARCHAR) + ' | '  +
		CAST(isnull(cast(sGST_AMT as integer) ,0) AS VARCHAR) + ' | '  +
		CAST(isnull(cast(iGST_AMT as integer) ,0) AS VARCHAR)   
	    FROM  #GSTR_CSV WHERE PARTSR IN('13') )AA ORDER BY Section 
 	   
	End 
END
go 


