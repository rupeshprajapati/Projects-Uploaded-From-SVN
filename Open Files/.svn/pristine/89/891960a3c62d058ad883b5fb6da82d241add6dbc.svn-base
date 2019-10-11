IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Ent_Cheque_Det]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Ent_Cheque_Det]
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
CREATE  Procedure [dbo].[USP_Ent_Cheque_Det]
(
	@Book_Id int
)
As
Begin
	Declare @SqlCommand nvarchar(4000)
	Declare @ErrMsg Varchar(100)

	Select Sel=Cast(0 as Bit),Chq_No,Status,TrnNm=IsNull(l.Code_Nm,''),PartyNm=IsNull((Case When IsNull(MailName,'')='' Then Ac_Name Else MailName End),'')
	From Cheque_Details c 
	Left join Lcode l on (l.Entry_Ty=c.Iss_Entry_Ty)
	Left Join BPMain m on (c.Iss_Tran_Cd=m.Tran_Cd)
	Left Join Ac_Mast Ac on (m.Ac_Id=ac.Ac_Id)
	Where c.Book_Id=@Book_Id
	Order By Cast(Chq_No as int)
	--Execute USP_Ent_Cheque_Det 11

End

GO


