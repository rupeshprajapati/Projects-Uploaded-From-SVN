If Exists(Select [name] From SysObjects Where xtype='P' and [Name]='USP_REP_GJFORM201')
Begin
	Drop Procedure USP_REP_GJFORM201
End
GO
--EXECUTE USP_REP_GJFORM201'','','','04/01/2013','03/31/2014','','','','',0,0,'','','','','','','','','2013-2014',''
 -- ==================
 -- Author:  Hetal L Patel
 -- Create date: 16/05/2007
 -- Description: This Stored procedure is useful to generate GJ VAT FORM 201
 -- Modify date: 16/05/2007 
 -- Modified By: Hetal Patel
 -- Modify date: /21/07/2009 
 -- Remark: Change made by Hetal to fetch Vat A/c from stax_mas & Minus Deduction Amt From Gross Amt
 -- Modified By: Sandeep Shah
 -- Modify date: /20/10/2010 
 -- Remark: Add additional tax 1 % in Input Tax and Output tax section for TKT-4641 
 -- Modified By:  Gaurav Tanna : Bug-24840 on 17/01/2015

 -- =============================================
CREATE Procedure [dbo].[USP_REP_GJFORM201]
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
 DECLARE @RATE NUMERIC(12,2),@AMTA1 NUMERIC(12,2),@AMTB1 NUMERIC(12,2),@AMTC1 NUMERIC(12,2),@AMTD1 NUMERIC(12,2),@AMTE1 NUMERIC(12,2),@AMTF1 NUMERIC(12,2),@AMTG1 NUMERIC(12,2),@AMTH1 NUMERIC(12,2),@AMTI1 NUMERIC(12,2),@AMTJ1 NUMERIC(12,2),@AMTK1 NUMERIC(12,2),@AMTL1 NUMERIC(12,2),@AMTM1 NUMERIC(12,2),@AMTN1 NUMERIC(12,2),@AMTO1 NUMERIC(12,2),@AMTP1 NUMERIC(12,2)
 DECLARE @AMTA2 NUMERIC(12,2),@AMTB2 NUMERIC(12,2),@AMTC2 NUMERIC(12,2),@AMTD2 NUMERIC(12,2),@AMTE2 NUMERIC(12,2),@AMTF2 NUMERIC(12,2),@AMTG2 NUMERIC(12,2),@AMTH2 NUMERIC(12,2),@AMTI2 NUMERIC(12,2),@AMTJ2 NUMERIC(12,2),@AMTK2 NUMERIC(12,2),@AMTL2 NUMERIC(12,2),@AMTM2 NUMERIC(12,2),@AMTN2 NUMERIC(12,2),@AMTO2 NUMERIC(12,2)
 DECLARE @PER NUMERIC(12,2),@TAXAMT NUMERIC(12,2),@CHAR INT,@LEVEL NUMERIC(12,2)
 
 --SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
 --INSERT INTO #VATAC_MAST SELECT DISTINCT AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1) FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"','"PURCHASES"') AND ISNULL(AC_NAME1,'')<>''
 
Declare @NetEff as numeric (12,2), @NetTax as numeric (12,2),@NETATAX AS NUMERIC (12,2)

Declare @PSDate SmallDatetime, @PEDate SmallDatetime
Declare @PAMTA1 Numeric (12,2)
		  
Set @PSDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, @SDATE) - 1, 0)
Set @PEDate = (DATEADD(DAY, -(DAY(@SDATE)), @SDATE))
/*
----Temporary Cursor1
SELECT BHENT='PT',M.INV_NO,M.Date,A.AC_NAME,A.AMT_TY,STM.TAX_NAME,SET_APP=ISNULL(SET_APP,0),STM.ST_TYPE,M.NET_AMT,M.GRO_AMT,TAXONAMT=M.GRO_AMT+M.TOT_DEDUC+M.TOT_TAX+M.TOT_EXAMT+M.TOT_ADD,PER=STM.LEVEL1,MTAXAMT=M.TAXAMT,TAXAMT=A.AMOUNT,STM.FORM_NM,PARTY_NM=AC1.AC_NAME,AC1.S_TAX,M.U_IMPORM
,ADDRESS=LTRIM(AC1.ADD1)+ ' ' + LTRIM(AC1.ADD2) + ' ' + LTRIM(AC1.ADD3),M.TRAN_CD,VATONAMT=99999999999.99,Dbname=space(20),ItemType=space(1),It_code=999999999999999999-999999999999999999,ItSerial=Space(5)
INTO #FORM201_1
FROM PTACDET A 
INNER JOIN PTMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2 --A.AC_NAME IN ( SELECT AC_NAME FROM #VATAC_MAST)

alter table #FORM201_1 add recno int identity
*/
---Temporary Cursor2
SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=M.TAXAMT,
M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
INTO #FORM201
FROM PTACDET A 
INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
WHERE 1=2

SET @PAMTA1=0

 
IF NOT EXISTS (SELECT 1 
           FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME='FORM201_1') 
	begin
	 print '...'
	 
		 SELECT PART=3,PARTSR='AAA',SRNO='AAA',RATE=99.999,AMT1=NET_AMT,AMT2=M.TAXAMT,AMT3=M.TAXAMT,AMT4=M.TAXAMT,
		 M.INV_NO,M.DATE,PARTY_NM=AC1.AC_NAME,ADDRESS=Ltrim(AC1.Add1)+' '+Ltrim(AC1.Add2)+' '+Ltrim(AC1.Add3),STM.FORM_NM,AC1.S_TAX
		 INTO FORM201_1
		 FROM PTACDET A 
		 INNER JOIN STMAIN M ON (A.ENTRY_TY=M.ENTRY_TY AND A.TRAN_CD=M.TRAN_CD)
		 INNER JOIN STAX_MAS STM ON (M.TAX_NAME=STM.TAX_NAME)
		 INNER JOIN AC_MAST AC ON (A.AC_NAME=AC.AC_NAME)
		 INNER JOIN AC_MAST AC1 ON (M.AC_ID=AC1.AC_ID)
		 WHERE 1=2
		 print 'Previous month credit'
		 insert into FORM201_1 EXECUTE USP_REP_GJFORM201 '','','', @PSDate,@PEDate,'','','','',0,0,'','','','','','','','','2014-2015',''
		
		PRINT 'TEST'
		 SELECT @PAMTA1 = amt1 FROM FORM201_1 WHERE PARTSR = '6' AND SRNO = 'I'

		 DROP TABLE FORM201_1
	end

SET @PAMTA1=CASE WHEN @PAMTA1 IS NULL THEN 0 ELSE @PAMTA1 END

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

		 Print 'in multi co. yes'


		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		
		-- Gaurav - start here
		--SET @SQLCOMMAND='Insert InTo  #FORM201_1 Select * from '+@MCON		
		SET @SQLCOMMAND='Insert InTo VATTBL Select * from '+@MCON
		-- Gaurav - end here
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	End
else
	Begin ------Fetch Single Co. Data
		 Set @MultiCo = 'NO'
		 -- Gaurav - start here 
		 --EXECUTE USP_REP_SINGLE_CO_DATA
		  EXECUTE USP_REP_SINGLE_CO_DATA_VAT
		  @TMPAC, @TMPIT, @SPLCOND, @SDATE, @EDATE
		 ,@SAC, @EAC, @SIT, @EIT, @SAMT, @EAMT
		 ,@SDEPT, @EDEPT, @SCATE, @ECATE,@SWARE
		 ,@EWARE, @SINV_SR, @EINV_SR, @LYN, @EXPARA
		 ,@MFCON = @MCON OUTPUT

		 Print 'in multi co. No'

		/*
		--SET @SQLCOMMAND='Select * from '+@MCON
		---EXECUTE SP_EXECUTESQL @SQLCOMMAND
		SET @SQLCOMMAND='Insert InTo  #FORM201_1 Select * from '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		---Drop Temp Table 
		SET @SQLCOMMAND='Drop Table '+@MCON
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
		*/
		-- Gaurav - end here 
	End
-----
-----SELECT * from #FORM201_1 where (Date Between @Sdate and @Edate) and Bhent in('EP','PT','CN') and TAX_NAME In('','NO-TAX') and U_imporm = ''
-----
--	SELECT TAXAMT,tax_name  FROM #FORM201_1 where bhent = 'ST' AND (DATE BETWEEN @SDATE AND @EDATE)  And S_tax <> '' And ac_name not like '%Rece%' and U_imporm <> 'Purchase Return' 
--    SELECT DISTINCT u_imporm,A.TRAN_cD,B.ADDLVAT1 FROM  #FORM201_1 A INNER JOIN STITEM B ON A.TRAN_CD=B.TRAN_CD  where  bhent = 'ST' AND (A.DATE BETWEEN @SDATE AND @EDATE)  And A.S_tax <> '' And ac_name not like '%Rece%'  and A.U_imporm <> 'Purchase Return'


 
  SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0,@AMTP1=0 



