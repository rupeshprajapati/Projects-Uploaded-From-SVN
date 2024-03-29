IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME ='USP_REP_RJ_FORMVAT10')
BEGIN
	DROP PROCEDURE USP_REP_RJ_FORMVAT10
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
EXECUTE USP_REP_RJ_FORMVAT10'','','','04/01/2015','03/31/2016','','','','',0,0,'','','','','','','','','2015-2016',''
*/
-- =============================================
-- Author	   : Sumit.S.Gavate
-- Create date : 28/05/2016
-- Description : This stored procedure is useful to generate VAT FORM 10 of rajasthan state
-- Bug No	   : 28055
-- Modified By : 
-- Modify date : 
-- Remark	   :
-- =============================================

CREATE PROCEDURE [dbo].[USP_REP_RJ_FORMVAT10]
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
DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2)
---Temporary Cursor
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=B.NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=M.TAXAMT,M.INV_NO,M.DATE,M.U_LRNO, M.U_LRDT, M.FORM_NO,
M.FORMRDT, ITEM=space(150), M.U_PONO, M.U_PODT,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3), AC1.S_TAX,
B.U_DUE_DT,B.U_TAX_DEPO,B.U_DELAY,B.U_DT_INT,B.U_DESC
INTO #VATFORM10 FROM PTACDET A INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME) INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN STITEM S ON (M.entry_ty = S.entry_ty AND M.Tran_cd = S.Tran_cd AND A.inv_no = S.inv_no)
INNER JOIN BPMAIN B ON (A.entry_ty = B.entry_ty AND A.date = B.Date AND A.Tran_cd = B.Tran_cd)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID) WHERE 1=2

--Calling Single company store procedure for updating vattbl table - start
Declare @MCON as NVARCHAR(2000)
EXECUTE USP_REP_SINGLE_CO_DATA_VAT @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT,
		@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA,@MFCON = @MCON OUTPUT
--Calling Single company store procedure for updating vattbl table - end

-- B . Turnover
-- B1. Tax Liability
-- 1.1 Turnover under section 8(3) [Works Contract EC]
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'1','1',0,@AMTA1,0,0,'')

-- 1.2 Turnover under section 5(1) of RVAT Act (Composition Schemes)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'2','1',0,@AMTA1,0,0,'')

-- 1.3 Turnover under section 3(2) [in case opt out of section 3(2)].
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'3','1',PER,ISNULL(Sum(AMT1),0),0,0,it_name,'' FROM (
SELECT A.Per,(CASE WHEN A.BHENT='ST' THEN (CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END) ELSE
(CASE WHEN STAX.STAX_ITEM = 1 THEN -A.VATONAMT ELSE -A.Gro_Amt END) END) as AMT1,I.It_name FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST','SR','CN')
AND A.ST_TYPE = 'LOCAL' AND A.U_Imporm IN('Under Section 3(2)','u/s 3(2)') AND A.Date Between @sdate and @edate AND
LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''),'VAT',''))) NOT IN ('15','1 5','36 A','36A')
UNION
SELECT ISNULL(ST.LEVEL1,0) as PER,-(A.Gro_Amt - A.taxamt) as Gro_Amt,I.It_name FROM CNITEM A
INNER JOIN CNMAIN C   ON (A.entry_ty = C.Entry_Ty AND A.date = C.Date AND A.inv_no = C.Inv_no AND A.Tran_cd = C.Tran_cd)
INNER JOIN IT_MAST I  ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.Entry_Ty = STAX.Entry_ty)
INNER JOIN AC_MAST AC ON (A.Ac_id = AC.Ac_id) LEFT JOIN STAX_MAS ST ON (A.entry_ty = ST.entry_ty AND A.tax_name = ST.tax_name)
WHERE A.Entry_Ty IN('CN') AND AC.ST_TYPE = 'LOCAL' AND C.U_Imporm IN('Under Section 3(2)','u/s 3(2)') AND A.Date Between @sdate and @edate
AND LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(A.tax_name,'-',''),'FORM',''),'VAT',''))) NOT IN ('15','1 5','36 A','36A')) A
GROUP BY PER,It_name ORDER BY It_name,PER

IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '3')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'3','1',0,0,0,0,'')
END

-- 1.4 Sale of goods taxable at MRP (First sale within the state)
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
select 1,'4','1',A.Per,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),0,0,I.It_name,'' from VATTBL A
INNER JOIN STMAIN S ON (A.BHENT = S.Entry_ty AND A.Inv_no = S.inv_no AND A.TRAN_CD = S.Tran_cd AND A.Date = S.date)
INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) INNER JOIN IT_MAST I ON (A.It_code = I.it_code) WHERE A.Per > 0 AND
S.VATMTYPE = 'Sales MRP Based' AND A.U_IMPORM NOT IN ('Under Section 3(2)','u/s 3(2)') AND A.ST_TYPE = 'LOCAL' AND A.BHENT = 'ST'
AND LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''),'VAT',''))) NOT IN ('15','1 5','36 A','36A')
And A.Date Between @sdate and @edate GROUP BY A.Per,I.It_name ORDER BY I.It_name,A.PER

IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '4')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'4','1',0,0,0,0,'')
END

