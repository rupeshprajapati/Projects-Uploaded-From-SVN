IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE NAME='USP_REP_OR_ANNEX_III' AND XTYPE='P')
BEGIN
	DROP PROCEDURE USP_REP_OR_ANNEX_III
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
--EXECUTE USP_REP_OR_ANNEX_III'','','','04/01/2015','03/31/2016','','','','',0,0,'','','','','','','','','2015-2016',''
-- Author:		Hetal L. Patel
-- Create date: 08/07/2009
-- Description:	This Stored procedure is useful to generate OR VAT FORM 200 Annx III
-- Modified By: Suraj kumawat
-- Modify date: 18-07-2015
-- Remark:
-- =============================================
CREATE  PROCEDURE [dbo].[USP_REP_OR_ANNEX_III]
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

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2)

SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=M.net_amt,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
INTO #FORMAnnex3
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2
EXECUTE USP_REP_SINGLE_CO_DATA_VAT
@TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
,@MFCON = @MCON OUTPUT
---part 1
---2% tax rate
SET @AMTA1 = 0
SET @AMTB1 = 0
SELECT @AMTA1 = isnull(SUM(VATONAMT),0),@AMTB1=ISNULL(SUM(TAXAMT),0) FROM VATTBL  
LEFT OUTER JOIN IT_MAST IT ON (VATTBL.It_code =IT.It_code)
WHERE BHENT ='PT' AND ST_TYPE IN('LOCAL','') AND U_SHCODE = ' '--AND U_SHCODE <> 'Schedule-D'
and ( Date between @SDATE and @EDATE ) and PER =2 and itemtype ='C'  and S_TAX <> ''
  INSERT INTO #FORMANNEX3 (PART,PARTSR,SRNO ,RATE,AMT1  ,AMT2  ,AMT3,INV_NO,PARTY_NM)
                VALUES  (1   ,'1'   ,'A',0   ,@AMTA1,@AMTB1,0   ,'01. ','2% tax rate ' )
---02.5% tax rate
SET @AMTA1 = 0
SET @AMTB1 = 0
SELECT @AMTA1 = isnull(SUM(VATONAMT),0),@AMTB1=ISNULL(SUM(TAXAMT),0) FROM VATTBL 
LEFT OUTER JOIN IT_MAST IT ON (VATTBL.It_code =IT.It_code)
WHERE BHENT ='PT' AND ST_TYPE IN('LOCAL','') AND U_SHCODE = ' '--AND U_SHCODE <> 'Schedule-D'
and ( Date between @SDATE and @EDATE ) and PER =5 and itemtype ='C' and S_TAX <> '' 
  INSERT INTO #FORMANNEX3 (PART,PARTSR,SRNO ,RATE,AMT1  ,AMT2  ,AMT3,INV_NO,PARTY_NM)
                VALUES  (1   ,'1'   ,'A',0   ,@AMTA1,@AMTB1,0   ,'02.'    ,'5% tax rate' )
---13.5% tax rate
SET @AMTA1 = 0
SET @AMTB1 = 0
SELECT @AMTA1 = isnull(SUM(VATONAMT),0),@AMTB1=ISNULL(SUM(TAXAMT),0) FROM VATTBL 
LEFT OUTER JOIN IT_MAST IT ON (VATTBL.It_code =IT.It_code)
WHERE BHENT ='PT' AND ST_TYPE IN('LOCAL','') AND U_SHCODE = ' '--AND U_SHCODE <> 'Schedule-D'
and ( Date between @SDATE and @EDATE ) and PER =13.5 and itemtype ='C'  and S_TAX <> ''
  INSERT INTO #FORMANNEX3 (PART,PARTSR,SRNO ,RATE,AMT1  ,AMT2  ,AMT3,INV_NO,PARTY_NM)
                VALUES  (1   ,'1'   ,'A',0   ,@AMTA1,@AMTB1,0   ,'03.'    ,'13.5% tax rate ' )
---TOTAL OF PART-1
SET @AMTA1 = 0
SET @AMTB1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMt1),0),@AMTB1 = ISNULL(SUM(AMT2),0) FROM #FORMANNEX3 WHERE PART=1 AND PARTSR='1' AND SRNO ='A'
INSERT INTO #FORMANNEX3 (PART,PARTSR,SRNO       ,RATE,AMT1  ,AMT2  ,AMT3,INV_NO,PARTY_NM) 
                VALUES  (1   ,'1'   ,'A',0   ,@AMTA1,@AMTB1,0   ,'04.'    ,'Total' )