-- Added by pankaj on 14.03.2014
--Description of top 3 commodities dealt in during the tax period.  start

DECLARE @CNT INT,@SRNO VARCHAR(1),@IT_NAME VARCHAR(50)  
SET @CNT=1
-- Changed by Gaurav on 02/12/2014 for Bug 24840 start here
 --DECLARE ITEM CURSOR FOR select distinct  top 3 taxamt=(sum(a.net_amt)/sum(a.gro_amt))*100,C.IT_NAME
 DECLARE ITEM CURSOR FOR select distinct  top 3 taxamt=sum(a.taxamt)+IsNull(Sum(B.ADDLVAT1), 0),C.IT_NAME
FROM VATTBL A 
INNER JOIN IT_MAST C ON (c.IT_CODE=A.IT_CODE)
inner join litem_vw B on (a.BHENT = B.Entry_ty And a.Tran_cd = B.Tran_cd And a.IT_CODE = B.IT_CODE)
WHERE (A.BHENT='ST') AND a.TAX_NAME LIKE '%VAT%' AND a.TAXAMT <> 0 And (a.Date Between @sdate and @edate) -- and c.eit_name<>''
group by C.IT_NAME -- ,(sum(a.net_amt)/sum(a.gro_amt))*100
Order By Sum(A.TaxAmt)+IsNull(Sum(B.ADDLVAT1), 0) desc
--order by  (sum(a.net_amt)/sum(a.gro_amt))*100 desc
OPEN ITEM
FETCH NEXT FROM ITEM INTO @AMTA1,@IT_NAME
WHILE @@FETCH_STATUS=0
BEGIN
	SET @SRNO=CASE WHEN @CNT=1 THEN 'A' WHEN @CNT=2 THEN 'B' WHEN @CNT=3 THEN 'C'  END  	
	INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM, s_tax) VALUES  (1,'11',@SRNO,0,@AMTA1,0,0,0,isnull(@IT_NAME,''), '')
	FETCH NEXT FROM ITEM INTO @AMTA1,@IT_NAME
	SET @CNT=@CNT+1
END 
CLOSE ITEM
DEALLOCATE ITEM

 
WHILE (@CNT < 4) 
	BEGIN
    SET @SRNO=CASE WHEN @CNT=1 THEN 'A' WHEN @CNT=2 THEN 'B' WHEN @CNT=3 THEN 'C'  END  

	INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM, s_tax) VALUES  (1,'11',@SRNO,0,0,0,0,0,isnull('',''), '')
      
    SET @CNT=@CNT+1
END -- WHILE
--Description of top 3 commodities dealt in during the tax period.  end
-- Added by pankaj on 14.03.2014
---- Added by pankaj on 14.03.2014
-- Changed by Gaurav on 02/12/2014 for Bug 24840 end here

--Tax invoice issued in the period start
DECLARE @INV_NO1 VARCHAR(6),@INV_NO2 VARCHAR(6)
select @INV_NO1=inv_no from VATTBL where date between @sdate and @edate and bhent='ST' and s_tax<>'' order by inv_no DESC
update #FORM201 set inv_no=@INV_NO1 where PARTSR='11' 
select @INV_NO2=inv_no from VATTBL where date between @sdate and @edate and bhent='ST' and s_tax<>'' order by inv_no ASC
update #FORM201 set form_nm=@INV_NO2 where PARTSR='11' 
--Tax invoice issued in the period end

set @inv_no1=''
set @inv_no2=''

--Retail invoice issued in the period start
select @INV_NO1=inv_no from VATTBL where date between @sdate and @edate and bhent='ST' and s_tax='' order by inv_no DESC
update #FORM201 set [address]=@INV_NO1 where PARTSR='11' 
select @INV_NO2=inv_no from VATTBL where date between @sdate and @edate and bhent='ST' and s_tax='' order by inv_no asc
update #FORM201 set s_tax=@INV_NO2 where PARTSR='11' 
--Retail invoice issued in the period end


---Part I
-- 01 Total Turnover
SET @AMTA1=0
SET @AMTA2=0
--SELECT @AMTA1=Round(Sum(gro_Amt),0) FROM  (select  a.gro_amt FROM Vattbl A  WHERE A.BHENT in ('ST')  AND (DATE BETWEEN @SDATE AND @EDATE) AND A.TAXAMT <> 0) C 

SELECT @AMTA1=Sum(gro_Amt) FROM  (select  a.gro_amt FROM Vattbl A  WHERE A.BHENT in ('ST')  AND (DATE BETWEEN @SDATE AND @EDATE)) C 
--select  @AMTA1=@AMTA1+CASE WHEN (A.BHENT = 'ST') then a.gro_amT ELSE (a.gro_amt * (-1)) end from Vattbl A  WHERE A.BHENT in ('ST', 'SR', 'CN') AND (DATE BETWEEN @SDATE AND @EDATE)

SELECT @AMTA2=Sum(gro_Amt) FROM  (select a.GRO_AMT FROM VATTBL A  WHERE A.BHENT in ('PT', 'P1', 'EP')  AND (DATE BETWEEN @SDATE AND @EDATE))c 
--select  @AMTA2=@AMTA2+CASE WHEN (A.BHENT = 'PT') then a.gro_amT ELSE (a.gro_amt * (-1)) end from Vattbl A  WHERE A.BHENT in ('PT', 'PR', 'DN') AND (DATE BETWEEN @SDATE AND @EDATE)

SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','A',0,@AMTA1,@AMTA2,0,0,'')

/*
-- 02 Adjustment as per item 29 of Annexure I and 32 of Annexure II
SELECT @AMTA1=Round(Sum(Gro_Amt),0) FROM VATTBL  WHERE BHENT='SR' AND (DATE BETWEEN @SDATE AND @EDATE) AND TAXAMT <> 0
--SELECT @AMTB1=Round(Sum(GRO_AMT),0) FROM VATTBL  WHERE BHENT='PR' AND (DATE BETWEEN @SDATE AND @EDATE)

SELECT @AMTB1=SUM(v.gro_amt)
FROM  VATMAIN_VW v
where v.entry_ty IN ('CN')  And (V.Date between @Sdate And @Edate)

SELECT @AMTB2=SUM(v.gro_amt)
FROM  VATMAIN_VW v
where v.entry_ty IN ('DN')  And (V.Date between @Sdate And @Edate)

 --SELECT @AMTA1=Round(Sum(Net_Amt),0) FROM #FORM201_1  WHERE BHENT='PR' AND (DATE BETWEEN @SDATE AND @EDATE)
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 SET @AMTB2=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB2 END

SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END 
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','B',0,@AMTA1+@AMTB1,@AMTB2,0,0,'')

-- 03 Net Turnover
SELECT @AMTA1=AMT1,@AMTA2=AMT2 FROM #FORM201 WHERE Partsr = '1' and srno = 'A'
SELECT @AMTB1=AMT1,@AMTB2=AMT2 FROM #FORM201 WHERE Partsr = '1' and srno = 'B'
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','C',0,@AMTA1-@AMTB1,@AMTA2-@AMTB2,0,0,'')
*/


-- 02 Deduct:
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','D',0,0,0,0,0,'')

---Agricultaral Goods--
-- 02. 1 Exempted from tax under section 5(1)
SET @AMTA1=0
SET @AMTA2=0
SET @AMTB1=0
SET @AMTB2=0

 SELECT @AMTA1=Sum(Gro_Amt) FROM Vattbl 
 INNER JOIN IT_MAST ON VATTBL.It_code = IT_MAST.It_code 
 WHERE IT_MAST.U_SHCODE in ('SCHEDULE I') AND BHENT in ('ST') AND (DATE BETWEEN @SDATE AND @EDATE)
 
 SELECT @AMTB1=Sum(Gro_Amt) FROM Vattbl 
 INNER JOIN IT_MAST ON VATTBL.It_code = IT_MAST.It_code 
 WHERE IT_MAST.U_SHCODE in ('SCHEDULE I') AND BHENT in ('PT', 'P1', 'EP') AND (DATE BETWEEN @SDATE AND @EDATE)
 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DA',0,@AMTA1+@AMTA2,@AMTB1+@AMTB2,0,0,'')
 
 
