DROP PROCEDURE [USP_REP_SalregC]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 15/06/2009
-- Description:	This Stored procedure is useful to generate Sales Register with fields from Discount and Charges Master (SALREGC.rpt).
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================

create PROCEDURE [USP_REP_SalregC]  
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= null
AS
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)
Declare @entry_ty varchar(2),@tran_cd int ,@date smalldatetime,@inv_no varchar(10),@ac_name varchar(75),@head_nm varchar(100),@fld_nm varchar(100),@sr decimal(5,2),@corder int,@tcond varchar(100),@att_file bit
Declare @found bit,@tfld_nm varchar(100),@grp varchar(1000),@tcnt int
Declare @cnt int ,@head1 varchar(30),@head2 varchar(30),@head3 varchar(30),@head4 varchar(30),@head5 varchar(30),@head6 varchar(30),@head7 varchar(30),@head8 varchar(30),@head9 varchar(30),@head10 varchar(30),@head11 varchar(30),@head12 varchar(30),@head13 varchar(30),@head14 varchar(30),@head15 varchar(30),@head16 varchar(30),@head17 varchar(30),@head18 varchar(30),@head19 varchar(30),@head20 varchar(30),@head21 varchar(30),@head22 varchar(30),@head23 varchar(30),@head24 varchar(30),@head25 varchar(30),@head26 varchar(30)
Declare @TBLNAME1 varchar(30),@TBLNM varchar(30)

select @head1='',@head2='',@head3='',@head4='',@head5='',@head6='',@head7='',@head8='',@head9='',@head10 ='',@head11 ='',@head12 ='',@head13 ='',@head14 ='',@head15 ='',@head16 ='',@head17 ='',@head18 ='',@head19 ='',@head20 ='',@head21 ='',@head22 ='',@head23 ='',@head24 ='',@head25 ='',@head26 =''
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=null,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE='I',@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

select entry_ty,corder,sr=99.99
,head_nm,fld_nm=space(100)
,per=cast(0 as decimal(10,3))
,att_file,Code
into #dcmast
from dcmast a
where 1=2

Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
				+ (DATEPART(ss, GETDATE()) * 1000 )
				+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
Set @TBLNAME1 = '##TMP1'+@TBLNM

Declare @serialNo Numeric(5,2)

insert into #dcmast(entry_ty,corder,sr,head_nm,fld_nm,per,att_file,Code)

select a.entry_ty,corder,sr=row_number()over(order by  case when att_file=0 then 'A' else 'B' End+ case when Bef_aft = 1  then 'A' else 'B' end + 
	(Case when Code='D' then 'A' else (case when code='T' then 'B' else (Case when code='E' then 'C' else (Case when code='A' then 'D' else ( Case When code='N' then 'E' else 'F' end) end) end) end ) end ),corder)
,head_nm,fld_nm
,per=cast(0 as decimal(10,3))
,att_file,Code
from dcmast a
inner join lcode l on (a.entry_ty=l.entry_ty)
where ( (a.entry_ty='ST') or (l.entry_ty='ST') ) 
order by case when att_file=0 then 'A' else 'B' End+ case when Bef_aft = 1  then 'A' else 'B' end + 
	(Case when Code='D' then 'A' else (case when code='T' then 'B' else (Case when code='E' then 'C' else (Case when code='A' then 'D' else ( Case When code='N' then 'E' else 'F' end) end) end) end ) end ),corder


Select Top 1 @serialNo=(sr-0.5) from #dcmast Where att_file=1 order by sr
insert into #dcmast(entry_ty,corder,sr,head_nm,fld_nm,per,att_file,Code)
values ('ST',1,@serialNo,'Gross Amount','gro_amt',0,0,' ')

Select Top 1 @serialNo=(sr-0.5) from #dcmast Where att_file=0 and code='E' order by sr
insert into #dcmast(entry_ty,corder,sr,head_nm,fld_nm,per,att_file,Code)
values ('ST',1,@serialNo,'Taxable Amount','u_asseamt',0,0,' ')

Select Top 1 @serialNo=max(sr)+1 from #dcmast 
insert into #dcmast(entry_ty,corder,sr,head_nm,fld_nm,per,att_file,Code)
values ('ST',1,@serialNo,'Total Amount','net_amt',0,1,' ')

--select * from #dcmast order by sr
--update #dcmast set att_file=1 where sr=3 --Excise



set @cnt=1
set @found=0
set @tfld_nm='0'
set @head1='Quantity'
set @head26='Rate'
set @tcnt=0

--select distinct sr,corder,head_nm,fld_nm,att_file from #dcmast order by sr,corder,head_nm,fld_nm
set @grp= 'group by m.date,ac_mast.ac_name,m.inv_no'
set @sqlcommand='select m.date,ac_mast.ac_name,m.inv_no'
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,[column1]=sum(i.qty)'
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,[column26]=sum(i.rate)'
declare  cur_dcmast cursor for 
select distinct sr,corder,head_nm,fld_nm,att_file from #dcmast order by sr,corder,head_nm,fld_nm

