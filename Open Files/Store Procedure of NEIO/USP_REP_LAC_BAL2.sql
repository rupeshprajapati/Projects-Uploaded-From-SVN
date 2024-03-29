DROP PROCEDURE [USP_REP_LAC_BAL2]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [USP_REP_LAC_BAL2]
@TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),@SDATE NVARCHAR(20),@EDATE  NVARCHAR(20),
@SNAME NVARCHAR(60),@ENAME NVARCHAR(60),@SITEM NVARCHAR(60),@EITEM NVARCHAR(60),@SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),
@SCAT NVARCHAR(60),@ECAT NVARCHAR(60),@SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),@SWARE NVARCHAR(60),@EWARE NVARCHAR(60),
@SPLFLD  NVARCHAR(60)
as 

IF @TMPAC <> NULL AND @TMPAC <> ''
BEGIN
	DECLARE @Qstr NVARCHAR(1000)
	SET @Qstr='SELECT * FROM '+@TMPAC
	INSERT #groups EXECUTE (@Qstr)
END
ELSE
BEGIN
	Declare @reccount integer
	Select ac_group_name,[group] into #groups from ac_group_mast where charindex(rtrim(ac_group_name),@SPLFLD ,1)<>0
	Select ac_group_name,[group] into #group1 from #groups
	Set @reccount = 2
	While @reccount>1
	Begin
		select ac_group_name,[group] into #group2 from ac_group_mast 
			where [group] in (select ac_group_name from #group1)
		insert into #groups select * from #group2
		delete from #group1
		insert into #group1 select ac_group_name,[group] from #group2
		drop table #group2
		set @reccount = (select count(ac_group_name) from #group1)
	End
	Drop table #group1
---	Select ac_name,[group] from ac_mast where [group] in (select ac_group_name from #groups group by ac_group_name) order by ac_name
---	Drop table #groups
END

	--------THIS STORED PROCEDURE IS USED FOR BALANCE LISTING--Creditors for Expenses --------------'

	select VW.tran_cd,VW.entry_ty,VW.[date],VW.doc_no,VW.ac_name,
		VW.ac_id,VW.ac_group_name,VW.amt_ty,
		opamtdebit=SUM(case when VW.amt_ty='DR' and (VW.date<cast(@SDATE as datetime)  or VW.entry_ty='OB') then VW.amount end),
		opamtcr=SUM(case when VW.amt_ty='CR' and (cast(VW.date as datetime)<@sdate  or VW.entry_ty='OB') then VW.amount end), 
		debit=SUM(case when VW.amt_ty='DR' and (VW.[date] >=cast(@SDATE as datetime)  and VW.entry_ty <> 'OB') then VW.amount end),
		credit=SUM(case when VW.amt_ty='CR' and (VW.[date] >= cast(@SDATE as datetime)   and VW.entry_ty <> 'OB') then VW.amount end)
	into tmptbls3
	from UVW_LAC_BAL VW
	where UPPER(VW.[group]) IN (select ac_group_name from #groups group by ac_group_name)   and VW.date BETWEEN cast(@SDATE as datetime) and cast( @edate as datetime)
	GROUP BY VW.tran_cd,VW.entry_ty,VW.[date],VW.doc_no,VW.ac_name,VW.ac_id,VW.ac_group_name,VW.[group],VW.amt_ty
	ORDER BY VW.ac_name 

	drop table #groups
	---select ac_name,sum(opamtdebit) as opamtdebit,sum(opamtcr) as opamtcr,sum(debit) as debit,sum(credit) as credit  from tbllacbal2223 group by ac_name order by ac_name

	select ac_name,sum(opamtdebit) as opamtdebit,sum(opamtcr) as opamtcr,sum(debit) as debit,sum(credit) as credit,
		cldebit=isnull(sum(case when (isnull(opamtdebit,0)+isnull(debit,0))-abs(isnull(opamtcr,0)+isnull(credit,0))>0
				 then (isnull(opamtdebit,0)+isnull(debit,0))-(abs(isnull(opamtcr,0)+isnull(credit,0))) end),0),
		clcredit=isnull(sum(abs(case when (isnull(opamtdebit,0)+isnull(debit,0))-abs(isnull(opamtcr,0)+isnull(credit,0))<0
					then abs(isnull(opamtdebit,0)+isnull(debit,0))-(abs(isnull(opamtcr,0)+isnull(credit,0))) end)),0)
	from tmptbls3 group by ac_name order by ac_name
	
	drop  table  tmptbls3
GO