--02.2 Exempted from tax under section 5(2)
 SET @AMTA1=0
SET @AMTA2=0
SET @AMTB1=0
SET @AMTB2=0

  SELECT @AMTA1=Sum(Gro_Amt) FROM Vattbl WHERE TAX_NAME='EXEMPTED' AND BHENT in ('ST') AND (DATE BETWEEN @SDATE AND @EDATE)
 --Select @AMTA2=Round(Sum(Gro_Amt),0) from VATTBL Where (Date between @Sdate and @Edate) and st_type = 'Local' and Bhent = 'ST' and u_imporm = 'Branch Transfer' and Tax_name = ' ' 
 SELECT @AMTB1=Sum(Gro_Amt) FROM VATTBL WHERE TAX_NAME='EXEMPTED' AND BHENT in('PT', 'P1', 'EP') AND (DATE BETWEEN @SDATE AND @EDATE)
 --Select @AMTB2=Round(Sum(Gro_Amt),0) from VATTBL Where (Date between @Sdate and @Edate) and st_type = 'Local' and Bhent In('PT','P1','EP') and u_imporm = 'Branch Transfer' and Tax_name = ' ' 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DB',0,@AMTA1+@AMTA2,@AMTB1+@AMTB2,0,0,'')
 --INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DB',0,0,0,0,0,'')
 
--02.3 Branch transfer or consignment to and from outside the State.
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DC',0,0,0,0,0,'')
 
-- (a) of the goods manufactured
SET @AMTA1=0
SET @AMTA2=0

 SELECT @AMTA1=Sum(gro_amt) FROM VATTBL WHERE ST_TYPE = 'OUT OF STATE' AND BHENT='ST' AND U_IMPORM IN ('Branch Transfer', 'Consignment Transfer')  AND (DATE BETWEEN @SDATE AND @EDATE) 
 --SELECT @AMTA2=Sum(Gro_Amt) FROM VATTBL WHERE ST_TYPE = 'OUT OF STATE' AND BHENT in('PT','P1','EP') AND U_IMPORM='Branch Transfer'  AND (DATE BETWEEN @SDATE AND @EDATE) 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DD',0,@AMTA1,@AMTA2,0,0,'')

-- (b) other than (a) above
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DE',0,0,0,0,0,'')

--02.4 Purchases not qualifying for tax credit as per section 11(8) read with section 11(5)
-- (either unregisterd dealer or purchase of capital goods OR Composition Dealer)
SET @AMTA1=0
SET @AMTA2=0
 
 SELECT @AMTA1=Sum(gro_Amt) FROM VATTBL B 
 inner Join It_mast C on (B.It_code = c.It_code) 
 WHERE BHENT in ('PT', 'P1', 'EP') AND (B.DATE BETWEEN @SDATE AND @EDATE) And (c.vatcap = 1 OR b.U_IMPORM = 'Composition Dealer')
 
 SELECT @AMTA2=Sum(gro_Amt) FROM VATTBL B 
 inner Join It_mast C on (B.It_code = c.It_code) 
 WHERE B.BHENT in ('PT', 'P1', 'EP') AND (B.DATE BETWEEN @SDATE AND @EDATE) And s_tax = ''  And (c.vatcap <> 1 And b.U_IMPORM <> 'Composition Dealer')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DF',0,0,@AMTA1+@AMTA2,0,0,'')
 
 
 SET @AMTA1=0
SET @AMTA2=0
--02.5 Reduction as per item 37 of Annexure III
 SELECT  @AMTA1=Sum(Gro_Amt) FROM (SELECT  a.Gro_amt FROM VATTBL a WHERE (a.ST_TYPE in('OUT OF COUNTRY')) AND a.BHENT='ST' AND (a.DATE BETWEEN @SDATE AND @EDATE) )C
 SELECT  @AMTA2=Sum(Gro_Amt) FROM (SELECT  a.GRO_AMT FROM VATTBL a WHERE (a.ST_TYPE in('OUT OF COUNTRY')) AND a.BHENT IN ('PT', 'P1', 'EP') AND (a.DATE BETWEEN @SDATE AND @EDATE) )C
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DG',0,@AMTA1,@AMTA2,0,0	,'')

SET @AMTA1=0
SET @AMTA2=0
--02.6 Charges towards labour, service and other charges referred to in sub-clause (c) of clause (30) of section 2
 select @AMTA1=Sum(Gro_Amt) from VATTBL where (Date between @Sdate and @Edate) and st_type = 'Local' and Bhent In('LI', 'I5', 'IL') 
 --select @AMTA2=Sum(Gro_Amt) from VATTBL where (Date between @Sdate and @Edate) and st_type = 'Local' and Bhent In('LR', 'R1', 'RL') 
 
  SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DH',0,@AMTA1,@AMTA2,0,0,'')


--Total of (02.1) to ( 02. 6)
 SELECT @AMTA1=sum(AMT1),@AMTA2=sum(AMT2) FROM #FORM201 WHERE Partsr = '1' and srno in('DA','DB','DD','DE','DF','DG','DH')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','E',0,@AMTA1,@AMTA2,0,0,'')
 
 --03 Net Taxable Turnover (01-03 )
 SELECT @AMTA1=sum(AMT1),@AMTA2=sum(AMT2) FROM #FORM201 WHERE Partsr = '1' and srno in('A')

 SELECT @AMTB1=sum(AMT1),@AMTB2=sum(AMT2) FROM #FORM201 WHERE Partsr = '1' and srno in('E')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','F',0,@AMTA1-@AMTB1,@AMTA2-@AMTB2,0,0,'')
 
 -- PART II
---OutPut Tax
declare @form_nm varchar(50)
declare @comm_nm varchar(100)
Declare @NetOEff as numeric (12,2), @NetOTax as numeric (12,2),@NETOATAX AS NUMERIC (12,2)
Declare @cPer As Varchar(1)
Declare @TotAmt as numeric (12,2)

SELECT @NetOEff = 0, @NetOTax = 0, @NETOATAX = 0, @TotAmt = 0
SELECT @cPer = ''

 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0,@AMTP1=0 

 SET @CHAR=65
 
 DECLARE  CUR_FORM221 CURSOR FOR 
 --select distinct level1 from stax_mas where ST_TYPE='LOCAL' and level1 in ('1.00','4.00','12.50','15.00') --CHARINDEX('VAT',TAX_NAME)>0
  select distinct level1 from stax_mas --where ST_TYPE='LOCAL'
 OPEN CUR_FORM221
 FETCH NEXT FROM CUR_FORM221 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
  --SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0,@AMTP1=0 

  
  if (@Per <> 0)
	  Begin
		INSERT INTO #FORM201
	    (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,FORM_NM)
	     
		SELECT 1, 
		'2', 
		CASE WHEN @per = 1.00 THEN 'A' WHEN (@per = 4.00) THEN 'B' WHEN (@per = 12.50) THEN 'C' ELSE 'D'  END, 
		@Per, 
		(Sum(VATTBL.GRO_AMT) - Sum(VATTBL.TAXAMT) - IsNull(Sum(B.ADDLVAT1), 0)),
		Sum(VATTBL.TAXAMT),	
		Sum(VATTBL.GRO_AMT),
	    IsNull(Sum(B.ADDLVAT1), 0),				
		it_mast.It_name, 
		it_mast.HSNCODE 
		FROM VATTBL 
		Inner Join IT_MAST ON IT_MAST.It_code = VATTBL.It_code
		inner join litem_vw B on (VATTBL.BHENT = B.Entry_ty And VATTBL.Tran_cd = B.Tran_cd And VATTBL.IT_CODE = B.IT_CODE)
		--Left Join STITEM ON VATTBL.TRAN_CD=STITEM.TRAN_CD
		where VATTBL.bhent in ('ST') And VATTBL.S_tax <> '' AND VATTBL.PER=@Per AND VATTBL.TAX_NAME LIKE '%VAT%' AND VATTBL.TAXAMT <> 0
		AND (VATTBL.DATE BETWEEN @SDATE AND @EDATE)
		group by IT_MAST.it_name, it_mast.HSNCODE, VATTBL.PER
	  
	  end
	  
	  -- Tax Payable on Purchase (when purchase is from non -registered dealers)
	  Begin
		INSERT INTO #FORM201
	    (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,FORM_NM)
	     
		SELECT 2, 
		'2', 
		CASE WHEN @per = 1.00 THEN 'E' WHEN (@per = 4.00) THEN 'F' WHEN (@per = 12.50) THEN 'G' ELSE 'H'  END, 
		@Per, 
		(Sum(VATTBL.GRO_AMT) - Sum(VATTBL.TAXAMT) - IsNull(Sum(B.ADDLVAT1), 0)),
		Sum(VATTBL.TAXAMT),	
		Sum(VATTBL.GRO_AMT),
	    IsNull(Sum(B.ADDLVAT1), 0),				
		it_mast.It_name, 
		it_mast.HSNCODE 
		FROM VATTBL 
		Inner Join IT_MAST ON IT_MAST.It_code = VATTBL.It_code
		inner join litem_vw B on (VATTBL.BHENT = B.Entry_ty And VATTBL.Tran_cd = B.Tran_cd And VATTBL.It_code = B.It_code)
		--Left Join STITEM ON VATTBL.TRAN_CD=STITEM.TRAN_CD
		where VATTBL.bhent in ('PT') And VATTBL.S_tax = '' AND VATTBL.PER=@Per AND VATTBL.TAX_NAME LIKE '%VAT%' AND VATTBL.TAXAMT <> 0
		AND (VATTBL.DATE BETWEEN @SDATE AND @EDATE)
		group by IT_MAST.it_name, it_mast.HSNCODE, VATTBL.PER
	  
	  end
   
  FETCH NEXT FROM CUR_FORM221 INTO @PER
 END
 CLOSE CUR_FORM221
 DEALLOCATE CUR_FORM221
 
 -- If no challan paid then print blank detail. 
 SET @AMTA1=0
 Select @AMTA1=COUNT(PART) From #FORM201 Where Partsr = '2'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

