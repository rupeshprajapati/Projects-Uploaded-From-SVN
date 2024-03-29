IF EXISTS (SELECT [NAME] FROM SYS.procedures WHERE [NAME]='USP_REP_OUTSTANDINGDR_AGEING')
BEGIN
	DROP PROCEDURE [USP_REP_OUTSTANDINGDR_AGEING]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Modified By: Sandeep Shah
-- Modify date: 24/06/2011
-- Description:	This Stored procedure is useful to generate ACCOUNTS  Outstanding Report for sundry debtors
--              TKT-8356 Added 5th parameter Days5 in Ageing form 
-- Remark	  : This Store procedure generated by used reference of USP_REP_OUTSTANDINGDR_BANK Store Procedure.
-- Modified By and Date : Satish Pal 03/10/2011  FOR TKT-8554
-- Modified By and Date : Satish Pal 31/10/2011  FOR TKT-9489
-- Modified By and Date : Shrikant S. on 31/08/2012 for Bug-5749 
-- Modified	: Shrikant S. on 21/04/2017 for GST	--Changed the columns U_PINVNO,U_PINVDT to PINVNO,PINVDT resp.
-- Modified	: Sachin N. S. on 25/07/2019 for Bug-31883
-- =============================================

CREATE  PROCEDURE [USP_REP_OUTSTANDINGDR_AGEING]  
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
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)
Declare @OPENTRIES as VARCHAR(50),@OPENTRY_TY as VARCHAR(50)
Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50),@TBLNAME2 as VARCHAR(50),@TBLNAME3 as VARCHAR(50),@TBLNAME11 as VARCHAR(50),@TBLNAME12 as VARCHAR(50)
DECLARE @GRPID AS INT,@MCOND AS BIT,@LVL  AS INT,@GRP AS VARCHAR(100)
DECLARE @COLCAP1 AS VARCHAR(50),@COLCAP2 AS VARCHAR(50),@COLCAP3 AS VARCHAR(50),@COLCAP4 AS VARCHAR(50),@COLCAP5 AS VARCHAR(50)

DECLARE @DAYS1 AS varchar (4),@DAYS2 AS varchar (4),@DAYS3 AS varchar (4),@DAYS4 AS varchar (4),@DAYS5 AS varchar (4),@FILTERDATE AS varchar (10),@JV_ALLOC AS varchar (1)
select @EXPARA =case when  isnull(@expara,'')='' then '  30,  60,  90, 120' else @expara end
--print @expara
SET @DAYS1=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS1
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
SET @DAYS2=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS2
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
SET @DAYS3=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS3
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
-- Added by Sandeep dt.24/06/2011 for TKT-8356--->Start
SET @DAYS4=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS4
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
---SET @DAYS5=@expara
----aDDED BY SATISH DT.03/10/2011 FOR TKT-8554
SET @DAYS5=substring(@expara,1,charindex(',',@expara)-1)
--print @DAYS5
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
print @EXPARA
SET @FILTERDATE=substring(@expara,1,charindex(',',@expara)-1)

--Commented By Shrikant S. on 31/08/2012 for Bug-5749		--Start
--IF @FILTERDATE='due_dt'	
--BEGIN
--SET @SDATE=DATEADD(day,-1,@SDATE)
--END
--Commented By Shrikant S. on 31/08/2012 for Bug-5749		--End

set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
SET @JV_ALLOC=@expara
---END

if ltrim(rtrim(@Days5))<>'0'
begin
	set @DAYS1='0'
	set @DAYS2='0'
	set @DAYS3='0'
	set @DAYS4=@DAYS5
end
-- Added by Sandeep dt.24/06/2011 for TKT-8356--->End

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=NULL,@VEDATE=@SDATE   ---Change by satish pal dt.03/10/2011 for TKT 8554
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=NULL,@VEAMT=NULL
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='MN',@VITFILE=Null,@VACFILE='AC'
--,@VDTFLD ='DUE_DT'
,@VDTFLD =@FILTERDATE			---Change by satish pal dt.03/10/2011 for TKT 8554	
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

