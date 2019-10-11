IF EXISTS(SELECT [NAME] FROM SYS.PROCEDURES WHERE [NAME]='Usp_Multi_Co_Final_Accounts')
BEGIN
	DROP PROCEDURE Usp_Multi_Co_Final_Accounts
END
GO

/****** Object:  StoredProcedure [dbo].[Usp_Multi_Co_Final_Accounts]    Script Date: 05/16/2018 13:06:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*:*****************************************************************************
*:       Program: Usp_Multi_Co_Final_Accounts
*:        System: Udyog Software (I) Ltd.
*:    Programmer: SACHIN N. SAPALIGA
*: Last modified: 08/07/2017
*:		AIM		: Maintain Final Acounts reports Like
*:				  [Trial Balance, Profit and Loss Accounts and Balance Sheet]
**:******************************************************************************/

CREATE PROCEDURE [dbo].[Usp_Multi_Co_Final_Accounts]
@FDate SMALLDATETIME,@TDate SMALLDATETIME,@C_St_Date SMALLDATETIME,@reporttype varchar(1),@CDbName varchar(20)
--,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
--,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)

As
--@reporttype varchar(1)
If @FDate IS NULL OR @TDate IS NULL OR @C_St_Date IS NULL
Begin
	RAISERROR ('Please pass valid parameters..',16,1)
	Return 
End
If @FDate = '' OR @TDate = '' OR @C_St_Date = ''
Begin
	RAISERROR ('Please pass valid parameters..',16,1)
	Return 
End

--if (@SDEPT is null OR @EDEPT IS NULL OR @SCATE IS NULL OR @ECATE IS NULL) /*TKT-1129*/
--Begin
--	RAISERROR ('Please pass valid parameters..',16,1)
--	Return 
--End

--SELECT @CDbName = SUBSTRING(REPLACE(@CDbName,'][',CHAR(39)+','+CHAR(39)),2,LEN(@CDbName)-2)

/* Internal Variable declaration and Assigning [Start] */
Declare @Balance Numeric(17,2),@TBLNM VARCHAR(50),@TBLNAME1 Varchar(50),
	@TBLNAME2 Varchar(50),@TBLNAME3 Varchar(50),@TBLNAME4 Varchar(50),
	@SQLCOMMAND as NVARCHAR(4000),@TIME SMALLDATETIME

Declare @TBLNAME5 Varchar(50)

Select @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
		+ (DATEPART(ss, GETDATE()) * 1000 )+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No),
		@Balance = 0,@SQLCOMMAND = ''

Select @TBLNAME1 = '##TMP1'+@TBLNM,@TBLNAME2 = '##TMP2'+@TBLNM
Select @TBLNAME3 = '##TMP3'+@TBLNM,@TBLNAME4 = '##TMP4'+@TBLNM
Select @TBLNAME5 ='##TMP5'+@TBLNM
/* Internale Variable declaration and Assigning [End] */

Select * into ##STKVALConfig from StkValConfig

--PRINT 'TEST - 1'

/* Collecting Data from accounts details and create table [Start] */
SET @SQLCOMMAND = 'SELECT AVW.TRAN_CD,AVW.ENTRY_TY,AVW.DATE,AVW.AMOUNT,AVW.AMT_TY,
		MVW.INV_NO,AC_MAST.AC_ID,AC_MAST.[TYPE],AC_MAST.AC_NAME,AVW.ACSERIAL,AVW.DBNAME
		INTO '+@TBLNAME1+' FROM LAC_VW AVW (NOLOCK)
		INNER JOIN AC_MAST (NOLOCK) ON AVW.AC_ID = AC_MAST.AC_ID AND AVW.DBNAME = AC_MAST.DBNAME
		INNER JOIN LMAIN_VW MVW (NOLOCK) ON AVW.TRAN_CD = MVW.TRAN_CD AND AVW.ENTRY_TY = MVW.ENTRY_TY AND AVW.DBNAME = MVW.DBNAME
		WHERE (MVW.DATE < = '''+CONVERT(VARCHAR(50),@TDate)+''' )'+
		CASE WHEN @CDbName<>'' THEN ' AND AVW.DBNAME = '+CHAR(39)+@CDbName+CHAR(39) ELSE '' END

