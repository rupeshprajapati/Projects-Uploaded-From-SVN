IF EXISTS(SELECT XTYPE,NAME FROM SYSOBJECTS WHERE XTYPE='P' AND NAME='USP_REP_PB_VATFORM24')
BEGIN
	DROP PROCEDURE USP_REP_PB_VATFORM24
END 
GO
SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description:	This Stored procedure is useful to generate PB VAT FORM 24
-- Modified By: GAURAV R. TANNA
-- Modify date: 31/07/2015
-- Remark:    : 
-- EXECUTE USP_REP_PB_VATFORM24 '','','','04/01/2014','03/31/2015','','','','',0,0,'','','','','','','','','2014-2015',''
-- =============================================
create PROCEDURE [dbo].[USP_REP_PB_VATFORM24]
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


SELECT PART=3,PARTSR='AAA',SRNO='AAA',tran_type=space(100),party_nm=RTRIM(ac.MAILNAME),ADDRESS=RTRIM(LTRIM(AC.CITY))	
 ,AC.S_TAX,BILLNO=M.U_PINVNO,BILLDT=M.U_PINVDT,ITDESC=B.ITEM,ITNAME=B.ITEM,LEVEL1=99.9999,CNNO=M.U_PINVNO,CNDT=M.U_PINVDT
,QTY=b.qty
,AMT1=B.GRO_AMT
,AMT2=B.GRO_AMT
,AMT3=B.GRO_AMT
,AMT4=B.GRO_AMT
,TR_NAT=SPACE(100)
INTO #FORMPB07A
FROM PTACDET A 
inner join VATITEM_VW B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD)
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME and AC.AC_ID=M.AC_ID)
WHERE 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'PTMAIN' And B.[Name] = 'DBNAME')
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
		SET @SQLCOMMAND='Insert InTo #FORM_PB7 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		 SET @EXPARA = ''
		 EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT
	End
		

DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@ATAXAMT NUMERIC(12,2),@TOTAMT NUMERIC(12,2),@ITEMTYPE VARCHAR(1)
Declare @VATONAMT as numeric(12,2),@INV_NO as varchar(10),@DATE as smalldatetime,@PARTY_NM as varchar(50),@ADDRESS as varchar(100),@ITDESC as varchar(100),@ITNAME as varchar(100),@FORM_NM as varchar(30),@S_TAX as varchar(30),@QTY as numeric(18,4)
Declare @billno as varchar (20),@billdt as smalldatetime,@cnno as varchar(20),@cndt as smalldatetime
Declare @U_IMPORM AS VARCHAR(100), @TAX_NAME AS VARCHAR(50), @TRAN_TYPE AS VARCHAR(100), @ST_TYPE As VarChar(50)
Declare @RFORM_NM VARCHAR(50), @TR_NAT VARCHAR(100), @BHENT VARCHAR(03), @TRAD_NM AS VARCHAR(150)

Declare @ISITEM BIT

SET @ISITEM = 1

select  @ISITEM = stax_item from LCODE WHERE ENTRY_TY = 'PT'
PRINT 'ISITEM' 
PRINT @ISITEM
SET @CHAR=65

SELECT @VATONAMT=0,@TAXAMT=0,@ATAXAMT=0,@TOTAMT=0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',@ITDESC ='',@ITNAME ='',@TRAD_NM=''
,@U_IMPORM ='', @TAX_NAME='', @TRAN_TYPE='', @ST_TYPE = ''
,@FORM_NM='',@S_TAX ='',@QTY=0,@ITEMTYPE='',@billno='',@billdt='',@itdesc ='',@cnno='',@cndt =''
, @RFORM_NM = '',@TR_NAT='', @BHENT = ''


