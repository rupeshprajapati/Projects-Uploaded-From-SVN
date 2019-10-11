If Exists(Select [Name] from Sysobjects where xType='P' and Id=Object_Id(N'USP_REP_DLFORM21'))
Begin
	Drop Procedure USP_REP_DLFORM21
End
Go

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


/*
EXECUTE USP_REP_DLFORM21'','','','04/01/2014','03/31/2015','','','','',0,0,'','','','','','','','','2014-2015',''
*/


-- =============================================
-- Author:		Sandeep
-- Create date: 29/10/2013
-- Description:	This Stored procedure is useful to generate DL VAT FORM 21 for bug-20342
-- Modify date/By/Remark:
-- =============================================
create PROCEDURE [dbo].[USP_REP_DLFORM21]
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
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),itemtype=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #FORMVAT_110
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #FORMVAT_110 add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
INTO #FORMVAT110
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
		SET @SQLCOMMAND='Insert InTo #FORMVAT_110 Select * from '+@MCON
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
		SET @SQLCOMMAND='Insert InTo #FORMVAT_110 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		--SET @SQLCOMMAND='Select * from '+@MCON
--		print @SQLCOMMAND
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End


--PRINT @SQLCOMMAND
--EXECUTE SP_EXECUTESQL @SQLCOMMAND
-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
-----
SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 


Declare @baccno as varchar (20) ,@InvNo as varchar(10),@date as Datetime,@branch as varchar(50) --,@branch=ac.s_tax

--SELECT @InvNo=b.U_CHALNO,@Date=b.U_CHALdt,@AMTA1=b.net_amt ,@branch=ac.s_tax FROM #FORMVAT_110 A 
SELECT @branch=ac.c_tax FROM #FORMVAT_110 A 
Inner Join Bpmain B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd) INNER JOIN AC_MAST AC ON (AC.ac_name=B.bank_nm) 
WHERE  A.BHENT in('BP') AND (A.DATE BETWEEN @SDATE AND @EDATE) And B.Party_nm like '%VAT%' and b.bank_nm<>''    --and b.U_CHALNO<>'' and ac.s_tax<>''
SET @branch=CASE WHEN @branch IS NULL THEN '' ELSE @branch END

INSERT INTO #FORMVAT110 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,Inv_no,date) VALUES (1,'1','1',0,0,0,0,@branch,'','')
SELECT @branch=ac.U_BKACTYPE FROM #FORMVAT_110 A 
Inner Join Bpmain B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd) INNER JOIN AC_MAST AC ON (AC.ac_name=B.bank_nm) 
WHERE  A.BHENT in('BP') AND (A.DATE BETWEEN @SDATE AND @EDATE) And B.Party_nm like '%VAT%' and b.bank_nm<>''    --and b.U_CHALNO<>'' and ac.s_tax<>''
SET @branch=CASE WHEN @branch IS NULL THEN '' ELSE @branch END
INSERT INTO #FORMVAT110 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,Inv_no,date) VALUES (1,'1','2',0,0,0,0,@branch,'','')

SELECT @branch=ac.MAILNAME FROM #FORMVAT_110 A 
Inner Join Bpmain B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd) INNER JOIN AC_MAST AC ON (AC.ac_name=B.bank_nm) 
WHERE  A.BHENT in('BP') AND (A.DATE BETWEEN @SDATE AND @EDATE) And B.Party_nm like '%VAT%' and b.bank_nm<>''    --and b.U_CHALNO<>'' and ac.s_tax<>''
SET @branch=CASE WHEN @branch IS NULL THEN '' ELSE @branch END
INSERT INTO #FORMVAT110 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,Inv_no,date) VALUES (1,'1','3',0,0,0,0,@branch,'','')

SELECT @branch=rtrim(ac.ac_name)+' '+rtrim(ac.add1)+' '+rtrim(ac.add2)+' '+rtrim(ac.add3) FROM #FORMVAT_110 A 
Inner Join Bpmain B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd) INNER JOIN AC_MAST AC ON (AC.ac_name=B.bank_nm) 
WHERE  A.BHENT in('BP') AND (A.DATE BETWEEN @SDATE AND @EDATE) And B.Party_nm like '%VAT%' and b.bank_nm<>''    --and b.U_CHALNO<>'' and ac.s_tax<>''
SET @branch=CASE WHEN @branch IS NULL THEN '' ELSE @branch END
INSERT INTO #FORMVAT110 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,Inv_no,date) VALUES (1,'1','4',0,0,0,0,@branch,'','')

SELECT @branch=U_MICRNO FROM #FORMVAT_110 A 
Inner Join Bpmain B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd) INNER JOIN AC_MAST AC ON (AC.ac_name=B.bank_nm) 
WHERE  A.BHENT in('BP') AND (A.DATE BETWEEN @SDATE AND @EDATE) And B.Party_nm like '%VAT%' and b.bank_nm<>''    --and b.U_CHALNO<>'' and ac.s_tax<>''
SET @branch=CASE WHEN @branch IS NULL THEN '' ELSE @branch END
INSERT INTO #FORMVAT110 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,Inv_no,date) VALUES (1,'1','5',0,0,0,0,@branch,'','')


--INSERT INTO #FORMVAT110 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,Inv_no,date) VALUES (1,'1','4',0,0,0,0,'','','')
--INSERT INTO #FORMVAT110 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM,Inv_no,date) VALUES (1,'1','5',0,0,0,0,'','','')
Update #FORMVAT110 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),



SELECT * FROM #FORMVAT110 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)



END
--Print 'DL VAT FORM 21'
--GO
-------
--Print 'DL STORED PROCEDURE UPDATION COMPLETED'
--GO
