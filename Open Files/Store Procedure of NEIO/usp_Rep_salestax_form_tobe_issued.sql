DROP PROCEDURE [usp_Rep_salestax_form_tobe_issued]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 02/06/2009
-- Description:	This Stored procedure is useful in Pending Sales Tax Form to be issued Report related to Project uestformno.app.
-- Modify date: 
-- Modified By: Rupesh Prajapati
-- Modified by: Shrikant S. on 03/04/2010 for TKT-631
-- Modified By: Shrikant S. on 05/02/2011 for TKT-5455 (For Party filter in reminder letter)
-- Modified By: Amrendra For Bug-83 on 11-11-11 , I did't Get the error provided in the BugZilla, So as Per disscussion had with Sachin and Rupesh, i am merging the SP with solution provided by Dinesh in Bugzilla.
-- modified by: Sandeep for bug-6280 on 12/09/12
-- modified by: SATISH PAL FOR BUG-7280 ON 1/2/2013
-- Remark:		
-- =============================================
Create procedure [usp_Rep_salestax_form_tobe_issued]
@vformnm varchar(30),@vparty varchar(100),@mCondn varchar(100),@vform int, @sdate smalldatetime,@edate smalldatetime
,@dept nvarchar(100),@cate nvarchar(100),@broker nvarchar(100)--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13
as
begin
	--declare @mCondn nvarchar(100)
	--set @mCondn = ' and (isnull(m.form_no,space(1))<>space(1) or isnull(m.form_nm,space(1))<>space(1))'
	declare @sqlcommand nvarchar(4000)
	declare @whcon nvarchar(1000)
	set @mCondn=upper(@mCondn)
	print @mCondn
	set @mCondn='YES' --Hard Coded for pending form to be issued
	set @vform=1 --Hard Coded for form to be issued
	set @whcon=''
	if isnull(@vformnm,'')<>''
	begin
		set @whcon=rtrim(@whcon)+' '+' and (  (isnull(st.form_nm,'''')='+char(39)+@vformnm+char(39)+' or isnull(st.rForm_Nm,'''')='+char(39)+@vformnm+char(39)+')  )'
	end 
	if isnull(@vparty,'')<>''
	begin
		set @whcon=rtrim(@whcon)+' '+' and ( ac.ac_name='+char(39)+@vparty+char(39)+')'
	end 
	if isnull(@vparty,'')<>''
	begin
		set @whcon=rtrim(@whcon)+' '+' and ( ac.ac_name='+char(39)+@vparty+char(39)+')'
	end	
	--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13-START
	if isnull(@dept,'')<>''
	begin
		set @whcon=rtrim(@whcon)+' '+' and ( m.dept='+char(39)+@dept+char(39)+')'
	end 

	if isnull(@cate,'')<>''
	begin
		set @whcon=rtrim(@whcon)+' '+' and ( m.cate='+char(39)+@cate+char(39)+')'
	end
	
	if isnull(@broker,'')<>''
	begin
		set @whcon=rtrim(@whcon)+' '+' and ( m.u_broker='+char(39)+@broker+char(39)+')'
	end
	--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13-END	
	if @mCondn='YES'
	begin
		if (@vform=1)
		begin
		--ADDED AND COMMENTED BY SATISH PAL FOR BUG-7280 DATED 1/2/13-START
			--set @whcon=' and (  (isnull(m.form_nm,SPACE(1))=SPACE(1) and isnull(st.form_nm,SPACE(1))<>SPACE(1))  )'	
			set @whcon=rtrim(@whcon)+' '+' and (  '+'isnull(m.form_nm,'''')='''''+' and isnull(m.form_no,'''')=''''' +'  )'
			--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13-END
		end
		else
		begin
			if (@vform=2)
			begin
				set @whcon=' and (  (isnull(m.form_no,SPACE(1))=SPACE(1) and isnull(st.rform_nm,SPACE(1))<>SPACE(1)) )'
			end
			else--3
			begin
				set @whcon=' and (  (isnull(m.form_no,SPACE(1))=SPACE(1) and isnull(st.rform_nm,SPACE(1))<>SPACE(1))  or (isnull(m.form_nm,SPACE(1))=SPACE(1) and isnull(st.form_nm,SPACE(1))<>SPACE(1))  )'	
			end			
		end
			-- Added by Shrikant S. on 05/02/2011 for TKT-5455		--Start
			if isnull(@vparty,'')<>''
			begin
				set @whcon=rtrim(@whcon)+' '+' and ( ac.ac_name='+char(39)+@vparty+char(39)+')'
			end	
			-- Added by Shrikant S. on 05/02/2011 for TKT-5455		--End
			
		--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13-START
			if isnull(@dept,'')<>''
			begin
				set @whcon=rtrim(@whcon)+' '+' and ( m.dept='+char(39)+@dept+char(39)+')'
			end	
			if isnull(@cate,'')<>''
			begin
				set @whcon=rtrim(@whcon)+' '+' and ( m.cate='+char(39)+@cate+char(39)+')'
			end
	
			if isnull(@broker,'')<>''
			begin
				set @whcon=rtrim(@whcon)+' '+' and ( m.u_broker='+char(39)+@broker+char(39)+')'
			end
		--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13-END
			
	end	
	if @mCondn='NO'
	begin
		if (@vform=1)
		begin
			set @whcon=' and (isnull(m.form_nm,SPACE(1))<>SPACE(1))'
		end
		else
		begin
			if (@vform=2)
			begin
				set @whcon=' and (isnull(m.form_no,SPACE(1))<>SPACE(1) )'
			end
			else--3 'ALL'
			begin
				set @whcon=' and (isnull(m.form_no,SPACE(1))<>SPACE(1) or isnull(m.form_nm,SPACE(1))<>SPACE(1))'
			end			
		end
		
	end	
	if @mCondn='ALL'
	begin
		if (@vform=1)
		begin
			set @whcon=' and (isnull(st.form_nm,SPACE(1))<>SPACE(1))'
		end
		else
		begin
			if (@vform=2)
			begin
				set @whcon=' and (isnull(st.rform_nm,SPACE(1))<>SPACE(1) )'
			end
			else--3
			begin
				set @whcon=' and (isnull(st.form_nm,SPACE(1))<>SPACE(1) or isnull(st.rform_nm,SPACE(1))<>SPACE(1))'
				set @whcon=' '
			end			
		end
		--set @whcon=' and 1=2'
	end	

	--

	select m.entry_ty,m.tran_cd,m.inv_no,m.form_nm,m.form_no,m.date,m.net_amt,m.tax_name,m.taxamt
	,ac.mailname,party_nm=ac.ac_name,formname=st.form_nm,rformname=st.rForm_Nm
	,bcode_nm=case when l.ext_vou=1 then l.bcode_nm else l.entry_ty end
	,code_nm
	,ac.add1,ac.add2,ac.add3,ac.contact,ac.city,ac.zip,ac.state
	,m.formidt,m.formrdt
