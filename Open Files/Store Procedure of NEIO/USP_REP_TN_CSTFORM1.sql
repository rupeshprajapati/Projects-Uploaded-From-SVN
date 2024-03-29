If Exists(Select [name] From SysObjects Where xtype='P' and [Name]='USP_REP_TN_CSTFORM1')
Begin
	Drop Procedure USP_REP_TN_CSTFORM1
End
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

 -- =============================================
 -- Author:  Hetal L. Patel
 -- Create date: 16/07/2009 
 -- Description: This Stored procedure is useful to generate TN CST Form1
 -- Modify date: 
 -- Modified By: 
 -- Modify date: 24/04/2015 by GAURAV R.TANNA For Bug - 26183
 -- =============================================
CREATE PROCEDURE [dbo].[USP_REP_TN_CSTFORM1]
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
 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2),@BALAMT as NUMERIC(18,2)

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
		 --EXECUTE USP_REP_SINGLE_CO_DATA
		 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT
		
	End
-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
-----

--Transfer of goods otherwise than by way of sale as referred to in section 6-A of the Act.
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate
and @Edate) And Bhent in('ST','CN')  And St_Type = 'OUT OF STATE' 
AND (U_IMPORM IN('BRANCH TRANSFER','CONSIGNMENT TRANSFER')) --  And TAX_NAME in ('EXEMPTED','')
Set @AMTA1 = IsNull(@AMTA1,0)  
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','A',0,@AMTA1,0,0,'')

--1-A Value of goods transferred to the assessee's place of business in the other states
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','B',0,@AMTA1,0,0,'')

--1-B Value of goods transferred to the assessee's agent or Principal in the other states
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'1','C',0,0,0,0,'')


--Gross amount received or receivable by the dealer during the period in respect of sales of goods
SET @AMTA1 = 0
SET  @BALAMT = 0 
Select @AMTA1=isnulL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate and @Edate) And Bhent in('ST','CN')
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT + ISNULL(@AMTA1,0)
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'2','A',0,@AMTA1,0,0,'')

---DEDUCT
-- (i) Sales of goods outside the state (as defined in section 4 of the Act)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'2','AA',0,0,0,0,'')


-- (ii) Sales of goods in the course of export outside India (as defined in section 5 (1) of the Act)
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL where (Date Between @Sdate
and @Edate) And Bhent in('ST','CN')  And St_Type = 'OUT OF COUNTRY' And U_IMPORM like '%Export Out of India%'
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'2','AB',0,@AMTA1,0,0,'')

-- (iii) Sales of goods in the course of import into India (as defined in section 5(2) of the Act) - Details to be furnished in Annexure I
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN i.BHENT='ST' THEN i.gro_Amt ELSE - i.GRO_AMT END),0) From VATTBL i
INNER JOIN STmain m on (m.entry_ty=i.bhent and m.tran_cd=i.tran_cd)
where (i.Date Between @Sdate and @Edate) And i.Bhent in('ST','CN')  And i.St_Type = 'OUT OF COUNTRY' And m.VATMTYPE like '%Sale in the course of import into India%'
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'2','AC',0,0,0,0,'')

-- (iv) Last Sale of goods preceding the sale occasioning the export of those goods outside India (as defined in section 5(3) of the Act)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'2','AD',0,0,0,0,'')

---Total of 2 (i), (ii), (iii) & (iv)
SET @AMTA1 = 0
Select @AMTA1=Sum(Amt1) from #form221 where partsr = '2' and srno in('AA','AB','AC','AD')
Set @AMTA1 = IsNull(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'2','B',0,@AMTA1,0,0,'')


/*2. Balance-turnover of Inter State Sales and Sales within the State*/
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'3','A',0,@BALAMT,0,0,'')