-- 1.5 Taxable sales
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm,FORM_NO)
select 1,'5','1',A.Per,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),0,0,I.It_name,'',I.rateunit from VATTBL A
INNER JOIN STMAIN S ON (A.BHENT = S.Entry_ty AND A.Inv_no = S.inv_no AND A.TRAN_CD = S.Tran_cd AND A.Date = S.date)
INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) INNER JOIN IT_MAST I ON (A.It_code = I.it_code) WHERE A.Per > 0 AND
S.VATMTYPE <> 'Sales MRP Based' AND A.U_IMPORM NOT IN ('Under Section 3(2)','u/s 3(2)') AND A.ST_TYPE = 'LOCAL' AND A.Tax_name like '%VAT%'
And A.Date Between @sdate and @edate AND A.BHENT = 'ST' GROUP BY A.Per,I.It_name,I.rateunit ORDER BY I.It_name,I.rateunit,A.PER

IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '5')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'5','1',0,0,0,0,'')
END

-- 1.6 Sales return of taxable goods within State under rule 22(1)(c) (other than return period)
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'6','1',A.Per,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),0,0,I.It_name,'' from VATTBL A
INNER JOIN SRITREF SRI on (A.BHENT = SRI.entry_ty AND A.TRAN_CD = SRI.Tran_cd AND A.It_code = SRI.It_Code AND A.ItSerial = SRI.Itserial)
INNER JOIN IT_MAST I ON (A.It_code = I.It_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT In('SR') AND
SRI.date BETWEEN SRI.RDate AND DateAdd(month,6,SRI.RDate) AND A.Tax_name like '%VAT%' AND SRI.rentry_ty = 'ST' and A.St_Type in('LOCAL')
AND A.U_Imporm <> 'Turnover of goods taxable at first point which have already suffered tax'
AND A.PER > 0 AND A.Taxamt > 0 AND (YEAR(A.Date) <> CAST(SUBSTRING(@LYN,1,4) As Int) OR YEAR(A.Date) <>  CAST(SUBSTRING(@LYN,6,4) as INT))
GROUP BY I.It_name,A.PER ORDER BY I.It_name,A.PER 

IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '6')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'6','1',0,0,0,0,'')
END

------
Update #VATFORM10 SET AMT2 = AMT1 * Rate / 100 WHERE PARTSR IN ('3','4','5','6')
------

-- 1.7 Output Tax
SELECT @AMTA1 = 0,@AMTA2 = 0,@AMTB1 = 0,@AMTB2 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0),@AMTA2 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PARTSR IN ('4','5')
SELECT @AMTB1 = ISNULL(SUM(AMT1),0),@AMTB2 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PARTSR IN ('6')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'7','1',0,@AMTA1-@AMTB1,@AMTA2 - @AMTB2,0,'')

-- 1.8 Turnover not liable to be Taxed
-- 1.8.1 Turnover under Rule 22(2a) (for sub contractors)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8','1',0,@AMTA1,0,0,'')

-- Other Turnover not liable to be Taxed
-- Exempted in Schedule-I (sold within state)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(A.GRO_AMT),0) FROM VATTBL A INNER JOIN IT_MAST I ON (A.it_code = I.it_code)
INNER JOIN STMAIN S ON (A.BHENT = S.entry_ty AND A.Date = S.date AND A.INV_NO = S.Inv_no AND A.Tran_cd = S.Tran_cd) WHERE
(A.BHENT='ST') AND A.ST_TYPE IN ('LOCAL') AND I.U_GVTYPE IN('Exempted in Schedule-I') AND A.Tax_NAME IN('Exempted','')
AND A.Date Between @sdate and @edate AND A.TaxAmt = 0 AND
S.U_IMPORM NOT IN ('Sales made for promotion of SEZ','Turnover of goods taxable at first point which have already suffered tax',
'Under Section 3(2)','u/s 3(2)')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','2',0,@AMTA1,0,0,'')

-- Fully Exempted in Schedule-II u/s 8(3) of RVAT ACT
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(A.GRO_AMT),0) FROM VATTBL A INNER JOIN IT_MAST I ON (A.it_code = I.it_code) 
INNER JOIN STMAIN S ON (A.BHENT = S.entry_ty AND A.Date = S.date AND A.INV_NO = S.Inv_no AND A.Tran_cd = S.Tran_cd) WHERE 
(A.BHENT='ST') AND A.ST_TYPE IN ('LOCAL') AND I.U_GVTYPE IN('Fully Exempted in Schedule-II u/s 8(3)') AND A.Tax_NAME IN('Exempted','')
AND A.Date Between @sdate and @edate AND A.TaxAmt = 0 AND
S.U_IMPORM NOT IN ('Sales made for promotion of SEZ','Turnover of goods taxable at first point which have already suffered tax',
'Under Section 3(2)','u/s 3(2)')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','3',0,@AMTA1,0,0,'')

-- Sales made for promotion of SEZ or Exports u/s 8(4) of RVAT ACT
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(A.GRO_AMT),0) FROM VATTBL A INNER JOIN IT_MAST I ON (A.it_code = I.it_code)
INNER JOIN STMAIN S ON (A.BHENT = S.entry_ty AND A.Date = S.date AND A.INV_NO = S.Inv_no AND A.Tran_cd = S.Tran_cd) WHERE
(A.BHENT='ST') AND A.ST_TYPE IN ('LOCAL') AND A.Date Between @sdate and @edate AND A.TaxAmt = 0
AND S.U_IMPORM = 'Sales made for promotion of SEZ'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','4',0,@AMTA1,0,0,'')

