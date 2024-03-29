set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Hetal L. Patel
-- Create date: 08/07/2009
-- Description:	This Stored procedure is useful to generate BR VAT FORM RT 03
-- Modify date: 03-FEB-2010
-- Modified By: Rakesh Varma
-- Remark:
-- =============================================
ALTER PROCEDURE [dbo].[USP_REP_BR_VATFORMRT4]
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

DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),
        @AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),
        @AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),
        @AMTO1 NUMERIC(12,2)

DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),
        @AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),
        @AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)

DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2)

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) 
INTO #VATAC_MAST 
FROM STAX_MAS 
WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''

INSERT INTO #VATAC_MAST 
SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1)
FROM STAX_MAS
WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,
M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,
TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM,
ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,
VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #FORM_RT4
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #FORM_RT4 add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),
STM.FORM_NM,AC1.S_TAX,Item=space(50),qty=9999999999999999999.9999
INTO #FORMRT4
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) 
          Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		 Set @MultiCo = 'YES'
		 EXECUTE USP_REP_MULTI_CO_DATA
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo #FORM_RT4 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		 EXECUTE USP_REP_SINGLE_CO_DATA
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo #FORM_RT4 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
        --select * from #FORM_RT4
	End

--***********************************************************************************************************

SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,
       @AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
 
--SET @CHAR=65

Declare @TAXONAMT as numeric(12,2),@TAXAMT1 as numeric(12,2),@ITEMAMT as numeric(12,2),
        @INV_NO as varchar(10),@DATE as smalldatetime,@PARTY_NM as varchar(50),
        @ADDRESS as varchar(100),@ITEM as varchar(50),@FORM_NM as varchar(30),
        @S_TAX as varchar(30),@QTY as numeric(18,4)

		SET @Per=CASE WHEN @Per IS NULL THEN 0 ELSE @Per END
		SET @TAXONAMT=CASE WHEN @TAXONAMT IS NULL THEN 0 ELSE @TAXONAMT END
		SET @TAXAMT1=CASE WHEN @TAXAMT1 IS NULL THEN 0 ELSE @TAXAMT1 END
		SET @ITEMAMT=CASE WHEN @ITEMAMT IS NULL THEN 0 ELSE @ITEMAMT END
		SET @QTY=CASE WHEN @QTY IS NULL THEN 0 ELSE @QTY END
		SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
		SET @INV_NO=CASE WHEN @INV_NO IS NULL THEN '' ELSE @INV_NO END
		SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
		SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END
		SET @ITEM=CASE WHEN @ITEM IS NULL THEN '' ELSE @ITEM END
		SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
		SET @FORM_NM=CASE WHEN @FORM_NM IS NULL THEN '' ELSE @FORM_NM END

--***********************************************************************************************************

--- Part 1

SELECT @AMTA1=0,@AMTB1=0

SELECT @AMTA1=SUM(Round(NET_AMT,0)),@AMTB1=SUM(Round(TAXAMT,0))
FROM #FORM_RT4
WHERE BHENT in ('ST','DN') AND (DATE BETWEEN @SDATE AND @EDATE)

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'1','A',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'1','B',@PER,@AMTB1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0,@AMTB1=0

SELECT @AMTA1=SUM(Round(NET_AMT,0)),@AMTB1=SUM(Round(TAXAMT,0))
FROM #FORM_RT4
WHERE BHENT in ('PT','EP','CN') AND (DATE BETWEEN @SDATE AND @EDATE)

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'1','C',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'1','D',@PER,@AMTB1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--- Part 2

SELECT @AMTA1=0

SELECT @AMTA1=SUM(Round(NET_AMT,0))
FROM #FORM_RT4
WHERE BHENT in ('ST','DN') AND (DATE BETWEEN @SDATE AND @EDATE)

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'2','A',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************
--- Part 3
--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=SUM(Round(NET_AMT,0))
FROM #FORM_RT4
WHERE BHENT in ('ST','DN') AND (DATE BETWEEN @SDATE AND @EDATE)

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3','A',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0)
FROM #FORM_RT4 
where (DATE BETWEEN @SDATE AND @EDATE) AND BHENT IN ('ST','DN') And 
       ST_TYPE='OUT OF STATE' AND U_IMPORM = 'Branch Transfer'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3','B',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0)
