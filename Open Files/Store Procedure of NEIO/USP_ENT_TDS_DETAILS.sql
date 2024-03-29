DROP PROCEDURE [USP_ENT_TDS_DETAILS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 18/06/2009
-- Description:	This Stored procedure is useful in Auto TDS BILL SELECTION  project uetdspayment.app.
-- Modified By: Rupesh Prajapati
-- Modify date/Reason: 25/06/2008 For Deductee Type Selection
-- Modify date/Reason: 20/01/2011 TKT-5692 Add Para @TdsTcs for TCS
-- Remark:
-- =============================================


CREATE procedure [USP_ENT_TDS_DETAILS]
@entry_ty varchar(2),@tran_cd int ,@date smalldatetime,@dedtype varchar(3),@TdsTcs varchar(3)
as
begin
	declare @sqlcommand nvarchar(4000),@whcon nvarchar(1000)
	set @whcon=''
	if not (@dedtype='' or @dedtype='CFI') and (@dedtype<>'1=2') and @dedtype<>'TCS' /*TKT-5692*/
	begin
		if charindex('C',@dedtype,1)>0
		begin
			set @whcon=rtrim(@whcon)+','+char(39)+'Company'+char(39)  
		end 
		--if charindex('F',@dedtype,1)>0
		--begin
		--	set @whcon=rtrim(@whcon)+','+char(39)+'Partnership Firm'+char(39)  
		--end
		if charindex('I',@dedtype,1)>0
		begin
			set @whcon=rtrim(@whcon)+','+char(39)+'Non-Company'+char(39)  
		end
		--Added by Priyanka B on 14062019 for Bug-31658 Start
		if charindex('B',@dedtype,1)>0
		begin
			set @whcon=rtrim(@whcon)+','+char(39)+'Company'+char(39)+','+char(39)+'Non-Company'+char(39)
		end
		--Added by Priyanka B on 14062019 for Bug-31658 End
		print @whcon
		set @whcon=substring(@whcon,2,len(@whcon)-1)
		set @whcon=' and a1.ded_type in ('+@whcon+')'	
	end
	if @dedtype='1=2'
	begin
		set @whcon='and 1=2'
	end
	--Commented by Shrikant S. on 26/12/2013 for Bug-21184		--Start
	--SELECT DISTINCT SECTION,AC_NAME=RTRIM(SUBSTRING(TDSPOSTING,2,CHARINDEX('"',TDSPOSTING,2)-2)) 
	--INTO #TDSMASTER
	--FROM TDSMASTER WHERE ISNULL(SECTION,SPACE(1))<>SPACE(1)
	--UNION
	--SELECT DISTINCT SECTION,AC_NAME=RTRIM(SUBSTRING(SCPOSTING,2,CHARINDEX('"',SCPOSTING,2)-2)) 
	--FROM TDSMASTER WHERE ISNULL(SECTION,SPACE(1))<>SPACE(1)
	--UNION
	--SELECT DISTINCT SECTION,AC_NAME=RTRIM(SUBSTRING(ECPOSTING,2,CHARINDEX('"',ECPOSTING,2)-2)) 
	--FROM TDSMASTER WHERE ISNULL(SECTION,SPACE(1))<>SPACE(1)
	--UNION
	--SELECT DISTINCT SECTION,AC_NAME=RTRIM(SUBSTRING(HCPOSTING,2,CHARINDEX('"',hCPOSTING,2)-2)) 
	--FROM TDSMASTER WHERE ISNULL(SECTION,SPACE(1))<>SPACE(1)
	--Commented by Shrikant S. on 26/12/2013 for Bug-21184		--End

--Commented by Shrikant S. on 20/04/2017 for GST		--Start
----Added by Shrikant S. on 26/12/2013 for Bug-21184		--Start
--select a.svc_cate,AC_NAME=RTRIM(SUBSTRING(a.TDSPOSTING,2,CHARINDEX('"',a.TDSPOSTING,2)-2))
--		,(Select top 1 Section from TDSMASTER where svc_cate=a.svc_cate and fromdt<=@date  Order by fromdt desc) as Section
--INTO #TDSMASTER	from TDSMASTER a Where a.fromdt<=@date 
--				group by a.svc_cate,a.TDSPOSTING
--UNION ALL
--select a.svc_cate,AC_NAME=RTRIM(SUBSTRING(a.SCPOSTING,2,CHARINDEX('"',a.SCPOSTING,2)-2))
--		,(Select top 1 Section from TDSMASTER where svc_cate=a.svc_cate and fromdt<=@date  Order by fromdt desc) as Section
--	from TDSMASTER a Where a.fromdt<=@date 
--				group by a.svc_cate,a.SCPOSTING
--UNION ALL				
--select a.svc_cate,AC_NAME=RTRIM(SUBSTRING(a.ECPOSTING,2,CHARINDEX('"',a.ECPOSTING,2)-2))
--		,(Select top 1 Section from TDSMASTER where svc_cate=a.svc_cate and fromdt<=@date  Order by fromdt desc) as Section
--	from TDSMASTER a Where a.fromdt<=@date 
--				group by a.svc_cate,a.ECPOSTING
--UNION ALL
--select a.svc_cate,AC_NAME=RTRIM(SUBSTRING(a.HCPOSTING,2,CHARINDEX('"',a.HCPOSTING,2)-2))
--		,(Select top 1 Section from TDSMASTER where svc_cate=a.svc_cate and fromdt<=@date   Order by fromdt desc) as Section
--	from TDSMASTER a Where a.fromdt<=@date 
--				group by a.svc_cate,a.HCPOSTING
--oRDER BY svc_cate,Section
----Added by Shrikant S. on 26/12/2013 for Bug-21184		--End
--Commented by Shrikant S. on 20/04/2017 for GST		--End
	
Declare @fld_nm Varchar(20)
Select svc_cate,AC_NAME=Space(100),Section 
,cast('' as varchar(5)) as CoInBo  --Added by Priyanka B on 14062019 for Bug-31658
INTO #TDSMASTER from TDSMASTER Where 1=2 

Declare tdsCursor cursor for
	Select pert_name From Dcmast Where Entry_ty='E1' and code='X'
	
Open tdsCursor	
Fetch Next From tdsCursor Into @fld_nm
While @@Fetch_status=0
Begin
	set @fld_nm=replace(replace(@fld_nm,'DS_PER','POSTING'),'_TP','POSTING')
	SET @sqlcommand='insert into #TDSMASTER select svc_cate,AC_NAME=REPLACE('+@fld_nm+',''"'',''''),(Select top 1 Section from TDSMASTER where svc_cate=a.svc_cate 
				and fromdt<='''+Convert(varchar(50),@date)+'''   Order by fromdt desc) as Section
				,'+char(39)+@dedtype+char(39)+'  --Added by Priyanka B on 14062019 for Bug-31658
					from TDSMASTER a Where fromdt<='''+Convert(varchar(50),@date)+'''
						group by svc_cate,'+@fld_nm+' oRDER BY svc_cate,Section'
	print @sqlcommand
	execute sp_executesql @sqlcommand
							
	Fetch Next From tdsCursor Into @fld_nm
End
Close tdsCursor 
Deallocate tdsCursor

	select entry_all,main_tran,acseri_all,new_all=sum(new_all) 
	into #mall 
	from mainall_vw 
	where ( entry_ty+rtrim(cast(tran_cd as varchar)) ) <> ( @entry_ty+rtrim(cast(@tran_cd as varchar)) )
	group by entry_all,main_tran,acseri_all

	select sel=cast(0 as bit),t.section,ac.entry_ty,ac.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=ac.amount
	,ac.amt_ty,a.typ
	,party_nm=a.ac_name,m.pinvno,m.pinvdt,m.inv_no,m.date,tpayment=cast(0 as decimal(17,2))
	,m.l_yn,ac.ac_id,m.compid,m.inv_sr,m.net_amt
	,a.ded_type,isused=3
	,cast('' as varchar(5)) as CoInBo  --Added by Priyanka B on 14062019 for Bug-31658
	into #tdsdetails
	from lac_vw ac 
	inner join ac_mast a on (a.ac_id=ac.ac_id)
	inner join lmain_vw m on (ac.entry_ty=m.entry_ty and ac.tran_cd=m.tran_cd)
--	inner join ac_mast a1 on (a1.ac_id=m.ac_id)
	LEFT JOIN #TDSMASTER T on (T.AC_NAME=A.AC_NAME)   
--	left join #mall mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all)
	where 1=2

--select * from #TDSMASTER
--select * from #mall

	set @sqlcommand='insert into #tdsdetails'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'select sel=cast(0 as bit),t.section,ac.entry_ty,ac.tran_cd,ac.acserial,a.ac_name,ac.amount,new_all=isnull(mall.new_all,0)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.amt_ty,a.typ'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',party_nm=a1.ac_name,m.pinvno,m.pinvdt,m.inv_no,m.date,tpayment=cast(0 as decimal(17,2))'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',m.l_yn,ac.ac_id,m.compid,m.inv_sr,m.net_amt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',a1.ded_type,isused=0'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',case when upper(a1.ded_type)=''COMPANY'' then ''CF'' else (case when upper(a1.ded_type)=''NON-COMPANY'' then ''I'' else '''' end) end'  --Added by Priyanka B on 17062019 for Bug-31658
	set @sqlcommand=rtrim(@sqlcommand)+' '+'from lac_vw ac '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast a on (a.ac_id=ac.ac_id)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join lmain_vw m on (ac.entry_ty=m.entry_ty and ac.tran_cd=m.tran_cd)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast a1 on (a1.ac_id=m.ac_id)'
	--set @sqlcommand=rtrim(@sqlcommand)+' '+'LEFT JOIN #TDSMASTER T on (T.AC_NAME=A.AC_NAME)'		--Commented by Shrikant S. on 26/12/2013 for Bug-21184		
	set @SqlCommand=RTRIM(@SqlCommand)+' '+'LEFT join #TDSMASTER t on (a1.svc_cate=t.svc_cate and t.ac_name=a.ac_name)'		--Added by Shrikant S. on 26/12/2013 for Bug-21184		
	set @sqlcommand=rtrim(@sqlcommand)+' '+'left join #mall mall on(ac.entry_ty=mall.entry_all and ac.tran_cd=main_tran and ac.acserial=acseri_all)'
	if @TdsTcs='TDS' /*Add if else for TKT-5692*/
	begin
		set @sqlcommand=rtrim(@sqlcommand)+' '+'where a.typ in (''TDS'')'
	end
	else
	begin
		set @sqlcommand=rtrim(@sqlcommand)+' '+'where a.typ in (''TCS'')'
	end
	/*set @sqlcommand=rtrim(@sqlcommand)+' '+'where a.typ in (''TDS'',''TDS-SUR'',''TDS-ECESS'',''TDS-HCESS'')' TKT-5692*/
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and ac.amt_ty=''CR'' '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and ac.amount<>isnull(mall.new_all,0)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'and ac.date<='+char(39)+cast(@date as varchar)+char(39)
	set @sqlcommand=rtrim(@sqlcommand)+' '+@whcon
	print @sqlcommand
	execute sp_executesql @sqlcommand

	select entry_all,main_tran into #tm from mainall_vw where entry_ty+cast(tran_cd as varchar) in (@entry_ty+cast(@tran_cd as varchar))
	update a set a.isused=1 from #tdsdetails a inner join #tm b on (a.entry_ty=b.entry_all and a.tran_cd=b.main_tran)

	select * from #tdsdetails 
		
	--where entry_ty+cast(tran_cd) in (select * from main_all vw )
	
	drop table #tdsdetails
end
GO
