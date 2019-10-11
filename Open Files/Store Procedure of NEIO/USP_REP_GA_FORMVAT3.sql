set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Hetal L Patel
-- Create date: 30/09/2009
-- Description:	This Stored procedure is useful to generate GA VAT FORM 03
-- Modify date: 
-- Modified By: 
-- Modify date: 
-- Remark: (Updated)
-- =============================================
ALTER PROCEDURE [dbo].[USP_REP_GA_FORMVAT3]
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

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #GA_FORM_III
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #GA_FORM_III add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
INTO #GA_FORMIII
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
		 EXECUTE USP_REP_MULTI_CO_DATA
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo #GA_FORM_III Select * from '+@MCON
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
		SET @SQLCOMMAND='Insert InTo #GA_FORM_III Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
-----

---Part 1 ( Section A )
select @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III WHERE BHENT = 'ST' AND DATE BETWEEN @SDATE AND @EDATE
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','A',0,@AMTA1,0,0,'')
---Blank Records
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','B',0,0,0,0,'')
---Exempted Sales
SELECT @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III  WHERE TAX_NAME='EXEMPTED' AND BHENT='ST' AND (DATE BETWEEN @SDATE AND @EDATE)
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','C',0,@AMTA1,0,0,'')

--Tax Free Sales
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','D',0,0,0,0,'')

---Net Amount of Sales of Inter State for the period
SELECT @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III  WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND U_IMPORM='Branch Transfer'  AND (DATE BETWEEN @SDATE AND @EDATE) and Taxamt <> 0
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','E',0,@AMTA1,0,0,'')

SELECT @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III  WHERE ST_TYPE='OUT OF COUNTRY' AND BHENT='ST' AND (DATE BETWEEN @SDATE AND @EDATE)
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','F',0,@AMTA1,0,0,'')

---Net Amount of Sales of Inter State CST for the period
SELECT @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III  WHERE ST_TYPE='OUT OF STATE' AND BHENT='ST' AND (DATE BETWEEN @SDATE AND @EDATE) AND U_IMPORM='Branch Transfer'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','G',0,@AMTA1,0,0,'')

INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','H',0,0,0,0,'')

select @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III WHERE BHENT = 'SR' AND DATE BETWEEN @SDATE AND @EDATE
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','I',0,@AMTA1,0,0,'')

INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','J',0,0,0,0,'')


select @AMTA1=SUM(AMT1) FROM #GA_FORMIII WHERE Partsr = '1' and srno <> 'A'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','K',0,@AMTA1,0,0,'')
select @AMTA2=SUM(AMT1) FROM #GA_FORMIII WHERE Partsr = '1' and srno = 'A'
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','L',0,@AMTA2-@AMTA1,0,0,'')


---Tax & Taxable Amount of Sales for the period
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
 SET @CHAR=65
 DECLARE  CUR_FORM221 CURSOR FOR 
 select distinct level1 from stax_mas where ST_TYPE='LOCAL'--CHARINDEX('VAT',TAX_NAME)>0
 OPEN CUR_FORM221
 FETCH NEXT FROM CUR_FORM221 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	if @per = 0
		begin
			SELECT @AMTA1=SUM(NET_AMT),@AMTB1=SUM(TAXAMT) FROM #GA_FORM_III WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' ---And S_tax <> '' 
			SELECT @AMTC1=SUM(NET_AMT),@AMTD1=SUM(TAXAMT) FROM #GA_FORM_III WHERE ST_TYPE='LOCAL' AND BHENT='SR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' ---And S_tax <> '' 
		end
	else
		begin
			SELECT @AMTA1=SUM(NET_AMT),@AMTB1=SUM(TAXAMT) FROM #GA_FORM_III WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) ---And S_tax <> '' 
			SELECT @AMTC1=SUM(NET_AMT),@AMTD1=SUM(TAXAMT) FROM #GA_FORM_III WHERE ST_TYPE='LOCAL' AND BHENT='SR' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE) ---And S_tax <> '' 
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
		  INSERT INTO #GA_FORMIII
		  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
		  (1,'3',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,0,'')
		  
		  SET @AMTJ1=@AMTJ1+@NETEFF --TOTAL TAXABLE AMOUNT
		  SET @AMTK1=@AMTK1+@NETTAX --TOTAL TAX
		  SET @CHAR=@CHAR+1
	  end

  FETCH NEXT FROM CUR_FORM221 INTO @PER
 END
 CLOSE CUR_FORM221
 DEALLOCATE CUR_FORM221
 
---Total of Tax & Taxable Amount of Sales for the period
 INSERT INTO #GA_FORMIII
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
 (1,'3','Z',0,@AMTJ1,@AMTK1,0,'')

---Machunery Sales
select @AMTA1=Sum(A.Net_Amt), @AMTA2=Sum(A.Taxamt) 
FROM #GA_FORM_III A
inner join litem_vw B on(A.BHENT = B.ENTRY_TY And A.Tran_Cd = B.Tran_cd)
inner join it_mast c on(B.It_Code = c.It_code)
WHERE A.BHENT = 'ST'
and A.date between @sdate and @edate and c.type = 'Machinery/Stores'
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'4','A',0,@AMTA1,@AMTA2,0,'')


