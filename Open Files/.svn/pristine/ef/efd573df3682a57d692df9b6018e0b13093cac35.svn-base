IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Ent_Ins_Cheque_Det]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Ent_Ins_Cheque_Det]
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
CREATE  Procedure [dbo].[USP_Ent_Ins_Cheque_Det]
(
	@AddEdit  Varchar(1),@Book_Id int,@Chq_From int,@Chq_To int,@Bank_Nm Varchar(100)
)
As
Begin
	Declare @SqlCommand nvarchar(4000)
	Declare @ErrMsg Varchar(100)



	While(@Chq_From <= @Chq_To)
	Begin
		if not exists(Select Book_Id From Cheque_Details Where Book_Id=@Book_Id and Chq_No=@Chq_From)
		Begin
			Insert Into Cheque_Details (Book_Id,Chq_No,Status,Iss_Entry_Ty,Iss_Tran_Cd,Bank_Nm) Values 
			(@Book_Id,Right ('000000'+Cast(@Chq_From as varchar),6),'Available','',0,@Bank_Nm)
		End
		set @Chq_From=@Chq_From+1
	End

	--Execute USP_Ent_Insert_Cheque_Details 'A',8,1,31

End

GO