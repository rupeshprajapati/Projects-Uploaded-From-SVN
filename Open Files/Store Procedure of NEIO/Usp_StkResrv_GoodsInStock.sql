DROP PROCEDURE [USP_STKRESRV_GOODSINSTOCK]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- PROCEDURE NAME		   : USP_STKRESRV_GOODSINSTOCK
-- PROCEDURE DESCRIPTION   : USED TO GET GOODS IN STOCK DETAILS IN STOCK RESERVATION MODULE
-- MODIFIED DATE/BY/REASON : Sachin N. S. on 27/02/2014 for Bug-21381
-- REMARK				   : 
-- ==========================================================
CREATE PROCEDURE [USP_STKRESRV_GOODSINSTOCK]
@SPCond VARCHAR(4000)
AS
Declare @SQLCOMMAND as NVARCHAR(4000)
Declare @TMPTBLSO as VARCHAR(50),@TMPTBLOP as VARCHAR(50),@TRANTY as VARCHAR(50)
Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50),@TBLNAME2 as VARCHAR(50),@TBLNAME3 as VARCHAR(50)
,@TBLNAME4 as varchar(50)  --Added by Priyanka B on 21092018 for Bug-31756

Select * Into #Tmp1 from USP_ENT_SPLITCOND(@SPCond)
Select Top 1 @TMPTBLSO = SVal From #Tmp1 Where SCond = 'TMPTBLSO'
Select Top 1 @TMPTBLOP = SVal From #Tmp1 Where SCond = 'TMPTBLOP'
Select Top 1 @TRANTY = SVal From #Tmp1 Where SCond = 'TRANTY'


Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
Set @TBLNAME1 = '##TMP1'+@TBLNM
Set @TBLNAME2 = '##TMP2'+@TBLNM
Set @TBLNAME3 = '##TMP3'+@TBLNM
Set @TBLNAME4 = '##TMP4'+@TBLNM  --Added by Priyanka B on 21092018 for Bug-31756

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' SELECT It_code Into '+@TBLNAME1+' From '+@TMPTBLSO+' Group by It_code' 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' SELECT a.Entry_ty,a.Tran_cd,a.ItSerial,a.It_code,b.Inv_no,b.Date,a.BatchNo,a.MfgDt,a.ExpDt
	,a.Qty,a.Qty as TotAlloc,a.Qty as BalQty,a.Qty as Allocate
	,a.Qty as GoodsSold  --Added by Priyanka B on 21092018 for Bug-31756
	,c.Code_nm,a.Ware_nm,a.Dc_No
	INTO '+@TBLNAME2+' FROM STKL_VW_ITEM a
	Inner Join STKL_VW_MAIN b on a.Entry_ty = b.Entry_ty And a.Tran_cd = b.Tran_cd 
	Inner Join Lcode c on a.Entry_ty = c.Entry_ty And c.Inv_Stk = ''+'' 
	Inner Join '+@TBLNAME1+' d on a.It_code = d.It_code'
--,a.Qty,a.Qty as TotAlloc,a.Qty as BalQty,a.Qty as Allocate,c.Code_nm	-- Changed by Sachin N. S. on 27/02/2104 for Bug-21381
print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

--Added by Priyanka B on 21092018 for Bug-31756 Start
Set @SQLCOMMAND = ' select c.rentry_ty,c.itref_tran,c.ritserial,a.it_code
,sum(case when a.entry_ty=''ST'' then c.rqty else 0 end) as rqty 
	INTO '+@TBLNAME4+' FROM STKL_VW_ITEM a
	Inner Join STKL_VW_MAIN b on (a.Entry_ty = b.Entry_ty And a.Tran_cd = b.Tran_cd)
	inner join STKL_VW_ITREF c on (a.Entry_ty = c.Entry_ty And a.Tran_cd = c.Tran_cd and a.itserial=c.itserial)	
	group by c.rentry_ty,c.itref_tran,c.ritserial,a.it_code'
	
print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND
--Added by Priyanka B on 21092018 for Bug-31756 End


Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set TotAlloc = 0,BalQty = 0,Allocate = 0'
Set @SQLCOMMAND = @SQLCOMMAND + ' ,GoodsSold = 0'  --Added by Priyanka B on 21092018 for Bug-31756
print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select *  INTO '+@TMPTBLOP+
	' From StkResrvDet Where It_code in (Select It_code From '+@TMPTBLSO+') 
	and Entry_ty not in (select entry_ty from lcode where entry_ty in (''PO'',''WK'') or bcode_nm in (''PO'',''WK'') )'
	print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select Entry_ty,Tran_cd,Itserial,Sum(AllocQty) As TotAlloc INTO '+@TBLNAME3+
	' From '+@TMPTBLOP+' Group by Entry_ty,Tran_cd,Itserial'
	print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set TotAlloc = b.TotAlloc From '+@TBLNAME2+' a,'+@TBLNAME3+' b 
	Where  a.Entry_ty = b.Entry_ty and a.Tran_cd = b.Tran_cd and a.ItSerial = b.ItSerial'
	print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set BalQty = Qty - (TotAlloc + Allocate)'
print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select * From  '+@TBLNAME2+' order by date,itserial'
print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND


Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Drop Table  '+@TBLNAME1
print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Drop Table  '+@TBLNAME2
print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Drop Table  '+@TBLNAME3
print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Drop Table  '+@TBLNAME4
print @SQLCOMMAND 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

GO
