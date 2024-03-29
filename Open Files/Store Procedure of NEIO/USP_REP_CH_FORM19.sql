set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
 -- Author:  Hetal L Patel
 -- Create date: 16/05/2007
 -- Description: This Stored procedure is useful to generate CH VAT FORM 19
 -- Modify date: 16/05/2007 
 -- Modified By: Madhavi Penumalli
 -- Modify date: 25/11/2009 
 -- =============================================
 -- Modified By: Rakesh Varma
 -- Modify date: 10-Feb-2010
 -- =============================================
ALTER PROCEDURE [dbo].[USP_REP_CH_FORM19]
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
 ,@VSDATE=@SDATE
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
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #CH_FORM19
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #CH_FORM19 add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
INTO #CHFORM19
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

alter table #CHFORM19 add Item varchar(200),qty varchar(100)

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
		SET @SQLCOMMAND='Insert InTo  #CH_FORM19 Select * from '+@MCON
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
		SET @SQLCOMMAND='Insert InTo  #CH_FORM19 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
        --SELECT * FROM #CH_FORM19
	End
-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
-----
--->PART 1-5 
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,
        @AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 

----------------------------------------------------------------------------------------------------------------
--CURSOR

DECLARE  @BHENT VARCHAR(200),@INV_NO VARCHAR(200),@Date VARCHAR(200),@ST_TYPE VARCHAR(200),
         @NET_AMT VARCHAR(200),@PARTY_NM VARCHAR(200),@ADDRESS VARCHAR(200),@S_TAX VARCHAR(200),
         @ITEM VARCHAR(200),@QTY VARCHAR(100),@DATE1 DATETIME

SET @CHAR=65

DECLARE CH_FORM19 CURSOR FOR
SELECT CF.BHENT,CF.PER,CF.NET_AMT,CF.TAXAMT,CF.PARTY_NM,CF.ADDRESS,CF.S_TAX,LW.ITEM,CF.INV_NO,LW.QTY,CF.DATE 
FROM #CH_FORM19 CF INNER JOIN LITEM_VW LW
ON (CF.BHENT = LW.ENTRY_TY AND CF.TRAN_CD = LW.TRAN_CD)
WHERE CF.BHENT IN ('PT','EP','CN') AND CF.ST_TYPE IN ('OUT OF STATE','OUT OF COUNTRY')
AND (CF.DATE BETWEEN @SDATE AND @EDATE)

OPEN CH_FORM19

FETCH NEXT FROM CH_FORM19 INTO @BHENT,@PER,@NET_AMT,@TAXAMT,@PARTY_NM,@ADDRESS,@S_TAX,@ITEM,@INV_NO,@QTY,@DATE1

WHILE (@@FETCH_STATUS=0)

BEGIN 

INSERT INTO #CHFORM19 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,address,s_tax,item,INV_NO,QTY,DATE)
               VALUES (1,'1',CHAR(@CHAR),@PER,@NET_AMT,@TAXAMT,0,@PARTY_NM,@ADDRESS,@S_TAX,@ITEM,@INV_NO,@QTY,@DATE1)

SET @CHAR = @CHAR + 1

FETCH NEXT FROM CH_FORM19 INTO @BHENT,@PER,@NET_AMT,@TAXAMT,@PARTY_NM,@ADDRESS,@S_TAX,@ITEM,@INV_NO,@QTY,@DATE1

END

CLOSE CH_FORM19
DEALLOCATE CH_FORM19
----------------------------------------------------------------------------------------------------------------

Update #CHFORM19 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,''),Qty = isnull(Qty,0),ITEM =isnull(item,'')

SELECT * FROM #CHFORM19
order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), 
partsr,SRNO
 
 END

set ANSI_NULLS OFF
--Print 'CH VAT FORM 19'

