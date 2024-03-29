If Exists(Select [name] From SysObjects Where xType='P' and [Name]='USP_REP_OR_VATFORM201')
Begin
	Drop Procedure USP_REP_OR_VATFORM201
End
Go
/*
EXECUTE USP_REP_OR_VATFORM201'','','','04/01/2013','03/31/2016','','','','',0,0,'','','','','','','','','2013-2016',''
*/      

-- =============================================
-- Author:		Hetal L. Patel
-- Create date: 08/07/2009
-- Description:	This Stored procedure is useful to generate OR VAT FORM 201
-- Modify date: 
-- Modified By: GAURAV R. TANNA for the bug-26503
-- Modify date: 14/07/2015
-- Remark:
-- =============================================
CREATE PROCEDURE [dbo].[USP_REP_OR_VATFORM201]
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
AS

BEGIN
DECLARE @FCON AS NVARCHAR(2000)
EXECUTE   USP_REP_FILTCON 

@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE=Null,@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000)
DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)
DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)
DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2)

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

---Temporary Cursor
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=SPACE(500),
STM.FORM_NM,AC1.S_TAX
INTO #FORM201
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		 Set @MultiCo = 'YES'
		 
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT
	End

SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
SET @CHAR=65

Declare @TAXONAMT as numeric(12,2),@TAXAMT1 as numeric(12,2),@ITEMAMT as numeric(12,2),@INV_NO as varchar(10),@DATE as smalldatetime,@PARTY_NM as varchar(50),@ADDRESS as varchar(100),@ITEM as varchar(50),@FORM_NM as varchar(30),@S_TAX as varchar(30),@QTY as numeric(18,4)
Set @Party_nm = ''

--- Part A
--- 05.Input tax credit carried forward from previous tax period. (same as at serial No.55 of the previous return)
DECLARE @STARTDT SMALLDATETIME,@ENDDT SMALLDATETIME,@TMONTH INT,@TYEAR INT
SET @TMONTH=DATEDIFF(M,@SDATE,@EDATE)
SET @TYEAR=DATEDIFF(YY,@SDATE,@EDATE)
SET @STARTDT=DATEADD(Y,-@TYEAR,@STARTDT)
SET @STARTDT=DATEADD(M,-(@TMONTH+1),@SDATE)
SET @ENDDT=DATEADD(D,-1,@SDATE)

select @AMTA1=SUM(A.NET_AMT) FROM JVMAIN A WHERE A.ENTRY_TY='J4' AND A.VAT_ADJ='Excess credit carried forward to  subsequent tax period' AND (A.DATE BETWEEN @STARTDT AND @ENDDT)
SET @AMTA1=ISNULL(@AMTA1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'0','A',0,@AMTA1,0,0,@PARTY_NM)   

--- Part B
-- I. -Within the State (Excluding capital goods & goods meant for sale by transfer of right to use)

---Exempted Purchases
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL Where Bhent In('PT','EP') 
And (Date Between @Sdate And @Edate) And Tax_Name = 'Exempted' And ST_TYPE in ('Local','') And Itemtype <> 'C'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','A',0,@AMTA1,@AMTB1,0,@PARTY_NM)
              
---Purchase At 1% Tax Rate            
Select @AmtA1 = 0,@AmtB1 = 0
--Select @AMTA1=isnulL(Sum(CASE WHEN BHENT IN ('PT', 'EP', 'CN') THEN (gro_Amt-TAXAMT) ELSE ((-1)*(GRO_AMT-TAXAMT)) END),0) ,
--@AMTB1=isnulL(Sum(CASE WHEN BHENT IN ('PT', 'EP', 'CN') THEN (TAXAMT) ELSE ((-1)*(TAXAMT)) END),0) 
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL Where Bhent In('PT','EP') 
And (Date Between @Sdate and @Edate) And Bhent in('PT','EP')  --And Bhent in('PT','EP', 'CN', 'PR', 'DN') 
And ST_TYPE in ('Local','') And Itemtype <> 'C' And Per = 1
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','B',0,@AMTA1,@AMTB1,0,@PARTY_NM)

---Purchase At 2% Tax Rate  
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And ST_TYPE in ('Local','') And Itemtype <> 'C' And Per = 2
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','C',0,@AMTA1,@AMTB1,0,@PARTY_NM)
              
----8
---Purchase At 5% Tax Rate  (i)
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And ST_TYPE in ('Local','') And Itemtype <> 'C' And Per = 5
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','D',0,@AMTA1,@AMTB1,0,@PARTY_NM)     

---Purchase At 5% Tax Rate  (ii) M.R.P.         
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','E',0,0,0,0,@PARTY_NM)                        

---Total (i + ii)=  (iii)              
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','F',0,@AMTA1,@AMTB1,0,@PARTY_NM)   
              
--- (iv) Purchase value of MRP goods at actual purchase price     
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','G',0,0,0,0,@PARTY_NM)                                   


----9A
---Purchase At 13.5% Tax Rate  (i)
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And ST_TYPE in ('Local','') And Itemtype <> 'C' And Per = 13.5
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','H',0,@AMTA1,@AMTB1,0,@PARTY_NM)     

---Purchase At 13.5% Tax Rate  (ii)    m.r.p          
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','I',0,0,0,0,@PARTY_NM)                        

---Total (i + ii)=  (iii)              
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','J',0,@AMTA1,@AMTB1,0,@PARTY_NM)   
              
--- (iv) Purchase value of MRP goods at actual purchase price    
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','K',0,0,0,0,@PARTY_NM)                                   

