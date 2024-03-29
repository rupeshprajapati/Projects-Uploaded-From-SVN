If Exists(Select [name] From SysObjects Where xtype='P' and [Name]='USP_MULTI_USP_REP_SALESTAX_FORM_REMLET')
Begin
	Drop Procedure USP_MULTI_USP_REP_SALESTAX_FORM_REMLET
End
GO
-- =============================================
-- Author:		Kishor Agarwal
-- Create date: 12/09/2015
-- Remark: -- Added By Kishor A. for Bug-26942-Cr on 16/09/2015
-- ============================================= 
CREATE Procedure [dbo].[USP_MULTI_USP_REP_SALESTAX_FORM_REMLET]
@vformnm varchar(30),@vparty varchar(100),@mCondn nvarchar(100),@vform int,@sdate smalldatetime,@edate smalldatetime,@dept nvarchar(100),@cate nvarchar(100),@broker nvarchar(100),@tmpTbl as varchar(4000)
AS
BEGIN
	DECLARE @COM_SQLSTR NVARCHAR(4000),@COM_SQLSTRST NVARCHAR(4000),@COM_SQLSTRPT NVARCHAR(4000),@COM_SQLSTRSR NVARCHAR(4000),@COM_SQLSTRPR NVARCHAR(4000),@SQL_STFLD NVARCHAR(4000)
	,@SQL_SRFLD NVARCHAR(4000),@SQL_PTFLD NVARCHAR(4000),@SQL_PRFLD NVARCHAR(4000),@SQL_TMPFLD NVARCHAR(4000),@xSQL_TMPFLD NVARCHAR(4000)
	
	EXECUTE Dynamically_Fields_Multi_REP
	SELECT @COM_SQLSTR = SqlStr FROM ##Dyn_TmpTable_multi WHERE Entry_ty='SQSTR'
	SELECT @xSQL_TMPFLD = SqlStr FROM ##Dyn_TmpTable_multi WHERE Entry_ty='TMPFLD'
	drop table ##Dyn_TmpTable_multi
	
	declare @SQLSTR nvarchar (4000),@IntoStr as Nvarchar(4000),@Call as nvarchar(4000)
	set @SQLSTR= 'select m.entry_ty,m.tran_cd,m.inv_no,m.form_nm,form_no=m.form_nm,m.date,m.net_amt,m.tax_name,m.taxamt
	,ac.mailname,party_nm=ac.ac_name,formname=st.form_nm,rformname=st.rForm_Nm
	,bcode_nm=case when l.ext_vou=1 then l.bcode_nm else l.entry_ty end
	,code_nm
	,ac.add1,ac.add2,ac.add3,ac.contact,ac.city,ac.zip,ac.state
	,formidt=m.DATE,formrdt=m.DATE
	,u_pinvno=cast('''' as varchar(100)),u_pinvdt=m.DATE
	,dbname=space(15),CompNm=SPACE(100),stax_no=SPACE(15)'+@COM_SQLSTR+'
	into ##stax_form_tobe_remlet
	from stmain m 
	inner join stax_mas st on (m.tax_name=st.tax_name and m.entry_ty=st.entry_ty)
	inner join ac_mast ac on (m.ac_id=ac.ac_id)
	inner join lcode l on (m.entry_ty=l.entry_ty)
	where (isnull(st.form_nm,'''')<>'''' or isnull(st.rform_nm,'''')<>'''') and 1=2'

	execute sp_executesql @SQLSTR
	set @IntoStr ='entry_ty,tran_cd,inv_no,form_nm,form_no,date,net_amt,tax_name,taxamt,mailname,party_nm,formname
	,rformname,bcode_nm,code_nm,add1,add2,add3,contact,city,zip,state,formidt,formrdt,u_pinvno,u_pinvdt'
		
	BEGIN
	declare @co_name varchar(20),@dbname varchar(15),@stax_no varchar(15)
	declare @fdbname varchar(10) , @cityname varchar(40), @itax_no varchar(40)

	select @fdbname=a.dbname  , @cityname = a.city, @itax_no = a.itax_no
	from vudyog..co_mast a
	where a.co_name=(select top 1 co_name from vudyog..co_mast)
			
	Declare @sqlcommand nvarchar(4000)

	declare #temp_db cursor for select a.co_name,b.dbname,b.stax_no from com_det a
	inner join vudyog..co_mast b on (a.co_name=b.co_name and a.sta_dt = b.sta_dt and a.end_dt = b.end_dt)
			 
	SET @SQLCOMMAND=''

	open #temp_db
	fetch next from #temp_db into @co_name,@dbname,@stax_no
	while @@fetch_status=0
	begin				
		SET @Call=''						
		set @Call = 'Execute '+rtrim(@dbname)+'..Dynamically_Fields_Rep '
		Execute sp_executesql @Call
		SELECT @SQL_TMPFLD = SqlStr FROM ##Dyn_TmpTable WHERE Entry_ty='MULTI'
		drop table ##Dyn_TmpTable				
		
		set @SQLCOMMAND =''
		SET @SQLCOMMAND='INSERT INTO ##stax_form_tobe_remlet ('+@IntoStr+@SQL_TMPFLD+' )
						 Execute '+rtrim(@dbname)+'..USP_REP_SALESTAX_FORM_REMLET '+char(39)+@vformnm+char(39)+','+char(39)+@vparty+char(39)+','+char(39)+@mCondn+char(39)+','+cast(@vform as varchar)+','+char(39)+cast(@sdate as varchar)+char(39)+','+char(39)+cast(@edate as varchar)+char(39)+','+char(39)+@dept+char(39)+','+char(39)+@cate+char(39)+','+char(39)+@broker+char(39)
		Execute sp_executesql @sqlcommand		
		update ##stax_form_tobe_remlet set dbname = rtrim(@dbname),CompNm=rtrim(@co_name),stax_no=rtrim(@stax_no) WHERE ISNULL(dbname,'')=''
		fetch next from #temp_db into @co_name,@dbname,@stax_no		
	end	
	
	close #temp_db
	deallocate #temp_db
	
	DECLARE @WSQL AS NVARCHAR(4000)	
	SET @WSQL='SELECT dbname,CompNm,stax_no,entry_ty,tran_cd,inv_no,form_nm,form_no,date,net_amt,tax_name,taxamt,mailname,party_nm,formname
	,rformname,bcode_nm,code_nm,add1,add2,add3,contact,city,zip,state,formidt,formrdt,u_pinvno,u_pinvdt '+@xSQL_TMPFLD+' INTO '+@tmpTbl+' FROM  ##stax_form_tobe_remlet '	

	EXECUTE SP_EXECUTESQL @WSQL

	END	
	
	DROP TABLE ##stax_form_tobe_remlet

END
