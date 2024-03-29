set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- ===================================================================================
-- Author:		Hetal L. Patel
-- Create date: 08/07/2009
-- Description:	This Stored procedure is useful to generate OR VAT FORM 002
-- Modify date: 27th Jan,2010
-- Modified By: Rakesh Varma
-- Remark:
-- ===================================================================================
ALTER PROCEDURE [dbo].[USP_REP_OR_VATFORM002]
 @TMPAC NVARCHAR(50),
 @TMPIT NVARCHAR(50),
 @SPLCOND VARCHAR(8000),
 @SDATE  SMALLDATETIME, @EDATE SMALLDATETIME,
 @SAC AS VARCHAR(60), @EAC AS VARCHAR(60),
 @SIT AS VARCHAR(60), @EIT AS VARCHAR(60),
 @SAMT FLOAT, @EAMT FLOAT,
 @SDEPT AS VARCHAR(60), @EDEPT AS VARCHAR(60),
 @SCATE AS VARCHAR(60), @ECATE AS VARCHAR(60),
 @SWARE AS VARCHAR(60), @EWARE AS VARCHAR(60),
 @SINV_SR AS VARCHAR(60), @EINV_SR AS VARCHAR(60),
 @LYN VARCHAR(20),
 @EXPARA AS VARCHAR(60)= NULL
 AS
 BEGIN
 DECLARE @FCON AS NVARCHAR(2000)
 EXECUTE USP_REP_FILTCON
 @VTMPAC=@TMPAC,
 @VTMPIT =@TMPIT,
 @VSPLCOND =@SPLCOND,
 @VSDATE=NULL, @VEDATE=@EDATE,
 @VSAC =@SAC, @VEAC =@EAC,
 @VSIT=@SIT, @VEIT=@EIT,
 @VSAMT=@SAMT, @VEAMT=@EAMT,
 @VSDEPT=@SDEPT, @VEDEPT=@EDEPT,
 @VSCATE =@SCATE, @VECATE =@ECATE,
 @VSWARE =@SWARE, @VEWARE  =@EWARE,
 @VSINV_SR =@SINV_SR, @VEINV_SR =@SINV_SR,
 @VMAINFILE='M',
 @VITFILE=Null,
 @VACFILE='AC',
 @VDTFLD ='DATE',
 @VLYN=Null,
 @VEXPARA=@EXPARA,
 @VFCON =@FCON OUTPUT

DECLARE @SQLCOMMAND NVARCHAR(4000)

DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),
        @AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),
        @AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),
        @AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)

DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),
		@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),
        @AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),
        @AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)

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
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,
M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,
MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM,
ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,
Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #FORM002_1
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #form002_1 add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,M.INV_NO,
M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,
AC1.S_TAX
INTO #FORM002
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

Declare @MultiCo VarChar(3)
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

		SET @SQLCOMMAND='Insert InTo  #FORM002_1 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND

		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
        --SELECT * from #form002_1 
	End
else
	Begin ------Fetch Records from Single Co. Data

		 Set @MultiCo = 'NO'
         EXECUTE USP_REP_SINGLE_CO_DATA
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		SET @SQLCOMMAND='Insert InTo  #FORM002_1 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND

		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
        --SELECT * from #form002_1 
	End

--(PRESENTLY 5 IN THE FORM)
----------------------------------------------------------------------------------------

SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,
       @AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0

SELECT @AMTA1=SUM(Round(NET_AMT,0)) FROM #FORM002_1  
WHERE TAX_NAME='EXEMPTED' AND BHENT in ('PT','EP','CN') AND (DATE BETWEEN @SDATE AND @EDATE)

SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm)
VALUES (1,'1','A',0,@AMTA1,0,0,'')

-------------------------------------------------------------------------------------------------------
--BELOW CODE IS FOR "PURCHASES AT 1%,4% AND 12.5% TAX RATES" (PRESENTLY 6,7,8 IN THE FORM)

SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,
       @AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0

 SET @CHAR=66

 DECLARE  CUR_FORM002 CURSOR FOR 
 select distinct level1 from stax_mas where ST_TYPE='LOCAL'--CHARINDEX('VAT',TAX_NAME)>0
 OPEN CUR_FORM002
 FETCH NEXT FROM CUR_FORM002 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
  if @per = 0
	Begin
		SELECT @AMTA1=Round(SUM(VATONAMT),0) 
        FROM (select distinct tran_cd,bhent,vatonamt,dbname from #form002_1 
              WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) 
              and Tax_name like '%Margin%' And S_tax <> '') b
		
        SELECT @AMTB1=Round(SUM(TAXAMT),0) FROM #form002_1
        WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) 
        and Tax_name like '%Margin%' And S_tax <> '' 

		SELECT @AMTC1=Round(SUM(VATONAMT),0) 
        FROM (select distinct tran_cd,bhent,vatonamt,dbname from #form002_1 
              WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) 
              and Tax_name like '%Margin%' And S_tax <> '') b

		SELECT @AMTD1=Round(SUM(TAXAMT),0) FROM #form002_1
        WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE)
        and Tax_name like '%Margin%' And S_tax <> ''

		SELECT @AMTF1=Round(SUM(VATONAMT),0) 
        FROM (select distinct tran_cd,bhent,vatonamt,dbname from #form002_1 
              WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE)
              and Tax_name like '%Margin%' And S_tax <> '') b

		SELECT @AMTF2=Round(SUM(TAXAMT),0)   FROM #form002_1 
        WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and 
        Tax_name like '%Margin%' And S_tax <> ''

		SELECT @AMTG1=Round(SUM(VATONAMT),0) 
        FROM (select distinct tran_cd,bhent,vatonamt,dbname from #form002_1
              WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) 
              and Tax_name like '%Margin%' And S_tax <> '') b

		SELECT @AMTG2=Round(SUM(TAXAMT),0) FROM #form002_1 
        WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) 
        and Tax_name like '%Margin%' And S_tax <> ''

		SELECT @AMTH1=Round(SUM(NET_AMT),0) 
        FROM (select distinct tran_cd,bhent,net_amt,dbname from #form002_1 
              WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE)
              and Tax_name like '%Margin%' And S_tax <> '' AND U_IMPORM = 'Purchase Return') b

		SELECT @AMTH2=Round(SUM(TAXAMT),0) FROM #form002_1 
        WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and 
        Tax_name like '%Margin%' And S_tax <> '' AND U_IMPORM = 'Purchase Return' 
	End
  else
	Begin
		SELECT @AMTA1=Round(SUM(Net_AMT),0) 
        FROM (select distinct tran_cd,bhent,net_amt,dbname from #form002_1
              WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) 
              And S_tax <> '') b

		SELECT @AMTB1=Round(SUM(TAXAMT),0) FROM #form002_1
        WHERE ST_TYPE='LOCAL' AND BHENT='PT' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 

		SELECT @AMTC1=Round(SUM(VATONAMT),0) 
        FROM (select distinct tran_cd,bhent,vatonamt,dbname from #form002_1 
              WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) 
              And S_tax <> '') b

		SELECT @AMTD1=Round(SUM(TAXAMT),0) FROM #form002_1 
        WHERE ST_TYPE='LOCAL' AND BHENT='PR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 

		SELECT @AMTF1=Round(SUM(VATONAMT),0) 
        FROM (select distinct tran_cd,bhent,vatonamt,dbname from #form002_1 
              WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) 
              And S_tax <> '') b

		SELECT @AMTF2=Round(SUM(TAXAMT),0) FROM #form002_1 
        WHERE ST_TYPE='LOCAL' AND BHENT='EP' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 

		SELECT @AMTG1=Round(SUM(VATONAMT),0) 
        FROM (select distinct tran_cd,bhent,vatonamt,dbname from #form002_1 
              WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) 
              And S_tax <> '') b

		SELECT @AMTG2=Round(SUM(TAXAMT),0) FROM #form002_1 
        WHERE ST_TYPE='LOCAL' AND BHENT='DN' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' 

		SELECT @AMTH1=Round(SUM(NET_AMT),0) 
        FROM (select distinct tran_cd,bhent,net_amt,dbname from #form002_1 
              WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And 
              S_tax <> '' AND U_IMPORM = 'Purchase Return') b

		SELECT @AMTH2=Round(SUM(TAXAMT),0) FROM #form002_1 
        WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) And 
        S_tax <> '' AND U_IMPORM = 'Purchase Return' 
	End

  --Purchase Invoice
  SET @AMTA1=ISNULL(@AMTA1,0)
  SET @AMTB1=ISNULL(@AMTB1,0)
  --Return Invoice
  SET @AMTC1=ISNULL(@AMTC1,0)
  SET @AMTD1=ISNULL(@AMTD1,0)
  --Expense Purchase Invoice
  SET @AMTF1=ISNULL(@AMTF1,0)
  SET @AMTF2=ISNULL(@AMTF2,0)
  --Debit Note Invoice
  SET @AMTG1=ISNULL(@AMTG1,0)
  SET @AMTG2=ISNULL(@AMTG2,0)
  --Sales Invoice Where U_imporm = 'Purchase Return'
  SET @AMTH1=ISNULL(@AMTH1,0)
  SET @AMTH2=ISNULL(@AMTH2,0)

