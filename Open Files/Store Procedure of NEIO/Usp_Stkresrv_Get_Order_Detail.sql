DROP PROCEDURE [USP_STKRESRV_GET_ORDER_DETAIL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- PROCEDURE NAME		   : USP_STKRESRV_GET_SALESORDER_DETAIL
-- PROCEDURE DESCRIPTION   : USED TO GET ORDER DETAIL IN STOCK RESERVATION MODULE
-- REMARK				   : 
-- ==========================================================
CREATE PROCEDURE [USP_STKRESRV_GET_ORDER_DETAIL]
@SPCond VARCHAR(4000)
AS
Declare @SQLCOMMAND as NVARCHAR(4000)
Declare @TMPTBLSO as VARCHAR(50),@TRANTY as VARCHAR(50),@MAINTBL as VARCHAR(50),@ITEMTBL as VARCHAR(50)
Declare @TRANID as VARCHAR(50),@PARTY as VARCHAR(50),@ITEM as VARCHAR(50),@FiltType as VARCHAR(50)

Select * Into #Tmp1 from USP_ENT_SPLITCOND(@SPCond)
Select Top 1 @TMPTBLSO = SVal From #Tmp1 Where SCond = 'TMPTBLSO'
Select Top 1 @TRANTY = SVal From #Tmp1 Where SCond = 'TRANTY'
Select Top 1 @MAINTBL = SVal From #Tmp1 Where SCond = 'MAINTBL'
Select Top 1 @ITEMTBL = SVal From #Tmp1 Where SCond = 'ITEMTBL'
Select Top 1 @TRANID = SVal From #Tmp1 Where SCond = 'TRANID'
Select Top 1 @PARTY = SVal From #Tmp1 Where SCond = 'PARTY'
Select Top 1 @ITEM = SVal From #Tmp1 Where SCond = 'ITEM'
Select Top 1 @FiltType = SVal From #Tmp1 Where SCond = 'FILTTYPE'

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' SELECT a.Entry_ty,a.Tran_cd,a.ItSerial,a.It_code,a.Item,a.Qty,a.Re_qty,b.Inv_No,b.Date,b.Due_dt,b.Party_nm
,ISNULL(c.AllocQty,0) as BalAllQty, a.Item_No,'''' as Dc_No INTO '+@TMPTBLSO+' FROM '+@ITEMTBL+' a
Inner Join '+@MAINTBL+' b on a.Entry_ty = b.Entry_ty And a.Tran_cd = b.Tran_cd 
Left Join StkResrvSum c on a.Entry_ty = c.Entry_ty And a.Tran_cd = c.Tran_cd And a.ItSerial = c.ItSerial
inner join it_mast it on (a.it_code=it.it_code)  --Added by Priyanka B on 27052019 for Bug-32555
Where 1 = 1' 
+'and it.nonstk=''Stockable'''   --Added by Priyanka B on 27052019 for Bug-32555

--,ISNULL(c.AllocQty,0) as BalAllQty INTO '+@TMPTBLSO+' FROM '+@ITEMTBL+' a

If @TRANTY !=''
Begin
	Set @SQLCOMMAND = @SQLCOMMAND +  ' And B.Entry_ty = '''+@TRANTY+''''
End
If @TRANID !=''
Begin
	Set @SQLCOMMAND = @SQLCOMMAND +  ' And B.Tran_cd ='+@TRANID
End
If @PARTY !=''
Begin
	Set @SQLCOMMAND = @SQLCOMMAND +  ' And B.Ac_id ='+@PARTY
End
If @ITEM !=''
Begin
	Set @SQLCOMMAND = @SQLCOMMAND +  ' And A.It_code ='+@ITEM
End

EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TMPTBLSO+' Set Re_Qty = Qty - Re_Qty,BalAllQty = Qty-BalAllQty'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

If @FiltType = 'PENDING'
Begin
	Set @SQLCOMMAND = ''
	Set @SQLCOMMAND = 'Delete From  '+@TMPTBLSO+' Where BalAllQty = 0'
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
End
If @FiltType = 'FULLALLOC'
Begin
	Set @SQLCOMMAND = ''
	Set @SQLCOMMAND = 'Delete From  '+@TMPTBLSO+' Where BalAllQty > 0'
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
End

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' SELECT * From  '+@TMPTBLSO+' order by due_dt,date,party_nm,item'
EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
