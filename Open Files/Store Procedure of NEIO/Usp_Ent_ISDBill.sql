set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 25/11/2009
-- Description:	This Stored procedure is useful in ISD bill Entry Module.
-- Modified By:date:Rupesh Prajapati. 10/12/2009. Grouping for #isdallocationR table.
-- Remark:
-- =============================================

ALTER  procedure [dbo].[Usp_Ent_ISDBill]
@entry_ty varchar(2),@tran_cd int,@date smalldatetime
as
begin
	Declare @SQLCOMMAND NVARCHAR(4000),@FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)
	EXECUTE   USP_REP_FILTCON 
	@VTMPAC ='',@VTMPIT ='',@VSPLCOND =''
	,@VSDATE=NULL
	,@VEDATE=@date
	,@VSAC ='',@VEAC =''
	,@VSIT='',@VEIT=''
	,@VSAMT=0,@VEAMT=0
	,@VSDEPT='',@VEDEPT=''
	,@VSCATE ='',@VECATE =''
	,@VSWARE ='',@VEWARE  =''
	,@VSINV_SR ='',@VEINV_SR =''
	,@VMAINFILE='m',@VITFILE='',@VACFILE=''
	,@VDTFLD ='date'
	,@VLYN=NULL
	,@VEXPARA=''
	,@VFCON =@FCON OUTPUT
	
	select aentry_ty,atran_cd,serbamt=sum(serbamt),sercamt=sum(sercamt),serhamt=sum(serhamt) 
	into #ISDAllocation 
	from ISDAllocation 
	where entry_ty=@entry_ty and tran_Cd<>@tran_cd
	group by aentry_ty,atran_cd

	

	select entry_ty,code_nm,bcode_nm=case when ext_vou=0 then entry_ty else bcode_nm end into #lcode from lcode

	select  
	entry_ty=(case when m.tdspaytype=2 then i.entry_ty else i.aentry_ty end)
	,tran_cd=(case when m.tdspaytype=2 then i.tran_cd else i.atran_Cd end)
	,serbamt=sum(i.serbamt),sercamt=sum(i.sercamt),serhamt=sum(i.serhamt)
	into #isdallocationR 
	from isdallocation i 
	inner join SerTaxMain_vw m on (i.entry_ty=m.entry_ty and i.tran_cd=m.tran_cd)
	inner join #lcode l on (m.entry_ty=l.entry_ty)
	where (l.bcode_nm in('BP','CP')) and m.date <=@date
	group by (case when m.tdspaytype=2 then i.entry_ty else i.aentry_ty end)
	,(case when m.tdspaytype=2 then i.tran_cd else i.atran_Cd end)
	
	
	--select * from #isdallocationR
		
	select a.entry_ty,tentry_ty=l.code_nm,a.tran_cd
	,m.date,m.inv_no,m.serty
	,m.serbper,m.sercper,m.serhper /*Bill Amount*/
	,m.serbamt,m.sercamt,m.serhamt,m.u_pinvno,m.u_pinvdt,party_nm=ac.ac_name
	,pserbamt=a.serbamt,psercamt=a.sercamt,pserhamt=a.serhamt /*Service Tax Available As Per Payment*/
	,lserbamt=isnull(i.serbamt,0) /*Passed Amount*/
	,lsercamt=isnull(i.sercamt,0) /*Passed Amount*/
	,lserhamt=isnull(i.serhamt,0) /*Passed Amount*/
	,aserbamt=a.serbamt-isnull(i.serbamt,0)
	,asercamt=a.sercamt-isnull(i.sercamt,0)
	,aserhamt=a.serhamt-isnull(i.serhamt,0)
	,sserbamt=m.serbamt
	,ssercamt=m.serbamt
	,sserhamt=m.serbamt
	into #isdbill
	from #isdallocationR  a
	inner join #lcode l on (a.entry_ty=l.entry_ty)
	inner join SerTaxMain_vw m on (a.entry_ty=m.entry_ty and a.tran_cd=m.tran_cd)
	inner join ac_mast ac on (m.ac_id=ac.ac_id)
	left join #ISDAllocation i on (a.entry_ty=i.aentry_ty and a.tran_cd=i.atran_cd)
	where l.bcode_nm in('EP','BP','CP') 
	order by m.date

	update #isdbill set sserbamt=0,ssercamt=0,sserhamt=0
	delete from #isdbill where aserbamt+asercamt+asercamt=0

	select sel=cast(0 as bit),* from #isdbill
	
	