--Net Effect
--DIN   Set @NetEFF = ((@AMTA1 - @AMTB1) + (@AMTF1 - @AMTF2) - (@AMTC1 - @AMTD1) - (@AMTG1 - @AMTG2) - (@AMTH1 - @AMTH2)) 
  Set @NetEFF = ((@AMTA1 - @AMTB1) + (@AMTF1 ) - (@AMTC1 - @AMTD1) - (@AMTG1 - @AMTG2) - (@AMTH1 - @AMTH2)) 
--  PRINT @NetEFF 
---Set @NetEFF = ((@AMTA1 - @AMTB1) + (@AMTE1 - @AMTF1)) - (@AMTC1 - @AMTD1)
  Set @NetTAX = (@AMTB1 + @AMTF2) - @AMTD1 - @AMTG2 - @AMTH2

  if @nettax <> 0
	  Begin
		  INSERT INTO #FORM002(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) 
          VALUES(1,'1',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,0,'')
		
		  SET @AMTM1=@AMTM1+@NETEFF --TOTAL TAXABLE AMOUNT
		  SET @AMTO1=@AMTO1+@NETTAX --TOTAL TAX
		  SET @CHAR=@CHAR+1
	  end
  FETCH NEXT FROM CUR_FORM002 INTO @PER
 END
 CLOSE CUR_FORM002
 DEALLOCATE CUR_FORM002

-------------------------------------------------------------------------------------------------------

--(PRESENTLY 9 IN THE FORM)

SELECT @AMTA1=0,@AMTB1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0) ,@AMTB1=Round(SUM(TAXAMT),0)
FROM #FORM002_1
where (DATE BETWEEN @SDATE AND @EDATE) AND (BHENT in ('PT','EP','CN') ) And 
ST_TYPE='OUT OF STATE' and tax_name <> '' AND U_IMPORM <>'Branch Transfer'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTB1 = CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END

INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm)
VALUES (1,'1','Y',0,@AMTA1,@AMTB1,0,'')

----------------------------------------------------------------------------------------
--(PRESENTLY 10 IN THE FORM)

SELECT @AMTA1=0,@AMTB1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0) ,@AMTB1=Round(SUM(TAXAMT),0)
FROM #FORM002_1
where (DATE BETWEEN @SDATE AND @EDATE) AND (BHENT in ('PT','EP','CN') ) And 
tax_name not like '%Vat%' and taxamt <> 0 AND ST_TYPE <> 'OUT OF STATE'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTB1 = CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END

INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm)
VALUES (1,'1','Z',0,@AMTA1,@AMTB1,0,'')
----------------------------------------------------------------------------------------
--(PRESENTLY 14 IN THE FORM)

SELECT @AMTA1=0

SELECT @AMTA1=SUM(Round(NET_AMT,0))
FROM #FORM002_1  
WHERE TAX_NAME='EXEMPTED' AND BHENT='ST' AND (DATE BETWEEN @SDATE AND @EDATE)

SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm)
VALUES (1,'2','A',0,@AMTA1,0,0,'')
----------------------------------------------------------------------------------------
--(PRESENTLY 15 IN THE FORM)

SELECT @AMTA1=0,@AMTB1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0) ,@AMTB1=Round(SUM(TAXAMT),0)
FROM #FORM002_1
where (DATE BETWEEN @SDATE AND @EDATE) AND BHENT = 'ST' And 
ST_TYPE='OUT OF STATE' and tax_name <> '' AND U_IMPORM <>'Branch Transfer'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTB1 = CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END

INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm)
VALUES (1,'2','B',0,@AMTA1,@AMTB1,0,'')
----------------------------------------------------------------------------------------

--(PRESENTLY 16 IN THE FORM)

SELECT @AMTA1=0,@AMTB1=0

SELECT @AMTA1=Round(SUM(NET_AMT),0) ,@AMTB1=Round(SUM(TAXAMT),0)
FROM #FORM002_1
where (DATE BETWEEN @SDATE AND @EDATE) AND BHENT='ST' And tax_name like '%Vat%' and ST_TYPE = 'LOCAL'

SET @AMTA1 = CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTB1 = CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END

INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm)
VALUES (1,'2','C',0,@AMTA1,@AMTB1,0,'')

-----------------------------------------------------------------------------------------------------
--(PRESENTLY 19 IN THE FORM)

Declare @TAXONAMT as numeric(12,2),@TAXAMT1 as numeric(12,2),@ITEMAMT as numeric(12,2),
        @INV_NO as varchar(10),@DATE as smalldatetime,@PARTY_NM as varchar(50),
        @ADDRESS as varchar(100),@ITEM as varchar(50),@FORM_NM as varchar(30),@S_TAX as varchar(30),
        @QTY as numeric(18,4)

SELECT @TAXONAMT=0,@TAXAMT =0,@ITEMAMT =0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',
       @ITEM ='',@FORM_NM='',@S_TAX ='',@QTY=0

SET @CHAR=65

SET @PER = 0

declare Cur_VatPay cursor  for
select A.Taxonamt,A.Gro_amt,A.taxamt,A.INV_NO,B.Date,A.Party_nm,Address='',A.Form_nm,A.S_tax
from #form002_1 A
Inner join Bpmain B on (A.Bhent = B.Entry_ty and A.Tran_cd = B.Tran_cd)
where BHENT = 'BP' And A.Date Between @sdate and @edate And B.party_nm Like '%VAT%'
open Cur_VatPay
FETCH NEXT FROM Cur_VatPay INTO @TAXONAMT,@ITEMAMT,@TAXAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX--,@item,@QTY,,@ITEMAMT
 WHILE (@@FETCH_STATUS=0)
 BEGIN

	SET @Per=CASE WHEN @Per IS NULL THEN 0 ELSE @Per END
	SET @TAXONAMT=CASE WHEN @TAXONAMT IS NULL THEN 0 ELSE @TAXONAMT END
	SET @TAXAMT=CASE WHEN @TAXAMT IS NULL THEN 0 ELSE @TAXAMT END
	SET @ITEMAMT=CASE WHEN @ITEMAMT IS NULL THEN 0 ELSE @ITEMAMT END
	SET @QTY=CASE WHEN @QTY IS NULL THEN 0 ELSE @QTY END
	SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
	SET @INV_NO=CASE WHEN @INV_NO IS NULL THEN '' ELSE @INV_NO END
	SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
	SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END
	SET @ITEM=CASE WHEN @ITEM IS NULL THEN '' ELSE @ITEM END
	SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
	SET @FORM_NM=CASE WHEN @FORM_NM IS NULL THEN '' ELSE @FORM_NM END
	
	INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
    VALUES (1,'3',CHAR(@CHAR),@PER,@TAXONAMT,@TAXAMT,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX)

 SET @CHAR=@CHAR+1
 FETCH NEXT FROM CUR_VatPay INTO @TAXONAMT,@TAXAMT,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX--,@ITEM,@QTY
END
CLOSE CUR_VatPay
DEALLOCATE CUR_VatPay
-------------------------------------------------------------------------------------------------------

INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,PARTY_NM) VALUES (1,'4','A',0.00,'PARTY_NM')
INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,PARTY_NM) VALUES (1,'4','B',0.00,'PARTY_NM')

--INSERT INTO #FORM002 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) 
--VALUES (1,'4','B',@PER,@TAXONAMT,@TAXAMT,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX)

SELECT * FROM #FORM002 
--order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)

END
--Print 'OR VAT FORM 02'

