set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

 -- =============================================
 -- Author:  Hetal L. Patel
 -- Create date: 16/07/2009 
 -- Description: This Stored procedure is useful to generate CG CST FORM 01
 -- Modify date: 
 -- Modified By: 
 -- Modify date: (Updated)
 -- =============================================
 ALTER PROCEDURE [dbo].[USP_REP_CG_CSTFORM01]
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
 DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2)
 
SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #FORM221_1
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #form221_1 add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
INTO #FORM221
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
		SET @SQLCOMMAND='Insert InTo  #FORM221_1 Select * from '+@MCON
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
		SET @SQLCOMMAND='Insert InTo  #FORM221_1 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
-----

--Gross Sales
Select @AMTA1=Round(Sum(Net_Amt),0) From #Form221_1 where (Date Between @Sdate and @Edate) And Bhent = 'ST' and U_imporm <> 'Purchase Return'
Set @AMTA1 = ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','A',0,@AMTA1,0,0,'')
--Blank Records
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','B',0,0,0,0,'')

--Out of State Sales
Select @AMTA1=Round(Sum(Net_Amt),0) From #Form221_1 where (Date Between @Sdate and @Edate) And Bhent = 'ST' And St_Type = 'Out of State' And U_Imporm = 'Branch Transfer'
Set @AMTA1 = ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','BA',0,@AMTA1,0,0,'')
--Out of Country Sales
Select @AMTA1=Round(Sum(Net_Amt),0) From #Form221_1 where (Date Between @Sdate and @Edate) And Bhent = 'ST' And St_Type = 'Out of Country' 
Set @AMTA1 = ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','BB',0,@AMTA1,0,0,'')

