if exists(select [name] from sysobjects where [name]='USP_REP_MH702_ANN_J_6' and xtype='P')
drop procedure USP_REP_MH702_ANN_J_6
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




/*
EXECUTE USP_REP_MH702_ANN_J_6 '','','','04/01/2011','03/31/2015','','','','',0,0,'','','','','','','','','2011-2015',''
*/

-- =============================================
-- Author:		Sandeep Shah
-- Create date: 21/01/2014
-- Description:	MVAT Form 704 - Annexure-J_6
-- Modified By: 
-- Remark:      

-- =============================================


create PROCEDURE [dbo].[USP_REP_MH702_ANN_J_6]
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
 DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2)

SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''

SELECT ENTRY_TY,BCODE=(CASE WHEN EXT_VOU=1 THEN BCODE_NM ELSE ENTRY_TY END),STAX_ITEM  INTO #LCODE FROM LCODE --for bug-6755,LUBRI
 

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,U_IMPORM
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code = 999999999999999999-999999999999999999,itserial=space(5)
INTO #MHFRM704_J_6
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #MHFRM704_J_6 add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.NET_AMT,AMT4=M.NET_AMT,
PARTY_NM=AC1.AC_NAME--,ADDRESS=Ltrim(AC.Add1)+' '+Ltrim(AC.Add2)+' '+Ltrim(AC.Add3),
,M.INV_NO,M.DATE,STM.FORM_NM,AC1.S_TAX,STTYPE=SPACE(20),U_IMPORM=SPACE(100),MCOMM=SPACE(50)
INTO #MHFRM704J_6
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
		SET @SQLCOMMAND='Insert InTo #MHFRM704_J_6 Select * from '+@MCON
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
--
--		SET @SQLCOMMAND='Select * from '+@MCON
--		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo #MHFRM704_J_6 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		--SET @SQLCOMMAND='SELECT * FROM '+@MCON
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0
-----
--PART 1-4 


Declare @vatONAMT as numeric(12,2),@TAXAMT1 as numeric(12,2),@NET_AMT as numeric(12,2),@EXPAMT as numeric(12,2),@INV_NO as varchar(15)
,@DATE as smalldatetime,@PARTY_NM as varchar(50),@ADDRESS as varchar(200),@ITEM as varchar(50),@FORM_NM as varchar(30),@S_TAX as varchar(30)
,@QTY as numeric(18,4),@STTYPE AS VARCHAR(20),@tax_name as varchar(20),@u_lrno as varchar(20),@rform_nm as varchar(15),@TYPOFCLR as varchar (10)
,@state as varchar(20),@U_IMPORM as varchar(100),@mcomm as varchar(50)
SELECT @vatONAMT=0,@TAXAMT1 =0,@NET_AMT =0,@EXPAMT=0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',@ITEM ='',@FORM_NM='',@S_TAX ='',@QTY=0,@tax_name=''
,@u_lrno='',@rform_nm='',@TYPOFCLR='',@state ='',@U_IMPORM=''--,@mcomm=''
Declare cur_MHFRM704J_1 Cursor for
--SELECT a.Per,vatonamt=sum(a.VATONAMT),taxamt=SUM(A.TAXAMT),NET_AMT=(CASE WHEN a.st_type='OUT OF STATE' THEN SUM(A.Net_amt) ELSE 0 END),EXPAMT=(CASE WHEN a.st_type='OUT OF COUNTRY' THEN SUM(A.Net_amt) ELSE 0 END)
SELECT PER=0,vatonamt=(CASE WHEN LC.BCODE='PR' THEN -SUM(A.VATONAMT) ELSE SUM(A.VATONAMT) END),taxamt=(CASE WHEN LC.BCODE='PR' THEN -SUM(A.TAXAMT) ELSE SUM(A.TAXAMT) END)
,NET_AMT=(CASE WHEN LC.BCODE='PR' THEN -SUM(A.Net_amt) ELSE SUM(A.Net_amt) END),EXPAMT=(CASE WHEN LC.BCODE='PR' THEN -SUM(A.Net_amt) ELSE SUM(A.Net_amt) END)
,PARTY_NM=(CASE WHEN sac_id !=0 THEN sh.mailname ELSE c.ac_name END),S_TAX=(CASE WHEN sac_id !=0 THEN sh.s_tax ELSE c.s_tax END),U_IMPORM=a.u_imporm--,MCOMM=it.eit_name
--,A.INV_NO,A.DATE
--,st.rform_nm,state=(CASE WHEN sh.state<>'' THEN sh.state ELSE c.state END)
--,address=a.party_nm+''+a.address+', '+rtrim(c.city)+', '+rtrim(c.state)
--,FORM_NM=d.form_no

