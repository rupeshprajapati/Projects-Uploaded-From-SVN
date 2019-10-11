IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='Usp_DataImport_ServiceTax_Mast')
BEGIN
	DROP PROCEDURE Usp_DataImport_ServiceTax_Mast
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- AUTHOR	  :	PRIYANKA B.
-- CREATE DATE: 30/12/2017
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO IMPORT SERVICE TAX MASTER.
-- MODIFIED BY: 
-- MODIFY DATE: 
-- REMARK:
-- =============================================

CREATE procedure [dbo].[Usp_DataImport_ServiceTax_Mast]
@Code Varchar(3),@fName varchar(100),@Loc_Code Varchar(7),@Tbl Varchar (50)
as 
Begin
	Declare @SqlCommand nvarchar(max),@SqlCommand1 nvarchar(max),@UpdateSql nvarchar(max),@PreUpdateSql nvarchar(max),@fld_Name varchar(60),@Table_Names Varchar (100),@Table_Name Varchar (100), @pos int
	Declare @TblFldList as VARCHAR(50)
	Declare @UpdateStmt nvarchar(max),@FilterCondition nvarchar(max),@SqlCommnad nvarchar(max)
	Declare @SqlCommand3 nvarchar(max),@UpdateSql3 nvarchar(max)
		
	set @Table_Names=@tbl
	
	Set @TblFldList = '##TblFldList'+(SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000)
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
		print @pos
		set @Table_Names=substring(@Table_Names,@pos+1,len(@Table_Names)-@pos)
		Print '@Table_name->'+@Table_Names	
		Print '@Code-->'+@Code
		set @SqlCommand=''
		set @UpdateSql=''		
		if (@Table_Name<>'')
		begin		
			set @SqlCommand1 ='Declare cur_SerTaxMaster cursor for select distinct Fld_Name from '+@TblFldList+' where Tbl_Name='+char(39)+@Table_Name+'_'+@fName+char(39)
			print @SqlCommand1
			execute sp_executesql @SqlCommand1
			open cur_SerTaxMaster
			fetch next from cur_SerTaxMaster into  @fld_Name
			while (@@fetch_Status=0)	
			begin
				
				set @UpdateSql=LTRIM(rtrim(@UpdateSql))+ RTRIM(cast(replicate(' ',100) as nvarchar(max)))+',a.['+@fld_name+']=b.['+@fld_name+']'
				set @SqlCommand=rtrim(@SqlCommand)+',['+@fld_Name+']'
				fetch next from cur_SerTaxMaster into  @fld_Name
			end
			close cur_SerTaxMaster
			deallocate cur_SerTaxMaster
			
		print 'UpdateSql :- '+ @UpdateSql
			--print 'aaa '+@SqlCommand
			Print 'aaa'+@SqlCommand
			if (@SqlCommand<>'')
			begin
				set @SqlCommand=substring(@SqlCommand,2,len(@SqlCommand)-1)
				set @UpdateSql=substring(@UpdateSql,2,len(@UpdateSql)-1)
				
				if @Table_Name='SERTAX_MAST'
				begin
				print '1'
					set @SqlCommand3=' insert into '+@Table_Name+' ('+rtrim(@SqlCommand)+',DataImport'+') '+' Select '+rtrim(@SqlCommand)+',DataExport1 from '+@Table_Name+'_'+@fName
					set @SqlCommand3=rtrim(@SqlCommand3)+' where (name+cast(sdate as varchar)+cast(edate as varchar)) not in (Select distinct (name+cast(sdate as varchar)+cast(edate as varchar)) From '+@Table_Name+' ) and DataExport1 not in (Select distinct DataImport From '+@Table_Name+')'
					set @UpdateSql3=N'Update a set '+LTRIM(rtrim(@UpdateSql))+' from '+@Table_Name+' a inner join '+@Table_Name+'_'+@fName+' b on (a.DataImport=b.DataExport1)'
					print ' Insert Statement:- '+ @SqlCommand3
					print ' Update Statement:- '+@UpdateSql3 
					EXECUTE SP_EXECUTESQL @UpdateSql3
					EXECUTE SP_EXECUTESQL @SqlCommand3
				end	
				
				 --Below Updating Nulls to their default Values.
				set @UpdateSql='execute Update_table_column_default_value '+char(39)+@Table_Name+char(39)+',1'
				EXECUTE SP_EXECUTESQL @UpdateSql

			end
		end
	end
end