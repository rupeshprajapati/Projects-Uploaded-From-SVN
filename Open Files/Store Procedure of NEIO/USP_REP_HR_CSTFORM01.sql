IF EXISTS (SELECT XTYPE, NAME FROM SYSOBJECTS WHERE XTYPE = 'P' AND NAME = 'USP_REP_HR_CSTFORM01')
BEGIN
	DROP PROCEDURE USP_REP_HR_CSTFORM01
END
GO
set ANSI_NULLS ON
GO
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Hetal L Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate HR CST FORM 01
-- Modify date: 16/05/2007
-- Modified By: Sandeep Shah
-- Modify date: 06/09/2010
-- Remark:(Updated) Add bank payment detials and validate all amounts calcualtions.
-- Modified By: G.PRASHANTHREDDY
-- Modify date: 06/03/2012
-- Remark:(Updated) Add bank payment detials and validate all amounts calcualtions.
-- Modified By: Gaurav R. Tanna for Bug-26301

-- =============================================
Create PROCEDURE [dbo].[USP_REP_HR_CSTFORM01]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= null
AS
BEGIN
Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE=NULL,@VACFILE=NULL
,@VDTFLD ='DATE'
,@VLYN=NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000)
DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)
DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)
DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2),@BALAMT NUMERIC(12,2)

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

------Temporary Cursor1
--SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM
--,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
--INTO #FORM_01
--FROM PTACDET A 
--INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
--INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
--INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
--INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
--WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

--alter table #FORM_01 add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
INTO #FORM01
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
		---- EXECUTE USP_REP_MULTI_CO_DATA
		----  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		---- ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		---- ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		---- ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		---- ,@MFCON = @MCON OUTPUT

		------SET @SQLCOMMAND='Select * from '+@MCON
		-------EXECUTE SP_EXECUTESQL @SQLCOMMAND
		----SET @SQLCOMMAND='Insert InTo #FORM_01 Select * from '+@MCON
		----EXECUTE SP_EXECUTESQL @SQLCOMMAND
		-------Drop Temp Table 
		----SET @SQLCOMMAND='Drop Table '+@MCON
		----EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		 --EXECUTE USP_REP_SINGLE_CO_DATA
		 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		------SET @SQLCOMMAND='Select * from '+@MCON
		-------EXECUTE SP_EXECUTESQL @SQLCOMMAND
		----SET @SQLCOMMAND='Insert InTo #FORM_01 Select * from '+@MCON
		----EXECUTE SP_EXECUTESQL @SQLCOMMAND
		-------Drop Temp Table 
		----SET @SQLCOMMAND='Drop Table '+@MCON
		----EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
-----

SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 

---Part 1
---Gross sale for the period
SET @AMTA1 = 0
SET  @BALAMT = 0 
Select @AMTA1=isnulL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate and @Edate) And Bhent in('ST','CN')
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT + ISNULL(@AMTA1,0)
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','A',0,@Amta1,0,0,'') 

----Deduction
---Blank Record
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','B',0,0,0,0,'')  

---Sales outside the State (Govt)

INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','C',0,0,0,0,'') 

---Sales Exported outside India
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate
and @Edate) And Bhent in('ST','CN')  And St_Type = 'OUT OF COUNTRY' --And U_IMPORM like '%Export Out of India%'
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','D',0,@AMTA1,0,0,'') 

---Turnover of Goods Transfered out of the State
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate
and @Edate) And Bhent in('ST','CN')  And St_Type = 'OUT OF STATE' AND (U_IMPORM IN('BRANCH TRANSFER','CONSIGNMENT TRANSFER'))
Set @AMTA1 = IsNull(@AMTA1,0)
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','E',0,@AMTA1,0,0,'') 

---Part 2
---Balance Turnover Inter-State & Within State
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'2','A',0,@BALAMT,0,0,'') 

---Deduct Turnover on Sales within the State
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From vattbl where (Date Between @Sdate and @Edate) 
And Bhent in('ST','CN') And St_Type in('LOCAL','')
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'2','B',0,@AMTA1,0,0,'') 

