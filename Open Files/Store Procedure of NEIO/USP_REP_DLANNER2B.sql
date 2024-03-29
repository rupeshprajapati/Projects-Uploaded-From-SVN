
If Exists(Select [Name] from Sysobjects where xType='P' and Id=Object_Id(N'USP_REP_DLANNER2B'))
Begin
	Drop Procedure USP_REP_DLANNER2B
End
Go
set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go




/*
EXECUTE USP_REP_DLANNER2B'','','','04/01/2012','04/30/2015','','','','',0,0,'','','','','','','','','2010-2012',''
*/

-- =============================================
-- Author:		Hetal L Patel
-- Create date: 22/05/2010
-- Description:	This Stored procedure is useful to generate Delhi Summary of Sales (As per DVAT-31)
-- Modify date: 07/06/2010
-- Modified By: Sandeep Shah
-- Remark     : Add month column 
 -- Modify date: 06/07/2010
 -- Modified By: sandeep shah 
 -- Description: Add address & item desc data calculation for TKT-2350
 -- Modify date: 30/08/2011
 -- Modified By: sandeep shah 
 -- Description: Rectifed calculation of column inter state sale for TKT-9443 
 -- Modified By/date/reason: sandeep/26-oct-13/for bug-20342

-- =============================================
CREATE PROCEDURE [dbo].[USP_REP_DLANNER2B]
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
 
SELECT ENTRY_TY,BCODE=(CASE WHEN EXT_VOU=1 THEN BCODE_NM ELSE ENTRY_TY END),STAX_ITEM,stax_round  INTO #LCODE FROM LCODE --for bug-6755,LUBRI

Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2)

----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,U_IMPORM
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code = 999999999999999999-999999999999999999,itserial=space(5)
INTO #DLVAT_31
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #DLVAT_31 add recno int identity

---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),
STM.FORM_NM,AC1.S_TAX,ITEMTYPE=SPACE(1),STTYPE1=SPACE(20),STTYPE=SPACE(20),MTH=SPACE(20),sign1=SPACE(1)
INTO #DLVAT31
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
		SET @SQLCOMMAND='Insert InTo #DLVAT_31 Select * from '+@MCON
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
		SET @SQLCOMMAND='Insert InTo #DLVAT_31 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		--SET @SQLCOMMAND='SELECT * FROM '+@MCON
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0 

-----
-----SELECT * from #form221_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
------->- PART 1-4 
Declare @TAXONAMT as numeric(12,2),@TAXAMT1 as numeric(12,2),@ITEMAMT as numeric(12,2),@INV_NO as varchar(10),@DATE as smalldatetime,@PARTY_NM as varchar(50),@ADDRESS as varchar(100),@ITEM as varchar(50),@FORM_NM as varchar(30),@S_TAX as varchar(30),@QTY as numeric(18,4),@ITEMTYPE AS VARCHAR(1),@STTYPE1 AS VARCHAR(20),@sign1 AS VARCHAR(1),@STTYPE AS VARCHAR(20),@MTH AS VARCHAR (20)

SELECT @TAXONAMT=0,@TAXAMT1 =0,@ITEMAMT =0,@INV_NO ='',@DATE ='',@PARTY_NM ='',@ADDRESS ='',@ITEM ='',@FORM_NM='',@S_TAX ='',@QTY=0

--select PARTY_NM,CONVERT(VARCHAR,Datename(month, date )) + ' ' +Convert(Varchar,DatePart(Year, date)),SUM(NET_AMT),SUM(VATONAMT),TAX_NAME,SUM(TAXAMT) from #DLVAT_31  where party_nm='DEIFY INFRASTRUCTURES LTD.                        ' 
--GROUP BY CONVERT(VARCHAR,Datename(month, date )) + ' ' +Convert(Varchar,DatePart(Year, date)),TAX_NAME,PARTY_NM

Declare cur_dlvat31 Cursor for

SELECT DISTINCT  A.Per,cc.Taxable,cc.TAXAMT,cc.ITEMAMT,INV_NO='',mth=CONVERT(VARCHAR,Datename(month, a.date) ) + ' '
 +Convert(Varchar,DatePart(Year, a.date)) ,A.PARTY_NM,A.ADDRESS,FORM_NM=CASE WHEN d.form_no<>'' THEN D.FORM_no ELSE D.FORM_NM END,A.S_TAX,
