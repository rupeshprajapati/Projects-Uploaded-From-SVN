DROP PROCEDURE [Usp_Outward_Discount_charges]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [Usp_Outward_Discount_charges]
as 
begin
select  d.tran_cd ,d.entry_ty ,d.itserial,h.AmendDate ,H.DATE , h.net_amt as Chrg_Befor_GST ,h.net_amt as disc_Befor_GST ,h.net_amt as Chrg_After_GST ,h.net_amt as disc_After_GST  into #tmpChrgtbl from STITEM  d  LEFT OUTER JOIN STMAIN H ON (D.ENTRY_TY= H.ENTRY_TY AND D.TRAN_CD =H.TRAN_CD )  where 1=2
declare @sqlstr1 nvarchar(4000),@Chrg_Befor_GST  varchar(max),@Disc_Befor_GST  varchar(max),@Chrg_after_GST  varchar(max),@Disc_after_GST  varchar(max),@bcode_nm varchar(2),@entry_ty varchar(2)
declare  Lother_cursor cursor for select (CASE WHEN bcode_nm <> '' THEN  bcode_nm ELSE Entry_ty END) as bcode_nm,Entry_ty   from LCODE  where Entry_ty in('ST','SR','SB','GD','GC','C6','D6')
open Lother_cursor
FETCH NEXT FROM Lother_cursor INTO @bcode_nm,@entry_ty
WHILE @@FETCH_STATUS = 0
BEGIN
	set @Chrg_Befor_GST = ''
	set @Chrg_Befor_GST = (SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty = @entry_ty and att_file = 0 and bef_aft  = 1 and code = 'T' order by entry_ty,code for xml path(''))
	if @Chrg_Befor_GST <> ''
		begin 
			set @Chrg_Befor_GST = substring(@Chrg_Befor_GST,0,len(@Chrg_Befor_GST))
		end 
	else
		begin
			set  @Chrg_Befor_GST = 0.00
		end 
	set @disc_Befor_GST = ''
	set @disc_Befor_GST = (SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty = @entry_ty and att_file = 0 and bef_aft  = 1 and code = 'D' order by entry_ty,code for xml path(''))
	if @disc_Befor_GST <> ''
		begin 
			set @disc_Befor_GST = substring(@disc_Befor_GST,0,len(@disc_Befor_GST))
		end 
	else
		begin
			set  @disc_Befor_GST = 0.00
		end 
		
		
	set @disc_after_GST = ''
	set @disc_after_GST = (SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty = @entry_ty and att_file = 0 and bef_aft  = 2 and code = 'F' order by entry_ty,code for xml path(''))
	if @disc_after_GST <> ''
		begin 
			set @disc_after_GST = substring(@disc_after_GST,0,len(@disc_after_GST))
		end 
	else
		begin
			set  @disc_after_GST = 0.00
		end 

	set @Chrg_After_GST = ''
	set @Chrg_After_GST = (SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty = @entry_ty  and att_file = 0 and bef_aft  = 2 and code = 'N' order by entry_ty,code for xml path(''))
	if @Chrg_After_GST <> ''
		begin 
			set @Chrg_After_GST = substring(@Chrg_After_GST,0,len(@Chrg_After_GST))
		end 
	else
		begin
			set  @Chrg_After_GST = 0.00
		end 

	set @sqlstr1 = ''
	set @sqlstr1 = ' insert into #tmpChrgtbl  select  d.tran_cd ,d.entry_ty ,d.itserial,AmendDate = (case when DATEDIFF(MM,H.DATE,H.AmendDAte) > 0 then h.AmendDate else ''''  end ) , H.DATE ,  ' + @Chrg_Befor_GST + '  as Chrg_Befor_GST ,'+ @disc_Befor_GST +' as disc_Befor_GST ,' + @Chrg_After_GST + ' as Chrg_After_GST , ' + @disc_After_GST + ' as disc_After_GST  from '+@bcode_nm+'ITEM  d  INNER JOIN ' +@bcode_nm+ 'MAIN H ON (D.ENTRY_TY= H.ENTRY_TY AND D.TRAN_CD =H.TRAN_CD ) AND H.ENTRY_TY = ' + '''' + @entry_ty  + ''''
	PRINT @sqlstr1
   EXECUTE SP_EXECUTESQL @sqlstr1
FETCH NEXT FROM Lother_cursor INTO @bcode_nm,@entry_ty   
END
CLOSE Lother_cursor
DEALLOCATE Lother_cursor
select * from  #tmpChrgtbl ORDER BY entry_ty,Tran_cd,itserial 
drop table #tmpChrgtbl

end
GO