set QUOTED_IDENTIFIER Off
Set @OPENTRY_TY = CHAR(39)+'OB'+CHAR(39)
Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
				+ (DATEPART(ss, GETDATE()) * 1000 )
				+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
Set @TBLNAME1 = '##TMP1'+@TBLNM
Set @TBLNAME2 = '##TMP2'+@TBLNM
Set @TBLNAME3 = '##TMP3'+@TBLNM
Set @TBLNAME12 = '##TMP12'+@TBLNM

DECLARE @TBLMALL VARCHAR(20)			-- Added by Sachin N. S. on 25/07/2019 for Bug-31883
Set @TBLMALL = '##TMPMALL'+@TBLNM		-- Added by Sachin N. S. on 25/07/2019 for Bug-31883

SET @GRP='SUNDRY DEBTORS'
DECLARE openingentry_cursor CURSOR FOR
	SELECT entry_ty FROM lcode
	WHERE bcode_nm = 'OB'
	OPEN openingentry_cursor
	FETCH NEXT FROM openingentry_cursor into @opentries
	WHILE @@FETCH_STATUS = 0
	BEGIN
	   Set @OPENTRY_TY = @OPENTRY_TY +','+CHAR(39)+@opentries+CHAR(39)
	   FETCH NEXT FROM openingentry_cursor into @opentries
	END
	CLOSE openingentry_cursor
	DEALLOCATE openingentry_cursor