IF @AMTA1 = 0
	INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'2','A',0,0,0,0,0,'')  


SET @AMTA1=0
SET @AMTA2=0
SET @AMTB1=0
SET @AMTB2=0

---Total of Tax & Taxable Amount of Sales for the period
select @AMTA1=sum(amt1) FROM #FORM201 where partsr='2' And part=1 and srno in ('A','B','C','D','E','F','G','H','I','J')
select @AMTA2=sum(amt2) FROM #FORM201 where partsr='2' And part=1 and srno in ('A','B','C','D','E','F','G','H','I','J')
select @AMTB1=sum(amt3) FROM #FORM201 where partsr='2' And part=1 and srno in ('A','B','C','D','E','F','G','H','I','J')
select @AMTB2=sum(amt4) FROM #FORM201 where partsr='2' And part=1 and srno in ('A','B','C','D','E','F','G','H','I','J')

SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END

/*
INSERT INTO #FORM201
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES
(1,'2','Z',0,@AMTA1,@AMTA2,@AMTB1,@AMTB2,'')
*/

SET @AMTC1=0
SET @AMTC2=0
SET @AMTD1=0
SET @AMTD2=0

---Total of Tax & Taxable Amount of Purchase of Taxable goods for the period
select @AMTC1=sum(amt1) FROM #FORM201 where partsr='2' And part=2 and srno in ('A','B','C','D','E','F','G','H','I','J')
select @AMTC2=sum(amt2) FROM #FORM201 where partsr='2' And part=2 and srno in ('A','B','C','D','E','F','G','H','I','J')
select @AMTD1=sum(amt3) FROM #FORM201 where partsr='2' And part=2 and srno in ('A','B','C','D','E','F','G','H','I','J')
select @AMTD2=sum(amt4) FROM #FORM201 where partsr='2' And part=2 and srno in ('A','B','C','D','E','F','G','H','I','J')

SET @AMTC1=CASE WHEN @AMTC1 IS NULL THEN 0 ELSE @AMTC1 END
SET @AMTC2=CASE WHEN @AMTC2 IS NULL THEN 0 ELSE @AMTC2 END
SET @AMTD1=CASE WHEN @AMTD1 IS NULL THEN 0 ELSE @AMTD1 END
SET @AMTD2=CASE WHEN @AMTD2 IS NULL THEN 0 ELSE @AMTD2 END


INSERT INTO #FORM201
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES
(1,'2A','Z',0,@AMTA1+@AMTC1,@AMTA2+@AMTC2,@AMTB1+@AMTD1,@AMTB2+@AMTD2,'')

/*
SET @AMTA1=0
SET @AMTB1=0

 SELECT @AMTA1=AMT2+AMT4 FROM #FORM201 WHERE Partsr = '2' and srno in('Z')
 SELECT @AMTB1=AMT2+AMT4 FROM #FORM201 WHERE Partsr = '2A' and srno in('Z')
 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
  SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
  
  INSERT INTO #FORM201
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES
(1,'2B','Z',0,@AMTA1,@AMTB1,@AMTA1+@AMTB1,0,'')
*/  
   
 INSERT INTO #FORM201
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES
(1,'2B','Z',0,@AMTA2+@AMTB2,@AMTC2+@AMTD2,@AMTA2+@AMTB2+@AMTC2+@AMTD2,0,'')


/*
-- 06
--C.S.T. (i) Against Form C/D 
 Select @AMTA1=Round(Sum(Gro_Amt),0),@AMTB1=Round(Sum(TaxAmt),0) from VATTBL A INNER JOIN STAX_MAS ST ON (A.tax_name=ST.TAX_NAME and st.entry_ty='st') 
 Where A.Bhent in ('ST', 'PR', 'DN') AND (A.DATE BETWEEN @SDATE AND @EDATE) And A.St_type = 'Out of State' and A.Tax_name like '%C.S.T%' AND ST.Rform_nm in ('Form C','C Form','Form D','D Form') AND a.TAXAMT <> 0
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES (1,'2','ZA',0,@AMTA1-@AMTB1,@AMTB1,@AMTA1,0,'')

 --C.S.T. (ii) Other than (i) above.
 Select @AMTA1=Round(Sum(Gro_Amt),0),@AMTB1=Round(Sum(TaxAmt),0) from VATTBL A INNER JOIN STAX_MAS ST ON (A.tax_name=ST.TAX_NAME and st.entry_ty='st') 
 Where A.Bhent in('ST', 'PR', 'DN')  AND (A.DATE BETWEEN @SDATE AND @EDATE) And A.St_type = 'Out of State' and A.Tax_name like '%C.S.T%' AND ST.Rform_nm not in ('Form C','C Form','Form D','D Form') AND a.TAXAMT <> 0
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES (1,'2','ZB',0,@AMTA1-@AMTB1,@AMTB1,@AMTA1,0,'')
*/

---Part III (Input Tax)

--- 05 Purchase of Capital goods from register dealers
 Select @AMTA1=Sum(a.Gro_Amt) from VATTBL A inner join litem_vw B on (A.BHENT = B.Entry_ty And A.Tran_cd = B.Tran_cd And A.IT_CODE = B.IT_CODE) 
 inner Join It_mast C on (B.It_code = c.It_code) 
 Where A.Bhent in ('PT','P1', 'EP')  AND (A.DATE BETWEEN @SDATE AND @EDATE) And c.VATCAP =1  and A.S_tax <> '' --AND  A.ST_TYPE='LOCAL' 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'3','A',0,@AMTA1,0,0,0,'')
 
 /*
--- 06 Purchase of other than capital goods from register dealers.
 Select @AMTA1=Sum(Gro_Amt) from (select distinct a.gro_amt,a.tran_cd from VATTBL A  
 inner join litem_vw B on (A.BHENT = B.Entry_ty And A.Tran_cd = B.Tran_cd And A.IT_CODE = B.IT_CODE) 
 inner Join It_mast C on (B.It_code = c.It_code)	
  Where a.bhent in ('PT','P1', 'EP')  AND (A.DATE BETWEEN @SDATE AND @EDATE) And  c.VATCAP =0 and A.S_tax <> '') C -- AND  A.ST_TYPE='LOCAL' )c 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'3','B',0,@AMTA1,0,0,0,'')
 
--- 07 Purchase of taxable goods from Un-register dealers.
  Select @AMTA1=Sum(Gro_Amt) from (select distinct a.gro_amt from VATTBL A  
  inner join litem_vw B on (A.BHENT = B.Entry_ty And A.Tran_cd = B.Tran_cd And A.IT_CODE = B.IT_CODE) inner Join It_mast C on (B.It_code = c.It_code)
   Where  a.bhent in ('PT','P1', 'EP')  AND (A.DATE BETWEEN @SDATE AND @EDATE) And c.VATCAP =0  and A.S_tax = '')c --   AND a.TAXAMT <> 0 AND  A.ST_TYPE='LOCAL')c
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'3','C',0,@AMTA1,0,0,0,'')
*/
--- 06 Purchase of taxable goods other than capital goods from register dealers.
 Select @AMTA1=Sum(Gro_Amt) from (select distinct a.gro_amt,a.tran_cd from VATTBL A  
 inner join litem_vw B on (A.BHENT = B.Entry_ty And A.Tran_cd = B.Tran_cd And A.IT_CODE = B.IT_CODE) 
 inner Join It_mast C on (B.It_code = c.It_code)	
  Where a.bhent in ('PT','P1', 'EP')  AND (A.DATE BETWEEN @SDATE AND @EDATE) And  c.VATCAP =0 and A.S_tax <> '' And (A.TAX_NAME LIKE '%VAT%' OR A.TAX_NAME LIKE '%C.S.T%') AND (A.FORM_NM = '' OR A.FORM_NM LIKE '%FORM C%' OR A.FORM_NM LIKE '%C FORM%') ) C -- AND  A.ST_TYPE='LOCAL' )c 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'3','B',0,@AMTA1,0,0,0,'')
 