--	,u_pinvno=m.inv_no,u_pinvdt=m.date  --Commented By Amrendra For Bug-83 on 11-11-11
	--,m.u_pinvno,m.u_pinvdt  --Added By Amrendra For Bug-83 on 11-11-11--commented by  sandeep for bug-6280 on 12/09/12
	,u_pinvno=cast('' as varchar(100)),m.pinvdt  --Added by sandeep for bug-6280 on 12/09/12
	,m.dept,m.cate,m.u_broker--added by satish pal for bug-7280
	into #stax_form
	from stmain m 
	inner join stax_mas st on (m.tax_name=st.tax_name and m.entry_ty=st.entry_ty)
	inner join ac_mast ac on (m.ac_id=ac.ac_id)
	inner join lcode l on (m.entry_ty=l.entry_ty)
	where (isnull(st.form_nm,'')<>'' or isnull(st.rform_nm,'')<>'') and 1=2

	set @sqlcommand='insert into #stax_form'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'select m.entry_ty,m.tran_cd,m.inv_no,m.form_nm,m.form_no,m.date,m.net_amt,m.tax_name,m.taxamt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.mailname,party_nm=ac.ac_name,formname=st.form_nm,rformname=st.rForm_Nm'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bcode_nm=case when l.ext_vou=1 then l.bcode_nm else l.entry_ty end'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',code_nm'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.add1,ac.add2,ac.add3,ac.contact,ac.city,ac.zip,ac.state'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',m.formidt,m.formrdt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',u_pinvno='''',u_pinvdt='''''
	set @sqlcommand=rtrim(@sqlcommand)+' '+',m.dept,m.cate,m.u_broker'--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13
	set @sqlcommand=rtrim(@sqlcommand)+' '+'from stmain m '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join stax_mas st on (m.tax_name=st.tax_name and m.entry_ty=st.entry_ty)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast ac on (m.ac_id=ac.ac_id)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join lcode l on (m.entry_ty=l.entry_ty)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'where (isnull(st.form_nm,space(1))<>space(1) or isnull(st.rform_nm,space(1))<>space(1))'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' and ( m.date between '+char(39)+cast(@sdate as varchar)+char(39)+' and '+char(39)+cast(@edate as varchar)+char(39)+')'+@whcon
	print @sqlcommand
	
	execute sp_executesql @sqlcommand

	set @sqlcommand='insert into #stax_form'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'select m.entry_ty,m.tran_cd,m.inv_no,m.form_nm,m.form_no,m.date,m.net_amt,m.tax_name,m.taxamt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.mailname,party_nm=ac.ac_name,formname=st.form_nm,rformname=st.rForm_Nm'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bcode_nm=case when l.ext_vou=1 then l.bcode_nm else l.entry_ty end'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',code_nm'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.add1,ac.add2,ac.add3,ac.contact,ac.city,ac.zip,ac.state'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',m.formidt,m.formrdt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',M.u_pinvno,M.u_pinvdt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',m.dept,m.cate,m.u_broker'--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13
	set @sqlcommand=rtrim(@sqlcommand)+' '+'from ptmain m '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join stax_mas st on (m.tax_name=st.tax_name and m.entry_ty=st.entry_ty)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast ac on (m.ac_id=ac.ac_id)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join lcode l on (m.entry_ty=l.entry_ty)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'where (isnull(st.form_nm,space(1))<>space(1) or isnull(st.rform_nm,space(1))<>space(1))'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' and ( m.date between '+char(39)+cast(@sdate as varchar)+char(39)+' and '+char(39)+cast(@edate as varchar)+char(39)+')'+@whcon
	print @sqlcommand
	execute sp_executesql @sqlcommand

	set @sqlcommand='insert into #stax_form'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'select m.entry_ty,m.tran_cd,m.inv_no,m.form_nm,m.form_no,m.date,m.net_amt,m.tax_name,m.taxamt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.mailname,party_nm=ac.ac_name,formname=st.form_nm,rformname=st.rForm_Nm'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bcode_nm=case when l.ext_vou=1 then l.bcode_nm else l.entry_ty end'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',code_nm'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.add1,ac.add2,ac.add3,ac.contact,ac.city,ac.zip,ac.state'  --Added By Amrendra For Bug-83 on 11-11-11	
	set @sqlcommand=rtrim(@sqlcommand)+' '+',m.formidt,m.formrdt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',u_pinvno='''',u_pinvdt='''''
	--set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.add1,ac.add2,ac.add3,ac.contact,ac.city,ac.zip,ac.state'  --Commented By Amrendra For Bug-83 on 11-11-11
	set @sqlcommand=rtrim(@sqlcommand)+' '+',m.dept,m.cate,m.u_broker'--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13
	set @sqlcommand=rtrim(@sqlcommand)+' '+'from srmain m '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join stax_mas st on (m.tax_name=st.tax_name and m.entry_ty=st.entry_ty)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast ac on (m.ac_id=ac.ac_id)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join lcode l on (m.entry_ty=l.entry_ty)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'where (isnull(st.form_nm,space(1))<>space(1) or isnull(st.rform_nm,space(1))<>space(1))'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' and ( m.date between '+char(39)+cast(@sdate as varchar)+char(39)+' and '+char(39)+cast(@edate as varchar)+char(39)+')'+@whcon
	print @sqlcommand
	execute sp_executesql @sqlcommand

	set @sqlcommand='insert into #stax_form'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'select m.entry_ty,m.tran_cd,m.inv_no,m.form_nm,m.form_no,m.date,m.net_amt,m.tax_name,m.taxamt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.mailname,party_nm=ac.ac_name,formname=st.form_nm,rformname=st.rForm_Nm'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',bcode_nm=case when l.ext_vou=1 then l.bcode_nm else l.entry_ty end'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',code_nm'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.add1,ac.add2,ac.add3,ac.contact,ac.city,ac.zip,ac.state'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',m.formidt,m.formrdt'
	set @sqlcommand=rtrim(@sqlcommand)+' '+',u_pinvno='''',u_pinvdt='''''
	set @sqlcommand=rtrim(@sqlcommand)+' '+',m.dept,m.cate,m.u_broker'--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13	
	set @sqlcommand=rtrim(@sqlcommand)+' '+'from prmain m '
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join stax_mas st on (m.tax_name=st.tax_name and m.entry_ty=st.entry_ty)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast ac on (m.ac_id=ac.ac_id)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join lcode l on (m.entry_ty=l.entry_ty)'
	set @sqlcommand=rtrim(@sqlcommand)+' '+'where (isnull(st.form_nm,space(1))<>space(1) or isnull(st.rform_nm,space(1))<>space(1))'
	set @sqlcommand=rtrim(@sqlcommand)+' '+' and ( m.date between '+char(39)+cast(@sdate as varchar)+char(39)+' and '+char(39)+cast(@edate as varchar)+char(39)+')'+@whcon
	print @sqlcommand

	execute sp_executesql @sqlcommand
	
	select entry_ty,tran_cd,inv_no,form_nm,form_no,date,net_amt,tax_name,taxamt,mailname,party_nm,formname,rformname,bcode_nm,code_nm
	,add1,add2,add3,contact,city,zip,city,formidt,formrdt,u_pinvno,u_pinvdt
	,dept,cate,u_broker--ADDED BY SATISH PAL FOR BUG-7280 DATED 1/2/13
	from #stax_form 
	--order by party_nm,u_pinvdt  -- Commented by Shrikant S. on 03/04/2010 for TKT-631
	order by party_nm,Case when isnull(u_pinvdt,0)=0 then Date else u_pinvdt end,Case when isnull(u_pinvno,'')='' then inv_no else u_pinvno end -- Added by Shrikant S. on 03/04/2010 for TKT-631
end
GO
