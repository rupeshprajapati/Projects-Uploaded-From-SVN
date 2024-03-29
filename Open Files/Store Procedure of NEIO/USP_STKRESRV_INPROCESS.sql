DROP PROCEDURE [USP_STKRESRV_INPROCESS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==========================================================
-- PROCEDURE NAME		   : USP_STKRESRV_GOODSINSTOCK
-- PROCEDURE DESCRIPTION   : USED TO GET GOODS IN STOCK DETAILS IN STOCK RESERVATION MODULE
-- MODIFIED DATE/BY/REASON :
-- REMARK				   : 
-- ==========================================================
CREATE PROCEDURE [USP_STKRESRV_INPROCESS]
@SPCond VARCHAR(4000)
AS
Declare @SQLCOMMAND as NVARCHAR(4000)
Declare @TMPTBLSO as VARCHAR(50),@TMPTBLWO as VARCHAR(50),@TRANTY as VARCHAR(50)
Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50),@TBLNAME2 as VARCHAR(50),@TBLNAME3 as VARCHAR(50),@TBLNAME4 as VARCHAR(50)

Select * Into #Tmp1 from USP_ENT_SPLITCOND(@SPCond)
Select Top 1 @TMPTBLSO = SVal From #Tmp1 Where SCond = 'TMPTBLSO'
Select Top 1 @TMPTBLWO = SVal From #Tmp1 Where SCond = 'TMPTBLWO'
Select Top 1 @TRANTY = SVal From #Tmp1 Where SCond = 'TRANTY'


Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
Set @TBLNAME1 = '##TMP1'+@TBLNM
Set @TBLNAME2 = '##TMP2'+@TBLNM
Set @TBLNAME3 = '##TMP3'+@TBLNM
Set @TBLNAME4 = '##TMP4'+@TBLNM

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' SELECT It_code Into '+@TBLNAME1+' From '+@TMPTBLSO+' Group by It_code' 
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' SELECT a.Entry_ty,a.Tran_cd,a.ItSerial,a.It_code,b.Inv_no,b.Date,a.BatchNo,a.MfgDt,a.ExpDt
,a.Qty,a.Qty as TotAlloc,a.Qty as BalQty,a.Qty as Allocate,c.Code_nm
INTO '+@TBLNAME2+' FROM ITEM a
Inner Join MAIN b on a.Entry_ty = b.Entry_ty And a.Tran_cd = b.Tran_cd 
Inner Join Lcode c on a.Entry_ty = c.Entry_ty And (c.Entry_ty in (''WK'') or c.BCode_Nm in (''WK''))
Inner Join '+@TBLNAME1+' d on a.It_code = d.It_code
Union All
 SELECT a.Entry_ty,a.Tran_cd,a.ItSerial,a.It_code,b.Inv_no,b.Date,'' '' as BatchNo,'' '' as MfgDt,'' '' as ExpDt
,a.Qty,a.Qty as TotAlloc,a.Qty as BalQty,a.Qty as Allocate,c.Code_nm
FROM POITEM a
Inner Join POMAIN b on a.Entry_ty = b.Entry_ty And a.Tran_cd = b.Tran_cd 
Inner Join Lcode c on a.Entry_ty = c.Entry_ty And (c.Entry_ty in (''PO'') or c.BCode_Nm in (''PO''))
Inner Join '+@TBLNAME1+' d on a.It_code = d.It_code'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set TotAlloc = 0,BalQty = 0,Allocate = 0'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select *  INTO '+@TMPTBLWO+
	' From StkResrvDet Where It_code in (Select It_code From '+@TMPTBLSO+') 
	 and Entry_ty in (select entry_ty from lcode where entry_ty in (''PO'',''WK'') or bcode_nm in (''PO'',''WK'') )'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select Entry_ty,Tran_cd,Itserial,Sum(AllocQty) As TotAlloc INTO '+@TBLNAME3+
	' From '+@TMPTBLWO+' Where REntry_ty in (select entry_ty from lcode where entry_ty in (''SO'') or bcode_nm in (''SO'') )
	 Group by Entry_ty,Tran_cd,Itserial'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select aEntry_ty,aTran_cd,aItserial,Sum(Qty) As Qty INTO '+@TBLNAME4+
	' From ProjectItRef Where Entry_ty  in (select entry_ty from lcode where entry_ty in (''OP'') or bcode_nm in (''OP'') )
	Group by aEntry_ty,aTran_cd,aItserial'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set TotAlloc = b.TotAlloc From '+@TBLNAME2+' a,'+@TBLNAME3+' b 
	Where  a.Entry_ty = b.Entry_ty and a.Tran_cd = b.Tran_cd and a.ItSerial = b.ItSerial'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set TotAlloc = (case when a.TotAlloc > b.qty then a.TotAlloc else b.qty end) From '+@TBLNAME2+' a,'+@TBLNAME4+' b 
	Where  a.Entry_ty = b.aEntry_ty and a.Tran_cd = b.aTran_cd and a.ItSerial = b.aItSerial '
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Update  '+@TBLNAME2+' Set BalQty = Qty - (TotAlloc + Allocate)'
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Drop Table  '+@TBLNAME3
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Drop Table  '+@TBLNAME4
EXECUTE SP_EXECUTESQL @SQLCOMMAND

Set @SQLCOMMAND = ''
Set @SQLCOMMAND = ' Select * From  '+@TBLNAME2+' order by date,itserial'
EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
