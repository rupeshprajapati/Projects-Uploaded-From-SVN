DROP PROCEDURE [USP_REP_SERTAX_ACCOUNTS_Multi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 11/08/2009
-- Description:	This Stored procedure is useful to generate Excise  Service Tax Report From EP,BP,CP,VR,OB,J2 entries.
-- Modification Date/By/Reason: 22/10/2011. Rup. Bug-134 Opening Balance Issue.
-- Modification Date/By/Reason: 24/09/2012. Sachin N. S. Bug-5164 (Added cut-off date of 30-06-2011 and added Service Tax Serial No. field) 
-- Remark:
-- Modification Date/By/Reason : 04/02/15 Nilesh Balu Yadav Bug 25259

-- =============================================
Create PROCEDURE [USP_REP_SERTAX_ACCOUNTS_Multi] 
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50)
,@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
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
SET QUOTED_IDENTIFIER OFF 
DECLARE @FDATE CHAR(10),@OBACID INT
SELECT @FDATE=CASE WHEN DBDATE=1 THEN 'U_CLDT' ELSE 'U_CLDT' END FROM MANUFACT

SET @FDATE='U_CLDT'

SELECT @OBACID=AC_ID FROM AC_MAST WHERE AC_NAME='OPENING BALANCES'
Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)

SELECT @EDATE=CASE WHEN @EDATE<'2011-07-01' THEN @EDATE ELSE '2011-06-30' END	-- Added by Sachin N. S. on 22/09/2012 for Bug-5164

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =' '
,@VSDATE=NULL
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='m',@VITFILE='',@VACFILE='ac'
,@VDTFLD =@FDATE
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

IF  CHARINDEX('m.U_CLDT', @FCON)<>0
BEGIN
	SET @FCON=REPLACE(@FCON, 'm.U_CLDT','ac.U_CLDT')
END


DECLARE @ENTRY_TY CHAR(2),@DATE SMALLDATETIME,@AC_ID INT,@AMOUNT NUMERIC(15,2),@AMT_TY CHAR(2),@U_CLDT SMALLDATETIME,@u_rg23no CHAR(10),@Serty varCHAR(200),@taxableamt NUMERIC(17,2),@TRAN_CD INT,@TTRAN_CD INT,@OPBAL1 NUMERIC(15,2),@RECEIPT1 NUMERIC(15,2),@ISSUE1 NUMERIC(15,2),@BALANCE1 NUMERIC(15,2),@OPBAL2 NUMERIC(15,2),@RECEIPT2 NUMERIC(15,2),@ISSUE2 NUMERIC(15,2),@BALANCE2 NUMERIC(15,2),@OPBAL3 NUMERIC(15,2),@RECEIPT3 NUMERIC(15,2),@ISSUE3 NUMERIC(15,2),@BALANCE3 NUMERIC(15,2),@OPBAL4 NUMERIC(15,2),@RECEIPT4 NUMERIC(15,2) ,@ISSUE4 NUMERIC(15,2),@BALANCE4 NUMERIC(15,2),@AC_ID5 NUMERIC(15,2),@OPBAL5 NUMERIC(15,2),@RECEIPT5 NUMERIC(15,2) ,@ISSUE5 NUMERIC(15,2),@BALANCE5 NUMERIC(15,2),@OPBAL6 NUMERIC(15,2),@RECEIPT6 NUMERIC(15,2) ,@ISSUE6 NUMERIC(15,2),@BALANCE6 NUMERIC(15,2),@OPBAL7 NUMERIC(15,2),@RECEIPT7 NUMERIC(15,2) ,@ISSUE7 NUMERIC(15,2),@BALANCE7 NUMERIC(15,2),@OPBAL8 NUMERIC(15,2),@RECEIPT8 NUMERIC(15,2) ,@ISSUE8 NUMERIC(15,2),@BALANCE8 NUMERIC(15,2),@OPBAL9 NUMERIC(15,2),@RECEIPT9 NUMERIC(15,2) ,@ISSUE9 NUMERIC(15,2),@BALANCE9 NUMERIC(15,2),@EXDATE SMALLDATETIME,@acserial varchar(5),@m1entry_ty varchar(2),@M1TRAN_CD INT
DECLARE @MAC_ID INT,@MDATE SMALLDATETIME,@OPBAL NUMERIC(15,2),@RECEIPT NUMERIC(15,2),@ISSUE NUMERIC(15,2),@BALANCE NUMERIC(15,2),@V1 NUMERIC(10)
DECLARE @FINAC NVARCHAR(500)
DECLARE @SQLCOMMAND NVARCHAR(4000)
DECLARE @FCOND CHAR(1)
DECLARE @CACID INT,@ACID1 INT,@ACID2 INT,@ACID3 INT,@ACID4 INT,@ACID5 INT,@ACID6 INT,@ACID7 INT,@ACID8 INT,@ACID9 INT,@ACID10 INT, @TRAW NUMERIC(10),@CAC_NAME VARCHAR(60),@AC_NAME1 VARCHAR(60),@AC_NAME2 VARCHAR(60),@AC_NAME3 VARCHAR(60),@AC_NAME4 VARCHAR(60),@AC_NAME5 VARCHAR(60),@AC_NAME6 VARCHAR(60),@AC_NAME7 VARCHAR(60),@AC_NAME8 VARCHAR(60),@AC_NAME9 VARCHAR(60)
DECLARE @VCOND VARCHAR(1000),@VST INT,@VEND INT,@FACNM VARCHAR(500),@I INT 