---part 2
---2% tax rate
SET @AMTA1 = 0
SET @AMTB1 = 0
SELECT @AMTA1 = isnull(SUM(VATONAMT),0),@AMTB1=ISNULL(SUM(TAXAMT),0) FROM VATTBL 
LEFT OUTER JOIN IT_MAST IT ON (VATTBL.It_code =IT.It_code)
WHERE BHENT ='PT' AND ST_TYPE IN('LOCAL','') AND U_SHCODE in('Schedule-D','Schedule D')
and ( Date between @SDATE and @EDATE ) and PER =2 and itemtype ='C'  and S_TAX <> ''
  INSERT INTO #FORMANNEX3 (PART,PARTSR,SRNO ,RATE,AMT1  ,AMT2  ,AMT3,INV_NO,PARTY_NM)
                VALUES  (1   ,'2'   ,'A',0   ,@AMTA1,@AMTB1,0   ,'05.'    ,'2% tax rate ' )
---02.5% tax rate
SET @AMTA1 = 0
SET @AMTB1 = 0
SELECT @AMTA1 = isnull(SUM(VATONAMT),0),@AMTB1=ISNULL(SUM(TAXAMT),0) FROM VATTBL 
LEFT OUTER JOIN IT_MAST IT ON (VATTBL.It_code =IT.It_code)
WHERE BHENT ='PT' AND ST_TYPE IN('LOCAL','') AND U_SHCODE in('Schedule-D','Schedule D')  and S_TAX <> ''
and ( Date between @SDATE and @EDATE ) and PER =5 and itemtype ='C'
  INSERT INTO #FORMANNEX3 (PART,PARTSR,SRNO ,RATE,AMT1  ,AMT2  ,AMT3,INV_NO,PARTY_NM)
                VALUES  (1   ,'2'   ,'A',0   ,@AMTA1,@AMTB1,0   ,'06.'    ,'5% tax rate' )
---13.5% tax rate
SET @AMTA1 = 0
SET @AMTB1 = 0
SELECT @AMTA1 = isnull(SUM(VATONAMT),0),@AMTB1=ISNULL(SUM(TAXAMT),0) FROM VATTBL 
LEFT OUTER JOIN IT_MAST IT ON (VATTBL.It_code =IT.It_code)
WHERE BHENT ='PT' AND ST_TYPE IN('LOCAL','') AND U_SHCODE in('Schedule-D','Schedule D')
and ( Date between @SDATE and @EDATE ) and PER =13.5 and itemtype ='C'  and S_TAX <> ''
  INSERT INTO #FORMANNEX3 (PART,PARTSR,SRNO ,RATE,AMT1  ,AMT2  ,AMT3,INV_NO,PARTY_NM)
                VALUES  (1   ,'2'   ,'A',0   ,@AMTA1,@AMTB1,0   ,'07.'    ,'13.5% tax rate ' )
---TOTAL OF PART-2 
SET @AMTA1 = 0
SET @AMTB1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMt1),0),@AMTB1 = ISNULL(SUM(AMT2),0) FROM #FORMANNEX3 WHERE PART=1 AND PARTSR='2' AND SRNO ='A'
INSERT INTO #FORMANNEX3 (PART,PARTSR,SRNO       ,RATE,AMT1  ,AMT2  ,AMT3,INV_NO,PARTY_NM)
                VALUES  (1   ,'2'   ,'A',0   ,@AMTA1,@AMTB1,0   ,'08.'    ,'Total' )

SET @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(CASE WHEN PARTSR='1' THEN +AMt2 ELSE -AMT2 END),0) FROM #FORMANNEX3 WHERE PART=1 AND PARTSR IN('2' ,'1') AND party_nm ='Total'

-----Excess credit carried forward to  subsequent tax period 
--Note Previous year data will come the this point(only one last year) 
SET @AMTB1 = 0
DECLARE @STARTDT SMALLDATETIME,@ENDDT SMALLDATETIME,@TMONTH INT,@TYEAR INT
SET @TMONTH=DATEDIFF(M,@SDATE,@EDATE)
SET @TYEAR=DATEDIFF(YY,@SDATE,@EDATE)
SET @STARTDT=DATEADD(Y,-@TYEAR,@STARTDT)
SET @STARTDT=DATEADD(M,-(@TMONTH+1),@SDATE)
SET @ENDDT=DATEADD(D,-1,@SDATE)

select @AMTB1=isnull(SUM(A.NET_AMT),0) FROM JVMAIN A WHERE A.ENTRY_TY='J4' AND A.VAT_ADJ='Excess credit carried forward to  subsequent tax period' AND (A.DATE BETWEEN @STARTDT AND @ENDDT)
and a.party_nm='Capital Goods'


Update #FORMANNEX3 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
					    RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
						AMT3 = isnull(@AMTA1,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
						PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
						FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,''),AMT4 = isnull(@AMTB1,0)
SELECT * FROM #FORMAnnex3 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END
