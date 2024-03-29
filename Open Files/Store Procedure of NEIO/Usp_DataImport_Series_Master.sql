DROP PROCEDURE [Usp_DataImport_Series_Master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Usp_DataImport_Series_Master]
@Code Varchar(3),@fName varchar(100),@Loc_Code Varchar(7),@Tbl Varchar (50)
as 
Begin
	Declare @SqlCommand nvarchar(max),@SqlCommand1 nvarchar(max),@UpdateSql nvarchar(max),@fld_Name varchar(60),@Table_Names Varchar (100),@Table_Name Varchar (100), @pos int -- Changed by Archana K. on 16/10/2012 for Bug-5837
	Declare @TblFldList as VARCHAR(50)
	Declare @UpdateStmt nvarchar(max),@FilterCondition nvarchar(max),@SqlCommnad nvarchar(max)-- Changed by Archana K. on 16/10/2012 for Bug-5837
	Declare @SqlCommand3 nvarchar(max),@UpdateSql3 nvarchar(max)		-- Changed by Archana K. on 09-04-2013

	--set @Table_Names='PTMain,PTItem,PTAcDet,PTItRef,PTMall'
	--set @Table_Names='Series'
	set @Table_Names=@Tbl

	Set @TblFldList = '##TblFldList'+(SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
	select * into #lcode_vw from lcode where entry_ty='AR' -- Lcode View 
--	select * from #lcode_vw
	--print @TblFldList
	--execute USP_DataImport_GetFiledSchema @Code,@fName,'PTMain,PTItem,PTAcDet,PTItRef,PTMall',@TblFldList
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

		set @SqlCommand=''
		set @UpdateSql=''
		if (@Table_Name<>'')
		begin
			Declare Cur_DataImp1 Cursor for select UpdateStmt,FilterCondition from ImpDataTableUpdate where Code=@Code and TableName=@Table_Name order by updOrder
			open Cur_DataImp1
			fetch next from Cur_DataImp1 into @UpdateStmt,@FilterCondition
			while (@@Fetch_Status=0)
			begin
				set @SqlCommnad=N'Update '+@Table_Name+' Set '+LTRIM(rtrim(@UpdateStmt)) +' Where '+rtrim(@FilterCondition)
				--print @SqlCommnad
				--execute sp_executesql @SqlCommnad
				fetch next from Cur_DataImp1 into @UpdateStmt,@FilterCondition
			end
			close Cur_DataImp1
			DeAllocate Cur_DataImp1

			set @SqlCommand1 ='Declare cur_AcMast cursor for select distinct Fld_Name from '+@TblFldList+' where Tbl_Name='+char(39)+@Table_Name+'_'+@fName+char(39)
			print @SqlCommand1
			execute sp_executesql @SqlCommand1
			open cur_AcMast
			fetch next from cur_AcMast into  @fld_Name
			while (@@fetch_Status=0)	
			begin
				
				set @UpdateSql=LTRIM(rtrim(@UpdateSql))+ RTRIM(cast(replicate(' ',100) as nvarchar(max))) +',a.['+@fld_name+']=b.['+@fld_name+']' ---- Changed by Sachin N. S. on 16/10/2012 for Bug-5837
				set @SqlCommand=rtrim(@SqlCommand)+',['+@fld_Name+']'
				
				fetch next from cur_AcMast into  @fld_Name

			end
			close cur_AcMast
			deallocate cur_AcMast
			
		
			--print 'aaa '+@SqlCommand
			if (@SqlCommand<>'')
			begin
				set @SqlCommand=substring(@SqlCommand,2,len(@SqlCommand)-1)
				set @UpdateSql=substring(@UpdateSql,2,len(@UpdateSql)-1)

				set @SqlCommand3=' insert into '+@Table_Name+' ('+rtrim(@SqlCommand)+',DataImport'+') '+' Select '+rtrim(@SqlCommand)+',DataExport1 from '+@Table_Name+'_'+@fName
--				set @SqlCommand=rtrim(@SqlCommand)+' where '+char(39)+@Loc_Code+char(39)+'+sEntry_ty+cast(Tran_cd as Varchar) not in (Select distinct DataImport From '+@Table_Name+')'
				set @SqlCommand3=rtrim(@SqlCommand3)+' where DataExport1 not in (Select distinct DataImport From '+@Table_Name+')'
				set @SqlCommand3=rtrim(@SqlCommand3)+' and Inv_sr not in (Select distinct Inv_sr From '+@Table_Name+')'

--				set @UpdateSql=N'Update a set '+LTRIM(rtrim(@UpdateSql))+' from '+@Table_Name+' a inner join '+@Table_Name+'_'+@fName+' b on (a.DataImport=b.DataExport1)' -- Commented by Archana K. on 16/10/2012 for Bug-5837
				set @UpdateSql3=N'Update a set '+LTRIM(rtrim(@UpdateSql))+' from '+@Table_Name+' a inner join '+@Table_Name+'_'+@fName+' b on (a.DataImport=b.DataExport1)' -- Changed by Archana K. on 16/10/2012 for Bug-5837
				print ' Insert Statement:- '+ @SqlCommand3
				print ' Update Statement:- '+@UpdateSql3 

				EXECUTE SP_EXECUTESQL @UpdateSql3				
				EXECUTE SP_EXECUTESQL @SqlCommand3

				-- Below Updating Nulls to their default Values.
				set @UpdateSql='execute Update_table_column_default_value '+char(39)+@Table_Name+char(39)+',1'
				EXECUTE SP_EXECUTESQL @UpdateSql

			end
		end
	end
end
GO