SET @SPLCOND=REPLACE(@SPLCOND, '`','''')
SET @VCOND=@SPLCOND
SET @VST= CHARINDEX(RTRIM('AC_NAME IN'), @VCOND ,1)
SET @FACNM=SUBSTRING(@VCOND,@VST,2000)
SET @VST= CHARINDEX(RTRIM('('), @FACNM ,1)+1
SET @VEND= CHARINDEX(RTRIM(')'), @FACNM ,1)
SET @FACNM=SUBSTRING(@FACNM,@VST,@VEND-@VST)
SET @FACNM= LTRIM(RTRIM(@FACNM))+', '
SET QUOTED_IDENTIFIER ON


SET @FINAC=CHAR(39)+@FACNM+CHAR(39)

SELECT mac_id=STKL_VW_MAIN.ac_id,SerTaxAcdet_vw.ENTRY_TY,SerTaxAcdet_vw.DATE,SerTaxAcdet_vw.AMT_TY,SerTaxAcdet_vw.U_CLDT,U_RG23NO='',
	AC_ID=SerTaxAcdet_vw.AC_ID,AC_ID1=SerTaxAcdet_vw.AC_ID,OPBAL1 =SerTaxAcdet_vw.AMOUNT,RECEIPT1=SerTaxAcdet_vw.AMOUNT,
	ISSUE1=SerTaxAcdet_vw.AMOUNT,BALANCE1=SerTaxAcdet_vw.AMOUNT,AC_ID2=SerTaxAcdet_vw.AC_ID,OPBAL2 =SerTaxAcdet_vw.AMOUNT,
	RECEIPT2=SerTaxAcdet_vw.AMOUNT,ISSUE2=SerTaxAcdet_vw.AMOUNT,BALANCE2=AMOUNT,AC_ID3=SerTaxAcdet_vw.AC_ID,OPBAL3 =SerTaxAcdet_vw.AMOUNT,
	RECEIPT3=SerTaxAcdet_vw.AMOUNT,ISSUE3=SerTaxAcdet_vw.AMOUNT,BALANCE3=SerTaxAcdet_vw.AMOUNT,AC_ID4=SerTaxAcdet_vw.AC_ID,
	OPBAL4 =SerTaxAcdet_vw.AMOUNT,RECEIPT4=SerTaxAcdet_vw.AMOUNT,ISSUE4=SerTaxAcdet_vw.AMOUNT,BALANCE4=SerTaxAcdet_vw.AMOUNT,
	AC_ID5=SerTaxAcdet_vw.AC_ID,OPBAL5 =SerTaxAcdet_vw.AMOUNT,RECEIPT5=SerTaxAcdet_vw.AMOUNT,ISSUE5=SerTaxAcdet_vw.AMOUNT,
	BALANCE5=SerTaxAcdet_vw.AMOUNT,AC_ID6=SerTaxAcdet_vw.AC_ID,OPBAL6 =SerTaxAcdet_vw.AMOUNT,RECEIPT6=SerTaxAcdet_vw.AMOUNT,
	ISSUE6=SerTaxAcdet_vw.AMOUNT,BALANCE6=SerTaxAcdet_vw.AMOUNT,AC_ID7=SerTaxAcdet_vw.AC_ID,OPBAL7 =SerTaxAcdet_vw.AMOUNT,
	RECEIPT7=SerTaxAcdet_vw.AMOUNT,ISSUE7=SerTaxAcdet_vw.AMOUNT,BALANCE7=SerTaxAcdet_vw.AMOUNT,AC_ID8=SerTaxAcdet_vw.AC_ID,
	OPBAL8 =SerTaxAcdet_vw.AMOUNT,RECEIPT8=SerTaxAcdet_vw.AMOUNT,ISSUE8=SerTaxAcdet_vw.AMOUNT,BALANCE8=SerTaxAcdet_vw.AMOUNT,
	AC_ID9=SerTaxAcdet_vw.AC_ID,OPBAL9 =SerTaxAcdet_vw.AMOUNT,RECEIPT9=SerTaxAcdet_vw.AMOUNT,ISSUE9=SerTaxAcdet_vw.AMOUNT,
	BALANCE9=SerTaxAcdet_vw.AMOUNT,TRAN_CD=SerTaxAcdet_vw.TRAN_CD,TTRAN_CD=SerTaxAcdet_vw.TRAN_CD,EXDATE=SerTaxAcdet_vw.DATE,
	SerTaxAcdet_vw.acserial,m1entry_ty=SerTaxAcdet_vw.entry_ty,m1tran_cd=SerTaxAcdet_vw.tran_cd,SerTaxAcdet_vw.serty,
	taxableamt=SerTaxAcdet_vw.amount, ServTxSrNo=SerTaxAcdet_vw.ServTxSrNo INTO  #ACDET		-- Changed By Sachin N. S. on 22/09/2012 for Bug-5164 
FROM SerTaxAcdet_vw 
	JOIN STKL_VW_MAIN ON (SerTaxAcdet_vw.TRAN_CD=STKL_VW_MAIN.TRAN_CD) WHERE 1=2
SELECT mac_id=STKL_VW_MAIN.ac_id,SerTaxAcdet_vw.ENTRY_TY,SerTaxAcdet_vw.DATE,SerTaxAcdet_vw.AC_ID,SerTaxAcdet_vw.AMOUNT,
	SerTaxAcdet_vw.AMT_TY,SerTaxAcdet_vw.U_CLDT,U_RG23NO='',STKL_VW_MAIN.U_INT,AC_MAST.AC_NAME,TRAN_CD=SerTaxAcdet_vw.TRAN_CD,
	EXDATE=SerTaxAcdet_vw.DATE,SerTaxAcdet_vw.acserial,m1entry_ty=SerTaxAcdet_vw.entry_ty,m1tran_cd=SerTaxAcdet_vw.tran_cd,
	SerTaxAcdet_vw.serty,taxableamt=SerTaxAcdet_vw.amount, ServTxSrNo=SerTaxAcdet_vw.ServTxSrNo  INTO #ACDET1	-- Changed By Sachin N. S. on 22/09/2012 for Bug-5164
FROM SerTaxAcdet_vw 
	JOIN STKL_VW_MAIN ON (SerTaxAcdet_vw.TRAN_CD=STKL_VW_MAIN.TRAN_CD)  JOIN AC_MAST ON (AC_MAST.AC_ID =SerTaxAcdet_vw.AC_ID) WHERE 1=2






SET @TTRAN_CD=0

SET  @ACID1=0
SET  @ACID2=0
SET  @ACID3=0
SET  @ACID4=0
SET  @ACID5=0
SET  @ACID6=0
SET  @ACID7=0
SET  @ACID8=0
SET  @ACID9=0


SET @FACNM=REPLACE(@FACNM,'''',' ')
PRINT @FACNM
SET @VST=1
SET @I=0
SET @VEND= CHARINDEX(',',@FACNM,1)

WHILE CHARINDEX(',',@FACNM,1)<>0
BEGIN
	SET @I=@I+1
	IF @I=1
	BEGIN
		SET @AC_NAME1= SUBSTRING(@FACNM,@VST,@VEND-@VST)
		SELECT  @ACID1 =AC_ID FROM AC_MAST WHERE LTRIM(RTRIM(AC_NAME))=LTRIM(RTRIM(@AC_NAME1))
		
	END
	IF @I=2
	BEGIN
		
		SET @AC_NAME2= SUBSTRING(@FACNM,@VST,@VEND-@VST)
		SELECT  @ACID2 =AC_ID FROM AC_MAST WHERE LTRIM(RTRIM(AC_NAME))=LTRIM(RTRIM(@AC_NAME2))
	END
	IF @I=3
	BEGIN
		SET @AC_NAME3= SUBSTRING(@FACNM,@VST,@VEND-@VST)
		SELECT  @ACID3 =AC_ID FROM AC_MAST WHERE LTRIM(RTRIM(AC_NAME))=LTRIM(RTRIM(@AC_NAME3))
	END
	IF @I=4
	BEGIN
		SET @AC_NAME4= SUBSTRING(@FACNM,@VST,@VEND-@VST)
		SELECT  @ACID4 =AC_ID FROM AC_MAST WHERE LTRIM(RTRIM(AC_NAME))=LTRIM(RTRIM(@AC_NAME4))
	END
	IF @I=5
	BEGIN
          		SET @AC_NAME5= SUBSTRING(@FACNM,@VST,@VEND-@VST)
		SELECT  @ACID5 =AC_ID FROM AC_MAST WHERE LTRIM(RTRIM(AC_NAME))=LTRIM(RTRIM(@AC_NAME5))
	END
	IF @I=6
	BEGIN
		SET @AC_NAME6= SUBSTRING(@FACNM,@VST,@VEND-@VST)
		SELECT  @ACID6 =AC_ID FROM AC_MAST WHERE AC_NAME=@AC_NAME6

	END
	IF @I=7
	BEGIN
        SET @AC_NAME7= SUBSTRING(@FACNM,@VST,@VEND-@VST)
		SELECT  @ACID7=AC_ID FROM AC_MAST WHERE AC_NAME=@AC_NAME7

	END
	IF @I=8
	BEGIN
		SET @AC_NAME8= SUBSTRING(@FACNM,@VST,@VEND-@VST)
		SELECT  @ACID8 =AC_ID FROM AC_MAST WHERE AC_NAME=@AC_NAME8

	END
	IF @I=9
	BEGIN
		 SET @AC_NAME9= SUBSTRING(@FACNM,@VST,@VEND-@VST)
		SELECT  @ACID9 =AC_ID FROM AC_MAST WHERE AC_NAME=@AC_NAME9
	END
	
	SET @FACNM=SUBSTRING(@FACNM,@VEND+1,500)
	SET @VEND= CHARINDEX(',',@FACNM,1)

END


/*select @ACID1,@AC_Name1,@ACID1,@AC_Name2,@ACID3,@AC_Name3*/
/*--->EP Against */
SET @SQLCOMMAND=' INSERT INTO #ACDET1 ' /*Service Tax*/
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd)'
-- SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid1 as varchar)+',isd.serbamt,''DR'',U_CLDT=m1.date,U_RG23NO='''',isd.Serty,taxableamt=isd.sTaxable,U_INT=0'			--Commented  for Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid1 as varchar)+',isd.serbamt,''DR'',U_CLDT=m1.date,'''',isd.Serty,taxableamt=isd.sTaxable,U_INT=0'		--added for Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+','+char(39)+rtrim(@ac_name1)+char(39)+',m.tran_cd,EXDATE=m1.date,acserial='''',m1entry_ty=m1.entry_ty,m1tran_cd=m1.tran_cd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'from isdallocation isd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m1 on (isd.entry_ty=m1.entry_ty and isd.tran_Cd=m1.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join acdetalloc acl on (isd.aentry_ty=acl.entry_ty and isd.atran_Cd=acl.tran_cd and isd.serty=acl.serty)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m  on (isd.aentry_ty=m.entry_ty and isd.atran_Cd=m.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+' where m1.date<='+char(39)+cast(@edate as varchar)+char(39)
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'and acl.seravail=''EXCISE'' '
print 'ep '+@SQLCOMMAND
execute sp_executesql @SQLCOMMAND

SET @SQLCOMMAND=' INSERT INTO #ACDET1 ' /*Edu. Cess on Service Tax*/
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd)'
--SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid2 as varchar)+',isd.sercamt,''DR'',U_CLDT=m1.date,U_RG23NO='''',isd.Serty,taxableamt=isd.sTaxable,U_INT=0'		--Commented for Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid2 as varchar)+',isd.sercamt,''DR'',U_CLDT=m1.date,'''',isd.Serty,taxableamt=isd.sTaxable,U_INT=0'			--added for Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+','+char(39)+rtrim(@ac_name2)+char(39)+',m.tran_cd,EXDATE=m1.date,acserial='''',m1entry_ty=m1.entry_ty,m1tran_cd=m1.tran_cd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'from isdallocation isd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m1 on (isd.entry_ty=m1.entry_ty and isd.tran_Cd=m1.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join acdetalloc acl on (isd.aentry_ty=acl.entry_ty and isd.atran_Cd=acl.tran_cd and isd.serty=acl.serty)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m  on (isd.aentry_ty=m.entry_ty and isd.atran_Cd=m.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+' where m1.date<='+char(39)+cast(@edate as varchar)+char(39)
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'and acl.seravail=''EXCISE'' '
print @SQLCOMMAND
execute sp_executesql @SQLCOMMAND

SET @SQLCOMMAND=' INSERT INTO #ACDET1 ' /*S & H. Cess on Service Tax*/
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd)'
--SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid3 as varchar)+',isd.serhamt,''DR'',U_CLDT=m1.date,U_RG23NO='''',isd.Serty,taxableamt=isd.sTaxable,U_INT=0'		--Commented for Bug 25259	
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid3 as varchar)+',isd.serhamt,''DR'',U_CLDT=m1.date,'''',isd.Serty,taxableamt=isd.sTaxable,U_INT=0'				--Added Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+','+char(39)+rtrim(@ac_name3)+char(39)+',m.tran_cd,EXDATE=m1.date,acserial='''',m1entry_ty=m1.entry_ty,m1tran_cd=m1.tran_cd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'from isdallocation isd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m1 on (isd.entry_ty=m1.entry_ty and isd.tran_Cd=m1.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join acdetalloc acl on (isd.aentry_ty=acl.entry_ty and isd.atran_Cd=acl.tran_cd and isd.serty=acl.serty)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m  on (isd.aentry_ty=m.entry_ty and isd.atran_Cd=m.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+' where m1.date<='+char(39)+cast(@edate as varchar)+char(39)
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'and acl.seravail=''EXCISE'' '
print @SQLCOMMAND
execute sp_executesql @SQLCOMMAND
/*EP Against Bill<---*/

/*--->BP Advance */
SET @SQLCOMMAND=' INSERT INTO #ACDET1 ' /*Service Tax*/
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd)'
--SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid1 as varchar)+',acl.serbamt,''DR'',U_CLDT=m.date,U_RG23NO='''',acl.Serty,taxableamt=acl.sTaxable,U_INT=0'   --Commented for Bug 25259	
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid1 as varchar)+',acl.serbamt,''DR'',U_CLDT=m.date,'''',acl.Serty,taxableamt=acl.sTaxable,U_INT=0'		--added for Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+','+char(39)+rtrim(@ac_name1)+char(39)+',m.tran_cd,EXDATE=m.date,acserial='''',m1entry_ty=m.entry_ty,m1tran_cd=m.tran_cd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'from acdetalloc acl '
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m  on (acl.entry_ty=m.entry_ty and acl.tran_Cd=m.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+' where m.date<='+char(39)+cast(@edate as varchar)+char(39)
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'and acl.seravail=''EXCISE'' and m.TdsPayType=2'
print @SQLCOMMAND
execute sp_executesql @SQLCOMMAND

SET @SQLCOMMAND=' INSERT INTO #ACDET1 ' /*Edu. cess on Service Tax*/
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd)'
--SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid2 as varchar)+',acl.sercamt,''DR'',U_CLDT=m.date,U_RG23NO='''',acl.Serty,taxableamt=acl.sTaxable,U_INT=0'  --commented Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid2 as varchar)+',acl.sercamt,''DR'',U_CLDT=m.date,'''',acl.Serty,taxableamt=acl.sTaxable,U_INT=0'			--added Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+','+char(39)+rtrim(@ac_name2)+char(39)+',m.tran_cd,EXDATE=m.date,acserial='''',m1entry_ty=m.entry_ty,m1tran_cd=m.tran_cd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'from acdetalloc acl '
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m  on (acl.entry_ty=m.entry_ty and acl.tran_Cd=m.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+' where m.date<='+char(39)+cast(@edate as varchar)+char(39)
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'and acl.seravail=''EXCISE'' and m.TdsPayType=2'
print @SQLCOMMAND
execute sp_executesql @SQLCOMMAND

SET @SQLCOMMAND=' INSERT INTO #ACDET1 ' /*S & H Cess on Service Tax*/
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd)'
--SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid3 as varchar)+',acl.serhamt,''DR'',U_CLDT=m.date,U_RG23NO='''',acl.Serty,taxableamt=acl.sTaxable,U_INT=0'	--commented for Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.ac_id,m.entry_ty,m.date,'+cast(@acid3 as varchar)+',acl.serhamt,''DR'',U_CLDT=m.date,'''',acl.Serty,taxableamt=acl.sTaxable,U_INT=0'			--added for Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+','+char(39)+rtrim(@ac_name3)+char(39)+',m.tran_cd,EXDATE=m.date,acserial='''',m1entry_ty=m.entry_ty,m1tran_cd=m.tran_cd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'from acdetalloc acl '
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join SerTaxMain_vw m  on (acl.entry_ty=m.entry_ty and acl.tran_Cd=m.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+' where m.date<='+char(39)+cast(@edate as varchar)+char(39)
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'and acl.seravail=''EXCISE'' and m.TdsPayType=2'
print @SQLCOMMAND
execute sp_executesql @SQLCOMMAND
/*<---BP Advance */
/*--->Service Tax Credit Entry */
SET @SQLCOMMAND=' INSERT INTO #ACDET1 '
--SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd,ServTxSrNo)'		-- Changed by Sachin N. S. on 22/09/2012 for Bug-5164
--SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.cons_id,m.entry_ty,m.date,ac.ac_id,ac.amount,''DR'',m.U_CLDT,U_RG23NO='''',ac.Serty,taxableamt=m.SerPAmt,U_INT=0'				--commented for Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'select m.cons_id,m.entry_ty,m.date,ac.ac_id,ac.amount,''DR'',m.U_CLDT,'''',ac.Serty,taxableamt=m.SerPAmt,U_INT=0'						--added for Bug 25259
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+',a.ac_name,m.tran_cd,EXDATE=m.u_cldt,ac.acserial,m1entry_ty=m.entry_ty,m1tran_cd=m.tran_cd'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+',m.ServTxSrNo '	-- Added By Sachin N. S. on 22/09/2012 for Bug-5164
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'from jvmain m '
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join jvacdet ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'inner join ac_mast a on (ac.ac_id=a.ac_id) '
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'where m.date<='+char(39)+cast(@edate as varchar)+char(39)
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'and m.entry_ty=''J2'' '