/*Deduct- Turnover Of Sales within the State…*/
SET @AMTA1 = 0
Select @AMTA1=ISNULL(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From vattbl where (Date Between @Sdate and @Edate) 
And Bhent in('ST','CN') And St_Type in('LOCAL','')
Set @AMTA1 = IsNull(@AMTA1,0)  
Set @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'3','AA',0,@AMTA1,0,0,'')

 /*3. Balance-/turnover of Inter-State Sales*/
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'4','A',0,@BALAMT,0,0,'')


 -- (i) Cash discount allowed according to the practice normally prevailing in the trade and cost of freight delivery or installation when such cost is separately charged.
SET @AMTA1 = 0
SET @AMTA2 = 0

SELECT @AMTA1=Sum(A.tot_nontax) FROM STITEM A  
WHERE A.Date Between @SDATE And @EDATE  
    
SELECT @AMTA2=Sum(A.tot_nontax) FROM STMAIN A  
WHERE A.Date Between @SDATE And @EDATE  
           
Set @AMTA1 = IsNull(@AMTA1,0)   
Set @AMTA2 = IsNull(@AMTA2,0)   
SET @BALAMT =@BALAMT - (ISNULL(@AMTA2,0) + ISNULL(@AMTA1,0)) 
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'4','AA',0,(@AMTA1+@AMTA2),0,0,'')

-- (ii) Tax Collections deducted according to section 8-A (1) (a)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'4','AB',0,0,0,0,'')

/*(iii) Sales prices of goods returned by the purchaser within the prescribed period*/
SET @AMTA1 = 0
SET @AMTA2 = 0

SELECT @AMTA1=Sum(Gro_Amt) FROM (SELECT DISTINCT A.GRO_AMT  FROM VATTBL A  
WHERE BHENT in ('SR') AND A.ST_TYPE ='OUT OF STATE' AND (A.Date Between @Sdate and @Edate) )b    
SET @BALAMT =@BALAMT - ISNULL(@AMTA1,0)
Set @AMTA1 = IsNull(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'4','AC',0,@AMTA1,0,0,'')

--Total of 4 (AA + AB + AC)
select @AMTA1=Sum(Amt1) from #form221 where Partsr = '4' and srno in('AA','AB','AC')
Set @AMTA1 = IsNull(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'4','B',0,@AMTA1,0,0,'')


--Balance- Total turnover on inter-State Sales
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'5','A',0,@BALAMT,0,0,'')


--5A Turnover on account of subsequent sales to registered dealers exempt under section 6(2) of the ac
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'5','AA',0,0,0,0,'')

--5B Turnover in goods exempt from tax under section 8 (2-A) of the Act
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'5','AB',0,0,0,0,'')

--5C Turnover exempt under section 8(5) of the Act
SET @AMTA1=0
Select @AMTA1=isnull(Sum(CASE WHEN BHENT='ST' THEN gro_Amt ELSE -GRO_AMT END),0) From VATTBL
where (Date Between @Sdate and @Edate) And Bhent  in('ST','CN') And St_Type = 'OUT OF STATE'
AND TAX_NAME='EXEMPTED'  --and rform_nm not like '%FORM%'
--SET @NetEFF = @NetEFF - @AMTA1
Set @AMTA1 = IsNull(@AMTA1,0)  
SET @BALAMT = @BALAMT - ISNULL(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'5','AC',0,@AMTA1,0,0,'')

--Total of 5-A, 5-B and 5-C
SET @AMTA1=0
select @AMTA1=Sum(Amt1) from #form221 where Partsr = '5' and srno in('AA','AB','AC')
Set @AMTA1 = IsNull(@AMTA1,0)
INSERT INTO #FORM221
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES
(1,'5','B',0,@AMTA1,0,0,'')


--Balance Turnover on account of Sales taxable under the act
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'6','A',0,@BALAMT,0,0,'')

-- APPENDIX - I - DECLARED GOODS
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'7','A',0,0,0,1,'')

-- APPENDIX - II - OTHER GOODS
DECLARE @it_name as varchar(200), @hsncode as varchar(15), @vatonamt as numeric(14,2), @srno as numeric(4)

