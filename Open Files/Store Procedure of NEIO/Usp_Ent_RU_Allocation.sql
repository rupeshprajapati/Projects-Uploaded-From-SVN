DROP PROCEDURE [Usp_Ent_RU_Allocation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sachin N. S..
-- Create date: 02/09/2015
-- Description:	This Stored procedure is useful in Returnable Gate Pass Receipt allocation form.
-- Modification Date/By/Reason: 
-- Remark:		
-- =============================================
CREATE procedure [Usp_Ent_RU_Allocation]
@party_nm varchar(100),@entry_ty varchar(2),@tran_cd int, @itserial varchar(5),@dt smalldatetime,@rule varchar(20),@it_code int
as
declare @sqlcommand nvarchar(4000),@bcode_nm varchar(2)

select @bcode_nm=(case when ext_vou=1 then bcode_nm else entry_ty end) from lcode where entry_ty=@entry_ty

select lientry_ty,li_itser,li_tran_cd,qty_used=sum(qty_used),wastage=sum(wastage),procwaste=sum(procwaste), cast('' as varchar(20)) as [rule]
into #rmdet
from irrmdet 
where 1=2
group by lientry_ty,li_itser,li_tran_cd

select b.pinvno as u_pinvno,b.pinvdt as u_pinvdt,a.inv_no,a.date,item=i1.it_name,i1.it_code,a.qty,qty_used=a.qty,aqty=a.qty,adjqty=a.qty,
	wastage=a.qty,procwaste=a.qty,days=999,days180=999,a.entry_ty,a.tran_cd,a.itserial,a.doc_no
into #lj
from iiitem a
inner join iimain b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)
inner join it_mast i1 on (a.it_code=i1.it_code)
where 1=2

if charindex('''',@party_nm)>0
Begin
	set @party_nm=replace(@party_nm,'''','''''')
end

set @sqlcommand='insert into #rmdet select lientry_ty,li_itser,li_tran_cd,qty_used=sum(qty_used),wastage=sum(wastage),procwaste=sum(procwaste),b.[rule] '
set @sqlcommand=rtrim(@sqlcommand)+' '+' from '+(case when (@bcode_nm='IR') then 'IR' else 'II' end)+'rmdet a '
set @sqlcommand=rtrim(@sqlcommand)+' '+' inner join '+(case when (@bcode_nm='IR') then 'IR' else 'II' end)+'main b on a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd '
set @sqlcommand=rtrim(@sqlcommand)+' '+' where not (a.entry_ty='+char(39)+@entry_ty+char(39)+' and a.tran_cd='+ltrim( rtrim(cast(@tran_cd as varchar)) )+') and b.[rule]='+char(39)+rtrim(@rule)+char(39) 
set @sqlcommand=rtrim(@sqlcommand)+' '+' and a.It_code='+cast(@It_Code as varchar)
set @sqlcommand=rtrim(@sqlcommand)+' '+' group by lientry_ty,li_itser,li_tran_cd,b.[rule]'
print @sqlcommand
execute sp_executesql @sqlcommand

set @sqlcommand='insert into #lj select a.pinvno,a.pinvdt,c.inv_no,c.date,item=i1.it_name,i1.it_code,a.qty,qty_used=0,aqty=a.qty,adjqty=0,wastage=0,procwaste=0'		
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,days=(  case when (datediff(day,a.date,'+char(39)+cast(@dt as varchar)+char(39)+'))<=180 then (datediff(day,a.date,'+char(39)+cast(@dt as varchar)+char(39)+')) else 0 end  )'
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,days180=(  case when (datediff(day,a.date,'+char(39)+cast(@dt as varchar)+char(39)+'))>180 then (datediff(day,a.date,'+char(39)+cast(@dt as varchar)+char(39)+')) else 0 end  )'
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,a.entry_ty,a.tran_cd,a.itserial,a.doc_no'
set @sqlcommand=rtrim(@sqlcommand)+' '+' from '+(case when (@bcode_nm='IR') then 'II' else 'IR' end)+'item a'
set @sqlcommand=rtrim(@sqlcommand)+' '+' inner join '+(case when (@bcode_nm='IR') then 'II' else 'IR' end)+'main c on (a.entry_ty=c.entry_ty and a.tran_cd=c.tran_cd)'
set @sqlcommand=rtrim(@sqlcommand)+' '+' inner join it_mast i1 on (a.it_code=i1.it_code)'
set @sqlcommand=rtrim(@sqlcommand)+' '+' inner join ac_mast  on (ac_mast.ac_id=c.ac_id)'
set @sqlcommand=rtrim(@sqlcommand)+' '+' where a.entry_ty='+char(39)+(case when (@bcode_nm='IR') then 'RU' else 'RE' end)+char(39)
set @sqlcommand=rtrim(@sqlcommand)+' '+' and ac_mast.ac_name='+char(39)+rtrim(@party_nm)+char(39)
set @sqlcommand=rtrim(@sqlcommand)+' '+' and a.date<='+char(39)+cast(@dt as varchar)+char(39)
set @sqlcommand=rtrim(@sqlcommand)+' '+' and c.[rule]='+char(39)+rtrim(@rule)+char(39)
set @sqlcommand=rtrim(@sqlcommand)+' '+' and a.It_code='+cast(@It_Code as varchar)
print @sqlcommand
execute sp_executesql @sqlcommand

--SELECT * FROM #LJ

update a set a.qty_used=b.qty_used+b.wastage+b.procwaste,a.aqty=a.aqty-(b.qty_used+b.wastage+b.procwaste),adjqty=0,wastage=0,procwaste=0	
from #lj a 
inner join #rmdet b on (a.entry_ty=b.lientry_ty and a.tran_cd=b.li_tran_cd and a.itserial=b.li_itser)

delete from #lj where aqty=0
select * from #lj
GO
