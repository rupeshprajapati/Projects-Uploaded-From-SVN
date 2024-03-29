DROP PROCEDURE [USP_REP_IL_VOU]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [USP_REP_IL_VOU]
@ENTRYCOND NVARCHAR(254)
as
Select Entry_ty,Tran_cd,itserial
,MINVNO=Inv_no,MDATE=Date,MITEM=Item
,Qty_used=Qty,Wastage=Qty,MQTY=Qty,liTran_cd=Tran_cd,Lientry=Entry_ty,li_itser=itserial,curQty_used=Qty,curWastage=Qty Into #IIItem From IIItem Where 1=2

Declare @Entry_ty Varchar(2),@date smalldatetime,@tran_cd Numeric,@Itserial Varchar(5),@inv_no Varchar(20),@it_code Numeric
Declare @LiEntry_ty Varchar(2), @Li_Tran_cd Numeric, @Li_itser Varchar(5)
Declare @SQLCOMMAND NVARCHAR(4000)

Select Entry_ty,tran_cd Into #tmpRec FROM IIITEM WHERE 1=2
set @SQLCOMMAND='Insert Into #tmpRec Select distinct Iimain.Entry_ty,Iimain.tran_cd
			from Iiitem Inner join Iimain ON (Iimain.Entry_ty=Iiitem.Entry_ty and Iimain.Tran_cd=Iiitem.Tran_cd) 
			Where '+@ENTRYCOND
execute sp_executesql @SQLCOMMAND

-- Finding Issues of condition
Declare IssueCur Cursor for
Select IIItem.Entry_ty,IIItem.date,IIItem.tran_cd,IIItem.itserial,IIItem.inv_no,IIItem.it_code FROM IIItem
	Inner join #tmpRec b on (IIItem.Entry_ty=b.Entry_ty and IIItem.Tran_cd=b.Tran_cd)
Open IssueCur
Fetch next from IssueCur Into @Entry_ty ,@date ,@tran_cd ,@Itserial ,@inv_no ,@it_code 
While @@Fetch_Status=0
Begin
--print @Itserial
--IssueCur	ReceiptCur
	-- Finding  the labour job tran_cd
	
	Declare ReceiptCur Cursor for
	Select distinct LiEntry_ty, Li_Tran_cd, Li_itser from iirmdet 
	Where Entry_ty=@Entry_ty and Tran_cd =@Tran_cd and itserial=@Itserial
	Open ReceiptCur
	Fetch Next From ReceiptCur Into @LiEntry_ty,@Li_Tran_cd,@Li_itser 

	While @@Fetch_Status=0
	Begin
		
		--Finding the receipt quantity of the labour job tran_cd		
		Insert Into #IIItem Select Entry_ty=@Entry_ty,Tran_cd=@tran_cd,Itserial=@Itserial,ii.pinvno,ii.pinvdt,ii.item,qty=sum(rm.Qty_used),Wastage=sum(rm.Wastage) 
--		,Qty=ii.qty,Li_Tran_cd=@Li_Tran_cd,LiEntry_ty=@LiEntry_ty,Li_itser=@Li_itser,curQty_used=sum(Case when CAST(i.inv_no AS INT) = CAST( (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END ) AS INT) and i.Date<= @date then rm.Qty_used else 0 end)
--		,curWastage=sum(Case when CAST(i.inv_no AS INT) = CAST( (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END ) AS INT) and i.Date= @date then rm.Wastage else 0 end) 
--Birendra:Commented above two line on 29 june 2011 for TKT - 8492
		,Qty=ii.qty,Li_Tran_cd=@Li_Tran_cd,LiEntry_ty=@LiEntry_ty,Li_itser=@Li_itser,curQty_used=sum(Case when i.inv_no =  (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END ) and i.Date<= @date then rm.Qty_used else 0 end)
		,curWastage=sum(Case when i.inv_no  =  (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END )  and i.Date= @date then rm.Wastage else 0 end) 
		from Iirmdet rm
		Inner Join Iiitem i on (rm.Tran_cd=i.Tran_cd and rm.Entry_ty=i.Entry_ty and rm.itserial=i.itserial)
		Inner join Iritem ii on (rm.LiEntry_ty=ii.Entry_ty and rm.Li_Tran_cd=ii.Tran_cd and Li_itser=ii.itserial)
		Where LiEntry_ty=@LiEntry_ty and Li_Tran_cd=@Li_Tran_cd and Li_itser=@Li_itser 
--		and i.Date<= @date AND CAST(i.inv_no AS INT) < =CAST( (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END ) AS INT)
--Birendra:Commented above line on 29 june 2011 for TKT - 8492
		and i.Date<= @date AND i.inv_no  < = (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END )
		Group by ii.pinvno,ii.pinvdt,ii.item,ii.qty

		Fetch Next From ReceiptCur Into @LiEntry_ty,@Li_Tran_cd,@Li_itser 
	End
	Close ReceiptCur 
	Deallocate ReceiptCur 	
Fetch next from IssueCur Into @Entry_ty ,@date ,@tran_cd ,@Itserial ,@inv_no ,@it_code 
End
Close IssueCur 
Deallocate IssueCur 
--Select * from #IrItem

SELECT IIITEM.ENTRY_TY ,IIITEM.TRAN_CD 
,MailName=(CASE WHEN ISNULL(MailName,'')='' THEN ac_name ELSE mailname END)
,IIITEM.INV_NO,IIITEM.DATE,IIITEM.itserial
,IT_Desc=(CASE WHEN ISNULL(IT_MAST.it_alias,'')='' THEN IT_MAST.it_name ELSE IT_MAST.it_alias END)
,IIITEM.QTY,IIMAIN.NET_AMT,IIITEM.ITEM_NO,IIITEM.RATE,IIITEM.GRO_AMT,U_WT=0,IT_MAST.RATEUNIT,NARR=SUBSTRING(IIITEM.NARR,1,8000),AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP
,RM.MINVNO,RM.MDATE,RM.MITEM,RM.MQTY,RM.QTY_USED,RM.WASTAGE,BALQTY=RM.MQTY -(RM.QTY_USED+RM.WASTAGE)
,RM.liTran_cd,RM.Lientry,RM.li_itser,RM.curQty_used,RM.curWastage
FROM IIMAIN  INNER  JOIN IIITEM ON  (IIMAIN.ENTRY_TY=IIITEM.ENTRY_TY AND IIMAIN.TRAN_CD=IIITEM.TRAN_CD ) 
INNER JOIN AC_MAST ON (IIMAIN.AC_ID=AC_MAST.AC_ID)  
INNER JOIN IT_MAST ON (IIITEM.IT_CODE=IT_MAST.IT_CODE) 
INNER JOIN #IIItem RM ON (IIITEM.ENTRY_TY=RM.ENTRY_TY AND IIITEM.TRAN_CD=RM.TRAN_CD AND IIITEM.ITSERIAL=RM.ITSERIAL) 
Order by iimain.date,iimain.Inv_no,iiitem.itserial
,RM.liTran_cd,RM.Lientry,RM.li_itser

--Select * from #IrItem

Drop table #IIItem
GO
