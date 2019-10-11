DROP PROCEDURE [USP_REP_STK_AGEINGWISE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rupesh Prajapati.
-- Create date: 04/05/2009
-- Description:	This Stored procedure is useful to generate Ageging INVENTORY STOCK List Report.
-- Modify date: 
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
CREATE PROCEDURE [USP_REP_STK_AGEINGWISE]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60) --= null
AS

DECLARE @VALMETHOD AS VARCHAR(20)
DECLARE @FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)

SET @VALMETHOD=CASE WHEN (@EXPARA LIKE '%FIFO%') THEN 'FIFO' ELSE (CASE WHEN (@EXPARA LIKE '%LIFO%') THEN 'LIFO' ELSE 'AVG'  END) END


EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL
,@VEDATE=NULL--@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE='I',@VACFILE=' '
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=null
,@VFCON =@FCON OUTPUT

set @VALMETHOD='FIFO'

declare @days1 int,@days2 int,@days3 int,@days4 int
DECLARE @COLCAP1 AS VARCHAR(50),@COLCAP2 AS VARCHAR(50),@COLCAP3 AS VARCHAR(50),@COLCAP4 AS VARCHAR(50),@COLCAP5 AS VARCHAR(50)

SET @DAYS1=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS1
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
--print @EXPARA
SET @DAYS2=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS2
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
--print @EXPARA
SET @DAYS3=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS3
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
--print @EXPARA
SET @DAYS4=@EXPARA
--print @DAYS4



----->Generate #l Table from LCODE with Behaviour
SELECT DISTINCT ENTRY_TY,(CASE WHEN EXT_VOU=1 THEN BCODE_NM ELSE ENTRY_TY END) AS BHENT,PMKEY=INV_STK  INTO #L FROM LCODE WHERE (V_ITEM<>0 ) AND INV_STK<>' '  ORDER BY BHENT
---<--Generate #l Table from LCODE with Behaviour

