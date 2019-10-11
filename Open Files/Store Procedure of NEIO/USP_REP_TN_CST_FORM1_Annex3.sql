If Exists(Select [name] From SysObjects Where xtype='P' and [Name]='USP_REP_TN_CST_FORM1_Annex3')
Begin
	Drop Procedure USP_REP_TN_CST_FORM1_Annex3
End
GO

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

 -- =============================================
 -- Author:  Sandeep Shah
 -- Create date: 06/07/2010
 -- Description: This Stored procedure is useful to generate TN CST FORM 01 ANNX III 
 -- Modify date: 
 -- Modified By: 
 -- Modify date: 27/04/2015 by GAURAV R.TANNA For Bug - 26189
 -- =============================================
CREATE procedure [dbo].[USP_REP_TN_CST_FORM1_Annex3]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= NULL
AS
Declare @FCON as NVARCHAR(2000)
Declare @SQLCOMMAND NVARCHAR(4000)
Declare @gro_amt decimal(12,2),@taxamt decimal(12,2),@fld_list NVARCHAR(2000)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE --null
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='m',@VITFILE='',@VACFILE=''
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

--select part=3,u_challno=m.inv_no,u_challdt=m.date,u_vehno=space(30)
--,u_lrno=space(30),u_lrdt=getdate(),it_desc=m.cate,i.qty,i.gro_amt
--,party_nm=a.ac_name,a.add1,a.add2,a.add3,a.s_tax,a.c_tax,m.form_no
--into #tn_CST_FORM1_PART3
--from ptmain m
--inner join ptitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)
--inner join ac_mast a on (m.ac_id=a.ac_id)
--inner join ac_mast a1 on (m.ac_id=a1.ac_id) --change to shipment party field.
--inner join ac_mast a2 on (m.ac_id=a1.ac_id) --change to Buyer party field.
--where 1=2

select part=1,srno1=1,u_challno=m.inv_no,u_challdt=m.date,u_vehno=m.u_vehno
,u_lrno=m.u_lrno,u_lrdt=m.u_lrdt,it_desc=i.item,i.qty,i.gro_amt
,party_nm=a.mailname,a.add1,a.add2,a.add3,a.s_tax,a.c_tax,m.form_no,m.formrdt
into #tn_CST_FORM1_PART3
from stmain m
inner join stitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)
inner join ac_mast a on (m.ac_id=a.ac_id)
inner join ac_mast a1 on (m.ac_id=a1.ac_id) --change to shipment party field.
inner join ac_mast a2 on (m.ac_id=a1.ac_id) --change to Buyer party field.
where 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		Set @MultiCo = 'YES'

		execute usp_rep_Taxable_Amount_Itemwise 'ST','i',@fld_list =@fld_list OUTPUT
		set @fld_list=rtrim(@fld_list)
