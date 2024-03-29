If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_RD_VOU')
Begin
	Drop Procedure USP_REP_RD_VOU
End
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[USP_REP_RD_VOU]
@ENTRYCOND NVARCHAR(254)
as
Select Entry_ty,Tran_cd,itserial
,MINVNO=Inv_no,MDATE=Date,MITEM=Item
,Qty_used=Qty,Wastage=Qty,MQTY=Qty,liTran_cd=Tran_cd,Lientry=Entry_ty,li_itser=itserial,curQty_used=Qty,curWastage=Qty Into #IrItem From Iritem Where 1=2

Declare @Entry_ty Varchar(2),@date smalldatetime,@tran_cd Numeric,@Itserial Varchar(5),@inv_no Varchar(20),@it_code Numeric
Declare @LiEntry_ty Varchar(2), @Li_Tran_cd Numeric, @Li_itser Varchar(5)
Declare @SQLCOMMAND NVARCHAR(4000)

Select Entry_ty,tran_cd Into #tmpRec FROM IRITEM WHERE 1=2
set @SQLCOMMAND='Insert Into #tmpRec Select distinct Irmain.Entry_ty,Irmain.tran_cd
			from Iritem Inner join Irmain ON (Irmain.Entry_ty=Iritem.Entry_ty and Irmain.Tran_cd=Iritem.Tran_cd) 
			Where '+@ENTRYCOND
execute sp_executesql @SQLCOMMAND


-- Finding Receipts of condition
Declare ReceiptCur Cursor for
Select Iritem.Entry_ty,Iritem.date,Iritem.tran_cd,Iritem.itserial,Iritem.inv_no,Iritem.it_code FROM Iritem
	Inner join #tmpRec b on (Iritem.Entry_ty=b.Entry_ty and Iritem.Tran_cd=b.Tran_cd)
Open ReceiptCur
Fetch next from ReceiptCur Into @Entry_ty ,@date ,@tran_cd ,@Itserial ,@inv_no ,@it_code 
While @@Fetch_Status=0
Begin
print @Itserial
	-- Finding  the labour job tran_cd
	Declare IssueCur Cursor for
	Select distinct LiEntry_ty, Li_Tran_cd, Li_itser from irrmdet 
	Where Entry_ty=@Entry_ty and Tran_cd =@Tran_cd and itserial=@Itserial
	Open IssueCur
	Fetch Next From IssueCur Into @LiEntry_ty,@Li_Tran_cd,@Li_itser 
	While @@Fetch_Status=0
	Begin
		--Finding the receipt quantity of the labour job tran_cd		