A.ITEMTYPE,
STTYPE1=CASE WHEN D.VATMTYPE IN ('Composition Rate','Assessment','Specific Material') then 'Works Contract' else 'Sales of Goods'  END 
--,STTYPE1=CASE WHEN D.VATMTYPE in ('Inter-State Branch','Inter-State Consignment Transfer','Export Out of India','High Sea Sales','Inter State sales','Local sales')
,sign1 = CASE WHEN A.BHENT IN ('DN')THEN '+' ELSE CASE WHEN A.BHENT ='CN' THEN '-' ELSE ' ' END END 

--,STTYPE = CASE WHEN A.ST_TYPE='OUT OF COUNTRY' AND A.TAXAMT=0 AND D.VATMTYPE<>'High Seas Sale' THEN 'EXPORT' 
--ELSE CASE WHEN A.ST_TYPE='OUT OF STATE' AND A.TAXAMT<>0 AND D.VATMTYPE<>'High Seas Sale' THEN 'STATE' 
--ELSE CASE WHEN A.ST_TYPE='LOCAL' AND A.TAXAMT<>0 AND D.VATMTYPE<>'High Seas Sale' THEN 'LOCAL' else 
--CASE WHEN A.ST_TYPE='OUT OF STATE' AND A.TAXAMT=0 AND D.VATMTYPE<>'High Seas Sale' THEN 'branch'-- end  END  END END 
--else CASE WHEN D.VATMTYPE='High Seas Sale' then 'HSEAS'  END end  END  END END 
/*
,STTYPE = CASE when c.ST_type='OUT OF STATE' AND  a.u_imporm='Inter-State Branch' and a.tax_name='FORM F' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'BRANCH' 
ELSE CASE WHEN  c.ST_type='OUT OF STATE' AND  a.u_imporm='Inter-State Consignment Transfer' and a.tax_name='FORM F' and a.taxamt=0  AND  Lc.BCODE='ST' THEN 'consg'
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='Export Out of India' and a.TAX_NAME='Form I' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'EXPORT' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='High Sea Sales' AND  Lc.BCODE='ST' THEN 'HSEAS'  --and c.vatmtype='HSP' 	
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='Inter-State Branch' AND  Lc.BCODE='ST'  THEN 'STATE' 
ELSE CASE WHEN C.ST_TYPE='LOCAL' AND a.u_imporm='Local sales' AND Lc.BCODE='ST' THEN 'LOCAL' 
ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%'  and  Lc.BCODE='ST' THEN 'FUEL' 
ELSE CASE WHEN  it.it_name like '%land%' AND  Lc.BCODE='S1' THEN 'LAND' 
ELSE CASE WHEN c.ST_type='OUT OF COUNTRY' AND a.tax_name='Form H' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'FORMH' 
END end  END  END END end end end end 
*/

,STTYPE = CASE when c.ST_type='OUT OF STATE' AND  a.u_imporm='Branch Transfer' --and a.tax_name='FORM F'
	 and (a.taxamt)=0 AND  Lc.BCODE='ST' THEN 'BRANCH' 
ELSE CASE WHEN  c.ST_type='OUT OF STATE' AND  a.u_imporm='Consignment Transfer' --and a.tax_name='FORM F'
 and (a.taxamt)=0  AND  Lc.BCODE='ST' THEN 'consg'
ELSE CASE WHEN c.ST_type in ('OUT OF STATE','OUT OF COUNTRY') AND a.u_imporm='Export Out of India' 
--and a.TAX_NAME='Form I'
 and (a.taxamt)=0 AND  Lc.BCODE='ST' THEN 'EXPORT' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='High Sea Sales' AND  Lc.BCODE='ST' THEN 'HSEAS'  --and c.vatmtype='HSP' 	
