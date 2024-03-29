DROP PROCEDURE [USP_Ent_Labour_Job_V_Pending]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Shrikant S. 
-- Create date: 21/03/2011
-- Description:	This Stored procedure is useful to generate Excise Annexure V for Labour Job Pending Stock.
-- Modification Date/By/Reason: 
-- Remark:
-- =============================================
Create PROCEDURE [USP_Ent_Labour_Job_V_Pending] 
@SDATE  SMALLDATETIME
AS
Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)

SELECT IIITEM.DATE,IIMAIN.INV_NO,IIITEM.ITSERIAL,IIITEM.ENTRY_TY,IIITEM.TRAN_CD,IIITEM.PARTY_NM,IIITEM.QTY,IIITEM.INV_SR,IIITEM.AC_ID
,QTY_USED=IIITEM.QTY,WASTAGE=IIITEM.QTY,RANGE='',DIVISION='',IT_MAST.CHAPNO,IT_MAST.P_UNIT,IT_MAST.IT_NAME,IRITEM.IT_CODE LR_ITCODE,IRITEM.QTY LR_QTY, IRITEM.DATE LR_DATE,BALQTY=IIITEM.QTY-(isnull(IRRMDET.QTY_USED,0)+isnull(IRRMDET.WASTAGE,0)),LR_ACMAST.AC_NAME,FITEM=LR_ITMAST.IT_NAME,FQTY=IRITEM.QTY
,PDAYS=DATEDIFF(DAY,IIITEM.DATE,'Oct  8 2009 12:00AM' ),IIITEM.RATE,IIITEM.IT_CODE,IIMAIN.DOC_NO,IIMAIN.[RULE],IIITEM.WARE_NM,IIMAIN.CONS_ID
INTO #PENDCHALL
FROM IIITEM  
INNER JOIN IIMAIN ON  (IIITEM.TRAN_CD=IIMAIN.TRAN_CD)  
INNER JOIN AC_MAST ON (AC_MAST.AC_ID=IIITEM.AC_ID)  
INNER JOIN IT_MAST ON (IIITEM.IT_CODE=IT_MAST.IT_CODE)  
LEFT JOIN IRRMDET ON (IIITEM.TRAN_CD=IRRMDET.LI_TRAN_CD AND IIITEM.ENTRY_TY=IRRMDET.LIENTRY_TY AND IIITEM.ITSERIAL=IRRMDET.LI_ITSER)  
LEFT JOIN IRMAIN ON (IRRMDET.TRAN_CD=IRMAIN.TRAN_CD)  
LEFT JOIN IRITEM ON (IRRMDET.TRAN_CD=IRITEM.TRAN_CD AND IRITEM.ENTRY_TY=IRRMDET.ENTRY_TY AND IRRMDET.ITSERIAL=IRITEM.ITSERIAL)  
LEFT JOIN AC_MAST LR_ACMAST ON (LR_ACMAST.AC_ID=IRITEM.AC_ID)  
LEFT JOIN IT_MAST LR_ITMAST ON (LR_ITMAST.IT_CODE=IRITEM.IT_CODE)  
WHERE 1=2


DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(1000)
SET @SQLCOMMAND=' INSERT INTO #PENDCHALL SELECT IRITEM.DATE,IRMAIN.INV_NO,IRITEM.ITSERIAL,IRITEM.ENTRY_TY,IRITEM.TRAN_CD,IRITEM.PARTY_NM,IRITEM.QTY,IRITEM.INV_SR,IRITEM.AC_ID,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' QTY_USED=CASE WHEN IIRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN isnull(IIRMDET.QTY_USED,0) ELSE 0 END,WASTAGE=CASE WHEN IIRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN isnull(IIRMDET.WASTAGE,0) ELSE 0 END, '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AC_MAST.RANGE,AC_MAST.DIVISION, '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' IT_MAST.CHAPNO,IT_MAST.P_UNIT, IT_MAST.IT_NAME,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' IIITEM.IT_CODE LR_ITCODE,LR_QTY=CASE WHEN IIRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN ISNULL(IIITEM.QTY,0) ELSE 0 END, IIITEM.DATE LR_DATE,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' BALQTY=IRITEM.QTY-(CASE WHEN IIRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN isnull(IIRMDET.QTY_USED,0) ELSE 0 END+CASE WHEN IIRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN isnull(IIRMDET.WASTAGE,0) ELSE 0 END),'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LR_ACMAST.AC_NAME,FITEM=LR_ITMAST.IT_NAME,FQTY=CASE WHEN IIRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' THEN ISNULL(IIITEM.QTY,0) ELSE 0 END '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,PDAYS=DATEDIFF(DAY,IRITEM.DATE,'+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+' ),IRITEM.RATE,IRITEM.IT_CODE,IRMAIN.DOC_NO,IRMAIN.[RULE],IRITEM.WARE_NM,IRMAIN.CONS_ID'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM IRITEM '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN IRMAIN ON  (IRITEM.TRAN_CD=IRMAIN.TRAN_CD) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=IRITEM.AC_ID) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN IT_MAST ON (IRITEM.IT_CODE=IT_MAST.IT_CODE) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN IIRMDET ON (IRITEM.TRAN_CD=IIRMDET.LI_TRAN_CD AND IRITEM.ENTRY_TY=IIRMDET.LIENTRY_TY AND IRITEM.ITSERIAL=IIRMDET.LI_ITSER AND IIRMDET.DATE<='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+') '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN IIMAIN ON (IIRMDET.TRAN_CD=IIMAIN.TRAN_CD) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN IIITEM ON (IIRMDET.TRAN_CD=IIITEM.TRAN_CD AND IIITEM.ENTRY_TY=IIRMDET.ENTRY_TY AND IIRMDET.ITSERIAL=IIITEM.ITSERIAL)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN AC_MAST LR_ACMAST ON (LR_ACMAST.AC_ID=IIITEM.AC_ID)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN IT_MAST LR_ITMAST ON (LR_ITMAST.IT_CODE=IIITEM.IT_CODE)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'WHERE IRMAIN.ENTRY_TY=''RL'' AND IRMAIN.DATE <='++CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ORDER BY IRITEM.DATE,IRMAIN.INV_NO,IRITEM.ITSERIAL '
print @SQLCOMMAND
EXEC SP_EXECUTESQL  @SQLCOMMAND

select Date,Inv_no,Itserial,Entry_ty,Tran_cd,Party_nm,Qty,inv_sr,ac_id,
qty_used=sum(Qty_used+WASTAGE),p_Unit,It_Name,BalQty=Qty-sum(Qty_used+WASTAGE),Rate,It_Code,DOC_NO,[rule],WARE_NM,CONS_ID
Into #PENDCHALL1 from #PENDCHALL 
Group By Date,Inv_no,Itserial,Entry_ty,Tran_cd,Party_nm,Qty,inv_sr,ac_id,p_Unit,It_Name,Rate,It_Code,DOC_NO,[rule],WARE_NM,CONS_ID

SELECT QTY,LIENTRY_TY,LI_TRAN_CD,LI_ITSER,QTY_USED=SUM(QTY_USED+WASTAGE) 
INTO #QTYUSED
FROM IIRMDET 
WHERE LI_DATE<=@SDATE
AND DATE<=@SDATE 
GROUP BY LIENTRY_TY,LI_TRAN_CD,LI_ITSER,QTY

DELETE FROM #QTYUSED WHERE QTY<>QTY_USED

DELETE FROM #PENDCHALL1 WHERE ENTRY_TY+RTRIM(CAST(TRAN_CD AS VARCHAR))+ITSERIAL IN (SELECT LIENTRY_TY+RTRIM(CAST(LI_TRAN_CD AS VARCHAR))+LI_ITSER FROM #QTYUSED)

Declare @Entry_ty Varchar(2),@fld_nm Varchar(20),@att_file Bit,@fld_lst Varchar(2000)
set @fld_lst=''
Declare LotherCursor Cursor for
Select E_code,fld_nm,att_file from Lother Where E_code='RL' 
Open LotherCursor 
Fetch Next from LotherCursor Into @Entry_ty, @fld_nm, @att_file 
While @@Fetch_Status=0
Begin
	if @att_file=1
		set @fld_lst=@fld_lst+',IRMain.'+rtrim(@fld_nm)	
	else
		set @fld_lst=@fld_lst+',IRItem.'+rtrim(@fld_nm)	
	Fetch Next from LotherCursor Into @Entry_ty, @fld_nm, @att_file 
End
Close LotherCursor 
Deallocate LotherCursor 

SET @SQLCOMMAND='SELECT a.*,IRMAIN.l_yn '+@fld_lst+' FROM #PENDCHALL1 a'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join IRItem on (IRItem.Entry_ty=a.Entry_ty and IRItem.Tran_cd=a.Tran_cd and IRItem.Itserial=a.Itserial) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Inner Join IRMain on (IRMain.Entry_ty=IRItem.Entry_ty and IRMain.Tran_cd=IRItem.Tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'ORDER BY a.DATE,a.INV_NO,a.ITSERIAL'
EXEC SP_EXECUTESQL  @SQLCOMMAND

DROP TABLE #PENDCHALL
DROP TABLE #PENDCHALL1
GO
