If Exists (Select [Name] from SysObjects Where xType='P' and [Name]='Usp_Ent_ISDBill_accrual')
Begin
	Drop Procedure Usp_Ent_ISDBill_accrual
End
go
-- =============================================  
-- Author:  Shrikant S. 
-- Create date: 27/07/2012  
-- Description: This Stored procedure is useful in ISD bill Entry Module.  
-- Modified By:date:Shrikant S. 27/07/2012. 
-- Remark:  
-- =============================================  
create procedure [dbo].[Usp_Ent_ISDBill_accrual]  
@entry_ty varchar(2),@tran_cd int,@date smalldatetime  
as  

begin  
   
	Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)


	select m.date,m.entry_ty,m.tran_cd,acl.Serty,Amount=sum(isnull(acl.Amount,0)),sTaxable=sum(isnull(acl.sTaxable,0)),SerBAmt=sum(isnull(acl.SerBAmt,0)),SerCAmt=sum(isnull(acl.SerCAmt,0)),SerHAmt=sum(isnull(acl.SerHAmt,0))
	into #acl1
	from acdetalloc acl 
	inner join SerTaxMain_vw m on (acl.entry_ty=m.entry_ty and acl.tran_cd=m.tran_cd)
	where  m.date<=@date and acl.SerTy<>'OTHERS' and acl.SerAvail='SERVICES' and acl.entry_ty not in ('S1') 
	group by m.date,m.entry_ty,m.tran_cd,acl.Serty
	
	select isd.aentry_ty,isd.atran_cd,isd.Serty,Amount=sum(isnull(isd.Amount,0)),sTaxable=sum(isnull(isd.sTaxable,0)),SerBAmt=sum(isnull(isd.SerBAmt,0)),SerCAmt=sum(isnull(isd.SerCAmt,0)),SerHAmt=sum(isnull(isd.SerHAmt,0))
	into #isd1
	from isdallocation isd 
	inner join SerTaxMain_vw m on (isd.entry_ty=m.entry_ty and isd.tran_cd=m.tran_cd)
	where m.date<=@date 
	group by isd.aentry_ty,isd.atran_cd,isd.Serty
	
	--select 'b',* from #isd1


	insert into #acl1 (entry_ty,tran_cd,serty,Amount,sTaxable,SerBAmt,SerCAmt,SerHAmt,date)
	select ac.entry_ty,ac.tran_cd,jm.Serty
	,Amount=(case when jm.entry_ty in ('J3') then jm.sTaxable else 0 end),sTaxable=(case when jm.entry_ty in ('J3') then jm.sTaxable else 0 end)
	,SerBAmt=sum(case when a.typ='Service Tax Available' then ac.amount else 0 end)
	,SerCAmt=sum(case when a.typ='Service Tax Available-Ecess' then ac.amount else 0 end)
	,SerHAmt=sum(case when a.typ='Service Tax Available-Hcess' then ac.amount else 0 end)
	,(case when (m.entry_ty in ('J3')) then ac.u_cldt else m.date end)
	from SerTaxAcDet_vw ac 
	inner join SerTaxMain_vw m on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
	inner join ac_mast a on (ac.ac_id=a.ac_id) 
	left join JvMain jm on (jm.entry_ty=ac.entry_ty and jm.tran_cd=ac.tran_cd)
	where ( (case when (m.entry_ty in ('J3')) then ac.u_cldt else m.date end)  <=@date )
	AND ac.amt_ty='Dr' and a.typ in ('Service Tax Available' ,'Service Tax Available-Ecess','Service Tax Available-Hcess')
	and ac.entry_ty not in ('E1','BP','CP')
	group by ac.entry_ty,ac.tran_cd,jm.Serty,(case when (m.entry_ty in ('J3')) then ac.u_cldt else m.date end),jm.entry_ty,jm.sTaxable

--select 'd',* from #acl1

select a.entry_ty,tentry_ty=l.code_nm,a.tran_cd  
,m.date,m.inv_no,a.serty  
,m.serbper  
,m.sercper  
,m.serhper  
,a.serbamt,a.sercamt,a.serhamt,m.u_pinvno,m.u_pinvdt,party_nm=ac.ac_name  
,pserbamt=a.serbamt,psercamt=a.sercamt,pserhamt=a.serhamt /*Service Tax Available As Per Payment*/
 ,lserbamt=isnull(b.serbamt,0)
 ,lsercamt=isnull(b.sercamt,0)
 ,lserhamt=isnull(b.serhamt,0)
 ,aserbamt=(a.serbamt-isnull(b.serbamt,0))  
 ,asercamt=(a.sercamt-isnull(b.sercamt,0))  
 ,aserhamt=(a.serhamt-isnull(b.serhamt,0)) 
 ,sserbamt=m.serbamt  
 ,ssercamt=m.serbamt  
 ,sserhamt=m.serbamt  
,a.Amount,a.sTaxable
Into #isdbill from #acl1 a  
inner join lcode l on (a.entry_ty=l.entry_ty)  
inner join SerTaxMain_vw m on (a.entry_ty=m.entry_ty and a.tran_cd=m.tran_cd)  
inner join ac_mast ac on (m.ac_id=ac.ac_id)  
left join #isd1 b on (b.aentry_ty=m.entry_ty and b.atran_cd=m.tran_cd)

update #isdbill set sserbamt=0,ssercamt=0,sserhamt=0  
  
If @tran_cd =0
Begin
	delete from #isdbill where aserbamt+asercamt+asercamt=0  
End
  
	select sel=cast(0 as bit),* from #isdbill  

end


