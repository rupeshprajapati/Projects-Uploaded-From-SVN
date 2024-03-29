DROP PROCEDURE [Usp_Alert_Reorder_Level]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ramya.
-- Create date: 24/09/2011
-- Description:	This Stored procedure is useful to generate Reorder Level Report for Alert Master.
-- =============================================

CREATE PROCEDURE  [Usp_Alert_Reorder_Level] 
@CommanPara varchar(8000) 
AS

DECLARE @Fcond_Alert AS NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4),@TMPIT NVARCHAR(50)

EXECUTE [Usp_Rep_FiltCond_Alert]
@CommanPara
,@VMAINFILE='A',@VITFILE='A',@VACFILE=' '
,@It_Mast= 'It_Mast',@Ac_Mast= ''
,@vFcond_Alert =@Fcond_Alert OUTPUT
print '@Fcond_Alert '+@Fcond_Alert

if isnull(@Fcond_Alert,'')=''
begin
	set @Fcond_Alert=' WHERE 1=1 '
end

DELETE FROM ALERT_REORDERLVL

SELECT A.DATE ,A.IT_CODE,A.AC_ID Into #tmpItemTable FROM PTITEM A Where 1=2		

DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(1000)
SET @SQLCOMMAND=' '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'Insert Into #tmpItemTable SELECT MAX(A.DATE) DATE,A.IT_CODE,AC_ID=0 FROM PTITEM A  '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join it_mast on (a.it_code=it_mast.it_code AND it_mast.reorder>0)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@Fcond_Alert)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' GROUP BY A.IT_CODE  ORDER BY A.DATE DESC '           
print @SQLCOMMAND
EXEC SP_EXECUTESQL  @SQLCOMMAND

declare @it_code numeric(18,0)
declare @ac_id int
declare c1 cursor for
select distinct it_code from #tmpItemTable
open c1
fetch Next From c1 into @it_code
WHILE @@FETCH_STATUS = 0
Begin
	select Top 1 @ac_id=ac_id  from ptitem
			where it_code=@it_code
				order by date,inv_no desc
	update #tmpItemTable set ac_id=@ac_id where It_code=@it_code
fetch Next From c1 into @it_code
End
close c1
Deallocate c1


SET @SQLCOMMAND='INSERT INTO ALERT_REORDERLVL '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT IT_MAST.IT_NAME, IT_MAST.P_UNIT,IT_MAST.REORDER,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' (B.ARQTY+B.ESQTY+B.IRQTY+B.OPQTY+B.OSQTY+B.PTQTY+B.SRQTY)-(B.SSQTY+B.STQTY+B.PRQTY+B.IIQTY+B.IPQTY+B.DCQTY) AS BALQTY,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'IT_MAST.REORDER-((B.ARQTY+B.ESQTY+B.IRQTY+B.OPQTY+B.OSQTY+B.PTQTY+B.SRQTY)-(B.SSQTY+B.STQTY+B.PRQTY+B.IIQTY+B.IPQTY+B.DCQTY)) QTYORDER,'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'MAILNAME=(CASE WHEN C.MAILNAME IS NULL THEN '''' ELSE C.MAILNAME END)' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' FROM IT_MAST  '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN #tmpItemTable D ON IT_MAST.IT_CODE = D.IT_CODE '  
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN AC_MAST C ON D.AC_ID = C.AC_ID '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' LEFT JOIN IT_BAL B ON IT_MAST.IT_CODE=B.IT_CODE '
if @TMPIT<>''	
Begin
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' INNER JOIN '+@TMPIT+' E ON IT_MAST.IT_NAME=E.IT_NAME '		
End
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@Fcond_Alert)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' (B.ARQTY+B.ESQTY+B.IRQTY+B.OPQTY+B.OSQTY+B.PTQTY+B.SRQTY)-'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' (B.SSQTY+B.STQTY+B.PRQTY+B.IIQTY+B.IPQTY+B.DCQTY) < IT_MAST.REORDER '
PRINT @SQLCOMMAND
EXEC SP_EXECUTESQL  @SQLCOMMAND

DROP TABLE #tmpItemTable

SELECT [Item Name],[UOM],[Balance Qty],[ReOrder Qty] as [ReOrder Qty],[Qty To Be Ordered],[Last Purchased By] FROM ALERT_REORDERLVL
GO
