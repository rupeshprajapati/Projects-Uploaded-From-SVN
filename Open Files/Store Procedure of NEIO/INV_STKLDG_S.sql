DROP PROCEDURE [INV_STKLDG_S]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [INV_STKLDG_S]
@sitem char(50),@eitem char(50),@sdate smalldatetime,@edate smalldatetime
as

select litem.entry_ty,litem.[date],litem.doc_no,litem.itserial,litem.party_nm,litem.inv_no,
litem.qty as receipt,litem.qty as o_receipt,litem.qty as issue,litem.qty as o_issue,
litem.qty as balance,litem.item as it_name,litem.ware_nm,space(40) co_name,
it_mast.chapno as u_chapno,it_mast.type,litem.[group] into #tblStkLedg from litem,it_mast where 1=2

declare @mopbal decimal(15,4),@mopbal1 decimal(15,4),@mentry_ty char(2),@mdate smalldatetime,
@mdoc_no varchar(5),@mparty_nm varchar(50),@mit_name varchar(50),@mreceipt decimal(15,4),
@MISSUE DECIMAL(15,4),@MBALANCE  DECIMAL(15,4),@MIQTY1 DECIMAL(15,4),
@MRQTY1 DECIMAL(15,4),@V DECIMAL(15,4),@V1 DECIMAL(15,4), @MQTY  DECIMAL(15,4),@MU_LQTY  DECIMAL(15,4)
DECLARE @ENTRY_TY CHAR(2),@DATE DATETIME,@DOC_NO VARCHAR(5),@PARTY_NM VARCHAR(50),
@IT_NAME VARCHAR(50),@QTY DECIMAL(15,4),@U_LQTY DECIMAL(15,4),@ITSERIAL  CHAR(20),
@CURRDT SMALLDATETIME,@ware_nm char(20),@cate char(20),@inv_sr char(20),@dept char(20),
@opening decimal(15,4),@closing decimal (15,4),@inv_no varchar(25)

set @party_nm=''
set @inv_no=''
SET @MOPBAL1=0
SET @MOPBAL=0
SET @MRECEIPT=0
SET @MISSUE=0
SET @MRQTY1=0
SET @MIQTY1=0
SET @MBALANCE=0
set @opening = 0
set @closing = 0
set @mit_name=''	
declare stk_ledg cursor for
select litem.entry_ty,litem.date,litem.doc_no,litem.party_nm,litem.item,litem.qty,litem.inv_no,
LITEM.U_LQTY,ITSERIAL,LITEM.WARE_NM,LITEM.CATE,LMAIN.INV_SR,LMAIN.DEPT
FROM LITEM 
INNER JOIN LMAIN ON (LMAIN.TRAN_CD = LITEM.TRAN_CD)
INNER JOIN  AC_MAST ON (AC_MAST.AC_NAME=LITEM.PARTY_NM)
INNER JOIN IT_MAST ON (IT_MAST.IT_NAME=LITEM.ITEM)
WHERE  (LITEM.ENTRY_TY IN (select cd from lcode where (cd in ('P ','OP','R ','LR','SR','S ','IP','I ','LI','PR','B ') or bcode_nm in ('P ','OP','R ','LR','SR','S ','IP','I ','LI','PR','B '))))
and it_mast.it_name between @sitem and @eitem and litem.date<@edate
ORDER BY LITEM.ITEM,LITEM.date,(CASE WHEN LITEM.ENTRY_TY='B ' THEN 'A' ELSE (CASE WHEN LITEM.ENTRY_TY IN ('P ','OP','R ','LR','SR') THEN 'B' ELSE 'C' END) END),LITEM.DOC_NO,LITEM.ITEM_NO

SET @CURRDT =@SDATE
OPEN STK_LEDG
FETCH NEXT FROM STK_LEDG INTO 
	@ENTRY_TY,@DATE,@DOC_NO,@PARTY_NM,@IT_NAME,@QTY,@inv_no,@U_LQTY,@ITSERIAL,@WARE_NM,@CATE,@INV_SR,@DEPT