----->Create Temporary Table to Calculate rate with Taxes & Charges [#STKVAL1]
SELECT M.DATE,TRAN_CD=0,M.INV_NO,M.ENTRY_TY,I.PMKEY,I.IT_CODE,I.QTY,IT.IT_NAME,IT.RATEPER,I.WARE_NM
,BHENT=SPACE(2),I.ITSERIAL,PMKEY1=3,DC_NO
INTO #STKVAL1
FROM STITEM I INNER JOIN 
STMAIN M ON(M.tran_cd=I.tran_cd) 
INNER JOIN IT_MAST IT ON(I.IT_CODE=IT.IT_CODE)
WHERE 1=2
---<--Create Temporary Table to Calculate rate with Taxes & Charges [#STKVAL1]
----->Insert Records into #STKVAL1 from all Item Tables
DECLARE @ENTRY_TY AS VARCHAR(2),@TRAN_CD INT,@BHENT AS VARCHAR(2),@ITSERIAL VARCHAR(10),@DATE SMALLDATETIME,@QTY NUMERIC(15,3),@AQTY NUMERIC(15,3),@AQTY1 NUMERIC(15,3),@IBALQTY1 NUMERIC(15,3),@QTY1 NUMERIC(15,3),@PMKEY VARCHAR(1)
DECLARE @ENTRY_TY1 AS VARCHAR(2),@TRAN_CD1 INT,@ITSERIAL1 VARCHAR(10),@WARE_NM1 VARCHAR(100),@DATE1 SMALLDATETIME,@IT_CODE1 INT
DECLARE @RATE NUMERIC(12,2),@RATE1 NUMERIC(12,2),@FRATE NUMERIC(12,2),@LRATE NUMERIC(12,2),@IT_CODE INT,@MIT_CODE INT,@IT_NAME VARCHAR(100),@WARE_NM VARCHAR(100),@MWARE_NM VARCHAR(100)

DECLARE @SQLCOMMAND AS NVARCHAR(4000)
print @FCON

DECLARE  C1STKVAL CURSOR FOR 
SELECT  DISTINCT BHENT,PMKEY FROM #L
ORDER BY BHENT
OPEN C1STKVAL
FETCH NEXT FROM C1STKVAL INTO @BHENT,@PMKEY
WHILE @@FETCH_STATUS=0
BEGIN
	SET @SQLCOMMAND=' '
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INSERT INTO #STKVAL1 ('
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'DATE,TRAN_CD,INV_NO,ENTRY_TY,PMKEY,IT_CODE,QTY,IT_NAME,RATEPER,WARE_NM'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',BHENT,I.ITSERIAL,PMKEY1,DC_NO'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+')'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT M.DATE,M.TRAN_CD,M.INV_NO,M.ENTRY_TY,I.PMKEY,I.IT_CODE,I.QTY,IT_MAST.IT_NAME,IT_MAST.RATEPER,I.WARE_NM'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',L.BHENT,I.ITSERIAL,PMKEY1=(CASE WHEN I.PMKEY='+CHAR(39)+'+'+CHAR(39)+' THEN 1 ELSE 0 END)'--,RTRAN_CD=(CASE WHEN ITR.TRAN_CD IS NULL THEN 0 ELSE ITR.TRAN_CD END) ,RENTRY_TY=ITR.ENTRY_TY,RBHENT=SPACE(2),RQTY=ITR.RQTY,RITSERIAL=ITR.ITSERIAL'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DC_NO FROM '+@BHENT+'ITEM I INNER JOIN '
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+@BHENT+'MAIN M ON(M.tran_cd=I.tran_cd) '	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN IT_MAST  ON(I.IT_CODE=IT_MAST.IT_CODE)'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND IT_MAST.IN_STKVAL=1'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN #L L ON (M.ENTRY_TY=L.ENTRY_TY)'

	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND I.PMKEY<>'+''' '''
	IF @PMKEY='-'
	BEGIN
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND M.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)
	END
	PRINT @SQLCOMMAND
	EXEC SP_EXECUTESQL  @SQLCOMMAND
		
	FETCH NEXT FROM C1STKVAL INTO @BHENT,@PMKEY
END
CLOSE C1STKVAL
DEALLOCATE C1STKVAL

SELECT * INTO #RECEIPT FROM #STKVAL1 WHERE PMKEY1=1 --+

DELETE FROM #STKVAL1 WHERE DATE>@SDATE
DELETE FROM #STKVAL1 WHERE ((PMKEY1=0 AND LEN(RTRIM(DC_NO))>0))
---<--Insert Records into #STKVAL1 from all Item Tables

SET @MIT_CODE=-1
SET @MWARE_NM=' '
SELECT * INTO #TRECEIPT FROM #RECEIPT
--->Delete Allocated entry i.e. PT
DELETE FROM #STKVAL1 WHERE LEN(DC_NO)>0  
---<-Delete Allocated entry i.e. PT
DECLARE @CNT NUMERIC(18)
SET @CNT=0

IF (@VALMETHOD='FIFO' or @VALMETHOD='LIFO')
BEGIN 
	--->In Receipt Entry qty direct enter into #STKVALFL .In Issue entry will be allocated to prev receipt entry. If Issue is allocated againts multiple receipt than it has multiple entries with same qty and different allocated qty (aqty) field.
	DECLARE @FETCH_STATUS BIT
	SELECT ENTRY_TY,TRAN_CD,ITSERIAL,WARE_NM,DATE,IT_CODE,QTY,AQTY=QTY,PMKEY,CNT=0,IT_NAME,AENTRY_TY=ENTRY_TY,ATRAN_CD=TRAN_CD,AITSERIAL=ITSERIAL,AWARE_NM=WARE_NM,ADATE=DATE INTO #STKVALFL FROM #STKVAL1 WHERE 1=2

	DECLARE STKVALCRSOR1 CURSOR FOR 
	SELECT ENTRY_TY,TRAN_CD,ITSERIAL,WARE_NM,DATE,IT_CODE,QTY,PMKEY,IT_NAME FROM  #STKVAL1 ORDER BY IT_CODE,WARE_NM,DATE,(CASE WHEN ENTRY_TY='OS' THEN 'A' ELSE (CASE WHEN PMKEY='+' THEN 'B' ELSE 'C'END) END),TRAN_CD,ITSERIAL
	OPEN STKVALCRSOR1
	FETCH NEXT FROM STKVALCRSOR1 INTO @ENTRY_TY,@TRAN_CD,@ITSERIAL,@WARE_NM,@DATE,@IT_CODE,@QTY,@PMKEY,@IT_NAME
	--                                        	
	WHILE (@@FETCH_STATUS=0)
	BEGIN
		
		SET @CNT=@CNT+1	
		IF (@PMKEY='+')
		BEGIN
			
			INSERT INTO #STKVALFL
				(ENTRY_TY,TRAN_CD,ITSERIAL,WARE_NM,DATE,IT_CODE,QTY,AQTY,PMKEY,CNT,IT_NAME,AENTRY_TY,ATRAN_CD,AITSERIAL,AWARE_NM,ADATE)
			VALUES (@ENTRY_TY,@TRAN_CD,@ITSERIAL,@WARE_NM,@DATE,@IT_CODE,@QTY,0,@PMKEY,@CNT,@IT_NAME,' ',0,' ',' ',@SDATE)
		END			
		IF (@PMKEY='-')
		BEGIN
			SET @IBALQTY1=@QTY
			IF  @VALMETHOD='FIFO'
			BEGIN
				DECLARE STKVALCRSOR2 CURSOR FOR 
				SELECT ENTRY_TY,TRAN_CD,ITSERIAL,WARE_NM,DATE,IT_CODE,QTY,AQTY FROM #STKVALFL WHERE (WARE_NM=@WARE_NM AND IT_CODE=@IT_CODE) AND (PMKEY='+') AND ((QTY-AQTY)>0) ORDER BY IT_CODE ,WARE_NM,DATE,TRAN_CD,ITSERIAL
			END
			ELSE
			BEGIN
				DECLARE STKVALCRSOR2 CURSOR FOR 
				SELECT ENTRY_TY,TRAN_CD,ITSERIAL,WARE_NM,DATE,IT_CODE,QTY,AQTY FROM #STKVALFL WHERE (WARE_NM=@WARE_NM AND IT_CODE=@IT_CODE) AND (PMKEY='+') AND ((QTY-AQTY)>0) ORDER BY DATE desc,TRAN_CD desc ,ITSERIAL DESC --IT_CODE,WARE_NM,
			END
			OPEN STKVALCRSOR2                                                          
			FETCH NEXT FROM STKVALCRSOR2 INTO @ENTRY_TY1,@TRAN_CD1,@ITSERIAL1,@WARE_NM1,@DATE1,@IT_CODE1,@QTY1,@AQTY1
			IF (@@FETCH_STATUS=0)
			BEGIN
				SET @FETCH_STATUS=0
			END
			WHILE (@FETCH_STATUS=0)
			BEGIN
				SET @CNT=@CNT+1
				
				 IF ((@QTY1-@AQTY1-@IBALQTY1)>0)
				 BEGIN
					SET @AQTY=@IBALQTY1
					SET @IBALQTY1=0
					UPDATE #STKVALFL SET AQTY=AQTY+@AQTY WHERE (ENTRY_TY=@ENTRY_TY1 AND TRAN_CD=@TRAN_CD1 AND ITSERIAL=@ITSERIAL1 AND IT_CODE=@IT_CODE)
				 END
				 ELSE
				 BEGIN
					SET @IBALQTY1=@IBALQTY1-(@QTY1-@AQTY1)
					SET @AQTY=(@QTY1-@AQTY1)
					
					UPDATE #STKVALFL SET AQTY=QTY WHERE (ENTRY_TY=@ENTRY_TY1 AND TRAN_CD=@TRAN_CD1 AND ITSERIAL=@ITSERIAL1 AND IT_CODE=@IT_CODE)
				 END
				FETCH NEXT FROM STKVALCRSOR2 INTO @ENTRY_TY1,@TRAN_CD1,@ITSERIAL1,@WARE_NM1,@DATE1,@IT_CODE1,@QTY1,@AQTY1
				IF (@IBALQTY1=0 OR @@FETCH_STATUS<>0)
				BEGIN
					SET @FETCH_STATUS=-1	
				END
			END	
			CLOSE STKVALCRSOR2
			DEALLOCATE STKVALCRSOR2
			IF @IBALQTY1>0
			BEGIN
				SET @AQTY=@qty-@IBALQTY1
				 INSERT INTO #STKVALFL
					    (ENTRY_TY,TRAN_CD,ITSERIAL,WARE_NM,DATE,IT_CODE,QTY,AQTY,PMKEY,CNT,IT_NAME,AENTRY_TY,ATRAN_CD,AITSERIAL,AWARE_NM,ADATE)
				 VALUES (@ENTRY_TY,@TRAN_CD,@ITSERIAL,@WARE_NM,@DATE,@IT_CODE,@QTY,@AQTY,@PMKEY,@CNT,@IT_NAME,' ',0,' ',' ',@SDATE)				
			END
		END
		FETCH NEXT FROM STKVALCRSOR1 INTO @ENTRY_TY,@TRAN_CD,@ITSERIAL,@WARE_NM,@DATE,@IT_CODE,@QTY,@PMKEY,@IT_NAME				
	END
	CLOSE STKVALCRSOR1
	DEALLOCATE STKVALCRSOR1
	
END

delete from #STKVALFL where (qty-aqty)=0

select entry_ty,tran_cd,date,itserial,it_code,it_name,clbal=qty-aqty,ware_nm,pmkey,PDAYS=DATEDIFF(day,DATE, @SDATE ) into #STKVAL FROM #STKVALFL 

---Assigning Column Caption--Start
IF LTRIM(RTRIM(@DAYS1))<>'0' AND LTRIM(RTRIM(@DAYS2))<>'0' AND LTRIM(RTRIM(@DAYS3))<>'0' AND LTRIM(RTRIM(@DAYS4))<>'0'
BEGIN
	SET @COLCAP1='<='+LTRIM(RTRIM(@DAYS1))+' '+'DAYS'
	SET @COLCAP2='>'+LTRIM(RTRIM(@DAYS1))+' AND '+'<='+LTRIM(RTRIM(@DAYS2))+' '+'DAYS'
	SET @COLCAP3='>'+LTRIM(RTRIM(@DAYS2))+' AND '+'<='+LTRIM(RTRIM(@DAYS3))+' '+'DAYS'
	SET @COLCAP4='>'+LTRIM(RTRIM(@DAYS3))+' AND '+'<='+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP5='>'+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
END
IF LTRIM(RTRIM(@DAYS1))='0' AND LTRIM(RTRIM(@DAYS2))<>'0' AND LTRIM(RTRIM(@DAYS3))<>'0' AND LTRIM(RTRIM(@DAYS4))<>'0'
BEGIN
	SET @COLCAP1='<='+LTRIM(RTRIM(@DAYS2))+' '+'DAYS'
	SET @COLCAP2='>'+LTRIM(RTRIM(@DAYS2))+' AND '+'<='+LTRIM(RTRIM(@DAYS3))+' '+'DAYS'
	SET @COLCAP3='>'+LTRIM(RTRIM(@DAYS3))+' AND '+'<='+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP4='>'+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP5=' '
END
IF LTRIM(RTRIM(@DAYS1))='0' AND LTRIM(RTRIM(@DAYS2))='0' AND LTRIM(RTRIM(@DAYS3))<>'0' AND LTRIM(RTRIM(@DAYS4))<>'0'
BEGIN
	SET @COLCAP1='<='+LTRIM(RTRIM(@DAYS3))+' '+'DAYS'
	SET @COLCAP2='>'+LTRIM(RTRIM(@DAYS3))+' AND '+'<='+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP3='>'+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP4=' '
	SET @COLCAP5=' '
END
IF LTRIM(RTRIM(@DAYS1))='0' AND LTRIM(RTRIM(@DAYS2))='0' AND LTRIM(RTRIM(@DAYS3))='0' AND LTRIM(RTRIM(@DAYS4))<>'0'
BEGIN
	SET @COLCAP1='<='+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP2='>'+LTRIM(RTRIM(@DAYS4))+' '+'DAYS'
	SET @COLCAP3=' '
	SET @COLCAP4=' '
	SET @COLCAP5=' '
END

SELECT it_code,it_name
,DAYS1=@COLCAP1
,DAYS2=@COLCAP2
,DAYS3=@COLCAP3
,DAYS4=@COLCAP4
,DAYS5=@COLCAP5
,cldays1=sum(case when pdays<=@days1 then clbal else 0 end)
,cldays2=sum(case when pdays>@days1 and pdays<=@days2 then clbal else 0 end)
,cldays3=sum(case when pdays>@days2 and pdays<=@days3 then clbal else 0 end)
,cldays4=sum(case when pdays>@days3 and pdays<=@days4 then clbal else 0 end)
,cldays5=sum(case when pdays>@days4 then clbal else 0 end)
FROM #STKVAL
group by it_code,it_name

drop table #L
drop table #STKVAL1
drop table #RECEIPT
drop table #TRECEIPT
drop table #STKVALFL
drop table #STKVAL
GO