FROM #MHFRM704_J_6 A
Inner Join Litem_vw B On(A.Bhent = B.Entry_ty And A.Tran_cd = b.Tran_cd  And A.it_code = b.it_code and  a.itserial=b.itserial)
inner join PTmain d on (A.Bhent = d.Entry_ty And A.Tran_cd = d.Tran_cd)
INNER JOIN AC_MAST C ON (b.AC_ID = C.AC_ID) 
inner join it_mast it on (it.it_code=b.it_code)
--left join shipto sh on C.Ac_id=sh.ac_id and d.scons_id=sh.shipto_id 
left join SHIPTO sh on c.Ac_id=sh.Ac_id and d.sac_id=sh.shipto_id and d.sac_id !=0
inner join #lcode lc on (a.Bhent = lc.Entry_ty)
left join stax_mas st on (a.bhent = st.entry_ty and a.tax_name=st.tax_name )

--inner join ac_mast b on a.Ac_id=b.Ac_id left join shipto c on a.Ac_id=c.ac_id and a.scons_id=c.shipto_id 
WHERE LC.bcode IN ('PT','PR') 
--AND RTRIM(A.U_IMPORM)=<> 
AND a.s_TAX<>' '
 and a.st_type='OUT OF STATE' AND (A.DATE BETWEEN @SDATE AND @EDATE) 

--group by  (CASE WHEN sac_id !=0 THEN sh.mailname ELSE c.ac_name END),A.INV_NO,A.DATE,d.form_no,(CASE WHEN sac_id !=0 THEN sh.s_tax ELSE c.s_tax END),A.st_type,d.form_no,(CASE WHEN sh.state<>'' THEN sh.state ELSE c.state END),st.rform_nm,lc.bcode
group by  (CASE WHEN sac_id !=0 THEN sh.s_tax ELSE c.s_tax END),A.st_type,lc.bcode,(CASE WHEN sac_id !=0 THEN sh.mailname ELSE c.ac_name END),a.u_imporm--,it.eit_name
ORDER BY (CASE WHEN sac_id !=0 THEN sh.mailname ELSE c.ac_name END)

OPEN CUR_MHFRM704J_1
FETCH NEXT FROM CUR_MHFRM704J_1 INTO @PER,@vatONAMT,@TAXAMT,@NET_AMT,@EXPAMT,@PARTY_NM,@S_TAX,@U_IMPORM--,@mcomm
WHILE (@@FETCH_STATUS=0)
BEGIN

	--SET @PER =CASE WHEN @PER IS NULL THEN 0 ELSE @PER END
	SET @vatONAMT=CASE WHEN @vatONAMT IS NULL THEN 0 ELSE @vatONAMT END
	SET @TAXAMT1=CASE WHEN @TAXAMT1 IS NULL THEN 0 ELSE @TAXAMT1 END
	SET @NET_AMT=CASE WHEN @NET_AMT IS NULL THEN 0 ELSE @NET_AMT END
	SET @EXPAMT=CASE WHEN @EXPAMT IS NULL THEN 0 ELSE @EXPAMT END
	SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
	--SET @INV_NO=CASE WHEN @INV_NO IS NULL THEN '' ELSE @INV_NO END
	--SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
	--SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END
	SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
	SET @U_IMPORM=CASE WHEN @U_IMPORM IS NULL THEN '' ELSE @U_IMPORM END
	--SET @mcomm=CASE WHEN @mcomm IS NULL THEN '' ELSE @mcomm END
	--SET @FORM_NM=CASE WHEN @FORM_NM IS NULL THEN '' ELSE @FORM_NM END     
   -- SET @STTYPE=CASE WHEN @STTYPE IS NULL THEN '' ELSE @STTYPE END
	--SET @TAX_NAME=CASE WHEN @TAX_NAME IS NULL THEN '' ELSE @TAX_NAME END
	--SET @u_lrno=CASE WHEN @u_lrno IS NULL THEN '' ELSE @u_lrno END
	--SET @rform_nm=CASE WHEN @rform_nm IS NULL THEN '' ELSE @rform_nm END
	--SET @TYPOFCLR=CASE WHEN @TYPOFCLR IS NULL THEN '' ELSE @TYPOFCLR END
	--SET @state=CASE WHEN @state IS NULL THEN '' ELSE @state END

	INSERT INTO #MHFRM704J_6 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,S_TAX,u_imporm)--,mcomm)
                 VALUES (1,'1','A',@PER,@vatONAMT,@TAXAMT,@NET_AMT,@EXPAMT,@PARTY_NM,@S_TAX,@U_IMPORM)--,@mcomm)
	
	SET @CHAR=@CHAR+1
	--FETCH NEXT FROM CUR_MHFRM704J_1 INTO @PER,@vatONAMT,@TAXAMT,@NET_AMT,@EXPAMT,@DATE,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX,@STTYPE,@TAX_NAME,@u_lrno,@rform_nm,@TYPOFCLR,@state
	FETCH NEXT FROM CUR_MHFRM704J_1 INTO @PER,@vatONAMT,@TAXAMT,@NET_AMT,@EXPAMT,@PARTY_NM,@S_TAX,@U_IMPORM--,@mcomm
END
CLOSE CUR_MHFRM704J_1
DEALLOCATE CUR_MHFRM704J_1

Update #MHFRM704J_6 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0),-- INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''),-- ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),
					 ,u_imporm = isnull(u_imporm,'')
					 --,mcomm = isnull(mcomm,'')

 SELECT * FROM #MHFRM704J_6 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO--,inv_no

End