---SECTION F
--Import Purchases
select @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III WHERE BHENT In('PT','EP') AND DATE BETWEEN @SDATE AND @EDATE and St_type = 'Out of Country'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','A',0,@AMTA1,0,0,'')

select @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III WHERE BHENT In('PT','EP') AND DATE BETWEEN @SDATE AND @EDATE and St_type = 'Out of State'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','B',0,@AMTA1,0,0,'')

select @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III WHERE BHENT In('PT','EP') AND DATE BETWEEN @SDATE AND @EDATE and U_imporm = 'Branch Transfer'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','C',0,@AMTA1,0,0,'')

INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','D',0,0,0,0,'')

select @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III WHERE BHENT In('PT','EP') AND DATE BETWEEN @SDATE AND @EDATE And Tax_name like '%VAT%' and st_type = 'Local'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','E',0,@AMTA1,0,0,'')

select @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III WHERE BHENT In('PT','EP') AND DATE BETWEEN @SDATE AND @EDATE And Tax_name not like '%VAT%' and tax_name <> ''
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','F',0,@AMTA1,0,0,'')

select @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III WHERE BHENT In('PT','EP') AND DATE BETWEEN @SDATE AND @EDATE and st_type = 'Local'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','G',0,@AMTA1,0,0,'')

select @AMTA1=SUM(NET_AMT) FROM #GA_FORM_III WHERE BHENT In('PT','EP') AND DATE BETWEEN @SDATE AND @EDATE
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','H',0,@AMTA1,0,0,'')

---SECTION G
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','H',0,0,0,0,'')

---SECTION H
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'8','A',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'8','B',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'8','C',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'8','D',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'8','E',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'8','F',0,0,0,0,'')

---SECTION I
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','A',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','B',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','C',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','D',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','E',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','F',0,0,0,0,'')

---SECTION I
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'10A','A',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'10A','B',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'10A','C',0,0,0,0,'')
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'10A','D',0,0,0,0,'')


SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 

--Part 1 

SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
SET @CHAR=65

Declare @TAXONAMT as numeric(12,2),@TAXAMT1 as numeric(12,2),@ITEMAMT as numeric(12,2),@INV_NO as varchar(10),@DATE as smalldatetime,@PARTY_NM as varchar(50),@ADDRESS as varchar(100),@ITEM as varchar(50),@FORM_NM as varchar(30),@S_TAX as varchar(30),@QTY as numeric(18,4)

SELECT @TAXONAMT=0,@TAXAMT1 =0,@ITEMAMT =0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',@ITEM ='',@FORM_NM='',@S_TAX ='',@QTY=0


DECLARE  CUR_FORM18a CURSOR FOR 
select distinct level1 from stax_mas where ST_TYPE='LOCAL' --CHARINDEX('VAT',TAX_NAME)>0
OPEN CUR_FORM18a
FETCH NEXT FROM CUR_FORM18a INTO @PER
WHILE (@@FETCH_STATUS=0)
BEGIN
	Declare cur_form18aa cursor for
    SELECT TAXONAMT,TAXAMT,NET_AMT,INV_NO,DATE,PARTY_NM,[ADDRESS],FORM_NM,S_TAX
    FROM #GA_FORM_III WHERE ST_TYPE='LOCAL' AND BHENT='ST' AND PER=@PER AND (DATE BETWEEN @SDATE AND @EDATE)
	OPEN CUR_FORM18aa
	FETCH NEXT FROM CUR_FORM18aa INTO @TAXONAMT,@TAXAMT,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX
	WHILE (@@FETCH_STATUS=0)
	BEGIN

		SET @Per=CASE WHEN @Per IS NULL THEN 0 ELSE @Per END
		SET @TAXONAMT=CASE WHEN @TAXONAMT IS NULL THEN 0 ELSE @TAXONAMT END
		SET @TAXAMT1=CASE WHEN @TAXAMT1 IS NULL THEN 0 ELSE @TAXAMT1 END
		SET @ITEMAMT=CASE WHEN @ITEMAMT IS NULL THEN 0 ELSE @ITEMAMT END
		--SET @QTY=CASE WHEN @QTY IS NULL THEN 0 ELSE @QTY END
		SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
		SET @INV_NO=CASE WHEN @INV_NO IS NULL THEN '' ELSE @INV_NO END
		SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
		SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END
		--SET @ITEM=CASE WHEN @ITEM IS NULL THEN '' ELSE @ITEM END
		SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
		SET @FORM_NM=CASE WHEN @FORM_NM IS NULL THEN '' ELSE @FORM_NM END


		INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,FORM_NM,S_TAX) VALUES (1,'10B',CHAR(@CHAR),@PER,@TAXONAMT,@TAXAMT1,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX)
		
		SET @CHAR=@CHAR+1
		FETCH NEXT FROM CUR_FORM18aa INTO @TAXONAMT,@TAXAMT,@ITEMAMT,@INV_NO,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX
	END
	CLOSE CUR_FORM18aa
	DEALLOCATE CUR_FORM18aa
	
	FETCH NEXT FROM CUR_FORM18a INTO @PER
END
CLOSE CUR_FORM18a
DEALLOCATE CUR_FORM18a

--section k
INSERT INTO #GA_FORMIII (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'10C','A',0,0,0,0,'')

Update #GA_FORMIII set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),


SELECT * FROM #GA_FORMIII order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
--Print 'GA VAT FORM 03'

