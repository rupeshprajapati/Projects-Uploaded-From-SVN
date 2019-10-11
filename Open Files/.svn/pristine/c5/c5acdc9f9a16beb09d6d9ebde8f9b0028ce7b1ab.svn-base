If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_Ent_eWayBill_Filter_PartyName')
Begin
	Drop Procedure USP_Ent_eWayBill_Filter_PartyName
End
Go
CREATE Procedure [USP_Ent_eWayBill_Filter_PartyName]
(
	@TrnName varchar(100),@PartyGstin varchar(50)
	--,@PartyName varchar(50)
)
As
Begin

	Declare @SqlCommand nvarchar(4000) ,@bCode_Nm Varchar(2)

	If (@TrnName = 'SALES' or @TrnName = 'PURCHASE' or @TrnName = 'DELIVERY CHALLAN' or @TrnName='LABOUR JOB ISSUE[IV]' or @TrnName='LABOUR JOB ISSUE[V]' 
	or @TrnName='LABOUR JOB RECEIPT[IV]' or @TrnName='LABOUR JOB RECEIPT[V]' or @TrnName='CREDIT NOTE' or @TrnName='SALES RETURN' or @TrnName='GOODS RECEIPT')
	Begin
		Select @bCode_Nm=Case when @TrnName='SALES' Then 'ST'
							  When @TrnName='PURCHASE' Then 'PT'
							  When @TrnName='DELIVERY CHALLAN' Then 'DC'
							  When @TrnName='LABOUR JOB ISSUE[IV]' Then 'II'
							  When @TrnName='LABOUR JOB ISSUE[V]' Then 'II'	
							  When @TrnName='LABOUR JOB RECEIPT[IV]' Then 'IR'
							  When @TrnName='LABOUR JOB RECEIPT[V]' Then 'IR'
							  When @TrnName='CREDIT NOTE' Then 'CN'
							  When @TrnName='SALES RETURN' Then 'SR'
							  When @TrnName='GOODS RECEIPT' Then 'AR'
							  Else '' End
					
		print '2'
		Create Table #eWayBillJson_accname (ac_name varchar(50),mailname varchar(50)) 
		Insert Into #eWayBillJson_accname select '','' 
		--ac_name=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)		--Commented by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		
		Set @SqlCommand='Insert Into #eWayBillJson_accname'		
		Set @SqlCommand=rtrim(@SqlCommand)+' Select distinct 
		ac_name=(case WHEN isnull(m.scons_id, 0) > 0 then (case when isnull(Cons_sp.ac_name,'''')='''' then  isnull(Cons_ac.ac_name,'''') else isnull(Cons_sp.ac_name,'''') end) else isnull(Cons_ac.ac_name,'''') end)		--Added by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		,mailname=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.mailname,'''') end)'
		Set @SqlCommand=rtrim(@SqlCommand)+' From '+@bCode_Nm+'Main m'
		Set @SqlCommand=rtrim(@SqlCommand)+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=rtrim(@SqlCommand)+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=rtrim(@SqlCommand)+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=rtrim(@SqlCommand)+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'

		If (@TrnName='LABOUR JOB ISSUE[IV]' or @TrnName='LABOUR JOB ISSUE[V]' or @TrnName='LABOUR JOB RECEIPT[IV]' or @TrnName='LABOUR JOB RECEIPT[V]')
		Begin
			If (@TrnName='LABOUR JOB ISSUE[IV]') Begin Set @SqlCommand=rtrim(@SqlCommand)+' Where m.Entry_ty=''LI''' End
			if (@TrnName='LABOUR JOB ISSUE[V]')	Begin Set @SqlCommand=rtrim(@SqlCommand)+' Where m.Entry_ty=''IL'''	End
			If (@TrnName='LABOUR JOB RECEIPT[IV]') Begin Set @SqlCommand=rtrim(@SqlCommand)+' Where m.Entry_ty=''LR''' End
			If (@TrnName='LABOUR JOB RECEIPT[V]') Begin Set @SqlCommand=rtrim(@SqlCommand)+' Where m.Entry_ty=''RL''' End		
			--If (@PartyGstin<>'' and @PartyName<>'') Begin Set @SqlCommand=@SqlCommand+' and acm.GSTIN='+char(39)+@PartyGstin+Char(39) + ' and acm.Ac_Name='+char(39)+@PartyName+Char(39) End
			--Else If (@PartyGstin<>'') Begin Set @SqlCommand=@SqlCommand+' and acm.GSTIN='+char(39)+@PartyGstin+Char(39) End
			--Else 
			--If (@PartyName<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)='+char(39)+@PartyName+Char(39) 
			--Set @SqlCommand=@SqlCommand+' or (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.mailname,'''') end)='+char(39)+@PartyName+Char(39) End
			If (@PartyGstin<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@PartyGstin+Char(39) End
		End
		Else
		Begin
			--If (@PartyGstin<>'' and @PartyName<>'') Begin Set @SqlCommand=@SqlCommand+' Where acm.GSTIN='+char(39)+@PartyGstin+Char(39) + ' and acm.Ac_Name='+char(39)+@PartyName+Char(39) End
			--Else If (@PartyGstin<>'') Begin Set @SqlCommand=@SqlCommand+' Where acm.GSTIN='+char(39)+@PartyGstin+Char(39) End
			--Else 
			--If (@PartyName<>'') Begin Set @SqlCommand=@SqlCommand+' Where (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)='+char(39)+@PartyName+Char(39) 
			--Set @SqlCommand=@SqlCommand+' or (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.mailname,'''') end)='+char(39)+@PartyName+Char(39) End
			--If (@PartyName<>'') Begin Set @SqlCommand=@SqlCommand+' Where acm.Ac_Name='+char(39)+@PartyName+Char(39) End
			If (@PartyGstin<>'') Begin Set @SqlCommand=@SqlCommand+' Where (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@PartyGstin+Char(39) End
		End
		
		Print @SqlCommand
		Execute sp_Executesql @SqlCommand
		Select * From #eWayBillJson_accname
		drop table #eWayBillJson_accname
	End
End