--- 07 Purchase of taxable goods from Un-register dealers.
  Select @AMTA1=Sum(Gro_Amt) from (select distinct a.gro_amt from VATTBL A  
  inner join litem_vw B on (A.BHENT = B.Entry_ty And A.Tran_cd = B.Tran_cd And A.IT_CODE = B.IT_CODE) inner Join It_mast C on (B.It_code = c.It_code)
   Where  a.bhent in ('PT','P1', 'EP')  AND (A.DATE BETWEEN @SDATE AND @EDATE) And c.VATCAP =0  and A.S_tax = '' And (A.TAX_NAME LIKE '%VAT%' OR A.TAX_NAME LIKE '%C.S.T%') AND (A.FORM_NM = '' OR A.FORM_NM LIKE '%FORM C%' OR A.FORM_NM LIKE '%C FORM%') )c --   AND a.TAXAMT <> 0 AND  A.ST_TYPE='LOCAL')c
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'3','C',0,@AMTA1,0,0,0,'')



---Calculation of Input Tax
--Additional Tax 1% by sandeep for TKT-4341

 SELECT @AMTA1=0,@AMTB1=0,@AMTC1=0,@AMTD1=0,@AMTE1=0,@AMTF1=0,@AMTG1=0,@AMTH1=0,@AMTI1=0,@AMTJ1=0,@AMTK1=0,@AMTL1=0,@AMTM1=0,@AMTN1=0,@AMTO1=0,@AMTP1=0 
 SET @CHAR=65
 set @form_nm=''
 DECLARE  CUR_FORM221 CURSOR FOR 
 select distinct level1 from stax_mas --where ST_TYPE='LOCAL'
 OPEN CUR_FORM221
 FETCH NEXT FROM CUR_FORM221 INTO @PER
 WHILE (@@FETCH_STATUS=0)
 BEGIN
   
  if (@Per <> 0)
 
	 begin 
		  INSERT INTO #FORM201
		  (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,FORM_NM) 		  
		  SELECT 1, 
		  '4', 
		   CASE WHEN @per = 1.00 THEN 'A' WHEN (@per = 4.00) THEN 'B' WHEN (@per = 12.50) THEN 'C' ELSE 'D'  END, 
		   @Per, 
		   (Sum(VATTBL.GRO_AMT) - Sum(VATTBL.TAXAMT) - IsNull(Sum(B.ADDLVAT1), 0)),
		   Sum(VATTBL.TAXAMT),
		   0,
		   IsNull(Sum(B.ADDLVAT1), 0),		
		   it_mast.It_name, 
		   it_mast.HSNCODE 
		   FROM VATTBL 
           Inner Join IT_MAST ON IT_MAST.It_code = VATTBL.It_code
		   inner join litem_vw B on (VATTBL.BHENT = B.Entry_ty And VATTBL.Tran_cd = B.Tran_cd And VATTBL.It_code = B.It_code)
           where VATTBL.bhent in ('PT', 'P1', 'EP') And VATTBL.S_tax <> '' AND VATTBL.PER=@Per AND VATTBL.TAX_NAME LIKE '%VAT%' AND VATTBL.TAXAMT <> 0
		   AND (VATTBL.DATE BETWEEN @SDATE AND @EDATE)
		   group by IT_MAST.it_name, it_mast.HSNCODE, VATTBL.PER
	  end
  
  SET @CHAR=@CHAR+1
  FETCH NEXT FROM CUR_FORM221 INTO @PER
 END
 CLOSE CUR_FORM221
 DEALLOCATE CUR_FORM221

--Total of INPUT CREDIT for the period
/*
select @AMTA1=sum(amt1) FROM #FORM201 where partsr='4' and srno in ('A','B','C','D','E','F','G','H','I','J')
select @AMTA2=sum(amt2) FROM #FORM201 where partsr='4' and srno in ('A','B','C','D','E','F','G','H','I','J')
select @AMTB1=sum(amt3) FROM #FORM201 where partsr='4' and srno in ('A','B','C','D','E','F','G','H','I','J')
select @AMTB2=sum(amt4) FROM #FORM201 where partsr='4' and srno in ('A','B','C','D','E','F','G','H','I','J')
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
INSERT INTO #FORM201
(PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES
(1,'4','Y',0,@AMTA1,@AMTA2,@AMTB1,@AMTB2,'')
*/

-- Tax Payable on Purchase of taxable goods under section 9
/*
 SELECT @AMTA1=sum(AMT1) FROM #FORM201 WHERE Partsr = '2A' and Srno = 'Z'
 SELECT @AMTA2=sum(AMT2) FROM #FORM201 WHERE Partsr = '2A' and Srno = 'Z'
 SELECT @AMTB1=sum(AMT3) FROM #FORM201 WHERE Partsr = '2A' and Srno = 'Z'
 SELECT @AMTB2=sum(AMT4) FROM #FORM201 WHERE Partsr = '2A' and Srno = 'Z'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'4','Z',0,@AMTA1, @amta2,@AMTB1,@AMTB2,'')
 */
 SET @AMTA1=0
 SET @AMTB1=0
 
 select @AMTA2=sum(amt2) FROM #FORM201 where partsr='4' and srno in ('A','B','C','D','E','F','G','H','I','J')
 select @AMTB2=sum(amt4) FROM #FORM201 where partsr='4' and srno in ('A','B','C','D','E','F','G','H','I','J')
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
 SELECT @AMTB1 = (@AMTA2+@AMTB2)
 
 SELECT @AMTA1=(AMT2 + AMT4) FROM #FORM201 WHERE Partsr = '2A' and Srno = 'Z'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'4A','Z',0,@AMTA1, @AMTB1,0,0,'')

---Part IV (Description of Tax Credit)

 SET @AMTA1=0
 SET @AMTB1=0
 
--- 09 Tax credit brought forward from previous tax period
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','A',0,@PAMTA1,0,0,0,'')

-- 10 Tax credit as per 8
 SET @AMTA1=0
 SET @AMTA2=0
 SELECT @AMTA1=sum(AMT1) FROM #FORM201 WHERE Partsr = '4A' and SrNo = 'Z'
 SELECT @AMTA2=sum(AMT2) FROM #FORM201 WHERE Partsr = '4A' and SrNo = 'Z'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','B',0,@AMTA1+@amta2,0,0,0,'')

-- Total (09 + 10)
 SET @AMTA1=0
 SELECT @AMTA1=sum(AMT1) FROM #FORM201 WHERE Partsr = '5' and Srno in('A','B')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','C',0,@AMTA1,0,0,0,'')
 
-- Adjustment of tax on purchase as per annexure II
 SET @AMTA1=0
 SET @AMTB1=0

 SELECT @AMTA1=SUM(v.gro_amt)
 FROM  VATMAIN_VW v
 where v.entry_ty IN ('CN')  And (V.Date between @Sdate And @Edate)

 SELECT @AMTB1=SUM(v.gro_amt)
 FROM  VATMAIN_VW v
 where v.entry_ty IN ('DN')  And (V.Date between @Sdate And @Edate)
 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','D',0,(@AMTA1-@AMTB1),0,0,0,'')
 
 --11. Gross Tax Credit
 SET @AMTA1=0
 SELECT @AMTA1=sum(AMT1) FROM #FORM201 WHERE Partsr = '5' and Srno in('C','D')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','E',0,@AMTA1,0,0,0,'')
  