--- (v) Purchase of goods at 50% tax rate excluding MRP goods on tax invoice
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And ST_TYPE in ('Local','') And Itemtype <> 'C' And Per = 50
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','L',0,@AMTA1,@AMTB1,0,@PARTY_NM)                                   

--- (vi) Purchase of MRP goods at 50% on MRP value on tax invoice
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','M',0,0,0,0,@PARTY_NM) 
              
--- (vii) Total (v) + (vi)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','N',0,@AMTA1,@AMTB1,0,@PARTY_NM) 
   
--- (viii) Purchase value of MRP goods at actual purchase price
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','O',0,0,0,0,@PARTY_NM)      
              
----9B
---Purchase At 10% Tax Rate  (i)
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And ST_TYPE in ('Local','') And Itemtype <> 'C' And Per = 10
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','P',0,@AMTA1,@AMTB1,0,@PARTY_NM) 


---Purchase At 25% Tax Rate  (ii)
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And ST_TYPE in ('Local','') And Itemtype <> 'C' And Per = 25
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','Q',0,@AMTA1,@AMTB1,0,@PARTY_NM)        
              
---10.Purchase of Schedule ‘C’ goods      
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i on (i.it_code = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('PT','EP') 
And A.ST_TYPE in ('Local','') And A.Itemtype <> 'C' And (i.u_shcode IN ('Schedule ''C''', 'Schedule C') or i.u_shcode like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','R',0,@AMTA1,@AMTB1,0,@PARTY_NM)     
              
---11. Any other receipts/purchases not specified above (Please specify)
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i on (i.it_code = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('PT','EP') 
And A.ST_TYPE in ('Local','') And A.Itemtype <> 'C' And (i.u_shcode NOT IN ('Schedule ''C''', 'Schedule C') And i.u_shcode Not like '% C %')
And A.PER NOT IN (1,2,5,10,13.5,25) And A.Tax_Name <> 'Exempted'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1','S',0,@AMTA1,@AMTB1,0,@PARTY_NM)                                  


--
-- SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
-- SET @CHAR=66
-- DECLARE  CUR_FORM221 CURSOR FOR 
-- select distinct level1 from stax_mas where ST_TYPE='LOCAL'--CHARINDEX('VAT',TAX_NAME)>0
-- OPEN CUR_FORM221
-- FETCH NEXT FROM CUR_FORM221 INTO @PER
-- WHILE (@@FETCH_STATUS=0)
-- BEGIN
--  if @per = 0
--	Begin
--		SELECT @AMTA1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '') b
--		SELECT @AMTB1=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' 
--		SELECT @AMTC1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '') b
--		SELECT @AMTD1=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> ''
--		SELECT @AMTF1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '') b
--		SELECT @AMTF2=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> ''
--		SELECT @AMTG1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '') b
--		SELECT @AMTG2=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> ''
--		SELECT @AMTH1=Round(SUM(NET_AMT),0) FROM (select distinct tran_cd,bhent,net_amt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND U_IMPORM = 'Purchase Return') b
--		SELECT @AMTH2=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND U_IMPORM = 'Purchase Return' 
--	End
--  else
--	Begin
--		SELECT @AMTA1=Round(SUM(Net_AMT),0) FROM (select distinct tran_cd,bhent,net_amt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '') b
--		SELECT @AMTB1=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 
--		SELECT @AMTC1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '') b
--		SELECT @AMTD1=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 
--		SELECT @AMTF1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '') b
--		SELECT @AMTF2=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 
--		SELECT @AMTG1=Round(SUM(VATONAMT),0) FROM (select distinct tran_cd,bhent,vatonamt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '') b
--		SELECT @AMTG2=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 
--		SELECT @AMTH1=Round(SUM(NET_AMT),0) FROM (select distinct tran_cd,bhent,net_amt,dbname from #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND U_IMPORM = 'Purchase Return') b
--		SELECT @AMTH2=Round(SUM(TAXAMT),0)   FROM #FORM_201 WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND U_IMPORM = 'Purchase Return' 
--	End

--  --Purchase Invoice
--  SET @AMTA1=ISNULL(@AMTA1,0)
--  SET @AMTB1=ISNULL(@AMTB1,0)
--  --Return Invoice
--  SET @AMTC1=ISNULL(@AMTC1,0)
--  SET @AMTD1=ISNULL(@AMTD1,0)
--  --Expense Purchase Invoice
--  SET @AMTF1=ISNULL(@AMTF1,0)
--  SET @AMTF2=ISNULL(@AMTF2,0)
--  --Debit Note Invoice
--  SET @AMTG1=ISNULL(@AMTG1,0)
--  SET @AMTG2=ISNULL(@AMTG2,0)
--  --Sales Invoice Where U_imporm = 'Purchase Return'
--  SET @AMTH1=ISNULL(@AMTH1,0)
--  SET @AMTH2=ISNULL(@AMTH2,0)

----Net Effect
----DIN   Set @NetEFF = ((@AMTA1 - @AMTB1) + (@AMTF1 - @AMTF2) - (@AMTC1 - @AMTD1) - (@AMTG1 - @AMTG2) - (@AMTH1 - @AMTH2)) 
--  Set @NetEFF = ((@AMTA1 - @AMTB1) + (@AMTF1 ) - (@AMTC1 - @AMTD1) - (@AMTG1 - @AMTG2) - (@AMTH1 - @AMTH2)) 
----PRINT @NetEFF 
-----Set @NetEFF = ((@AMTA1 - @AMTB1) + (@AMTE1 - @AMTF1)) - (@AMTC1 - @AMTD1)
--  Set @NetTAX = (@AMTB1 + @AMTF2) - @AMTD1 - @AMTG2 - @AMTH2

--  if @nettax <> 0
--	  Begin
--		  INSERT INTO #FORM201
--		  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
--		  (1,'1',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,0,'')
--		  SET @AMTM1=@AMTM1+@NETEFF --TOTAL TAXABLE AMOUNT
--		  SET @AMTO1=@AMTO1+@NETTAX --TOTAL TAX
--		  SET @CHAR=@CHAR+1
--	  end
--  FETCH NEXT FROM CUR_FORM221 INTO @PER
-- END
-- CLOSE CUR_FORM221
-- DEALLOCATE CUR_FORM221
----
-----Purhcase At 20% Tax Rate (Schedule C)
--Select @AmtA1=Round(Sum(Net_Amt),0),@AmtA2=Round(Sum(TaxAmt),0) From #Form_201 Where Bhent In('PT','EP','CN') And (Date Between @Sdate And @Edate) And Per = 20 
--Set @AmtA1 = IsNull(@AMTA1,0)
--Set @AmtA2 = IsNull(@AMTA2,0)
--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
--              VALUES (1,'1','Y',20,@AMTA1,@AMTA2,0,@PARTY_NM)
--SET @CHAR=@CHAR+1
-----Purhcase Tax On Purchase Price (Section 12)
--Select @AmtA1=Round(Sum(Net_Amt),0),@AmtA2=Round(Sum(TaxAmt),0) From #Form_201 Where Bhent In('PT','EP','CN') And (Date Between @Sdate And @Edate) And Per = 20 
--Set @AmtA1 = IsNull(@AMTA1,0)
--Set @AmtA2 = IsNull(@AMTA2,0)
--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
--              VALUES (1,'1','Z',0,@AMTA1,@AMTA2,0,@PARTY_NM)

--- Part 1A

---Purhcase Inter State
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And St_Type = 'Out Of State' And U_Imporm NOT IN ('Branch Transfer', 'Consignment Transfer') And Itemtype <> 'C'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1A','A',0,@AMTA1,0,0,@PARTY_NM) 

---Purhcase Import 
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And St_Type = 'Out Of Country' And Itemtype <> 'C'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1A','B',0,@AMTA1,0,0,@PARTY_NM) 

---Stock Transfer
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And St_Type = 'Out Of State' And U_Imporm IN ('Branch Transfer') And Itemtype <> 'C'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1A','C',0,@AMTA1,0,0,@PARTY_NM) 

---Consignment
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And St_Type = 'Out Of State' And U_Imporm IN ('Consignment Transfer') And Itemtype <> 'C'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1A','D',0,@AMTA1,0,0,@PARTY_NM) 

---Total
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Amt1) From #Form201 Where PartSr = '1' And SrNo In('A','B','C','D','G','H','K','L','O','P','Q','R','S')
Select @AmtB1=Sum(Amt1) From #Form201 Where PartSr = '1A' And SrNo In('A','B','C','D')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1A','E',0,@AMTA1+@AMTB1,0,0,@PARTY_NM)
              
              
---iii CAPITAL GOODS (WITHIN STATE)
---LOCAL (i) Purchase / receipt value of capital goods
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And St_Type in ('Local','') And Itemtype = 'C'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1B','A',0,@AMTA1,0,0,@PARTY_NM) 
	            

