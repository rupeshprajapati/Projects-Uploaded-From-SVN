If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_Ent_eWayBill_AcMast_json')
Begin
	Drop Procedure USP_Ent_eWayBill_AcMast_json
End
/****** Object:  StoredProcedure [dbo].[USP_Ent_eWayBill_AcMast_json]    Script Date: 01-Feb-18 11:38:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 31/01/2018
-- Description:	This Stored procedure is useful for eWayBill Customer and Suppllier Master Json Deatails
-- Modify By/date/Reason: 
-- Remark:
-- =============================================
CREATE Procedure [dbo].[USP_Ent_eWayBill_AcMast_json]
(
	--@AcNm varchar(100),@GrpNm Varchar(100),@AcTyp varchar(1)  --Commented by Priyanka B on 07022018 for Bug-31242
	@AcNm varchar(100),@GrpNm Varchar(100),@AcTyp varchar(2)  --Modified by Priyanka B on 07022018 for Bug-31242
)
As
Begin

Declare @SqlCommand nvarchar(4000)
If(@AcTyp='C' and @GrpNm='')
Begin
	Set @GrpNm='(''SUNDRY DEBTORS'')'
End
If(@AcTyp='S' and @GrpNm='')
Begin
	Set @GrpNm='(''SUNDRY CREDITORS'')'
End
If(@AcTyp='CS' and @GrpNm='')
Begin
	Set @GrpNm='(''SUNDRY DEBTORS'',''SUNDRY CREDITORS'')'
End


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
			Set @T=@T+1  --Added by Priyanka B on 08022018 for Bug-31242
		End
		Else
		Begin
			Set @T=0
		End
	End
End
 
--Set @SqlCommand='Select Sel=Cast(0 as Bit),client_type=(Case When isnull(ac.GSTIN,'''')<>'''' Then ''Reg'' else ''UnReg'' End) ,clientGstin=Ac.GSTIN,clientName=ac.Ac_Name,clientBusAddr1=ac.add1,clientBusAddr2=ac.add2,clientBusPlace=ac.City,clientBusPincode=ac.zip,clientMob=ac.Phone,clientEmail=ac.Email,State_Name=isnull(st.[State],''''),clientStateCode=st.GST_State_Code,approxDistance=99,GrpNm=ac.[Group]'  --Commented by Priyanka B on 05022018 for Bug-31242
--Modified by Priyanka B on 05022018 for Bug-31242 Start
Set @SqlCommand='Select Sel=Cast(0 as Bit),client_type=(Case When isnull(ac.GSTIN,'''')<>'''' and isnull(ac.GSTIN,'''')<>''UNREGISTERED'' Then ''Reg'' else ''UnReg'' End) 
,clientGstin=(Case when isnull(sh.GSTIN,'''')<>'''' then isnull(sh.GSTIN,'''') else isnull(ac.GSTIN,'''') end)
,clientName=(Case when isnull(sh.mailname,'''')<>'''' then isnull(sh.mailname,'''') else isnull(ac.mailname,'''') end)
,clientBusAddr1=(Case when isnull(sh.add1,'''')<>'''' then isnull(sh.add1,'''') else isnull(ac.add1,'''') end)
,clientBusAddr2=(Case when isnull(sh.add2,'''')<>'''' then isnull(sh.add2,'''') else isnull(ac.add2,'''') end)
,clientBusPlace=(Case when isnull(sh.city,'''')<>'''' then isnull(sh.city,'''') else isnull(ac.city,'''') end)
,clientBusPincode=(Case when isnull(sh.zip,'''')<>'''' then isnull(sh.zip,'''') else isnull(ac.zip,'''') end)
,clientMob=(Case when isnull(sh.mobile,'''')<>'''' then isnull(sh.mobile,'''') else isnull(ac.mobile,'''') end)
,clientEmail=(Case when isnull(sh.email,'''')<>'''' then isnull(sh.email,'''') else isnull(ac.email,'''') end)
,State_Name=(Case when isnull(sh.State,'''')='''' then isnull(ac.State,'''') else isnull(sh.State,'''') end)
,clientStateCode=(select top 1 cast(GST_State_Code as varchar(2)) from state where isnull(code,'''')<>'''' and [state] = (Case when isnull(sh.State,'''')='''' then isnull(ac.State,'''') else isnull(sh.State,'''') end))
,approxDistance=(Case when isnull(sh.EWBDIST,0)<>0 then isnull(sh.EWBDIST,0) else isnull(ac.EWBDIST,0) end)
,GrpNm=ac.[Group]'
--Modified by Priyanka B on 05022018 for Bug-31242 End
Set @SqlCommand=rtrim(@SqlCommand)+' from Ac_Mast ac'
Set @SqlCommand=rtrim(@SqlCommand)+' Left Join shipto sh on (ac.ac_id=sh.ac_id)'  --Added by Priyanka B on 05022018 for Bug-31242
--Set @SqlCommand=rtrim(@SqlCommand)+' Left Join State st on (sh.State_id=st.State_Id)'  --Commented by Priyanka B on 09022018 for Bug-31242
--Set @SqlCommand=rtrim(@SqlCommand)+' Where 1=1' --Commented by Priyanka B on 05022018 for Bug-31242
Set @SqlCommand=rtrim(@SqlCommand)+' Where 1=1 and ac.defa_ac=0' --Modified by Priyanka B on 05022018 for Bug-31242
If(@GrpNm<>'')
Begin
	Set @SqlCommand=rtrim(@SqlCommand)+' And Ac.Ac_group_id in (Select Distinct Ac_group_id from #AcGrid)'
End
If(@AcNm<>'')
Begin
	Set @SqlCommand=rtrim(@SqlCommand)+' And ac.Ac_Name='+Char(39)+@ACNm+Char(39)
End
Print @SqlCommand
Execute sp_Executesql @SqlCommand
----execute USP_Ent_eWayBill_ItMast_json '','',''
If(@GrpNm<>'')
Begin
	Drop Table #AcGrid
End


End