--ELSE CASE WHEN C.ST_type='OUT OF STATE' AND ST.FORM_NM IN('E2 Form','E1 Form') and  ST.RFORM_NM IN ('FORM C') AND A.TAX_NAME<>'EXEMPTED'  AND a.tax_name IN ('E - 1','E - 2')  THEN 'CE1E2FRM' 
--ELSE CASE WHEN C.ST_type='OUT OF STATE' AND ST.FORM_NM<>'' or  ST.RFORM_NM<>'' AND A.TAX_NAME<>'EXEMPTED'  THEN 'CE1E2FRM' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' --AND a.u_imporm='Inter-State Branch'
 and  a.u_imporm<>'Branch Transfer' AND a.u_imporm<>'Consignment Transfer' and a.u_imporm<>'Export Out of India' and   Lc.BCODE='ST'  THEN 'STATE' 
ELSE CASE WHEN C.ST_TYPE='LOCAL' -- AND a.u_imporm='Local sales' 
AND Lc.BCODE='ST' THEN 'LOCAL' 
ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%' AND C.ST_TYPE='LOCAL'  and	Lc.BCODE='ST' THEN 'FUEL' 
--ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%'  and   Lc.BCODE='ST' THEN 'FUEL' 
END end  END  END END end END

FROM #DLVAT_31 A
 inner join stmain d on (A.Bhent = d.Entry_ty And A.Tran_cd = d.Tran_cd) 	
INNER JOIN AC_MAST C ON (d.AC_ID = C.AC_ID)
left join DNMAIN dn on (A.Bhent = dN.Entry_ty And A.Tran_cd = dN.Tran_cd)
left join CNMAIN Cn on (A.Bhent = CN.Entry_ty And A.Tran_cd = CN.Tran_cd)
LEFT JOIN SBMAIN S1 ON (A.Bhent = S1.Entry_ty And A.Tran_cd = S1.Tran_cd)
left join it_mast it on ( A.it_code = it.it_code)
inner join #lcode lc on (a.Bhent = lc.Entry_ty)