--CREATE TABLE #ACGRPID (GACID DECIMAL(9),LVL DECIMAL(9))
CREATE TABLE #ACGRPID (GACID DECIMAL(9),PARID INT, LVL DECIMAL(9))		-- Changed by Sachin N. S. on 25/07/2019 for Bug-31883
SET @LVL=0
--***** Changed by Sachin N. S. on 25/07/2019 for Bug-31883 -- Start
--INSERT INTO #ACGRPID SELECT AC_GROUP_ID,@LVL  FROM AC_GROUP_MAST WHERE AC_GROUP_NAME=@GRP
--SET @MCOND=1
--WHILE @MCOND=1
--BEGIN
--	IF EXISTS (SELECT AC_GROUP_ID FROM AC_GROUP_MAST WHERE GAC_ID IN (SELECT DISTINCT GACID  FROM #ACGRPID WHERE LVL=@LVL)) --WHERE LVL=@LVL
--	BEGIN
		
--		INSERT INTO #ACGRPID SELECT AC_GROUP_ID,@LVL+1 FROM AC_GROUP_MAST WHERE GAC_ID IN (SELECT DISTINCT GACID  FROM #ACGRPID WHERE LVL=@LVL)
--		SET @LVL=@LVL+1
--	END
--	ELSE
--	BEGIN
--		SET @MCOND=0	
--	END
--END

;WITH ACGRP_CTE AS
(
	SELECT AC_GROUP_ID as gac_id, gac_id as ParId, @LVL AS LVL
		from AC_GROUP_MAST A 
			WHERE ac_group_name=@GRP
	UNION ALL
	SELECT A.AC_GROUP_ID as gac_id, A.gac_id as ParId, LVL=B.LVL+1 
		from AC_GROUP_MAST A
			INNER JOIN ACGRP_CTE B ON A.GAC_ID = B.GAC_ID
)
INSERT INTO #ACGRPID 
	SELECT * FROM ACGRP_CTE
--***** Changed by Sachin N. S. on 25/07/2019 for Bug-31883 -- End



SELECT AC_ID,AC_NAME INTO #ACMAST FROM AC_MAST WHERE  AC_GROUP_ID IN (SELECT DISTINCT GACID FROM #ACGRPID)

--Added by Shrikant S. on 31/08/2012 for Bug-5749	--Start
IF @FILTERDATE='DUE_DT'
Begin
	Declare @QueryStr Varchar(1000)
	set @QueryStr='Case when MN.DATE=MN.DUE_DT THEN '+CHAR(39)+CONVERT(VARCHAR(50),@SDATE)+CHAR(39)+' ELSE '+CHAR(39)+CONVERT(VARCHAR(50),DATEADD(DAY,-1,@SDATE))+CHAR(39)+' END '
	set @FCON=replace(@FCON,char(39)+convert(varchar(50),@sdate)+char(39),@QueryStr)
End
--Added by Shrikant S. on 31/08/2012 for Bug-5749	--End
--print @FCON

-- Added by Sachin N. S. on 25/07/2019 for Bug-31883 -- Start
SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT * INTO '+@TBLMALL+' from MAINALL_VW WHERE DATE <= '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)
EXECUTE SP_EXECUTESQL @SQLCOMMAND
-- Added by Sachin N. S. on 25/07/2019 for Bug-31883 -- End


SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT AC_MAST.AC_NAME,AC.AC_ID,AC.AMOUNT,AC.ACSERIAL,AC.AMT_TY,MN.ENTRY_TY,MN.DATE,MN.TRAN_CD,MN.L_YN,MN.INV_NO,MN.DUE_DT,MN.PINVNO AS U_PINVNO'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',BILLAMT=AC.AMOUNT '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',RECAMT=SUM(case when (AC.entry_ty=MLL.entry_all and AC.tran_cd =MLL.main_tran and AC.acserial =MLL.acseri_all and AC.AC_ID=MLL.AC_ID) then ISNULL(MLL.NEW_ALL,0)+ISNULL(MLL.TDS,0)+ISNULL(MLL.DISC,0) else 0 end)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INTO '+@TBLNAME1
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM LAC_VW AC '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN #ACMAST AM ON (AC.AC_ID=AM.AC_ID)'		-- Changed by Sachin N. S. on 25/07/2019 for Bug-31883
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=Am.AC_ID)'		-- Changed by Sachin N. S. on 25/07/2019 for Bug-31883
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=AC.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN LMAIN_VW MN ON (AC.ENTRY_TY=MN.ENTRY_TY AND AC.TRAN_CD=MN.TRAN_CD)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN '+@TBLMALL+' MLL ON (AC.entry_ty=MLL.entry_all and AC.tran_cd =MLL.main_tran and AC.acserial =MLL.acseri_all and AC.AC_ID=MLL.AC_ID) AND MLL.DATE <= '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)	
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN MAINALL_VW MLL ON (AC.entry_ty=MLL.entry_all and AC.tran_cd =MLL.main_tran and AC.acserial =MLL.acseri_all and AC.AC_ID=MLL.AC_ID) AND MLL.DATE <= '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)	
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN #ACMAST AM ON (AC_MAST.AC_ID=AM.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' AND MN.TDSPAYTYPE<>3' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'GROUP BY AC_MAST.AC_NAME,AC.AC_ID,AC.AMOUNT,AC.ACSERIAL,AC.AMT_TY,MN.ENTRY_TY,MN.DATE,MN.TRAN_CD,MN.L_YN,MN.INV_NO,MN.DUE_DT,MN.PINVNO'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

-- Added by Sachin N. S. on 25/07/2019 for Bug-31883 -- Start
SET @SQLCOMMAND='drop table '+@TBLMALL
EXECUTE SP_EXECUTESQL @SQLCOMMAND

SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT * INTO '+@TBLMALL+' from MAINALL_VW WHERE DATE_ALL <= '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)
EXECUTE SP_EXECUTESQL @SQLCOMMAND
-- Added by Sachin N. S. on 25/07/2019 for Bug-31883 -- End


SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT AC_MAST.AC_NAME,AC.AC_ID,AC.AMOUNT,AC.ACSERIAL,AC.AMT_TY,MN.ENTRY_TY,MN.DATE,MN.TRAN_CD,MN.L_YN,MN.INV_NO,MN.DUE_DT,MN.PINVNO AS U_PINVNO'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',BILLAMT=AC.AMOUNT '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',RECAMT=sum(case when (AC.entry_ty=MLY.entry_ty and AC.tran_cd =MLY.tran_cd and AC.acserial =MLY.acserial and AC.AC_ID=MLY.AC_ID) then case when ISNULL(MLY.NEW_ALL,0) = 0 then ISNULL(MLY.TDS,0)+ISNULL(MLY.DISC,0) else ISNULL(MLY.NEW_ALL,0) end else 0 end)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INTO '+@TBLNAME2
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM LAC_VW AC '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN #ACMAST AM ON (AC.AC_ID=AM.AC_ID)'		-- Changed by Sachin N. S. on 25/07/2019 for Bug-31883
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=AM.AC_ID)'	-- Changed by Sachin N. S. on 25/07/2019 for Bug-31883
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN AC_MAST  ON (AC_MAST.AC_ID=AC.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN LMAIN_VW MN ON (AC.ENTRY_TY=MN.ENTRY_TY AND AC.TRAN_CD=MN.TRAN_CD)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN '+@TBLMALL+' MLY ON (AC.entry_ty=MLY.entry_ty and AC.tran_cd =MLY.tran_cd and AC.acserial =MLY.acserial and AC.AC_ID=MLY.AC_ID) AND MLY.DATE_ALL <= '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)		
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN MAINALL_VW MLY ON (AC.entry_ty=MLY.entry_ty and AC.tran_cd =MLY.tran_cd and AC.acserial =MLY.acserial and AC.AC_ID=MLY.AC_ID) AND MLY.DATE_ALL <= '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)		
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN #ACMAST AM ON (AC_MAST.AC_ID=AM.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' AND MN.TDSPAYTYPE<>3' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'GROUP BY AC_MAST.AC_NAME,AC.AC_ID,AC.AMOUNT,AC.ACSERIAL,AC.AMT_TY,MN.ENTRY_TY,MN.DATE,MN.TRAN_CD,MN.L_YN,MN.INV_NO,MN.DUE_DT,MN.PINVNO'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

-- Added by Sachin N. S. on 25/07/2019 for Bug-31883 -- Start
SET @SQLCOMMAND='drop table '+@TBLMALL
EXECUTE SP_EXECUTESQL @SQLCOMMAND
-- Added by Sachin N. S. on 25/07/2019 for Bug-31883 -- End


SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT A.AC_NAME,A.AMOUNT,A.ACSERIAL,A.AMT_TY,A.ENTRY_TY,A.DATE,A.TRAN_CD,A.L_YN,A.INV_NO,A.DUE_DT,A.U_PINVNO'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',A.BILLAMT,RECAMT=A.RECAMT+ISNULL(B.RECAMT,0) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',BALAMT=A.BILLAMT-(A.RECAMT+ISNULL(B.RECAMT,0))'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INTO '+@TBLNAME12
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM '+@TBLNAME1+' A '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN '+@TBLNAME2+' B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ACSERIAL=B.ACSERIAL) AND A.AC_ID = B.AC_ID '
EXECUTE SP_EXECUTESQL @SQLCOMMAND

SET @SQLCOMMAND = 'SELECT * FROM '+@TBLNAME1
SET @SQLCOMMAND = 'DECLARE @OPTRAN_CD as INT,@OPDATE as DATETIME,@OPACNAME as varchar(250) DECLARE openingentry_cursor CURSOR FOR
	SELECT TRAN_CD,AC_NAME,DATE FROM '+@TBLNAME12+' WHERE 
	ENTRY_TY IN ('+@OPENTRY_TY+') 
	OPEN openingentry_cursor
	FETCH NEXT FROM openingentry_cursor into @OPTRAN_CD,@OPACNAME,@OPDATE
	WHILE @@FETCH_STATUS = 0
	BEGIN
	   DELETE FROM '+@TBLNAME12+' WHERE ENTRY_TY IN ('+@OPENTRY_TY+') AND TRAN_CD = @OPTRAN_CD
			AND AC_NAME IN (SELECT AC_NAME FROM '+@TBLNAME12+' WHERE AC_NAME = @OPACNAME AND DATE < @OPDATE )
	   FETCH NEXT FROM openingentry_cursor into @OPTRAN_CD,@OPACNAME,@OPDATE
	END
CLOSE openingentry_cursor
DEALLOCATE openingentry_cursor'

EXECUTE SP_EXECUTESQL @SQLCOMMAND

IF RTRIM(LTRIM(@DAYS1))<>'0' 
BEGIN
SET @SQLCOMMAND=' '
/* Changes made for Below lines for days calculation for Bug-5749. Replaced DUE_DT with @FILTERDATE */
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT *'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS1AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS1+') THEN BALAMT ELSE 0 END) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS2AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>' +@DAYS1+') AND ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS2+') THEN BALAMT ELSE 0 END )'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS3AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>' +@DAYS2+') AND ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS3+') THEN BALAMT ELSE 0 END )'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS4AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>' +@DAYS3+') AND ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS4+') THEN BALAMT ELSE 0 END )'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS5AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>'+@DAYS4+') THEN BALAMT ELSE 0 END ) into '+@TBLNAME3
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM '+@TBLNAME12+ ' WHERE BALAMT <> 0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM '+@TBLNAME12+ ' WHERE BALAMT <> 0 '+CASE WHEN @JV_ALLOC=0  THEN ' AND ENTRY_TY<>''JV''' ELSE '' END +'' 


END

IF LTRIM(RTRIM(@DAYS1))='0' AND LTRIM(RTRIM(@DAYS2))<>'0' 
BEGIN
SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT *'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS1AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS2+') THEN BALAMT ELSE 0 END) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS2AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>' +@DAYS2+') AND ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS3+') THEN BALAMT ELSE 0 END )'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS3AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>' +@DAYS3+') AND ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS4+') THEN BALAMT ELSE 0 END )'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS4AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>'+@DAYS4+') THEN BALAMT ELSE 0 END )'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS5AMT=0 into '+@TBLNAME3
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM '+@TBLNAME12+ ' WHERE BALAMT <> 0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM '+@TBLNAME12+ ' WHERE BALAMT <> 0 '+CASE WHEN @JV_ALLOC=0  THEN ' AND ENTRY_TY<>''JV''' ELSE '' END +'' -- added By  Satish Pal 31/10/2011  FOR TKT-9489