Declare cur_formPB07Aaa cursor for
SELECT 
A.TRAN_CD,
A.BHENT,
U_IMPORM = CASE WHEN A.BHENT = 'PT' THEN A.U_IMPORM ELSE 'Purchase Return' END,
A.TAX_NAME,
AC.ST_TYPE,
A.RFORM_NM,
PARTY_NM=RTRIM(ac.MAILNAME),
ADDRESS=RTRIM(LTRIM(AC.CITY)),
AC.S_TAX,
BILLNO=A.inv_no,
BILLDT=A.DATE,
ITDESC=CAST(IT.IT_DESC AS VARCHAR(100)),		
ITNAME=IT.IT_NAME,
TRADNM=IT.U_TRDNM
,QTY=Sum(v.qty),
LEVEL1=A.PER,
 --AMT1=CASE WHEN A.BHENT = 'PT' THEN Sum((A.GRO_AMT - A.TAXAMT - IsNull(V.ADDLVAT1, 0))) ELSE Sum(((-1) * (A.GRO_AMT - A.TAXAMT - IsNull(V.ADDLVAT1, 0)))) END ,
 AMT1=CASE WHEN A.BHENT = 'PT' THEN Sum((A.VATONAMT)) ELSE Sum(((-1) * (A.GRO_AMT - A.TAXAMT - IsNull(V.ADDLVAT1, 0)))) END ,
 AMT2=CASE WHEN A.BHENT = 'PT' THEN Sum(A.TAXAMT) ELSE Sum(((-1) * A.TAXAMT)) END,
 AMT3=CASE WHEN A.BHENT = 'PT' THEN Sum(IsNull(V.ADDLVAT1, 0)) ELSE Sum(((-1) * IsNull(V.ADDLVAT1, 0))) END,
 AMT4=CASE WHEN A.BHENT = 'PT' THEN Sum((A.TAXAMT + IsNull(V.ADDLVAT1, 0))) ELSE Sum(((-1) * (A.TAXAMT + IsNull(V.ADDLVAT1, 0)))) END,
CNNO='',
CNDT=CAST('1900/01/01' As smalldatetime)
FROM vattbl A
inner join litem_vw V on (A.BHENT = V.Entry_ty And A.Tran_cd = V.Tran_cd And A.ITSERIAL = V.ITSERIAL And A.IT_CODE = V.IT_CODE)
INNER JOIN AC_MAST AC ON (A.AC_ID = AC.AC_ID)
INNER JOIN IT_MAST IT ON (IT.IT_CODE =A.IT_CODE)
WHERE  A.BHENT in ('PT', 'PR') AND  AC.ST_TYPE IN ('LOCAL','') AND (A.DATE BETWEEN @SDATE AND @EDATE)
GROUP BY A.TRAN_CD, A.BHENT,CASE WHEN A.BHENT = 'PT' THEN A.U_IMPORM ELSE 'Purchase Return' END,
A.TAX_NAME,AC.ST_TYPE,A.RFORM_NM,RTRIM(ac.MAILNAME),RTRIM(LTRIM(AC.CITY)),AC.S_TAX,A.inv_no,A.DATE,
CAST(IT.IT_DESC AS VARCHAR(100)),IT.IT_NAME,IT.U_TRDNM,A.PER 
UNION
SELECT 
S.TRAN_CD,
A.BHENT,
U_IMPORM = 'Purchase Return',
A.TAX_NAME,
AC.ST_TYPE,
A.RFORM_NM,
PARTY_NM=RTRIM(ac.MAILNAME),
ADDRESS=RTRIM(LTRIM(AC.CITY)),
AC.S_TAX,
BILLNO=A.inv_no,
BILLDT=A.DATE,
ITDESC=CAST(IT.IT_DESC AS VARCHAR(100)),		
ITNAME=IT.IT_NAME,
TRADNM=IT.U_TRDNM
,QTY=Sum(v.qty),
LEVEL1=A.PER,
 --AMT1=Sum(((-1) * (A.GRO_AMT - A.TAXAMT - IsNull(V.ADDLVAT1, 0)))),
 AMT1=Sum(((-1) * (A.VATONAMT))),
 AMT2=Sum(((-1) * A.TAXAMT)) ,
 AMT3=Sum(((-1) * IsNull(V.ADDLVAT1, 0))) ,
 AMT4=Sum(((-1) * (A.TAXAMT + IsNull(V.ADDLVAT1, 0)))) ,