inner join 
(SELECT a.per,A.Party_nm,mth=CONVERT(VARCHAR,Datename(month, a.date )) + ' ' +Convert(Varchar,DatePart(Year, a.date)),
Taxable=SUM(A.VATONAMT)--cast(sum((round(B.QTY*B.RATE,2)-(B.TOT_DEDUC))+B.TOT_EXAMT+B.TOT_TAX) as decimal (18,2)),
,TAXAMT=sum(a.taxamt),ITEMAMT=sum(A.Net_amt)
--,STTYPE=CASE WHEN A.ST_TYPE='OUT OF COUNTRY' AND A.TAXAMT=0 and D.VATMTYPE<>'High Seas Sale' THEN 'EXPORT'
-- ELSE CASE WHEN A.ST_TYPE='OUT OF STATE'AND A.TAXAMT<>0  and  D.VATMTYPE<>'High Seas Sale' THEN 'STATE'
-- ELSE CASE WHEN A.ST_TYPE='LOCAL' AND A.TAXAMT<>0  and  D.VATMTYPE<>'High Seas Sale' THEN 'LOCAL' else 
--CASE WHEN A.ST_TYPE='OUT OF STATE' AND A.TAXAMT=0  AND d.VATMTYPE<>'High Seas Sale' THEN 'branch'-- end  END  END END 
--else CASE WHEN D.VATMTYPE='High Seas Sale' then 'HSEAS'  END end  END  END END 
/*
,STTYPE = CASE when c.ST_type='OUT OF STATE' AND  a.u_imporm='Inter-State Branch' and a.tax_name='FORM F' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'BRANCH' 
ELSE CASE WHEN  c.ST_type='OUT OF STATE' AND  a.u_imporm='Inter-State Consignment Transfer' and a.tax_name='FORM F' and a.taxamt=0  AND  Lc.BCODE='ST' THEN 'consg'
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='Export Out of India' and a.TAX_NAME='Form I' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'EXPORT' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='High Sea Sales' AND  Lc.BCODE='ST' THEN 'HSEAS'  --and c.vatmtype='HSP' 	
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='Inter-State Branch' AND  Lc.BCODE='ST'  THEN 'STATE' 
ELSE CASE WHEN C.ST_TYPE='LOCAL' AND a.u_imporm='Local sales' AND Lc.BCODE='ST' THEN 'LOCAL' 
ELSE CASE WHEN  it.it_name like '%land%' AND  Lc.BCODE='S1' THEN 'LAND' 
ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%'  and  Lc.BCODE='ST' THEN 'FUEL' 
ELSE CASE WHEN c.ST_type='OUT OF COUNTRY' AND a.tax_name='Form H' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'FORMH' 
END end  END  END END end end end end 
*/

,STTYPE = CASE when c.ST_type='OUT OF STATE' AND  a.u_imporm='Branch Transfer' --and a.tax_name='FORM F'
	 and (a.taxamt)=0 AND  Lc.BCODE='ST' THEN 'BRANCH' 
ELSE CASE WHEN  c.ST_type='OUT OF STATE' AND  a.u_imporm='Consignment Transfer' --and a.tax_name='FORM F'
 and (a.taxamt)=0  AND  Lc.BCODE='ST' THEN 'consg'
ELSE CASE WHEN c.ST_type in ('OUT OF STATE','OUT OF COUNTRY') AND a.u_imporm='Export Out of India' 
--and a.TAX_NAME='Form I'
 and (a.taxamt)=0 AND  Lc.BCODE='ST' THEN 'EXPORT' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='High Sea Sales' AND  Lc.BCODE='ST' THEN 'HSEAS'  --and c.vatmtype='HSP' 	
--ELSE CASE WHEN C.ST_type='OUT OF STATE' AND ST.FORM_NM IN('E2 Form','E1 Form') and  ST.RFORM_NM IN ('FORM C') AND A.TAX_NAME<>'EXEMPTED'  AND a.tax_name IN ('E - 1','E - 2')  THEN 'CE1E2FRM' 
--ELSE CASE WHEN C.ST_type='OUT OF STATE' AND ST.FORM_NM<>'' or  ST.RFORM_NM<>'' AND A.TAX_NAME<>'EXEMPTED'  THEN 'CE1E2FRM' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' --AND a.u_imporm='Inter-State Branch'
 and  a.u_imporm<>'Branch Transfer' AND a.u_imporm<>'Consignment Transfer' and a.u_imporm<>'Export Out of India' and   Lc.BCODE='ST'  THEN 'STATE' 
ELSE CASE WHEN C.ST_TYPE='LOCAL' -- AND a.u_imporm='Local sales' 
AND Lc.BCODE='ST' THEN 'LOCAL' 
ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%' AND C.ST_TYPE='LOCAL'  and	Lc.BCODE='ST' THEN 'FUEL' 
--ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%'  and   Lc.BCODE='ST' THEN 'FUEL' 
END end  END  END END end END

--
  FROM #dlvat_31 A 
 inner join LITEM_vW B ON (A.BHENT = B.Entry_Ty and A.Tran_cd = B.Tran_cd AND a.itserial=b.itserial) 
 inner join stmain d on (A.Bhent = d.Entry_ty And A.Tran_cd = d.Tran_cd) 
INNER JOIN AC_MAST C ON (d.AC_ID = C.AC_ID)
left join DNMAIN dn on (A.Bhent = dN.Entry_ty And A.Tran_cd = dN.Tran_cd)
left join CNMAIN Cn on (A.Bhent = CN.Entry_ty And A.Tran_cd = CN.Tran_cd)
left join it_mast it on ( A.it_code = it.it_code)
inner join #lcode lc on (a.Bhent = lc.Entry_ty)
	
group by CONVERT(VARCHAR,Datename(month, a.date )) + ' ' +Convert(Varchar,DatePart(Year, a.date)),A.Party_nm,A.PER,
--,CASE WHEN A.ST_TYPE='OUT OF COUNTRY' AND A.TAXAMT=0 AND D.VATMTYPE<>'High Seas Sale' THEN 'EXPORT'  
--ELSE CASE WHEN A.ST_TYPE='OUT OF STATE' AND A.TAXAMT<>0  AND D.VATMTYPE<>'High Seas Sale' THEN 'STATE'
--ELSE CASE WHEN A.ST_TYPE='LOCAL' AND A.TAXAMT<>0  AND D.VATMTYPE<>'High Seas Sale' THEN 'LOCAL' else 
--CASE WHEN A.ST_TYPE='OUT OF STATE' AND A.TAXAMT=0  AND D.VATMTYPE<>'High Seas Sale' THEN 'branch' else 
--CASE WHEN D.VATMTYPE='High Seas Sale' then 'HSEAS'  END end  END  END END ) CC
/*
CASE when c.ST_type='OUT OF STATE' AND  a.u_imporm='Inter-State Branch' and a.tax_name='FORM F' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'BRANCH' 
ELSE CASE WHEN  c.ST_type='OUT OF STATE' AND  a.u_imporm='Inter-State Consignment Transfer' and a.tax_name='FORM F' and a.taxamt=0  AND  Lc.BCODE='ST' THEN 'consg'
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='Export Out of India' and a.TAX_NAME='Form I' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'EXPORT' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='High Sea Sales' AND  Lc.BCODE='ST' THEN 'HSEAS'  --and c.vatmtype='HSP' 	
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='Inter-State Branch' AND  Lc.BCODE='ST'  THEN 'STATE' 
ELSE CASE WHEN C.ST_TYPE='LOCAL' AND a.u_imporm='Local sales' AND Lc.BCODE='ST' THEN 'LOCAL' 
ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%'  and  Lc.BCODE='ST' THEN 'FUEL' 
ELSE CASE WHEN  it.it_name like '%land%' AND  Lc.BCODE='S1' THEN 'LAND' 
ELSE CASE WHEN c.ST_type='OUT OF COUNTRY' AND a.tax_name='Form H' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'FORMH' 
END end  END  END END end end end end ) 
*/