---Part 3
---Balance Turnover Inter-State
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'3','A',0,@BALAMT,0,0,'') 

---Deduct Cost Freight & other Charges
SET @AMTA1 = 0
SET @AMTA2 = 0

--SELECT @AMTA1=Sum(A.tot_nontax) FROM STITEM A  
--WHERE A.Date Between @SDATE And @EDATE  
    
--SELECT @AMTA2=Sum(A.tot_nontax) FROM STMAIN A  
--WHERE A.Date Between @SDATE And @EDATE  
           
--Set @AMTA1 = IsNull(@AMTA1,0)   
--Set @AMTA2 = IsNull(@AMTA2,0)   
--SET @BALAMT =@BALAMT - (ISNULL(@AMTA2,0) + ISNULL(@AMTA1,0)) 
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'3','B',0,(@AMTA1+@AMTA2),0,0,'') 

---Part 4
---Balance Turnover on Inter-State Sales
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'4','A',0,@BALAMT,0,0,'') 

---Blank Record
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'4','B',0,0,0,0,'') 

---Turnover of inter-state sales of goods exempted from Tax
SET @AMTA1=0
Select @AMTA1=isnull(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent  in('ST','CN') And St_Type = 'OUT OF STATE'
AND TAX_NAME='EXEMPTED' AND (U_IMPORM NOT IN('BRANCH TRANSFER','CONSIGNMENT TRANSFER'))
--SET @NetEFF = @NetEFF - @AMTA1
Set @AMTA1 = IsNull(@AMTA1,0)  
SET @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'4','C',0,@AMTA1,0,0,'') 

---Turnover of Sales return from purchaser
SET @AMTA1 = 0
DECLARE @RAMTA1 NUMERIC(14,2),@RAMTA2 NUMERIC(14,2),@LSTTHREEMTHDATE DATETIME
SET @RAMTA1 = 0
SET @RAMTA2 = 0
Set @LSTTHREEMTHDATE = DATEADD(MONTH,-3, convert(datetime,@Edate,104)) 

SELECT @AMTA1=Sum(Gro_Amt) FROM VATTBL A  
inner join SRITREF sr on (sr.tran_cd = A.tran_cd And sr.it_code = A.it_code And sr.entry_ty = A.bhent)
WHERE A.BHENT in ('SR') AND A.ST_TYPE ='OUT OF STATE' AND (sr.RDate Between @Sdate and @Edate)
AND A.Date <= DATEADD(MONTH,3, convert(datetime,sr.RDate,104)) 

Set @AMTA1 = IsNull(@AMTA1,0)
SET @BALAMT =@BALAMT - ISNULL(@AMTA1,0)

INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'4','D',0,@AMTA1,0,0,'')

-- Sales return part of registered dealer
SELECT @RAMTA1=Sum(Gro_Amt) FROM (SELECT DISTINCT A.GRO_AMT  FROM VATTBL A  
inner join SRITREF sr on (sr.tran_cd = A.tran_cd And sr.it_code = A.it_code And sr.entry_ty = A.bhent)
WHERE BHENT in ('SR') AND A.ST_TYPE ='OUT OF STATE' AND A.s_tax <> ''
AND (sr.RDate Between @Sdate and @Edate) AND  A.Date <= DATEADD(MONTH,3, convert(datetime,sr.RDate,104))  )b    
Set @RAMTA1 = IsNull(@RAMTA1,0)

-- Sales return part of unregistered dealer
SELECT @RAMTA2=Sum(Gro_Amt) FROM (SELECT DISTINCT A.GRO_AMT  FROM VATTBL A  
inner join SRITREF sr on (sr.tran_cd = A.tran_cd And sr.it_code = A.it_code And sr.entry_ty = A.bhent)
WHERE BHENT in ('SR') AND A.ST_TYPE ='OUT OF STATE' AND A.s_tax = ''
AND (sr.RDate Between @Sdate and @Edate) AND A.Date <= DATEADD(MONTH,3, convert(datetime,sr.RDate,104)) )b    
Set @RAMTA2 = IsNull(@RAMTA2,0)


 
---Turnover of Sales falling in section4
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'4','E',0,0,0,0,'') 

