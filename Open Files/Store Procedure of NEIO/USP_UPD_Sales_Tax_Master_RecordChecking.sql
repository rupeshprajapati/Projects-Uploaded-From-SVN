DROP PROCEDURE [USP_UPD_Sales_Tax_Master_RecordChecking]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 16/05/2007
-- Description:	This is useful to add records in Sales Tax (Stax_mas Table) as per Taxes in Transaction tables.
-- Modified By: Ruepesh Prajapati
-- Modify date: 28/01/2008
-- Remark:
-- =============================================
create   PROCEDURE [USP_UPD_Sales_Tax_Master_RecordChecking] 
AS
begin
	declare @name varchar(30),@sqlcommand nvarchar(1000),@tax_name varchar(50),@entry_ty varchar(2)
	select entry_ty,tax_name into #taxlist from stmain where 1=2  
	select * into #stm1 from stax_mas
	select * into #stm2 from stax_mas  where 1=2
	
	delete from stax_mas
	
	declare cur_tbllist cursor for select [name] from sysobjects where id in 
	(select id from syscolumns where [name]='tax_name') and xtype='U' and ([name] like '__Main' or [name] like '__Item')
	open cur_tbllist 
	fetch next from cur_tbllist into @name
	while(@@fetch_status=0)
	begin
		
		set @sqlcommand='insert into #taxlist (entry_ty,tax_name) select distinct entry_ty,tax_name from '+@name +' where tax_name<>'''' and entry_ty<>'''''
		print @sqlcommand
		execute sp_executesql @sqlcommand
		--select @name,* from #taxlist

		fetch next from cur_tbllist into @name
	end
	close cur_tbllist
	deallocate cur_tbllist
	--select 'a','b',* from #taxlist
	
	--select distinct 'a','b','c',entry_ty,tax_name from #taxlist order by entry_ty

	declare cur_stm cursor for select distinct entry_ty,tax_name from #taxlist order by entry_ty
	open cur_stm 
	fetch next from cur_stm into @entry_ty,@tax_name
	while(@@fetch_status=0)
	begin
		print @entry_ty+'--'+@tax_name
		delete from #stm2
		--select distinct * from #stm1 where tax_name=@tax_name
		insert into #stm2 select distinct * from #stm1 where tax_name=@tax_name
		
		update #stm2 set entry_ty=@entry_ty
		
		insert into stax_mas select * from  #stm2
		
		fetch next from cur_stm into @entry_ty,@tax_name
	end
	close cur_stm
	deallocate cur_stm

	--select * from #stm1
	
	
	delete from #stm2
	insert into #stm2 select * from #stm1 where tax_name not in (select distinct tax_name from stax_mas)
	update #stm2 set entry_ty='ST'
	insert into stax_mas select * from  #stm2

	select * from stax_mas
	--delete from stax_mas
	--select distinct entry_ty,tax_name from 
end
GO