-- Sales of goods purchased & sold outside state
SELECT @AMTA1 = 0
Select @AMTA1 = ISNULL(SUM(A.GRO_AMT),0) from VATTBL A INNER JOIN (SELECT * FROM STITREF WHERE Rentry_ty = 'PT') SIT
ON (A.BHENT = SIT.entry_ty AND A.TRAN_CD = SIT.Tran_cd) WHERE A.ST_TYPE = 'OUT OF STATE' AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','5',0,@AMTA1,0,0,'')

-- Turnover of goods taxable at first point which have already suffered tax
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM
(SELECT ISNULL(Sum(CASE WHEN A.BHENT='ST' THEN (CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END) ELSE
(CASE WHEN STAX.STAX_ITEM = 1 THEN -A.VATONAMT ELSE -A.Gro_Amt END) END),0) as AMT1 FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) 
WHERE A.BHENT IN('ST','SR','CN') AND A.ST_TYPE = 'LOCAL' AND A.U_Imporm IN('Turnover of goods taxable at first point which have already suffered tax')
AND A.Tax_name  = '' AND A.TaxAmt = 0
UNION
SELECT - ISNULL(Sum(A.Gro_Amt),0) as AMT1 FROM CNITEM A INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN AC_MAST AC ON (A.Ac_id = AC.Ac_id)
INNER JOIN CNMAIN C ON (A.entry_ty = C.Entry_Ty AND A.date = C.Date AND A.inv_no = C.Inv_no AND A.Tran_cd = C.Tran_cd) WHERE A.Entry_Ty IN('CN')
AND AC.ST_TYPE = 'LOCAL' AND C.U_Imporm IN('Turnover of goods taxable at first point which have already suffered tax')
AND A.Tax_name  = '' AND A.TaxAmt = 0) B
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','6',0,@AMTA1,0,0,'')

-- Turnover of goods sold in the state on behalf of principal (against Form VAT 36A)
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULL(Sum(CASE WHEN A.BHENT='ST' THEN (CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END) ELSE
(CASE WHEN STAX.STAX_ITEM = 1 THEN -A.VATONAMT ELSE -A.Gro_Amt END) END),0) FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST','SR','CN') AND
A.ST_TYPE = 'LOCAL' AND LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''),'VAT',''))) IN ('36 A','36A')
AND A.Date Between @sdate and @edate
SELECT @AMTA2 = ISNULL(Sum(A.Gro_Amt),0) FROM CNITEM A INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN AC_MAST AC ON (A.Ac_id = AC.Ac_id)
INNER JOIN CNMAIN C ON (A.entry_ty = C.Entry_Ty AND A.date = C.Date AND A.inv_no = C.Inv_no AND A.Tran_cd = C.Tran_cd) WHERE A.Entry_Ty IN('CN')
AND AC.ST_TYPE = 'LOCAL' AND LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(A.tax_name,'-',''),'FORM',''),'VAT',''))) IN ('36 A','36A')
AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','7',0,@AMTA1 - @AMTA2,0,0,'')

-- Amount of deductions as provided in RVAT rules (in case of works Contracts)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','8',0,@AMTA1,0,0,'')

-- Sales to Exporters within the state (against FormVAT-15)
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULL(Sum(CASE WHEN A.BHENT='ST' THEN (CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END) ELSE
(CASE WHEN STAX.STAX_ITEM = 1 THEN -A.VATONAMT ELSE -A.Gro_Amt END) END),0) FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST','SR','CN') AND
A.ST_TYPE = 'LOCAL' AND LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''),'VAT',''))) IN ('15','1 5')
AND A.Date Between @sdate and @edate
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA2 = ISNULL(Sum(A.Gro_Amt),0) FROM CNITEM A INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN AC_MAST AC ON (A.Ac_id = AC.Ac_id)
INNER JOIN CNMAIN C ON (A.entry_ty = C.Entry_Ty AND A.date = C.Date AND A.inv_no = C.Inv_no AND A.Tran_cd = C.Tran_cd) WHERE A.Entry_Ty IN('CN')
AND AC.ST_TYPE = 'LOCAL' AND LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(A.Tax_name,'-',''),'FORM',''),'VAT',''))) IN ('15','1 5')
AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','9',0,@AMTA1 - @AMTA2,0,0,'')

-- Others not liable to tax under VAT (please specify)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','10',0,@AMTA1,0,0,'')

-- Turnover of sales return of goods sold within the return period under RVAT
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0) FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('SR') AND A.ST_TYPE = 'LOCAL' AND
LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''),'VAT',''))) NOT IN ('36A','36 A','15','1 5') AND A.Date Between @sdate and @edate AND
U_Imporm NOT IN('Turnover of goods taxable at first point which have already suffered tax','Under Section 3(2)','u/s 3(2)')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8A','11',0,@AMTA1,0,0,'')

--Total & Total Turnover b (1.1+ 1.2 +1.3 + 1.4 +1.5+1.8)
SELECT @AMTA1 = 0,@AMTA2 = 0
Select @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PARTSR = '8A'
Select @AMTA2 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PARTSR IN('1','2','3','4','5','8A')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8AF','1',0,@AMTA1,@AMTA2,0,'')

