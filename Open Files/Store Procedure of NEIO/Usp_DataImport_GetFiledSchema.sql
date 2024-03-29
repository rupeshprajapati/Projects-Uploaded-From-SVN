DROP PROCEDURE [Usp_DataImport_GetFiledSchema]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [Usp_DataImport_GetFiledSchema]
@Code Varchar(3),@fName varchar(100),@Table_Names Varchar (100),@TblFldList varchar(60)
as
begin
	Declare @SqlCommand nVarchar(1000)
	set @SqlCommand='Create  table '+@TblFldList+' (Tbl_Name varchar(100),Fld_Name varchar(50),fType varchar(60))'
	execute sp_executesql @SqlCommand
	Create  table #tblExclFld (Tbl_Name varchar(100) COLLATE database_default ,Fld_Name varchar(50) COLLATE database_default )
	--Create  table #TblFldList (Tbl_Name varchar(100),Fld_Name varchar(50),fType varchar(60))
	Declare @Table_Name Varchar (100),@tTable_Name Varchar (1000), @pos int,@pos1 int,@ExclFld varchar(1000),@Fld_Nm varchar(50)
	set @Table_Names=@Table_Names+','
	Select @tTable_Name=Tables from imp_master where import=1 and Code=@code
	set @pos=2
	while (@pos>1)
	begin
		set @pos=charindex(',',@Table_Names)
		set @Table_Name=substring(@Table_Names,0,@pos)
		--print @pos
		set @Table_Names=substring(@Table_Names,@pos+1,len(@Table_Names)-@pos)
		--print '-'
--		print @Table_Name
--		print @tTable_Name
		set @pos1=charindex('<<'+@Table_Name,@tTable_Name)
--		print '---'
		set @ExclFld=''
		if ( (@pos1>0) and (@Table_Name<>''))
		begin
			set @ExclFld=substring(@tTable_Name,@pos1+2,len(@tTable_Name))
--			print @ExclFld
			set @pos1=charindex('>>>',@ExclFld)
			set @ExclFld=substring(@ExclFld,1,@pos1)
--			print 'B '+@ExclFld
			set @pos1=charindex('##ExcludeFld<',@ExclFld)
--			print @pos1
			set @ExclFld=substring(@ExclFld,@pos1+13,len(@ExclFld)-@pos1-12)
--			print 'C '+@ExclFld
			set @pos1=charindex('>',@ExclFld)
--			print @pos1
			set @ExclFld=substring(@ExclFld,1,@pos1-1)
--			print 'D '+@ExclFld
			set @ExclFld=@ExclFld+','
			--print @ExclFld
			if  (@ExclFld<>'')
			begin	
				while(charindex(',',@ExclFld)>0)
				begin
					
					set @pos1=charindex(',',@ExclFld)
					
					set @fld_nm=substring(@ExclFld,1,@pos1-1)
					insert into #tblExclFld values (@Table_Name,@fld_nm)
					--print @fld_nm
					set @ExclFld=substring(@ExclFld,@pos1,len(@ExclFld))
					if (substring(@ExclFld,1,1)=',') 
					begin	
						set @ExclFld=substring(@ExclFld,2,len(@ExclFld)-1)
					end
					--print 'bb '+@ExclFld
				end
			end		
		end
		--
		
		set @SqlCommand='insert into '+@TblFldList+' (Tbl_Name,Fld_Name,fType) '
		set @SqlCommand=rtrim(@SqlCommand)+' '+'select o.[Name],c.[Name],t.[Name] from syscolumns c inner join sysobjects o  on (c.id=o.id) inner join systypes t  on (c.xType=t.xType) where o.[Name]='+char(39)+@Table_Name+'_'+@fName+char(39)+' and o.xtype=''u'''
		set @SqlCommand=rtrim(@SqlCommand)+' '+'and c.[Name] in '
		set @SqlCommand=rtrim(@SqlCommand)+' '+'('
		set @SqlCommand=rtrim(@SqlCommand)+' '+'select c.[Name] from syscolumns c inner join sysobjects o  on (c.id=o.id) where o.[Name]='+char(39)+@Table_Name+char(39)+' and o.xtype=''u''' 	
		set @SqlCommand=rtrim(@SqlCommand)+' '+'and c.[Name] not in (select Fld_Name from #tblExclFld where Tbl_Name='+char(39)+@Table_Name+char(39)+')'
		set @SqlCommand=rtrim(@SqlCommand)+' '+')'
		print @SqlCommand
		--set @SqlCommand=rtrim(@SqlCommand)+' '+'order by c.[Name]'	


		execute sp_executesql @SqlCommand
--		insert into #TblFldList (Tbl_Name,Fld_Name,fType) 
--		select o.[Name],c.[Name],t.[Name] from syscolumns c inner join sysobjects o  on (c.id=o.id) inner join systypes t  on (c.xType=t.xType) where o.[Name]=@Table_Name+'_'+@fName and o.xtype='u'
--		and c.[Name] in 
--		(
--		select c.[Name] from syscolumns c inner join sysobjects o  on (c.id=o.id) where o.[Name]=@Table_Name and o.xtype='u' 	
--		and c.[Name] not in (select Fld_Name from #tblExclFld where Tbl_Name=@Table_Name)
--		)
--		order by c.[Name]	
	end /*while (@pos>1)*/
	select * from #tblExclFld
	set @SqlCommand='select * from '+@TblFldList
	print @SqlCommand
	execute sp_executesql @SqlCommand
end
GO