--		
----		set @sqlcommand=@sqlcommand+' '+',u_lrno=m.u_lrno,u_lrdt=m.u_lrdt,it_desc=(itm.it_name),qty=sum(i.qty)'
----		set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
----		set @sqlcommand=@sqlcommand+' '+',party_nm=acm.mailname,add1=acm.add1,add2=acm.add2,add3=acm.add3,s_tax=acm.s_Tax,c_tax=acm.c_tax,m.form_no,m.formrdt'				
----		set @sqlcommand=@sqlcommand+' '+'from stitem i '
----		set @sqlcommand=@sqlcommand+' '+'inner join stmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd and m.dbname = i.dbname) '
----		set @sqlcommand=@sqlcommand+' '+'inner join ac_mast acm on (i.ac_id=acm.ac_id and i.dbname = acm.dbname)'
----		set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code and i.dbname = itm.dbname)'
----		--set @sqlcommand=@sqlcommand+' '+'inner join stax_mas st on (st.tax_name=i.tax_name)'
----		set @sqlcommand=@sqlcommand+' '+rtrim(@fcon)
----		set @sqlcommand=@sqlcommand+' '+'and isnull(acm.st_type,'''')='+'''out of state''' +' and m.u_imporm='+'''Branch Transfer'''
----		set @sqlcommand=@sqlcommand+' '+'and '
----		set @sqlcommand=@sqlcommand+' '+'group by itm.it_name,acm.mailname,acm.add1,acm.add2,acm.add3,acm.s_Tax,acm.c_tax,m.form_nm,m.u_vehno,m.u_lrno,m.u_lrdt,m.u_chalno,m.u_chaldt'
----		print @sqlcommand
----		execute sp_executesql @sqlcommand

----		if not exists(select * from #tn_CST_FORM1_PART3 where part=1)
----		begin
----			insert into #tn_CST_FORM1_PART3
----			(part,u_challno,u_challdt,u_vehno
----			,u_lrno,u_lrdt,it_desc,qty,gro_amt
----			,party_nm,add1,add2,add3,s_tax,c_tax
----			,form_no,formrdt)
----			values
----			(
----			1,'','',''
----			,'','','',0,0
----			,'','','','','',''
----			,'',''
----			)
------			print '1'
----		end
--		if not exists(select * from #tn_CST_FORM1_PART3 where part=2)
--		begin
--			insert into #tn_CST_FORM1_PART3
--			(part,u_challno,u_challdt,u_vehno
--			,u_lrno,u_lrdt,it_desc,qty,gro_amt
--			,party_nm,add1,add2,add3,s_tax,c_tax
--			,form_no)
--			values
--			(
--			2,'','',''
--			,'','','',0,0
--			,'','','','','',''
--			,'' 
--			)
--		end
	End
Else
	Begin
		Set @MultiCo = 'NO'

		execute usp_rep_Taxable_Amount_Itemwise 'ST','i',@fld_list =@fld_list OUTPUT
		set @fld_list=rtrim(@fld_list)
		set @sqlcommand='insert into #tn_CST_FORM1_PART3 select part=1,srno1=1,u_challno=m.u_chalno,u_challdt=m.u_chaldt,u_vehno=m.u_vehno'
		set @sqlcommand=@sqlcommand+' '+',u_lrno=m.u_lrno,u_lrdt=m.u_lrdt,it_desc=(itm.it_name),qty=sum(i.qty)'
		set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
		set @sqlcommand=@sqlcommand+' '+',party_nm=acm.mailname,add1=acm.add1,add2=acm.add2,add3=acm.add3,s_tax=acm.s_Tax,c_tax=acm.c_tax,m.form_no, m.formrdt'
		set @sqlcommand=@sqlcommand+' '+'from stitem i '
		set @sqlcommand=@sqlcommand+' '+'inner join stmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd) '
		set @sqlcommand=@sqlcommand+' '+'inner join ac_mast acm on (i.ac_id=acm.ac_id)'
		set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code)'
		--set @sqlcommand=@sqlcommand+' '+'inner join stax_mas st on (st.tax_name=i.tax_name) and st.entry_ty='+'''ST'''
		set @sqlcommand=@sqlcommand+' '+rtrim(@fcon)
		set @sqlcommand=@sqlcommand+' '+'and isnull(acm.st_type,'''')='+'''out of state''' +' and m.u_imporm='+'''Branch Transfer'''
		set @sqlcommand=@sqlcommand+' '+'group by itm.it_name,acm.mailname,acm.add1,acm.add2,acm.add3,acm.s_Tax,acm.c_tax,m.form_no,m.formrdt,m.u_vehno,m.u_lrno,m.u_lrdt,m.u_chalno,m.u_chaldt'
		print @sqlcommand
		execute sp_executesql @sqlcommand

----		if not exists(select * from #tn_CST_FORM1_PART3 where part=1 and srno1=1)
----		begin
----			insert into #tn_CST_FORM1_PART3
----			(part,srno1,u_challno,u_challdt,u_vehno
----			,u_lrno,u_lrdt,it_desc,qty,gro_amt
----			,party_nm,add1,add2,add3,s_tax,c_tax
----			,form_no,formrdt)
----			values
----			(
----			1,1,'','',''
----			,'','','',0,0
----			,'','','','','',''
----			,'',''
----			)
------			print '1'
----		end
--		if not exists(select * from #tn_CST_FORM1_PART3 where part=2)
--		begin
--			insert into #tn_CST_FORM1_PART3
--			(part,u_challno,u_challdt,u_vehno
--			,u_lrno,u_lrdt,it_desc,qty,gro_amt
--			,party_nm,add1,add2,add3,s_tax,c_tax
--			,form_no)
--			values
--			(
--			2,'','',''
--			,'','','',0,0
--			,'','','','','',''
--			,'' 
--			)
--		end
	End

select * from #tn_CST_FORM1_PART3
DROP TABLE  #tn_CST_FORM1_PART3