-- B2. Purchase Tax
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'8B','1',A.Per,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,
I.It_name,'' FROM VATTBL A INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty)
WHERE A.BHENT IN('PT') AND A.S_TAX = ' ' AND A.ST_TYPE = 'LOCAL' AND A.Tax_name LIKE '%VAT%' AND A.Date Between @sdate and @edate
GROUP BY A.Per,I.It_name ORDER BY I.It_name,A.PER

IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '8B')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8B','1',0,0,0,0,'')
END

-- B3. Reverse Tax
-- Return of goods purchased (other than the return period)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'8C','1',A.Per,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('PR')
And (YEAR(A.Date) <> CAST(SUBSTRING(@LYN,1,4) As Int) OR YEAR(A.Date) <>  CAST(SUBSTRING(@LYN,6,4) as INT))
AND A.ST_TYPE = 'LOCAL' AND A.Tax_name LIKE '%VAT%' GROUP BY A.Per,I.It_name ORDER BY I.It_name,A.PER

IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '8C' AND SRNO = '1')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8C','1',0,0,0,0,'')
END

-- Goods purchased for a purpose specified in Section 18 (1) (a) to (g) and disposed off otherwise including non-allowable proportionate ITC
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
Select 1,'8C','2',A.Per,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,''
from VATTBL A INNER JOIN (SELECT * FROM STITREF WHERE Rentry_ty = 'PT') SIT ON
(A.BHENT = SIT.entry_ty AND A.TRAN_CD = SIT.Tran_cd AND A.It_code = SIT.It_code AND A.ItSerial = SIT.Itserial)
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.TAXAMT > 0
AND A.Date Between @sdate and @edate AND A.ST_TYPE = 'LOCAL' AND A.Tax_name LIKE '%VAT%'
GROUP BY A.Per,I.It_name ORDER BY I.It_name,A.PER

IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '8C' AND SRNO = '2')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8C','2',0,0,0,0,'')
END

-- In case of SOS (up to 4%) ------ %
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8C','3',0,@AMTA1,0,0,'')

-- Stocks remained in case of switch over to option u/s3(2) [See Rule17(3)]
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8C','4',0,@AMTA1,0,0,'')

-- In any other case (Please specify)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8C','5',0,@AMTA1,0,0,'')

-- B3 Total 1.2 to 1.5
SELECT @AMTA1 = 0,@AMTA2 = 0
Select @AMTA1 = ISNULL(SUM(AMT1),0),@AMTA2 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '8C' AND SRNO IN ('2','3','4','5')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8CF','1',0,@AMTA1,@AMTA2,0,'')

-- B4.1.1 INPUT TAX & DETAILS OF PURCHASES
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'8D','1',A.Per,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('PT') AND A.S_TAX <> ' ' AND I.vatcap = 0
And A.Date Between @sdate and @edate AND A.ST_TYPE = 'LOCAL' AND A.Tax_name LIKE '%VAT%' GROUP BY A.Per,I.It_name ORDER BY I.It_name,A.PER

IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '8D' AND SRNO = '1')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'8D','1',0,0,0,0,'')
END

-- 1.2 Purchases of Capital Goods
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'9','1',A.Per,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('PT') AND A.S_TAX <> ' ' AND I.vatcap = 1
And A.Date Between @sdate and @edate AND A.ST_TYPE = 'LOCAL' AND A.Tax_name LIKE '%VAT%' GROUP BY A.Per,I.It_name ORDER BY I.It_name,A.PER

IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '9' AND SRNO = '1')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'9','1',0,0,0,0,'')
END


-- 1.3 Total (1.1 to 1.2)
-- 1.4 ITC Claimed in 7A by the Dealer
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULl(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR IN('8D','9')
SELECT @AMTA2 = ISNULL(SUM(A.TAXAMT),0) FROM VATTBL A INNER JOIN PTMAIN P ON (A.TRAN_cD=P.TRAN_cD AND A.BHENT=P.ENTRY_tY)
WHERE  A.BHENT='PT' AND A.ST_TYPE='LOCAL' AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'10','4',0,@AMTA1,@AMTA2,0,'')

-- 1.5 Purchase return (Purchased within the return period)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(A.TAXAMT),0) FROM VATTBL A WHERE A.BHENT IN('PR') AND A.ST_TYPE = 'LOCAL' AND A.Date Between @sdate and @edate
AND (YEAR(A.Date) <> CAST(SUBSTRING(@LYN,1,4) As Int) OR YEAR(A.Date) <>  CAST(SUBSTRING(@LYN,6,4) as INT))
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'10','5',0,0,@AMTA1,0,'')

-- 1.6 Total eligible input tax credit (1.4 -1.5)
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULL(Sum(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '10' AND SRNO = '4'
SELECT @AMTA2 = ISNULL(Sum(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '10' AND SRNO = '5'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'11','6',0,@AMTA1 - @AMTA2,0,0,'')

-- 1.7 Amount of ITC Brought forward (From previous return)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(A.Net_AMT),0) FROM VATTBL A INNER JOIN JVMAIN J ON (A.Bhent = J.entry_ty AND A.TRAN_CD = J.Tran_cd AND A.INV_NO = J.inv_no)
WHERE A.BHENT = 'J4' AND J.VAT_ADJ = 'Amount of ITC Brought forward (From previous return)' AND A.AC_NAME = 'Vat Payable'
AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'11A','7',0,@AMTA1,0,0,'')

-- 1.8 Total Input Tax Credit Available (1.6 + 1.7)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR IN('11','11A')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'11A','8',0,@AMTA1,0,0,'')

