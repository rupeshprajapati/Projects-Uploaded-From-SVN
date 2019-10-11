DROP PROCEDURE [USP_ENT_GETITEMDETAILS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [USP_ENT_GETITEMDETAILS]
@It_code Numeric(10,0)
AS
Declare @Rlevel Varchar(10),@Rate Numeric(15,2),@Ac_id Numeric(10,0),@PartyNm Varchar(100)
Select Top 1 @Rlevel=Rlevel,@Rate=it_rate From IT_RATE Where It_code=@It_code and Ptype='I' Order by Rlevel

If @Rlevel is null
Begin
	Select Top 1 @Ac_id=Ac_id,@Rate=it_rate,@PartyNm=ac_name  From IT_RATE Where It_code=@It_code and Ptype='P' 
	if @Ac_id is null
		Select @Ac_id=0,@Rate=0,@PartyNm='' 
End
Else
Begin
-- Changed by Sachin N. S. on 25/01/2018 for Bug-30938 -- Start
	--Select Top 1 @Ac_id=Ac_Id,@PartyNm=ac_name From Ac_mast Where Rate_Level=@Rlevel
	
	Select Top 1 @Ac_id=a.Ac_Id,@PartyNm=a.ac_name, @Rate=b.It_Rate From ac_mast a
		inner join (Select RLevel,It_rate from IT_RATE Where It_code=@It_code and Ptype='I'
						and it_rate in (Select min(It_rate) from IT_RATE Where It_code=@It_code and Ptype='I' )) b on a.Rate_Level=b.RLevel
-- Changed by Sachin N. S. on 25/01/2018 for Bug-30938 -- End
End
--Select @Ac_id as Ac_id,@Rate as Rate,@PartyNm as Party_nm  --Commented by Priyanka B on 04052018 for Bug-30938
Select isnull(@Ac_id,0) as Ac_id,isnull(@Rate,0.00) as Rate,isnull(@PartyNm,'') as Party_nm  --Modified by Priyanka B on 04052018 for Bug-30938
GO