--Local Sale
--Select @AMTA1=Round(Sum(Net_Amt),0) From #Form221_1 where (Date Between @Sdate and @Edate) And Bhent = 'ST' And St_Type = 'Local' and tax_name <> ''
Select @AMTA1=Sum(AMT1) From #Form221 Where PartSr = '1' and SrNo = 'A'
Select @AMTB1=Sum(AMT1) From #Form221 Where PartSr = '1' and SrNo In('BA','BB')
Set @AMTA1 = ISNULL(@AMTA1,0)
Set @AMTB1 = ISNULL(@AMTB1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','C',0,@AMTA1-@AMTB1,0,0,'')
Select @AMTA1=Round(Sum(Net_Amt),0) From #Form221_1 where (Date Between @Sdate and @Edate) And Bhent = 'ST' And St_Type = 'Local' and tax_name <> '' and U_imporm <> 'Purchase Return'
Set @AMTA1 = ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','CA',0,@AMTA1,0,0,'')
Select @AMTA1=Sum(AMT1) From #form221 where Partsr = '1' And Srno = 'C'
Select @AMTA2=Sum(AMT1) From #form221 where Partsr = '1' And Srno = 'CA'
Set @AMTA1 = ISNULL(@AMTA1,0)
Set @AMTA2 = ISNULL(@AMTA2,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','D',0,@AMTA1-@AMTA2,0,0,'')
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','DA',0,0,0,0,'')


--Local Sale
Select @AMTA1=Round(Sum(Net_Amt),0) From #Form221_1 where (Date Between @Sdate and @Edate) And Bhent = 'ST' And St_Type = 'Local' and tax_name = ''
Set @AMTA1 = ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','E',0,@AMTA1,0,0,'')
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','F',0,0,0,0,'')
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','FA',0,0,0,0,'')
Set @AMTA1 = 0
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','FB',0,@AMTA1,0,0,'')
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','FC',0,@AMTA1,0,0,'')
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','FD',0,0,0,0,'')
--Sales to Register Dealer's
Select @AMTA1=Round(Sum(Net_Amt),0) From #Form221_1 where (Date Between @Sdate and @Edate) And Bhent = 'ST' And s_tax <> '' and U_imporm Not In('Purchase Return','Branch Transfer') and st_type = 'Out Of State'
Set @AMTA1 = ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','FE',0,@AMTA1,0,0,'')
--Sales to Un-Register Dealer's
Select @AMTA1=Round(Sum(Net_Amt),0) From #Form221_1 where (Date Between @Sdate and @Edate) And Bhent = 'ST' And s_tax = '' and U_imporm Not In('Purchase Return','Branch Transfer') and st_type = 'Out Of State'
Set @AMTA1 = ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','FF',0,@AMTA1,0,0,'')
Select @AMTA1=Sum(Amt1) from #Form221 Where Partsr = '1' and srno in('FB','FC','FD','FE','FF')
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','FG',0,@AMTA1,0,0,'')

 -->---PART 2

---Tax & Taxable Amount of Sales for the period
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 
 SET @CHAR=65
 DECLARE  CUR_FORM221 CURSOR FOR 
 select distinct level1 from stax_mas where ST_TYPE='OUT OF STATE'--CHARINDEX('VAT',TAX_NAME)>0
 OPEN CUR_FORM221
 FETCH NEXT FROM CUR_FORM221 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	if @per = 0
		begin
			SELECT @AMTA1=Round(SUM(NET_AMT),0) FROM #form221_1 where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND PER=@PER And ac_name not like '%Rece%' and U_imporm <> 'Purchase Return' And St_Type = 'Out Of State' And U_Imporm <> 'Branch Transfer'
			SELECT @AMTB1=Round(SUM(TAXAMT),0)  FROM #form221_1 where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND PER=@PER And ac_name not like '%Rece%' and U_imporm <> 'Purchase Return' And St_Type = 'Out Of State' And U_Imporm <> 'Branch Transfer'
			SELECT @AMTC1=Round(SUM(NET_AMT),0) FROM #form221_1 where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND PER=@PER And St_Type = 'Out Of State' And U_Imporm <> 'Branch Transfer' 
			SELECT @AMTD1=Round(SUM(TAXAMT),0)  FROM #form221_1 where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) and Tax_name like '%Margin%' And S_tax <> '' AND PER=@PER And St_Type = 'Out Of State' And U_Imporm <> 'Branch Transfer'
		end
	else
		begin
			SELECT @AMTA1=Round(SUM(NET_AMT),0) FROM #form221_1 where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and ac_name not like '%Rece%' And S_tax <> '' AND PER=@PER and U_imporm <> 'Purchase Return' And St_Type = 'Out Of State' And U_Imporm <> 'Branch Transfer'
			SELECT @AMTB1=Round(SUM(TAXAMT),0)  FROM #form221_1 where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE) and ac_name not like '%Rece%' And S_tax <> '' AND PER=@PER and U_imporm <> 'Purchase Return' And St_Type = 'Out Of State' And U_Imporm <> 'Branch Transfer'
			SELECT @AMTC1=Round(SUM(NET_AMT),0) FROM #form221_1 where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND PER=@PER And St_Type = 'Out Of State' And U_Imporm <> 'Branch Transfer'
			SELECT @AMTD1=Round(SUM(TAXAMT),0)  FROM #form221_1 where bhent = 'SR' AND (DATE BETWEEN @SDATE AND @EDATE) And S_tax <> '' AND PER=@PER And St_Type = 'Out Of State' And U_Imporm <> 'Branch Transfer'
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
		  INSERT INTO #FORM221
		  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
		  (1,'2',CHAR(@CHAR),@PER,@NETEFF,@NETTAX,0,'')
		--  (1,'6',CHAR(@CHAR),@PER,@AMTA1-@AMTB1,@AMTB1,0)
		  
		--  SET @AMTJ1=@AMTJ1+@AMTA1 --TOTAL TAXABLE AMOUNT
		--  SET @AMTK1=@AMTK1+@AMTB1 --TOTAL TAX
		  SET @AMTJ1=@AMTJ1+@NETEFF --TOTAL TAXABLE AMOUNT
		  SET @AMTK1=@AMTK1+@NETTAX --TOTAL TAX
		  SET @CHAR=@CHAR+1
	  end

  FETCH NEXT FROM CUR_FORM221 INTO @PER
 END
 CLOSE CUR_FORM221
 DEALLOCATE CUR_FORM221

---Total of Tax & Taxable Amount of Sales for the period
 INSERT INTO #FORM221
 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES
 (1,'2','Z',0,@AMTJ1,@AMTK1,0,'')
-- (1,'6','Z',0,@AMTJ1-@AMTK1,@AMTK1,0)

  --<---PART 6


--Updating Null Records  
Update #form221 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

 SELECT * FROM #FORM221 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
 --SELECT * FROM #FORM221_1 --order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
 
 END
--Print 'CG CST FORM 01'