--	select aentry_ty,atran_cd,serbamt=sum(serbamt),sercamt=sum(sercamt),serhamt=sum(serhamt) 
--	into #ISDAllocation 
--	from ISDAllocation 
--	where entry_ty=@entry_ty and tran_Cd<>@tran_cd
--	group by aentry_ty,atran_cd
--
--	SET @SQLCOMMAND='insert into #isbillent1'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'select m.entry_ty,m.tran_cd,m.inv_no,m.date'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',i.serbamt,i.sercamt,i.serhamt'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',m1entry_ty=case when m1.entry_ty'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',m1inv_no=m1.inv_no,m1date=m1.date'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ',m1serbamt=m1.serbamt,m1sercamt=m1.sercamt,m1serhamt=m1.serhamt'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'from isdallocation i'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'inner join SerTaxMain_vw m on (i.entry_ty=m.entry_ty and i.tran_cd=m.tran_cd)'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'inner join #lcode l on (m.entry_ty=l.entry_ty)'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'left join SerTaxMain_vw m1 on (i.aentry_ty=m1.entry_ty and i.atran_cd=m1.tran_cd)'
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ @fcon
--	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ 'and l.entry_ty<>''SD''' 
--	print @SQLCOMMAND
--	execute sp_executesql @SQLCOMMAND
	
	
	

	--select * from #isbillent1
	
	--select entry_ty,tran_cd,fld_nm,amount=sum(amount),re_all=sum(re_all),are_all=sum(are_all) into #acdetalloc from acdetalloc group by entry_ty,tran_cd,fld_nm
	 	
	--select 'a',* from #ISDAllocation
	--select 'b',*  from acdetalloc
--	select a.entry_ty,tentry_ty=l.code_nm,a.tran_cd
--	,m.date,m.inv_no,m.serty
--	,m.serbper
--	,m.sercper
--	,m.serhper
--	,m.serbamt,m.sercamt,m.serhamt,m.u_pinvno,m.u_pinvdt,party_nm=ac.ac_name
--	,pserbamt=sum(case when fld_nm='serbamt' then (case when l.bcode_nm in('EP') then a.re_all else a.amount end ) else 0 end)
--	,psercamt=sum(case when fld_nm='sercamt' then (case when l.bcode_nm in('EP') then a.re_all else a.amount end ) else 0 end)
--	,pserhamt=sum(case when fld_nm='serhamt' then (case when l.bcode_nm in('EP') then a.re_all else a.amount end ) else 0 end)
--	,lserbamt=isnull(i.serbamt,0)--sum(isnull(i.serbamt,0))
--	,lsercamt=isnull(i.sercamt,0)--sum(isnull(i.sercamt,0))
--	,lserhamt=isnull(i.serhamt,0)--sum(isnull(i.serhamt,0))
--	,aserbamt=sum(case when fld_nm='serbamt' then (case when l.bcode_nm in('EP') then a.re_all-isnull(i.serbamt,0) else a.amount-isnull(i.serbamt,0) end ) else 0 end)
--	,asercamt=sum(case when fld_nm='sercamt' then (case when l.bcode_nm in('EP') then a.re_all-isnull(i.sercamt,0) else a.amount-isnull(i.sercamt,0) end ) else 0 end)
--	,aserhamt=sum(case when fld_nm='serhamt' then (case when l.bcode_nm in('EP') then a.re_all-isnull(i.serhamt,0) else a.amount-isnull(i.serhamt,0) end ) else 0 end)
--	,sserbamt=m.serbamt
--	,ssercamt=m.serbamt
--	,sserhamt=m.serbamt
--	into #isdbill
--	from acdetalloc a
--	inner join #lcode l on (a.entry_ty=l.entry_ty)
--	inner join SerTaxMain_vw m on (a.entry_ty=m.entry_ty and a.tran_cd=m.tran_cd)
--	inner join ac_mast ac on (m.ac_id=ac.ac_id)
--	left join #ISDAllocation i on (a.entry_ty=i.aentry_ty and a.tran_cd=i.atran_cd)
--	where l.bcode_nm in('EP','BP','CP') 
--	group by a.entry_ty,l.code_nm,a.tran_cd,m.date,m.inv_no,m.serbamt,m.sercamt,m.serhamt,m.serty,m.u_pinvno,m.u_pinvdt,ac.ac_name,m.serbper,m.sercper,m.serhper
--	,i.serbamt,i.sercamt,i.serhamt
--	
--	update #isdbill set sserbamt=0,ssercamt=0,sserhamt=0
--
--	delete from #isdbill where aserbamt+asercamt+asercamt=0
--
--	select sel=cast(0 as bit),* from #isdbill
	
end 


--IF You Win , you need not have to explain..., if you lose,you should not be there to explain!
--Everyone thinks of chage the world but no one thinks of changing himself