CNNO='',
CNDT=CAST('1900/01/01' As smalldatetime)
FROM vattbl A
inner join Stmain S on (s.tran_cd=a.tran_cd and s.ac_id=a.ac_id )
inner join litem_vw V on (A.BHENT = V.Entry_ty And A.Tran_cd = V.Tran_cd And A.ITSERIAL = V.ITSERIAL And A.IT_CODE = V.IT_CODE)
INNER JOIN AC_MAST AC ON (S.AC_ID = AC.AC_ID)
INNER JOIN IT_MAST IT ON (IT.IT_CODE =A.IT_CODE)
WHERE  A.BHENT in ('ST') AND  AC.ST_TYPE IN ('LOCAL','') AND (A.DATE BETWEEN @SDATE AND @EDATE) AND (A.U_IMPORM = 'Purchase Return')
GROUP BY S.TRAN_CD, A.BHENT, A.U_IMPORM,
A.TAX_NAME,AC.ST_TYPE,A.RFORM_NM,RTRIM(ac.MAILNAME),RTRIM(LTRIM(AC.CITY)),AC.S_TAX,A.inv_no,A.DATE,
CAST(IT.IT_DESC AS VARCHAR(100)),IT.IT_NAME,IT.U_TRDNM,A.PER 
UNION
SELECT 
S.TRAN_CD, 
S.ENTRY_TY,
U_IMPORM='Repair/Job Work',
B.TAX_NAME,
AC.ST_TYPE,
RFORM_NM='',
PARTY_NM=RTRIM(ac.MAILNAME),
ADDRESS=RTRIM(LTRIM(AC.CITY)),
AC.S_TAX,
BILLNO=S.inv_no,
BILLDT=S.DATE,
ITDESC=CAST(IT.IT_DESC AS VARCHAR(100)),
ITNAME=IT.IT_NAME,
TRADNM=IT.U_TRDNM
,QTY=Sum(b.qty),
LEVEL1=STM.LEVEL1,
 AMT1=Sum((B.GRO_AMT - B.TAXAMT - IsNull(V.ADDLVAT1, 0))),
 AMT2=Sum(B.TAXAMT),
 AMT3=Sum(IsNull(V.ADDLVAT1, 0)),
 AMT4=Sum((B.TAXAMT + IsNull(V.ADDLVAT1, 0))),
CNNO='',
CNDT=CAST('1900/01/01' As smalldatetime)
FROM IRItem B 
inner join IRMain S on (s.tran_cd=B.tran_cd and s.entry_ty=b.entry_ty)
INNER JOIN AC_MAST AC ON (S.AC_ID = AC.AC_ID)
INNER JOIN IT_MAST IT ON (IT.IT_CODE = B.IT_CODE)
inner join litem_vw V on (b.entry_ty = V.Entry_ty And b.Tran_cd = V.Tran_cd And B.ITSERIAL = V.ITSERIAL And B.IT_CODE = V.IT_CODE)
LEFT JOIN STAX_MAS STM on (STM.ENTRY_TY = B.ENTRY_TY AND B.TAX_NAME = STM.TAX_NAME)
WHERE  B.ENTRY_TY IN ('R1', 'RL') AND  AC.ST_TYPE IN ('LOCAL','') AND (B.DATE BETWEEN @SDATE AND @EDATE)
GROUP BY S.TRAN_CD, S.ENTRY_TY,B.TAX_NAME,AC.ST_TYPE,RTRIM(ac.MAILNAME),RTRIM(LTRIM(AC.CITY)),AC.S_TAX,S.inv_no,S.DATE,
CAST(IT.IT_DESC AS VARCHAR(100)),IT.IT_NAME,IT.U_TRDNM,STM.LEVEL1
order by Billdt,billno

DECLARE @RENTRY_TY VARCHAR(10), @RTRAN_CD INT, @TRAN_CD INT, @REF_TAX VARCHAR(30)

SELECT @RENTRY_TY ='', @RTRAN_CD=0, @TRAN_CD=0, @REF_TAX = ''

