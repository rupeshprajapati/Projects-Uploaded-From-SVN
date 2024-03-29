DROP PROCEDURE [USP_UPDATE_REALL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [USP_UPDATE_REALL]
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 03/01/2009
-- Description:	This Stored procedure is useful tp Update re_all in acdet table from mall table.
-- Modify date: 
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
as
begin
	declare @entry_ty varchar(2),@tran_cd int,@acserial varchar(5)
	declare @entry_all varchar(2),@main_tran int,@acseri_all varchar(5),@new_all numeric(17,2),@bhent varchar(2),@name varchar(50)
	declare @sqlcommand nvarchar(1000)
	-->re_all=0
	print 're_all=0'
	declare cur_table cursor for select [Name] from sysobjects where [name] like  '__ACDET' and xtype='U' and id in (select id from syscolumns where [name]='re_all')
	open cur_table
	fetch next  from cur_table into @name
	while(@@fetch_status=0)
	begin
		set @sqlcommand='update '+@name+' set re_all=0'
		print @sqlcommand
		execute sp_executesql @sqlcommand
		fetch next  from cur_table into @name
	end
	close cur_table
	deallocate cur_table
	--<--re_all=0

	-->Update Re_all for main Transaction e.g. BP from BPMALL
	set @sqlcommand=0
	print '---------------------------------------------------------------'
	print '--Update Re_all for main Transaction e.g. BP from BPMALL--'
	declare cur_main cursor for 
	select a.entry_ty,a.tran_cd,a.acserial,new_all=sum(a.new_all)
	,bhent=(case when b.ext_vou=1 then b.bcode_nm else b.entry_ty end) 
	from mainall_vw a 
	inner join lcode b on (a.entry_ty=b.entry_ty)
	group by a.entry_ty,a.tran_cd,a.acserial,b.ext_vou,b.bcode_nm,b.entry_ty
	open cur_main
	fetch next from cur_main into @entry_ty,@tran_cd,@acserial,@new_all,@bhent	
	while(@@fetch_status=0)
	begin
		--print @entry_ty+cast(@tran_cd as varchar)+@acserial
		set @sqlcommand='update '+@bhent+'acdet set re_all=re_all+'+cast(@new_all as varchar(19))+' where entry_ty='+char(39)+@entry_ty+char(39)+' and tran_cd='+cast(@tran_cd as varchar(5))+' and acserial='++char(39)+@acserial+char(39) --+' WHERE RE_ALL=0
		print @sqlcommand
		execute sp_executesql @sqlcommand
		fetch next from cur_main into @entry_ty,@tran_cd,@acserial,@new_all,@bhent	
	end
	close cur_main
	deallocate cur_main
	--<--Update Re_all for main Transaction e.g. BP from BPMALL
	
	-->Update Re_all for allocate Transaction e.g. ST from BPMALL
	set @sqlcommand=0
	print '---------------------------------------------------------------'
	print '--Update Re_all for allocate Transaction e.g. ST from BPMALL--'
	declare cur_mall cursor for 
	select a.entry_all,a.main_tran,a.acseri_all,new_all=sum(a.new_all)
	,bhent=(case when b.ext_vou=1 then b.bcode_nm else b.entry_ty end) 
	from mainall_vw a 
	inner join lcode b on (a.entry_all=b.entry_ty)
	group by a.entry_all,a.main_tran,a.acseri_all,b.ext_vou,b.bcode_nm,b.entry_ty
	open cur_mall
	fetch next from cur_mall into @entry_all,@main_tran,@acseri_all,@new_all,@bhent	
	while(@@fetch_status=0)
	begin
		set @sqlcommand='update '+@bhent+'acdet set re_all=re_all+'+cast(@new_all as varchar(19))+' where entry_ty='+char(39)+@entry_all+char(39)+' and tran_cd='+cast(@main_tran as varchar(5))+' and acserial='++char(39)+@acseri_all+char(39) --+' WHERE RE_ALL=0
		print @sqlcommand
		execute sp_executesql @sqlcommand
		fetch next from cur_mall into @entry_all,@main_tran,@acseri_all,@new_all,@bhent	
	end
	close cur_mall
	deallocate cur_mall
	--<--Update Re_all for allocate Transaction e.g. ST from BPMALL
end
GO
