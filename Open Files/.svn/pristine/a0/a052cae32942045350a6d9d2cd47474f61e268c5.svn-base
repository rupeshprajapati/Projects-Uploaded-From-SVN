IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='USP_GetLot_Details')
BEGIN
	DROP PROCEDURE USP_GetLot_Details
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[USP_GetLot_Details]
@Entryty varchar(2)
,@Processhouse varchar(50)
,@lotno varchar(10)
,@Item varchar(100)
,@curqty numeric(16,4)
As
declare @sqlcmd nvarchar(max)
if @Entryty= 'RD' or @Entryty= 'W1'
Begin
	select distinct a.entry_ty,a.tran_cd,a.flotno,a.party_nm,a.qty,cast(0.00 as decimal(16,4)) as allocqty,a.qty as balqty
	into #a from iiitem a where 1=2

	select a.qty as lrqty,a.flotno,a.party_nm
	into #b from iritem a where 1=2

	set @sqlcmd=''
	set @sqlcmd= 'Insert into #a 
	select distinct a.entry_ty,a.tran_cd,a.flotno,a.party_nm,sum(a.qty),cast(0.00 as decimal(16,4)) as allocqty,sum(a.qty) as balqty
	from iiitem a where entry_ty=''ID'' and a.party_nm='''+rtrim(@processhouse)+''''
	if @lotno='' set @sqlcmd= @sqlcmd + ' and a.flotno <> '''''
	else set @sqlcmd = @sqlcmd + ' and a.flotno='''+rtrim(@lotno)+''''
	set @sqlcmd= @sqlcmd + ' group by a.entry_ty,a.tran_cd,a.flotno,a.party_nm'
	print @sqlcmd
	execute sp_executesql @sqlcmd
	
	set @sqlcmd= 'Insert into #b 
	select lrqty = sum(lrqty),flotno,party_nm From (
	select sum(a.qty) as lrqty,a.flotno,a.party_nm
	from iritem a 
	where a.entry_ty=''RD'' and a.party_nm='''+rtrim(@processhouse) +''''
	if @lotno='' set @sqlcmd= @sqlcmd + ' and a.flotno <> '''''
	else set @sqlcmd = @sqlcmd + ' and a.flotno='''+rtrim(@lotno)+''''
	set @sqlcmd = @sqlcmd + ' group by a.flotno,a.party_nm'
	set @sqlcmd = @sqlcmd + ' union all'
	set @sqlcmd = @sqlcmd + ' select sum(a.qty) as lrqty,a.flotno,a.party_nm 
	from item a 
	where a.entry_ty=''W1'' 
	and a.party_nm='''+rtrim(@processhouse) +'''
	and (a.entry_ty+rtrim(ltrim(str(a.tran_cd)))+a.itserial) not in (select (rentry_ty+rtrim(ltrim(str(itref_tran)))+ritserial) from iritref i)'
	if @lotno='' set @sqlcmd= @sqlcmd + ' and a.flotno <> '''''
	else set @sqlcmd = @sqlcmd + ' and a.flotno='''+rtrim(@lotno)+''''
	set @sqlcmd = @sqlcmd + ' group by a.flotno,a.party_nm'
	set @sqlcmd = @sqlcmd + ' )aa group by flotno,party_nm'
	print @sqlcmd
	execute sp_executesql @sqlcmd
	
	--select * from #a
	--select * from #b
	Update #a set #a.allocqty = #b.lrqty from #a inner join #b on (#a.party_nm=#b.party_nm and #a.flotno=#b.flotno)
	
	Update #a set #a.balqty = (#a.qty - #a.allocqty) from #a inner join #b on (#a.party_nm=#b.party_nm and #a.flotno=#b.flotno)
	
	select flotno,qty,allocqty,balqty
	from #a
	where balqty > 0
	
	drop table #a
	drop table #b

end
else 
Begin
	select distinct a.entry_ty,a.tran_cd,a.flotno,a.qty,cast(0.00 as decimal(16,4)) as allocqty,a.qty as balqty,a.item,a.fshade,a.fgrade,a.fdesign
	into #c from ipitem a where 1=2

	select a.qty as lrqty,a.flotno,a.item,a.fshade,a.fgrade,a.fdesign
	into #d from opitem a where 1=2

	set @sqlcmd=''
	set @sqlcmd= 'Insert into #c select distinct a.entry_ty,a.tran_cd,a.flotno,sum(a.qty),cast(0.00 as decimal(16,4)) as allocqty,sum(a.qty) as balqty
	,a.item,a.fshade,a.fgrade,a.fdesign
	from ipitem a where entry_ty=''IC'' and a.party_nm=''Use for Production'''
	if @lotno='' set @sqlcmd= @sqlcmd + ' and a.flotno <> '''''
	else set @sqlcmd = @sqlcmd + ' and a.flotno='''+rtrim(@lotno)+''''
	if @Item='' set @sqlcmd= @sqlcmd + ' and a.Item <> '''''
	else set @sqlcmd = @sqlcmd + ' and a.Item='''+rtrim(@Item)+''''
	set @sqlcmd= @sqlcmd + ' group by a.entry_ty,a.tran_cd,a.flotno,a.item,a.fshade,a.fgrade,a.fdesign'
	print @sqlcmd
	execute sp_executesql @sqlcmd
	
	set @sqlcmd= 'Insert into #d 
	select lrqty = sum(lrqty),flotno,item,fshade,fgrade,fdesign
	from (
	select sum(a.qty) as lrqty,a.flotno,a.item,a.fshade,a.fgrade,a.fdesign
	from opitem a 
	where a.entry_ty=''OC''' --and a.party_nm=''Use for Production'''
	if @lotno='' set @sqlcmd= @sqlcmd + ' and a.flotno <> '''''
	else set @sqlcmd = @sqlcmd + ' and a.flotno='''+rtrim(@lotno)+''''
	if @Item='' set @sqlcmd= @sqlcmd + ' and a.Item <> '''''
	else set @sqlcmd = @sqlcmd + ' and a.Item='''+rtrim(@Item)+''''
	set @sqlcmd = @sqlcmd + ' group by a.flotno,a.item,a.fshade,a.fgrade,a.fdesign'
	set @sqlcmd = @sqlcmd + ' union all
	select sum(a.qty) as lrqty,a.flotno,a.item,a.fshade,a.fgrade,a.fdesign
	from item a
	where a.entry_ty=''W2'' and a.party_nm=''Use for Production'' 
	and (a.entry_ty+rtrim(ltrim(str(a.tran_cd)))+a.itserial) not in (select (rentry_ty+rtrim(ltrim(str(itref_tran)))+ritserial) from opitref i)'
	if @lotno='' set @sqlcmd= @sqlcmd + ' and a.flotno <> '''''
	else set @sqlcmd = @sqlcmd + ' and a.flotno='''+rtrim(@lotno)+''''
	if @Item='' set @sqlcmd= @sqlcmd + ' and a.Item <> '''''
	else set @sqlcmd = @sqlcmd + ' and a.Item='''+rtrim(@Item)+''''
	set @sqlcmd= @sqlcmd + ' group by a.flotno,a.item,a.fshade,a.fgrade,a.fdesign	'
	set @sqlcmd= @sqlcmd + ' )aa group by flotno,item,fshade,fgrade,fdesign	'
	print @sqlcmd
	execute sp_executesql @sqlcmd
	
	--select * from #c
	--select * from #d
	--Update #c set #c.allocqty = #d.lrqty+isnull(@curqty,0.00) from #c inner join #d on (#c.entry_ty=#d.ientry_ty and #c.tran_cd=#d.itran_cd and #c.item=#d.item)-- and #a.itserial=#b.li_itser)
	Update #c set #c.allocqty = #d.lrqty from #c inner join #d on (#c.item=#d.item and #c.fshade=#d.fshade and #c.fgrade=#d.fgrade and #c.fdesign=#d.fdesign)
	
	Update #c set #c.balqty = (#c.qty - #c.allocqty) from #c inner join #d on (#c.item=#d.item and #c.fshade=#d.fshade and #c.fgrade=#d.fgrade and #c.fdesign=#d.fdesign)
	
	/*Update #c set #c.allocqty = #d.lrqty from #c inner join #d on (#c.entry_ty=#d.ientry_ty and #c.tran_cd=#d.itran_cd and #c.item=#d.item)-- and #a.itserial=#b.li_itser)
	
	Update #c set #c.balqty = (#c.qty - #c.allocqty) from #c inner join #d on (#c.entry_ty=#d.ientry_ty and #c.tran_cd=#d.itran_cd and #c.item=#d.item)-- and #a.itserial=#b.li_itser)
	*/
	select flotno,qty,allocqty,balqty,item,fshade,fgrade,fdesign
	from #c
	where balqty > 0 

	drop table #c
	drop table #d
end


