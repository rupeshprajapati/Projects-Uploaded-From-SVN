IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='USP_REP_RJ_FORM37')
BEGIN
	DROP PROCEDURE USP_REP_RJ_FORM37
END
go
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_REP_RJ_FORM37]
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
DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2),@BAL_AMT NUMERIC(12,2)
DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)
DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2),@BANK_NM VARCHAR(250),@BK_CITY VARCHAR(250),@BK_BRANCH VARCHAR(250),@LSTDTPAY DATETIME 
Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
,bank_nm=SPACE(250),LSTDTPAY=M.DATE,BK_CITY=SPACE(50),BK_BRANCH=SPACE(50)
INTO #HPFORM2
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID) WHERE 1=2
Declare @MultiCo	VarChar(3),@MCON as NVARCHAR(2000)
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
		SET @SQLCOMMAND='Insert InTo  #HPFORM2_1 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
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
/*A  (a) Payments under the VAT Act.*/
SET @AMTA1=0
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','A',0,@AMTA1,0,0,'')
/*B  (i) Advance payment of VAT*/
SET @BAL_AMT = 0	
SET @AMTA1=0
SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','B',0,@AMTA1,0,0,'')
/*C  (ii) Deposit of Demand */
SET @AMTA1=0
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','C',0,@AMTA1,0,0,'') 
/*D  (1) VAT*/
SET @AMTA1=0
select @AMTA1=ISNULL(sum(A.GRO_AMT),0) from VATTBL A Inner Join Bpmain B On(a.Bhent = B.Entry_ty And A.Tran_cd = B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) And B.U_NATURE ='VAT'  And B.Party_nm ='Vat Payable' 

SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','D',0,@AMTA1,0,0,'') 
/*E (2) Penalty*/
SET @AMTA1=0
select @AMTA1=ISNULL(sum(A.GRO_AMT),0) from VATTBL A Inner Join Bpmain B On(a.Bhent = B.Entry_ty And A.Tran_cd = B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) And B.U_NATURE='Penalty' And B.Party_nm ='Vat Payable' 
SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','E',0,@AMTA1,0,0,'')
/*F  (3) Interest*/
SET @AMTA1=0
select @AMTA1=ISNULL(sum(A.GRO_AMT),0) from VATTBL A Inner Join Bpmain B On(a.Bhent = B.Entry_ty And A.Tran_cd = B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) and b.u_nature='Interest' And B.Party_nm ='Vat Payable'
SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','F',0,@AMTA1,0,0,'')
/*G  (4) Other sum */
set @AMTA1 = 0
select @AMTA1=ISNULL(sum(A.GRO_AMT),0) from VATTBL A Inner Join Bpmain B On(a.Bhent = B.Entry_ty And A.Tran_cd = B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) and b.u_nature='Other payments on account of' And B.Party_nm ='Vat Payable'
SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','G',0,@AMTA1,0,0,'')
/*H Total (a) (ii) */
set @AMTA1 = 0
select @AMTA1 =ISNULL(SUM(AMT1),0) from #HPFORM2 where part=1 and partsr='1' AND SRNO in('D','E','F','G')
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','H',0,@AMTA1,0,0,'') 
/*I (iii) Other fee */
set @AMTA1 = 0
SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','I',0,@AMTA1,0,0,'') 
/*J Please describe */
set @AMTA1 = 0
SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','J',0,@AMTA1,0,0,'') 
/*K Total (a) = (i)+(ii)+(iii) */
set @AMTA1 = 0
SET @AMTA1 = @BAL_AMT
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','K',0,@AMTA1,0,0,'') 
/*(b) Other Payments*/
set @AMTA1 = 0


INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','L',0,@AMTA1,0,0,'') 
/*(i) Fines/Penalties and interest*/
set @AMTA1 = 0
SET @BAL_AMT = 0
select @AMTA1=ISNULL(sum(A.GRO_AMT),0) from VATTBL A Inner Join Bpmain B On(a.Bhent = B.Entry_ty And A.Tran_cd = B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) and b.u_nature='Fines' And B.Party_nm ='Vat Payable'
SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','M',0,@AMTA1,0,0,'') 
/*(ii) Security*/
SET @AMTA1=0
select @AMTA1=ISNULL(sum(A.GRO_AMT),0) from VATTBL A Inner Join Bpmain B On(a.Bhent = B.Entry_ty And A.Tran_cd = B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) and b.u_nature LIKE 'Security Money' And B.Party_nm ='Vat Payable'
SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','N',0,@AMTA1,0,0,'') 
/*(iii) Miscellaneous Payments*/
set @AMTA1 = 0
select @AMTA1=ISNULL(sum(A.GRO_AMT),0) from VATTBL A Inner Join Bpmain B On(a.Bhent = B.Entry_ty And A.Tran_cd = B.Tran_cd)
where A.bhent='BP' AND (A.Date Between @Sdate and @Edate) and b.u_nature = 'Miscellaneous' And B.Party_nm ='Vat Payable'
SET @BAL_AMT = @BAL_AMT + @AMTA1
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','O',0,@AMTA1,0,0,'') 
/*(Please describe)*/
/*Total (b) */	
set @AMTA1 = @BAL_AMT
INSERT INTO #HPFORM2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,PARTY_NM) VALUES (1,'1','Q',0,@AMTA1,0,0,'') 

SET @BANK_NM=''
SET @BK_CITY=''
SET @LSTDTPAY = NULL
SET @BK_BRANCH= ''
/*Added by Suraj K. for Bug-25456 Bank details Start */
SELECT TOP 1 @LSTDTPAY=BP.DATE,@BANK_NM=BK.AC_NAME,@BK_CITY=BK.CITY,@BK_BRANCH=BK.s_tax FROM BPMAIN BP LEFT OUTER JOIN AC_MAST BK ON (BP.BANK_NM=BK.AC_NAME) 
WHERE (BP.Date Between @Sdate and @Edate) AND BP.party_nm='VAT PAYABLE'  AND BP.U_NATURE IN('VAT','Penalty','Interest','Other payments on account of','Fines','Security Money','Miscellaneous') ORDER BY BP.DATE DESC,Tran_cd DESC  
/*Added by Suraj K.  on 08-01-2015 for Bug-25456 Bank details end */
Update #HPFORM2 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0)+ (select ISNULL(SUM(amt1),0) from #HPFORM2 where srno in('K','Q')), 
					 AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')
					,BANK_NM=@BANK_NM,BK_CITY=@BK_CITY,LSTDTPAY=@LSTDTPAY,BK_BRANCH=@BK_BRANCH 
SELECT * FROM #HPFORM2 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