print @SQLCOMMAND
execute sp_executesql @SQLCOMMAND
/*<---Service Tax Credit Entry */

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
,@VMAINFILE='SerTaxMain_vw',@VITFILE='',@VACFILE='ac'
,@VDTFLD =@FDATE
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT
IF  CHARINDEX('SerTaxMain_vw.U_CLDT', @FCON)<>0
BEGIN
	SET @FCON=REPLACE(@FCON, 'SerTaxMain_vw.U_CLDT','SerTaxAcdet_vw.U_CLDT')
END



SET @SQLCOMMAND=' INSERT INTO #ACDET1 '
--SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd)'
SET @SQLCOMMAND=rtrim(@SQLCOMMAND)+' '+'(mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,U_INT,AC_NAME,TRAN_CD,EXDATE,acserial,m1entry_ty,m1tran_cd,ServtxSrNo)'	-- Changed By Sachin N. S. on 22/09/2012 for Bug-5164
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'SELECT SerTaxMain_vw.ac_id,SerTaxAcdet_vw.ENTRY_TY,SerTaxAcdet_vw.DATE,SerTaxAcdet_vw.AC_ID,SerTaxAcdet_vw.AMOUNT'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',SerTaxAcdet_vw.AMT_TY,SerTaxAcdet_vw.U_CLDT,U_RG23NO='''',SerTaxAcdet_vw.SerTy,0,U_INT=0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',AC_MAST.AC_NAME,SerTaxAcdet_vw.TRAN_CD,SerTaxAcdet_vw.'+@FDATE+',SerTaxAcdet_vw.acserial,'''',0 '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',SerTaxAcdet_vw.ServTxSrNo FROM SerTaxAcdet_vw '		-- Changed by Sachin N. S. on 22/09/2012 for Bug-5164
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'INNER JOIN SerTaxMAin_vw ON (SerTaxAcdet_vw.TRAN_CD=SerTaxMain_vw.TRAN_CD AND SerTaxAcdet_vw.ENTRY_TY=SerTaxMain_vw.ENTRY_TY)   JOIN AC_MAST ON (AC_MAST.AC_ID =SerTaxAcdet_vw.AC_ID) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'inner join lcode l on (SerTaxMain_vw.entry_ty=l.entry_ty)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'and (  l.entry_ty in (''VR'',''OB'') or l.bcode_nm in (''OB''))'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' ORDER BY SerTaxAcdet_vw.'+ @FDATE+'SerTaxAcdet_vw.u_RG23NO,,SerTaxAcdet_vw.ServtxSrNo '	-- Changed by Sachin N. S. on 22/09/2012 for Bug-5164
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' ORDER BY SerTaxAcdet_vw.'+ @FDATE+',SerTaxAcdet_vw.U_RG23NO,SerTaxAcdet_vw.ServtxSrNo '	--commented for Bug 25259
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' ORDER BY SerTaxAcdet_vw.'+ @FDATE+',SerTaxAcdet_vw.ServtxSrNo '			--added for Bug 25259
PRINT @SQLCOMMAND
EXEC SP_EXECUTESQL  @SQLCOMMAND