OPEN CUR_FORMPB07Aaa
FETCH NEXT FROM CUR_FORMPB07Aaa INTO @TRAN_CD,@BHENT, @U_IMPORM, @TAX_NAME, @ST_TYPE, @RFORM_NM, @PARTY_NM,@ADDRESS,@S_TAX,@billno,@billdt,@itdesc,@itname,@TRAD_NM,@QTY,@PER,@VATONAMT,@TAXAMT,@ATAXAMT,@TOTAMT,@cnno ,@cndt
WHILE (@@FETCH_STATUS=0)
BEGIN


	SET @VATONAMT=CASE WHEN @VATONAMT IS NULL THEN 0 ELSE @VATONAMT END
	SET @TAXAMT=CASE WHEN @TAXAMT IS NULL THEN 0 ELSE @TAXAMT END
	SET @ATAXAMT=CASE WHEN @ATAXAMT IS NULL THEN 0 ELSE @ATAXAMT END
	SET @TOTAMT=CASE WHEN @TOTAMT IS NULL THEN 0 ELSE @TOTAMT END
	SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
	SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END	
	SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
	SET @BILLNO=CASE WHEN @BILLNO IS NULL THEN '' ELSE @BILLNO END
	SET @CNNO=CASE WHEN @CNNO IS NULL THEN '' ELSE @CNNO END
	SET @CNDT=CASE WHEN @CNDT IS NULL THEN '' ELSE @CNDT END
	SET @qty=CASE WHEN @qty IS NULL THEN 0 ELSE @qty END
	SET @PER=CASE WHEN @PER IS NULL THEN 0 ELSE @PER END
	SET @ITNAME=CASE WHEN @ITNAME IS NULL THEN '' ELSE @ITNAME END
	SET @ITDESC=CASE WHEN @ITDESC IS NULL THEN '' ELSE @ITDESC END
	SET @TRAD_NM=CASE WHEN @TRAD_NM IS NULL THEN '' ELSE @TRAD_NM END
	SET @TRAN_TYPE = ''
	SET @TR_NAT=''
	SET @REF_TAX=''
	
	SET @TRAN_TYPE = @U_IMPORM
	
	
	IF @U_IMPORM = 'Discount/Incentive'
		begin
			SET @TRAN_TYPE = 'Discount/Incentive'
			SET @VATONAMT=((-1) * @VATONAMT)
		end		
	ELSE IF @U_IMPORM = 'Purchase Return'
		begin
			SET @TRAN_TYPE = 'Purchase Return'
			--SET @TR_NAT = 'Purchase Return'
			
			IF @BHENT = 'PR'
			BEGIN
				SELECT @TR_NAT=M.U_IMPORM FROM PRITREF R
				INNER JOIN PTMAIN M ON (M.ENTRY_TY = R.RENTRY_TY AND M.TRAN_CD = R.ITREF_TRAN)
				WHERE R.Tran_cd = @TRAN_CD AND R.ENTRY_TY = @BHENT AND R.ITEM = @ITNAME AND R.RENTRY_TY = 'PT'
				SET @TR_NAT = ISNULL(@TR_NAT,'')
				
				SELECT @REF_TAX=D.TAX_NAME FROM PRITREF R
				INNER JOIN PTITEM D ON (D.ENTRY_TY = R.RENTRY_TY AND D.TRAN_CD = R.ITREF_TRAN AND D.ITEM = R.ITEM)
				WHERE R.Tran_cd = @TRAN_CD AND R.ENTRY_TY = @BHENT AND R.ITEM = @ITNAME AND R.RENTRY_TY = 'PT'
				
				SET @REF_TAX = ISNULL(@REF_TAX,'')
			END
			
			IF @BHENT = 'ST'
			BEGIN
				SELECT @TR_NAT=M.U_IMPORM FROM STITREF R
				INNER JOIN PTMAIN M ON (M.ENTRY_TY = R.RENTRY_TY AND M.TRAN_CD = R.ITREF_TRAN)
				WHERE R.Tran_cd = @TRAN_CD AND R.ENTRY_TY = @BHENT AND R.ITEM = @ITNAME AND R.RENTRY_TY = 'PT'
				SET @TR_NAT = ISNULL(@TR_NAT,'')
				
				SELECT @REF_TAX=D.TAX_NAME FROM STITREF R
				INNER JOIN PTITEM D ON (D.ENTRY_TY = R.RENTRY_TY AND D.TRAN_CD = R.ITREF_TRAN AND D.ITEM = R.ITEM)
				WHERE R.Tran_cd = @TRAN_CD AND R.ENTRY_TY = @BHENT AND R.ITEM = @ITNAME AND R.RENTRY_TY = 'PT'
				
				SET @REF_TAX = ISNULL(@REF_TAX,'')
			END
		end	
	ELSE IF @U_IMPORM = 'Repair/Job Work'
		begin
			SET @TRAN_TYPE = 'Repair/Job Work'
			--SET @TR_NAT = 'Repair/Job Work'
		end	
		
	IF @TAX_NAME = 'Form H'
		begin
			SET @TRAN_TYPE = 'Purchase Against H Form'
		end	
	ELSE IF @TAX_NAME = ''	
		begin
			SET @TRAN_TYPE = 'Tax Free Purchase'
		end
	ELSE IF @TAX_NAME = 'Exempted'
		begin
			SET @TRAN_TYPE = 'Exempted Purchase'
		end
	
	IF @TRAN_TYPE = ''
		BEGIN
			IF @S_TAX = ''
				BEGIN
					SET @TRAN_TYPE = 'Retail Purchase(Including purchase from Registered Person)'
				END
			IF @S_TAX <> '' AND @TAX_NAME like '%VAT%'
				BEGIN
					SET @TRAN_TYPE = 'Purchase from Taxable Person'
				END
		END
		
		
		
	IF @U_IMPORM in ('Purchase Return')
		BEGIN
		
			IF @TR_NAT = 'Discount/Incentive'
				begin
					SET @TR_NAT = 'Discount/Incentive'
					
				end		
			
			ELSE IF @TR_NAT = 'Repair/Job Work'
				begin
					SET @TR_NAT = 'Repair/Job Work'
				end	
				
				
			IF @REF_TAX = 'Form H'
				begin
					SET @TR_NAT = 'Purchase Against H Form'
				end	
			ELSE IF @REF_TAX = ''	
				begin
					SET @TR_NAT = 'Tax Free Purchase'
				end
			ELSE IF @REF_TAX = 'Exempted'
				begin
					SET @TR_NAT = 'Exempted Purchase'
				end
			
			IF @TR_NAT = ''
				BEGIN
					IF @S_TAX = ''
						BEGIN
							SET @TR_NAT = 'Retail Purchase(Including purchase from Registered Person)'
						END
					IF @S_TAX <> '' AND @REF_TAX like '%VAT%'
						BEGIN
							SET @TR_NAT = 'Purchase from Taxable Person'
						END
				END
		
		END		
		
		
		
	set @itdesc = CASE WHEN isnull(@itdesc,'')<>'' THEN isnull(@itdesc,'') ELSE isnull(@itname,'') end
	
    INSERT INTO #FORMPB07A (PART,PARTSR,SRNO,TRAN_TYPE,S_TAX,PARTY_NM,ADDRESS,billno,billdt,itdesc,itname,QTY,LEVEL1,AMT1,AMT2,AMT3,AMT4,cnno ,cndt,TR_NAT)
    VALUES (1,'1',CHAR(@CHAR),@TRAN_TYPE,@S_TAX,@PARTY_NM,@ADDRESS,@billno,@billdt,@TRAD_NM,@itdesc,@QTY,@PER,@VATONAMT,@TAXAMT,@ATAXAMT,@TOTAMT,@cnno ,@cndt,@TR_NAT)	
	SET @CHAR=@CHAR+1

	FETCH NEXT FROM CUR_FORMPB07Aaa INTO @TRAN_CD,@BHENT, @U_IMPORM, @TAX_NAME, @ST_TYPE, @RFORM_NM, @PARTY_NM,@ADDRESS,@S_TAX,@billno,@billdt,@itdesc,@itname,@TRAD_NM,@QTY,@PER,@VATONAMT,@TAXAMT,@ATAXAMT,@TOTAMT,@cnno ,@cndt
