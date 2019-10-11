IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Ent_Vou_CheqNo]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Ent_Vou_CheqNo]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 21/03/2018
-- Description:	GSTR-1 Json
-- Modify By/date/Reason: 
-- Remark:
-- =============================================
CREATE  Procedure [dbo].[USP_Ent_Vou_CheqNo]
(
	@Bank_Nm varchar(100)
	,@trandate smalldatetime,@series varchar(20)=null  --Added by Priyanka B on 28072018 for Bug-31690
)
As
Begin
	Declare @SqlCommand nvarchar(4000)
	Declare @Chq_No int,@Chq_Exists bit,@Chq_Ava bit
	Set @Chq_No=0
	Set @Chq_Ava=0
	--Select @Chq_No=isnull(Max(cast(cheq_no as int)),0)  From BpMain  Where Bank_Nm=@Bank_Nm  --Commented by Priyanka B on 30072018 for Bug-31690
	--Commented by Priyanka B on 25082018 for Bug-31756 Start
	/*--Added by Priyanka B on 30072018 for Bug-31690 Start
	Select @Chq_No=isnull(Max(cast(bp.cheq_no as int)),0)  From BpMain bp
	inner join Cheque_Details cd on (bp.cheq_no=cd.chq_no) inner join ChequeBookMaster cb on (cd.book_id=cb.book_id)
	Where bp.Bank_Nm=Ltrim(@Bank_Nm) and (@trandate between cb.book_act_dt and cb.book_deact_dt) and bp.inv_sr=isnull(@series,'')
	--Added by Priyanka B on 30072018 for Bug-31690 End
	*/
	--Commented by Priyanka B on 25082018 for Bug-31756 End

	--Modified by Priyanka B on 25082018 for Bug-31756 Start
	SELECT TOP 1 @Chq_No = Chq_No 
	From (
		Select Chq_No=isnull(Max(cast(bp.cheq_no as int)),0) From BpMain bp
		inner join Cheque_Details cd on (bp.cheq_no=cd.chq_no) inner join ChequeBookMaster cb on (cd.book_id=cb.book_id)
		Where bp.Bank_Nm=Ltrim(@Bank_Nm) and (@trandate between cb.book_act_dt and cb.book_deact_dt) and bp.inv_sr=isnull(@series,'')
		UNION
		Select Chq_No=isnull(Max(cast(br.cheq_no as int)),0)  
		From BrMain br
		inner join Cheque_Details cd on (br.cheq_no=cd.chq_no) inner join ChequeBookMaster cb on (cd.book_id=cb.book_id)
		Where br.Bank_Nm=Ltrim(@Bank_Nm) and (@trandate between cb.book_act_dt and cb.book_deact_dt) and br.inv_sr=isnull(@series,'')
	) aa order by chq_no desc

	--Modified by Priyanka B on 25082018 for Bug-31756 End

	if (@Chq_No=0)
	Begin
		Select @Chq_No=min(Cast(Chq_No as int))-1 
		From Cheque_Details cd 
		--Where cb.Bank_Nm= Ltrim(@Bank_Nm)  --Commented by Priyanka B on 28072018 for Bug-31690
		--Added by Priyanka B on 28072018 for Bug-31690 Start
		inner join ChequeBookMaster cb on (cd.book_id=cb.book_id)
		Where cb.Bank_Nm= Ltrim(@Bank_Nm)
		and (@trandate between cb.book_act_dt and cb.book_deact_dt)
		and cb.inv_sr=isnull(@series,'')
		--Added by Priyanka B on 28072018 for Bug-31690 End
	End            
	if (@Chq_No<>0)
	Begin
		Set @Chq_No=@Chq_No+1
		Set @Chq_Exists=1
		While (@Chq_Exists=1 and @Chq_Ava=0)
		Begin
			print 'W1'
			If not Exists(Select Chq_No From Cheque_Details cd Where Bank_Nm= Ltrim(@Bank_Nm) and Chq_No=@Chq_No)
			Begin
				If not Exists(Select Chq_No From Cheque_Details cd Where Bank_Nm= Ltrim(@Bank_Nm) and Chq_No>@Chq_No)
				Begin
					Set @Chq_Exists=0
					print 'R1 '+@Bank_Nm + ' ' +cast(@Chq_No as varchar)
				End
				Else
				Begin
					Select top 1 @Chq_No= Chq_No From Cheque_Details cd Where Bank_Nm= Ltrim(@Bank_Nm) and Chq_No>@Chq_No
				End
								
			End
			Else
			Begin
				if not Exists(Select Chq_No From Cheque_Details Where Bank_Nm= @Bank_Nm and Cast(Chq_No as int)=@Chq_No and Status='Available')
				Begin
					print 'R2'
					Set @Chq_No=@Chq_No+1
				End
				Else
				Begin
					Set @Chq_Ava=1
				End

				
			End
		End --While (@Chq_Exists=1)
	End
	--Select Chq_No=Right('000000'+cast(@Chq_No as varchar),6)   --Commented by Priyanka B on 28072018 for Bug-31690
	Select Chq_No=isnull(Right('000000'+cast(@Chq_No as varchar),6),'')   --Modified by Priyanka B on 28072018 for Bug-31690
End

GO