SELECT
@OPBAL1     =SUM(CASE WHEN AC_ID=@ACID1 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@BALANCE1=SUM(CASE WHEN AC_ID=@ACID1 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END),@OPBAL2     =SUM(CASE WHEN AC_ID=@ACID2 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@BALANCE2=SUM(CASE WHEN AC_ID=@ACID2 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@OPBAL3     =SUM(CASE WHEN AC_ID=@ACID3 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@BALANCE3=SUM(CASE WHEN AC_ID=@ACID3 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END),
@OPBAL4     =SUM(CASE WHEN AC_ID=@ACID4 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@BALANCE4=SUM(CASE WHEN AC_ID=@ACID4 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END),
@OPBAL5     =SUM(CASE WHEN AC_ID=@ACID5 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@BALANCE5=SUM(CASE WHEN AC_ID=@ACID5 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END),
@OPBAL6     =SUM(CASE WHEN AC_ID=@ACID6 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@BALANCE6=SUM(CASE WHEN AC_ID=@ACID6 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END),
@OPBAL7     =SUM(CASE WHEN AC_ID=@ACID7 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@BALANCE7=SUM(CASE WHEN AC_ID=@ACID7 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END),
@OPBAL8     =SUM(CASE WHEN AC_ID=@ACID8 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@BALANCE8=SUM(CASE WHEN AC_ID=@ACID8 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END),
@OPBAL9     =SUM(CASE WHEN AC_ID=@ACID9 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END) ,
@BALANCE9=SUM(CASE WHEN AC_ID=@ACID9 THEN  (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END)
FROM #ACDET1 WHERE ((EXDATE<@SDATE AND ENTRY_TY<>'OB') OR (EXDATE<=@SDATE AND ENTRY_TY='OB')) 


SET @OPBAL1=CASE WHEN @OPBAL1 IS NULL THEN 0 ELSE @OPBAL1 END
SET @BALANCE1=CASE WHEN @BALANCE2 IS NULL THEN 0 ELSE @BALANCE1 END
SET @OPBAL2=CASE WHEN @OPBAL2 IS NULL THEN 0 ELSE @OPBAL2 END
SET @BALANCE2=CASE WHEN @BALANCE2 IS NULL THEN 0 ELSE @BALANCE2 END
SET @OPBAL3=CASE WHEN @OPBAL3 IS NULL THEN 0 ELSE @OPBAL3 END
SET @BALANCE3=CASE WHEN @BALANCE3 IS NULL THEN 0 ELSE @BALANCE3 END
SET @OPBAL4=CASE WHEN @OPBAL4 IS NULL THEN 0 ELSE @OPBAL4 END
SET @BALANCE4=CASE WHEN @BALANCE4 IS NULL THEN 0 ELSE @BALANCE4 END
SET @OPBAL5=CASE WHEN @OPBAL5 IS NULL THEN 0 ELSE @OPBAL5 END
SET @BALANCE5=CASE WHEN @BALANCE5 IS NULL THEN 0 ELSE @BALANCE5 END
SET @OPBAL6=CASE WHEN @OPBAL6 IS NULL THEN 0 ELSE @OPBAL6 END
SET @BALANCE6=CASE WHEN @BALANCE6 IS NULL THEN 0 ELSE @BALANCE6 END
SET @OPBAL7=CASE WHEN @OPBAL7 IS NULL THEN 0 ELSE @OPBAL7 END
SET @BALANCE7=CASE WHEN @BALANCE7 IS NULL THEN 0 ELSE @BALANCE7 END
SET @OPBAL8=CASE WHEN @OPBAL8 IS NULL THEN 0 ELSE @OPBAL8 END
SET @BALANCE8=CASE WHEN @BALANCE8 IS NULL THEN 0 ELSE @BALANCE8 END
SET @OPBAL9=CASE WHEN @OPBAL9 IS NULL THEN 0 ELSE @OPBAL9 END
SET @BALANCE9=CASE WHEN @BALANCE9 IS NULL THEN 0 ELSE @BALANCE9 END



SET @RECEIPT1=0
SET @ISSUE1=0
SET @RECEIPT2=0
SET @ISSUE2=0
SET @RECEIPT3=0
SET @ISSUE3=0
SET @RECEIPT4=0
SET @ISSUE4=0
SET @RECEIPT5=0
SET @ISSUE5=0
SET @RECEIPT6=0
SET @ISSUE6=0
SET @RECEIPT7=0
SET @ISSUE7=0
SET @RECEIPT8=0
SET @ISSUE8=0
SET @RECEIPT9=0
SET @ISSUE9=0

SET @TTRAN_CD=@TTRAN_CD+1

IF ABS(@OPBAL1)+ABS(@BALANCE1)+ABS(@OPBAL2)+ABS(@BALANCE2)+ABS(@OPBAL3)+ABS(@BALANCE3)+ABS(@OPBAL4)+ABS(@BALANCE4)+ABS(@OPBAL5)+ABS(@BALANCE5)+ABS(@OPBAL6)+ABS(@BALANCE6)+ABS(@OPBAL7)+ABS(@BALANCE7)+ABS(@OPBAL8)+ABS(@BALANCE8)+ABS(@OPBAL9)+ABS(@BALANCE9)<>0
BEGIN
	print 'r1'
	INSERT INTO #ACDET (mac_id,ENTRY_TY,DATE,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,AC_ID,TRAN_CD,	AC_ID1,OPBAL1,RECEIPT1,ISSUE1,BALANCE1,
	AC_ID2,OPBAL2,RECEIPT2,ISSUE2,BALANCE2,
	AC_ID3,OPBAL3,RECEIPT3,ISSUE3,BALANCE3,
	AC_ID4,OPBAL4,RECEIPT4,ISSUE4,BALANCE4,
	AC_ID5,OPBAL5,RECEIPT5,ISSUE5,BALANCE5,
	AC_ID6,OPBAL6,RECEIPT6,ISSUE6,BALANCE6,
	AC_ID7,OPBAL7,RECEIPT7,ISSUE7,BALANCE7,
	AC_ID8,OPBAL8,RECEIPT8,ISSUE8,BALANCE8,
	AC_ID9,OPBAL9,RECEIPT9,ISSUE9,BALANCE9,
	TTRAN_CD,EXDATE,acserial,M1ENTRY_TY,M1TRAN_CD
	)
	VALUES(@obacid,'OB',@SDATE,' ',@SDATE,' ',' ',0,@OBACID,0,
	@ACID1,@OPBAL1,@RECEIPT1,@ISSUE1,@BALANCE1,
	@ACID2,@OPBAL2,@RECEIPT2,@ISSUE2,@BALANCE2,
	@ACID3,@OPBAL3,@RECEIPT3,@ISSUE3,@BALANCE3,
	@ACID4,@OPBAL4,@RECEIPT4,@ISSUE4,@BALANCE4,
	@ACID5,@OPBAL5,@RECEIPT5,@ISSUE5,@BALANCE5,
	@ACID6,@OPBAL6,@RECEIPT6,@ISSUE6,@BALANCE6,
	@ACID7,@OPBAL7,@RECEIPT7,@ISSUE7,@BALANCE7,
	@ACID8,@OPBAL8,@RECEIPT8,@ISSUE8,@BALANCE8,
	@ACID9,@OPBAL9,@RECEIPT9,@ISSUE9,@BALANCE9,
	@TTRAN_CD,@SDATE,'','',0
	)
	print 'r2'
END

--SELECT mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,u_Rg23No,Serty,taxableamt,TRAN_CD,EXDATE,acserial,m1entry_ty,M1TRAN_CD 
--FROM #ACDET1  
--WHERE (((EXDATE>=@SDATE  AND ENTRY_TY<>'OB') OR (EXDATE>@SDATE  AND ENTRY_TY='OB'))) 
--ORDER BY EXDATE,(CASE WHEN AMT_TY='DR' THEN 0 ELSE 1 END),tran_cd,serty,m1tran_cd



DECLARE RG23II_CURSOR CURSOR FORWARD_ONLY  FOR 
SELECT mac_id,ENTRY_TY,DATE,AC_ID,AMOUNT,AMT_TY,U_CLDT,u_Rg23No,Serty,taxableamt,TRAN_CD,EXDATE,acserial,m1entry_ty,M1TRAN_CD 
FROM #ACDET1  
WHERE (((EXDATE>=@SDATE  AND ENTRY_TY<>'OB') OR (EXDATE>@SDATE  AND ENTRY_TY='OB'))) 
ORDER BY EXDATE,(CASE WHEN AMT_TY='DR' THEN 0 ELSE 1 END),tran_cd,serty,m1tran_cd


OPEN RG23II_CURSOR
FETCH NEXT FROM RG23II_CURSOR INTO
@mac_id,@ENTRY_TY,@DATE,@AC_ID,@AMOUNT,@AMT_TY,@U_CLDT,@u_Rg23No,@Serty,@taxableamt,@TRAN_CD,@EXDATE,@acserial,@M1ENTRY_TY,@M1TRAN_CD
while(@@FETCH_STATUS=0)
BEGIN
	SET @RECEIPT1=0
	SET @ISSUE1=0
	SET @RECEIPT2=0
	SET @ISSUE2=0
	SET @RECEIPT3=0
	SET @ISSUE3=0
	SET @RECEIPT4=0
	SET @ISSUE4=0
	SET @RECEIPT5=0
	SET @ISSUE5=0
	SET @RECEIPT6=0
	SET @ISSUE6=0
	SET @RECEIPT7=0
	SET @ISSUE7=0
	SET @RECEIPT8=0
	SET @ISSUE8=0
	SET @RECEIPT9=0
	SET @ISSUE9=0
	print 'Ac_id'
	print @ac_id
	print @AMT_TY

	IF @AMT_TY='DR'
	BEGIN
	
		IF @AC_ID=@ACID1
		BEGIN
			SET @RECEIPT1=@AMOUNT	
		END
		ELSE
		BEGIN
			IF @AC_ID=@ACID2
			BEGIN
				SET @RECEIPT2=@AMOUNT	
			END 		
			ELSE
			BEGIN
				IF @AC_ID=@ACID3
				BEGIN
					SET @RECEIPT3=@AMOUNT	
				END 	
				ELSE
				BEGIN
					IF @AC_ID=@ACID4
					BEGIN
						SET @RECEIPT4=@AMOUNT	
					END 	
					ELSE	
					BEGIN
						IF @AC_ID=@ACID5
						BEGIN
							SET @RECEIPT5=@AMOUNT	
						END 	
						ELSE
						BEGIN
							IF @AC_ID=@ACID6
							BEGIN
								SET @RECEIPT6=@AMOUNT	
							END 	
							ELSE
							BEGIN
								IF @AC_ID=@ACID7
								BEGIN
									SET @RECEIPT7=@AMOUNT	
								END 	
								ELSE
								BEGIN
									IF @AC_ID=@ACID8
									BEGIN
										SET @RECEIPT8=@AMOUNT	
									END 	
									ELSE
									BEGIN
										IF @AC_ID=@ACID9
										BEGIN
											SET @RECEIPT9=@AMOUNT	
										END 	
									END
								END
							END
						END
					END
				END
			END
		END
	END

	IF @AMT_TY='CR'
	BEGIN

		IF @AC_ID=@ACID1
		BEGIN
			SET @ISSUE1=@AMOUNT	
		END
		ELSE
		BEGIN
			IF @AC_ID=@ACID2
			BEGIN
				SET @ISSUE2=@AMOUNT	
			END 		
			ELSE
			BEGIN
				IF @AC_ID=@ACID3
				BEGIN
					SET @ISSUE3=@AMOUNT	
				END 	
				ELSE
				BEGIN
					IF @AC_ID=@ACID4
					BEGIN
						SET @ISSUE4=@AMOUNT	
					END 	
					ELSE
					BEGIN
						IF @AC_ID=@ACID5
						BEGIN
							SET @ISSUE5=@AMOUNT	
						END 	
						ELSE
						BEGIN
							IF @AC_ID=@ACID6
							BEGIN
								SET @ISSUE6=@AMOUNT	
							END 	
							ELSE
							BEGIN
								IF @AC_ID=@ACID7
								BEGIN
									SET @ISSUE7=@AMOUNT	
								END 	
								ELSE
								BEGIN
									IF @AC_ID=@ACID8
									BEGIN
										SET @ISSUE8=@AMOUNT	
									END 	
									ELSE
									BEGIN
										IF @AC_ID=@ACID9		
										BEGIN	
											SET @ISSUE9=@AMOUNT	
										END 	
									END
								END
							END
						END
					END
				END
			END
		END
	END

	SET @BALANCE1=@BALANCE1+@RECEIPT1-@ISSUE1
	SET @BALANCE2=@BALANCE2+@RECEIPT2-@ISSUE2
	SET @BALANCE3=@BALANCE3+@RECEIPT3-@ISSUE3
	SET @BALANCE4=@BALANCE4+@RECEIPT4-@ISSUE4
	SET @BALANCE5=@BALANCE5+@RECEIPT5-@ISSUE5
	SET @BALANCE6=@BALANCE6+@RECEIPT6-@ISSUE6
	SET @BALANCE7=@BALANCE7+@RECEIPT7-@ISSUE7
	SET @BALANCE8=@BALANCE8+@RECEIPT8-@ISSUE8
	SET @BALANCE9=@BALANCE9+@RECEIPT9-@ISSUE9

	
	SET @TTRAN_CD=@TTRAN_CD+1
	INSERT INTO #ACDET (mac_id,ENTRY_TY,DATE,AMT_TY,U_CLDT,U_RG23NO,Serty,taxableamt,AC_ID,TRAN_CD,
	AC_ID1,OPBAL1,RECEIPT1,ISSUE1,BALANCE1,
	AC_ID2,OPBAL2,RECEIPT2,ISSUE2,BALANCE2,
	AC_ID3,OPBAL3,RECEIPT3,ISSUE3,BALANCE3,	AC_ID4,OPBAL4,RECEIPT4,ISSUE4,BALANCE4,
	AC_ID5,OPBAL5,RECEIPT5,ISSUE5,BALANCE5,
	AC_ID6,OPBAL6,RECEIPT6,ISSUE6,BALANCE6,
	AC_ID7,OPBAL7,RECEIPT7,ISSUE7,BALANCE7,
	AC_ID8,OPBAL8,RECEIPT8,ISSUE8,BALANCE8,
	AC_ID9,OPBAL9,RECEIPT9,ISSUE9,BALANCE9,
	TTRAN_CD,EXDATE,acserial,M1ENTRY_TY,M1TRAN_CD
	)
	VALUES(@mac_id,@ENTRY_TY,@DATE,@AMT_TY,@U_CLDT,@U_RG23NO,@Serty,@taxableamt,@AC_ID,@TRAN_CD,
	@ACID1,@OPBAL1,@RECEIPT1,@ISSUE1,@BALANCE1,
	@ACID2,@OPBAL2,@RECEIPT2,@ISSUE2,@BALANCE2,
	@ACID3,@OPBAL3,@RECEIPT3,@ISSUE3,@BALANCE3,
	@ACID4,@OPBAL4,@RECEIPT4,@ISSUE4,@BALANCE4,
	@ACID5,@OPBAL5,@RECEIPT5,@ISSUE5,@BALANCE5,
	@ACID6,@OPBAL6,@RECEIPT6,@ISSUE6,@BALANCE6,
	@ACID7,@OPBAL7,@RECEIPT7,@ISSUE7,@BALANCE7,
	@ACID8,@OPBAL8,@RECEIPT8,@ISSUE8,@BALANCE8,
	@ACID9,@OPBAL9,@RECEIPT9,@ISSUE9,@BALANCE9,
	@TTRAN_CD,@EXDATE,@acserial,@M1ENTRY_TY,@M1TRAN_CD
	)

	SET @OPBAL1=@BALANCE1
	SET @OPBAL2=@BALANCE2
	SET @OPBAL3=@BALANCE3
	SET @OPBAL4=@BALANCE4
	SET @OPBAL5=@BALANCE5
	SET @OPBAL6=@BALANCE6
	SET @OPBAL7=@BALANCE7
	SET @OPBAL8=@BALANCE8
	SET @OPBAL9=@BALANCE9

	FETCH NEXT FROM RG23II_CURSOR INTO
	@mac_id,@ENTRY_TY,@DATE,@AC_ID,@AMOUNT,@AMT_TY,@U_CLDT,@U_RG23NO,@Serty,@taxableamt,@TRAN_CD,@EXDATE,@acserial,@M1ENTRY_TY,@M1TRAN_CD
END ---@@FETCH_STATUS=0
CLOSE  RG23II_CURSOR
DEALLOCATE RG23II_CURSOR


if charindex('##Accrual',isnull(@EXPARA,''))=1
begin
	
	select top 1 @BALANCE1=BALANCE1,@BALANCE2=BALANCE2,@BALANCE3=BALANCE3,@BALANCE4=BALANCE4,@BALANCE5=BALANCE5,@BALANCE6=BALANCE6,@BALANCE7=BALANCE7,@BALANCE8=BALANCE8 from #ACDET order by ttran_Cd desc
	set @SqlCommand='insert into '+@EXPARA+' Values	('+rtrim(Cast(@acid1 as varchar))+','+rtrim(Cast(@acid2 as varchar))+','+rtrim(Cast(@acid3 as varchar))+','+rtrim(Cast(@acid4 as varchar))+','+rtrim(Cast(@acid5 as varchar))+','+rtrim(Cast(@acid6 as varchar))+','+rtrim(Cast(@acid7 as varchar))+','+rtrim(Cast(@acid8 as varchar))+','+rtrim(Cast(@BALANCE1 as varchar))+','+rtrim(Cast(@BALANCE2 as varchar))+','+rtrim(Cast(@BALANCE3 as varchar))+','+rtrim(Cast(@BALANCE4 as varchar))+','+rtrim(Cast(@BALANCE5 as varchar))+','+rtrim(Cast(@BALANCE6 as varchar))+','+rtrim(Cast(@BALANCE7 as varchar))+','+rtrim(Cast(@BALANCE8 as varchar))+')'
	print 'ins '+@SqlCommand
	execute sp_executesql  @SqlCommand
end
else
begin
	SELECT distinct cgrp=1,ttran_Cd,
	A.ENTRY_TY,a.tran_cd,A.AMT_TY,A.U_CLDT,A.U_RG23NO,A.Serty,A.taxableamt,A.AC_ID,A.Exdate,
	AC_NAME1=@AC_NAME1,A.AC_ID1,A.OPBAL1,A.RECEIPT1,A.ISSUE1,A.BALANCE1,
	AC_NAME2=@AC_NAME2,A.AC_ID2,A.OPBAL2,A.RECEIPT2,A.ISSUE2,A.BALANCE2,
	AC_NAME3=@AC_NAME3,A.AC_ID3,A.OPBAL3,A.RECEIPT3,A.ISSUE3,A.BALANCE3,
	AC_NAME4=@AC_NAME4,A.AC_ID4,A.OPBAL4,A.RECEIPT4,A.ISSUE4,A.BALANCE4,
	AC_NAME5=@AC_NAME5,A.AC_ID5,A.OPBAL5,A.RECEIPT5,A.ISSUE5,A.BALANCE5,
	AC_NAME6=@AC_NAME6,A.AC_ID6,A.OPBAL6,A.RECEIPT6,A.ISSUE6,A.BALANCE6,
	AC_NAME7=@AC_NAME7,A.AC_ID7,A.OPBAL7,A.RECEIPT7,A.ISSUE7,A.BALANCE7,
	AC_NAME8=@AC_NAME8,A.AC_ID8,A.OPBAL8,A.RECEIPT8,A.ISSUE8,A.BALANCE8,
	AC_NAME9=@AC_NAME9,A.AC_ID9,A.OPBAL9,A.RECEIPT9,A.ISSUE9,A.BALANCE9
	,ac_mast.ECCNO,ac_mast.DIVISION,ac_mast.RANGE,ac_mast.COLL,party_nm=ac_mast.MailName
	,m.inv_no,m.date,m.u_pinvno,m.u_pinvdt
	,a.taxableamt
	,narr=cast(m.narr as varchar(4000))
	,m.ServTxSrNo		-- Added By Sachin N. S. on 22/09/2012 for Bug-5164
	FROM #ACDET A
	left JOIN SerTaxMain_vw m on (a.entry_ty=m.entry_ty and a.tran_cd=m.tran_cd)
	left JOIN AC_MAST  ON (a.mAC_id =ac_mast.AC_ID)
	left join stkl_vw_main m1 on (a.m1entry_ty=m1.entry_ty and a.m1tran_cd=m1.tran_cd)
	order by ttran_Cd

end


DROP TABLE #ACDET1
DROP TABLE #ACDET


SET QUOTED_IDENTIFIER ON
GO
