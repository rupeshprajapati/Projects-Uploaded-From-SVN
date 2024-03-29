If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_Ent_eWayBill_ItMast_json')
Begin
	Drop Procedure USP_Ent_eWayBill_ItMast_json
End
/****** Object:  StoredProcedure [dbo].[USP_Ent_eWayBill_ItMast_json]    Script Date: 01-Feb-18 11:37:54 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 29/01/2017
-- Description:	This Stored procedure is useful for eWayBill Item Master Json Deatails
-- Modify By/date/Reason: 
-- Remark:
-- =============================================
CREATE Procedure [dbo].[USP_Ent_eWayBill_ItMast_json]
(
	@ItNm varchar(100),@GrpNm Varchar(100),@ItTyp varchar(60)

)
As
Begin

If (@GrpNm<>'')
Begin
	Create table #ItGrid (ItGrid int)
	Declare @T int,@ItGrid int
	Insert into #ItGrid Select ItGrid From ITEM_GROUP where it_group_name=@GrpNm
	Set @T=1
	While (@t=1)
	Begin
		If Exists (Select ItGrid From ITEM_GROUP Where Fk_Itgrid in (Select ItGrid From #ItGrid) and Itgrid not in (Select ItGrid From #ItGrid))
		Begin
			Insert into #ItGrid Select ItGrid From ITEM_GROUP Where Fk_Itgrid in (Select ItGrid From #ItGrid) and Itgrid not in (Select ItGrid From #ItGrid) 
		End
		Else
		Begin
			Set @T=0
		End
	End
	--Select * From #ItGrid
End

Declare @SqlCommand nvarchar(4000) 
--Set @SqlCommand='Select Sel=Cast(0 as Bit),it.It_Code,it.[Group],productName=it.It_Name,description=It_Desc,measuringUnit=it.RateUnit,hsnCode=it.hsncode,cgst=Isnull(hr.cgstper,0),sgst=Isnull(hr.sgstper,0),igst=Isnull(hr.igstper,0) ,cess=0.00,cessAdvol=0.00,It.[type]'  --Commented by Priyanka B on 05022018 for Bug-31241
Set @SqlCommand='Select Sel=Cast(0 as Bit),it.It_Code,it.[Group],productName=it.It_Name,description=It_Desc,measuringUnit=it.RateUnit,hsnCode=it.hsncode,cgst=Isnull(hr.cgstper,0),sgst=Isnull(hr.sgstper,0),igst=Isnull(hr.igstper,0) ,cess=isnull(cr.cessrate,''''),cessAdvol=0.00,It.[type]'  --Modified by Priyanka B on 05022018 for Bug-31241
Set @SqlCommand=rtrim(@SqlCommand)+' from It_Mast it Left join hsn_master hm on (it.hsn_id=hm.hsn_id)'
Set @SqlCommand=rtrim(@SqlCommand)+' Left Join hsncodemast hr on (hm.hsn_id=hr.hsnid)'
Set @SqlCommand=rtrim(@SqlCommand)+' Left Join Cessrate cr on (hm.hsn_code=hr.hsncode and hm.hsn_code=cr.hsncode)'  --Added by Priyanka B on 05022018 for Bug-31241
Set @SqlCommand=rtrim(@SqlCommand)+' Where 1=1'
If(@GrpNm<>'')
Begin
	Set @SqlCommand=rtrim(@SqlCommand)+' And it.ItGrid in (Select Distinct ItGrid from #ItGrid)'
End

If(@ItNm<>'')
Begin
	--Set @SqlCommand=rtrim(@SqlCommand)+' And ItNm='+Char(39)+@ItNm+Char(39)  --Commented by Priyanka B on 01022018 for Bug-31241
	Set @SqlCommand=rtrim(@SqlCommand)+' And It_Name='+Char(39)+@ItNm+Char(39)  --Modified by Priyanka B on 01022018 for Bug-31241
End
If(@ItTyp<>'')
Begin
	Set @SqlCommand=rtrim(@SqlCommand)+' And It.[type]='+Char(39)+@ItTyp+Char(39)
End


Print @SqlCommand
Execute sp_Executesql @SqlCommand
--execute USP_Ent_eWayBill_ItMast_json '','',''
If(@GrpNm<>'')
Begin
	Drop Table #ItGrid
End


End