--12 Reduction in tax credit
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','F',0,0,0,0,0,'')
 --12. 1 Under section 11(3)(b)(i) (other than 12.2 below)
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','FA',0,0,0,0,0,'')
 --12. 2 Under section 11(3)(b)(ii) (of the goods manufactured)
 
 SET @AMTA1=0
 SET @AMTA2=0

 SELECT @AMTA1=Sum(A.TAXAMT)+IsNull(Sum(B.ADDLVAT1), 0) FROM VATTBL A 
 inner join litem_vw B on (A.BHENT = B.Entry_ty And A.Tran_cd = B.Tran_cd And A.IT_CODE = B.IT_CODE)
 WHERE A.ST_TYPE = 'OUT OF STATE' AND A.BHENT='PT' AND A.U_IMPORM IN ('Branch Transfer', 'Consignment Transfer')  AND (A.DATE BETWEEN @SDATE AND @EDATE) 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 
 IF @AMTA1 > 0
	SET @AMTA2= ((@AMTA1*4)/100)
  
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','FB',0,@AMTA2,0,0,0,'')
 
 --12. 3 Under section 11(3)(b)(ii) (of fuel used for manufacture of goods)
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','FC',0,0,0,0,0,'')
 
 --12. 4 Under section 11(5) (for use in manufacture of goods exempted from tax under sections 5(1) and 5(2))
 
 SET @AMTA1=0
 SET @AMTA2=0

 SELECT @AMTA1=Sum(A.TAXAMT)+IsNull(Sum(B.ADDLVAT1), 0) FROM VATTBL A 
 inner join litem_vw B on (A.BHENT = B.Entry_ty And A.Tran_cd = B.Tran_cd And A.ItSerial = B.itserial)
 inner join STITREF C on (A.BHENT = C.rEntry_ty And A.Tran_cd = C.itref_Tran And A.ItSerial = c.Ritserial And C.ENTRY_TY = 'ST')
 inner join STITEM S on (C.entry_ty = S.Entry_ty And C.Itserial = S.itserial And c.Tran_cd = S.Tran_cd)
 WHERE A.BHENT='PT' AND S.tax_name IN ('Exempted')  AND (A.DATE BETWEEN @SDATE AND @EDATE) 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 
 IF @AMTA1 > 0	
	--SET @AMTA2= ((@AMTA1*4)/100)
     SET @AMTA2= @AMTA1
  
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','FD',0,@AMTA2,0,0,0,'')
 
 --12. 5 Other reason
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','FE',0,0,0,0,0,'')
 
 
 -- TOTAL : [12.1 + 12.2 + 12.3 + 12.4 + 12.5]
 SET @AMTA1=0
 SET @AMTA2=0
 
 SELECT @AMTA1=sum(AMT1) FROM #FORM201 WHERE Partsr = '5' and srno in ('FA','FB','FC','FD','FE')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','G',0,@AMTA1,0,0,0,'')
 
 SELECT @AMTA2=sum(AMT1) FROM #FORM201 WHERE Partsr = '5' and srno = 'E'
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 
 --13 Net tax credit admissible (11 – 12)
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'5','H',0,(@AMTA2 - @AMTA1),0,0,0,'')


---Part V (Net Tax Payable)

 SET @AMTA1=0
 SET @AMTB1=0


/*
--14. The amount of tax payable as per 04.1
 SELECT @AMTA1=sum(AMT2) FROM #FORM201 WHERE Partsr = '2' And srno = 'Z'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
  SELECT @AMTA2=sum(AMT4) FROM #FORM201 WHERE Partsr = '2' And srno = 'Z'
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','A',0,@AMTA1+@amta2,0,0,0,'')
 
 --15. Tax payable on the purchase of taxable goods under section 9 as per 04.2
 SELECT @AMTB1=sum(AMT1) FROM #FORM201 WHERE Partsr = '4A' And srno = 'Z'
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','B',0,@AMTB1,0,0,0,'')
 
 --16. Total Tax  
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','C',0,@AMTA1+@amta2+@AMTB1,0,0,0,'')
 */
 
 --14. The amount of tax payable as per 04.1
 SELECT @AMTA1=sum(AMT1) FROM #FORM201 WHERE Partsr = '2B' And srno = 'Z'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','A',0,@AMTA1,0,0,0,'')
 
 --15. Tax payable on the purchase of taxable goods under section 9 as per 04.2
 SET @AMTB1=0
 SET @AMTB2=0
 SELECT @AMTB1=sum(AMT2) FROM #FORM201 WHERE Partsr = '2B' And srno = 'Z'
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END

 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','B',0,@AMTB1,0,0,0,'')
 
 --16. Total Tax  
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','C',0,@AMTA1+@AMTB1,0,0,0,'')
 
 
-- 17. Less... 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','D',0,0,0,0,0,'')
 
 -- 17.1 (Adjustment of tax on sale as per Annexure I)
 SET @AMTA1=0
 SELECT @AMTA1=Sum(Gro_Amt) FROM VATTBL  WHERE BHENT='SR' AND (DATE BETWEEN @SDATE AND @EDATE)
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END 

 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','DA',0,@AMTA1,0,0,0,'')
 -- 17.2 (Remission under section 41)
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','DB',0,0,0,0,0,'')
 -- 17.3 (Credit u/s 593(9) of the amount of tax deducted at source (enclose form -703)
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','DC',0,0,0,0,0,'')
 -- 17.4 (Adjustment of the amount deposited under section 22)
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','DD',0,0,0,0,0,'')
 -- 17.5 Net tax credit as per 13
 SET @AMTA1=0
 SELECT @AMTA1=AMT1 FROM #FORM201 WHERE Partsr = '5' and Srno in('H')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','DE',0,@AMTA1,0,0,0,'')
 
-- Total ... [17.1 + 17.2 + 17.3 + 17.4 + 17.5]

 SET @AMTA1=0
  SELECT @AMTA1=Sum(AMT1) FROM #FORM201 WHERE Partsr = '6' and Srno in ('DA','DB','DC','DD','DE') 
  
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','DF',0,@AMTA1,0,0,0,'')

-- 18. Net tax payable (16-17)
 SELECT @AMTA1=AMT1 FROM #FORM201 WHERE Partsr = '6' AND SRNO='C' 
 SELECT @AMTB1=AMT1 FROM #FORM201 WHERE Partsr = '6' and srno = 'DF'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','E',0,@AMTA1-@AMTB1,0,0,0,'')

--19. Excess amount of tax credit (17-16)
 SELECT @AMTB1=AMT1 FROM #FORM201 WHERE Partsr = '6' and srno = 'DF'
 SELECT @AMTA1=AMT1 FROM #FORM201 WHERE Partsr = '6' and srno = 'C'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','F',0,@AMTB1-@AMTA1,0,0,0,'')

--20. Excess amount of tax credit adjusted against CST
/*
 SELECT @AMTA1=Round(Sum(TaxAmt),0) FROM VATTBL  WHERE ST_TYPE='OUT OF STATE' AND BHENT In ('ST', 'PR', 'DN') and TAX_NAME LIKE '%C.S.T.%' AND (DATE BETWEEN @SDATE AND @EDATE)
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','E',0,@AMTA1,0,0,0,'')
*/
SELECT @AMTA1=SUM(NET_AMT) FROM (select distinct A.tran_cd,A.bhent,C.NET_AMT,dbname  FROM vattbl A 
INNER JOIN JVMAIN C ON A.TRAN_cD=C.TRAN_cD WHERE A.BHENT IN ('JV','J4') AND C.VAT_ADJ like '%CST%' 
AND (A.DATE BETWEEN @SDATE AND @EDATE))B 
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','G',0,@AMTA1,0,0,0,'')

--21. Excess amount of tax credit claimed as refund
SELECT @AMTA1=SUM(NET_AMT) FROM (select distinct A.tran_cd,A.bhent,C.NET_AMT,dbname  FROM vattbl A 
INNER JOIN JVMAIN C ON A.TRAN_cD=C.TRAN_cD WHERE A.BHENT IN ('JV','J4') AND C.VAT_ADJ='Refund Claim' 
AND (A.DATE BETWEEN @SDATE AND @EDATE))B 
SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','H',0,@AMTA1,0,0,0,'')

--22. Amount of tax credit carried forward to the next tax period
 SELECT @AMTA1=SUM(AMT1) FROM #FORM201 WHERE Partsr = '6' and srno = 'F'
 SELECT @AMTB1=SUM(AMT1) FROM #FORM201 WHERE Partsr = '6' and srno = 'G'
 SELECT @AMTC1=SUM(AMT1) FROM #FORM201 WHERE Partsr = '6' and srno = 'H'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 SET @AMTC1=CASE WHEN @AMTC1 IS NULL THEN 0 ELSE @AMTC1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'6','I',0,@AMTA1-@AMTB1-@AMTC1,0,0,0,'')



---Part VI (Payment of tax)

--23. Amount payable
  INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'7','A',0,0,0,0,0,'')
 
 -- 23.1 Amount of tax payable as per 19
 Select @AMTA1=AMT1 From #FORM201 Where Partsr = '6' and Srno = 'E'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'7','B',0,@AMTA1,0,0,0,'')
   
 --23.2 Amount of interest.
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'7','C',0,0,0,0,0,'')
  --23.3 Amount of PENALTY.
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'7','D',0,0,0,0,0,'')
 
 --Total.
 Select @AMTA1=Sum(AMT1) From #FORM201 Where Partsr = '7' And SrNo in('A','B','C','D')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'7','E',0,@AMTA1,0,0,0,'')
 
 --24. Amount paid
 Select @AMTA1=Sum(A.gro_Amt) From VATTBL a
 Inner Join BpMain B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd)
 Where Bhent= 'BP' And A.Date between @Sdate And @Edate And B.Party_nm Like '%VAT%'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'7','F',0,@AMTA1,0,0,0,'')

