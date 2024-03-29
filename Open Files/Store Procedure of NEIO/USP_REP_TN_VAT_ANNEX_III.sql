If Exists(Select [Name] from Sysobjects where xType='P' and Id=Object_Id(N'USP_REP_TN_VAT_ANNEX_III'))
Begin
	Drop Procedure USP_REP_TN_VAT_ANNEX_III
End
Go

set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
GO

/*
EXECUTE USP_REP_TN_VAT_ANNEX_III'','','','04/01/2015','03/31/2016','','','','',0,0,'','','','','','','','','2015-2016',''
*/
-- =============================================
-- Author:		Hetal L Patel
-- Create date: 01/06/2009	
-- Description:	This Stored procedure is useful to generate Tamilnadu VAT - FORM Annexure Report.
-- Modify date: 08/06/2009
-- Modified By: Dinesh & Hetal
-- Modify date: 19/05/2015 Bug-26174 by GAURAV R. TANNA
---Modify Date : 21-12-2015 -For the bug-27444 by Suraj K.
-- Remark:
-- =============================================

Create Procedure [dbo].[USP_REP_TN_VAT_ANNEX_III]
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
Declare @FCON as NVARCHAR(2000),@fld_list NVARCHAR(2000)
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE=Null,@VACFILE='i'
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

DECLARE @TAXABLE_AMT NUMERIC(14,2),@taxamt numeric(14,2)
set @FCON=rtrim(@FCON)
select part=1,srno1=3, it_desc=m.cate,acm.ac_name,acm.s_tax,commodity_code=space(100)
---,taxable_amt=i.gro_amt+i.BCDAMT+i.U_CESSAMT+i.U_HCESAMT+i.EXAMT+i.U_CVDAMT -- for bug-27444
 ,taxable_amt=m.net_amt ---- for bug-27444
,taxamt=i.taxamt
,st.tax_name,st.level1,st.st_type ,m.u_imporm
into #tn_vat_Annexure
from ptitem i  
inner join ptmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd) 
inner join ac_mast acm on (i.ac_id=acm.ac_id) 
inner join it_mast itm on (i.it_code=itm.it_code) 
inner join stax_mas st on (st.tax_name=i.tax_name)
where 1=2
declare @sqlcommand nvarchar(4000)

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		Set @MultiCo = 'YES'
		
	End
