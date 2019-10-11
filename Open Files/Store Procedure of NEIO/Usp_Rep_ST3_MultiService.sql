If Exists(Select [name] From SysObjects Where xType='P' and [Name]='Usp_Rep_ST3_MultiService')
Begin
	Drop Procedure Usp_Rep_ST3_MultiService
End
Go

-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 22/05/2010
-- Description:	This Stored procedure is useful to generate Service Tax ST 3 Report .
-- Modification Date/By/Reason: 28/07/2010. TKT-794 GTA &&18/09/2010
-- Modification Date/By/Reason: 16/09/2010. TKT-4123
-- Modification Date/By/Reason: 24/09/2010. Rupesh Prajapati. TKT-4200 
-- Modification Date/By/Reason: 09/12/2010. Rupesh Prajapati. TKT-3468
-- Remark:
-- =============================================
create procedure [dbo].[Usp_Rep_ST3_MultiService]
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
begin --sp
	
declare @sdate1 smalldatetime,@edate1 smalldatetime,@sdate2 smalldatetime,@edate2 smalldatetime,@sdate3 smalldatetime,@edate3 smalldatetime,@sdate4 smalldatetime,@edate4 smalldatetime,@sdate5 smalldatetime,@edate5 smalldatetime,@sdate6 smalldatetime,@edate6 smalldatetime
declare @particulars varchar(250),@particulars1 varchar(250),@u_arrears varchar(250),@sDocNo varchar(50),@sDocDt smalldatetime
declare @c int,@m int,@y int,@strdt varchar(10)
declare @u_chalno varchar(20),@u_chaldt smalldatetime,@date smalldatetime,@CommanNotivar varchar(300)
declare @isdprouct bit

set @isdprouct=0
if CHARINDEX('VUISD', upper(@EXPARA))>0
begin
	set @isdprouct=1
end

set @sdate1=@sdate1
	
