DROP PROCEDURE [USP_ENT_PARTYONHOLD]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 28/04/2009
-- Description:	This Stored procedure is useful in PartyonHold Module. [uepartyonhold.app]
-- Modify date:By:Reason: 02/02/2010 Rupesh Prajapati. for Query L2S-110
-- Modify date:By:Reason: 05/07/2010 Shrikant S. for TKT-2780
-- Remark:
-- =============================================
CREATE procedure [USP_ENT_PARTYONHOLD]
@ac_name varchar(100),@date smalldatetime,@opt varchar(10)
as
begin
	select b.ac_id,a.ac_name,holdby=isnull(b.holdby,''),hresn=isnull(b.hresn,''),holddt=isnull(b.holddt,''),reldt=isnull(b.reldt,''),relby=isnull(b.relby,''),rresn=isnull(b.rresn,'') ,[username]=isnull(b.[username],''),sysdate=isnull(b.sysdate,''),editby=isnull(b.editby,''),editdate=isnull(b.editdate,'')  ,tran_cd,delrec=cast(0 as int),fdate=cast('Feb  1 2010 12:00AM' as smalldatetime)
	into #partyonhold
	from partyonhold  b  inner join  ac_mast a on (a.ac_id=b.ac_id)  
	where 1=2
	

	declare @mCondn nvarchar(100)
	declare @sqlcommand nvarchar(4000)
	
	set @sqlcommand='insert into #partyonhold (ac_id,ac_name,holdby,hresn,holddt,reldt,relby,rresn,[username],sysdate,editby,editdate,tran_cd,delrec,fdate)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' select b.ac_id,a.ac_name'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' ,holdby=isnull(b.holdby,''''),hresn=isnull(b.hresn,''''),holddt=isnull(b.holddt,'''')'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' ,reldt=isnull(b.reldt,''''),relby=isnull(b.relby,''''),rresn=isnull(b.rresn,'''')'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' ,[username]=isnull(b.[username],''''),sysdate=isnull(b.sysdate,''''),editby=isnull(b.editby,''''),editdate=isnull(b.editdate,'''')'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' ,tran_cd,delrec=cast(0 as int),fdate=cast('+char(39)+cast(@date as varchar)+char(39)+' as smalldatetime)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' from partyonhold  b'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' inner join  ac_mast a on (a.ac_id=b.ac_id)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' where isnull(a.ac_name,'''')<>'''''
	set @sqlcommand=rtrim(@sqlcommand)+' '+' and b.holddt>='+char(39)+cast(@date as varchar)+char(39)
	
	if (isnull(@ac_name,'')<>'')
	begin
	--	set @sqlcommand=rtrim(@sqlcommand)+' '+' and a.ac_name='''+rtrim(@ac_name)+''''		--Commented by Shrikant S. on 05/07/2010 for TKT-2780
		set @sqlcommand=rtrim(@sqlcommand)+' '+' and a.ac_name='''+Case when charindex('''',rtrim(@ac_name))>0 then replace(@ac_name,'''','''''')else rtrim(@ac_name) end+''''	--Changed by Shrikant S. on 05/07/2010 for TKT-2780
	end 

	if (upper(isnull(@opt,'ALL'))='HOLD')
	begin
		print ''
		--set @sqlcommand=rtrim(@sqlcommand)+' '+' and ('+char(39)+cast(getdate() as varchar)+char(39)+'<b.reldt or year(isnull(b.reldt,''''))<=1900 )'
		--set @sqlcommand=rtrim(@sqlcommand)+' '+' and not (b.reldt>='+char(39)+cast(getdate() as varchar)+char(39)+')'
		set @sqlcommand=rtrim(@sqlcommand)+' '+' and ( '+' b.reldt>'+char(39)+cast(getdate() as varchar)+char(39)+' or year(b.reldt)<=1900 '+' )'
	end 
	if (upper(isnull(@opt,'ALL'))='RELEASED')
	begin
		--set @sqlcommand=rtrim(@sqlcommand)+' '+' and b.reldt>='+char(39)+cast(getdate() as varchar)+char(39)
		set @sqlcommand=rtrim(@sqlcommand)+' '+' and ( '+' b.reldt<='+char(39)+cast(getdate() as varchar)+char(39)+' and year(b.reldt)>1900 '+' )'
	end 

	
	if (upper(isnull(@opt,'ALL'))='BLANK')
	begin
		--set @sqlcommand=rtrim(@sqlcommand)+' '+' and b.reldt<'+char(39)+cast(@date as varchar)+char(39)
		set @sqlcommand=rtrim(@sqlcommand)+' '+' and 1=2'
	end 

	set @sqlcommand=rtrim(@sqlcommand)+' '+' order by a.ac_name'
	
	set @sqlcommand=rtrim(@sqlcommand)+' '+''
	
	print @sqlcommand
	execute sp_executesql @sqlcommand
	select * from #partyonhold
end

--declare @date smalldatetime
--set @date='09/04/2009'
--set dateformat dmy  execute usp_ent_partyonhold '',@date,'BLANK'
GO
