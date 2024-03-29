If Exists(Select [Name] from Sysobjects where xType='P' and Id=Object_Id(N'USP_REP_DL_VATCHALL'))
Begin
	Drop Procedure USP_REP_DL_VATCHALL
end 
go 
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Hetal L Patel
-- Create date: 01/06/2009
-- Description:	This Stored procedure is useful to generate DL VAT CHALLAN
-- Modify date: 01/07/2009
-- Modified By/date/reason: sandeep/26-oct-13/for bug-20342 
-- =============================================
create PROCEDURE [dbo].[USP_REP_DL_VATCHALL]
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
Begin
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

Declare @SQLCOMMAND NVARCHAR(4000)
 DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)
 DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)
 DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2),@party_nm varchar(10)

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #DLVAT_CH
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #DLVAT_CH add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),
STM.FORM_NM,AC1.S_TAX
INTO #DLVATCH
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
		SET @SQLCOMMAND='Insert InTo #DLVAT_CH Select * from '+@MCON
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
		SET @SQLCOMMAND='Insert InTo #DLVAT_CH Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		--SET @SQLCOMMAND='SELECT * FROM '+@MCON
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0,@party_nm='' 

-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
------->- PART 1-4 

select @AMTA1=sum(A.NET_AMT),@party_nm=b.U_BSRCODE   
from #DLVAT_CH A
Inner Join Bpmain B On(B.Entry_ty = A.Bhent And A.Tran_cd =B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) And B.Party_nm Like '%VAT%' and b.u_nature='Tax'
group by b.u_bsrcode
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @party_nm=CASE WHEN @party_nm IS NULL THEN 0 ELSE @party_nm END
INSERT INTO #DLVATCH (PART,PARTSR,SRNO,rate,AMT1,AMT2,AMT3,AMT4,party_nm,Date) VALUES(1,'1','1111',0,@AMTA1,0,0,0,@party_nm,@edate)

select @AMTA1=sum(A.NET_AMT),@party_nm=b.U_BSRCODE    
from #DLVAT_CH A
Inner Join Bpmain B On(B.Entry_ty = A.Bhent And A.Tran_cd =B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) And B.Party_nm Like '%VAT%' and b.u_nature='INTEREST'
group by b.u_bsrcode
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @party_nm=CASE WHEN @party_nm IS NULL THEN 0 ELSE @party_nm END
INSERT INTO #DLVATCH (PART,PARTSR,SRNO,rate,AMT1,AMT2,AMT3,AMT4,party_nm,date) VALUES(2,'2','2222',0,@AMTA1,0,0,0,'',@edate)


select @AMTA1=sum(A.NET_AMT),@party_nm=b.U_BSRCODE     
from #DLVAT_CH A
Inner Join Bpmain B On(B.Entry_ty = A.Bhent And A.Tran_cd =B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) And B.Party_nm Like '%VAT%' and b.u_nature='Penalty'
group by b.u_bsrcode
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @party_nm=CASE WHEN @party_nm IS NULL THEN 0 ELSE @party_nm END
INSERT INTO #DLVATCH (PART,PARTSR,SRNO,rate,AMT1,AMT2,AMT3,AMT4,party_nm,date) VALUES(3,'3','3333',0,@AMTA1,0,0,0,'',@edate)

select @AMTA1=sum(A.NET_AMT),@party_nm=b.U_BSRCODE     
from #DLVAT_CH A
Inner Join Bpmain B On(B.Entry_ty = A.Bhent And A.Tran_cd =B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) And B.Party_nm Like '%VAT%' and b.u_nature='Composition amount/tax'
group by b.u_bsrcode
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @party_nm=CASE WHEN @party_nm IS NULL THEN 0 ELSE @party_nm END
INSERT INTO #DLVATCH (PART,PARTSR,SRNO,rate,AMT1,AMT2,AMT3,AMT4,party_nm,date) VALUES(4,'4','4444',0,@AMTA1,0,0,0,'',@edate)


select @AMTA1=sum(A.NET_AMT),@party_nm=b.U_BSRCODE     
from #DLVAT_CH A
Inner Join Bpmain B On(B.Entry_ty = A.Bhent And A.Tran_cd =B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) And B.Party_nm Like '%VAT%' and rtrim(b.u_nature)='TDS/Other'
group by b.u_bsrcode
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @party_nm=CASE WHEN @party_nm IS NULL THEN 0 ELSE @party_nm END
INSERT INTO #DLVATCH (PART,PARTSR,SRNO,rate,AMT1,AMT2,AMT3,AMT4,party_nm,Date) VALUES(5,'5','5555',0,@AMTA1,0,0,0,'',@edate)

--<- PART 1-4

Update #DLVATCH set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

 SELECT * FROM #DLVATCH order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO

End
--Print 'DL VAT CHALLAN'