--Balance Taxable Turnover on inter-state sales
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'4','F',0,@BALAMT,0,0,'') 

---Part 5
---Goodswise Breaks
--Blank Record
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'5','A',0,0,0,0,'') 

--Blank Record
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'5','B',0,0,0,0,'') 

---Sold to Registered Dealers against 'C' forms
----SELECT @AMTA1=SUM(AMT1) FROM #FORM01 WHERE PartSr = '4' and srno = 'A'
----SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
----SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'5','C',0,0,0,0,'') 

---Sold to Otherwise not against 'C' forms
--SELECT @AMTA1=SUM(NET_AMT),@AMTA2=SUM(TAXAMT) FROM #FORM_01 WHERE BHENT='ST' And S_TAX = ' ' AND (DATE BETWEEN @SDATE AND @EDATE)
--SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
--SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'5','D',0,0,0,0,'') 

--Other Goods All Sold Govt covered by form 'D'
--Blank Record
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'5','E',0,0,0,0,'') 

---Sold to Registered Dealers
SET @AMTA2=0
SET @AMTB2=0

SET @AMTA1=0
Select @AMTA1=isnull(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent  in('ST','CN') And s_tax <> ''  And St_Type = 'OUT OF STATE'
AND U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER') AND TAX_NAME <> 'EXEMPTED' --AND RFORM_NM NOT LIKE('%FORM%')
Set @AMTA1 = IsNull(@AMTA1,0)
Set @AMTA2 = (@AMTA1- @RAMTA1)
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'5','F',0,@AMTA2,0,0,'') 

---Sold to Otherwise All Sold Govt not covered by form 'D'
SET @AMTA1=0
Select @AMTA1=isnull(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL 
where (Date Between @Sdate and @Edate) And Bhent  in('ST','CN') And s_tax= ''  And St_Type = 'OUT OF STATE'
AND U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER') AND TAX_NAME <> 'EXEMPTED' --AND RFORM_NM NOT LIKE('%FORM%')
Set @AMTA1 = IsNull(@AMTA1,0)
Set @AMTB2 = (@AMTA1- @RAMTA2)
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'5','G',0,@AMTB2,0,0,'') 

---Total
SET @AMTA1=0
SELECT @AMTA1=sum(AMT1) FROM #FORM01 WHERE partsr = '5' 
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
--SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'5','H',0,@Amta1,0,0,'') 

---Part 6
---Taxable at % xyz on Amt abc Tax Amt pqr
SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0
 SET @CHAR=65
 DECLARE  CUR_FORM221 CURSOR FOR 
 select distinct level1 from stax_mas 
 OPEN CUR_FORM221
 FETCH NEXT FROM CUR_FORM221 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
		begin
			SET @AMTA1 = 0
			SET @AMTA2 = 0
			SET @AMTB1 = 0
			SET @AMTB2 = 0
			SET @AMTC1 = 0
			SET @AMTC2 = 0
			SET @AMTD1 = 0
			SET @AMTD2 = 0
			SET @AMTE1 = 0
			SET @AMTE2 = 0

			SELECT @AMTA1=ISNULL(SUM(CASE WHEN BHENT='ST' THEN GRO_AMT-TAXAMT ELSE -GRO_AMT+TAXAMT END),0),
			@AMTA2=ISNULL(SUM(CASE WHEN BHENT='ST' THEN TAXAMT ELSE -TAXAMT END),0) FROM VATTBL 
			where Bhent  IN( 'ST','CN') AND (DATE BETWEEN @SDATE AND @EDATE) AND PER=@PER And St_Type = 'OUT OF STATE'
			AND U_IMPORM NOT IN ('BRANCH TRANSFER','CONSIGNMENT TRANSFER') AND TAX_NAME <> 'EXEMPTED'
			
			Select @AMTC1=ISNULl(SUM(A.GRO_Amt-A.TAXAMT),0),@AMTC2=ISNULl(SUM(A.TAXAMT),0) From VATTBL A
			inner join SRITREF sr on (sr.tran_cd = A.tran_cd And sr.it_code = A.it_code And sr.entry_ty = A.bhent)
			where (sr.RDate Between @Sdate and @Edate)  And A.Bhent = 'SR'  
			And A.St_Type = 'OUT OF STATE'  AND A.Date <= DATEADD(MONTH,3, convert(datetime,sr.RDate,104)) AND A.PER=@PER
			
			SET @AMTA1=ISNULL(@AMTA1,0)
			SET @AMTA2=ISNULL(@AMTA2,0)
			
			SET @AMTC1=ISNULL(@AMTC1,0)
			SET @AMTC2=ISNULL(@AMTC2,0)
			
		end
  --Net Effect
  Set @NetEFF = (@AMTA1-@AMTC1)
  Set @NetTAX = (@AMTA2-@AMTC2)
  if @NetEFF <> 0
	  begin
		print 'T 6'
		  INSERT INTO #FORM01
		  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'6',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,(round(@NETTAX,0)-(@NETTAX)),'') 
 	
 		  SET @AMTJ1=@AMTJ1+@NETEFF --TOTAL TAXABLE AMOUNT
		  SET @AMTK1=@AMTK1+@NETTAX --TOTAL TAX
	
		  --SET @AMTK1=@AMTK1+((@NETEFF *@PER)/100)
		  --SET @AMTK11=@AMTK11+(round(@NETTAX,0)-(@NETTAX))
	
		  SET @CHAR=@CHAR+1
	  end
  FETCH NEXT FROM CUR_FORM221 INTO @PER
 END
 CLOSE CUR_FORM221
 DEALLOCATE CUR_FORM221