CASE when c.ST_type='OUT OF STATE' AND  a.u_imporm='Branch Transfer' --and a.tax_name='FORM F'
	 and (a.taxamt)=0 AND  Lc.BCODE='ST' THEN 'BRANCH' 
ELSE CASE WHEN  c.ST_type='OUT OF STATE' AND  a.u_imporm='Consignment Transfer' --and a.tax_name='FORM F'
 and (a.taxamt)=0  AND  Lc.BCODE='ST' THEN 'consg'
ELSE CASE WHEN c.ST_type in ('OUT OF STATE','OUT OF COUNTRY') AND a.u_imporm='Export Out of India' 
--and a.TAX_NAME='Form I'
 and (a.taxamt)=0 AND  Lc.BCODE='ST' THEN 'EXPORT' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='High Sea Sales' AND  Lc.BCODE='ST' THEN 'HSEAS'  --and c.vatmtype='HSP' 	
--ELSE CASE WHEN C.ST_type='OUT OF STATE' AND ST.FORM_NM IN('E2 Form','E1 Form') and  ST.RFORM_NM IN ('FORM C') AND A.TAX_NAME<>'EXEMPTED'  AND a.tax_name IN ('E - 1','E - 2')  THEN 'CE1E2FRM' 
--ELSE CASE WHEN C.ST_type='OUT OF STATE' AND ST.FORM_NM<>'' or  ST.RFORM_NM<>'' AND A.TAX_NAME<>'EXEMPTED'  THEN 'CE1E2FRM' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' --AND a.u_imporm='Inter-State Branch'
 and  a.u_imporm<>'Branch Transfer' AND a.u_imporm<>'Consignment Transfer' and a.u_imporm<>'Export Out of India' and   Lc.BCODE='ST'  THEN 'STATE' 
ELSE CASE WHEN C.ST_TYPE='LOCAL' -- AND a.u_imporm='Local sales' 
AND Lc.BCODE='ST' THEN 'LOCAL' 
ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%' AND C.ST_TYPE='LOCAL'  and	Lc.BCODE='ST' THEN 'FUEL' 
--ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%'  and   Lc.BCODE='ST' THEN 'FUEL' 
END end  END  END END end END ) cc

 on CONVERT (VARCHAR,datename(month,a.date) ) + ' ' +Convert(Varchar,DatePart(Year,a.date))=cc.mth and A.Party_nm=CC.Party_nm AND A.PER=CC.per
 and 