while @@fetch_status = 0
begin
	SET @MIT_NAME=@IT_NAME
	WHILE @CURRDT<@DATE
	BEGIN
		SET @CURRDT=@CURRDT+1
	END
	IF @IT_NAME=@MIT_NAME
	BEGIN
		SET @V1=@V1+1
	END
	ELSE	
	BEGIN 
		SET @MIT_NAME=@IT_NAME
		SET @CURRDT =@SDATE
		SET @MOPBAL1=0
		SET @MRECEIPT=0
		SET @MISSUE=0
		SET @MBALANCE=0
	END
	
	SET @MENTRY_TY=@ENTRY_TY
	SET @MDATE=@DATE
	SET @MDOC_NO=@DOC_NO
	SET @MPARTY_NM=@PARTY_NM
	SET @MIT_NAME=@IT_NAME
	SET @MQTY=@QTY
	SET @MIQTY1=0
	SET @MRQTY1=0
	SET @MOPBAL=0	
	set @opening = 0
	set @closing = 0
	
	SET @MU_LQTY=@U_LQTY
	IF @DATE<@SDATE
	BEGIN
		insert into #tblStkLedg(entry_ty,date,doc_no,itserial,party_nm,inv_no,
		receipt,o_receipt,issue,o_issue,balance,it_name,ware_nm,co_name,u_chapno,type,[group])
		values('','','','','Balance B/f','',0,0,0,0,0,@it_name,'','','','','')
		IF @ENTRY_TY IN (select cd from lcode where (cd in ('P ','OP','R ','LR','SR','B ') or bcode_nm in ('P ','OP','R ','LR','SR','B ')))
		BEGIN
			SET @MOPBAL1 = @MOPBAL1 + @QTY
			set @opening = @opening + @qty
		END
		ELSE	
		BEGIN
			SET @MOPBAL1 = @MOPBAL1 - @QTY
			set @opening = @opening - @qty
		END
		IF EXISTS(SELECT  * FROM #tblStkLedg WHERE IT_NAME=@MIT_NAME)
		BEGIN
			update #tblStkLedg set BALANCE=@MOPBAL1 WHERE IT_NAME=@IT_NAME
		END
		ELSE
		BEGIN
			SET @MBALANCE=@MOPBAL1+@MRECEIPT-@MISSUE
			SET @MOPBAL=@MBALANCE-@MRQTY1+@MIQTY1	
			insert into #tblStkLedg(entry_ty,date,doc_no,itserial,party_nm,inv_no,
			receipt,o_receipt,issue,o_issue,balance,it_name,ware_nm,co_name,u_chapno,type,[group])
			values('','','','','Balance B/f','',0,0,0,0,@MOPBAL1,@it_name,'','','','','')
		END
	END
	
	IF @DATE=@SDATE
	BEGIN
		PRINT 'R1'
		IF @ENTRY_TY='B '
		BEGIN
			SET @MOPBAL1 = @MOPBAL1 + @QTY
			set @opening = @opening + @qty
			IF EXISTS(SELECT  * FROM #tblStkLedg WHERE IT_NAME=@IT_NAME and date=@date and doc_no=@doc_no and itserial=@itserial)
			BEGIN
				UPDATE #tblStkLedg SET BALANCE=@MOPBAL1 WHERE IT_NAME=@IT_NAME
			END
			ELSE
			BEGIN
				SET @MBALANCE=@MOPBAL1+@MRECEIPT-@MISSUE
				SET @MOPBAL=@MBALANCE-@MRQTY1+@MIQTY1
				insert into #tblStkLedg(entry_ty,date,doc_no,itserial,party_nm,inv_no,
				receipt,o_receipt,issue,o_issue,balance,it_name,ware_nm,co_name,u_chapno,type,[group])
				values(@entry_ty,@date,@doc_no,@itserial,@party_nm,'',0,0,0,0,@MOPBAL1,@it_name,'','','','','')
			END
		END
		ELSE 
		BEGIN
			IF @ENTRY_TY IN ('P ','OP','R ','LR','SR')
			BEGIN
				SET @MRECEIPT=@MRECEIPT+@QTY
				SET @MRQTY1=@QTY
			END
			ELSE
			BEGIN
				SET @MISSUE=@MISSUE+@QTY
				SET @MIQTY1=@QTY
			END
		END

		SET @MBALANCE=@MOPBAL1+@MRECEIPT-@MISSUE
		SET @MOPBAL=@MBALANCE-@MRQTY1+@MIQTY1	
		
		insert into #tblStkLedg(entry_ty,date,doc_no,itserial,party_nm,inv_no,
		receipt,o_receipt,issue,o_issue,balance,it_name,ware_nm,co_name,u_chapno,type,[group])
		values(@entry_ty,@date,@doc_no,@itserial,@party_nm,@inv_no,@mreceipt,0,@missue,0,@MOPBAL1,@it_name,'','','','','')

	END
	
	IF @DATE>@SDATE
	BEGIN	
		IF @ENTRY_TY IN ('P ','OP','R ','LR','SR','B ')
		BEGIN
			SET @MRECEIPT=@MRECEIPT+@QTY
			SET @MRQTY1 = @QTY
			set @closing = @closing + @qty 
		END
		ELSE
		BEGIN
			SET @MISSUE=@MISSUE+@QTY
			SET @MIQTY1=@QTY
			set @closing = @closing - @qty 
		END
		
		SET @MBALANCE=@MOPBAL1+@MRECEIPT-@MISSUE
		SET @MOPBAL=@MBALANCE-@MRQTY1+@MIQTY1	

		insert into #tblStkLedg(entry_ty,date,doc_no,itserial,party_nm,inv_no,
		receipt,o_receipt,issue,o_issue,balance,it_name,ware_nm,co_name,u_chapno,type,[group])
		values(@entry_ty,@date,@doc_no,@itserial,@party_nm,@inv_no,@mreceipt,0,@missue,0,@MOPBAL1,@it_name,'','','','','')
	END	
	WHILE @CURRDT<@DATE
	BEGIN
		SET @CURRDT=@CURRDT+1
	END
	set @closing = @opening + @closing
	set @mit_name = @it_name
	FETCH NEXT FROM STK_LEDG INTO 
	@ENTRY_TY,@DATE,@DOC_NO,@PARTY_NM,@IT_NAME,@QTY,@inv_no,@U_LQTY,@ITSERIAL,@WARE_NM,@CATE,@INV_SR,@DEPT
	if @@fetch_status <>0 or @mit_name <> @it_name
	begin
		insert into #tblStkLedg(entry_ty,date,doc_no,itserial,party_nm,inv_no,
		receipt,o_receipt,issue,o_issue,balance,it_name,ware_nm,co_name,u_chapno,type,[group])
		values('','','','','Balance C/f','',@mreceipt,0,@missue,0,@mreceipt-@missue,@it_name,'','','','','')
		set @mreceipt = 0
		set @missue = 0
		SET @MOPBAL1=0
		SET @MOPBAL=0
		SET @MRECEIPT=0
		SET @MISSUE=0
		SET @MRQTY1=0
		SET @MIQTY1=0
		SET @MBALANCE=0
	end
end

CLOSE STK_LEDG
DEALLOCATE STK_LEDG

DECLARE @rows int

select A.* FROM #tblStkLedg A

drop table #tblStkLedg
GO
