DROP PROCEDURE [acc_ledger_g]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [acc_ledger_g]

@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND NVARCHAR(500),
@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME,@sparty_nm varchar(50),@eparty_nm varchar(50),
@Sdept CHAR(50),@Edept CHAR(50),@Scate CHAR(50),@Ecate CHAR(50)

as

declare @ety char(2),@qry nvarchar(4000),@entry_ty char(15),@bcode char(2),
@@opbalance decimal(13,2),@insertnm varchar(50),@flag bit

declare @tcd integer, @entryty char(2),@dt smalldatetime,@docno char(5),@dept varchar(20),@amt decimal(15,2),@amt_ty char(2)
declare @acnm varchar(50),@grp varchar(50),@typ varchar(20),@post varchar(20),@pName varchar(50)

select acdet.tran_cd,acdet.ac_name,acdet.amount as debit_amt,acdet.amount as credit_amt,acdet.entry_ty,acdet.[date],
acdet.doc_no,acdet.amount as bal_amt,acdet.amount as dbper,acdet.amount as crper,main.inv_no,acdet.oac_name,
space(50) as co_name,acdet.amt_ty,acdet.narr,main.cheq_no,acdet.clause as b_clause,acdet.narr as oac_name1,
acdet.narr as oac_name2,main.narr as oac_name3,main.pinvno,main.pinvdt into #tbllacstat 
from main,acdet where 1=2

select ac_name into #tblAc_Mast from ac_mast where ac_name between @sParty_Nm and @eParty_Nm
select * into #ac_mast from ac_mast where ac_name between @sParty_Nm and @eParty_Nm

declare curAc_Mast cursor for 
select ac_name,[group],type,posting from #ac_mast order by ac_name

open curAc_Mast
fetch next from curAc_Mast into @acnm,@grp,@typ,@post
while @@fetch_status = 0
begin
	set @flag=0
	execute prc_account_opening_balance @acnm,@sdate,@@opbalance output
	set @insertnm = 'Balance B/f '
	if @@opbalance > 0
	begin
		insert into #tbllacstat (tran_cd,ac_name,debit_amt,credit_amt,entry_ty,date,doc_no,bal_amt,dbper,crper,inv_no,oac_name,
		co_name,amt_ty,narr,cheq_no,b_clause,oac_name1,oac_name2,oac_name3,u_pinvno,u_pinvdt)
		values(0,@acnm,0,@@opbalance,'',@sdate,'',@@opbalance,0,0,'',@insertnm,'','','','','','','','','','')
	end
	else
	begin
		if @@opbalance != 0
		begin
			insert into #tbllacstat (tran_cd,ac_name,debit_amt,credit_amt,entry_ty,date,doc_no,bal_amt,dbper,crper,inv_no,oac_name,
			co_name,amt_ty,narr,cheq_no,b_clause,oac_name1,oac_name2,oac_name3,u_pinvno,u_pinvdt)
			values(0,@acnm,-@@opbalance,0,'',@sdate,'',@@opbalance,0,0,'',@insertnm,'','','','','','','','','','')
		end
	end

	insert into #tbllacstat
	select acdet.tran_cd,acdet.ac_name,
	debit_amt=CASE WHEN amt_ty='DR' then amount else 0 end,credit_amt=CASE WHEN amt_ty='CR' then amount else 0 end,
	acdet.entry_ty,acdet.[date],acdet.doc_no,0 as bal_amt,0 as dbper,0 as crper,
	main.inv_no,acdet.oac_name,space(50) as co_name,acdet.amt_ty,acdet.narr,main.cheq_no,acdet.clause as b_clause,
	'' as oac_name1,acdet.oac_name as oac_name2,main.narr as oac_name3,main.pinvno,main.pinvdt
	from lmain_vw main,lac_vw acdet 
	where acdet.ac_name=@acnm and acdet.entry_ty=main.entry_ty and main.tran_cd=acdet.tran_cd and acdet.date between @sdate and @edate
	
	declare curLacStat cursor for
	select entry_ty,date,doc_no,debit_amt+credit_amt as amount,amt_ty from #tblLacStat where entry_ty<>'' and ac_name=@acnm order by Ac_Name,date
	open curLacStat
	fetch next from curLacStat into @entryty,@dt,@docno,@amt,@amt_ty
	while @@fetch_status = 0
	begin
		if @amt_ty='CR'
		begin
			set @@opbalance = @@opbalance+@amt
			update 	#tblLacStat set bal_amt = @@opbalance where entry_ty=@entryty and date=@dt and doc_no=@docno and credit_amt=@amt
		end
		else
		begin
			set @@opbalance = @@opbalance-@amt
			update 	#tblLacStat set bal_amt = @@opbalance where entry_ty=@entryty and date=@dt and doc_no=@docno and debit_amt=@amt
		end
		print @@opBalance
		fetch next from curLacStat into @entryty,@dt,@docno,@amt,@amt_ty
	end
	set @insertnm = 'Balance C/f '
	if @@opbalance > 0
	begin
		insert into #tbllacstat (tran_cd,ac_name,debit_amt,credit_amt,entry_ty,date,doc_no,bal_amt,dbper,crper,inv_no,oac_name,
		co_name,amt_ty,narr,cheq_no,b_clause,oac_name1,oac_name2,oac_name3,u_pinvno,u_pinvdt)
		values(0,@acnm,0,@@opbalance,'',@edate,'',@@opbalance,0,0,'',@insertnm,'','','','','','','','','','')
	end
	else
	begin
		if @@opbalance != 0
		begin
			insert into #tbllacstat (tran_cd,ac_name,debit_amt,credit_amt,entry_ty,date,doc_no,bal_amt,dbper,crper,inv_no,oac_name,
			co_name,amt_ty,narr,cheq_no,b_clause,oac_name1,oac_name2,oac_name3,u_pinvno,u_pinvdt)
			values(0,@acnm,-@@opbalance,0,'',@edate,'',@@opbalance,0,0,'',@insertnm,'','','','','','','','','','')
		end
	end
	close curLacStat
	deallocate curLacStat
	fetch next from curAc_Mast into @acnm,@grp,@typ,@post
end
close curAc_Mast
deallocate curAc_Mast
select * from #tbllacstat order by ac_name,date
drop table #tbllacstat
drop table #tblAc_Mast
drop table #ac_mast
--drop table opbalval





IF @@ERROR = 0BEGINPRINT 'ACC_LEDGER_G Successfully Created..!'END
GO