-- C. Turnover and Liability under CST
-- 1.1 Tax Liability under CST
-- Inter-State sale against Form C @2%
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'12','1',2,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST')
AND A.ST_TYPE = 'OUT OF STATE' AND A.Per = 2 AND LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) = 'C' AND A.S_TAX <> ' '
AND A.U_IMPORM NOT IN ('Subsequent Inter State sales u/s 6(2)','Under section 6(3)','Sales made to SEZ under section 8(6)')
AND A.Date Between @sdate and @edate GROUP BY I.It_name ORDER BY I.It_name
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO = '1')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','1',0,0,0,0,'')
END

-- Inter-State sale against Form C @%
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'12','2',A.Per,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST')
AND A.ST_TYPE = 'OUT OF STATE' AND A.Per NOT IN (2,0) AND LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) = 'C'
AND A.U_IMPORM NOT IN ('Subsequent Inter State sales u/s 6(2)','Under section 6(3)','Sales made to SEZ under section 8(6)')
AND A.Date Between @sdate and @edate GROUP BY I.It_name,A.Per ORDER BY I.It_name,A.Per
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO = '2')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','2',0,0,0,0,'')
END

-- Inter-State sale without Form C @%
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'12','3',A.PER,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST')
AND A.ST_TYPE = 'OUT OF STATE' AND A.Per > 0 AND LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) <> 'C' AND A.S_TAX <> ' '
AND A.U_IMPORM NOT IN ('Subsequent Inter State sales u/s 6(2)','Under section 6(3)','Sales made to SEZ under section 8(6)')
AND (A.Tax_name LIKE '%CST%' OR A.Tax_name LIKE '%C.S.T%') AND A.Date Between @sdate and @edate GROUP BY I.It_name,A.Per ORDER BY I.It_name,A.Per
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO = '3')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','3',0,0,0,0,'')
END

-- Sales outside State Branch/Depot/Stock Transfer/Consignment Sale (without Form F@ %)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'12','4',0,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST')
AND A.ST_TYPE = 'OUT OF STATE' AND LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) <> 'F' 
AND A.U_IMPORM IN ('Branch Transfer','Consignment Transfer') AND A.S_TAX <> ' '
AND (A.Tax_name LIKE '%CST%' OR A.Tax_name LIKE '%C.S.T%') AND A.Date Between @sdate and @edate GROUP BY I.It_name ORDER BY I.It_name
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO = '4')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','4',0,0,0,0,'')
END

-- Subsequent Inter State sales u/s 6(2) of CST Act (without Form C/E I/ E II)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'12','5',0,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST') AND A.S_TAX <> ' '
AND A.ST_TYPE = 'OUT OF STATE' AND LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) NOT IN ('C','E I','E II','EI','EII','E1','E2','E 1','E 2')
AND A.U_IMPORM IN ('Subsequent Inter State sales u/s 6(2)') AND (A.Tax_name LIKE '%CST%' OR A.Tax_name LIKE '%C.S.T%') AND
A.Date Between @sdate and @edate GROUP BY I.It_name ORDER BY I.It_name
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO = '5')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','5',0,0,0,0,'')
END

-- Inter State sales under section 6(3) of CST Act (without Form J)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'12','6',0,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST')
AND A.ST_TYPE = 'OUT OF STATE' AND LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) NOT IN ('J') AND A.S_TAX <> ' '
AND A.U_IMPORM IN ('Under section 6(3)') AND (A.Tax_name LIKE '%CST%' OR A.Tax_name LIKE '%C.S.T%') AND
A.Date Between @sdate and @edate GROUP BY I.It_name ORDER BY I.It_name
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO = '6')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','6',0,0,0,0,'')
END

-- Inter State sales made to SEZ under section 8(6) of CST ACT (without Form I)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'12','7',0,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('ST')
AND A.ST_TYPE = 'OUT OF STATE' AND LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) NOT IN ('I') AND A.S_TAX <> ' '
AND A.U_IMPORM IN ('Sales made to SEZ under section 8(6)') AND (A.Tax_name LIKE '%CST%' OR A.Tax_name LIKE '%C.S.T%') AND
A.Date Between @sdate and @edate GROUP BY I.It_name ORDER BY I.It_name
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO = '7')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','7',0,0,0,0,'')
END

-- Other @...............
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','8',0,@AMTA1,0,0,'')

-- Total (1.1.1 to1.1.9)
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0),@AMTA2 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO IN ('1','2','3','4','5','6','7','8')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','9',0,@AMTA1,@AMTA2,0,'')

-- Sales return of taxable goods under section 8A of CST ACT (other than return period)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Item,Party_nm)
SELECT 1,'12','10',0,ISNULL(Sum(CASE WHEN STAX.STAX_ITEM = 1 THEN A.VATONAMT ELSE A.Gro_Amt END),0),ISNULL(Sum(A.TaxAmt),0),0,I.It_name,'' FROM VATTBL A
INNER JOIN IT_MAST I ON (A.It_code = I.it_code) INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT IN('SR') AND A.S_TAX <> ' '
AND (YEAR(A.Date) <> CAST(SUBSTRING(@LYN,1,4) As Int) OR YEAR(A.Date) <>  CAST(SUBSTRING(@LYN,6,4) as INT))
AND A.ST_TYPE = 'OUT OF STATE' AND (A.Tax_name LIKE '%CST%' OR A.Tax_name LIKE '%C.S.T%') AND A.U_IMPORM = 'Under section 8A'
GROUP BY I.It_name ORDER BY I.It_name
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO = '10')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12','10',0,0,0,0,'')
END

