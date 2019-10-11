DROP PROCEDURE [Usp_Uereport_AccountFoundFromGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 04/05/2010. 
-- Description:	Used in uereport project for Account Group and SubGroup checking. Replacement of Usp_ent_AccountFoundFromGroup,usp_acc_subgroups in uerport.app
-- Modify By/Date/Reason: Rupesh. 18/05/2010.  Modified for Multiple Account Group selecttion in r_Status
-- Modify By/Date/Reason: For Tkt - 6601 By Amrendra. 14/03/2011.  
-- Modify By/Date/Reason: For Bug-388 By Birendra. 11/11/2011.  
-- Modify By/Date/Reason: Sandeep/05-Sep-13/for bug-18760
-- Modify By/Date/Reason: Sandeep/27-dec-13/for bug-21153
-- Remark:
-- =============================================
create  procedure [Usp_Uereport_AccountFoundFromGroup]
@accGroup varchar(4000),@fldstr varchar(2000)
,@fcity varchar(40),@tcity varchar(40)
,@fsalesman varchar(100),@tsalesman varchar(100)
as
declare @reccount integer,@Sqlcommand Nvarchar(4000),@fldcon varchar(2000)



select ac_group_name,[group] into #groups from ac_group_mast where 1=2  
if isnull(@accGroup,'')<>''
begin
	set @accGroup=''''+replace(@accGroup,',',''',''')+''''
	set @Sqlcommand='insert into #groups select ac_group_name,[group] from ac_group_mast where ac_group_name in ('+@accGroup+')' 
end
else
begin
	set @Sqlcommand='insert into #groups select ac_group_name,[group] from ac_group_mast' 
end

print @Sqlcommand														
Execute sp_Executesql @Sqlcommand										
--Added by Shrikant S. on 14/04/2010 for TKT-648		&& End

--charindex(rtrim(ac_group_name),@accountname,1)<>0 --Commented by Shrikant S. on 14/04/2010 for TKT-648
select ac_group_name,[group] into #group1 from #groups
set @reccount = 2
while @reccount>1
begin
	select ac_group_name,[group] into #group2 from ac_group_mast 
		where [group] in (select ac_group_name from #group1)
	insert into #groups select * from #group2
	delete from #group1
	insert into #group1 select ac_group_name,[group] from #group2
	drop table #group2
	set @reccount = (select count(ac_group_name) from #group1)
end
drop table #group1
--select 'a',* from #groups

--set @SqlCommand='select  '+rtrim(@fldstr)+' from ac_mast' --Commented by Sandeep/05-Sep-13/for bug-18760
----Added by Sandeep/05-Sep-13/for bug-18760--Start
--set @SqlCommand='select distinct '+rtrim(@fldstr)+' from ac_mast inner join lmain_vw b on ac_mast.ac_id=b.ac_id'   
--set @fldcon=' where [group] in (select ac_group_name from #groups group by ac_group_name) and isnull(ac_name,'''')<>'''' '
----Added by Sandeep/05-Sep-13/for bug-18760--End 
--Added by Sandeep/05-Sep-13/for bug-21153--Start
set @SqlCommand='select distinct '+rtrim(@fldstr)+' from ac_mast left join lmain_vw b on ac_mast.ac_id=b.ac_id'   
set @fldcon=' where [group] in (select ac_group_name from #groups group by ac_group_name) and isnull(ac_name,'''')<>'''' '
--Added by Sandeep/05-Sep-13/for bug-21153--End 

if @tcity<>'' /*City*/
begin
--	if @fldcon='' begin set @fldcon=' where ' end else begin set @fldcon=@SqlCommand+' And ' end
--	set @fldcon=rtrim(@fldcon)+' '+' (b.city between '+char(39)+rtrim(@fcity)+char(39)+' and ' +char(39)+rtrim(@tcity)+char(39)+')'
--Birendra : Bug-388 on 11/11/2011 :Start:
	if @fldcon='' begin set @fldcon=' where ' end else begin set @fldcon=@fldcon+' And ' end
--	set @fldcon=rtrim(@fldcon)+' '+' (city between '+char(39)+rtrim(@fcity)+char(39)+' and ' +char(39)+rtrim(@tcity)+char(39)+')' --Commented by Sandeep/05-Sep-13/for bug-18760
	set @fldcon=rtrim(@fldcon)+' '+' (ac_mast.city between '+char(39)+rtrim(@fcity)+char(39)+' and ' +char(39)+rtrim(@tcity)+char(39)+')' --Added by Sandeep/05-Sep-13/for bug-18760
--Birendra : Bug-388 on 11/11/2011 :End:

end

if @tsalesman<>'' /*City*/
begin
---comment By Amrendra. 14/03/2011.  For Tkt - 6601 -----Start
	--if @fldcon='' begin set @fldcon=' where ' end else begin set @fldcon=@SqlCommand+' And ' end
	--set @fldcon=rtrim(@fldcon)+' '+' (b.salesman between '+char(39)+rtrim(@fsalesman)+char(39)+' and ' +char(39)+rtrim(@tsalesman)+char(39)+')'
---comment By Amrendra. 14/03/2011.  For Tkt - 6601 -----End
---Added By Amrendra. 14/03/2011.  For Tkt - 6601 -----Start
	if @fldcon='' begin set @fldcon=' where ' end else begin set @fldcon=@fldcon+' And ' end
--	set @fldcon=rtrim(@fldcon)+' '+' (salesman between '+char(39)+rtrim(@fsalesman)+char(39)+' and ' +char(39)+rtrim(@tsalesman)+char(39)+')' --Commented by Sandeep/05-Sep-13/for bug-18760
	set @fldcon=rtrim(@fldcon)+' '+' ( (case when  isnull(ac_mast.salesman,'''')<>'''' then ac_mast.salesman else b.salesman end)  between '+char(39)+rtrim(@fsalesman)+char(39)+' and ' +char(39)+rtrim(@tsalesman)+char(39)+')'--Added by Sandeep/05-Sep-13/for bug-18760
---Added By Amrendra. 14/03/2011.  For Tkt - 6601 -----End
end

set @SqlCommand=rtrim(@SqlCommand)+' '+@fldcon
	
set @SqlCommand=rtrim(@SqlCommand)+' '+'order by  acname'

print @SqlCommand
EXECUTE SP_EXECUTESQL @SqlCommand

drop table #groups
GO