--CASE WHEN A.ST_TYPE='OUT OF COUNTRY' AND A.TAXAMT=0 AND D.VATMTYPE<>'High Seas Sale' THEN 'EXPORT'
-- ELSE CASE WHEN A.ST_TYPE='OUT OF STATE' AND A.TAXAMT<>0 AND D.VATMTYPE<>'High Seas Sale' THEN 'STATE' 
--ELSE CASE WHEN A.ST_TYPE='LOCAL' AND A.TAXAMT<>0 AND D.VATMTYPE<>'High Seas Sale' THEN 'LOCAL' else 
--CASE WHEN A.ST_TYPE='OUT OF STATE' AND A.TAXAMT=0 AND D.VATMTYPE<>'High Seas Sale' THEN 'branch' else 
--CASE WHEN D.VATMTYPE='High Seas Sale' then 'HSEAS'  END end  END  END END =CC.STTYPE 
---- AND A.PER=CC.PER 
/*
CASE when c.ST_type='OUT OF STATE' AND  a.u_imporm='Inter-State Branch' and a.tax_name='FORM F' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'BRANCH' 
ELSE CASE WHEN  c.ST_type='OUT OF STATE' AND  a.u_imporm='Inter-State Consignment Transfer' and a.tax_name='FORM F' and a.taxamt=0  AND  Lc.BCODE='ST' THEN 'consg'
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='Export Out of India' and a.TAX_NAME='Form I' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'EXPORT' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='High Sea Sales' AND  Lc.BCODE='ST' THEN 'HSEAS'  --and c.vatmtype='HSP' 	
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='Inter-State Branch' AND  Lc.BCODE='ST'  THEN 'STATE' 
ELSE CASE WHEN C.ST_TYPE='LOCAL' AND a.u_imporm='Local sales' AND Lc.BCODE='ST' THEN 'LOCAL' 
ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%'  and  Lc.BCODE='ST' THEN 'FUEL' 
ELSE CASE WHEN  it.it_name like '%land%' AND  Lc.BCODE='S1' THEN 'LAND' 
ELSE CASE WHEN c.ST_type='OUT OF COUNTRY' AND a.tax_name='Form H' and a.taxamt=0 AND  Lc.BCODE='ST' THEN 'FORMH' 
END end  END  END END end end end end=CC.STTYPE
*/
CASE when c.ST_type='OUT OF STATE' AND  a.u_imporm='Branch Transfer' --and a.tax_name='FORM F'
	 and (a.taxamt)=0 AND  Lc.BCODE='ST' THEN 'BRANCH' 
ELSE CASE WHEN  c.ST_type='OUT OF STATE' AND  a.u_imporm='Consignment Transfer' --and a.tax_name='FORM F'
 and (a.taxamt)=0  AND  Lc.BCODE='ST' THEN 'consg'
ELSE CASE WHEN c.ST_type in ('OUT OF STATE','OUT OF COUNTRY') AND a.u_imporm='Export Out of India' 
--and a.TAX_NAME='Form I'
 and (a.taxamt)=0 AND  Lc.BCODE='ST' THEN 'EXPORT' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' AND a.u_imporm='High Sea Sales' AND  Lc.BCODE='ST' THEN 'HSEAS'  --and c.vatmtype='HSP' 	
--ELSE CASE WHEN C.ST_type='OUT OF STATE' AND ST.FORM_NM IN('E2 Form','E1 Form') and  ST.RFORM_NM IN ('FORM C') AND A.TAX_NAME<>'EXEMPTED'  AND a.tax_name IN ('E - 1','E - 2')  THEN 'CE1E2FRM' 
--ELSE CASE WHEN C.ST_type='OUT OF STATE' AND ST.FORM_NM<>'' or  ST.RFORM_NM<>'' AND A.TAX_NAME<>'EXEMPTED'  THEN 'CE1E2FRM' 
ELSE CASE WHEN c.ST_type='OUT OF STATE' --AND a.u_imporm='Inter-State Branch'
 and  a.u_imporm<>'Branch Transfer' AND a.u_imporm<>'Consignment Transfer' and a.u_imporm<>'Export Out of India' and   Lc.BCODE='ST'  THEN 'STATE' 
