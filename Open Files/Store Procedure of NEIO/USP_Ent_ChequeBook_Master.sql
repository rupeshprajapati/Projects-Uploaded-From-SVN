IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Ent_ChequeBook_Master]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Ent_ChequeBook_Master]
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
Create  Procedure [dbo].[USP_Ent_ChequeBook_Master]
(
	@LocCode  Varchar(3),@Bank_Nm Varchar(60),@Book_Status varchar(10)
)
As
Begin
	Declare @SqlCommand nvarchar(4000)

	Select Sel=0,Bank_Nm,Chq_From,Chq_To,Book_Id, convert(varchar,Book_Act_Dt, 103)as Book_Act_Dt,convert(varchar,Book_Deact_Dt, 103)as Book_Deact_Dt,TotalChq=cast(0 as int),Available=cast(0 as int),Issue=cast(0 as int),Cancelled=cast(0 as int),Reco=cast(0 as int),UnReco=cast(0 as int),PDC=cast(0 as int),Inv_Sr,Book_Id 
	,Location=isnull(l.Loc_Desc,'')
	From ChequeBookMaster c
	left Join Loc_Master l on (c.Loc_Code=l.Loc_Code)
	--SET DATEFormat dmy
	--Print @EDATE
	Select Entry_Ty,BCode_Nm=(Case When isNull(BCode_Nm,'')='' Then Entry_Ty Else BCode_Nm End) InTo #lCode From LCode

	--Select Part='11AAAA',ctin=cast('' as varchar(15)),inum=m.Inv_NO,idt=m.[Date],Val=m.Net_Amt,POS=cast('' as varchar(2))
	--,rchrg=Cast('' as varchar(1)),inv_typ=Cast('' as varchar(5))
	--,num=cast(0 as int),txval=m.Net_Amt,rt=cast (0 as Decimal(10,3)),camt=m.Net_Amt,samt=m.Net_Amt,iamt=m.Net_Amt,csamt=m.Net_Amt
	--,etin=cast('' as varchar(15)),sply_ty=cast('' as varchar(10)),Typ=cast('' as varchar(100))
	--,ntty=cast('' as varchar(1)),nt_num=cast('' as varchar(15)),nt_dt=cast('' as SmallDateTime),rsn=cast('' as varchar(1)),p_gst=cast('' as varchar(1))
	--,exp_typ=cast('' as varchar(10)),sbpcode=cast('' as varchar(20)),sbnum=cast('' as varchar(15)),sbdt=cast('' as SmallDateTime)
	--,ad_amt=cast (0 as Decimal(10,2))
	--,hsn_sc=cast('' as varchar(10)),[desc]=cast('' as varchar(30)),uqc=cast('' as varchar(30)), qty=cast (0 as Decimal(15,3))
	--,doc_num=cast (0 as int),doc_typ=cast('' as varchar(30)),[to]=cast('' as varchar(16)),[from]=cast('' as varchar(16)),totnum=cast (0 as int),cancel=cast (0 as int),net_issue=cast (0 as int)
	--,expt_amt=cast (0 as Decimal(11,2)),nil_amt=cast (0 as Decimal(11,2)),ngsup_amt=cast (0 as Decimal(11,2)),oinum=cast('' as varchar(15)),oidt=cast('' as SmallDateTime),ont_num=cast('' as varchar(15)),ont_dt=cast('' as SmallDateTime),omon=cast('' as varchar(6))
	--,Sec=Cast('' as varchar(10))
	--Into #TblB2B
	--From StMain m  
	--Where 1=2
	
	--Execute [USP_Ent_Cheque_Master] '','','N'

End
GO