FROM #FORM_RT4
where (DATE BETWEEN @SDATE AND @EDATE) AND BHENT IN ('ST','DN') And 
       ST_TYPE='LOCAL' AND U_IMPORM <>'Branch Transfer'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3','C',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0)
FROM #FORM_RT4
where (DATE BETWEEN @SDATE AND @EDATE) AND BHENT IN ('ST','DN') AND tax_name <> '' and ST_TYPE = 'OUT OF STATE'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3','D',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0)
FROM #FORM_RT4
where (DATE BETWEEN @SDATE AND @EDATE) AND BHENT = 'SR'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3','E',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0)
FROM #FORM_RT4
where (DATE BETWEEN @SDATE AND @EDATE) AND BHENT = 'ST' AND ST_TYPE='OUT OF COUNTRY' 

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3','F',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

-- BELOW ONE WILL BE BLANK

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3','G',@PER,@TAXONAMT,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=Round(SUM(AMT1),0)
FROM #FORMRT4
WHERE PARTSR = 3 AND SRNO IN ('B','C','D','E','F','G')

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3','H',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=SUM(Round(NET_AMT,0))
FROM #FORM_RT4
WHERE BHENT in ('ST','DN') AND (DATE BETWEEN @SDATE AND @EDATE)

SELECT @AMTB1=0

SELECT @AMTB1=Round(SUM(AMT1),0)
FROM #FORMRT4
WHERE PARTSR = '3' AND SRNO IN ('B','C','D','E','F','G')

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3','',@PER,@AMTA1-@AMTB1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************
--- Part 3a
--****************************************************************************************
--Below one is blank

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty)
VALUES (1,'3A','A',@PER,@TAXONAMT,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0)
FROM #FORM_RT4
where (DATE BETWEEN @SDATE AND @EDATE) AND (BHENT in ('SR','ST') ) And 
tax_name like '%Vat%' and taxamt <> 0 AND ST_TYPE = 'LOCAL'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3A','B',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--****************************************************************************************

SELECT @AMTA1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0)
FROM #FORM_RT4
where (DATE BETWEEN @SDATE AND @EDATE) AND (BHENT in ('SR','ST') ) And 
tax_name not like '%Vat%' and taxamt <> 0 AND ST_TYPE = 'LOCAL'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3A','C',@PER,@AMTA1,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)


--****************************************************************************************
--- Part 3b
--****************************************************************************************

--**************************************************************************************************

 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,
        @AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
 
 SET @CHAR=65

 DECLARE  CUR_FORMRT04
 CURSOR FOR select distinct level1 from stax_mas where ST_TYPE='LOCAL'
 OPEN CUR_FORMRT04
 FETCH NEXT FROM CUR_FORMRT04 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	if @per = 0
		begin
			SELECT @AMTA1=Round(SUM(NET_AMT),0) FROM #FORM_RT4 where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' And ac_name not like '%Rece%' and U_imporm <> 'Purchase Return'
			SELECT @AMTB1=Round(SUM(TAXAMT),0)  FROM #FORM_RT4 where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' And ac_name not like '%Rece%' and U_imporm <> 'Purchase Return'
			SELECT @AMTC1=Round(SUM(NET_AMT),0) FROM #FORM_RT4 where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND PER=@PER 
			SELECT @AMTD1=Round(SUM(TAXAMT),0)  FROM #FORM_RT4 where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND PER=@PER
		end
	else
		begin
			SELECT @AMTA1=Round(SUM(NET_AMT),0) FROM #FORM_RT4 where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and ac_name not like '%Rece%' And S_tax <> '' AND PER=@PER and U_imporm <> 'Purchase Return'
			SELECT @AMTB1=Round(SUM(TAXAMT),0)  FROM #FORM_RT4 where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and ac_name not like '%Rece%' And S_tax <> '' AND PER=@PER and U_imporm <> 'Purchase Return'
			SELECT @AMTC1=Round(SUM(NET_AMT),0) FROM #FORM_RT4 where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND PER=@PER
			SELECT @AMTD1=Round(SUM(TAXAMT),0)  FROM #FORM_RT4 where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND PER=@PER
		end
	
  --Sales Invoices
  SET @AMTA1=ISNULL(@AMTA1,0)
  SET @AMTB1=ISNULL(@AMTB1,0)
 
  --Return Invoices
  SET @AMTC1=ISNULL(@AMTC1,0)
  SET @AMTD1=ISNULL(@AMTD1,0)

  --Net Effect
  Set @NetEFF = @AMTA1-(@AMTB1+(@AMTC1-@AMTD1))
 
  --Set @NetEFF = (@AMTA1-@AMTB1)-(@AMTC1-@AMTD1)
  Set @NetTAX = (@AMTB1)-(@AMTD1)


  if @nettax <> 0
	  begin