-- Total CST (1.1.9 -1.1.10)
SELECT @AMTA1 = 0, @AMTA2 = 0,@AMTB1 = 0,@AMTB2 = 0 
SELECT @AMTA1 = ISNULL(SUM(AMT1),0),@AMTB1 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO IN('9')
SELECT @AMTA2 = ISNULL(SUM(AMT1),0),@AMTB2 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12' AND SRNO IN('10')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'12A','1',0,@AMTA1 - @AMTA2,@AMTB1 - @AMTB2,0,'')

-- 1.2 Turnover not liable to tax under CST
-- Sales in course of Export U/s 5(3) of CST ACT,(against Form H)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(A.Gro_Amt),0) FROM VATTBL A
INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT = 'ST' AND A.St_Type = 'OUT OF COUNTRY'
AND LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) IN ('H') AND A.U_IMPORM = 'Export U/s 5(3)'
AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'13','1',0,@AMTA1,0,0,'')

-- Sales in course of Export U/s 5(1) of CST ACT
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(A.Gro_Amt),0) FROM VATTBL A
INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT = 'ST' AND A.St_Type = 'OUT OF COUNTRY'
AND A.U_IMPORM = 'Export U/s 5(1)' AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'13','2',0,@AMTA1,0,0,'')

-- Sales outside State/Branch/Depot/Stock Transfer/Consignment Sale (against Form F)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(A.Gro_Amt),0) FROM VATTBL A
INNER JOIN lcode STAX ON (A.BHENT = STAX.Entry_ty) WHERE A.BHENT = 'ST' AND A.St_Type = 'OUT OF STATE'
AND LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) IN ('F') AND A.U_IMPORM IN('Branch Transfer','Consignment Transfer')
AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'13','3',0,@AMTA1,0,0,'')

-- Subsequent Inter State sales u/s 6(2) of CST ACT(against Form C and EI/ E II)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(A.Gro_Amt),0) FROM VATTBL A WHERE A.BHENT IN('ST') AND A.ST_TYPE = 'OUT OF STATE' AND
LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) IN ('C','E I','E II','EI','EII','E1','E2','E 1','E 2')
AND A.U_IMPORM IN ('Subsequent Inter State sales u/s 6(2)') AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'13','4',0,@AMTA1,0,0,'')

-- Inter State sales under section 6(3) of CST ACT (against Form J)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(A.Gro_Amt),0) FROM VATTBL A WHERE A.BHENT IN('ST') AND A.ST_TYPE = 'OUT OF STATE' AND
LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) IN ('J') AND A.U_IMPORM IN ('Under section 6(3)') AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'13','5',0,@AMTA1,0,0,'')

-- Inter State sales made to SEZ under section 8(6) of CST ACT (against Form I)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(A.Gro_Amt),0) FROM VATTBL A WHERE A.BHENT IN('ST') AND A.ST_TYPE = 'OUT OF STATE' AND
LTRIM(RTRIM(REPLACE(REPLACE(A.RFORM_NM,'-',''),'FORM',''))) IN ('I') AND A.U_IMPORM IN ('Sales made to SEZ under section 8(6)')
AND A.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'13','6',0,@AMTA1,0,0,'')

-- Exempted Sales under CST ACT
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(Sum(A.Gro_Amt),0) FROM VATTBL A WHERE A.BHENT IN('ST') AND A.ST_TYPE = 'OUT OF STATE' AND
A.Date Between @sdate and @edate AND A.tax_name  = 'Exempted' 
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'13','7',0,@AMTA1,0,0,'')

-- Other deductions, if any, (Please specify)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'13','8',0,@AMTA1,0,0,'')

-- 1.2 Total
SELECT @AMTA1 = 0,@AMTA2 = 0,@AMTB1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '13'
-- 1.3 Turnover of sales return of goods sold within the return period under CST
SELECT @AMTA2 = ISNULL(Sum(A.Gro_Amt),0) FROM VATTBL A WHERE A.BHENT IN('SR')
AND A.ST_TYPE = 'OUT OF STATE' AND A.Date Between @sdate and @edate AND A.U_IMPORM <> 'Under section 8A'

Select @AMTB1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR IN ('12A') AND SRNO IN ('1')

INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'13A','1',0,@AMTA1,@AMTA2,@AMTA1 + @AMTA2 + @AMTB1,'')

-- D -Details of Tax due and Deposit of Tax, Interest and Late Fee
-- 1. Tax Payable (Category of Payment)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,FORM_NO,Date,inv_no)
SELECT 1,'14','1',0,ISNULL(SUM(A.NET_AMT),0),0,0,A.ac_name,CASE WHEN A.ac_name = 'Vat Payable' THEN 'VAT' ELSE 'CST' END,A.Date,A.Inv_no
FROM VATTBL A INNER JOIN BPMAIN B ON (A.Tran_cd = B.Tran_cd AND A.INV_NO = B.inv_no AND A.Date = B.date) WHERE A.BHENT = 'BP' AND
A.AC_NAME IN ('Vat Payable','CST PAYABLE') AND A.Date Between @sdate and @edate AND B.tdspaytype <> 3
GROUP BY A.ac_name,A.Date,A.Inv_no ORDER BY A.Date,A.Inv_no,A.AC_NAME
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '14' AND SRNO = '1')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'14','1',0,0,0,0,'')
END