ELSE CASE WHEN C.ST_TYPE='LOCAL' -- AND a.u_imporm='Local sales' 
AND Lc.BCODE='ST' THEN 'LOCAL' 
ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%' AND C.ST_TYPE='LOCAL'  and	Lc.BCODE='ST' THEN 'FUEL' 
--ELSE CASE WHEN  it.it_name like '%Diesel%' or it.it_name like '%Petrol%'  and   Lc.BCODE='ST' THEN 'FUEL' 
END end  END  END END end END=CC.STTYPE
 --AND A.PER=C.PER 
--  WHERE A.BHENT='ST' AND (A.DATE BETWEEN @SDATE AND @EDATE)
WHERE Lc.BCODE IN('ST','DN','CN','SB') AND (A.DATE BETWEEN @SDATE AND @EDATE) 

 order by MTH

--SELECT * FROM #DLVAT_31		



OPEN CUR_DLVAT31
FETCH NEXT FROM CUR_DLVAT31 INTO @PER,@TAXONAMT,@TAXAMT,@ITEMAMT,@INV_NO,@MTH,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX,@ITEMTYPE,@STTYPE1,@sign1,@STTYPE
WHILE (@@FETCH_STATUS=0)
BEGIN

	SET @PER =CASE WHEN @PER IS NULL THEN 0 ELSE @PER END
	SET @TAXONAMT=CASE WHEN @TAXONAMT IS NULL THEN 0 ELSE @TAXONAMT END
	SET @TAXAMT1=CASE WHEN @TAXAMT1 IS NULL THEN 0 ELSE @TAXAMT1 END
	SET @ITEMAMT=CASE WHEN @ITEMAMT IS NULL THEN 0 ELSE @ITEMAMT END
	SET @PARTY_NM=CASE WHEN @PARTY_NM IS NULL THEN '' ELSE @PARTY_NM END
	SET @INV_NO=CASE WHEN @INV_NO IS NULL THEN '' ELSE @INV_NO END
    SET @MTH=CASE WHEN @MTH IS NULL THEN '' ELSE @MTH END
	SET @DATE=CASE WHEN @DATE IS NULL THEN '' ELSE @DATE END
	SET @ADDRESS=CASE WHEN @ADDRESS IS NULL THEN '' ELSE @ADDRESS END
	SET @S_TAX=CASE WHEN @S_TAX IS NULL THEN '' ELSE @S_TAX END
    SET @ITEMTYPE=CASE WHEN @ITEMTYPE IS NULL THEN '' ELSE @ITEMTYPE END
    SET @STTYPE1=CASE WHEN @STTYPE1 IS NULL THEN '' ELSE @STTYPE1 END    
	SET @sign1=CASE WHEN @sign1 IS NULL THEN '' ELSE @sign1 END    
	SET @FORM_NM=CASE WHEN @FORM_NM IS NULL THEN '' ELSE @FORM_NM END     	
    SET @STTYPE=CASE WHEN @STTYPE IS NULL THEN '' ELSE @STTYPE END

	INSERT INTO #DLVAT31 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,INV_NO,MTH,PARTY_NM,ADDRESS,FORM_NM,S_TAX,ITEMTYPE,STTYPE1,sign1,STTYPE)
                 VALUES (1,'1','A',@PER,@TAXONAMT,@TAXAMT,@ITEMAMT,@INV_NO,@MTH,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX,@ITEMTYPE,@STTYPE1,@sign1,@STTYPE)
	
	SET @CHAR=@CHAR+1
	FETCH NEXT FROM CUR_DLVAT31 INTO @PER,@TAXONAMT,@TAXAMT,@ITEMAMT,@INV_NO,@MTH,@PARTY_NM,@ADDRESS,@FORM_NM,@S_TAX,@ITEMTYPE,@STTYPE1,@sign1,@STTYPE
END
CLOSE CUR_DLVAT31
DEALLOCATE CUR_DLVAT31
--<- PART 1-4


Update #DLVAT31 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0),AMT4 = isnull(AMT4,0), INV_NO = isnull(INV_NO,''),DATE = isnull(DATE,''), MTH = isnull(MTH,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

 SELECT * FROM #DLVAT31 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), partsr,SRNO,party_nm,MTH

End




