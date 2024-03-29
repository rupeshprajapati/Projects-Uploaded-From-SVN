DROP PROCEDURE [Drop_Columns]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Drop_Columns]   
@tblnm as varchar(100),   
@Column varchar(1000)  
as  
declare @fldnm as  varchar (100)  
set @fldnm=@Column  
print @fldnm  
  
declare @name varchar(30),@sqlcommand nvarchar(1000),@fld_exists bit,@id int  
declare cur_name cursor for select [name],id from sysobjects where [type]='U' and [name] like @tblnm --'%acdet'  
open cur_name  
fetch next from cur_name into @name,@id  
while (@@fetch_status=0)  
begin  
 set @sqlcommand=' '  
 if exists (select * from syscolumns where id=@id and [name]=@fldnm)  
 begin  
  select consnm=name Into #tmpcons from sysobjects where id in ( select syscolumns.cdefault from syscolumns  
  inner join sysobjects on (syscolumns.id=sysobjects.id)  
  where syscolumns.name=@Column and sysobjects.name=@name)  
    
  Declare @reccnt int,@consname varchar(500)  
  select @reccnt=0  
  Select @reccnt=count(*) from #tmpcons   
    
  if @reccnt>0  
  Begin  
   Declare conscur cursor for   
    Select [consnm] from #tmpcons  
      
   Open conscur   
     
   Fetch Next from conscur Into @consname  
   While @@FETCH_STATUS=0  
   Begin  
    set @sqlcommand='alter table '+@name+' Drop Constraint '+@consname  
    print @sqlcommand  
    execute sp_executesql @sqlcommand  
    Fetch Next from conscur Into @consname  
   End  
   Close conscur   
   Deallocate conscur   
  end  
    
  set @sqlcommand='alter table '+@name+' Drop column '+@Column  
  print @sqlcommand  
  execute sp_executesql @sqlcommand  
  Drop table #tmpcons
 end  
 fetch next from cur_name into @name,@id  
end  
close cur_name  
deallocate cur_name
GO