--		Commented By Shrikant S. on 09/02/2011 for TKT-5602	--sTART
--		Insert Into #IrItem Select Entry_ty=@Entry_ty,Tran_cd=@tran_cd,Itserial=@Itserial,ii.u_pinvno,ii.u_pinvdt,ii.item,qty=sum(rm.Qty_used),Wastage=sum(rm.Wastage) 
--		,Qty=ii.qty,Li_Tran_cd=@Li_Tran_cd,LiEntry_ty=@LiEntry_ty,Li_itser=@Li_itser,curQty_used=sum(Case when CAST(i.inv_no AS INT) = CAST( (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END ) AS INT) and i.Date<= @date then rm.Qty_used else 0 end)
--		,curWastage=sum(Case when CAST(i.inv_no AS INT) = CAST( (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END ) AS INT) and i.Date= @date then rm.Wastage else 0 end)
--		from Irrmdet rm
--		Inner Join Iritem i on (rm.Tran_cd=i.Tran_cd and rm.Entry_ty=i.Entry_ty and rm.itserial=i.itserial)
--		Inner join Iiitem ii on (rm.LiEntry_ty=ii.Entry_ty and rm.Li_Tran_cd=ii.Tran_cd and Li_itser=ii.itserial)
--		Where LiEntry_ty=@LiEntry_ty and Li_Tran_cd=@Li_Tran_cd and Li_itser=@Li_itser 
--		and i.Date<= @date AND CAST(i.inv_no AS INT) <= CAST( (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END ) AS INT)
--		Group by ii.u_pinvno,ii.u_pinvdt,ii.item,ii.qty
--		Commented By Shrikant S. on 09/02/2011 for TKT-5602	--End
--		Added By Shrikant S. on 09/02/2011 for TKT-5602	--sTART
		Insert Into #IrItem Select Entry_ty=@Entry_ty,Tran_cd=@tran_cd,Itserial=@Itserial,ii.pinvno as u_pinvno,ii.pinvdt as u_pinvdt,ii.item,qty=sum(rm.Qty_used),Wastage=sum(rm.Wastage) 
		,Qty=ii.qty,Li_Tran_cd=@Li_Tran_cd,LiEntry_ty=@LiEntry_ty,Li_itser=@Li_itser,curQty_used=sum(Case when i.inv_no = (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END )  and i.Date<= @date then rm.Qty_used else 0 end)
		,curWastage=sum(Case when i.inv_no = (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END ) and i.Date= @date then rm.Wastage else 0 end)
		from Irrmdet rm
		Inner Join Iritem i on (rm.Tran_cd=i.Tran_cd and rm.Entry_ty=i.Entry_ty and rm.itserial=i.itserial)
		Inner join Iiitem ii on (rm.LiEntry_ty=ii.Entry_ty and rm.Li_Tran_cd=ii.Tran_cd and Li_itser=ii.itserial)
		Where LiEntry_ty=@LiEntry_ty and Li_Tran_cd=@Li_Tran_cd and Li_itser=@Li_itser 
		and i.Date<= @date AND i.inv_no <= (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END ) 
		Group by ii.pinvno,ii.pinvdt,ii.item,ii.qty
--		Added By Shrikant S. on 09/02/2011 for TKT-5602	--End
		Fetch Next From IssueCur Into @LiEntry_ty,@Li_Tran_cd,@Li_itser 
	End
	Close IssueCur 
	Deallocate IssueCur 	
Fetch next from ReceiptCur Into @Entry_ty ,@date ,@tran_cd ,@Itserial ,@inv_no ,@it_code 
End
Close ReceiptCur 
Deallocate ReceiptCur 

--Select * from #IrItem

SELECT IRITEM.ENTRY_TY ,IRITEM.TRAN_CD 
,MailName=(CASE WHEN ISNULL(MailName,'')='' THEN ac_name ELSE mailname END)
,IRITEM.INV_NO,IRITEM.DATE,iritem.itserial
,IT_Desc=(CASE WHEN ISNULL(IT_MAST.it_alias,'')='' THEN IT_MAST.it_name ELSE IT_MAST.it_alias END)
,IRITEM.QTY,IRMAIN.NET_AMT,IRITEM.ITEM_NO,IRITEM.RATE,IRITEM.GRO_AMT,U_WT=0,IT_MAST.RATEUNIT,NARR=SUBSTRING(IRITEM.NARR,1,8000),AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY
,AC_MAST.ZIP,ac_mast.[state],ac_mast.gstin
,RM.MINVNO,RM.MDATE,RM.MITEM,RM.MQTY,RM.QTY_USED,RM.WASTAGE,BALQTY=RM.MQTY -(RM.QTY_USED+RM.WASTAGE)
,RM.liTran_cd,RM.Lientry,RM.li_itser,RM.curQty_used,RM.curWastage
FROM IRMAIN  INNER  JOIN IRITEM ON  (IRITEM.ENTRY_TY=IRITEM.ENTRY_TY AND IRMAIN.TRAN_CD=IRITEM.TRAN_CD ) 
INNER JOIN AC_MAST ON (IRMAIN.AC_ID=AC_MAST.AC_ID)  
INNER JOIN IT_MAST ON (IRITEM.IT_CODE=IT_MAST.IT_CODE) 
INNER JOIN #IrItem RM ON (IRITEM.ENTRY_TY=RM.ENTRY_TY AND IRITEM.TRAN_CD=RM.TRAN_CD AND IRITEM.ITSERIAL=RM.ITSERIAL) 
Order by irmain.date,irmain.Inv_no,iritem.itserial
,RM.liTran_cd,RM.Lientry,RM.li_itser

--Select * from #IrItem

Drop table #IrItem 






