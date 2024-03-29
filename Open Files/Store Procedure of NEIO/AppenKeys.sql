DROP PROCEDURE [AppenKeys]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  procedure [AppenKeys] 
@type varchar(2)
As
declare @typ varchar(2),@dbname varchar(20),@pkTable varchar(30),@pkColumn Varchar(30),@fkColumn varchar(30),@fkTable varchar(30),@pkName varchar(50),@fkName varchar(50),@cKeycol1 varchar(20),@tname varchar(20),@indexName varchar(50)
declare test1 cursor  for  select name from sysobjects where xtype='U' 
open test1
fetch next from test1 into @tName
While @@fetch_Status=0
Begin
if @type = 'P'
    Begin
	set @typ='P'
	select TABLE_CATALOG	= db_name(),
		TABLE_SCHEMA	= user_name(o.uid),
		TABLE_NAME		= o.name,	
		COLUMN_NAME		= c.name,
		PK_NAME			= i.name
		into #pKey from	sysindexes i, syscolumns c, sysobjects o, syscolumns c1
		where	o.type in ('U')
		and 	o.name =@tName
		and 	o.id = c.id
		and 	o.id = i.id
		and 	(i.status & 0x800) = 0x800
		and 	c.name = index_col (user_name(o.uid)+'.'+o.name, i.indid, c1.colid)
		and 	c1.id = c.id
		and 	c1.colid <= i.keycnt	/* create rows from 1 to keycnt */
		and	permissions(o.id) <> 0
	
		declare test cursor  for select TABLE_CATALOG,TABLE_NAME,COLUMN_NAME from #pkey
		open test
		fetch next from test into @dbname ,@pkTable ,@cKeycol1
		While @@fetch_Status=0
		begin
		    if not exists(select type,dbname,pkTable,keycol1 from relation where type=@typ and dbname=@dbname and pkTable=@pkTable and keycol1=@ckeycol1)
		    insert into relation(type,dbname,pkTable,keycol1)values(@typ ,@dbname ,@pkTable ,@cKeycol1)
		    fetch next from test into @dbname ,@pkTable ,@cKeycol1
		end
		close test
		deallocate test
		drop table #pKey
             end
else
if @type='F'
     ---For inserting foregin keys
      begin 
	set @typ='F'
	select
	PK_TABLE_CATALOG	= db_name(r.rkeydbid),
	PK_TABLE_NAME 		= o1.name,
	PK_COLUMN_NAME 		= c1.name,
	FK_TABLE_NAME 		= o2.name,
	FK_COLUMN_NAME 		= c2.name,
	PK_NAME				= i.name,
	FK_NAME				= object_name(r.constid)
	into #fKey from
	sysobjects o1, sysobjects o2,
	syscolumns c1, syscolumns c2,
	sysreferences r, sysindexes i
	where	o1.name = @tName
	and	o1.id = r.rkeyid
	and	o1.id = c1.id
	and	c1.colid = r.rkey1
	and r.fkeyid = o2.id
	and	o2.id = c2.id
	and	c2.colid = r.fkey1
	and permissions(o1.id) <> 0
	and permissions(o2.id) <> 0
	and i.id = r.rkeyid
	and i.indid = r.rkeyindid

	declare test cursor  for select PK_TABLE_CATALOG,PK_TABLE_NAME,PK_COLUMN_NAME,FK_TABLE_NAME,FK_COLUMN_NAME,PK_NAME,FK_NAME from #fkey
	open test
	fetch next from test into @dbname,@pkTable,@pkColumn,@fkTable,@fkColumn,@pkName,@fkName
	While @@fetch_Status=0
	 begin
	    if not exists(select type,dbname,pkTable,pkcolumn,fktable,fkcolumn from relation where type=@typ and dbname=@dbname and pkTable=@pkTable and pkcolumn=@pkcolumn and fktable=@fkTable and fkcolumn=@fkcolumn and pkname=@pkName and fkName=@fkName)
	    insert into relation(type,dbname,pkTable,PkColumn,fkTable,FkColumn,pkName,fkName)values(@typ,@dbname,@pkTable,@pkColumn,@fkTable,@fkColumn,@pkname,@fkName)
	    fetch next from test into @dbname,@pkTable,@pkColumn,@fkTable,@fkColumn,@pkName,@fkName
	end
	close test
	deallocate test
	drop table #fKey
     end
else 
 --For inserting Indexes
     begin
	set @typ='I'
	select	TABLE_CATALOG		= db_name(),
		TABLE_NAME		= o.name,
		INDEX_NAME		= x.name,
		COLUMN_NAME		= c.name
	into #index from sysobjects o, sysindexes x, syscolumns c, sysindexkeys xk
	where	o.type in ('U')
	and 	o.name = @tName
	and	x.id = o.id
	and	o.id = c.id
	and	o.id = xk.id
	and	x.indid = xk.indid
	and	c.colid = xk.colid
	and	xk.keyno <= x.keycnt
	and	permissions(o.id, c.name) <> 0
	and     (x.status&32) = 0  -- No hypothetical indexes
	declare test cursor  for select TABLE_CATALOG,TABLE_NAME,INDEX_NAME,COLUMN_NAME from #index
	open test
	fetch next from test into @dbname ,@pkTable ,@indexName,@pkColumn
	While @@fetch_Status=0
	begin
	    if not exists(select type,dbname,pkTable,indexname from relation where type=@typ and dbname=@dbname and pkTable=@pkTable and indexName=@indexname)
	    insert into relation(type,dbname,pkTable,Indexname)values(@typ ,@dbname ,@pkTable ,@IndexName)
	    fetch next from test into @dbname ,@pkTable ,@indexName,@pkColumn
	end
	close test
	deallocate test
	drop table #Index
      End
  fetch next from test1 into @tName
 End
 close test1
 deallocate test1
GO
