DROP PROCEDURE [Add_Multiple_Columns]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 26/05/2011
-- Description:	This Stored procedure is useful to Add Multiple Columns in Single Line Command
-- Modify By/date/Reason: 
-- Remark:
-- =============================================
CREATE procedure [Add_Multiple_Columns] 
--@tblnm as varchar(10),
@tblnm as varchar(100), --Changed by Ajay Jaiswal on 03/04/2010
@fld_list varchar(1000)
as

declare @fldnm as  varchar (100)
Declare @a bit,@pos int,@vfld_nm varchar(100)
set @a=1
while (@a=1)
begin
	set @pos=0
	set @vfld_nm=''
	set @pos=charindex(';',@fld_list,1)		
--	print @pos
	if @pos<>0
	begin
		set @vfld_nm=substring(@fld_list,1,@pos-1)
		set @fld_list=substring(@fld_list,@pos+1,len(@fld_list)-(@pos) )
	end
	else
	begin
		set @vfld_nm=@fld_list
	end
	--print '1 '+@vfld_nm
	
	set @fldnm=substring(@vfld_nm,1,CHARINDEX(space(1), rtrim(@vfld_nm),1))	
	print @fldnm
	declare @name varchar(30),@sqlcommand nvarchar(1000),@fld_exists bit,@id int
	declare cur_name cursor for select [name],id from sysobjects where [type]='U' and [name] like @tblnm --'%acdet'
	open cur_name
	fetch next from cur_name into @name,@id
	--select [name],id from sysobjects where [type]='U' and [name] like rtrim(@tblnm) --'%acdet'
	--print '2 '+@tblnm
	while (@@fetch_status=0)
	begin
		--print '3 '
		set @sqlcommand=' '
		if not exists (select * from syscolumns where id=@id and [name]=@fldnm)
		begin
			set @sqlcommand='alter table '+@name+' add '+@vfld_nm
			print @sqlcommand
			execute sp_executesql @sqlcommand
		end
		fetch next from cur_name into @name,@id
	end
	close cur_name
	deallocate cur_name
	if @pos=0
	begin
		set @a=0
	end 
end
GO
