set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

---Use Erpbeta
ALTER Procedure [dbo].[USP_Crystal_Trading_profitandloss]
As 
Declare @Balance Numeric(17,2),@Level Int,@OpDrcr CHAR(2),@CLDrcr CHAR(2)
DECLARE @OrderLevel VarChar(50),@TotalRecLine Char(1),@Tblvar Varchar(20)

Select @Balance = 0
Select @Level = 0
Select @TotalRecLine = 'N'

select @Tblvar = OBJECT_ID('Tempdb..#Curprint')
If @Tblvar <> '' And @Tblvar Is Not Null
Begin
	Drop Table #Curprint 
End

SElect @TotalRecLine as TotalRecLine,@OrderLevel as LORDERLEVEL,@Level as LLevel,
	Space(1) as LMAINFLG,a.ac_Name as LAC_NAME,a.ac_Name as LGroup,@Balance as LCLBAL,
	@OrderLevel as RORDERLEVEL,@Level as RLevel,Space(1) as RMAINFLG,
	a.ac_Name as RAC_NAME,a.ac_Name as RGroup,@Balance as RCLBAL,Space(1) as TRDPLType
	Into #Curprint From ac_Group_Mast a Where 1 = 2

Select * From #Curprint