Else
	Begin	------Fetch Records from Single Co. Data
		Set @MultiCo = 'NO'
		-->Part-3
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,1,'','','','','',''
		,0
		,'',0,0)
		--
		execute usp_rep_Taxable_Amount_Itemwise 'ST','i',@fld_list =@fld_list OUTPUT
		set @fld_list=rtrim(@fld_list)
		set @sqlcommand='insert into #tn_vat_Annexure select part=3,srno1=2'
		set @sqlcommand=@sqlcommand+' '+',cate='''',ac_name='''',acm.s_tax,itm.hsncode'
		set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
		set @sqlcommand=@sqlcommand+' '+',taxamt=isnull(sum(i.taxamt),0)'
		set @sqlcommand=@sqlcommand+' '+',st.tax_name,st.level1,st.st_type ,m.u_imporm'
		set @sqlcommand=@sqlcommand+' '+'from stitem i '
		set @sqlcommand=@sqlcommand+' '+'inner join stmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
		set @sqlcommand=@sqlcommand+' '+'inner join ac_mast acm on (i.ac_id=acm.ac_id)'
		set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code)'
		set @sqlcommand=@sqlcommand+' '+'LEFT join stax_mas st on (st.tax_name=i.tax_name AND st.entry_ty = i.entry_ty)'
		set @sqlcommand=@sqlcommand+' '+rtrim(@fcon)
		set @sqlcommand=@sqlcommand+' '+'and m.[rule] = ''CAPTIVE USE'''
		set @sqlcommand=@sqlcommand+' '+'and i.entry_ty = ''ST'''
		set @sqlcommand=@sqlcommand+' '+'group by acm.s_tax,itm.hsncode,st.tax_name,st.level1,st.st_type ,m.u_imporm'

		print @sqlcommand
		execute sp_executesql @sqlcommand
		if not exists(select * from #tn_vat_Annexure  where part=3 and srno1=2)
		begin
			insert into #tn_vat_Annexure 
			(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
			,taxable_amt 
			,tax_name,taxamt,level1)
			values
			(3,2,'','','','','',''
			,0
			,'',0,0)
		end
		--
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,3,'','','','','',''
		,0
		,'',0,0)
		--
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,4,'','','','','',''
		,0
		,'',0,0)
		--
		--execute usp_rep_Taxable_Amount_Itemwise 'ST','i',@fld_list =@fld_list OUTPUT
		--set @fld_list=rtrim(@fld_list)
		--set @sqlcommand='insert into #tn_vat_Annexure select part=3,srno1=5'
		--set @sqlcommand=@sqlcommand+' '+',cate='''',ac_name='''',s_tax='''',itm.hsncode'
		--set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
		--set @sqlcommand=@sqlcommand+' '+',taxamt=isnull(sum(i.taxamt),0)'
		--set @sqlcommand=@sqlcommand+' '+',st.tax_name,st.level1,st.st_type ,m.u_imporm'
		--set @sqlcommand=@sqlcommand+' '+'from stitem i '
		--set @sqlcommand=@sqlcommand+' '+'inner join stmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
		--set @sqlcommand=@sqlcommand+' '+'inner join ac_mast acm on (i.ac_id=acm.ac_id)'
		--set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code)'
		--set @sqlcommand=@sqlcommand+' '+'inner join stax_mas st on (st.tax_name=i.tax_name) And St.Entry_ty = '+'''ST'''
		--set @sqlcommand=@sqlcommand+' '+rtrim(@fcon)
		-----set @sqlcommand=@sqlcommand+' '+'and m.[Cate]='+'''Samples'''
		--set @sqlcommand=@sqlcommand+' '+'group by itm.hsncode,st.tax_name,st.level1,st.st_type ,m.u_imporm'

		--print @sqlcommand
		--execute sp_executesql @sqlcommand
		--if not exists(select * from #tn_vat_Annexure  where part=3 and srno1=5)
		--begin
		--	insert into #tn_vat_Annexure 
		--	(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		--	,taxable_amt 
		--	,tax_name,taxamt,level1)
		--	values
		--	(3,5,'','','','','',''
		--	,0
		--	,'',0,0)
		--end
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,5,'','','','','',''
		,0
		,'',0,0)
		--
		
		execute usp_rep_Taxable_Amount_Itemwise 'SS','i',@fld_list =@fld_list OUTPUT
		set @fld_list=rtrim(@fld_list)
		set @sqlcommand='insert into #tn_vat_Annexure select part=3,srno1=6'
		set @sqlcommand=@sqlcommand+' '+',cate='''',ac_name='''',s_tax='''',itm.hsncode'
		set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
		set @sqlcommand=@sqlcommand+' '+',taxamt=0'
		set @sqlcommand=@sqlcommand+' '+',tax_name='''',level1=0,st_type='''',u_imporm='''''
		set @sqlcommand=@sqlcommand+' '+'from ssitem i '
		set @sqlcommand=@sqlcommand+' '+'inner join ssmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
		set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code)'
		set @sqlcommand=@sqlcommand+' '+rtrim(@fcon)
		set @sqlcommand=@sqlcommand+' '+'and m.Entry_ty = ''SS'''
		set @sqlcommand=@sqlcommand+' '+'group by itm.hsncode'

		print @sqlcommand
		execute sp_executesql @sqlcommand
		if not exists(select * from #tn_vat_Annexure  where part=3 and srno1=6)
		begin
			insert into #tn_vat_Annexure 
			(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
			,taxable_amt 
			,tax_name,taxamt,level1)
			values
			(3,6,'','','','','',''
			,0
			,'',0,0)
		end
		--
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,7,'','','','','',''
		,0
		,'',0,0)
		--
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,8,'','','','','',''
		,0
		,'',0,0)
		--
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,9,'','','','','',''
		,0
		,'',0,0)
		--
		execute usp_rep_Taxable_Amount_Itemwise 'ST','i',@fld_list =@fld_list OUTPUT
		set @fld_list=rtrim(@fld_list)
		set @sqlcommand='insert into #tn_vat_Annexure select part=3,srno1=10'
		set @sqlcommand=@sqlcommand+' '+',cate='''',ac_name='''',acm.s_tax,itm.hsncode'
		set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
		set @sqlcommand=@sqlcommand+' '+',taxamt=isnull(sum(i.taxamt),0)'
		set @sqlcommand=@sqlcommand+' '+',isnull(st.tax_name,''''),isnull(st.level1,0),ISNULL(st.st_type,''''),m.u_imporm'
		set @sqlcommand=@sqlcommand+' '+'from stitem i '
		set @sqlcommand=@sqlcommand+' '+'inner join stmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
		set @sqlcommand=@sqlcommand+' '+'inner join ac_mast acm on (i.ac_id=acm.ac_id)'
		set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code)'
		set @sqlcommand=@sqlcommand+' '+'LEFT  join stax_mas st on (st.tax_name=i.tax_name AND st.entry_ty = m.entry_ty)'
		set @sqlcommand=@sqlcommand+' '+ rtrim(@fcon)		
		set @sqlcommand=@sqlcommand+' '+'and m.u_imporm =''Consignment Transfer'''
		set @sqlcommand=@sqlcommand+' '+'and m.entry_ty = ''ST'''
		set @sqlcommand=@sqlcommand+' '+'and LTRIM(RTRIM(REPLACE(REPLACE(ISNULL(st.RForm_Nm,''''),''-'',''''),''FORM'',''''))) <> ''F'''
		set @sqlcommand=@sqlcommand+' '+'and acm.St_Type in (''OUT OF STATE'',''LOCAL'')'
		set @sqlcommand=@sqlcommand+' '+'group by acm.s_tax,itm.hsncode,st.tax_name,st.level1,st.st_type ,m.u_imporm'
		print @sqlcommand
		execute sp_executesql @sqlcommand
		if not exists(select * from #tn_vat_Annexure  where part=3 and srno1=10)
		begin
			insert into #tn_vat_Annexure 
			(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
			,taxable_amt 
			,tax_name,taxamt,level1)
			values
			(3,10,'','','','','',''
			,0
			,'',0,0)
		end
		--
		execute usp_rep_Taxable_Amount_Itemwise 'ST','i',@fld_list =@fld_list OUTPUT
		set @fld_list=rtrim(@fld_list)
		set @sqlcommand='insert into #tn_vat_Annexure select part=3,srno1=11'
		set @sqlcommand=@sqlcommand+' '+',cate='''',ac_name='''',acm.s_tax,itm.hsncode'
		set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
		set @sqlcommand=@sqlcommand+' '+',taxamt=isnull(sum(i.taxamt),0)'
		set @sqlcommand=@sqlcommand+' '+',isnull(st.tax_name,''''),isnull(st.level1,0),ISNULL(st.st_type,''''),m.u_imporm'
		set @sqlcommand=@sqlcommand+' '+'from stitem i '
		set @sqlcommand=@sqlcommand+' '+'inner join stmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
		set @sqlcommand=@sqlcommand+' '+'inner join ac_mast acm on (i.ac_id=acm.ac_id)'
		set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code)'
		set @sqlcommand=@sqlcommand+' '+'left join stax_mas st on (st.tax_name=i.tax_name AND st.entry_ty = m.entry_ty)'
		set @sqlcommand=@sqlcommand+' '+ rtrim(@fcon)
		set @sqlcommand=@sqlcommand+' '+'and m.u_imporm =''Branch Transfer'''
		set @sqlcommand=@sqlcommand+' '+'and m.entry_ty = ''ST'''
		set @sqlcommand=@sqlcommand+' '+'and LTRIM(RTRIM(REPLACE(REPLACE(ISNULL(st.RForm_Nm,''''),''-'',''''),''FORM'',''''))) <> ''F'''
		set @sqlcommand=@sqlcommand+' '+'and acm.St_Type in (''OUT OF STATE'',''LOCAL'')'
		set @sqlcommand=@sqlcommand+' '+'group by acm.s_tax,itm.hsncode,st.tax_name,st.level1,st.st_type ,m.u_imporm'
		print @sqlcommand
		execute sp_executesql @sqlcommand
		if not exists(select * from #tn_vat_Annexure  where part=3 and srno1=11)
		begin
			insert into #tn_vat_Annexure 
			(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
			,taxable_amt 
			,tax_name,taxamt,level1)
			values
			(3,11,'','','','','',''
			,0
			,'',0,0)
		end
		--
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,12,'','','','','',''
		,0
		,'',0,0)
		
		--

		execute usp_rep_Taxable_Amount_Itemwise 'ST','i',@fld_list =@fld_list OUTPUT
		set @fld_list=rtrim(@fld_list)
		set @sqlcommand='insert into #tn_vat_Annexure select part=3,srno1=13'
		set @sqlcommand=@sqlcommand+' '+',cate='''',ac_name='''',acm.s_tax,itm.hsncode'
		set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
		set @sqlcommand=@sqlcommand+' '+',taxamt=isnull(sum(i.taxamt),0)'
		set @sqlcommand=@sqlcommand+' '+',isnull(st.tax_name,''''),isnull(st.level1,0),ISNULL(st.st_type,''''),m.u_imporm'
		set @sqlcommand=@sqlcommand+' '+'from stitem i '
		set @sqlcommand=@sqlcommand+' '+'inner join stmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
		set @sqlcommand=@sqlcommand+' '+'inner join ac_mast acm on (i.ac_id=acm.ac_id)'
		set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code)'
		set @sqlcommand=@sqlcommand+' '+'LEFT join stax_mas st on (st.tax_name=i.tax_name and st.entry_ty = m.entry_ty)'
		set @sqlcommand=@sqlcommand+' '+ rtrim(@fcon)
		set @sqlcommand=@sqlcommand+' '+'and m.entry_ty = ''ST'''
		set @sqlcommand=@sqlcommand+' '+'and m.u_imporm not in ('+'''Branch Transfer'',''Consignment Transfer'''+')'+' and acm.st_type = ''out of state'''
		set @sqlcommand=@sqlcommand+' '+'and LTRIM(RTRIM(REPLACE(REPLACE(ISNULL(st.RForm_Nm,''''),''-'',''''),''FORM'',''''))) = ''C'''
		set @sqlcommand=@sqlcommand+' '+'group by acm.s_tax,itm.hsncode,st.tax_name,st.level1,st.st_type ,m.u_imporm'
		print @sqlcommand
		execute sp_executesql @sqlcommand
		if not exists(select * from #tn_vat_Annexure  where part=3 and srno1=13)
		begin
			insert into #tn_vat_Annexure 
			(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
			,taxable_amt 
			,tax_name,taxamt,level1)
			values
			(3,13,'','','','','',''
			,0
			,'',0,0)
		end
		--

		--

		execute usp_rep_Taxable_Amount_Itemwise 'ST','i',@fld_list =@fld_list OUTPUT
		set @fld_list=rtrim(@fld_list)
		set @sqlcommand='insert into #tn_vat_Annexure select part=3,srno1=14'
		set @sqlcommand=@sqlcommand+' '+',cate='''',ac_name='''',acm.s_tax,itm.hsncode'
		set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
		set @sqlcommand=@sqlcommand+' '+',taxamt=isnull(sum(i.taxamt),0)'
		set @sqlcommand=@sqlcommand+' '+',st.tax_name,st.level1,st.st_type ,m.u_imporm'
		set @sqlcommand=@sqlcommand+' '+'from stitem i '
		set @sqlcommand=@sqlcommand+' '+'inner join stmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
		set @sqlcommand=@sqlcommand+' '+'inner join ac_mast acm on (i.ac_id=acm.ac_id)'
		set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code)'
		set @sqlcommand=@sqlcommand+' '+'inner join stax_mas st on (st.tax_name=i.tax_name) And St.Entry_ty = '+'''ST'''
		set @sqlcommand=@sqlcommand+' '+rtrim(@fcon)
		set @sqlcommand=@sqlcommand+' '+'and m.u_imporm not in ('+'''Branch Transfer'',''Consignment Transfer'''+')'+' and acm.st_type = ''OUT OF STATE'''
		set @sqlcommand=@sqlcommand+' '+'and LTRIM(RTRIM(REPLACE(REPLACE(st.RForm_Nm,''-'',''''),''FORM'',''''))) <> ''C'''
		set @sqlcommand=@sqlcommand+' '+'group by acm.s_tax,itm.hsncode,st.tax_name,st.level1,st.st_type ,m.u_imporm'
		print @sqlcommand
		execute sp_executesql @sqlcommand
		if not exists(select * from #tn_vat_Annexure  where part=3 and srno1=14)
		begin
			insert into #tn_vat_Annexure 
			(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
			,taxable_amt 
			,tax_name,taxamt,level1)
			values
			(3,14,'','','','','',''
			,0
			,'',0,0)
		end
		--

		execute usp_rep_Taxable_Amount_Itemwise 'PR','i',@fld_list =@fld_list OUTPUT
		set @fld_list=rtrim(@fld_list)
		set @sqlcommand='insert into #tn_vat_Annexure select part=3,srno1=15'
		set @sqlcommand=@sqlcommand+' '+',cate='''',ac_name='''',acm.s_tax,itm.hsncode'
		set @sqlcommand=@sqlcommand+' '+',taxable_amt=sum(i.gro_amt'+@fld_list+')'
		set @sqlcommand=@sqlcommand+' '+',taxamt=isnull(sum(i.taxamt),0)'
		set @sqlcommand=@sqlcommand+' '+',tax_name = ISNULL(st.tax_name,''''),level1 = ISNULL(st.level1,0),st.st_type  ,u_imporm='''''
		set @sqlcommand=@sqlcommand+' '+'from PRitem i '
		set @sqlcommand=@sqlcommand+' '+'inner join prmain m on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
		set @sqlcommand=@sqlcommand+' '+'inner join ac_mast acm on (i.ac_id=acm.ac_id)'
		set @sqlcommand=@sqlcommand+' '+'inner join it_mast itm on (i.it_code=itm.it_code)'
		set @sqlcommand=@sqlcommand+' '+'LEFT join stax_mas st on (st.tax_name=i.tax_name and st.entry_ty = m.entry_ty)'
		set @sqlcommand=@sqlcommand+' '+rtrim(@fcon)
		--set @sqlcommand=@sqlcommand+' '+'and acm.st_type='+'''out of state'''+' and st.tax_name<>'+'''form c'''
		set @sqlcommand=@sqlcommand+' '+'and m.Entry_ty = ''PR'''
		set @sqlcommand=@sqlcommand+' '+'group by acm.s_tax,itm.hsncode,st.tax_name,st.level1,st.st_type' 
		print @sqlcommand
		execute sp_executesql @sqlcommand
		if not exists(select * from #tn_vat_Annexure where part=3 and srno1=15)
		begin
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,15,'','','','','',''
		,0
		,'',0,0)
        end 
		--
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,16,'','','','','',''
		,0
		,'',0,0)
		--
		insert into #tn_vat_Annexure 
		(part,srno1,it_desc,ac_name,s_tax,commodity_code,st.st_type ,m.u_imporm
		,taxable_amt 
		,tax_name,taxamt,level1)
		values
		(3,17,'','','','','',''
		,0
		,'',0,0)
		--<--Part-3
	End

select  * from #tn_vat_Annexure order by part,srno1,LEVEL1,IT_DESC,COMMODITY_CODE

