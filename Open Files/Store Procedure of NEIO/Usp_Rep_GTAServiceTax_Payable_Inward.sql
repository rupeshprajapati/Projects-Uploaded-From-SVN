
If Exists(Select [name] From SysObjects Where xType='P' and [Name]='Usp_Rep_GTAServiceTax_Payable_Inward')
Begin
	Drop Procedure Usp_Rep_GTAServiceTax_Payable_Inward
End
Go


-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 30/05/2011
-- Description:	This Stored procedure is useful to generate Accrual Basis Service Tax Payable Report.
-- Modification Date/By/Reason: 
-- Remark:
/*
Modification By : Vasant
Modification On : 25-02-2013
Bug Details		: Bug-6092 ( Required "Service Tax REVERSE CHARGE MECHANISM" in our Default Products.)
Search for		: BUG6092
*/
-- =============================================
create procedure [dbo].[Usp_Rep_GTAServiceTax_Payable_Inward]
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
Begin
	Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)
	
	select m.entry_ty,m.tran_cd,m.date,m.inv_no,acl.serty,rdate=m.date 
	,a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt ,taxable_amt=sTaxable,SerBAmt=acl.SerBAmt,SerCAmt=acl.SerCAmt,SerHAmt=acl.SerHAmt 
	into #serpay
	from AcdetAlloc acl inner join SerTaxMain_vw m on (acl.entry_ty=m.entry_ty and acl.tran_cd=m.tran_cd) 
	inner join ac_mast a on (m.ac_id=a.ac_id)   
	WHERE 1=2

	
	EXECUTE USP_REP_FILTCON 
	@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=@SDATE,@VEDATE=@EDATE
	,@VSAC =@SAC,@VEAC =@EAC
	,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT
	,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
	,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE
	,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='m',@VITFILE=Null,@VACFILE='AC'
	,@VDTFLD ='DATE'
	,@VLYN=Null
	,@VEXPARA=@EXPARA
	,@VFCON =@FCON OUTPUT
	
	select m.entry_ty,m.tran_cd,m.date,acl.Serty,Amount=sum(acl.Amount),sTaxable=sum(acl.sTaxable)			--BUG6092
	,SerBAmt=sum((case when m.entry_ty in ('BP','CP','B1','C1') then acl.SerrBAmt else acl.SerBAmt end))	--BUG6092
	,SerCAmt=sum((case when m.entry_ty in ('BP','CP','B1','C1') then acl.SerrCAmt else acl.SerCAmt end))	--BUG6092
	,SerHAmt=sum((case when m.entry_ty in ('BP','CP','B1','C1') then acl.SerrHAmt else acl.SerHAmt end))	--BUG6092
	,SerrBAmt=sum((case when m.entry_ty in ('EP','E1','IF','OF') then acl.SerrBAmt else 0 end))				--BUG6092
	,SerrCAmt=sum((case when m.entry_ty in ('EP','E1','IF','OF') then acl.SerrCAmt else 0 end))				--BUG6092
	,SerrHAmt=sum((case when m.entry_ty in ('EP','E1','IF','OF') then acl.SerrHAmt else 0 end))				--BUG6092
	,m.SerRule
	into #acl1
	from acdetalloc acl 
	inner join SerTaxMain_vw m on (acl.entry_ty=m.entry_ty and acl.tran_cd=m.tran_cd)
	where  m.date<@Edate and acl.SerTy='TRANSPORT OF GOODS BY ROAD INWARD'	--BUG6092
	--and 1=(case when acl.entry_ty='S1' or (acl.entry_ty in('BP','CP') and m.tdspaytype=2) then 1 else 0 end)
	group by m.entry_ty,m.tran_cd,m.date,acl.Serty,m.SerRule											--BUG6092
	
	--select 'a',* from #acl1

	select m.entry_ty,m.tran_cd,isd.Serty,Amount=sum(isd.Amount),sTaxable=sum(isd.sTaxable)
	,SerBAmt=sum(isd.SerBAmt)
	,SerCAmt=sum(isd.SerCAmt)
	,SerHAmt=sum(isd.SerHAmt)
	into #isd1
	from isdallocation isd 
	inner join SerTaxMain_vw m on (isd.entry_ty=m.entry_ty and isd.tran_cd=m.tran_cd)
	where m.date<@Edate
	group by m.entry_ty,m.tran_cd,isd.Serty
	
	--select 'i',* from #isd1

	--BUG6092
	select m.entry_ty,m.tran_cd,isd.Serty
	,SerrBAmt=sum(isnull(isd.SerrBAmt,0))
	,SerrCAmt=sum(isnull(isd.SerrCAmt,0))
	,SerrHAmt=sum(isnull(isd.SerrHAmt,0))
	into #isd2
	from isdallocation isd 
	inner join SerTaxMain_vw m on (isd.aentry_ty=m.entry_ty and isd.atran_cd=m.tran_cd)
	inner join SerTaxMain_vw b on (isd.entry_ty=b.entry_ty and isd.tran_cd=b.tran_cd)
	where m.date<@Edate and b.date<@Edate 
	group by m.entry_ty,m.tran_cd,isd.Serty
	
	--select 'a2',* from #acl1
	--select 'b',* from #isd2
	
	update #acl1 set 
		SerBAmt = a.SerBAmt+case when a.SerrBAmt > 0 then (case when (@Edate-a.date) > 180 then a.SerrBAmt else isnull(i.SerrBAmt,0) end) else 0 end,--a.SerBAmt end,
		SerCAmt = a.SerCAmt+case when a.SerrCAmt > 0 then (case when (@Edate-a.date) > 180 then a.SerrCAmt else isnull(i.SerrCAmt,0) end) else 0 end,-- a.SerCAmt end,
		SerHAmt = a.SerHAmt+case when a.SerrHAmt > 0 then (case when (@Edate-a.date) > 180 then a.SerrHAmt else isnull(i.SerrHAmt,0) end) else  0 end--a.SerHAmt end 
		from #acl1 a
		left join #isd2 i on (a.entry_ty=i.entry_ty   and a.tran_cd=i.tran_cd and a.serty=i.serty)

	--select 'a1',* from #acl1
	--BUG6092
	
	select a.entry_ty,a.tran_cd,a.serty
	,Amount=a.Amount-isnull(i.amount,0),sTaxable=a.sTaxable-isnull(i.sTaxable,0),SerBAmt=a.SerBAmt-isnull(i.SerBAmt,0),SerCAmt=a.SerCAmt-isnull(i.SerCAmt,0),SerHAmt=a.SerHAmt-isnull(i.SerHAmt,0)
	into #acl
	from #acl1 a 
	left join #isd1 i on (a.entry_ty=i.entry_ty   and a.tran_cd=i.tran_cd and a.serty=i.serty)
	--and a.sTaxable-isnull(i.sTaxable,0)>0.5
	where a.sTaxable-isnull(i.sTaxable,0)>0.5 and a.SerBAmt-isnull(i.SerBAmt,0)>0.5 and not (a.entry_ty in ('E1') and (a.SerRule<>'IMPORT' and a.SerrBAmt = 0))	--BUG6092
	
	--select 'c',* from #acl

	
	set @sqlcommand='select m.entry_ty,m.tran_cd,(case when isnull(m.u_pinvdt,'' '') = '' '' then m.date else m.u_pinvdt end) as date,(case when isnull(m.u_pinvno,'' '') = '' '' then m.inv_no else m.u_pinvno end) as inv_no,acl.serty,rdate=m.date,m.SerRule'	--BUG6092
	set @sqlcommand=rtrim(@sqlcommand)+' '+',a.ac_name,a.add1,a.add2,a.add3,a.SREGN,m.net_amt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',acl.Serty,acl.Amount,acl.sTaxable,acl.SerBAmt,acl.SerCAmt,acl.SerHAmt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'from #acl acl'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join SerTaxMain_vw m on (acl.entry_ty=m.entry_ty and acl.tran_cd=m.tran_cd)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast a on (m.ac_id=a.ac_id)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+rtrim(@fcon)
	set @sqlcommand=rtrim(@sqlcommand)+' '+' and (acl.entry_ty in (''IF'',''B1'',''C1'')) '	--BUG6092
	set @sqlcommand=rtrim(@sqlcommand)+' '+' Order by m.date,m.Entry_ty,M.Inv_No,acl.Serty'

	print  @sqlcommand
	EXECUTE SP_EXECUTESQL @SQLCOMMAND

	
END