END
CLOSE CUR_FORMPB07Aaa
DEALLOCATE CUR_FORMPB07Aaa

INSERT INTO #FORMPB07A (PART,PARTSR,SRNO,TRAN_TYPE,S_TAX,PARTY_NM,ADDRESS,billno,billdt,itdesc,itname,QTY,LEVEL1,AMT1,AMT2,AMT3,AMT4,cnno ,cndt,TR_NAT)
    SELECT 1,'2','A'
    ,D.TRAN_TYPE,D.S_TAX,D.PARTY_NM,D.ADDRESS,'','',D.itdesc,D.itname,Sum(D.QTY),D.LEVEL1,Sum(D.AMT1),Sum(D.AMT2),Sum(D.AMT3),Sum(D.AMT4),'','',''
	FROM #FORMPB07A D
	GROUP BY TRAN_TYPE,S_TAX,PARTY_NM,ADDRESS,itdesc,itname,LEVEL1,cnno ,cndt,TR_NAT
	
INSERT INTO #FORMPB07A (PART,PARTSR,SRNO,TRAN_TYPE,S_TAX,PARTY_NM,ADDRESS,billno,billdt,itdesc,itname,QTY,LEVEL1,AMT1,AMT2,AMT3,AMT4,cnno ,cndt,TR_NAT)
    VALUES (1,'3','A','','','','','','','','',0,0,0,0,0,0,'','','')
    
Update #FORMPB07A set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
					AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), AMT3 = isnull(AMT3,0), AMT4 = isnull(AMT4,0)
					, PARTY_NM = isnull(Party_nm,''),ADDRESS = isnull(ADDRESS,''),S_TAX = isnull(S_TAX,'')
					,BILLNO = isnull(BILLNO,''),ITDESC = isnull(ITDESC,''),ITNAME = isnull(ITNAME,'')
					,Qty = isnull(Qty,0),LEVEL1 = isnull(LEVEL1,0),tran_type = isnull(tran_type,'')
					,TR_NAT= isnull(TR_NAT,'')
					
					
				 --,ITEMTYPE = isnull(ITEMTYPE,'')
					 --FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),



SELECT * FROM #FORMPB07A order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
END