--25. Amount outstanding
 Select @AMTA1=Sum(AMT1) From #FORM201 Where Partsr = '7' And SrNo in('E')
 Select @AMTB1=Sum(AMT1) From #FORM201 Where Partsr = '7' And SrNo in('F')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'7','G',0,CASE WHEN @AMTA1>@AMTB1 THEN @AMTA1-@AMTB1 ELSE 0 END ,0,0,0,'')
 
 --26. Amount paid in excess
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'7','H',0,CASE WHEN @AMTB1>@AMTA1 THEN @AMTB1-@AMTA1 ELSE 0 END,0,0,0,'')

 -- Challan Detail
INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM,INV_NO,DATE) 
Select 1, '8A', 'A', 0, A.Gro_Amt,0,0,0,b.bank_nm,b.U_CHALNO,B.u_chqdt  From VATTBL a
 Inner Join BpMain B On(A.Bhent = B.Entry_Ty And A.Tran_cd = B.Tran_cd)
 Where Bhent= 'BP' And A.Date between @Sdate And @Edate And B.Party_nm Like '%VAT%'

-- If no challan paid then print blank detail. 
 SET @AMTA1=0
 Select @AMTA1=COUNT(PART) From #FORM201 Where Partsr = '8A' And SrNo in('A')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

IF @AMTA1 = 0
	INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8A','A',0,0,0,0,0,'')  


---Annexure I
--27
/*
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','A',0,0,0,0,0,'')
--27.1 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','AA',0,0,0,0,0,'')
--27.2 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','AB',0,0,0,0,0,'')
*/

---Annexure I
--27
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','A',0,0,0,0,0,'')
--27.1 
SET @AMTA1=0
SET @AMTB1=0
 SELECT @AMTA1=Sum(Gro_Amt) FROM (SELECT DISTINCT A.gro_amt  FROM  VATTBL  A 
 inner join CNMAIN v on (A.BHENT = v.ENTRY_TY AND A.TRAN_CD = v.TRAN_CD)
 inner JOIN   CNACDET C on (A.BHENT = C.ENTRY_TY AND A.TRAN_CD = C.TRAN_CD) 
 inner join ac_mast ac on (c.ac_id=ac.ac_id)
 where  a.ST_TYPE <>'' AND  BHENT IN ('CN') AND v.U_GPRICE IN('Sales Cancelled') AND (A.DATE BETWEEN @SDATE AND @EDATE))b 

 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','AA',0,0,@AMTA1,0,0,'')
 
--27.2 

SET @AMTA1=0
SET @AMTB1=0
SET @AMTA2=0
SET @AMTB2=0

SELECT @AMTA1=SUM(Gro_Amt) FROM (SELECT DISTINCT A.gro_amt,A.ST_TYPE  FROM  VATTBL  A 
 inner join CNMAIN v on (A.BHENT = v.ENTRY_TY AND A.TRAN_CD = v.TRAN_CD)
 inner JOIN   CNACDET C on (A.BHENT = C.ENTRY_TY AND A.TRAN_CD = C.TRAN_CD) 
 inner join ac_mast ac on (c.ac_id=ac.ac_id)
 where  a.ST_TYPE <>'' AND  BHENT IN ('CN') AND v.U_GPRICE IN('Alteration in consideration of sale')  AND (A.DATE BETWEEN @SDATE AND @EDATE))b 
 
SELECT @AMTA2=SUM(Gro_Amt) FROM (SELECT DISTINCT A.gro_amt,A.ST_TYPE  FROM  VATTBL  A 
 inner join DNMAIN v on (A.BHENT = v.ENTRY_TY AND A.TRAN_CD = v.TRAN_CD)
 inner JOIN  DNACDET C on (A.BHENT = C.ENTRY_TY AND A.TRAN_CD = C.TRAN_CD) 
 inner join ac_mast ac on (c.ac_id=ac.ac_id)
 where  a.ST_TYPE <>'' AND  BHENT IN ('DN') AND v.U_GPRICE IN('Alteration in consideration of sale')  AND (A.DATE BETWEEN @SDATE AND @EDATE))b 
 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END

 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END

 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','AB',0,@AMTA2,@AMTA1,0,0,'')


--27.3
 SELECT @AMTA1=Sum(Gro_Amt) FROM VATTBL  WHERE BHENT='SR' AND (DATE BETWEEN @SDATE AND @EDATE)
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','AC',0,0,@AMTA1,0,0,'')
--28
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','B',0,0,0,0,0,'')
 
--Total 
 SELECT @AMTA1=SUM(AMT2) FROM #FORM201 WHERE Partsr = '8' and srno in ('A','AA','AB','AC','B')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','C',0,0,@AMTA1,0,0,'')
 
--29. Net of Sale 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','D',0,0,0,0,0,'')
--Adjustment in tax on Sale 
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'8','E',0,0,0,0,0,'')
 
 

 
---Annexure II
/*
SELECT @AMTA1=SUM(V.gro_amt),@AMTB1=SUM(C.amount) 
FROM  VATTBL  A 
inner join VATMAIN_VW v on (A.BHENT = v.ENTRY_TY AND A.TRAN_CD = v.TRAN_CD)
inner JOIN   CNACDET C on (A.BHENT = C.ENTRY_TY AND A.TRAN_CD = C.TRAN_CD)  
inner join ac_mast ac on (c.ac_id=ac.ac_id)
where ac.typ ='INPUT VAT'  and c.amt_ty IN('DR') AND  BHENT IN ('CN')  And (A.Date between @Sdate And @Edate)
*/

/*
SELECT @AMTA1=SUM(v.gro_amt)
FROM  DNACDET d
inner join VATMAIN_VW v on (d.entry_ty = v.ENTRY_TY AND d.TRAN_CD = v.TRAN_CD)
 inner join ac_mast ac on (d.ac_id=ac.ac_id)
where ac.typ ='OUTPUT VAT'  and D.amt_ty IN('DR') AND  D.entry_ty IN ('DN')  And (D.Date between @Sdate And @Edate)

SELECT @AMTB1=SUM(v.gro_amt)
FROM  CNACDET C
inner join VATMAIN_VW v on (c.entry_ty = v.ENTRY_TY AND C.TRAN_CD = v.TRAN_CD)
 inner join ac_mast ac on (c.ac_id=ac.ac_id)
where ac.typ ='INPUT VAT'  and c.amt_ty IN('DR') AND  c.entry_ty IN ('CN')  And (c.Date between @Sdate And @Edate)
*/

-- 30 on account of credit/debit note
SET @AMTA1=0
SET @AMTB1=0

SELECT @AMTA1=SUM(v.gro_amt)
FROM  VATMAIN_VW v
where v.entry_ty IN ('CN')  And (V.Date between @Sdate And @Edate)

SELECT @AMTB1=SUM(v.gro_amt)
FROM  VATMAIN_VW v
where v.entry_ty IN ('DN')  And (V.Date between @Sdate And @Edate)


 --SELECT @AMTA1=Round(Sum(Net_Amt),0) FROM #FORM201_1  WHERE BHENT='PR' AND (DATE BETWEEN @SDATE AND @EDATE)
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
  SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'9','A',0,@AMTA1,@AMTB1,0,0,'')
 
 -- 31
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'9','B',0,0,0,0,0,'')

 SELECT @AMTA1=SUM(AMT1),@AMTB1=SUM(AMT2) FROM #FORM201 WHERE Partsr = '9' and srno = 'A'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 -- Total
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'9','C',0,@AMTA1,@AMTB1,0,0,'')

 -- 32. Net of Purchase
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'9','D',0,0,0,0,0,'')
  -- Adjustment in tax on purchase
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'9','E',0,0,0,0,0,'')

