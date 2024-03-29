
DROP PROCEDURE [Usp_ItBal_ItBalW]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- AUTHOR	  :	
-- CREATE DATE: 
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO UPDATE IT_BAL & IT_BALW TABLES.
-- MODIFIED BY: PRIYANKA B. FOR BUG-31076
-- MODIFY DATE: 06/01/2018
-- REMARK:
-- =============================================

--Birendra : Function has use to update automatic in it_bal and it_balw like  other table updation. 
CREATE procedure [Usp_ItBal_ItBalW]
@Item_temp Varchar(100),@Main_temp varchar(100),@Item_table Varchar(100),@Main_table varchar(100),@mfld varchar(10)
as 
Begin
---------------------------It_BalW----------------------------------------Start
	declare @SqlCommand nvarchar(max),@compid int
	set @compid=isnull((select top 1 compid from vudyog..co_mast where dbname=db_name()),0)

	set @SqlCommand ='Update  a set a.qty=a.qty-b.qty from it_balw a inner join
					(select i.it_code,i.ware_nm,m.[rule],i.entry_ty,i.date,i.qty from '+ltrim(rtrim(@Item_table))+' i  
					 inner join '+@Main_table+' m on
					(i.entry_ty=m.entry_ty and i.tran_cd=m.tran_cd and i.date=m.date) 
					where i.dataimport in (select dataexport1 from '+ltrim(rtrim(@Item_temp))+')) 
					 b on 
					(a.it_code=b.it_code and a.ware_nm=b.ware_nm and a.[rule]=b.[rule]
					and a.entry_ty=b.entry_ty and a.date=b.date)
					'
	execute sp_executesql @SqlCommand

	set @SqlCommand ='Update  a set a.qty=a.qty+b.qty from it_balw a inner join
					(select i.it_code,i.ware_nm,m.[rule],i.entry_ty,i.date,i.qty from '+ltrim(rtrim(@Item_temp))+' i  
					 inner join '+@Main_temp+' m on
					(i.entry_ty=m.entry_ty and i.tran_cd=m.tran_cd and i.date=m.date) 
					) 
					 b on 
					(a.it_code=b.it_code and a.ware_nm=b.ware_nm and a.[rule]=b.[rule]
					and a.entry_ty=b.entry_ty and a.date=b.date)
					'
	execute sp_executesql @SqlCommand

	set @SqlCommand ='insert into it_balw (it_code,ware_nm,[rule],entry_ty,date,qty)
					select i.it_code,i.ware_nm,m.[rule],i.entry_ty,cast(i.date as datetime),sum(cast(rtrim(ltrim(i.qty)) as numeric(20,4)))
					from '+ltrim(rtrim(@Item_temp))+' i inner join '+@Main_temp+' m on
					(i.entry_ty=m.entry_ty and i.oldtran_cd=m.oldtran_cd and i.date=m.date) 
					where ltrim(rtrim(i.it_code))+space(1)+ltrim(rtrim(i.ware_nm))+space(1)+ltrim(rtrim(m.[rule]))+space(1)
						+ltrim(rtrim(i.entry_ty))+space(1)+ltrim(rtrim(i.date)) not in 
					(select ltrim(rtrim(it_code))+space(1)+ltrim(rtrim(ware_nm))+space(1)+ltrim(rtrim([rule]))
					+space(1)+ltrim(rtrim(entry_ty))+space(1)+ltrim(rtrim(convert(varchar(20),date,126))) from it_balw)
					group by i.it_code,i.ware_nm,m.[rule],i.entry_ty,i.date
					'

	execute sp_executesql @SqlCommand



---------------------------It_BalW----------------------------------------End

---------------------------It_Bal----------------------------------------Start
	
	set @SqlCommand ='Update a set a.'+ltrim(rtrim(@mfld))+'=a.'+ltrim(rtrim(@mfld))+'-i.qty from it_bal a inner join
					(select it_code,isnull(sum(qty),0) as qty,compid from '+ltrim(rtrim(@Item_table))+'
						where dataimport in (select dataexport1 from '+ltrim(rtrim(@Item_temp))+')
						 group by it_code,compid) i  on(a.it_code=i.it_code and a.compid=i.compid )
					where a.it_code=i.it_code and a.compid=i.compid
					'

	execute sp_executesql @SqlCommand

	set @SqlCommand ='Update a set a.'+ltrim(rtrim(@mfld))+'=a.'+ltrim(rtrim(@mfld))+'+i.qty from it_bal a inner join
					(select it_code,isnull(sum(cast(rtrim(ltrim(qty)) as numeric(20,4))),0) as qty,compid from '+ltrim(rtrim(@Item_temp))+' group by it_code,compid) i on (a.it_code=i.it_code and a.compid=i.compid )
					where a.it_code=i.it_code and a.compid=i.compid
					'

	execute sp_executesql @SqlCommand

	declare @tmpfld varchar(max),@tmpvalue varchar(max),@tmpnext int,@tmptext varchar(5)
	set @tmpfld=''
--	set @tmpfld_w=''
	select @tmpfld=case when len(ltrim(rtrim(@tmpfld)))>0 then @tmpfld+',' else '' end +[name] from syscolumns where id in (select id from sysobjects where [name]='it_bal' and xtype='U')
	select @tmpvalue=replace(replace(@tmpfld,'it_name','item'),@mfld,'@mfld')
	while 1=1
	begin
		set @tmpnext=patindex('%[a-z0-9][a-z0-9]qty%',@tmpvalue)
		if @tmpnext=0
			break
		select @tmpvalue=stuff(@tmpvalue,@tmpnext,5,'0')
	end 
--select @tmpvalue=replace(replace(@tmpvalue,'qty','0'),'compid',''+@compid+'')
select @tmpvalue=replace(@tmpvalue,'qty','0')


	set @SqlCommand ='insert into it_bal ('+@tmpfld+')
					select '+replace(@tmpvalue,'@mfld','isnull(sum(cast(rtrim(ltrim(qty)) as numeric(20,4))),0) as qty')+'
					from '+ltrim(rtrim(@Item_temp))+'  
					--where it_code+space(1)+compid not in (select rtrim(ltrim(cast(it_code as varchar(20))))+space(1)+rtrim(ltrim(cast(compid as varchar(10)))) from it_bal)  --Commented by Priyanka B on 06012018 for Bug-31076
					where cast(it_code as varchar)+space(1)+cast(compid as varchar) not in (select rtrim(ltrim(cast(it_code as varchar(20))))+space(1)+rtrim(ltrim(cast(compid as varchar(10)))) from it_bal)  --Modified by Priyanka B on 06012018 for Bug-31076
					group by it_code,item,compid
					'
print @SqlCommand

	execute sp_executesql @SqlCommand
---------------------------It_Bal----------------------------------------End
end
GO