-- 2. Details of Deposit-(VAT-37B, VAT-38, VAT-41(TDSC), VAT- 25(RAO) etc.)
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm,FORM_NO,Date,inv_no,U_DUE_DT,U_TAX_DEPO,U_DELAY,U_DT_INT,U_DESC)
SELECT 1,'15','1',0,ISNULL(SUM(A.NET_AMT),0),ISNULL(SUM(A.TAXAMT),0),0,A.ac_name,CASE WHEN A.ac_name = 'Vat Payable' THEN 'VAT' ELSE 'CST' END,
A.Date,A.Inv_no,B.U_DUE_DT,B.U_TAX_DEPO,B.U_DELAY,B.U_DT_INT,B.U_DESC FROM VATTBL A
INNER JOIN BPMAIN B ON (A.Tran_cd = B.Tran_cd AND A.INV_NO = B.inv_no AND A.Date = B.date) WHERE A.BHENT = 'BP' AND
A.AC_NAME IN ('Vat Payable','CST PAYABLE') AND A.Date Between @sdate and @edate AND B.tdspaytype = 3
GROUP BY A.ac_name,A.Date,A.Inv_no,B.U_DUE_DT,B.U_TAX_DEPO,B.U_DELAY,B.U_DT_INT,B.U_DESC ORDER BY A.Date,A.Inv_no,A.AC_NAME
IF NOT EXISTS (SELECT Distinct PARTSR  FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '15' AND SRNO = '1')
BEGIN
	INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'15','1',0,0,0,0,'')
END

-- 3. DETAIL OF VAT-41/ T.D.S. CERTIFICATES
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'16','1',0,@AMTA1,0,0,'')

-- 4. Details of Late Fee
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'17','1',0,@AMTA1,0,0,'')

-- E. Tax Payable
-- Output Tax (B1-d1.7)
SELECT @AMTA1 = 0
SELECT @AMTA1  = ISNULL(AMT2,0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '7'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','1',0,@AMTA1,0,0,'')

-- Tax collected as per sales invoice
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(TAXAMT),0) FROM VATTBL WHERE BHENT = 'ST' AND ST_TYPE = 'LOCAL' AND TAX_NAME LIKE '%VAT%'
AND Date Between @sdate and @edate AND TAXAMT <> 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','2',0,@AMTA1,0,0,'')

-- Output tax (maximum of 1.1 and 1.2)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','3',0,@AMTA1,0,0,'')

-- Purchase tax (B2)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '8B'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','4',0,@AMTA1,0,0,'')

-- Reverse Tax (B3)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '8C' AND SRNO IN ('2','3','4','5')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','5',0,@AMTA1,0,0,'')

-- Others, If any, (Specify)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','6',0,@AMTA1,0,0,'')

-- Total Tax (1.3 to 1.6)
SELECT @AMTA1 = 0.
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('3','4','5','6')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','7',0,@AMTA1,0,0,'')

-- Total input tax credit available (B4.1.8)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '11A' AND SRNO IN ('8')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','8',0,@AMTA1,0,0,'')

-- Net Tax Payable (1.7 –1.8)
SELECT @AMTA1 = 0,@AMTA2= 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('7')
SELECT @AMTA2 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('8')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','9',0,@AMTA1 - @AMTA2,0,0,'')

-- Tax Deferred in Percent (under VAT)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','10',0,@AMTA1,0,0,'')

-- Tax Deferred (under VAT)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','11',0,@AMTA1,0,0,'')

-- Amount Payable (+)/Creditable (1.9 - 1.11)
SELECT @AMTA1 = 0,@AMTA2= 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('9')
SELECT @AMTA2 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('11')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','12',0,@AMTA1 - @AMTA2,0,0,'')

-- Exemption Fee (in case of works contract)(B 1.1d)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','13',0,@AMTA1,0,0,'')

-- Composition Fee (B1.1.2 d)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','14',0,@AMTA1,0,0,'')

-- Tax Payable on Turnover under section 3(2) [in case opt out of section 3(2)] (B1.1.3 d)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '3'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','15',0,@AMTA1,0,0,'')

-- Total Amount Payable(+)/Creditable (-)(1.12+ 1.13+1.14+1.15)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('12','13','14','15')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','16',0,@AMTA1,0,0,'')

-- Amount Deposited Under VAT
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '15' AND FORM_NO = 'VAT'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','17',0,@AMTA1,0,0,'')

-- Amount Payable (+)/Creditable (-) (1.14 - 1.15)
SELECT @AMTA1 = 0,@AMTA2= 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('14')
SELECT @AMTA2 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('15')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','18',0,@AMTA1 - @AMTA2,0,0,'')

-- Tax due under CST ACT (C-1.1)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT2),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '12A'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','19',0,@AMTA1,0,0,'')