---Annexure III
--33
 SET @AMTA1=0
  SELECT @AMTA1=Sum(Gro_Amt) FROM (SELECT DISTINCT A.Gro_AMT  FROM VATTBL A  
  WHERE BHENT in ('ST') AND A.ST_TYPE in ('OUT OF COUNTRY') and A.u_imporm in ('High Sea Sales','High Seas Sales') 
  AND (a.DATE BETWEEN @SDATE AND @EDATE) )b 
  
  SET @AMTA2=0
  SELECT @AMTA2=Sum(Gro_Amt) FROM (SELECT DISTINCT A.Gro_AMT  FROM VATTBL A  
  WHERE BHENT in ('PT') AND A.ST_TYPE in ('OUT OF COUNTRY') and A.u_imporm in ('High Sea Purchases','High Seas Purchases') 
  AND (a.DATE BETWEEN @SDATE AND @EDATE) )b 
  
  Set @AMTA1 = IsNull(@AMTA1,0)   
  Set @AMTA2 = IsNull(@AMTA2,0)
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'10','A',0,@AMTA1,@AMTA2,0,0,'')
 
 --34
   SELECT @AMTA1=Sum(GRO_Amt) FROM (SELECT  A.GRO_AMT  FROM  VATTBL A 
   --inner join #lcode lc on (a.Bhent = lc.Entry_ty) 
  inner join Stmain m on (a.tran_cd=m.tran_Cd) 
  inner join AC_MAST ac on (ac.Ac_id=m.Ac_id)
  WHERE (A.Date between @Sdate And @Edate) And AC.ST_TYPE = 'OUT OF COUNTRY' AND A.BHENT in ('ST') AND A.U_IMPORM not in ('High Sea Sales','High Seas Sales') And A.RFORM_NM in (''))C
  --WHERE (A.Date between @Sdate And @Edate) And AC.ST_TYPE = 'OUT OF COUNTRY' AND A.BHENT in ('ST','EI', 'DN', 'PR'))C

   SELECT @AMTA2=Sum(Gro_Amt) FROM (SELECT A.Gro_AMT  FROM  VATTBL A 
   --inner join #lcode lc on (a.Bhent = lc.Entry_ty) 
  inner join Ptmain m on (a.tran_cd=m.tran_Cd) 
  inner join AC_MAST ac on (ac.Ac_id=m.Ac_id)
  WHERE  (A.Date between @Sdate And @Edate)  And  AC.ST_TYPE = 'OUT OF COUNTRY' AND A.BHENT  in('PT', 'P1', 'EP') AND A.U_IMPORM not in ('High Sea Purchases','High Seas Purchases') And A.FORM_NM in (''))C
  --WHERE  (A.Date between @Sdate And @Edate)  And  AC.ST_TYPE = 'OUT OF COUNTRY' AND A.BHENT  in('PT','P1','EP', 'CN', 'SR'))C
  
  -- ADDED BY PANKAJ ON 13.03.2014 END
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'10','B',0,@AMTA1,@AMTA2,0,0,'')
  
--35
  SET @AMTA1=0
  SELECT @AMTA1=Sum(Gro_Amt) FROM (SELECT DISTINCT A.Gro_AMT  FROM VATTBL A  
  WHERE BHENT in ('ST') AND A.ST_TYPE in ('OUT OF COUNTRY') and a.rform_nm in ('FORM H','H FORM') 
  AND (a.DATE BETWEEN @SDATE AND @EDATE) )b 
    
  SET @AMTA2=0
  SELECT @AMTA2=Sum(Gro_Amt) FROM (SELECT DISTINCT A.Gro_AMT  FROM VATTBL A  
  WHERE BHENT in ('PT') AND A.ST_TYPE in ('OUT OF COUNTRY') and a.FORM_NM in ('FORM H','H FORM') 
  AND (a.DATE BETWEEN @SDATE AND @EDATE) )b 
    
  SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
  SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END  
  INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'10','C',0,@AMTA1,@AMTA2,0,0,'')
 
 -- ADDED BY PANKAJ ON 13.03.2014 START
  --36
  SELECT  @AMTA1=SUM(M.NET_AMT) FROM Stmain m 
  inner join AC_MAST ac on (ac.Ac_id=m.Ac_id)
  WHERE AC.ST_TYPE = 'OUT OF STATE' AND M.u_imporm NOT IN ('Branch Transfer','Consignment Transfer') and  (M.[Date] between @sdate and @edate)

  SELECT  @AMTA2=SUM(M.NET_AMT) FROM Ptmain m 
  inner join AC_MAST ac on (ac.Ac_id=m.Ac_id)
  WHERE AC.ST_TYPE = 'OUT OF STATE' AND M.u_imporm NOT IN ('Branch Transfer','Consignment Transfer') and  (M.[Date] between @sdate and @edate)

 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'10','D',0,@AMTA1,@AMTA2,0,0,'')

--37
 SELECT @AMTA1=SUM(AMT1) FROM #FORM201 WHERE PartSr = '10'
 SELECT @AMTA2=SUM(AMT2) FROM #FORM201 WHERE PartSr = '10'
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'10','E',0,@AMTA1,@AMTA2,0,0,'')
 
 
update #FORM201 set amt1=@amta1,amt2=@amta2 where partsr='1' and srno='DG'-- (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','DG',0,@AMTA1,@AMTA2,0,0,'')-- For Part I Reduction
 
 SELECT @AMTA1=sum(AMT1),@AMTA2=sum(AMT2) FROM #FORM201 WHERE Partsr = '1' and srno in('DA','DB','DD','DE','DF','DG','DH')
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 update #FORM201 set amt1=@amta1,amt2=@amta2 where partsr='1' and srno='E'
 
 --INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','E',0,@AMTA1,@AMTA2,0,0,'')
  --SELECT @AMTA1=sum(AMT1),@AMTA2=sum(AMT2) FROM #FORM201 WHERE Partsr = '1' and srno in('C')
  SELECT @AMTA1=sum(AMT1),@AMTA2=sum(AMT2) FROM #FORM201 WHERE Partsr = '1' and srno in('A')
 SELECT @AMTB1=sum(AMT1),@AMTB2=sum(AMT2) FROM #FORM201 WHERE Partsr = '1' and srno in('E')
 
 SET @AMTA1=CASE WHEN @AMTA1 IS NULL THEN 0 ELSE @AMTA1 END
 SET @AMTA2=CASE WHEN @AMTA2 IS NULL THEN 0 ELSE @AMTA2 END
 SET @AMTB1=CASE WHEN @AMTB1 IS NULL THEN 0 ELSE @AMTB1 END
 SET @AMTB2=CASE WHEN @AMTB2 IS NULL THEN 0 ELSE @AMTB2 END
 update #FORM201 set amt1=@AMTA1-@AMTB1,amt2=@AMTA2-@AMTB2 where partsr='1' and srno='F'--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'1','F',0,@AMTA1-@AMTB1,@AMTA2-@AMTB2,0,0,'')
---Annexure III


--INSERT INTO #FORM201 (PART,PARTSR,SRNO,RATE,AMT1,AMT2,AMT3,AMT4,PARTY_NM) VALUES  (1,'10','F',0,0,0,0,0,'')

Update #FORM201 set  PART = isnull(Part,0) , Partsr = isnull(PARTSR,''), SRNO = isnull(SRNO,''),
		             RATE = isnull(RATE,0), AMT1 = isnull(AMT1,0), AMT2 = isnull(AMT2,0), 
					 AMT3 = isnull(AMT3,0),AMT4 = isnull(AMT4,0), INV_NO = isnull(INV_NO,''), DATE = isnull(Date,''), 
					 PARTY_NM = isnull(Party_nm,''), ADDRESS = isnull(Address,''),
					 FORM_NM = isnull(form_nm,''), S_TAX = isnull(S_tax,'')--, Qty = isnull(Qty,0),  ITEM =isnull(item,''),

 --select substring(partsr,1,2), isnumeric(substring(partsr,1,2)), cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int) from #FORM201
 SELECT * FROM #FORM201 order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int), SRNO
 --SELECT * FROM #FORM201_1 --order by cast(substring(partsr,1,case when (isnumeric(substring(partsr,1,2))=1) then 2 else 1 end) as int)
 
 END
--Print 'GJ VAT FORM 201'