END

IF LTRIM(RTRIM(@DAYS1))='0' AND LTRIM(RTRIM(@DAYS2))='0' AND LTRIM(RTRIM(@DAYS3))<>'0'
BEGIN
SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT *'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS1AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS3+') THEN BALAMT ELSE 0 END) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS2AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>' +@DAYS3+') AND ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS4+') THEN BALAMT ELSE 0 END )'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS3AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>'+@DAYS4+') THEN BALAMT ELSE 0 END )'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS4AMT=0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS5AMT=0 into '+@TBLNAME3
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM '+@TBLNAME12+ ' WHERE BALAMT <> 0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM '+@TBLNAME12+ ' WHERE BALAMT <> 0 '+CASE WHEN @JV_ALLOC=0  THEN ' AND ENTRY_TY<>''JV''' ELSE '' END +'' -- added By  Satish Pal 31/10/2011  FOR TKT-9489
END

IF LTRIM(RTRIM(@DAYS1))='0' AND LTRIM(RTRIM(@DAYS2))='0' AND LTRIM(RTRIM(@DAYS3))='0' AND LTRIM(RTRIM(@DAYS4))<>'0'
BEGIN
SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT *'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS1AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'<='+@DAYS4+') THEN BALAMT ELSE 0 END) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS2AMT=(CASE WHEN ('+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>'+@DAYS4+') THEN BALAMT ELSE 0 END )'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS3AMT=0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS4AMT=0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DAYS5AMT=0 into '+@TBLNAME3
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM '+@TBLNAME12+ ' WHERE BALAMT <> 0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM '+@TBLNAME12+ ' WHERE BALAMT <> 0 '+CASE WHEN @JV_ALLOC=0  THEN ' AND ENTRY_TY<>''JV''' ELSE '' END +'' -- added By  Satish Pal 31/10/2011  FOR TKT-9489