SET @AMTJ1=ISNULL(@AMTJ1,0)
SET @AMTK1=ISNULL(@AMTK1,0)

if not exists(select top 1 srno from #FORM01 where part=1 and partsr ='6' )
begin
	INSERT INTO #FORM01
		  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'6','A',0,0,0,0,'')
end

INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','A',0,@AMTJ1,@AMTK1,0,'') 

--Part 7
--A- Tax deposited in Bank / Treasury
----Bank Payment Details

Declare @cheq_no as varchar(30),@u_chqdt as smalldatetime 
SELECT @AMTA1=0,@cheq_no ='',@u_chqdt=''

SET @CHAR=65
SET @AMTJ1 = 0
SET @PER = 0
declare Cur_VatPay cursor  for
Select A.vatonamt,b.cheq_no,b.U_CHQDT
From VATTBL A
Inner Join BPMAIN B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd)
INNER JOIN AC_MAST AC ON (AC.AC_NAME=B.BANK_NM) 
Where A.BHENT = 'BP'  And (B.Date Between @sdate and @edate) AND  B.Party_nm like '%CST%'

open Cur_VatPay
FETCH NEXT FROM Cur_VatPay INTO @AMTA1,@cheq_no,@u_chqdt
	WHILE (@@FETCH_STATUS=0)
	BEGIN
	
	SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
	SET @cheq_no=CASE WHEN @cheq_no IS NULL THEN '' ELSE @cheq_no END
	SET @u_chqdt=CASE WHEN @u_chqdt IS NULL THEN '' ELSE @u_chqdt END
	
	INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,DATE,FORM_NM) VALUES (1,'8',CHAR(@CHAR),0,@AMTA1,0,0,'',@u_chqdt,@cheq_no)
	SET @AMTJ1 = @AMTJ1 + @AMTA1
	SET @CHAR=@CHAR+1
	FETCH NEXT FROM CUR_VatPay INTO @AMTA1,@cheq_no,@u_chqdt
END
CLOSE CUR_VatPay
DEALLOCATE CUR_VatPay

if not exists(select top 1 srno from #FORM01 where part=1 and partsr ='8' )
begin
	INSERT INTO #FORM01
		  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'8','A',0,0,0,0,'')
end

INSERT INTO #FORM01 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','A',0,@AMTK1-@AMTJ1,0,0,'') 

Update #form01  set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''), 
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0), ITEM =isnull(item,'')


SELECT * FROM #FORM01 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
--SELECT * FROM #FORM221_1 --order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)

END

--Print 'HR CST FORM 01'