declare cr_Othgoods cursor FOR
select i.it_name,i.hsncode, a.per, Sum(a.vatonamt) As vatonamt From VATTBL a
inner join IT_MAST i on (i.it_code = a.it_code)
where a.Bhent  in('ST') And a.St_Type = 'OUT OF STATE' And a.Date Between @sdate and @edate AND a.TAX_NAME='EXEMPTED'
group by it_name, hsncode, per
ORDER BY it_name, hsncode, per
SET @it_name =''
SET @hsncode =''
SET @per = 0.00
SET @vatonamt = 0.00
SET @srno = 0
OPEN cr_Othgoods
FETCH NEXT FROM cr_Othgoods INTO @it_name,@hsncode,@per,@vatonamt
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	begin
		--SET @CHALSR = @CHALSR +1
		SET @SRNO = @SRNO + 1
		INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,form_nm) VALUES(1,'8','',@per,@vatonamt,0,@SRNO,@it_name,@hsncode)
	end
 FETCH NEXT FROM cr_Othgoods INTO @it_name,@hsncode,@per,@vatonamt
END
CLOSE cr_Othgoods
DEALLOCATE cr_Othgoods


SET @AMTA1=0
Select @AMTA1=sum(AMT1) from #form221  WHERE PARTSR in ('7', '8') AND PART = 1
Set @AMTA1 = IsNull(@AMTA1,0)
INSERT INTO #FORM221 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'9','A',0,@AMTA1,0,0,'')
 

SET @AMTA1=0
SELECT @AMTA1=ISNULL(Sum(CASE WHEN A.BHENT='ST' THEN A.TAXAMT ELSE -A.TAXAMT END),0) FROM VATTBL A
where A.bhent in ('ST', 'CN') AND (A.DATE BETWEEN @SDATE AND @EDATE) AND A.ST_TYPE='OUT OF STATE' --AND A.RFORM_NM = '' 
Set @AMTA1 = IsNull(@AMTA1,0)   
INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES(1,'10','A',0,@AMTA1,0,0,'')

DECLARE @PYMT_DT AS SMALLDATETIME, @BANK_NM AS VARCHAR(100), @CHQ_NO AS VARCHAR(30), @BSRCODE AS VARCHAR(30)

SET @PYMT_DT =NULL
SET @VATONAMT = 0.00
set @Bank_nm = ''
set @BSRCODE = ''
set @CHQ_NO = ''
SET @srno = 0
declare cr_castPayable cursor FOR
Select A.vatonamt,Date=a.date,bank_nm=B.bank_nm,b.cheq_no,ac.BSRCODE
From VATTBL A
Inner Join BPMAIN B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd)
INNER JOIN AC_MAST AC ON (AC.AC_NAME=B.BANK_NM) 
Where A.BHENT = 'BP'  And (B.Date Between @sdate and @edate) AND  B.Party_nm like '%CST%'
OPEN cr_castPayable
FETCH NEXT FROM cr_castPayable INTO @VATONAMT,@PYMT_DT,@BANK_NM, @CHQ_NO,@BSRCODE
 WHILE (@@FETCH_STATUS=0)
 BEGIN
	begin
		--SET @CHALSR = @CHALSR +1
		SET @SRNO = @SRNO + 1
		INSERT INTO #FORM221(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,date,form_nm,address) VALUES(1,'11','',0,@VATONAMT,0,@SRNO,@Bank_nm,@PYMT_DT,@BSRCODE,@CHQ_NO)
	end
 FETCH NEXT FROM cr_castPayable INTO @VATONAMT,@PYMT_DT,@BANK_NM, @CHQ_NO,@BSRCODE
END
CLOSE cr_castPayable
DEALLOCATE cr_castPayable


--Updating Null Records  
Update #form221 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

 SELECT * FROM #FORM221 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
 --SELECT * FROM #FORM221_1 --order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
 
 END
--Print 'TN CST FORM 01'