set @c=1
set @m=month(@sdate)
set @y=year(@sdate)
while(@c<=6)
begin
	if(@c=1)
	begin
		--set @sdate1=cast('04/01/2008' as smalldatetime) cast(day(@sdate) as varchar(2))+'/'+cast(month(@sdate) as varchar(2))+'/'+cast(year(@sdate) as varchar(4))
		set @sdate1=cast( cast(month(@sdate) as varchar(2))+'/'+cast(day(@sdate) as varchar(2))+'/'+cast(year(@sdate) as varchar(4))  as smalldatetime)
		if(@m in (1,3,5,7,8,10,12))
		begin
			set @edate1=cast( cast(@m as varchar(2))+'/'+cast(31 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (4,6,9,11))
		begin
			set @edate1=cast( cast(@m as varchar(2))+'/'+cast(30 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (2))
		begin
			set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/29'
			if isdate(@strdt)=1
			begin
				set @edate1=cast(@strdt as smalldatetime)	
			end
			else
			begin
				set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/28'
				set @edate1=cast( @strdt as smalldatetime)	
			end	
		end		
	end


	if(@c=2)
	begin
		set @sdate2=cast( cast(@m as varchar(2))+'/'+cast(1 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		if(@m in (1,3,5,7,8,10,12))
		begin
			set @edate2=cast( cast(@m as varchar(2))+'/'+cast(31 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (4,6,9,11))
		begin
			set @edate2=cast( cast(@m as varchar(2))+'/'+cast(30 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (2))
		begin
			set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/29'
			if isdate(@strdt)=1
			begin
				set @edate2=cast(@strdt as smalldatetime)	
			end
			else
			begin
				set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/28'
				set @edate2=cast( @strdt as smalldatetime)	
			end	
		end		

	end --c=2
	
	if(@c=3)
	begin
		set @sdate3=cast( cast(@m as varchar(2))+'/'+cast(1 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)

		if(@m in (1,3,5,7,8,10,12))
		begin
			set @edate3=cast( cast(@m as varchar(2))+'/'+cast(31 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (4,6,9,11))
		begin
			set @edate3=cast( cast(@m as varchar(2))+'/'+cast(30 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (2))
		begin
			set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/29'
			if isdate(@strdt)=1
			begin
				set @edate3=cast(@strdt as smalldatetime)	
			end
			else
			begin
				set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/28'
				set @edate3=cast( @strdt as smalldatetime)	
			end	
		end		

	end --c=3

	if(@c=4)
	begin
		set @sdate4=cast( cast(@m as varchar(2))+'/'+cast(1 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)

		if(@m in (1,3,5,7,8,10,12))
		begin
				set @edate4=cast( cast(@m as varchar(2))+'/'+cast(31 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (4,6,9,11))
		begin
			set @edate4=cast( cast(@m as varchar(2))+'/'+cast(30 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (2))
		begin
			set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/29'
			if isdate(@strdt)=1
			begin
				set @edate4=cast(@strdt as smalldatetime)	
			end
			else
			begin
				set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/28'
				set @edate2=cast( @strdt as smalldatetime)	
			end	
		end		

	end --c=4
		
	if(@c=5)
	begin
		set @sdate5=cast( cast(@m as varchar(2))+'/'+cast(1 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)

		if(@m in (1,3,5,7,8,10,12))
		begin
			set @edate5=cast( cast(@m as varchar(2))+'/'+cast(31 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (4,6,9,11))
		begin
			set @edate5=cast( cast(@m as varchar(2))+'/'+cast(30 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (2))
		begin
			set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/29'
			if isdate(@strdt)=1
			begin
				set @edate5=cast(@strdt as smalldatetime)	
			end
			else
			begin
				set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/28'
				set @edate5=cast( @strdt as smalldatetime)	
			end	
		end		

	end --c=5

	if(@c=6)
	begin
		set @sdate6=cast( cast(@m as varchar(2))+'/'+cast(1 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		if(@m in (1,3,5,7,8,10,12))
		begin
				set @edate6=cast( cast(@m as varchar(2))+'/'+cast(31 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (4,6,9,11))
		begin
				set @edate6=cast( cast(@m as varchar(2))+'/'+cast(30 as varchar(2))+'/'+cast(@y as varchar(4))  as smalldatetime)
		end
		if(@m in (2))
		begin
			set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/29'
			if isdate(@strdt)=1
			begin
				set @edate6=cast(@strdt as smalldatetime)	
			end
			else
			begin
				set @strdt=cast( @y as varchar(4)  )+'/'+cast( @m as varchar(4)  )+'/28'
				set @edate6=cast( @strdt as smalldatetime)	
			end	
		end		

	end --c=6
	--print @m
	--print @y

	set @m=@m+1
	if (@m>12)
	begin
		set @m=1
		set @y=@y+1
	end
	set @c=@c+1
end	


select distinct [name],[serty],[code] into #SerTax_Mast from SerTax_Mast
/*--->#st3_5b*/
select distinct ac.entry_ty,ac.tran_cd,ac_mast.ac_name,ac.amount,ac.amt_ty,ac.date
,sm.serty 
,m.sertype
/*=case when (isnull(bpm.tdspaytype,1)=2)  then isnull(bpm.sertype,'') else (case when (isnull(cpm.tdspaytype,1)=2)  then isnull(cpm.sertype,'') else (case when (isnull(bpm.tdspaytype,1)=2)  then isnull(bpm.sertype,'') else (case when (isnull(jvm.entry_ty,'')<>'')  then isnull(jvm.sertype,'') else (isnull(m1.sertype,'')) end) end) end) end*/
,beh=(case when l.ext_vou=1 then l.bcode_nm else l.entry_ty end)
,ac_mast.typ
into #st3_5b
from SerTaxAcDet_vw ac 
inner join ac_mast ac_mast on (ac.ac_id=ac_mast.ac_id) 
inner join lcode l on (ac.entry_ty=l.entry_ty)
left join #SerTax_Mast sm on (ac.serty=sm.[name]) /*TKT-4123 Inner join---> Left. Problem found in Service Tax Adjustment entry with Excise-->Servicre Tax*/
left join SerTaxMain_vw m on (m.entry_ty=ac.entry_ty and m.tran_cd =ac.tran_cd)
left join jvmain jvm on (jvm.entry_ty=ac.entry_ty and jvm.tran_cd =ac.tran_cd)
where ac_mast.ac_name like '%service tax available%'
and (ac.u_cldt<= @edate)
--order by ac.tran_cd,ac_mast.ac_name	
union all
select distinct ac.entry_ty,ac.tran_cd
,ac_name=case 
	when ac_mast.ac_name='Service Tax Payable' then 'Service Tax Available' 
	when ac_mast.ac_name='Edu. Cess on Service Tax Payable' then 'Edu. Cess on Service Tax Available'
	when ac_mast.ac_name='S & H Cess on Service Tax Payable' then 'S & H Cess on Service Tax Available' 
	else ac_mast.ac_name end
,ac.amount,ac.amt_ty,ac.date
,sm.serty/*TKT-794 ac.serty*/
,m.sertype
/*=case when (isnull(bpm.tdspaytype,1)=2)  then isnull(bpm.sertype,'') else (case when (isnull(cpm.tdspaytype,1)=2)  then isnull(cpm.sertype,'') else (case when (isnull(bpm.tdspaytype,1)=2)  then isnull(bpm.sertype,'') else (case when (isnull(jvm.entry_ty,'')<>'')  then isnull(jvm.sertype,'') else (isnull(m1.sertype,'')) end) end) end) end*/
,beh=(case when l.ext_vou=1 then l.bcode_nm else l.entry_ty end)
,typ=case 
	when ac_mast.typ='Service Tax Payable' then 'Service Tax Available' 
	when ac_mast.typ='Service Tax Payable-Ecess' then 'Service Tax Available-Ecess' 
	when ac_mast.typ='Service Tax Payable-Hcess' then 'Service Tax Available-Hcess' 
	else ac_mast.typ end
from SerTaxAcDet_vw ac 
inner join ac_mast ac_mast on (ac.ac_id=ac_mast.ac_id) 
inner join lcode l on (ac.entry_ty=l.entry_ty)
inner join #SerTax_Mast sm on (ac.serty=sm.[name])
left join SerTaxMain_vw m on (m.entry_ty=ac.entry_ty and m.tran_cd =ac.tran_cd)
inner join jvmain jvm on (jvm.entry_ty=ac.entry_ty and jvm.tran_cd =ac.tran_cd)
where ac_mast.ac_name like '%service tax Payable%'
and isnull(jvm.ser_adj,'')='Advance Adjustment' 
and (ac.u_cldt<= @edate)
order by ac.tran_cd,ac_mast.ac_name	
/*<---#st3_5b*/
--select 'c',* from #st3_5b where amt_ty='DR' 

/*--->#bracdet --used in 3F*/
/*TKT-3468--->*/
--select isd.entry_ty,isd.tran_cd
--,isd.serty
--,amount=sum(isd.amount),staxable=sum(isd.staxable)
--,m1.serbper,m1.sercper,m1.serhper
--,serbamt=sum(isd.serbamt),sercamt=sum(isd.sercamt),serhamt=sum(isd.serhamt)
--,acl1.SabtNoti,acl1.SabtSr,acl1.SSubCls,acl1.SExNoti
--into #BrIsdSB
--from isdallocation isd
--inner join SerTaxMain_vw m on (isd.entry_ty=m.entry_ty and isd.tran_cd=m.tran_cd)
--inner join AcdetAlloc acl on (isd.aentry_ty=acl.entry_ty and isd.atran_cd=acl.tran_cd and isd.serty=acl.serty)
--inner join lcode l on (isd.entry_ty=l.entry_ty)
--inner join SerTaxMain_vw m1 on (acl.entry_ty=m1.entry_ty and acl.tran_cd=m1.tran_cd)
--inner join AcdetAlloc acl1 on (m1.entry_ty=acl1.entry_ty and m1.tran_cd=acl.tran_cd and acl.serty=acl.serty) /*3468*/
--where (  (l.entry_ty in ('BR','CR') and isd.aentry_ty in ('SB'))  or 
--         (l.entry_ty in ('B1','C1') and isd.aentry_ty in ('IF','OF')) /*TKT-794 GTA*/
--	  )
--and (m.date between @sdate and @edate)
--and (m1.tdspaytype<>2)/*Against Bill*/
--group by isd.entry_ty,isd.tran_cd,isd.serty,m1.serbper,m1.sercper,m1.serhper
--,acl1.SabtNoti,acl1.SabtSr,acl1.SabtSr,acl1.SSubCls,acl1.SExNoti
----,isd.serbamt,isd.sercamt,isd.serhamt
--union all
--select distinct acl.entry_ty,acl.tran_cd
--,acl.serty
--,acl.amount,acl.staxable,m.serbper,m.sercper,m.serhper,m.serbamt,m.sercamt,m.serhamt
--,acl.SabtNoti,acl.SabtSr,acl.SSubCls,acl.SExNoti
--from acdetalloc acl
--inner join lcode l on (acl.entry_ty=l.entry_ty)
--inner join SerTaxMain_vw m on (acl.entry_ty=m.entry_ty and acl.tran_cd=m.tran_cd)
--where ( (l.entry_ty in ('BR','CR')) or 
--		(l.entry_ty in ('B1','C1')) /*TKT-794 GTA*/
--	  )	
--and m.tdspaytype=2 /*Advance Receipt*/
--and (m.date between @sdate and @edate)
--union all
--select distinct isd.entry_ty,isd.tran_cd
--,isd.serty
--,isd.amount,isd.staxable
--,m1.serbper,m1.sercper,m1.serhper
--,isd.serbamt,isd.sercamt,isd.serhamt
--,acl.SabtNoti,acl.SabtSr,acl.SSubCls,acl.SExNoti
--from isdallocation isd
--inner join SerTaxMain_vw m on (isd.entry_ty=m.entry_ty and isd.tran_cd=m.tran_cd)
--inner join AcdetAlloc acl on (isd.aentry_ty=acl.entry_ty and isd.atran_cd=acl.tran_cd) --and isd.serty=acl.serty)
--inner join lcode l on (isd.entry_ty=l.entry_ty)
--inner join SerTaxMain_vw m1 on (acl.entry_ty=m1.entry_ty and acl.tran_cd=m1.tran_cd)
--where ( l.entry_ty in ('SB','IF','OF') and isd.entry_ty in ('SB','IF','OF') )  /*TKT-794 GTA Add IF,OF*/
--and (m.date between @sdate and @edate)
--and m1.tdspaytype=2 /*SB Against Advanced Receipt*/ /*Output Service Tax*/
--and acl.entry_ty+cast(acl.tran_cd as  varchar)+isd.serty 
--not in (
--select distinct acl.entry_ty+cast(acl.tran_cd as  varchar)+acl.serty from isdallocation isd
--inner join AcdetAlloc acl on (isd.aentry_ty=acl.entry_ty and isd.atran_cd=acl.tran_cd)
--)
--union all
--select distinct
--m.entry_ty,m.tran_cd
--,acl.serty
--,acl.amount,acl.staxable
--,m.serbper,m.sercper,m.serhper
--,acl.serbamt,acl.sercamt,acl.serhamt
--,acl.SabtNoti,acl.SabtSr,acl.SSubCls,acl.SExNoti
--from AcdetAlloc acl
--inner join lcode l on (acl.entry_ty=l.entry_ty)
--inner join SerTaxMain_vw m on (acl.entry_ty=m.entry_ty and acl.tran_cd=m.tran_cd)
--where l.entry_ty in ('EP') /*Imported Purchase*/
--and (m.date between @sdate and @edate)
--and m.serrule='IMPORT'
--
--
--
--select
--m.inv_no
--,sm.serty
--,m.date
--,amt_ty,ac.amt_ty
--,m.tdspaytype
--,gro_amt=a.amount 
--,taxable_amt=a.staxable 
--,sabtamt    =a.amount-a.staxable 
--,a.serbper,a.sercper,a.serhper
--,serbamt=sum(case when am.typ in ('Service Tax Payable','GTA Service Tax Payable') then ac.amount else 0 end)
--,sercamt=sum(case when am.typ in ('Service Tax Payable-Ecess','GTA Service Tax Payable-Ecess') then ac.amount else 0 end)
--,serhamt=sum(case when am.typ in ('Service Tax Payable-Hcess','GTA Service Tax Payable-Hcess') then ac.amount else 0 end)
--,ac.entry_ty,ac.tran_cd,acserial=''
--,sttran_cd=0
--,serrule=''
--,SabtNoti,SabtSr,SSubCls,SExNoti
--,sProvider=(case when ac.entry_ty in ('EP','B1','C1') then 'NO' else 'YES' end)
--,sReceiver=(case when ac.entry_ty in ('EP','B1','C1') then 'YES' else 'NO' end)
--into #bracdet --used in 3F /*into #bracdet1 TKT-794 GTA */
--from #BrIsdSB a
--inner join #SerTax_Mast sm on (a.serty=sm.[name])
--left join SerTaxAcdet_vw ac on (a.entry_ty=ac.entry_ty and a.tran_cd=ac.tran_cd and sm.[name]=ac.serty and ac.amt_ty='cr')/*don't use inner join due to normal BR Against Exempted EP *//*a.serty=ac.serty TKT-794 GTA*/ 
--inner join SerTaxMain_vw m on (m.entry_ty=a.entry_ty and m.tran_cd=a.tran_cd)
----inner join ac_mast ac_mast on (ac.ac_id=ac_mast.ac_id) /*TKT-3468 same as above line*/
--left join ac_mast am on (ac.ac_id=am.ac_id)  /*don't use inner join due to normal BR Against Exempted EP */
--where ac.amt_ty='cr' /*Add to join */
--group by 
--m.inv_no
--,sm.serty,m.date
--,ac.amt_ty
--,m.tdspaytype
--,a.serbper,a.sercper,a.serhper
--,ac.entry_ty,ac.tran_cd
--,a.amount 
--,a.staxable 
--,(case when ac.entry_ty in ('EP','B1','C1') then 'NO' else 'YES' end)
--,(case when ac.entry_ty in ('EP','B1','C1') then 'YES' else 'NO' end)
--,SabtNoti,SabtSr,SSubCls,SExNoti
/*TKT-3468*/

select
m.inv_no
,sm.serty
,m.date
,m.tdspaytype
,gro_amt=isd.amount 
,taxable_amt=isd.staxable 
,acl.sabtamt
,m1.serbper,m1.sercper,m1.serhper
,isd.serbamt
,isd.sercamt
,isd.serhamt
,isd.entry_ty,isd.tran_cd,acserial=''
,sttran_cd=0
,m1.serrule
,acl.SabtSr,acl.SSubCls,acl.SExNoti
,sProvider='Yes'
,sReceiver='No'
,acl.sExpAmt
into #bracdet --used in 3F 
from isdallocation isd
inner join SerTaxMain_vw m on (isd.entry_ty =m.entry_ty and isd.tran_cd=m.tran_cd)
inner join #SerTax_Mast sm on (isd.serty=sm.[name])
inner join acdetalloc acl on (isd.aentry_ty =acl.entry_ty and isd.atran_cd=acl.tran_cd)
inner join SerTaxMain_vw m1 on (acl.entry_ty =m1.entry_ty and acl.tran_cd=m1.tran_cd)
where isd.entry_ty in ('BR','CR','B1','C1') and acl.entry_ty in ('SB','IF','OF') and m.tdspaytype=1 /*Against Bill*/
union /*Advance Receipt*/
select
m.inv_no
,sm.serty
,m.date
,m.tdspaytype
,gro_amt=acl.amount 
,taxable_amt=acl.staxable 
,acl.sabtamt
,m.serbper,m.sercper,m.serhper
,acl.serbamt
,acl.sercamt
,acl.serhamt
,acl.entry_ty,acl.tran_cd,acserial=''
,sttran_cd=0
,m.serrule
,acl.SabtSr,acl.SSubCls,acl.SExNoti
,sProvider='Yes'
,sReceiver='No'
,acl.sExpAmt
from acdetalloc acl
inner join SerTaxMain_vw m on (acl.entry_ty =m.entry_ty and acl.tran_cd=m.tran_cd)
inner join #SerTax_Mast sm on (acl.serty=sm.[name])
where acl.entry_ty in ('BR','CR','B1','C1') and m.tdspaytype=2 /*Advance*/
union /*Imported Service*/
select
m.inv_no
,sm.serty
,m.date
,tdspaytype=1
,gro_amt=acl.amount 
,taxable_amt=acl.staxable 
,acl.sabtamt
,m.serbper,m.sercper,m.serhper
,acl.serbamt
,acl.sercamt
,acl.serhamt
,acl.entry_ty,acl.tran_cd,acserial=''
,sttran_cd=0
,m.serrule
,acl.SabtSr,acl.SSubCls,acl.SExNoti
,sProvider='No'
,sReceiver='Yes'
,acl.sExpAmt
from acdetalloc acl
inner join SerTaxMain_vw m on (acl.entry_ty =m.entry_ty and acl.tran_cd=m.tran_cd)
inner join #SerTax_Mast sm on (acl.serty=sm.[name])
where acl.entry_ty in ('EP') 
and m.serrule='IMPORT'
union /*Advance Adjustment*/
select
m.inv_no
,sm.serty
,m.date
,tdspaytype=1
,gro_amt=acl.amount 
,taxable_amt=acl.staxable 
,acl.sabtamt
,m.serbper,m.sercper,m.serhper
,acl.serbamt
,acl.sercamt
,acl.serhamt
,acl.entry_ty,acl.tran_cd,acserial=''
,sttran_cd=0
,m.serrule
,acl.SabtSr,acl.SSubCls,acl.SExNoti
,sProvider='Yes'
,sReceiver='No'
,acl.sExpAmt
from acdetalloc acl
inner join SerTaxMain_vw m on (acl.entry_ty =m.entry_ty and acl.tran_cd=m.tran_cd)
inner join SerTaxAcDet_vw ac on (acl.entry_ty=ac.entry_ty and acl.tran_cd=ac.tran_cd and acl.serty=ac.serty and ac.amt_ty='Cr')
inner join ac_mast am on (ac.ac_id=am.ac_id and am.typ in ('Service Tax Payable','GTA Service Tax Payable','Service Tax Payable-Ecess','GTA Service Tax Payable-Ecess','Service Tax Payable-Hcess','GTA Service Tax Payable-Hcess'))
inner join #SerTax_Mast sm on (acl.serty=sm.[name])
where acl.entry_ty in ('SB')



--select sProvider,sReceiver,* from #BrIsdSB

/*--->TKT-794 GTA
	select inv_no,serty,date,amt_ty,tdspaytype,serbper,sercper,serhper,entry_ty,tran_cd,acserial,sttran_cd,serrule,serbamt,sercamt,serhamt
	,gro_amt=sum(gro_amt)
	,taxable_amt=sum(taxable_amt)
	,sabtamt=sum(sabtamt)	
	into #bracdet
	from #bracdet1 a
	group by
	inv_no,serty,date,amt_ty,tdspaytype,serbper,sercper,serhper,entry_ty,tran_cd,acserial,sttran_cd,serrule,serbamt,sercamt,serhamt
<---TKT-794 GTA*/

/*<---#bracdet --used in 3F*/


update #bracdet set tdspaytype =1 where isnull(tdspaytype,0)=0

/*--->#bpacdet --used in 4A*/
select --sm.serty,/*ac.serty TKT-794  GTA*/
ac.entry_ty,ac.tran_cd
,date=(case when isnull(ac.u_cldt,'')='' then ac.date else ac.u_cldt end)
,ac_mast.ac_name,amount,typ,beh=(case when l.ext_vou=1 then l.bcode_nm else l.entry_ty end),m.u_arrears
,m.u_chalno,m.u_chaldt,er_adj=isnull(jvm.ser_adj,'')
,m.sDocNo,m.sDocDt
,ac.u_cldt
,m.TDSPayType
into #bpacdet
from SerTaxAcdet_vw ac
inner join SerTaxMain_vw m on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
left join jvmain jvm on (jvm.entry_ty=ac.entry_ty and jvm.tran_cd=ac.tran_cd)
inner join ac_mast on (ac_mast.ac_id=ac.ac_id)
inner join lcode l on (m.entry_ty=l.entry_ty)
--inner join #SerTax_Mast sm on (ac.serty=sm.[name])
where ac.amt_ty='DR' 
and ac_mast.typ in ('Service Tax Payable','Service Tax Payable-Ecess','Service Tax Payable-Hcess','GTA Service Tax Payable','GTA Service Tax Payable-Ecess','GTA Service Tax Payable-Hcess') /*TKT-794 GTA*/
and ( ac.u_cldt between @sdate and @edate) 


/*<---#bpacdet --used in 4A*/

update #bracdet set tdspaytype =1 where isnull(tdspaytype,0)=0

update #bracdet set taxable_amt=isnull(taxable_amt,0),serbper=isnull(serbper,0),serbamt=isnull(serbamt,0),sercper=isnull(sercper,0),sercamt=isnull(sercamt,0),serhper=isnull(serhper,0),serhamt=isnull(serhamt,0)


declare @amt1 decimal(17,2),@amt2 decimal(17,2),@amt3 decimal(17,2),@amt4 decimal(17,2),@amt5 decimal(17,2),@amt6 decimal(17,2),@serty varchar(100)
Declare @sProvider varchar(3),@sReceiver varchar(3),@ExpAmt Numeric(17,2),@SabtNoti varchar(13),@SabtSr varchar(13),@SSubCls varchar(13),@SExNoti varchar(13)
declare @SERBPER decimal(6,2),@SERBAMT decimal(17,2),@SERCPER decimal(6,2),@SERCAMT decimal(17,2),@SERHPER decimal(6,2),@SERHAMT decimal(17,2)

select particulars=space(250),serty,srno1='AA',srno2='AA',srno3='AA',srno4='AA',srno5='AA',srno6='AA'
,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
,sdate1=@sdate,sdate2=@sdate,sdate3=@sdate,sdate4=@sdate,sdate5=@sdate,sdate6=@sdate
,amt1=net_amt,amt2=net_amt,amt3=net_amt,amt4=net_amt,amt5=net_amt,amt6=net_amt
,chalno1=space(20),chaldt1 =cast('' as smalldatetime),chalno2=space(20),chaldt2 =cast('' as smalldatetime),chalno3=space(20),chaldt3 =cast('' as smalldatetime),chalno4=space(20),chaldt4 =cast('' as smalldatetime),chalno5=space(20),chaldt5 =cast('' as smalldatetime),chalno6=space(20),chaldt6 =cast('' as smalldatetime)
,SProvider=space(3),SReceiver=space(3),SabtNoti =Space(13),SabtSr=space(13),SSubCls = space(13),SExNoti =space(13)
,sDocNo=space(50),sDocDt=m.date
into #st3 
from sbmain m
inner join stax_mas st on (m.tax_name=st.tax_name)
where 1=2


--select distinct serty,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver from #bracdet
--union /*Don't use union all*/
--select distinct sm.serty,acl.SabtNoti,acl.SabtSr,acl.SSubCls,acl.SExNoti,sProvider='YES',sReceiver='NO'/*acl.serty TKT-794 GTA*/
--from acdetalloc acl 
--inner join sbmain m on (m.entry_ty=acl.entry_ty and m.tran_cd=acl.tran_cd)
--inner join #SerTax_Mast sm on (acl.serty=sm.[name])
--where acl.serty<>'' and  (date between @sdate and @edate) /*Used for Export Service*/

/*3F--->*/

select distinct serty,sProvider,sReceiver,SabtSr,SSubCls,SExNoti
into #br3a
from #bracdet
union /*Don't use union all*/
select distinct sm.serty
,sProvider=(case when m.entry_ty in ('EP','B1','C1') then 'NO' else 'YES' end)
,sReceiver=(case when m.entry_ty in ('EP','B1','C1') then 'YES' else 'NO' end),acl.SabtSr,acl.SSubCls,acl.SExNoti/*acl.serty TKT-794 GTA*/
from acdetalloc acl 
inner join sbmain m on (m.entry_ty=acl.entry_ty and m.tran_cd=acl.tran_cd)
inner join #SerTax_Mast sm on (acl.serty=sm.[name])
where acl.serty<>'' and  (date between @sdate and @edate) /*Used for Export Service*/

set @serty=''
select top 1 @serty=serty from  #br3a
if isnull(@serty,'')=''
begin
	insert into #br3a (serty,sProvider,sReceiver,SabtSr,SSubCls,SExNoti) values ('z','Yes','','','','')
end
declare cur_serty cursor for
select distinct serty from #br3a order by serty

open cur_serty
fetch next from cur_serty into @serty
--,@SabtNoti,@SabtSr,@SSubCls,@SExNoti,@sProvider,@sReceiver
while (@@fetch_status=0)
begin
	/*-->3A to E*/
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
	)
	values
	('',@serty,'3','A','1','0','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,0,0,0,0,0,0
	,'','','','','',''
	)
	
	set @sProvider='No'
	if exists(select serty from #br3a where sProvider='Yes' and serty=@serty )
	begin
		set @sProvider='Yes'
	end
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
	)
	values
	('',@serty,'3','A','2','1','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,0,0,0,0,0,0
	,'','','','',@sProvider,''
	)


	set @sReceiver='No'
	if exists(select serty from #br3a where sReceiver='Yes' and serty=@serty)
	begin
		set @sReceiver='Yes'
	end
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
	)
	values
	('',@serty,'3','A','2','2','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,0,0,0,0,0,0
	,'','','','','',@sReceiver
	)

	select top 1 @CommanNotivar =SSubCls from #br3a where serty=@serty and SSubCls<>''
	set @CommanNotivar=isnull(@CommanNotivar,'')
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
	)
	values
	('',@serty,'3','B','0','','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,0,0,0,0,0,0
	,'','',@CommanNotivar,'','',''
	)
	
	set @CommanNotivar='No'
	if exists(select serty from #br3a where isnull(SExNoti,'')<>'' and serty=@serty)
	begin
		set @CommanNotivar='Yes'
	end

	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
	)
	values
	('',@serty,'3','C','1','','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,0,0,0,0,0,0
	,'','','',@CommanNotivar,'',''
	)

	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
	)
	select '',@serty,'3','C','2','','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,0,0,0,0,0,0
	,'','','',SExNoti,'',''
	from #br3a
	where isnull(SExNoti,'')<>'' and serty=@serty
	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
	)
	select '',@serty,'3','D','0','','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,0,0,0,0,0,0
	,'',SabtSr,'','','',''
	from #br3a
	where isnull(SabtSr,'')<>'' and serty=@serty
	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
	)
	values
	('',@serty,'3','E','1','','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,0,0,0,0,0,0
	,'','','','No','',''
	)
	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
	)
	values
	('',@serty,'3','E','2','','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,0,0,0,0,0,0
	,'','','','','',''
	)	
	

		
	/*<--3A to E*/
	/*--->3F*/
		declare @i int 
		set @i=0
		while @i<=1
		begin
			set @i=@i+1
			select  @sProvider='No',@sReceiver='No'

			if @i=1 begin set @sProvider='Yes' end   else  begin set @sReceiver='Yes'end
			
			/*-->3F 1*/
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','A','0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			

			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(gro_amt,0) else 0 end)/*taxable_amt*/
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(gro_amt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(gro_amt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(gro_amt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(gro_amt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(gro_amt,0) else 0 end)
			from #bracdet
			where tdspaytype=1
			and serty=@serty 
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			
		

			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','A','1',' '
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(gro_amt,0) else 0 end)/*taxable_amt*/
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(gro_amt,0) else 0 end)/*taxable_amt*/
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(gro_amt,0) else 0 end)/*taxable_amt*/
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(gro_amt,0) else 0 end)/*taxable_amt*/
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(gro_amt,0) else 0 end)/*taxable_amt*/
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(gro_amt,0) else 0 end)/*taxable_amt*/
			from #bracdet
			where tdspaytype=2
			and serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end

			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','A','2',' '
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','B','0',' '
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			
			
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','C','0',' '
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)

			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(taxable_amt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(taxable_amt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(taxable_amt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(taxable_amt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(taxable_amt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(taxable_amt,0) else 0 end)
			from #bracdet
			where serrule='EXPORT'
			and serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			
			declare @SrNo4 varchar(2),@srno5 varchar(2)

			select @srno5 = case when @sProvider='Yes' then '1' else '0' end
			set @srno5=isnull(@srno5,'')
			if @srno5<>'0'
			begin
				select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
				insert into #st3
				(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
				,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
				,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
				,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
				)
				values
				('',@serty,'3','F','1','C',@srno5,' '
				,0,0,0,0,0,0
				,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
				,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
				)
			end
			
	
			select @srno5 = case when @sProvider='Yes' then '2' else '1' end
			set @srno5=isnull(@srno5,'')
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(taxable_amt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(taxable_amt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(taxable_amt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(taxable_amt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(taxable_amt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(taxable_amt,0) else 0 end)
			from #bracdet
			where serrule='EXEMPTED'
			and serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end

			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','C',@srno5,' '
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			
			select @srno5 = case when @sProvider='Yes' then '3' else '2' end
			set @srno5=isnull(@srno5,'')
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(sExpAmt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(sExpAmt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(sExpAmt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(sExpAmt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(sExpAmt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(sExpAmt,0) else 0 end)
			from #bracdet
			where serrule='PURE AGENT'
			and serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end			

			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','C',@srno5,' '
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)

		
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(sabtamt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(sabtamt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(sabtamt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(sabtamt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(sabtamt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(sabtamt,0) else 0 end)
			from #bracdet
			where serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			
					
	
			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
			
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','D','0',' '
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)

			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when srno4 in('A','B') then amt1 else -amt1 end )
			,@amt2=sum(case when srno4 in('A','B') then amt2 else -amt2 end ) 
			,@amt3=sum(case when srno4 in('A','B') then amt3 else -amt3 end )
			,@amt4=sum(case when srno4 in('A','B') then amt4 else -amt4 end )
			,@amt5=sum(case when srno4 in('A','B') then amt5 else -amt5 end )
			,@amt6=sum(case when  serty=@serty and srno1='3' and srno2='F' and srno3='1' Then ( case when srno4 in('A','B') then amt6 else -amt6 end ) else 0 end)
			from #st3 where serty=@serty and srno1='3' and srno2='F' and srno3='1' AND SRNO4 IN ('A','B','C','D') 
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			

			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','E','0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			

			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','1','F','0',' '
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			
			
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(taxable_amt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(taxable_amt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(taxable_amt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(taxable_amt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(taxable_amt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(taxable_amt,0) else 0 end)
			from #bracdet
			where serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			and serbper=5

			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('(I) Value on Which Service Tax is Payable @:5',@serty,'3','F','1','F','',''
			,5,0,2,0,1,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(taxable_amt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(taxable_amt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(taxable_amt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(taxable_amt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(taxable_amt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(taxable_amt,0) else 0 end)
			from #bracdet
			where serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			and serbper=8
			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('(II) Value on Which Service Tax is Payable @:8',@serty,'3','F','1','F','',''
			,8,0,2,0,1,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)			
			
			

			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(taxable_amt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(taxable_amt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(taxable_amt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(taxable_amt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(taxable_amt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(taxable_amt,0) else 0 end)
			from #bracdet
			where serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			and serbper=10
			
			
--			select 'a',*
--			from #bracdet
--			where serty=@serty
--			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
--			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
--			and serbper=10

			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('(III) Value on Which Service Tax is Payable @:10',@serty,'3','F','1','F','',''
			,10,0,2,0,1,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)			
			
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(taxable_amt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(taxable_amt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(taxable_amt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(taxable_amt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(taxable_amt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(taxable_amt,0) else 0 end)
			from #bracdet
			where serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			and serbper=12
			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('(IV) Value on Which Service Tax is Payable @:12',@serty,'3','F','1','F','',''
			,12,0,2,0,1,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)			
			
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(taxable_amt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(taxable_amt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(taxable_amt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(taxable_amt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(taxable_amt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(taxable_amt,0) else 0 end)
			,@serbper=serbper
			from #bracdet
			where serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			and serbper not in (5,8,10,12) and serbamt<>0
			group by serbper
			
			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
					,@serbper=isnull(@serbper,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			,chalno1
			)
			values
			('(V) Value on Which Service Tax is Payable at any other rate @',@serty,'3','F','1','F','',''
			,@serbper,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			,rtrim(cast(@serbper as varchar))
			)			
		
			

			select @amt1=sum(amt1+amt2+amt3+amt4+amt5+amt6) 
			from #st3 where serty=@serty and (srno1='3' and srno2='F' and srno3='1' and srno4='F')
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end

			if isnull(@amt1,0)=0
			begin
				insert into #st3
				(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
				,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
				,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
				,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
				)
				values
				('',@serty,'3','F','1','F','',''
				,99,0,0,0,0,0
				,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
				,0,0,0,0,0,0,@sProvider,@sReceiver
				)
			end	

	
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			@amt1=sum(case when (date between @sdate1 and @edate1) then isnull(serbamt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(serbamt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(serbamt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(serbamt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(serbamt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(serbamt,0) else 0 end)
			from #bracdet
			where serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			
			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			( '',@serty,'3','F','1','G','0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)	

			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			@amt1=sum(case when (date between @sdate1 and @edate1) then isnull(sercamt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(sercamt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(sercamt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(sercamt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(sercamt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(sercamt,0) else 0 end)
			from #bracdet
			where serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			( '',@serty,'3','F','1','H','0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)	
			
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(serhamt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(serhamt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(serhamt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(serhamt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(serhamt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(serhamt,0) else 0 end)
			from #bracdet
			where serty=@serty
			and sProvider=case when @sProvider ='Yes' then 'Yes' else 'No' end
			and sReceiver=case when @sProvider ='Yes' then 'No' else 'Yes' end
			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			( '',@serty,'3','F','1','I','0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)	
			/*<--3F 1*/
			/*-->3F 2*/


			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select
			@amt1=sum(case when (date between @sdate1 and @edate1) then isnull(acl.amount,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(acl.amount,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(acl.amount,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(acl.amount,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(acl.amount,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(acl.amount,0) else 0 end)
			from SerTaxMain_vw m/*sbmain m TKT-794 GTA*/
			inner join acdetalloc acl on (m.entry_ty=acl.entry_ty and m.tran_cd=acl.tran_cd)
			inner join #SerTax_Mast sm on (acl.serty=sm.[name])
			where m.entry_ty in ('SB','IF','OF','EP') 
			and (date between @sdate and @edate)
			and sm.serty=@serty
			and (case when m.entry_ty in ('SB') then 'Yes' else 'No' end)=@sProvider /*Provider*/
			and (case when m.entry_ty in ('SB') then 'No' else 'Yes' end)=@sReceiver /*Receiver*/

			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','2','J','0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)

			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','2','K','0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			if @sProvider='Yes'
			begin
				select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
				select
				@amt1=sum(case when (date between @sdate1 and @edate1) then isnull(acl.amount,0) else 0 end)
				,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(acl.amount,0) else 0 end)
				,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(acl.amount,0) else 0 end)
				,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(acl.amount,0) else 0 end)
				,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(acl.amount,0) else 0 end)
				,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(acl.amount,0) else 0 end)
				from SerTaxMain_vw m/*sbmain m TKT-794 GTA*/
				inner join acdetalloc acl on (m.entry_ty=acl.entry_ty and m.tran_cd=acl.tran_cd)
				inner join #SerTax_Mast sm on (acl.serty=sm.[name])
				where m.entry_ty in ('SB') 
				and (date between @sdate and @edate)
				and sm.serty=@serty
				and m.SerRule='EXPORT'
				select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
				insert into #st3
				(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
				,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
				,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
				,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
				)
				values
				('',@serty,'3','F','2','L','0',''
				,0,0,0,0,0,0
				,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
				,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
				)
			end

			select @SrNo4=case when @sProvider='Yes' then 'M' else 'L' end
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select
			@amt1=sum(case when (date between @sdate1 and @edate1) then isnull(acl.amount,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(acl.amount,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(acl.amount,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(acl.amount,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(acl.amount,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(acl.amount,0) else 0 end)
			from SerTaxMain_vw m/*sbmain m TKT-794 GTA*/
			inner join acdetalloc acl on (m.entry_ty=acl.entry_ty and m.tran_cd=acl.tran_cd)
			inner join #SerTax_Mast sm on (acl.serty=sm.[name])
			where m.entry_ty in ('SB','IF','OF','EP')  
			and (date between @sdate and @edate)
			and sm.serty=@serty
			and m.SerRule='EXEMPTED'
			and (case when m.entry_ty in ('SB') then 'Yes' else 'No' end)=@sProvider /*Provider*/
			and (case when m.entry_ty in ('SB') then 'No' else 'Yes' end)=@sReceiver /*Receiver*/


			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','2',@SrNo4,'0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			
			select @SrNo4=case when @sProvider='Yes' then 'N' else 'M' end
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select
			@amt1=sum(case when (date between @sdate1 and @edate1) then isnull(acl.sExpAmt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(acl.sExpAmt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(acl.sExpAmt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(acl.sExpAmt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(acl.sExpAmt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(acl.sExpAmt,0) else 0 end)
			from SerTaxMain_vw m/*sbmain m TKT-794 GTA*/
			inner join acdetalloc acl on (m.entry_ty=acl.entry_ty and m.tran_cd=acl.tran_cd)
			inner join #SerTax_Mast sm on (acl.serty=sm.[name])
			where m.entry_ty in ('SB','IF','OF','EP')  
			and (date between @sdate and @edate)
			and sm.serty=@serty
			and m.SerRule='PURE AGENT'
			and (case when m.entry_ty in ('SB') then 'Yes' else 'No' end)=@sProvider /*Provider*/
			and (case when m.entry_ty in ('SB') then 'No' else 'Yes' end)=@sReceiver /*Receiver*/


			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','2',@SrNo4,'0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			
			select @SrNo4=case when @sProvider='Yes' then 'O' else 'N' end
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select
			@amt1=sum(case when (date between @sdate1 and @edate1) then isnull(acl.sAbtAmt,0) else 0 end)
			,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(acl.sAbtAmt,0) else 0 end)
			,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(acl.sAbtAmt,0) else 0 end)
			,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(acl.sAbtAmt,0) else 0 end)
			,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(acl.sAbtAmt,0) else 0 end)
			,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(acl.sAbtAmt,0) else 0 end)
			from SerTaxMain_vw m/*sbmain m TKT-794 GTA*/
			inner join acdetalloc acl on (m.entry_ty=acl.entry_ty and m.tran_cd=acl.tran_cd)
			inner join #SerTax_Mast sm on (acl.serty=sm.[name])
			where m.entry_ty in ('SB','IF','OF','EP')  
			and (date between @sdate and @edate)
			and sm.serty=@serty
			and (case when m.entry_ty in ('SB') then 'Yes' else 'No' end)=@sProvider /*Provider*/
			and (case when m.entry_ty in ('SB') then 'No' else 'Yes' end)=@sReceiver /*Receiver*/


			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','2',@SrNo4,'0',''
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
			)
			
			select @SrNo4=case when @sProvider='Yes' then 'P' else 'O' end	
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			select 
			 @amt1=sum(case when srno4 in('J','K') then amt1 else -amt1 end )
			,@amt2=sum(case when srno4 in('J','K') then amt2 else -amt2 end ) 
			,@amt3=sum(case when srno4 in('J','K') then amt3 else -amt3 end )
			,@amt4=sum(case when srno4 in('J','K') then amt4 else -amt4 end )
			,@amt5=sum(case when srno4 in('J','K') then amt5 else -amt5 end )
			,@amt6=sum(case when srno4 in('J','K') then amt6 else -amt6 end )
			/*,@amt6=sum(case when  serty=@serty and srno1='3' and srno2='F' and srno3='1' Then ( case when srno4 in('A','B') then amt6 else -amt6 end ) else 0 end)*/
			from #st3 where serty=@serty and srno1='3' and srno2='F' and srno3='2'  AND SRNO4 IN ('J','K','L','M','N','O')
			and sProvider=@sProvider /*Provider*/
			and sReceiver=@sReceiver /*Receiver*/
	

			select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
			)
			values
			('',@serty,'3','F','2',@SrNo4,'0',' '
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@SabtNoti,@SabtSr,@SSubCls,@SExNoti,@sProvider,@sReceiver
			)

			/*<--3F 2*/
		end /*while i=<2*/
	/*Blank Records--->*/	
	if not exists(select serty from #st3 where serty=@serty and srno1='3' and srno2='C' and srno3='2')
	begin
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
		)
		values
		('',@serty,'3','C','2','','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,0,0,0,0,0,0
		,'','','','','',''
		)
	end
	if not exists(select serty from #st3 where serty=@serty and srno1='3' and srno2='D' and srno3='0')
	begin
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6,SabtNoti,SabtSr,SSubCls,SExNoti,sProvider,sReceiver
		)
		values
		('',@serty,'3','D','0','','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,0,0,0,0,0,0
		,'','','','','',''
		)
	end
	
	
	/*<--Blank Records*/	
	fetch next from cur_serty into @serty
--,@SabtNoti,@SabtSr,@SSubCls,@SExNoti,@sProvider,@sReceiver
end--while (@@fetch_status=0)
close cur_serty
deallocate cur_serty /*Repetable Part Over*/
/*<---3F*/

/*--->4*/
	/*-->4 1&2*/
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select
	@amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable','GTA Service Tax Payable','Edu. Cess on Service Tax Payable','GTA Edu. Cess on Service Tax Payable' ,'S & H Cess on Service Tax Payable','GTA S & H Cess on Service Tax Payable') and beh in ('BP','CP') 
	and isnull(u_arrears,'')='Advance Service Tax paid [Rule 6(1A)]'
	/*?replaced and isnull(u_arrears,'')=''*/
	
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6,sProvider,sReceiver
	)
	values
	('','','4','1','','','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6,@sProvider,@sReceiver
	)

	declare cur_st3_2 cursor for
	select distinct date,u_chalno,u_chaldt
	from #bpacdet 
	where ((isnull(u_chalno,'')<>'') or (isnull(u_chaldt,'')<>'') )
	and isnull(u_arrears,'')='Advance Service Tax paid [Rule 6(1A)]'	 /*?Added*/
	order by date
	
	open cur_st3_2
	fetch next from cur_st3_2 into @date,@u_chalno,@u_chaldt
	
	set @c=0
	set @particulars1=' '
	while(@@fetch_status=0)
	begin
		set @c=@c+1
		select @particulars=(case when @c=1 then '(i)' else (case when @c=2 then '(ii)' else (case when @c=3 then '(iii)' else (case when @c=4 then '(iv)' else (case when @c=5 then '(v)' else (case when @c=6 then '(vi)' else (case when @c=7 then '(vii)' else (case when @c=8 then '(viii)' else (case when @c=9 then '(ix)' else (case when @c=10 then '(x)' else '' end) end) end) end) end) end) end) end) end) end)
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6
		,chalno1,chaldt1,chalno2,chaldt2,chalno3,chaldt3,chalno4,chaldt4,chalno5,chaldt5,chalno6,chaldt6
		)
		values
		('','','4','2','','','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
		,(case when (@date between @sdate1 and @edate1) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate1 and @edate1) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate2 and @edate2) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate2 and @edate2) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate3 and @edate3) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate3 and @edate3) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate4 and @edate4) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate4 and @edate4) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate5 and @edate5) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate5 and @edate5) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate6 and @edate6) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate6 and @edate6) then isnull(@u_chaldt,'') else '' end)
		)
		
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6
		,chalno1,chaldt1,chalno2,chaldt2,chalno3,chaldt3,chalno4,chaldt4,chalno5,chaldt5,chalno6,chaldt6
		)
		values
		('','','4','3','','','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
		,(case when (@date between @sdate1 and @edate1) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate1 and @edate1) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate2 and @edate2) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate2 and @edate2) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate3 and @edate3) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate3 and @edate3) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate4 and @edate4) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate4 and @edate4) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate5 and @edate5) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate5 and @edate5) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate6 and @edate6) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate6 and @edate6) then isnull(@u_chaldt,'') else '' end)
		)
		fetch next from cur_st3_2 into @date,@u_chalno,@u_chaldt
	end
	close cur_st3_2
	deallocate cur_st3_2
	
	if not exists(select serty from #st3 where srno1='4' and srno2='2')
	begin
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6
		)
		values
		('','','4','2','','','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,0,0,0,0,0,0
		)
	end
	if not exists(select serty from #st3 where srno1='4' and srno2='3')
	begin
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6
		)
		values
		('','','4','3','','','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,0,0,0,0,0,0
		)
	end
	/*<--4 1&2*/
	/*-->4 A1*/
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','A','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	/*->Service Tax*/
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable','GTA Service Tax Payable') and beh in ('BP','CP') and isnull(u_arrears,' ')=' '
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','A','1',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable','GTA Service Tax Payable') and beh in ('JV') and isnull(u_arrears,' ')=' ' 
	
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','A','2',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable','GTA Service Tax Payable') and isnull(u_arrears,' ')='under Rule 6 (1A)'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','A','2','A'
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable','GTA Service Tax Payable') and isnull(u_arrears,' ')='under Rule 6 (3) of ST Rules'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','A','3',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable','GTA Service Tax Payable') and isnull(u_arrears,' ')='under Rule 6 (4A) of ST Rules'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','A','4',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		
	/*<-Service Tax*/
	/*->Edu. Cess*/
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','B','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Ecess','GTA Service Tax Payable-Ecess') and beh in ('BP','CP') and isnull(u_arrears,' ')=' '
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','B','1',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Ecess','GTA Service Tax Payable-Ecess') and beh in ('JV') and isnull(u_arrears,' ')=' ' 
	
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','B','2',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Ecess','GTA Service Tax Payable-Ecess') and isnull(u_arrears,' ')='under Rule 6 (1A)'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','B','2','A'
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Ecess','GTA Service Tax Payable-Ecess') and isnull(u_arrears,' ')='under Rule 6 (3) of ST Rules'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','B','3',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Ecess','GTA Service Tax Payable-Ecess') and isnull(u_arrears,' ')='under Rule 6 (4A) of ST Rules'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','B','4',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	/*<-Edu. Cess*/
	/*->S & H Cess*/
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','C','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Hcess','GTA Service Tax Payable-Hcess') and beh in ('BP','CP') and isnull(u_arrears,' ')=' '
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','C','1',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Hcess','GTA Service Tax Payable-Hcess') and beh in ('JV') and isnull(u_arrears,' ')=' ' 
	
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','C','2',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Hcess','GTA Service Tax Payable-Hcess') and isnull(u_arrears,' ')='under Rule 6 (1A)'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','C','2','A'
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Hcess','GTA Service Tax Payable-Hcess') and isnull(u_arrears,' ')='under Rule 6 (3) of ST Rules'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','C','3',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where typ in ('Service Tax Payable-Hcess','GTA Service Tax Payable-Hcess') and isnull(u_arrears,' ')='under Rule 6 (4A) of ST Rules'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','C','4',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		
	/*<-S & H Cess*/
	/*4 A D->*/
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where  isnull(u_arrears,' ')='Arrears of revenue paid in cash'

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','1',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where isnull(u_arrears,' ')='Arrears of revenue paid by credit'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','2',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where isnull(u_arrears,' ')='Arrears of education cess paid in cash (Differantial of Cess)'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','3',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where  isnull(u_arrears,' ')='Arrears of education cess paid by credit'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','4',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where  isnull(u_arrears,' ')='Arrears of Sec & higher edu cess paid by cash'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','5',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where isnull(u_arrears,' ')='Arrears of Sec & higher edu cess paid by credit'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','6',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where  isnull(u_arrears,' ')='Interest paid'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','7',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where  isnull(u_arrears,' ')='Penalty paid'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','8',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where isnull(u_arrears,' ')='Section 73A amount paid'
		
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','9',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)		

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (date between @sdate1 and @edate1) then isnull(amount,0) else 0 end)
	,@amt2=sum(case when (date between @sdate2 and @edate2) then isnull(amount,0) else 0 end)
	,@amt3=sum(case when (date between @sdate3 and @edate3) then isnull(amount,0) else 0 end)
	,@amt4=sum(case when (date between @sdate4 and @edate4) then isnull(amount,0) else 0 end)
	,@amt5=sum(case when (date between @sdate5 and @edate5) then isnull(amount,0) else 0 end)
	,@amt6=sum(case when (date between @sdate6 and @edate6) then isnull(amount,0) else 0 end)
	from #bpacdet
	where isnull(u_arrears,'') 
	--not in ('','Arrears of revenue paid in cash','Arrears of revenue paid by credit','Arrears of education cess paid in cash (Differantial of Cess)','Arrears of education cess paid by credit','Arrears of Sec & higher edu cess paid by cash','Arrears of Sec & higher edu cess paid by credit','Interest paid','Penalty paid','Section 73A amount paid') 
	not in ('','Arrears of revenue paid in cash','Arrears of revenue paid by credit','Arrears of Education cess paid in cash (Differential of Cess)','Arrears of education cess paid by credit','Arrears of Sec & higher edu cess paid by cash','Arrears of Sec & higher edu cess paid by credit','Interest paid','Penalty paid','Section 73A amount paid','Any other amount','under Rule 6 (3) of ST Rules','under Rule 6 (4A) of ST Rules')

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','A','1','D','10',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			
	/*<-4 A D*/
	/*<--4 A1*/
	/*-->4 A2 & B */
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','B','0','','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	
	
	

	declare cur_st3_2 cursor for
	select distinct date,u_chalno,u_chaldt,u_arrears,sDocNo,sDocDt
	from #bpacdet 
	where ((isnull(u_chalno,'')<>'') or (isnull(u_chaldt,'')<>'') )
	order by date

	open cur_st3_2
	fetch next from cur_st3_2 into @date,@u_chalno,@u_chaldt,@u_arrears,@sDocNo,@sDocDt
	set @c=0
	set @particulars1=' '
	while(@@fetch_status=0)
	begin
		set @c=@c+1
		select @particulars=(case when @c=1 then '(i)' else (case when @c=2 then '(ii)' else (case when @c=3 then '(iii)' else (case when @c=4 then '(iv)' else (case when @c=5 then '(v)' else (case when @c=6 then '(vi)' else (case when @c=7 then '(vii)' else (case when @c=8 then '(viii)' else (case when @c=9 then '(ix)' else (case when @c=10 then '(x)' else '' end) end) end) end) end) end) end) end) end) end)
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6
		,chalno1,chaldt1,chalno2,chaldt2,chalno3,chaldt3,chalno4,chaldt4,chalno5,chaldt5,chalno6,chaldt6
		)
		values
		(@particulars,'','4','A','2','A','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
		,(case when (@date between @sdate1 and @edate1) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate1 and @edate1) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate2 and @edate2) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate2 and @edate2) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate3 and @edate3) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate3 and @edate3) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate4 and @edate4) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate4 and @edate4) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate5 and @edate5) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate5 and @edate5) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate6 and @edate6) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate6 and @edate6) then isnull(@u_chaldt,'') else '' end)
		)
		
		select @particulars=(case when @c=1 then '(i)' else (case when @c=2 then '(ii)' else (case when @c=3 then '(iii)' else (case when @c=4 then '(iv)' else (case when @c=5 then '(v)' else (case when @c=6 then '(vi)' else (case when @c=7 then '(vii)' else (case when @c=8 then '(viii)' else (case when @c=9 then '(ix)' else (case when @c=10 then '(x)' else '' end) end) end) end) end) end) end) end) end) end)
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6
		,chalno1,chaldt1,chalno2,chaldt2,chalno3,chaldt3,chalno4,chaldt4,chalno5,chaldt5,chalno6,chaldt6
		)
		values
		(@particulars,'','4','A','2','B','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
		,(case when (@date between @sdate1 and @edate1) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate1 and @edate1) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate2 and @edate2) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate2 and @edate2) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate3 and @edate3) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate3 and @edate3) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate4 and @edate4) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate4 and @edate4) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate5 and @edate5) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate5 and @edate5) then isnull(@u_chaldt,'') else '' end)
		,(case when (@date between @sdate6 and @edate6) then isnull(@u_chalno,'') else '' end)
		,(case when (@date between @sdate6 and @edate6) then isnull(@u_chaldt,'') else '' end)
		)

		/*set @particulars=cast(@c as varchar)*/
		if isnull(@u_arrears,'')<>''
		begin
			set @particulars= isnull(@u_arrears,'')
			select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
			insert into #st3
			(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
			,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
			,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
			,amt1,amt2,amt3,amt4,amt5,amt6
			,chalno1,chaldt1,chalno2,chaldt2,chalno3,chaldt3,chalno4,chaldt4,chalno5,chaldt5,chalno6,chaldt6
			,sDocNo,sDocDt
			)
			values
			(@particulars,'','4','B','1',cast(@c as varchar),'',''
			--(@u_arrears,'','4','B','1',@particulars,'',''	
			,0,0,0,0,0,0
			,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
			,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
			,(case when (@date between @sdate1 and @edate1) then isnull(@u_chalno,'') else '' end)
			,(case when (@date between @sdate1 and @edate1) then isnull(@u_chaldt,'') else '' end)
			,(case when (@date between @sdate2 and @edate2) then isnull(@u_chalno,'') else '' end)
			,(case when (@date between @sdate2 and @edate2) then isnull(@u_chaldt,'') else '' end)
			,(case when (@date between @sdate3 and @edate3) then isnull(@u_chalno,'') else '' end)
			,(case when (@date between @sdate3 and @edate3) then isnull(@u_chaldt,'') else '' end)
			,(case when (@date between @sdate4 and @edate4) then isnull(@u_chalno,'') else '' end)
			,(case when (@date between @sdate4 and @edate4) then isnull(@u_chaldt,'') else '' end)
			,(case when (@date between @sdate5 and @edate5) then isnull(@u_chalno,'') else '' end)
			,(case when (@date between @sdate5 and @edate5) then isnull(@u_chaldt,'') else '' end)
			,(case when (@date between @sdate6 and @edate6) then isnull(@u_chalno,'') else '' end)
			,(case when (@date between @sdate6 and @edate6) then isnull(@u_chaldt,'') else '' end)
			,isnull(@sDocNo,''),isnull(@sDocDt,'')

			--,@u_chalno,@u_chaldt,'','','','',''
			)
		end
			
		fetch next from cur_st3_2 into @date,@u_chalno,@u_chaldt,@u_arrears,@sDocNo,@sDocDt
	end
	close cur_st3_2
	deallocate cur_st3_2
	if not exists(select serty from #st3 where srno1='4' and srno2='A' and srno3='2' and srno4='A')
	begin
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6
		)
		values
		('','','4','A','2','A','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,0,0,0,0,0,0
		)
	end
	if not exists(select serty from #st3 where srno1='4' and srno2='A' and srno3='2' and srno4='B')
	begin
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6
		)
		values
		('','','4','A','2','B','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,0,0,0,0,0,0
		)
	end
	if not exists(select serty from #st3 where srno1='4' and srno2='B' and srno3='1')
	begin
		insert into #st3
		(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
		,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
		,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
		,amt1,amt2,amt3,amt4,amt5,amt6
		,sDocNo,sDocDt
		)
		values
		('','','4','B','1','','',''
		,0,0,0,0,0,0
		,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
		,0,0,0,0,0,0
		,'',''
		)
	end


	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when srno1+srno2='4A' then -amt1 else amt1 end )
	,@amt2=sum(case when srno1+srno2='4A' then -amt2 else amt2 end ) 
	,@amt3=sum(case when srno1+srno2='4A' then -amt3 else amt3 end )
	,@amt4=sum(case when srno1+srno2='4A' then -amt4 else amt4 end )
	,@amt5=sum(case when srno1+srno2='4A' then -amt5 else amt5 end )
	,@amt6=sum(case when srno1+srno2='4A' then -amt6 else amt6 end )
	/*,@amt6=sum(case when  serty=@serty and srno1='3' and srno2='F' and srno3='1' Then ( case when srno4 in('A','B') then amt6 else -amt6 end ) else 0 end)*/
	from #st3 where 
		(
		(srno1='3' and srno2='F' and srno3='1'  AND SRNO4 IN ('G','H','I')) or
		(srno1='4' and srno2='A')
		)			
	
--	select * from #st3 where (srno1='3' and srno2='F' and srno3='1'  AND SRNO4 IN ('G','H','I'))
--	select * from #st3 where (srno1='4' and srno2='A')

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)

	insert into #st3 
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','4','C','0','','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)


	/*<--4 A2 & B */
/*<---4*/

/*5A--->*/
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','A','0','','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('No','','5','A','A','','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('No','','5','A','B','','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('No','','5','A','C','','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('No','','5','A','D','1','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('No','','5','A','D','2','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
/*<---5A*/

/*--->5AA*/
select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','A','Z','0','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)


	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','A','Z','A','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','A','Z','B','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','A','Z','C','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','A','Z','D','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','A','Z','E','',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	,chalno1,chaldt1,chalno2,chaldt2,chalno3,chaldt3,chalno4,chaldt4,chalno5,chaldt5,chalno6,chaldt6
	)
	values
	(@particulars,'','5','A','Z','F','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	/*,(case when (@date between @sdate1 and @edate1) then isnull(@u_chalno,'') else '' end) */
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	)
	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	,chalno1,chaldt1,chalno2,chaldt2,chalno3,chaldt3,chalno4,chaldt4,chalno5,chaldt5,chalno6,chaldt6
	)
	values
	(@particulars,'','5','A','Z','G','',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	/*,(case when (@date between @sdate1 and @edate1) then isnull(@u_chalno,'') else '' end) */
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	,'' 
	)
/*<---5AA*/
/*--->5B*/
	/*-->5B 1*/
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (beh='OB' or date<@sdate1) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt2=sum(case when (beh='OB' or date<@sdate2) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt3=sum(case when (beh='OB' or date<@sdate3) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt4=sum(case when (beh='OB' or date<@sdate4) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt5=sum(case when (beh='OB' or date<@sdate5) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt6=sum(case when (beh='OB' or date<@sdate6) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	from #st3_5b
	where  (date<=@edate) and (typ='Service Tax Available') and @isdprouct=0--(serty=@serty) and

	

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','A','0',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			
	
	--5b1b
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','B','0',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available')  
	and (sertype in ('Credit taken On input')) 
	and @isdprouct=0--(serty=@serty) and

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','B','1',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available') 
	and (sertype='Credit taken On capital goods') and @isdprouct=0--(serty=@serty) and

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','B','2',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available') and @isdprouct=0--(serty=@serty)
	and sertype=''

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','B','3',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available') and @isdprouct=0--(serty=@serty) and
	and (sertype ='Credit taken As received from input service distributor')

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','B','4',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available') 
	and (sertype='Credit taken From inter unit transfer by a LTU*') 
	and @isdprouct=0 --(serty=@serty) and

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','B','5',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(isnull(amt1,0))
	,@amt2=sum(isnull(amt2,0))
	,@amt3=sum(isnull(amt3,0))
	,@amt4=sum(isnull(amt4,0))
	,@amt5=sum(isnull(amt5,0))
	,@amt6=sum(isnull(amt6,0))
	from #st3 where  srno1='5' and srno2='B' and srno3='1' and srno4='B' and srno5<>'6'
	--,@amt4=sum(case when srno4 in('J','K') then amt4 else -amt4 end )

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','B','6',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	--5B1B
		--5B1C
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','C','0',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available')  and sertype not like 'Credit utilized%' and @isdprouct=0--(sertype'') --(serty=@serty) and

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','C','1',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available') and @isdprouct=0 and (sertype='Credit utilized For payment of education cess on taxable service') --(serty=@serty) and

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','C','2',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			
	--select * from #st3_5b

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available') and @isdprouct=0 --(serty=@serty) and
	and (sertype='Credit utilized For payment of excise or any other duty')

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','C','3',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

 	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available') and @isdprouct=0 and (sertype='Credit utilized Towards clearance of input goods and capital goods removed as such') --(serty=@serty) and

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','C','4',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available') and @isdprouct=0 and (sertype='Credit utilized Towards inter unit transfer of LTU*') --(serty=@serty) and

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','C','5',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where  (typ='Service Tax Available') and @isdprouct=0 and (sertype='Credit utilized for payment under rule 6 (3) of the Cenvat Credit Rules(2004)') --(serty=@serty) and

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','C','6',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)


	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(isnull(amt1,0))
	,@amt2=sum(isnull(amt2,0))
	,@amt3=sum(isnull(amt3,0))
	,@amt4=sum(isnull(amt4,0))
	,@amt5=sum(isnull(amt5,0))
	,@amt6=sum(isnull(amt6,0))
	from #st3 where srno1='5' and srno2='B' and srno3='1' and srno4='C' and srno5<>'7'
	--,@amt4=sum(case when srno4 in('J','K') then amt4 else -amt4 end )

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','C','7',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	--5B1C
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when srno4 in('A','B') then isnull(amt1,0) else -isnull(amt1,0) end)
	,@amt2=sum(case when srno4 in('A','B') then isnull(amt2,0) else -isnull(amt2,0) end)
	,@amt3=sum(case when srno4 in('A','B') then isnull(amt3,0) else -isnull(amt3,0) end)
	,@amt4=sum(case when srno4 in('A','B') then isnull(amt4,0) else -isnull(amt4,0) end)
	,@amt5=sum(case when srno4 in('A','B') then isnull(amt5,0) else -isnull(amt5,0) end)
	,@amt6=sum(case when srno4 in('A','B') then isnull(amt6,0) else -isnull(amt6,0) end)
	from #st3 where srno1='5' and srno2='B' and srno3='1' and (srno4 in('A') or (srno4 in('B') and srno5='6') or (srno4 in('C') and srno5='7') ) --and srno4 in('A','B','C') and srno5<>'7'
	

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','1','D','0',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	/*<--5B 1*/
	/*-->5B 2*/
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when (beh='OB' or date<@sdate1) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt2=sum(case when (beh='OB' or date<@sdate2) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt3=sum(case when (beh='OB' or date<@sdate3) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt4=sum(case when (beh='OB' or date<@sdate4) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt5=sum(case when (beh='OB' or date<@sdate5) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	,@amt6=sum(case when (beh='OB' or date<@sdate6) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
	from #st3_5b
	where (date<=@edate1) and @isdprouct=0 and ( typ in('Service Tax Available-Ecess','Service Tax Available-Hcess') )
 
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','A','0',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			
	
	--5b2b
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','B','0',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess'))  and @isdprouct=0 and (sertype='Credit taken On input')

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','B','1',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess')) and @isdprouct=0 and (sertype='Credit taken On capital goods') 

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','B','2',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess')) and @isdprouct=0
	and sertype=''

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','B','3',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess')) and @isdprouct=0
	and (sertype ='Credit taken As received from input service distributor')

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','B','4',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
	from #st3_5b
	where  (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess')) and @isdprouct=0 and (sertype='Credit taken From inter unit transfer by a LTU*') 

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','B','5',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(isnull(amt1,0))
	,@amt2=sum(isnull(amt2,0))
	,@amt3=sum(isnull(amt3,0))
	,@amt4=sum(isnull(amt4,0))
	,@amt5=sum(isnull(amt5,0))
	,@amt6=sum(isnull(amt6,0))
	from #st3 where  srno1='5' and srno2='B' and srno3='2' and srno4='B' and srno5<>'6'
	--,@amt4=sum(case when srno4 in('J','K') then amt4 else -amt4 end )

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','B','6',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	--5B2B
	--5B2C
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','C','0',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess')) and @isdprouct=0
	and (sertype='') 
	--and (sertype not in ('Credit utilized For payment of education cess and secondary and higher education cess on goods','Credit utilized Towards payment of education cess and secondary and higher education cess on clearance of input goods and capital goods removed as such','Credit utilized Towards inter unit transfer of LTU*')) 

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','C','1',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess'))  and @isdprouct=0
	and (sertype='Credit utilized For payment of education cess and secondary and higher education cess on goods') 

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0--Not Known
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','C','2',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess')) and @isdprouct=0
	and (sertype ='Credit utilized For Towards payment of education cess and secondary and higher education cess on clearance of input goods and capital goods removed as such') 

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','C','3',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
	,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
	,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
	,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
	,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
	,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
	from #st3_5b
	where  (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess'))  and @isdprouct=0
	and (sertype='Credit utilized Towards inter unit transfer of LTU*') 
	

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','C','4',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(isnull(amt1,0))
	,@amt2=sum(isnull(amt2,0))
	,@amt3=sum(isnull(amt3,0))
	,@amt4=sum(isnull(amt4,0))
	,@amt5=sum(isnull(amt5,0))
	,@amt6=sum(isnull(amt6,0))
	from #st3 where  srno1='5' and srno2='B' and srno3='2' and srno4='C' and srno5<>'5'

	--,@amt4=sum(case when srno4 in('J','K') then amt4 else -amt4 end )

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','C','5',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	--5B2C

	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when srno4 in('A','B') then isnull(amt1,0) else -isnull(amt1,0) end)
	,@amt2=sum(case when srno4 in('A','B') then isnull(amt2,0) else -isnull(amt2,0) end)
	,@amt3=sum(case when srno4 in('A','B') then isnull(amt3,0) else -isnull(amt3,0) end)
	,@amt4=sum(case when srno4 in('A','B') then isnull(amt4,0) else -isnull(amt4,0) end)
	,@amt5=sum(case when srno4 in('A','B') then isnull(amt5,0) else -isnull(amt5,0) end)
	,@amt6=sum(case when srno4 in('A','B') then isnull(amt6,0) else -isnull(amt6,0) end)
	from #st3 where srno1='5' and srno2='B' and srno3='2' and (srno4 in('A') or (srno4 in('B') and srno5='6') or (srno4 in('C') and srno5='5') )
	--srno1='5' and srno2='B' and srno3='2' and srno4 in('A','B','C') and srno5<>'6'
	--,@amt4=sum(case when srno4 in('J','K') then amt4 else -amt4 end )
	

	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','5','B','2','D','0',' '
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	/*<--5B 2*/
/*<---5B*/
/*--->6*/
	if @isdprouct=1
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
		select 
		@amt1=sum(case when (beh='OB' or date<@sdate1) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt2=sum(case when (beh='OB' or date<@sdate2) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt3=sum(case when (beh='OB' or date<@sdate3) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt4=sum(case when (beh='OB' or date<@sdate4) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt5=sum(case when (beh='OB' or date<@sdate5) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt6=sum(case when (beh='OB' or date<@sdate6) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		from #st3_5b
		where (date<=@edate) and (typ='Service Tax Available') --(serty=@serty) and
	end
	else
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	end
  			
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','1','A','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			
	--601b
	if @isdprouct=1
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
		select 
		@amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
		,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
		,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
		,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
		,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
		,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
		from #st3_5b
		where  (typ='Service Tax Available')

		select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
	end
	else
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	end	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','1','B','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	

	if @isdprouct=1
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
		select 
		@amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
		,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
		,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
		,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
		,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
		,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
		from #st3_5b
		where  (typ='Service Tax Available')
	end
	else
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	end	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','1','C','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','1','D','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when srno4 in('A','B') then isnull(amt1,0) else -isnull(amt1,0) end)
	,@amt2=sum(case when srno4 in('A','B') then isnull(amt2,0) else -isnull(amt2,0) end)
	,@amt3=sum(case when srno4 in('A','B') then isnull(amt3,0) else -isnull(amt3,0) end)
	,@amt4=sum(case when srno4 in('A','B') then isnull(amt4,0) else -isnull(amt4,0) end)
	,@amt5=sum(case when srno4 in('A','B') then isnull(amt5,0) else -isnull(amt5,0) end)
	,@amt6=sum(case when srno4 in('A','B') then isnull(amt6,0) else -isnull(amt6,0) end)
	from #st3 where srno1='6' and srno2='0' and srno3='1' and (srno4 in('A','B','C','D') )
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','1','E','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

	if @isdprouct=1
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
		select 
		@amt1=sum(case when (beh='OB' or date<@sdate1) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt2=sum(case when (beh='OB' or date<@sdate2) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt3=sum(case when (beh='OB' or date<@sdate3) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt4=sum(case when (beh='OB' or date<@sdate4) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt5=sum(case when (beh='OB' or date<@sdate5) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		,@amt6=sum(case when (beh='OB' or date<@sdate6) then (case when amt_ty='DR' then amount else -amount end) else 0 end)
		from #st3_5b
		where (date<=@edate) and (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess'))
	end
	else
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	end
  			
	select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','2','A','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)			
	--601b
	if @isdprouct=1
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
		select 
		@amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='DR') then  amount else  0 end)
		,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='DR') then  amount else  0 end) 
		,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='DR') then  amount else  0 end)
		,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='DR') then  amount else  0 end)
		,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='DR') then  amount else  0 end)
		,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='DR') then  amount else  0 end)
		from #st3_5b
		where  (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess'))

		select @amt1=isnull(@amt1,0),@amt2=isnull(@amt2,0),@amt3=isnull(@amt3,0),@amt4=isnull(@amt4,0),@amt5=isnull(@amt5,0),@amt6=isnull(@amt6,0)
	end
	else
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	end	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','2','B','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)	

	if @isdprouct=1
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
		select 
		@amt1=sum(case when entry_ty<>'OB' and  (date between @sdate1 and @edate1) and (amt_ty='CR') then  amount else  0 end)
		,@amt2=sum(case when entry_ty<>'OB' and  (date between @sdate2 and @edate2) and (amt_ty='CR') then  amount else  0 end) 
		,@amt3=sum(case when entry_ty<>'OB' and  (date between @sdate3 and @edate3) and (amt_ty='CR') then  amount else  0 end)
		,@amt4=sum(case when entry_ty<>'OB' and  (date between @sdate4 and @edate4) and (amt_ty='CR') then  amount else  0 end)
		,@amt5=sum(case when entry_ty<>'OB' and  (date between @sdate5 and @edate5) and (amt_ty='CR') then  amount else  0 end)
		,@amt6=sum(case when entry_ty<>'OB' and  (date between @sdate6 and @edate6) and (amt_ty='CR') then  amount else  0 end)
		from #st3_5b
		where  (typ in('Service Tax Available-Ecess','Service Tax Available-Hcess'))
	end
	else
	begin
		select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	end	
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','2','C','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','2','D','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)
	
	select @amt1=0,@amt2=0,@amt3=0,@amt4=0,@amt5=0,@amt6=0
	select 
	 @amt1=sum(case when srno4 in('A','B') then isnull(amt1,0) else -isnull(amt1,0) end)
	,@amt2=sum(case when srno4 in('A','B') then isnull(amt2,0) else -isnull(amt2,0) end)
	,@amt3=sum(case when srno4 in('A','B') then isnull(amt3,0) else -isnull(amt3,0) end)
	,@amt4=sum(case when srno4 in('A','B') then isnull(amt4,0) else -isnull(amt4,0) end)
	,@amt5=sum(case when srno4 in('A','B') then isnull(amt5,0) else -isnull(amt5,0) end)
	,@amt6=sum(case when srno4 in('A','B') then isnull(amt6,0) else -isnull(amt6,0) end)
	from #st3 where srno1='6' and srno2='0' and srno3='2' and (srno4 in('A','B','C','D') )
	insert into #st3
	(particulars,serty,srno1,srno2,srno3,srno4,srno5,srno6
	,SERBPER,SERBAMT,SERCPER,SERCAMT,SERHPER,SERHAMT
	,sdate1,sdate2,sdate3,sdate4,sdate5,sdate6
	,amt1,amt2,amt3,amt4,amt5,amt6
	)
	values
	('','','6','0','2','E','0',''
	,0,0,0,0,0,0
	,@sdate1,@sdate2,@sdate3,@sdate4,@sdate5,@sdate6
	,@amt1,@amt2,@amt3,@amt4,@amt5,@amt6
	)