--- (ii) Purchase / receipt value of goods for sale by transfer of right to use
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1B','B',0,0,0,0,@PARTY_NM)      
              

---OUT OF STATE (i) Purchase / receipt value of capital goods
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('PT','EP') 
And St_Type in ('Out of State') And Itemtype = 'C'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1C','A',0,@AMTA1,0,0,@PARTY_NM) 
	            

--- (ii) Purchase / receipt value of goods for sale by transfer of right to use
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1C','B',0,0,0,0,@PARTY_NM)      


---Total value of goods purchased / received including capital goods and goods meant for sale by way of transfer of right to use (16+17(i)+17(ii)+18(i)+18(ii))
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Amt1) From #Form201 Where PartSr = '1A' And SrNo In('E')
Select @AmtB1=Sum(Amt1) From #Form201 Where PartSr in ('1B', '1C') And SrNo In('A','B')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1D','A',0,@AMTA1+@AMTB1,0,0,@PARTY_NM)


---20. Total amount of Input tax [05+07(i)(B)+ 07(ii)(B +08 (iii)(B)+09A(iii)(B)+09A(vii)B+9B(i)B]+9B(ii)B
Select @AmtB1 = 0          
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('1') And SrNo In('B','C','F','J','N','P','Q')
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1E','A',0,0,@AMTB1,0,@PARTY_NM)         
              
----Less
---(i) Non-Creditable amount of input tax in respect of despatch of goods otherwise than by way of sales (Box 6(8) of Annexure I)
Select @AmtB1 = 0          
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1F','A',0,0,@AMTB1,0,@PARTY_NM)               
              
---(ii) Reduction of ITC in excess of CST payable, as per clause (d) to the proviso in sub-section (3) of Section 20 (as at serial 5 of Annexure II or Sl. No. 8 of Annexure-II-A)
Select @AmtB1 = 0          
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1F','B',0,0,@AMTB1,0,@PARTY_NM)   

---(iii) Reduction of ITC for sale value less than corresponding purchase value as per sub-section (8-a) of Section 20 (total of column 7(e) of the table in Annexure VI or column 9(v) of Annexure VI-A whichever is applicable)
Select @AmtB1 = 0          
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1F','C',0,0,@AMTB1,0,@PARTY_NM)
    
---(iv) ITC to be reversed for other reasons (as per column 8-D of Annexure -VII)
Select @AmtB1 = 0          
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1F','D',0,0,@AMTB1,0,@PARTY_NM)     

---(v) VAT paid on goods for use in mining, generation of electricity including captive power plant.
Select @AmtB1 = 0          
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1F','E',0,0,@AMTB1,0,@PARTY_NM) 
    

---(vi) VAT paid on goods which are not input
Select @AmtB1 = 0          
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1F','F',0,0,@AMTB1,0,@PARTY_NM)   
  

---22 Total
Select @AmtB1 = 0          
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1F','G',0,0,@AMTB1,0,@PARTY_NM)  

---23 Net Input Tax (20-22)            
Select @AmtA1 = 0,@AmtB1 = 0                    
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('1E') And SrNo In('A')
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('1F') And SrNo In('G')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1G','A',0,0,@AMTA1-@AMTB1,0,@PARTY_NM)                    
                   
                   
---24. Decrease of ITC due to receipt of credit note [Strike out which is not applicable] [box (4)(viii) of Table-II of Annexure-V]              
Select @AmtB1 = 0          
Select @AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('CN') 
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1H','A',0,0,@AMTB1,0,@PARTY_NM)  
                   
---25. Increase of ITC due to receipt of debit note [box (6)(viii) of Table-II of Annexure-V]
Select @AmtB1 = 0          
Select @AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('DN') 
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1H','B',0,0,@AMTB1,0,@PARTY_NM)  
                   
---26.*Creditable amount of input tax in respect of purchase of capital goods (refer sub rule (2) of rule 11. (box 09 of Annexure-III)
Select @AmtB1 = 0          
--Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1H','C',0,0,@AMTB1,0,@PARTY_NM)  
                   
---27.**Creditable amount of input tax in respect of goods, the right to use of which has been transferred (box 5 of Annexure III-A) (see rule-13)
Select @AmtB1 = 0          
--Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1H','D',0,0,@AMTB1,0,@PARTY_NM)  
                   
                   
---28.Creditable amount of input tax on the stock held on the date of registration/eligible date for conversion from SRIN to TIN  (Refer to Form VAT 608-A issued)
Select @AmtB1 = 0          
--Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1H','E',0,0,@AMTB1,0,@PARTY_NM)  
                                      

---29.Total creditable Input Tax [(23-24)+25+26+27+28]
Select @AmtA1 = 0,@AmtB1 = 0,@AmtC1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('1G') And SrNo In('A')
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('1H') And SrNo In('A')
Select @AmtC1=Sum(Amt2) From #Form201 Where PartSr in ('1H') And SrNo In('B','C','D','E')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
Set @AmtC1 = IsNull(@AMTC1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'1I','A',0,0,@AMTA1-@AMTB1+@AMTC1,0,@PARTY_NM)                    
                   

-----Sales Return (Local)
--Select @AmtA1=Round(Sum(Net_Amt),0) From #Form_201 Where Bhent In('SR') And (Date Between @Sdate And @Edate) And St_Type = 'Local'
--Set @AmtA1 = IsNull(@AMTA1,0)
--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
--              VALUES (1,'1A','F',0,@AMTA1,0,0,@PARTY_NM)

----- Part 1A
-----Despatch Other than Sales (18)
--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
--              VALUES (1,'1A','GA',0,0,0,0,@PARTY_NM)
----- Purchase Capital Goods (19)
--Select @AmtA1=Round(Sum(TaxAmt),0) From #Form_201 Where Bhent in('PT','EP','CN') And (Date Between @Sdate And @Edate) And ItemType = 'C'
--Set @AmtA1 = IsNull(@AMTA1,0)
--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
--              VALUES (1,'1A','GB',0,@AMTA1,0,0,@PARTY_NM)

----- Purchase Consignment Purchase (20)
--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
--              VALUES (1,'1A','GC',0,0,0,0,@PARTY_NM)

----- Input Credit Opening (21)
--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
--              VALUES (1,'1A','GD',0,0,0,0,@PARTY_NM)

----- Total Input Credit [12(B) + 18 + 19 + 20 + 21]
--Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr = '1'
--Select @AmtA2=Sum(Amt1) From #Form201 Where PartSr = '1A' And SrNo In('GA','GB','GC','GD','GE')
--Set @AmtA1 = IsNull(@AMTA1,0)
--Set @AmtA2 = IsNull(@AMTA2,0)
--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
--              VALUES (1,'1A','GE',0,@AMTA1+@AMTA2,0,0,@PARTY_NM)

----- Part 1A





--- Part 2
---30.Sales subject to zero-rate
---(i) Sales in the course of export out of India
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') 
And A.St_Type = 'Out Of Country' And A.U_IMPORM IN ('Export Out of India')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2A','A',0,@AMTA1,0,0,@PARTY_NM) 


---(ii) Sales in the course of import into India
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join STMAIN s on (S.ENTRY_TY = A.BHENT And S.TRAN_CD = A.TRAN_CD)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') 
And A.St_Type = 'Out Of Country' And s.VATMTYPE like ('%course of import into India%') And A.U_IMPORM NOT IN ('Export Out of India')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2A','B',0,@AMTA1,0,0,@PARTY_NM) 


---(iii) Sales in the course of inter-state trade or commerce
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2A','C',0,0,0,0,@PARTY_NM) 


---(iv) Sale to a dealer under SEZ / STP / EHTP (See explanation to section 18)
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join STMAIN s on (S.ENTRY_TY = A.BHENT And S.TRAN_CD = A.TRAN_CD)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') 
And s.VATMTYPE like ('%SEZ%') And A.U_IMPORM NOT IN ('Export Out of India')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2A','D',0,@AMTA1,0,0,@PARTY_NM) 
              

---(v) Sale to a EOU (See explanation to section 18)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2A','E',0,0,0,0,@PARTY_NM) 
              
              
---(vi) Total [(i)+(ii)+(iii)+(iv)+(v)]
Select @AmtA1 = 0     
Select @AmtA1=Sum(Amt1) From #Form201 Where PartSr in ('2A') And SrNo In('A','B','C','D', 'E')
Set @AmtA1 = IsNull(@AMTA1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2A','F',0,@AMTA1,0,0,@PARTY_NM)               


--- 31.Despatch of goods to outside the state otherwise than by way of sale - by way of Branch transfer / Consignment sales
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('ST') 
And St_Type = 'Out Of State' And U_Imporm IN ('Branch Transfer','Consignment Transfer') 
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2A','G',0,@AMTA1,0,0,@PARTY_NM) 

--- 32.Sale of goods exempt from tax
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(Gro_Amt - TaxAmt),@AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('ST') 
And Tax_Name = 'Exempted'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2A','H',0,@AMTA1,0,0,@PARTY_NM) 

--- 33.
--(i) Sales at 1% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 1
And (i.u_shcode NOT IN ('Schedule ''C''', 'Schedule C') And i.u_shcode Not like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2B','A',0,@AMTA1,@AMTB1,0,@PARTY_NM)

--(ii) Sales at 2% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 2
And (i.u_shcode NOT IN ('Schedule ''C''', 'Schedule C') And i.u_shcode Not like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2B','B',0,@AMTA1,@AMTB1,0,@PARTY_NM)

--(iii) Sales at 5% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 5
And (i.u_shcode NOT IN ('Schedule ''C''', 'Schedule C') And i.u_shcode Not like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2B','C',0,@AMTA1,@AMTB1,0,@PARTY_NM)

--(iv) Sales at 10% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 10
And (i.u_shcode NOT IN ('Schedule ''C''', 'Schedule C') And i.u_shcode Not like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2B','D',0,@AMTA1,@AMTB1,0,@PARTY_NM)

--(v) Sales at 13.5% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 13.5
And (i.u_shcode NOT IN ('Schedule ''C''', 'Schedule C') And i.u_shcode Not like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2B','E',0,@AMTA1,@AMTB1,0,@PARTY_NM)

--(vi) Sales at 25% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 25
And (i.u_shcode NOT IN ('Schedule ''C''', 'Schedule C') And i.u_shcode Not like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2B','F',0,@AMTA1,@AMTB1,0,@PARTY_NM)


--(vii) Sales at 50% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 50
And (i.u_shcode NOT IN ('Schedule ''C''', 'Schedule C') And i.u_shcode Not like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2B','G',0,@AMTA1,@AMTB1,0,@PARTY_NM)

--(viii) Sale of goods (excluding goods in Schedule C) at such other rate under section 17-A.
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per NOT IN (1,2,5,10,13.5,25,50,0)
And (i.u_shcode NOT IN ('Schedule ''C''', 'Schedule C') And i.u_shcode Not like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2B','H',0,@AMTA1,@AMTB1,0,@PARTY_NM)


---33 (ix) Total
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt1),@AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2B') And SrNo In('A','B','C','D','E','F','G','H')
Set @AmtA1 = IsNull(@AMTA1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2B','I',0,@AMTA1,@AMTB1,0,@PARTY_NM)               


---34. Subtotal [32+33(ix)]
Select @AmtA1 = 0,@AmtB1 = 0,@AmtC1 = 0,@AmtD1 = 0
Select @AmtA1=Sum(Amt1),@AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2A') And SrNo In('H')
Select @AmtC1=Sum(Amt1),@AmtD1=Sum(Amt2) From #Form201 Where PartSr in ('2B') And SrNo In('I')
Set @AmtA1 = IsNull(@AMTA1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2C','A',0,@AMTA1+@AMTC1, @AMTB1+@AMTD1,0,@PARTY_NM)  


---35. Purchase/receipt of goods subject to tax on purchase price under section 12.
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2D','A',0,0,0,0,@PARTY_NM) 

---36. Sale of Schedule “C” goods (other than 1st point)
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') 
And (i.u_shcode IN ('Schedule ''C''', 'Schedule C', 'Schedule "C"') OR i.u_shcode like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2E','A',0,@AmtA1,0,0,@PARTY_NM) 

--- 37.
--(i) Sales at 5% tax rate
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2F','A',0,0,0,0,@PARTY_NM)

--(ii) Sales at 13.5% tax rate
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2F','B',0,0,0,0,@PARTY_NM)

--(iii) Sales at 50% tax rate
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2F','C',0,0,0,0,@PARTY_NM)

--(iv) Total
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2F','D',0,0,0,0,@PARTY_NM)

--- 38.
--(i) Sales at 5% tax rate
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2G','A',0,0,0,0,@PARTY_NM)

--(ii) Sales at 13.5% tax rate
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2G','B',0,0,0,0,@PARTY_NM)

--(iii) Sales at 50% tax rate
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2G','C',0,0,0,0,@PARTY_NM)

--(iv) Total
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2G','D',0,0,0,0,@PARTY_NM)


--- 39 (Schedule C)
--(i) Sales at 20% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 20
And (i.u_shcode IN ('Schedule ''C''', 'Schedule C') Or i.u_shcode like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2H','A',0,@AMTA1,@AMTB1,0,@PARTY_NM)


--(ii) Sales at 23% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 23
And (i.u_shcode IN ('Schedule ''C''', 'Schedule C') Or i.u_shcode like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2H','B',0,@AMTA1,@AMTB1,0,@PARTY_NM)


--(iii) Sales at 25% tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per = 25
And (i.u_shcode IN ('Schedule ''C''', 'Schedule C') Or i.u_shcode like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2H','C',0,@AMTA1,@AMTB1,0,@PARTY_NM)

--(iv) Sales at other tax rate
Select @AmtA1 = 0,@AmtB1 = 0          
Select @AmtA1=Sum(A.Gro_Amt - A.TaxAmt),@AmtB1=Sum(A.TaxAmt) From VATTBL A
Inner join it_mast i ON (i.IT_CODE = A.it_code)
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.Per not in (20,23,25,0)
And (i.u_shcode IN ('Schedule ''C''', 'Schedule C') Or i.u_shcode like '% C %')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2H','D',0,@AMTA1,@AMTB1,0,@PARTY_NM)


--(v) Total
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt1),@AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2H') And SrNo In('A','B','C','D')
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2H','E',0,@AMTA1, @AMTB1,0,@PARTY_NM)  


---40
Select @AmtA1 = 0,@AmtB1 = 0,@AmtC1 = 0,@AmtD1 = 0,@AmtE1 = 0
Select @AmtA1=Sum(Amt1) From #Form201 Where PartSr in ('2A') And SrNo In('F','G')
Select @AmtB1=Sum(Amt1) From #Form201 Where PartSr in ('2C') And SrNo In('A')
Select @AmtC1=Sum(Amt1) From #Form201 Where PartSr in ('2D') And SrNo In('A')
Select @AmtD1=Sum(Amt1) From #Form201 Where PartSr in ('2E') And SrNo In('A')
Select @AmtE1=Sum(Amt1) From #Form201 Where PartSr in ('2F') And SrNo In('D')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
Set @AmtC1 = IsNull(@AMTC1,0)
Set @AmtD1 = IsNull(@AMTD1,0)
Set @AmtE1 = IsNull(@AMTE1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2I','A',0,(@AMTA1+@AMTB1+@AMTC1+@AMTD1+@AMTE1),0,0,@PARTY_NM)               


---41
Select @AmtA1 = 0,@AmtC1 = 0,@AmtD1 = 0,@AmtE1 = 0
Select @AmtA1=Sum(Amt1) From #Form201 Where PartSr in ('2B') And SrNo In('I')
Select @AmtC1=Sum(Amt1) From #Form201 Where PartSr in ('2D') And SrNo In('A')
Select @AmtD1=Sum(Amt1) From #Form201 Where PartSr in ('2G') And SrNo In('D')
Select @AmtE1=Sum(Amt1) From #Form201 Where PartSr in ('2H') And SrNo In('E')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtC1 = IsNull(@AMTC1,0)
Set @AmtD1 = IsNull(@AMTD1,0)
Set @AmtE1 = IsNull(@AMTE1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2I','B',0,(@AMTA1+@AMTC1+@AMTD1+@AMTE1),0,0,@PARTY_NM)               

---42
Select @AmtA1 = 0,@AmtC1 = 0,@AmtD1 = 0,@AmtE1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('2C') And SrNo In('A')
Select @AmtC1=Sum(Amt2) From #Form201 Where PartSr in ('2D') And SrNo In('A')
Select @AmtD1=Sum(Amt2) From #Form201 Where PartSr in ('2G') And SrNo In('D')
Select @AmtE1=Sum(Amt2) From #Form201 Where PartSr in ('2H') And SrNo In('E')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtC1 = IsNull(@AMTC1,0)
Set @AmtD1 = IsNull(@AMTD1,0)
Set @AmtE1 = IsNull(@AMTE1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2I','C',0,0,(@AMTA1+@AMTC1+@AMTD1+@AMTE1),0,@PARTY_NM)               



---43. Decrease of output tax due to issue of credit note [As at Box 4(x) of Table-IV of Annexure-V]
Select @AmtB1 = 0          
Select @AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('CN') 
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2I','D',0,0,@AMTB1,0,@PARTY_NM)  
                   
---44. Increase of output tax due to issue of debit note [As at Box 6(x) of Table-IV of Annexure-V]
Select @AmtB1 = 0          
Select @AmtB1=Sum(TaxAmt) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent in('DN') 
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2I','E',0,0,@AMTB1,0,@PARTY_NM)  


---45. (42 – 43 +44)
Select @AmtA1 = 0,@AmtB1 = 0,@AmtC1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('2I') And SrNo In('C')
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2I') And SrNo In('D')
Select @AmtC1=Sum(Amt2) From #Form201 Where PartSr in ('2I') And SrNo In('E')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
Set @AmtC1 = IsNull(@AMTC1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2I','F',0,0,(@AMTA1-@AMTB1+@AMTC1),0,@PARTY_NM)               


---46. Net tax payable (45 - 29) (if 45 > 29)
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('1I') And SrNo In('A')
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2I') And SrNo In('F')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2I','G',0,0,CASE WHEN (@AMTB1 >= @AMTA1) THEN (@AMTB1- @AMTA1) ELSE 0 END,0,@PARTY_NM)               


--47. Interest payable u/s 34
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2I','H',0,0,0,0,@PARTY_NM)


---48. 
--(i) Total tax and interest (46+47)
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('2I') And SrNo In('G')
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2I') And SrNo In('H')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2J','A',0,0,(@AMTA1 + @AMTB1),0,@PARTY_NM)  


--(ii) Excess paid if any[56(i)(g)] [56(v)(g) – 48]
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('2J') And SrNo In('A')
select @AmtB1=Sum(A.Gro_amt) from VATTBL A
Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
where A.BHENT = 'BP' And A.Date Between @sdate and @edate And B.Party_nm Like '%VAT%'
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2J','B',0,0,CASE WHEN (@AMTB1>= @AMTA1) THEN (@AMTB1- @AMTA1) ELSE 0 END,0,@PARTY_NM)  


---49. Excess Amount of Input Tax credit (29 - 45) (if 29 > 45)
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('1I') And SrNo In('A')
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2I') And SrNo In('F')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2K','A',0,0,CASE WHEN (@AMTA1 > @AMTB1) THEN (@AMTA1- @AMTB1) ELSE 0 END,0,@PARTY_NM)               


---50. ITC adjusted against CST payable during the tax period (put the amount of CST payable in the box)
Select @AmtB1 = 0          
Select @AmtB1=Sum(A.TaxAmt) From VATTBL A
where (A.Date Between @Sdate and @Edate) And A.Bhent in('ST') And A.st_type = 'OUT OF STATE' AND A.TAX_NAME like '%C.S.T.%' AND A.S_TAX <> ''
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2K','B',0,0,@AMTB1,0,@PARTY_NM)  

---51. Balance ITC after adjustment of CST (49-50)
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('2K') And SrNo In('A')
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2K') And SrNo In('B')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2K','C',0,0,(@AMTA1- @AMTB1),0,@PARTY_NM)               

----Refund claim under Rule 65 and Rule 66
--52. Amount of refund claimed (i) as per Rule 65
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2L','A',0,0,0,0,@PARTY_NM)

--(ii) as per Rule 66
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2L','B',0,0,0,0,@PARTY_NM)

--(iii) Total ((i)+(ii))
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2L','C',0,0,0,0,@PARTY_NM)


---53. Balance ITC after refund claim (51-52(iii))
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('2K') And SrNo In('C')
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2L') And SrNo In('C')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2L','D',0,0,(@AMTA1- @AMTB1),0,@PARTY_NM)  


--54. Amount disallowed from the refund claim but allowed to be credited to ITC as per refund sanction order, if any.
--(refund sanction order, if any, passed during the tax period to allow such ITC) (order copy to be enclosed)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2L','E',0,0,0,0,@PARTY_NM)


---55. Total ITC to be carried forward (53+54)
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('2L') And SrNo In('D')
Select @AmtB1=Sum(Amt2) From #Form201 Where PartSr in ('2L') And SrNo In('E')
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) 
              VALUES (1,'2L','F',0,0,(@AMTA1 + @AMTB1),0,@PARTY_NM)  


SELECT @TAXONAMT=0,@TAXAMT =0,@ITEMAMT =0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',@ITEM ='',@FORM_NM='',@S_TAX ='',@QTY=0
Declare @SRNO Numeric (4,0), @TotalDepo Numeric(12,0)


SET @TotalDepo = 0

---56. Details of Tax deposited (i)
Select @AmtA1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('2J') And SrNo In('B')
Set @AmtA1 = IsNull(@AMTA1,0)
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,Address) 
              VALUES (1,'2M','A',0,0,@AMTA1,1,@PARTY_NM,'Excess payment, if any carried forward from the previous tax period')
SET @TotalDepo = @AmtA1

INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,Address) 
              VALUES (1,'2N','A',0,0,0,0,'','Particulars of payment')
SET @SRNO = 1
SET @CHAR=65
SET @AMTA1 = 0


SELECT @AMTA1 = Sum(A.Gro_Amt) from VATTBL A
Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
where BHENT = 'BP' And A.Date Between @sdate and @edate And B.Party_nm Like '%VAT%'
SET @AMTA1 = IsNull(@AMTA1,0)

declare Cur_VatPay cursor  for
select Top 1 B.Drawn_on,B.U_ChalNo, B.U_ChalDt,@AMTA1
from VATTBL A
Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
where BHENT = 'BP' And A.Date Between @sdate and @edate And B.Party_nm Like '%VAT%'
Order By B.U_ChalDt Desc
open Cur_VatPay
FETCH NEXT FROM Cur_VatPay INTO @PARTY_NM,@INV_NO,@DATE, @TAXONAMT
 WHILE (@@FETCH_STATUS=0)
 BEGIN

    SET @SRNO = @SRNO + 1
	SET @TAXONAMT=CASE WHEN @TAXONAMT IS NULL THEN 0 ELSE @TAXONAMT END
	SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
	SET @INV_NO=CASE WHEN @INV_NO IS NULL THEN '' ELSE @INV_NO END
	SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
	
	INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS) 
	VALUES (1,'2O',CHAR(@CHAR),0,0,@TAXONAMT,@SRNO,@INV_NO,@DATE,@PARTY_NM,'Self deposit or by Bank Draft')
	
	SET @TotalDepo = @TotalDepo + @TAXONAMT

 SET @CHAR=@CHAR+1
 FETCH NEXT FROM CUR_VatPay INTO @PARTY_NM,@INV_NO,@DATE, @TAXONAMT
END
CLOSE CUR_VatPay
DEALLOCATE CUR_VatPay

SET @PARTY_NM=''
-- TDS
SET @SRNO = @SRNO + 1
--SET @CHAR=@CHAR+1

INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS) 
VALUES (1,'2O',CHAR(@CHAR),0,0,0,@SRNO,'','','','TDS-')

-- Payment made at the check gate or any other payment against money receipt
SET @SRNO = @SRNO + 1
SET @CHAR=@CHAR+1

INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS) 
VALUES (1,'2O',CHAR(@CHAR),0,0,0,@SRNO,'','','','Payment made at the check gate or any other payment against money receipt')


-- Total payment [(i)+(ii)+(iii)+(iv)]
SET @SRNO = @SRNO + 1
SET @CHAR=@CHAR+1

INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS) 
VALUES (1,'2O',CHAR(@CHAR),0,0,@TotalDepo,@SRNO,'','','','Total payment [(i)+(ii)+(iii)+(iv)]')


-- Balance payable [48-56(v)] if 48 > 56(v)
Select @AmtA1 = 0,@AmtB1 = 0
Select @AmtA1=Sum(Amt2) From #Form201 Where PartSr in ('2J') And SrNo In('A')
Select @AmtB1=@TotalDepo
Set @AmtA1 = IsNull(@AMTA1,0)
Set @AmtB1 = IsNull(@AMTB1,0)
SET @SRNO = @SRNO + 1
SET @CHAR=@CHAR+1

INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS) 
              VALUES (1,'2O',CHAR(@CHAR),0,0,CASE WHEN (@AMTA1>= @AMTB1) THEN (@AMTA1- @AMTB1) ELSE 0 END,@SRNO,'','','','Balance payable [48-56(v)] if 48 > 56(v)')  


-- Excess payment remaining unadjusted for adjustment in the next tax period(s) [to be taken to column [56(i)(g)] [56(v)(g) – 48, if 48<56(v)]
SET @SRNO = @SRNO + 1
SET @CHAR=@CHAR+1

INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS) 
              VALUES (1,'2O',CHAR(@CHAR),0,0,CASE WHEN (@AMTB1>= @AMTA1) THEN (@AMTB1- @AMTA1) ELSE 0 END,@SRNO,'','','','Excess payment remaining unadjusted for adjustment in the next tax period(s) [to be taken to column [56(i)(g)] [56(v)(g) – 48, if 48<56(v)]')  

--- 57
--SALE ON RETAIL INVOICE
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,PARTY_NM,AMT1,FORM_NM,S_TAX) 
SELECT 1,'3','A',0,CAST(datename(Month,A.Date)+'-'+CAST(Year(A.Date) As Varchar(5)) As Varchar(20)),Sum(A.GRO_AMT), Min(A.Inv_No), Max(A.INV_NO)
FROM VATTBL A WHERE A.date between @sdate and @edate and A.bhent='ST' and A.s_tax=''
GROUP BY CAST(datename(Month,A.Date)+'-'+CAST(Year(A.Date) As Varchar(5)) As Varchar(20))
ORDER BY CAST(CAST(RIGHT(CAST(datename(Month,A.Date)+'-'+CAST(Year(A.Date) As Varchar(5)) As Varchar(20)),4) AS VARCHAR(4))+'/'+CAST(DATEPART(mm,CAST(SUBSTRING(CAST(datename(Month,A.Date)+'-'+CAST(Year(A.Date) As Varchar(5)) As Varchar(20)),0,CHARINDEX('-',CAST(datename(Month,A.Date)+'-'+CAST(Year(A.Date) As Varchar(5)) As Varchar(20)))+0)+ ' 1900' AS DATETIME)) AS VARCHAR(02))+'/01' AS smalldatetime)


SET @AMTA1=0
SELECT @AMTA1=COUNT(PARTSR) FROM #FORM201 WHERE PARTSR = '3' AND SRNO = 'A'
IF @AMTA1 = 0
	BEGIN
		INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,PARTY_NM,AMT1,FORM_NM,S_TAX) 
              VALUES (1,'3','A',0,'',0,'','')
	END
	
--List showing sale of goods to registered dealers of Odisha on tax invoice
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,PARTY_NM,ADDRESS,S_TAX,AMT1,AMT2) 
SELECT 1,'4','A',0,A.AC_NAME,A.ADDRESS,A.S_TAX,Sum(A.VATONAMT),Sum(A.TAXAMT)
FROM VATTBL A WHERE A.date between @sdate and @edate and A.bhent='ST' and A.s_tax<>'' And A.ST_TYPE = 'LOCAL'
GROUP BY A.AC_NAME,A.ADDRESS,A.S_TAX

SET @AMTA1=0
SELECT @AMTA1=COUNT(PARTSR) FROM #FORM201 WHERE PARTSR = '4' AND SRNO = 'A'
IF @AMTA1 = 0
	BEGIN
		INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,PARTY_NM,AMT1,FORM_NM,S_TAX) 
              VALUES (1,'4','A',0,'',0,'','')
	END	

--List showing sale of goods to registered dealers of Odisha on tax invoice
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,PARTY_NM,ADDRESS,S_TAX,AMT1,AMT2) 
SELECT 1,'5','A',0,A.AC_NAME,A.ADDRESS,A.S_TAX,Sum(A.VATONAMT),Sum(A.TAXAMT)
FROM VATTBL A WHERE A.date between @sdate and @edate and A.bhent in ('PT','EP') and A.s_tax<>'' And A.ST_TYPE = 'LOCAL'
GROUP BY A.AC_NAME,A.ADDRESS,A.S_TAX

SET @AMTA1=0
SELECT @AMTA1=COUNT(PARTSR) FROM #FORM201 WHERE PARTSR = '5' AND SRNO = 'A'
IF @AMTA1 = 0
	BEGIN
		INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,PARTY_NM,AMT1,FORM_NM,S_TAX) 
              VALUES (1,'5','A',0,'',0,'','')
	END	


Update #form201 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),


SELECT * FROM #FORM201 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
--Print 'OR VAT FORM 201'

