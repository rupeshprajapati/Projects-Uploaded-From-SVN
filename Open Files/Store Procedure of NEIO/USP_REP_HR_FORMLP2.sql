IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE = 'P' AND name = 'USP_REP_HR_FORMLP2')
BEGIN
	DROP PROCEDURE USP_REP_HR_FORMLP2
END
GO
set ANSI_NULLS ON
GO
set QUOTED_IDENTIFIER ON
go
/*
EXECUTE USP_REP_HR_FORMLP2'','','','04/01/2011','03/31/2016','','','','',0,0,'','','','','','','','','2015-2016',''
*/
-- =============================================
-- Author      : Hetal L Patel
-- Create date : 16/05/2007
-- Description : This Stored procedure is useful to generate HR VAT FORM LP 02
-- Modify date : 16/05/2007
-- Modified By : GAURAV R. TANNA for the Bug-
-- Modify date : 14/05/2015
-- Remark      :
-- Modified By : Sumit Gavate for bug - 26278
-- Modify date : 21/07/2016
-- =============================================
CREATE PROCEDURE [dbo].[USP_REP_HR_FORMLP2]
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

---Temporary Cursor
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,
ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),AC1.S_TAX,Item=space(50),Qty=99999999999.9999,Cons_Nm=AC1.AC_NAME,
Cons_Add=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3), U_AGRNO=SPACE(60), U_AGRDT=M.DATE INTO #FORMLP2 FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD) INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME) INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID) WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		 Set @MultiCo = 'YES'
		 
		 /* --Put in remarks by GAURAV R. TANNA for the Bug - start
		-- EXECUTE USP_REP_MULTI_CO_DATA
		--  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		-- ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		-- ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		-- ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		-- ,@MFCON = @MCON OUTPUT

		----SET @SQLCOMMAND='Select * from '+@MCON
		-----EXECUTE SP_EXECUTESQL @SQLCOMMAND
		--SET @SQLCOMMAND='Insert InTo #FORM_LP2 Select * from '+@MCON
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
		-----Drop Temp Table 
		--SET @SQLCOMMAND='Drop Table '+@MCON
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
		
		*/-- Put in remarks by GAURAV R. TANNA for the Bug - end
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		  --Changed by GAURAV R. TANNA for the Bug - start
		 --EXECUTE USP_REP_SINGLE_CO_DATA
		 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		 --CHanged by GAURAV R. TANNA for the Bug - End
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		--Put in remarks by GAURAV R. TANNA for the Bug - start
		----SET @SQLCOMMAND='Select * from '+@MCON
		-----EXECUTE SP_EXECUTESQL @SQLCOMMAND
		--SET @SQLCOMMAND='Insert InTo #FORM_LP2 Select * from '+@MCON
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
		-----Drop Temp Table 
		--SET @SQLCOMMAND='Drop Table '+@MCON
		--EXECUTE SP_EXECUTESQL @SQLCOMMAND
		--Put in remarks by GAURAV R. TANNA for the Bug - end
		INSERT INTO #FORMLP2 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,S_TAX,QTY,CONS_NM,CONS_ADD,U_AGRNO,U_AGRDT)
		SELECT 1,'1', 'A', 0, A.GRO_AMT,0,0,P.u_pinvno,P.u_pinvdt, A.AC_NAME, A.ADDRESS,
		CASE WHEN CAST(ISNULL(I.IT_DESC,'') AS VARCHAR) = '' THEN I.IT_NAME ELSE CAST(ISNULL(I.IT_DESC,'') AS VARCHAR) END as it_name,A.S_TAX,D.qty,
		Cons_nm=AC.ac_name,Cons_Add=RTrim(Ac.Add1)+' '+RTrim(Ac.Add2)+' '+RTrim(Ac.Add3),P.U_AGRNO,P.U_AGRDT FROM VATTBL A
		INNER JOIN PTMAIN P ON (P.TRAN_CD = A.TRAN_CD AND P.ENTRY_TY = A.BHENT)
		INNER JOIN PTITEM D ON (D.TRAN_CD = A.TRAN_CD AND D.ENTRY_TY = A.BHENT AND D.IT_CODE = A.IT_CODE)
		INNER JOIN IT_MAST I ON (I.IT_CODE = A.IT_CODE) INNER JOIN AC_MAST AC ON (AC.AC_ID = p.cons_ID ) WHERE A.BHENT in ('P1','PT') AND
		(P.VATMTYPE = 'Purchase in the Course of Export Out of India') And (A.DATE BETWEEN @SDATE AND @EDATE) AND A.ST_TYPE = 'OUT OF COUNTRY'
		---AND A.S_TAX <> ' '  
		ORDER BY A.AC_NAME,A.ADDRESS,A.S_TAX,P.u_pinvno,P.u_pinvdt,I.IT_NAME
		
		IF NOT EXISTS(SELECT DISTINCT PART FROM #FORMLP2 WHERE PART = 1 AND PARTSR = '1' AND SRNO = 'A')
		BEGIN
			INSERT INTO #FORMLP2(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,S_TAX,QTY,CONS_NM,CONS_ADD,U_AGRNO,U_AGRDT)
			VALUES (1,'1', 'A', 0,0,0,0,'','','','','','',0,'','','','')
		END
		DECLARE @AMT1 NUMERIC(15,2)
		SELECT @AMT1 = ISNULL(SUM(AMT1),0) FROM #FORMLP2
		INSERT INTO #FORMLP2(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,DATE,PARTY_NM,ADDRESS,ITEM,S_TAX,QTY,CONS_NM,CONS_ADD,U_AGRNO,U_AGRDT)
		VALUES (1,'1', 'Z', 0,@AMT1,0,0,'','','','','Total','',0,'','','','')
	End
-----

Update #formLP2 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0),
					 AMT2 = isnull(AMT2,0),AMT3 = isnull(AMT3,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''),PARTY_NM = isnull(Party_nm,''),
					 ADDRESS = isnull(Address,''),S_TAX = isnull(S_tax,''), Qty = isnull(Qty,0),  ITEM =isnull(item,''),U_AGRNO = isnull(U_AGRNO,''),
					 U_AGRDT = isnull(U_AGRDT,''), Cons_nm=isnull(cons_nm,''), Cons_add=isnull(Cons_add,'') 

SELECT * FROM #FORMLP2 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int),SRNO
END
DROP TABLE #FORMLP2
--Print 'HR VAT FORM LP 02'