/*<---6*/


select SrNo=srno1+srno2+srno3+srno4+srno5+srno6,tAmt1=amt1+amt2+amt3,tAmt2=amt4+amt5+amt6
,tChalNo1=ChalNo1+ChalNo2+ChalNo3,tChalNo2=ChalNo4+ChalNo5+ChalNo6
,srno1,srno2,srno3,srno4,srno5,srno6,amt1,amt2,amt3,amt4,amt5,amt6
,ChalNo1,ChalNo2,ChalNo3,ChalNo4,ChalNo5,ChalNo6
,ChalDt1,ChalDt2,ChalDt3,ChalNo4,ChalNo5,ChalNo6
--,tChalDt=ChalDt1+ChalDt2+ChalDt3,tChalNo2=ChalNo4+ChalNo5+ChalNo6
, L_YN=substring(@LYN,1,4)+'-'+substring(@LYN,8,2),a.* ,b.code
from #st3 a
left join #SerTax_Mast b on (a.serty=b.serty)
--where srno1+srno2+srno3+srno4+srno5='4A1A1'
order by (case when srno1='3' then a.serty else 'z' end)
-- commented by suraj k on date 28-02-2015 for bug-25365  start
--,srno1,srno2,isnull(sReceiver,''),srno3,srno4,cast(srno5 as int),srno6 
--,ChalDt1,ChalDt2,ChalDt3,ChalNo4,ChalNo5,ChalNo6
-- commented by suraj k on date 28-02-2015 for bug-25365  end
-- added by suraj k on date 28-02-2015 for bug-25365  start
,a.srno1,a.srno2,isnull(sReceiver,''),a.srno3,a.srno4,cast(a.srno5 as int),a.srno6 
,a.ChalDt1,a.ChalDt2,a.ChalDt3,a.ChalNo4,a.ChalNo5,a.ChalNo6
-- added by suraj k on date 28-02-2015 for bug-25365  end



/*ORDER BY SRNO1,SRNO2,SRNO3,SRNO4,SRNO5
select * from #bracdet
select * from #bracdet where typ like '%out%' order by tran_cd*/
end--sp


/*print '@sdate1= '+cast(@sdate1 as varchar)
print @edate1
print '@sdate2= '+cast(@sdate2 as varchar)
print @edate2
print '@sdate3= '+cast(@sdate3 as varchar)
print @edate3
print '@sdate4= '+cast(@sdate4 as varchar)
print @edate4
print '@sdate5= '+cast(@sdate5 as varchar)
print @edate5
print '@sdate6= '+cast(@sdate6 as varchar)
print @edate6*/



























