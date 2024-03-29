IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE='P' AND name = 'USP_REP_BR_VATCHALLAN')
	BEGIN
		DROP PROCEDURE USP_REP_BR_VATCHALLAN
	END
GO
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Hetal L. Patel
-- Create date: 08/07/2009
-- Description:	This Stored procedure is useful to generate BR VAT CHALLAN
-- Modify date: 
-- Modified By: GAURAV R. TANNA - Bug : 26614
-- Modify date: 23/07/2015
-- Remark:
-- =============================================
CREATE PROCEDURE [dbo].[USP_REP_BR_VATCHALLAN]
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


Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		 Set @MultiCo = 'YES'
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		 --EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		 -- @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 --,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 --,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 --,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 --,@MFCON = @MCON OUTPUT
		 
		 SELECT A.U_CHALNO, A.U_CHALDT, A.BANK_NM, M.S_TAX AS BRANCH, M.BSRCODE, A.PARTY_NM,
	 	 (
	 	 SELECT IsNull(Sum(B.GRO_AMT),0) FROM BPMAIN B
	 	 INNER JOIN AC_MAST A1 ON (A1.AC_NAME = B.BANK_NM)
		 WHERE A.U_CHALNO = B.U_CHALNO AND A.U_CHALDT = B.U_CHALDT AND A.BANK_NM = B.BANK_NM  AND A1.S_TAX = M.S_TAX
		 AND (B.U_NATURE in ('','CST') And B.TDSPAYTYPE <> 2)
		 ) AS TAXAMT,
		 (
		 SELECT IsNull(Sum(C.GRO_AMT),0) FROM BPMAIN C
		 INNER JOIN AC_MAST A2 ON (A2.AC_NAME = C.BANK_NM)
		 WHERE A.U_CHALNO = C.U_CHALNO AND A.U_CHALDT = C.U_CHALDT AND A.BANK_NM = C.BANK_NM AND A2.S_TAX = M.S_TAX
		 AND C.U_NATURE = 'PENALTY'  And C.TDSPAYTYPE <> 2
		 ) AS PENALTYAMT,
		 (
		 SELECT IsNull(Sum(D.GRO_AMT),0) FROM BPMAIN D
		 INNER JOIN AC_MAST A3 ON (A3.AC_NAME = D.BANK_NM)
		 WHERE A.U_CHALNO = D.U_CHALNO AND A.U_CHALDT = D.U_CHALDT AND A.BANK_NM = D.BANK_NM AND A3.S_TAX = M.S_TAX
		 AND D.U_NATURE = 'COMPOSITION MONEY'  And D.TDSPAYTYPE <> 2
		 ) AS COMPOSAMT,
		 (
		 SELECT IsNull(Sum(E.GRO_AMT),0) FROM BPMAIN E
		 INNER JOIN AC_MAST A4 ON (A4.AC_NAME = E.BANK_NM)
		 WHERE A.U_CHALNO = E.U_CHALNO AND A.U_CHALDT = E.U_CHALDT AND A.BANK_NM = E.BANK_NM AND A4.S_TAX = M.S_TAX
		 AND E.U_NATURE = 'INTEREST'  And E.TDSPAYTYPE <> 2
		 ) AS INTAMT,
		 (
		 SELECT IsNull(Sum(F.GRO_AMT),0) FROM BPMAIN F
		 INNER JOIN AC_MAST A5 ON (A5.AC_NAME = F.BANK_NM)
		 WHERE A.U_CHALNO = F.U_CHALNO AND A.U_CHALDT = F.U_CHALDT AND A.BANK_NM = F.BANK_NM AND A5.S_TAX = M.S_TAX
		 AND F.TDSPAYTYPE = 2
		 ) AS ADVAMT,
		 (
		 SELECT IsNull(Sum(G.GRO_AMT),0) FROM BPMAIN G
		 INNER JOIN AC_MAST A6 ON (A6.AC_NAME = G.BANK_NM)
		 WHERE A.U_CHALNO = G.U_CHALNO AND A.U_CHALDT = G.U_CHALDT AND A.BANK_NM = G.BANK_NM AND  A6.S_TAX = M.S_TAX
		 AND G.U_NATURE Not in ('','CST', 'PENALTY','COMPOSITION MONEY','INTEREST','Assessed/Re-assessed Tax','Appeal Fee','Revision Fee','Registration Fees') And G.TDSPAYTYPE <> 2
		 ) AS OTHERAMT,
		 (
		 SELECT IsNull(Sum(H.GRO_AMT),0) FROM BPMAIN H
		 INNER JOIN AC_MAST A7 ON (A7.AC_NAME = H.BANK_NM)
		 WHERE A.U_CHALNO = H.U_CHALNO AND A.U_CHALDT = H.U_CHALDT AND A.BANK_NM = H.BANK_NM AND A7.S_TAX = M.S_TAX
		 AND H.U_NATURE = 'Assessed/Re-assessed Tax'  And H.TDSPAYTYPE <> 2
		 ) AS ASSESSAMT,
		 (
		 SELECT IsNull(Sum(I.GRO_AMT),0) FROM BPMAIN I
		 INNER JOIN AC_MAST A8 ON (A8.AC_NAME = I.BANK_NM)
		 WHERE A.U_CHALNO = I.U_CHALNO AND A.U_CHALDT = I.U_CHALDT AND A.BANK_NM = I.BANK_NM AND A8.S_TAX = M.S_TAX
		 AND I.U_NATURE = 'Registration Fees'  And I.TDSPAYTYPE <> 2
		 ) AS FEESAMT,
		 (
		 SELECT IsNull(Sum(J.GRO_AMT),0) FROM BPMAIN J
		 INNER JOIN AC_MAST A9 ON (A9.AC_NAME = J.BANK_NM)
		 WHERE A.U_CHALNO = J.U_CHALNO AND A.U_CHALDT = J.U_CHALDT AND A.BANK_NM = J.BANK_NM AND A9.S_TAX = M.S_TAX
		 AND J.U_NATURE = 'Appeal Fee'  And J.TDSPAYTYPE <> 2
		 ) AS AFEESAMT,
		 (
		 SELECT IsNull(Sum(K.GRO_AMT),0) FROM BPMAIN K
		 INNER JOIN AC_MAST A10 ON (A10.AC_NAME = K.BANK_NM)
		 WHERE A.U_CHALNO = K.U_CHALNO AND A.U_CHALDT = K.U_CHALDT AND A.BANK_NM = K.BANK_NM AND A10.S_TAX = M.S_TAX
		 AND K.U_NATURE = 'Revision Fee'  And K.TDSPAYTYPE <> 2
		 ) AS RFEESAMT
		 FROM BPMAIN A
		 INNER JOIN AC_MAST M ON (A.BANK_NM = M.AC_NAME)
		 WHERE A.PARTY_NM in ('VAT Payable', 'CST Payable') AND (A.DATE BETWEEN @SDATE AND @EDATE)
		 GROUP BY A.U_CHALNO, A.U_CHALDT, A.BANK_NM, M.S_TAX, M.BSRCODE, A.PARTY_NM
	End

END
--Print 'BR VAT CHALLAN'