END
-- Added by Sandeep dt.24/06/2011 for TKT-8356--->Start
If @FILTERDATE<>'due_dt'    -----added condition by satish  dt. 03/10/2011  for tkt--8554
begin
if @Days5=@Days4
begin
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' And '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'-'+@FILTERDATE+'>'+@DAYS4
end
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ORDER BY INV_NO' 
end 

else
Begin
if @Days5=@Days4
	begin
		SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' And '+CHAR(39)+CAST(DATEADD(day,1,@SDATE) as varchar(50))+CHAR(39)+'-'+@FILTERDATE+'>'+@DAYS4
	end
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ORDER BY INV_NO' 
End
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
-- Added by Sandeep Dt.24/06/2011 for TKT-8356<---End


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
PRINT 'COLUMN CAPTION'
PRINT @COLCAP1
PRINT @COLCAP2
PRINT @COLCAP3
PRINT @COLCAP4
PRINT @COLCAP5

---Assigning Column Caption--End

--FOR BALANCE
SELECT 
AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY
,MN.L_YN
,AC_MAST.AC_ID,AC_MAST.AC_NAME
INTO #AC_BAL1 
FROM LAC_VW AC
INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID)
INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY)
WHERE 1=2

SET @SQLCOMMAND = ''


SET @SQLCOMMAND = 'INSERT INTO #AC_BAL1
SELECT 
AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY
,MN.L_YN
,AC_MAST.AC_ID,AC_MAST.AC_NAME
FROM LAC_VW AC
INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID)
INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY) '+RTRIM(@FCON)
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