--		  INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,QTY) 
--          VALUES (1,'3B',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,0,'',0)

    INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
    VALUES (1,'3B',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

		--  (1,'6',CHAR(@CHAR),@PER,@AMTA1-@AMTB1,@AMTB1,0)
		  
		--  SET @AMTJ1=@AMTJ1+@AMTA1 --TOTAL TAXABLE AMOUNT
		--  SET @AMTK1=@AMTK1+@AMTB1 --TOTAL TAX
		  SET @AMTJ1=@AMTJ1+@NETEFF --TOTAL TAXABLE AMOUNT
		  SET @AMTK1=@AMTK1+@NETTAX --TOTAL TAX
		  SET @CHAR=@CHAR+1
	  end

  FETCH NEXT FROM CUR_FORMRT04 INTO @PER
 END
 CLOSE CUR_FORMRT04
 DEALLOCATE CUR_FORMRT04

--**************************************************************************************************

SELECT @AMTA1=0,@AMTB1=0,@PER = 0

SELECT @AMTA1=Round(SUM(AMT1),0),@AMTB1=Round(SUM(AMT2),0)
FROM #FORMRT4
WHERE PARTSR = '3B' AND SRNO IN ('A','B','C')

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3B','D',@PER,@AMTA1,@AMTB1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--**************************************************************************************************
--This one will be blank

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3B','E',@PER,@TAXONAMT,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--**************************************************************************************************

--This one will be blank

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3B','F',@PER,@TAXONAMT,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--**************************************************************************************************

SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0

SELECT @AMTA1=Round(SUM(AMT1),0),@AMTC1=Round(SUM(AMT2),0)
FROM #FORMRT4
WHERE PARTSR = '3B' AND SRNO IN ('D','E')

SELECT @AMTB1=Round(SUM(AMT1),0),@AMTD1=Round(SUM(AMT2),0)
FROM #FORMRT4
WHERE PARTSR = '3B' AND SRNO = 'F'

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3B','G',@PER,@AMTA1-@AMTB1,@AMTC1-@AMTD1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--**************************************************************************************************

--This one will be blank

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3B','H',@PER,@TAXONAMT,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--**************************************************************************************************

--This one will be blank

SELECT @AMTA1=Round(SUM(AMT1),0),@AMTC1=Round(SUM(AMT2),0)
FROM #FORMRT4
WHERE PARTSR = '3B' AND SRNO = 'G'

SELECT @AMTB1=Round(SUM(AMT1),0),@AMTD1=Round(SUM(AMT2),0)
FROM #FORMRT4
WHERE PARTSR = '3B' AND SRNO = 'H'

INSERT INTO #FORMRT4 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,FORM_NM,S_TAX,Qty) 
VALUES (1,'3B','I',@PER,@AMTA1-@AMTB1,@AMTC1-@AMTD1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@ITEM,@FORM_NM,@S_TAX,@QTY)

--**************************************************************************************************

SELECT * FROM #FORMRT4 
order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)

END
--Print 'BR VAT FORM RT 04'
--GO
-------
--PRINT 'BR STORED PROCEDURE UPDATION COMPLETED'
--GO