open cur_dcmast
fetch next from cur_dcmast into @sr,@corder,@head_nm,@fld_nm,@att_file
while(@@fetch_status=0 and @cnt<>-1)
begin
	set @cnt=@cnt+1
	print cast(@cnt as varchar)+ ' '+@head_nm
	if @att_file=0
	begin
		set @tfld_nm=',sum(i.'+@fld_nm+')'
	end 
	if @att_file=1
	begin
		if (@sr=4.5)
		begin
			set @tcnt=@cnt
			set @found=1 --Taxable Amt.
			set @tfld_nm=','+@fld_nm
		end 
		else
		begin
			if @sr=5	
			begin
				set @tfld_nm=',(case when m.tax_name='''+rtrim(@head_nm)+''' then m.'+rtrim(@fld_nm)+' else 0 end)'
				set @grp=rtrim(@grp)+',m.tax_name,m.'+@fld_nm
			end
			else
			begin	
				set @tfld_nm=',m.'+@fld_nm
				set @grp=rtrim(@grp)+',m.'+@fld_nm
			end
		end 
	end 

	if (@cnt=1) begin set @head1=@head_nm end
	if (@cnt=2) begin set @head2=@head_nm end
	if (@cnt=3) begin set @head3=@head_nm end
	if (@cnt=4) begin set @head4=@head_nm end
	if (@cnt=5) begin set @head5=@head_nm end
	if (@cnt=6) begin set @head6=@head_nm end
	if (@cnt=7) begin set @head7=@head_nm end
	if (@cnt=8) begin set @head8=@head_nm end
	if (@cnt=9) begin set @head9=@head_nm end
	if (@cnt=10) begin set @head10=@head_nm end
	if (@cnt=11) begin set @head11=@head_nm end
	if (@cnt=12) begin set @head12=@head_nm end
	if (@cnt=13) begin set @head13=@head_nm end
	if (@cnt=14) begin set @head14=@head_nm end
	if (@cnt=15) begin set @head15=@head_nm end
	if (@cnt=16) begin set @head16=@head_nm end
	if (@cnt=17) begin set @head17=@head_nm end
	if (@cnt=18) begin set @head18=@head_nm end
	if (@cnt=19) begin set @head19=@head_nm end
	if (@cnt=20) begin set @head20=@head_nm end
	if (@cnt=21) begin set @head21=@head_nm end
	if (@cnt=22) begin set @head22=@head_nm end
	if (@cnt=23) begin set @head23=@head_nm end
	if (@cnt=24) begin set @head24=@head_nm end
	if (@cnt=25) begin set @head25=@head_nm end
	if (@cnt=26) begin set @head26=@head_nm end
	
	--set @sqlcommand=rtrim(@sqlcommand)+' '+',sum('+rtrim(@fld_nm)+') as ['+rtrim(@head_nm)+']'
	print 'r'
	print @tfld_nm	
	set @sqlcommand=rtrim(@sqlcommand)+' '+rtrim(@tfld_nm)+' as [column'+rtrim(cast(@cnt as varchar))+']'
fetch next from cur_dcmast into @sr,@corder,@head_nm,@fld_nm,@att_file
end
close cur_dcmast
deallocate cur_dcmast

while(@Cnt<25)
begin
	set @cnt=@cnt+1
	set @sqlcommand=rtrim(@sqlcommand)+' '+',0 as [column'+rtrim(cast(@cnt as varchar))+']'
end

set @sqlcommand=rtrim(@sqlcommand)+' '+' ,head1='''+rtrim(@head1)+''''+',head2='''+rtrim(@head2)+''''+',head3='''+rtrim(@head3)+''''+',head4='''+rtrim(@head4)+''''+',head5='''+rtrim(@head5)+''''+',head6='''+rtrim(@head6)+''''+',head7='''+rtrim(@head7)+''''+',head8='''+rtrim(@head8)+''''+',head9='''+rtrim(@head9)+''''+',head10='''+rtrim(@head10)+''''
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,head11='''+rtrim(@head11)+''''+',head12='''+rtrim(@head12)+''''+',head13='''+rtrim(@head13)+''''+',head14='''+rtrim(@head14)+''''+',head15='''+rtrim(@head15)+''''+',head16='''+rtrim(@head16)+''''+',head17='''+rtrim(@head17)+''''+',head18='''+rtrim(@head18)+''''+',head19='''+rtrim(@head19)+''''+',head20='''+rtrim(@head20)+''''
set @sqlcommand=rtrim(@sqlcommand)+' '+' ,head21='''+rtrim(@head21)+''''+',head22='''+rtrim(@head22)+''''+',head23='''+rtrim(@head23)+''''+',head24='''+rtrim(@head24)+''''+',head25='''+rtrim(@head25)+''''+',head26='''+rtrim(@head26)+''''
set @sqlcommand=rtrim(@sqlcommand)+' '+'into '+@TBLNAME1
set @sqlcommand=rtrim(@sqlcommand)+' '+' from stmain m'
set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join stitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast on (m.ac_id=ac_mast.ac_id)'
set @sqlcommand=rtrim(@sqlcommand)+' '+@FCON
set @sqlcommand=rtrim(@sqlcommand)+' '+@grp
--set @sqlcommand=rtrim(@sqlcommand)+' '+'group by m.entry_ty,m.tran_cd,m.date,m.inv_no,ac_mast.ac_name'


print @sqlcommand
execute  sp_executesql @sqlcommand
set @cnt=1

--set @sqlcommand=' '
--while(@cnt<@tcnt)
--begin
--	set @sqlcommand=rtrim(@sqlcommand)+'+column'+rtrim(cast(@cnt as varchar))
--	set @cnt=@cnt+1
--end
--set @sqlcommand=substring(@sqlcommand,2,len(@sqlcommand))
--set @sqlcommand='update '+@TBLNAME1+' set column'+rtrim(cast(@cnt as varchar))+'='+@sqlcommand--+' group by date,ac_name,inv_no'
--print @sqlcommand
--execute  sp_executesql @sqlcommand


set @sqlcommand='select * from '+ @TBLNAME1
execute  sp_executesql @sqlcommand

set @sqlcommand='drop table '+ @TBLNAME1
execute  sp_executesql @sqlcommand
GO