--If (@EDEPT<>'')
--Begin
--	SET @SQLCOMMAND =rtrim(@SQLCOMMAND)+' '+' and ('+'MVW.DEPT between '''+@SDEPT+''' and '''+@EDEPT+''')'
--End

--If (@ECATE<>'') 
--Begin
--	SET @SQLCOMMAND =rtrim(@SQLCOMMAND)+' '+' and ('+'MVW.Cate between '''+@SCATE+''' and '''+@ECATE+''')'
--End
--PRINT @SQLCOMMAND
EXECUTE sp_executesql @SQLCOMMAND
/* Collecting Data from accounts details and create table [End] */


--PRINT 'TEST - 2'

Declare @Stk_OpAccounts Varchar(100),@Stk_ClAccounts Varchar(100)  
Set @Stk_ClAccounts = ''
DECLARE CSTKVAL CURSOR FOR 
SELECT ClB_AcName FROM ##STKVALConfig
OPEN CSTKVAL
FETCH NEXT FROM CSTKVAL INTO @Stk_ClAccounts
WHILE @@FETCH_STATUS=0
BEGIN

	SET @SQLCOMMAND = 'DELETE FROM '+@TBLNAME1+' WHERE AC_NAME = '''+@Stk_ClAccounts+''' AND 
		[DATE] < '''+CONVERT(VARCHAR(50),@C_St_Date-1)+''' '	
	EXECUTE sp_executesql @SQLCOMMAND 

	FETCH NEXT FROM CSTKVAL INTO @Stk_ClAccounts
END
CLOSE CSTKVAL
DEALLOCATE CSTKVAL

--PRINT 'TEST - 3'

/*Remove Trading and Profit loss Previous Entry [Start]*/
SET @SQLCOMMAND = 'DELETE FROM '+@TBLNAME1+' WHERE CONVERT(VARCHAR(20),TRAN_CD)+''-''+ENTRY_TY+''-''+DBNAME IN 
	(SELECT CONVERT(VARCHAR(20),TRAN_CD)+''-''+ENTRY_TY+''-''+DBNAME AS COMEID FROM '+@TBLNAME1+' WHERE [TYPE] IN (''T'',''P'') 
	AND [DATE] NOT BETWEEN '''+CONVERT(VARCHAR(50),@FDate)+''' AND '''+CONVERT(VARCHAR(50),@TDate)+''') AND [TYPE] IN (''T'',''P'') '
EXECUTE sp_executesql @SQLCOMMAND
/*Remove Trading and Profit loss Previous Entry [End]*/

--PRINT 'TEST - 4'

SET @SQLCOMMAND = 'DECLARE @OPTRAN_CD as INT,@OPDATE as DATETIME,@OPACNAME as varchar(250),@OPDBNAME as varchar(250)  
	DECLARE openingentry_cursor CURSOR FOR
	SELECT TRAN_CD,AC_NAME,DATE,DBNAME FROM '+@TBLNAME1+' WHERE 
	ENTRY_TY IN (''OB'') 
	OPEN openingentry_cursor
	FETCH NEXT FROM openingentry_cursor into @OPTRAN_CD,@OPACNAME,@OPDATE,@OPDBNAME
	WHILE @@FETCH_STATUS = 0
	BEGIN
	   DELETE FROM '+@TBLNAME1+' WHERE DATE < @OPDATE AND DBNAME = @OPDBNAME		--Changes done by vasant on 05/05/2012 as per Bug 3450 (Balance sheet report Problem).
			AND AC_NAME IN (SELECT AC_NAME FROM '+@TBLNAME1+' WHERE AC_NAME = @OPACNAME AND ENTRY_TY IN (''OB'') AND 
			TRAN_CD = @OPTRAN_CD AND DBNAME = @OPDBNAME)		--Changes done by vasant on 05/05/2012 as per Bug 3450 (Balance sheet report Problem).
	   FETCH NEXT FROM openingentry_cursor into @OPTRAN_CD,@OPACNAME,@OPDATE,@OPDBNAME
	END
CLOSE openingentry_cursor
DEALLOCATE openingentry_cursor'
EXECUTE SP_EXECUTESQL @SQLCOMMAND
 
--PRINT 'TEST - 5'

Set @Stk_OpAccounts = ''
DECLARE CSTKVAL CURSOR FOR 
SELECT Op_AcName FROM ##STKVALConfig
OPEN CSTKVAL
FETCH NEXT FROM CSTKVAL INTO @Stk_OpAccounts
WHILE @@FETCH_STATUS=0
BEGIN

	SET @SQLCOMMAND = 'IF EXISTS(SELECT TOP 1 A.DATE FROM ARMAIN A WHERE A.[RULE] IN (''EXCISE'',''NON-EXCISE'') AND 
		A.DATE < '''+CONVERT(VARCHAR(50),@C_St_Date)+''')' 
	SET @SQLCOMMAND = @SQLCOMMAND + 'Update '+@TBLNAME1+' Set Amount = 0 Where AC_NAME in ('''+@Stk_OpAccounts+''') '	
	EXECUTE sp_executesql @SQLCOMMAND

	FETCH NEXT FROM CSTKVAL INTO @Stk_OpAccounts
END
CLOSE CSTKVAL
DEALLOCATE CSTKVAL

--PRINT 'TEST - 6'


Set @Stk_OpAccounts = ''
Set @Stk_ClAccounts = ''
DECLARE CSTKVAL CURSOR FOR 
SELECT Op_AcName,ClB_AcName FROM ##STKVALConfig
OPEN CSTKVAL
FETCH NEXT FROM CSTKVAL INTO @Stk_OpAccounts,@Stk_ClAccounts
WHILE @@FETCH_STATUS=0
BEGIN

	SET @SQLCOMMAND = 'UPDATE '+@TBLNAME1+' SET AC_NAME = '''+@Stk_OpAccounts+''', AC_ID=(SELECT AC_ID FROM AC_MAST 
		WHERE AC_NAME = '''+@Stk_OpAccounts+''') WHERE AC_NAME = '''+@Stk_ClAccounts+''' AND 
		[DATE] = '''+CONVERT(VARCHAR(50),@C_St_Date-1)+''' '	
	EXECUTE sp_executesql @SQLCOMMAND 

	FETCH NEXT FROM CSTKVAL INTO @Stk_OpAccounts,@Stk_ClAccounts
END
CLOSE CSTKVAL
DEALLOCATE CSTKVAL

--PRINT 'TEST - 7'

Drop table ##STKVALConfig


SET @SQLCOMMAND = 
	'SELECT TRAN_CD=0,ENTRY_TY='' '',
		DATE = '''+CONVERT(VARCHAR(50),@FDate)+''',
		AMOUNT=ISNULL(SUM(CASE WHEN TVW.AMT_TY = ''DR'' THEN TVW.AMOUNT ELSE - TVW.AMOUNT END),0),
		TVW.AC_ID,TVW.AC_NAME,TVW.ACSERIAL,AMT_TY=''A'',INV_NO='' '', DBNAME
		INTO '+@TBLNAME2+' FROM '+@TBLNAME1+' TVW
	WHERE (TVW.DATE < '''+CONVERT(VARCHAR(50),@FDate)+'''
		OR TVW.ENTRY_TY IN 
			(Select Entry_Ty From LCode 
				Where bCode_Nm = ''OB'' OR Entry_Ty = ''OB'' OR bCode_Nm = ''OS'' OR Entry_Ty = ''OS'' AND DBNAME=TVW.DBNAME)) 
	GROUP BY TVW.DBNAME,TVW.AC_ID,TVW.AC_NAME,TVW.ACSERIAL
	UNION
	SELECT TVW.TRAN_CD,TVW.ENTRY_TY,TVW.DATE,
		AMOUNT=(CASE WHEN TVW.AMT_TY=''DR'' THEN TVW.AMOUNT ELSE -TVW.AMOUNT END),
		TVW.AC_ID,TVW.AC_NAME,TVW.ACSERIAL,TVW.AMT_TY,TVW.INV_NO,TVW.DBNAME
	FROM '+@TBLNAME1+' TVW
		LEFT JOIN LAC_VW LVW (NOLOCK) ON TVW.TRAN_CD = LVW.TRAN_CD AND TVW.ENTRY_TY = LVW.ENTRY_TY AND TVW.AC_ID != LVW.AC_ID AND TVW.DBNAME = LVW.DBNAME
		WHERE (TVW.DATE BETWEEN '''+CONVERT(VARCHAR(50),@FDate)+''' AND '''+CONVERT(VARCHAR(50),@TDate)+''' AND 
			TVW.ENTRY_TY NOT IN (Select Entry_Ty From LCode Where bCode_Nm = ''OB'' OR Entry_Ty = ''OB'' OR 
			bCode_Nm = ''OS'' OR Entry_Ty = ''OS'' AND DBNAME=TVW.DBNAME))'
EXECUTE sp_executesql @SQLCOMMAND

--PRINT 'TEST - 8'

SET @SQLCOMMAND = 'SELECT A.DBNAME,a.Ac_id,
	Opening = isnull(CASE Amt_Ty WHEN ''A'' THEN SUM(a.Amount)END,0),
	Debit = isnull(CASE Amt_Ty WHEN ''DR'' THEN SUM(a.Amount)END,0),
	Credit = isnull(CASE Amt_Ty WHEN ''CR'' THEN SUM(a.Amount) END,0)
	Into '+@TBLNAME3+' from '+@TBLNAME2+' a
	group by A.DBNAME,a.Ac_id,a.amt_ty'
EXECUTE sp_executesql @SQLCOMMAND

--PRINT 'TEST - 9'

SET @SQLCOMMAND = 'SELECT b.Ac_id,Sum(IsNull(a.Opening,0)) as OpBal,Sum(IsNull(a.Debit,0)) as Debit,
	Sum(IsNull(a.Credit,0)) as Credit,CAST(0 AS Numeric(17,2)) As ClBal, b.dbname
	Into '+@TBLNAME4+' from '+@TBLNAME3+' a Right Join Ac_Mast b 
	ON (b.Ac_id = a.Ac_id and b.DbName = a.DbName ) '+
	CASE WHEN @CDbName<>'' THEN ' Where b.DBNAME = '+CHAR(39)+@CDbName+CHAR(39) ELSE '' END+' group by b.DbName,b.Ac_id'
EXECUTE sp_executesql @SQLCOMMAND

--PRINT 'TEST - 10'

SET @SQLCOMMAND = 'Update '+@TBLNAME4+' SET OPbal = (CASE WHEN OpBal IS NULL THEN 0 ELSE OPBAL END),
	Debit = (CASE WHEN Debit IS NULL THEN 0 ELSE Debit END),
	Credit = (CASE WHEN Credit IS NULL THEN 0 ELSE Credit END),
	Clbal = (CASE WHEN Clbal IS NULL THEN 0 ELSE Clbal END)'
EXECUTE sp_executesql @SQLCOMMAND

--PRINT 'TEST - 11'

SET @SQLCOMMAND = 'UPDATE '+@TBLNAME4+' SET ClBal = (OpBal+Debit-ABS(Credit)) '
EXECUTE sp_executesql @SQLCOMMAND 


--PRINT 'TEST - 12'

/* Combined Groups And Ledgers with Opening,Debit,Credit[Start] */
SET @SQLCOMMAND = 'Select Updown,''G'' As MainFlg,Ac_Group_Id as Ac_Id,gAC_id as Ac_Group_Id,AC_GROUP_NAME+space(100) as Ac_Name,[Group]+space(100) as [Group],
	CAST(0 AS Numeric(17,2)) As OpBal,CAST(0 AS Numeric(17,2)) As Debit,CAST(0 AS Numeric(17,2)) As Credit,CAST(0 AS Numeric(17,2)) As ClBal,
	dbname
	INTO '+@TBLNAME5+' From Ac_Group_Mast'+
	CASE WHEN @CDbName<>'' THEN ' WHERE DBNAME ='+CHAR(39)+@CDbName+CHAR(39) ELSE '' END+	
' Union All 
Select Updown,''L'' As MainFlg,b.Ac_Id,b.Ac_Group_Id,b.Ac_Name+space(100), b.[Group]+space(100) as [Group],
	a.OpBal,a.Debit,ABS(a.Credit),a.ClBal, a.DbName
	From '+@TBLNAME4+' a Right Join Ac_Mast b ON (b.Ac_id = a.Ac_id and b.dbname = a.dbname)'+
	CASE WHEN @CDbName<>'' THEN ' WHERE B.DBNAME ='+CHAR(39)+@CDbName+CHAR(39) ELSE '' END
--print @SQLCOMMAND
EXECUTE sp_executesql @SQLCOMMAND
/* Combined Groups And Ledgers [End] */

--PRINT 'TEST - 13'


/* Updating the Alternate group in case of Negative Balance Sheet[Start] */	
If Exists(Select b.[name] From sysobjects a inner join syscolumns b on (a.id=b.id) where a.[name]='ac_mast' and b.[name]='agrp_id')
Begin
	SET @SQLCOMMAND = 'Select DbName,Ac_id,aGrp_Id Into #pGrpid from Ac_mast 
		Where isnull(AGRP_ID,0)<>0 '+ CASE WHEN @CDbName<>'' THEN ' AND DBNAME = '+char(39)+@CDbName+char(39) ELSE '' END+

	--'PRINT ''TEST - 13.1'' '+

	'SELECT DbName,AC_ID,ACTYPE=space(1) INTO #ACMAST FROM PTMAIN WHERE 1=2
	
	DECLARE @MCOND AS BIT,@LVL AS INT
	
	CREATE TABLE #ACGRPID (DBNAME VARCHAR(20) COlLATE DATABASE_DEFAULT,GACID DECIMAL(9),LVL DECIMAL(9))
	SET @LVL=0
	
	--PRINT ''TEST - 13.2'' 
	
	INSERT INTO #ACGRPID 
		SELECT DBNAME,AC_GROUP_ID,@LVL FROM AC_GROUP_MAST WHERE AC_GROUP_NAME =''LIABILITIES'' '+CASE WHEN @CDbName<>'' THEN ' AND DBNAME = '+char(39)+@CDbName+char(39) ELSE ' ' END+
	'SET @MCOND=1
	WHILE @MCOND=1
	BEGIN
		IF EXISTS (SELECT AC_GROUP_ID FROM AC_GROUP_MAST 
						WHERE AC_GROUP_ID!=GAC_ID AND GAC_ID IN 
								(SELECT DISTINCT GACID  FROM #ACGRPID WHERE LVL=@LVL AND DBNAME=AC_GROUP_MAST.DBNAME) 
							'+CASE WHEN @CDbName<>'' THEN ' AND DBNAME = '+char(39)+@CDbName+char(39) ELSE '' END+') 
		BEGIN
			----PRINT @LVL
			INSERT INTO #ACGRPID SELECT DBNAME,AC_GROUP_ID,@LVL+1 FROM AC_GROUP_MAST 
				WHERE AC_GROUP_ID!=GAC_ID AND 
					GAC_ID IN (SELECT DISTINCT GACID  FROM #ACGRPID WHERE LVL=@LVL AND DBNAME=AC_GROUP_MAST.DBNAME)'
			+CASE WHEN @CDbName<>'' THEN ' AND DBNAME = '+char(39)+@CDbName+char(39) ELSE '' END+
			'SET @LVL=@LVL+1
		END
		ELSE
		BEGIN
			SET @MCOND=0	
		END
	END
	
	--PRINT ''TEST - 13.3'' 
	
	INSERT INTO #ACMAST 
		SELECT DBNAME,AC_ID,''L'' FROM AC_MAST 
			WHERE  AC_GROUP_ID IN (SELECT DISTINCT GACID FROM #ACGRPID WHERE DBNAME=AC_MAST.DBNAME)'
			+CASE WHEN @CDbName<>'' THEN ' AND DBNAME = '+char(39)+@CDbName+char(39) ELSE '' END+
	'DELETE FROM #ACGRPID
	
	
	--PRINT ''TEST - 13.4'' 
	
	INSERT INTO #ACGRPID 
		SELECT DBNAME,AC_GROUP_ID,@LVL  FROM AC_GROUP_MAST WHERE AC_GROUP_NAME =''ASSETS'''+CASE WHEN @CDbName<>'' THEN ' AND DBNAME = '+char(39)+@CDbName+char(39) ELSE '' END+
		
	--'PRINT ''TEST - 13.5'' '+
		
	'SET @LVL=0
	SET @MCOND=1
	WHILE @MCOND=1
	BEGIN
		IF EXISTS (SELECT AC_GROUP_ID FROM AC_GROUP_MAST 
						WHERE GAC_ID IN (SELECT DISTINCT GACID FROM #ACGRPID 
											WHERE LVL=@LVL AND DBNAME=AC_GROUP_MAST.DBNAME)
								'+CASE WHEN @CDbName<>'' THEN ' AND DBNAME = '+char(39)+@CDbName+char(39) ELSE '' END+')
		BEGIN
			INSERT INTO #ACGRPID 
				SELECT DBNAME,AC_GROUP_ID,@LVL+1 FROM AC_GROUP_MAST 
					WHERE GAC_ID IN (SELECT DISTINCT GACID  FROM #ACGRPID WHERE LVL=@LVL AND DBNAME=AC_GROUP_MAST.DBNAME)'
						+CASE WHEN @CDbName<>'' THEN ' AND DBNAME = '+char(39)+@CDbName+char(39) ELSE '' END+
			'SET @LVL=@LVL+1
		END
		ELSE
		BEGIN
			SET @MCOND=0	
		END
	END
	
	
	--PRINT ''TEST - 13.6''
	
	INSERT INTO #ACMAST 
		SELECT DBNAME,AC_ID,''A'' FROM AC_MAST 
			WHERE  AC_GROUP_ID IN (SELECT DISTINCT GACID FROM #ACGRPID WHERE DBNAME=AC_MAST.DBNAME)'
			+CASE WHEN @CDbName<>'' THEN ' AND DBNAME = '+char(39)+@CDbName+char(39) ELSE '' END+
	'DELETE FROM #ACGRPID'


	--PRINT 'TEST - 13.7'

	SET @SQLCOMMAND = @SQLCOMMAND+' '+'Update '	+@TBLNAME5+' set Ac_group_Id=b.aGrp_id From '+@TBLNAME5+' a '
	SET @SQLCOMMAND = @SQLCOMMAND+' '+'inner join #pGrpid b On (a.Ac_Id=b.Ac_Id AND a.DBNAME=b.DBNAME) '
	SET @SQLCOMMAND = @SQLCOMMAND+' '+'Left Join #ACMAST c on (a.ac_id=c.ac_id AND a.DBNAME=c.DBNAME) '
	SET @SQLCOMMAND = @SQLCOMMAND+' '+'Where (c.AcType=''L'' and a.ClBal>0) Or ((c.AcType IS NULL OR c.AcType=''A'')AND a.ClBal<0)'
	
	
	EXECUTE sp_executesql @SQLCOMMAND
	
	--PRINT 'TEST - 13.8'
End
/* Updating the Alternate group in case of Negative Balance Sheet[End] */

--PRINT 'TEST - 14'

Declare @OpbalAmt Decimal(18,2),@ParmDefinition NVARCHAR(500)
set @OpbalAmt=0
SET @ParmDefinition=N'@parmOUT Decimal(18,2) Output'
SET @SQLCOMMAND = 'Select @parmOUT=Isnull(Clbal,0) from '+@TBLNAME5+' Where AC_NAME in (''OPENING BALANCES'')'		
EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition,@parmOUT=@OpbalAmt Output

--PRINT 'TEST - 15'

SET @SQLCOMMAND = 'Update '+@TBLNAME5+' Set Opbal=0,Debit=0,Credit=0,ClBal=0 Where AC_NAME in (''OPENING BALANCES'')'		
EXECUTE sp_executesql @SQLCOMMAND


--PRINT 'TEST - 16'

SET @SQLCOMMAND = 'Select a.*,'+convert(Varchar(20),@OpbalAmt)+' as OpBalAmt, b.Co_Name From '+@TBLNAME5+' a '+
	' Inner join Com_Det b on a.DbName=B.DbName '
EXECUTE sp_executesql @SQLCOMMAND

--PRINT 'TEST - 17'

SET @SQLCOMMAND = 'Drop table '+@TBLNAME5
EXECUTE sp_executesql @SQLCOMMAND

/* Droping Temp tables [Start] */
SET @SQLCOMMAND = 'Drop table '+@TBLNAME1
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'Drop table '+@TBLNAME2
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'Drop table '+@TBLNAME3
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'Drop table '+@TBLNAME4
EXECUTE sp_executesql @SQLCOMMAND
/* Droping Temp tables [End] */
GO


