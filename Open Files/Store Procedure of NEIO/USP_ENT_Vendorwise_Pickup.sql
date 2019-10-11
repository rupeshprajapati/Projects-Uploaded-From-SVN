If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_ENT_Vendorwise_Pickup')
Begin
	Drop Procedure USP_ENT_Vendorwise_Pickup
End
GO

CREATE procedure USP_ENT_Vendorwise_Pickup
(
	@paraEntry_Ty Varchar(2),
	@paraTran_Cd Int,
	@paraItSerial as Varchar(5)
)
As
Begin
declare @autotranon varchar(100),@SQLStr nvarchar(max),@mEntry varchar(2)
DECLARE @Select as Bit,@ParmDefinition nvarchar(500)
set @select=0
	Select @autotranon=(case when autotranon<>'' then 'm.'+autotranon else '' end),@mEntry=mEntry from (
	Select autotranon=(select replace(ltrim(rtrim(autotranon)),',',',m.') from lcode where entry_ty=@paraEntry_Ty)
	,mEntry=case when Bcode_nm<>'' then Bcode_nm else (case when ext_vou=1 then '' else entry_ty end) end 
	From Lcode a where entry_ty=(select iautotran from lcode b where entry_ty=@paraEntry_Ty)
	) aa

	SET @ParmDefinition = N'@Select Bit,@paraEntry_Ty Varchar(2),@paraTran_Cd Int'

	set @SQLStr = 'SELECT * 
	FROM (
	select @Select as lSelect,m.party_nm as ac_name,r.entry_ty,r.tran_cd,r.itserial,i.it_code,i.qty,i.rate'+case when @autotranon<>'' then ','+@autotranon else '' end+' 
	from '+@mEntry+'MAIN m inner join '+@mEntry+'ITEM i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd) inner join autotranref r on (r.rentry_ty=i.entry_ty and r.rtran_cd=i.tran_cd and r.ritserial=i.itserial)
	where r.entry_ty='+char(39)+@paraEntry_Ty+char(39)+' and r.tran_cd='+ltrim(rtrim(str(@paraTran_Cd)))+' and r.itserial='+char(39)+@paraItSerial+char(39)
	+') venddts'
	print @SQLStr
	EXECUTE sp_executesql @SQLStr , @ParmDefinition,@Select = @Select,	@paraTran_Cd = @paraTran_Cd,@paraEntry_Ty = @paraEntry_Ty
End
go

--Execute USP_ENT_Vendorwise_Pickup 'Q1',50,'00001'--,'PQ',1,'00001'
go

