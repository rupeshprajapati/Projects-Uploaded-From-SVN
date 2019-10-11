If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_Ent_eWayBill_Filter')
Begin
	Drop Procedure USP_Ent_eWayBill_Filter
End
Go
CREATE Procedure [USP_Ent_eWayBill_Filter]
(
	@TrnName varchar(100)--,@PartyGstin varchar(15)
	--,@PartyName varchar(50)
)
As
Begin

Declare @SqlCommand nvarchar(4000) ,@bCode_Nm Varchar(2)

If (@TrnName = 'C' or @TrnName = 'S' or @TrnName = 'CS')
Begin
	Create Table #eWayBillJson_AcName (ac_name varchar(50))
	Insert Into #eWayBillJson_AcName select ''
	Declare @GrpNm Varchar(100)
	
	If(@TrnName='C')
	Begin
		Set @GrpNm='(''SUNDRY DEBTORS'')'
	End
	If(@TrnName='S')
	Begin
		Set @GrpNm='(''SUNDRY CREDITORS'')'
	End
	If(@TrnName='CS')
	Begin
		Set @GrpNm='(''SUNDRY DEBTORS'',''SUNDRY CREDITORS'')'
	End
	print @GrpNm
	
	If (@GrpNm<>'')
	Begin
		Create table #AcGrid (Ac_group_id int)
		Declare @T int,@Ac_group_id int
		Set @SqlCommand ='Insert into #AcGrid Select Ac_group_id From AC_GROUP_MAST where Ac_Group_Name in '+@GrpNm
		Print @SqlCommand
		Execute Sp_ExecuteSQl @SqlCommand
		Set @T=1
		While (@t=1)
		Begin
			If Exists (Select Ac_group_id From AC_GROUP_MAST Where gAC_Id in (Select Ac_group_id From #AcGrid) and Ac_group_id not in (Select Ac_group_id From #AcGrid))
			Begin
				Insert into #AcGrid Select Ac_group_id From AC_GROUP_MAST Where gAC_Id in (Select Ac_group_id From #AcGrid) and Ac_group_id not in (Select Ac_group_id From #AcGrid)
				Set @T=@T+1
			End
			Else
			Begin
				Set @T=0
			End
		End
	End

	Set @SqlCommand='Insert Into #eWayBillJson_AcName'
	Set @SqlCommand=rtrim(@SqlCommand)+' Select distinct ac_name = rtrim(ac.ac_name) '
	Set @SqlCommand=rtrim(@SqlCommand)+' From Ac_Mast ac '
	Set @SqlCommand=rtrim(@SqlCommand)+' Left Join shipto sh on (ac.ac_id=sh.ac_id)'
	Set @SqlCommand=rtrim(@SqlCommand)+' Where 1=1 and ac.defa_ac=0'
	If(@GrpNm<>'') Begin Set @SqlCommand=rtrim(@SqlCommand)+' And ac.Ac_group_id in (Select Distinct Ac_group_id from #AcGrid)'	End
	/*If(@AcNm<>'')	Begin Set @SqlCommand=rtrim(@SqlCommand)+' And ac.Ac_Name='+Char(39)+@ACNm+Char(39) End
	If (@TrnName='C') Begin Set @SqlCommand=rtrim(@SqlCommand)+' [group] in (''SUNDRY DEBTORS'')' End
	If (@TrnName='S') Begin Set @SqlCommand=rtrim(@SqlCommand)+' [group] in (''SUNDRY CREDITORS'')' End
	If (@TrnName='CS') Begin Set @SqlCommand=rtrim(@SqlCommand)+' [group] in (''SUNDRY DEBTORS'',''SUNDRY CREDITORS'')' End
	*/
	Print @SqlCommand
	Execute sp_Executesql @SqlCommand
	
	Select * From #eWayBillJson_AcName
	drop table #eWayBillJson_AcName
	drop table #AcGrid
End

Else If (@TrnName='' or @TrnName='Finished' or @TrnName='Machinery/Stores' or @TrnName='Packing Material' or @TrnName='Raw Material' or @TrnName='Semi Finished' or @TrnName='Trading')
Begin
	Create Table #eWayBillJson_ItName (It_name varchar(50))
	Insert Into #eWayBillJson_ItName select ''

	Set @SqlCommand='Insert Into #eWayBillJson_ItName'
	Set @SqlCommand=rtrim(@SqlCommand)+' Select distinct it_name = rtrim(it_name) '
	Set @SqlCommand=rtrim(@SqlCommand)+' From It_Mast '
	If (@TrnName<>'') Begin Set @SqlCommand=rtrim(@SqlCommand)+' Where [type]='''+@TrnName+'''' End
	Set @SqlCommand=rtrim(@SqlCommand)+' Order by it_name'
	Print @SqlCommand
	Execute sp_Executesql @SqlCommand
	
	Select * From #eWayBillJson_ItName
	drop table #eWayBillJson_ItName
End

End