DELETE FROM #AC_BAL1 WHERE 
DATE < (SELECT TOP 1 DATE FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN)
AND AC_NAME IN (SELECT AC_NAME FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN GROUP BY AC_NAME) 


SELECT AC_NAME,AC_ID,LBAL=SUM(CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END)
,DAYS1=@COLCAP1,DAYS2=@COLCAP2,DAYS3=@COLCAP3,DAYS4=@COLCAP4,DAYS5=@COLCAP5 
INTO #AC_BAL
FROM #AC_BAL1
GROUP BY AC_NAME,AC_ID
ORDER BY AC_NAME,AC_ID

--FOR BALANCE

SET @SQLCOMMAND=' '
SET @SQLCOMMAND = ' SELECT A.*,B.LBAL,B.DAYS1,B.DAYS2,B.DAYS3,B.DAYS4,B.DAYS5 FROM '+@TBLNAME3 +' A INNER JOIN #AC_BAL B ON (A.AC_NAME=B.AC_NAME) ORDER BY A.AC_NAME,A.DATE'
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND


SET @SQLCOMMAND=' '

SET @SQLCOMMAND=' '
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME1
EXECUTE SP_EXECUTESQL @SQLCOMMAND

SET @SQLCOMMAND=' '
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME2
EXECUTE SP_EXECUTESQL @SQLCOMMAND

SET @SQLCOMMAND=' '
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME3
EXECUTE SP_EXECUTESQL @SQLCOMMAND

SET @SQLCOMMAND=' '
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME12
EXECUTE SP_EXECUTESQL @SQLCOMMAND

SET ANSI_NULLS OFF
GO
