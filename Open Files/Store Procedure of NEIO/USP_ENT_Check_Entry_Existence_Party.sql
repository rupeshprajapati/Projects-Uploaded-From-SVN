DROP PROCEDURE [USP_ENT_Check_Entry_Existence_Party]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Procedure [USP_ENT_Check_Entry_Existence_Party]
@Ac_id Numeric(10,0),@sAc_id Numeric(10,0)
As

Declare @table Varchar(10),@Sqlcmd NVarchar(4000),@ans Int,@FldList Varchar(200)
DECLARE @ParmDefinition nvarchar(500)

Select Ac_id,Ac_id as Shipto_id Into #shipto from Shipto where 1=2

set @ans=0

Declare curentry cursor for 
	Select Entry_tbl= Case when bcode_nm<>'' then Bcode_nm else (Case when ext_vou=1 then '' else Entry_ty end) end+'Main'   From Lcode Where Entry_ty in ('PT','ST','BR','CR','E1','S1') 

Open curentry	
Fetch next From curentry Into @table
While @@fetch_Status=0
Begin
	print @table
	Select @FldList=
	 STUFF((SELECT ',' + b.[Name] 
            From Sysobjects a Inner join syscolumns b on (a.id=b.id) Where a.[name]=@table and b.[name] in ('Cons_id','sCons_id')
            FOR XML PATH('')) ,1,1,'') 
            
		set @Sqlcmd='insert Into #shipto ('+replace(replace(@FldList,'sCons_id','Shipto_id'),'Cons_id','Ac_id')+') Select '+@FldList+' From '+@table+' Where Ac_id='+CONVERT(varchar(10),@Ac_id)
		EXEC sp_executesql @Sqlcmd
		print @table
		print @FldList
		
		Select @FldList=
		STUFF((SELECT ',' + b.[Name] 
            From Sysobjects a Inner join syscolumns b on (a.id=b.id) Where a.[name]=@table and b.[name] in ('Ac_id','sac_id')
            FOR XML PATH('')) ,1,1,'') 
	
		set @Sqlcmd='insert Into #shipto ('+replace(@FldList,'sac_id','Shipto_id')+') Select '+@FldList+' From '+@table+' Where Ac_id='+CONVERT(varchar(10),@Ac_id)
		EXEC sp_executesql @Sqlcmd
		
		Update #shipto set Shipto_id=isnull(Shipto_id,0)
		
		if @sAc_id >0
		Begin
			if Exists(Select Top 1 ac_id from #shipto Where Ac_id=@Ac_id and Shipto_Id=@sAc_id)
			Begin	
				set @ans=1
			end
		End
		Else
		Begin
			if Exists(Select Top 1 ac_id from #shipto Where Ac_id=@Ac_id)
			Begin	
				set @ans=1
			end
		End
	if  @ans=1
		break
	Fetch next From curentry Into @table
End
Close curentry
Deallocate curentry

Select ans=@ans
GO
