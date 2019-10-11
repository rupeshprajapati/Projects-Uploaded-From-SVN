IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='Usp_DataImport_Country_Master')
BEGIN
	DROP PROCEDURE Usp_DataImport_Country_Master
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- AUTHOR	  :	PRIYANKA B.
-- CREATE DATE: 27/12/2017
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO IMPORT COUNTRY MASTER.
-- MODIFIED BY: 
-- MODIFY DATE: 
-- REMARK:
-- =============================================

CREATE procedure [dbo].[Usp_DataImport_Country_Master]
@Code Varchar(3),@fName varchar(100),@Loc_Code Varchar(7),@Tbl Varchar (50)
as 
Begin
	Declare @SqlCommand nvarchar(max),@SqlCommand1 nvarchar(max),@UpdateSql nvarchar(max),@fld_Name varchar(60),@Table_Names Varchar (100),@Table_Name Varchar (100), @pos int
	Declare @UpdateSqlTmp nvarchar(max),@SqlCommand3 nvarchar(max),@SqlCommand2 nvarchar(max),@SqlCommand4 nvarchar(max),@UpdateSql1 nvarchar(max)
	, @country varchar(30),@country_id int,@ParmDefinition nvarchar(500),@TblFldList as VARCHAR(50)
	Declare @SqlCommand5 nvarchar(max),@UpdateSql3 nvarchar(max)
	
	set @Table_Names=@Tbl 
	Set @TblFldList = '##TblFldList'+(SELECT substring(rtrim(ltrim(str(RAND((DATEPART(mm, GETDATE()) * 100000)
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
	
	execute USP_DataImport_GetFiledSchema @Code,@fName,@Table_Names,@TblFldList
	print 'a '+@TblFldList

	set @Table_Names=@Table_Names+','
	set @pos=2
	
	while (@pos>1)
	begin
		set @pos=charindex(',',@Table_Names)
		set @Table_Name=substring(@Table_Names,0,@pos)
		set @Table_Names=substring(@Table_Names,@pos+1,len(@Table_Names)-@pos)
		
		set @SqlCommand=''
		set @UpdateSql=''
		if (@Table_Name<>'')
		begin
		print '1'
			set @SqlCommand1 ='Declare cur_COUNTRY cursor for select distinct Fld_Name from '+@TblFldList+' where Tbl_Name='+char(39)+@Table_Name+'_'+@fName+char(39)
			execute sp_executesql @SqlCommand1
			open cur_COUNTRY
			fetch next from cur_COUNTRY into @fld_Name
			while (@@fetch_Status=0)	
			begin
				set @UpdateSql=LTRIM(rtrim(@UpdateSql))+ RTRIM(cast(replicate(' ',100) as nvarchar(max)))+',a.['+@fld_name+']=b.['+@fld_name+']'
				set @SqlCommand=rtrim(@SqlCommand)+',['+@fld_Name+']'
				fetch next from cur_COUNTRY into  @fld_Name
			end
			close cur_COUNTRY
			deallocate cur_COUNTRY
			
			Print 'a'
			if (@SqlCommand<>'')
			begin
				set @SqlCommand4=substring(@SqlCommand,2,len(@SqlCommand)-1)
				set @UpdateSql1=substring(@UpdateSql,2,len(@UpdateSql)-1)
				set @SqlCommand2 ='Declare chk_COUNTRYID cursor for select distinct country from '+@Table_Name+'_'+@fName
				print @SqlCommand2
				execute sp_executesql @SqlCommand2
				open chk_COUNTRYID
				fetch next from chk_COUNTRYID into @country
				while (@@fetch_Status=0)	
				begin
					set @country_id = 0
					set @SqlCommand3=N'select @gnm=country_id from '+@Table_Name+' where country='''+replace(@country,'''','''''') +''''
					SET @ParmDefinition = N'@gnm Numeric(18,0) OUTPUT';
					execute sp_executesql @SqlCommand3,@ParmDefinition,@gnm=@country_id OUTPUT; 	
					if(@country_id>0)
					begin
						set @UpdateSqlTmp=N'Update a set a.country_id='+convert(varchar(20),@country_id)+' from '+@Table_Name+'_'+@fName+ ' a where a.country='''+replace(@country,'''','''''')+''''
						Print '1. '+@UpdateSqlTmp
						EXECUTE SP_EXECUTESQL @UpdateSqlTmp	
						set @UpdateSql3=N'Update a set '+LTRIM(rtrim(@UpdateSql1))+' from '+@Table_Name+' a inner join '+@Table_Name+'_'+@fName+' b on (a.DataImport=b.DataExport1 )'
						print ' Update Statement:- '+@UpdateSql3
						EXECUTE SP_EXECUTESQL @UpdateSql3
					end	
					else
					begin
						set @SqlCommand5=N'Insert into '+@Table_Name+' ('+rtrim(@SqlCommand4)+',DataImport'+') '+' Select '+rtrim(@SqlCommand4)+',DataExport1 from '+@Table_Name+'_'+@fName
						set @SqlCommand5=rtrim(@SqlCommand5)+' where country not in (Select distinct country From '+@Table_Name+' ) and  DataExport1 not in (Select distinct DataImport From '+@Table_Name+') and country='''+replace(@country,'''','''''')+''''
						print ' Insert Statement:- '+ @SqlCommand5
						EXECUTE SP_EXECUTESQL @SqlCommand5
					end
				fetch next from chk_COUNTRYID into @country
				end
				close chk_COUNTRYID
				deallocate chk_COUNTRYID
				
				set @SqlCommand4=''
				set @UpdateSql1=''
				-- Below Updating Nulls to their default Values.
				set @UpdateSql='execute Update_table_column_default_value '+char(39)+@Table_Name+char(39)+',1'
				EXECUTE SP_EXECUTESQL @UpdateSql
			end
		end
	end
end