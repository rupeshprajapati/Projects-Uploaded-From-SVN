DROP PROCEDURE [inventory_reciept]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [inventory_reciept] @p varchar(2),@sr varchar(2),@ar varchar(2),@op varchar(2),@es varchar(2),
@ir varchar(2),@b  varchar(2),@lr varchar(2),@wipr varchar(2)
as 
declare @test varchar(20)
set @test = @p+@ar
select a.entry_ty,a.[date],b.inv_no,a.item,a.qty,c.rateunit,a.rate,
b.net_amt,b.gro_amt as lmain_gro,a.gro_amt as litem_gro
from litem a,lmain b,it_mast c where a.entry_ty = b.entry_ty and a.date=b.date and a.doc_no = b.doc_no
and a.item = c.it_name and a.entry_ty in (@p,@sr,@ar,@op,@es,@ir,@b,@lr) order by a.[date],a.entry_ty
GO