-- Tax Collected as per sales invoice
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(TAXAMT),0) FROM VATTBL WHERE BHENT = 'ST' AND ST_TYPE = 'OUT OF STATE' AND TAXAMT <> 0 AND
(TAX_NAME LIKE '%CST%' OR TAX_NAME LIKE '%C.S.T%') AND Date Between @sdate and @edate --AND S_TAX = ' '
--AND LTRIM(RTRIM(REPLACE(REPLACE(RFORM_NM,'-',''),'FORM',''))) NOT IN ('C','H','F','C','EI','EII','E 1','E 2','E1','E2','J','I') AND
--U_IMPORM NOT IN ('Branch Transfer','Consignment Transfer','Subsequent Inter State sales u/s 6(2)','Under section 6(3)','Sales made to SEZ under section 8(6)')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','20',0,@AMTA1,0,0,'')

-- Maximum of 1.20 and 1.21
SELECT @AMTA1 = 0,@AMTA2= 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('19')
SELECT @AMTA2 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN ('20')
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','21',0,CASE WHEN @AMTA1 > @AMTA2 THEN @AMTA1 ELSE @AMTA2 END,0,0,'')

-- Tax Deferred in percent (Under CST)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','22',0,@AMTA1,0,0,'')

-- Tax Deferred (Under CST)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','23',0,@AMTA1,0,0,'')

-- Set off of Entry Tax paid (Only in case of CST for commodity like paper, Dyes and dyes stuff, Textile auxiliaries, 
-- Edible oil notified under section 8 (5) of CST ACT)
SELECT @AMTA1 = 0
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','24',0,@AMTA1,0,0,'')

-- CST to be deposited
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '15' AND FORM_NO = 'CST'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','25',0,@AMTA1,0,0,'')

-- Creditable ITC to be adjusted
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO = '18'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','26',0,@AMTA1,0,0,'')

-- CST payable (1.27 - 1.28)
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO = '25'
SELECT @AMTA2 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO = '18'
SET @AMTA2 = CASE WHEN @AMTA2 < 0 THEN ABS(@AMTA2) ELSE @AMTA2 END
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','27',0,@AMTA1 - @AMTA2,0,0,'')

-- Amount Deposited Under CST
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO IN('23','24')
SELECT @AMTA2 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO = '21'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','28',0,@AMTA2 - @AMTA1,0,0,'')

-- Net Tax payable / creditable (1.29 - 1.30 )
SELECT @AMTA1 = 0,@AMTA2 = 0
SELECT @AMTA1 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO = '27'
SELECT @AMTA2 = ISNULL(SUM(AMT1),0) FROM #VATFORM10 WHERE PART = 1 AND PARTSR = '18' AND SRNO = '28'
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','29',0,@AMTA1 - @AMTA2,0,0,'')

-- Refund claimed (if any)
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(a.VATONAMT),0) from (Select DISTINCt INV_NO,TRAN_CD,BHENT,Date,VATONAMT,TAXAMT from VATTBL where BHENT = 'J4'
AND AC_NAME = 'Vat Payable') a inner join JVMAIN b on a.tran_cd=b.tran_cd  and a.bhent=b.entry_ty
INNER JOIN ac_mast ac on ac.ac_id=b.ac_id and A.BHENT=B.ENTRY_TY
INNER JOIN (SELECT DISTINCT entry_ty,INV_NO,TRAN_CD from JVACDET where entry_ty = 'J4' AND AC_NAME = 'Vat Payable') j  on j.tran_cd=b.tran_cd and j.entry_ty=b.entry_Ty 
WHERE a.BHENT='J4' AND RTRIM(LTRIM(B.VAT_ADJ))='Refund Claim' AND a.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','30',0,@AMTA1,0,0,'')

-- ITC to be carried forward for next quarter
SELECT @AMTA1 = 0
SELECT @AMTA1 = ISNULL(SUM(a.VATONAMT),0) from (Select DISTINCt INV_NO,TRAN_CD,BHENT,Date,VATONAMT,TAXAMT from VATTBL where BHENT = 'J4'
AND AC_NAME = 'Vat Payable') a inner join JVMAIN b on a.tran_cd=b.tran_cd  and a.bhent=b.entry_ty
INNER JOIN ac_mast ac on ac.ac_id=b.ac_id and A.BHENT=B.ENTRY_TY
INNER JOIN (SELECT DISTINCT entry_ty,INV_NO,TRAN_CD from JVACDET where entry_ty = 'J4' AND AC_NAME = 'Vat Payable') j  on j.tran_cd=b.tran_cd and j.entry_ty=b.entry_Ty 
WHERE a.BHENT='J4' AND RTRIM(LTRIM(B.VAT_ADJ))='ITC to be carried forward for next quarter' AND a.Date Between @sdate and @edate
INSERT INTO #VATFORM10 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,Party_nm) VALUES (1,'18','31',0,@AMTA1,0,0,'')

Update #VATFORM10 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0),
AMT2 = isnull(AMT2,0),AMT3 = isnull(AMT3,0), AMT4 = isnull(AMT4,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''),PARTY_NM = isnull(Party_nm,''),
ADDRESS = isnull(Address,''),ITEM = isnull(ITEM,''),U_LRNO = isnull(U_LRNO,''), U_LRDT = isnull(U_LRDT,''),U_PONO = isnull(U_PONO,''),
U_PODT = isnull(U_PODT,''),FORM_NO = isnull(form_nO,''), FORMRDT = isnull(FORMRDT,''), S_TAX = isnull(S_tax,'')

SELECT * FROM #VATFORM10 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int),
partsr,cast(SRNO AS INT)

END
DROP TABLE #VATFORM10
set ANSI_NULLS OFF