DROP PROCEDURE [gen_acserial_new]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [gen_acserial_new] 
as
DECLARE @IntVariable INT
DECLARE @SQLString1 NVARCHAR(500)
DECLARE @ParmDefinition NVARCHAR(500)
DECLARE @p INT
SET @ParmDefinition = N'@p int output'

DECLARE @TBLNM VARCHAR(30),@SQLCOMMAND NVARCHAR(1000),@SQLCOMMAND1 NVARCHAR(1000),@FETCH_STATUS_M INT ,@AC_ID INT
DECLARE @TRAN_CD INT,@AC_NAME VARCHAR(100),@COUNT INT,@MTRAN_CD INT ,@ACSERIAL VARCHAR(5)
declare cur_tblnm cursor for
select [name] from sysobjects where [name] like '%acdet' and type='u' and id in (select id from syscolumns where [name]='acserial')
open  cur_tblnm
fetch next from cur_tblnm into @TBLNM
SET @FETCH_STATUS_M=@@FETCH_STATUS
WHILE (@FETCH_STATUS_M=0)
BEGIN
	PRINT @TBLNM
	SET @SQLCOMMAND='declare cur_FLD1 cursor for SELECT TRAN_CD,AC_NAME,AC_ID FROM '+@TBLNM+' where isnull(acserial,space(1))=space(1) ORDER BY TRAN_CD'
	EXECUTE SP_EXECUTESQL @SQLCOMMAND 
	open  cur_FLD1
	fetch next from cur_FLD1 into @TRAN_CD,@AC_NAME,@AC_ID
	SET @MTRAN_CD=@TRAN_CD
	SET @COUNT=0
	WHILE (@@FETCH_STATUS=0)
	BEGIN
		SET @COUNT=0
		set @p=0
		SET @SQLString1='SELECT @p=MAX(CAST(ACSERIAL AS NUMERIC)) FROM '+@TBLNM+' WHERE isnumeric(ACSERIAL)=1 and TRAN_CD='+CAST(@TRAN_CD AS VARCHAR)	
		EXECUTE sp_executesql @SQLString1, @ParmDefinition,@p OUTPUT
		 
		SET @COUNT=isnull(@p,0)+1
		SET @ACSERIAL=CAST(@COUNT AS VARCHAR(5))
		SET @ACSERIAL=REPLICATE('0',5-LEN(@ACSERIAL))+@ACSERIAL
		--PRINT @TBLNM+' ' +RTRIM(@AC_NAME)+' '+RTRIM(CAST(@TRAN_CD AS VARCHAR))+' '+@ACSERIAL
		SET @SQLCOMMAND1='UPDATE '+@TBLNM+' SET ACSERIAL= '+CHAR(39)+@ACSERIAL+CHAR(39)+ ' WHERE TRAN_CD='+CAST(@TRAN_CD AS VARCHAR)+ ' AND AC_ID='+CAST(@AC_ID AS VARCHAR)+ ' and isnull(acserial,space(1))=space(1)'
		print  @SQLString1
		print @SQLCOMMAND1
		EXECUTE SP_EXECUTESQL @SQLCOMMAND1
	fetch next from cur_FLD1 into @TRAN_CD,@AC_NAME,@AC_ID
	END
	close cur_FLD1
	deallocate cur_FLD1
	fetch next from cur_tblnm into @TBLNM
	SET @FETCH_STATUS_M=@@FETCH_STATUS
END
close cur_tblnm
deallocate cur_tblnm
GO
