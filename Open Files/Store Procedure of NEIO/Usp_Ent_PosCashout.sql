If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Ent_PosCashout')
Begin
	Drop Procedure Usp_Ent_PosCashout
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Ent_PosCashout]    Script Date: 12/06/2018 15:42:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[Usp_Ent_PosCashout]
@UserName Varchar(50),@Date varchar(15),@CompID int,@Trancd varchar(10),@Mode int,@CNTRCODE VARCHAR(5)
as 
DECLARE @SQLSTR nvarchar(4000)
begin

if @Mode =0
Begin	
	SET @SQLSTR =''
	SET @SQLSTR =   'SELECT PayMode,sum(Totalvalue) as Totalvalue FROM PSPAYDETAIL PS INNER JOIN DCMAIN M ON M.Tran_cd=PS.Tran_cd
					WHERE PS.[user_name]='''+@UserName+''' AND isnull(M.POSOUTTRAN,0) = 0 and Convert(Varchar,PS.[date],103)<='''+@Date+''' 
					AND M.CNTRCODE = '''+@CNTRCODE+''' group by PayMode'
	PRINT @SQLSTR
	EXEC SP_EXECUTESQL  @SQLSTR						

	SET @SQLSTR =''
	SET @SQLSTR =   'SELECT ROW_NUMBER() OVER(ORDER BY USER_NAME) as Row ,ItemGrosAmt =ISNULL(SUM(A.gro_amt),0),ItemTaxAmt=ISNULL(sum(A.taxamt),0),
					ItemDiscount=ISNULL(SUM(A.tot_fdisc),0),ItemTotal=ISNULL(SUM(A.gro_amt),0)-ISNULL(sum(A.taxamt),0)-ISNULL(SUM(A.tot_fdisc),0)
					INTO ##TmpDcItem FROM DCITEM A INNER JOIN DCMAIN B ON A.TRAN_CD=B.TRAN_CD 
					WHERE ISNULL(POSOUTTRAN,0)= 0 AND B.entry_ty in (''PS'',''HS'') AND B.[user_name]='''+@UserName+''' and Convert(Varchar,B.[date],103)<='''+@Date+'''
					AND B.CNTRCODE = '''+@CNTRCODE+''' 
					GROUP BY B.[USER_NAME]'
	PRINT @SQLSTR	
	EXEC SP_EXECUTESQL  @SQLSTR	
	
	SET @SQLSTR =''
	SET @SQLSTR =   'SELECT ROW_NUMBER() OVER(ORDER BY USER_NAME) as Row,MainTaxAmt=ISNULL(SUM(taxamt),0),
					MainDiscount=ISNULL(SUM(tot_fdisc),0), Count(*) as Bills
					INTO ##TmpDcMain FROM DCMAIN WHERE ISNULL(POSOUTTRAN,0)=0 AND entry_ty in (''PS'',''HS'') AND [user_name]='''+@UserName+''' and Convert(Varchar,[date],103)<='''+@Date+'''
					AND CNTRCODE = '''+@CNTRCODE+''' 
					GROUP BY [USER_NAME]' 
	PRINT @SQLSTR
	EXEC SP_EXECUTESQL  @SQLSTR	
	
	SET @SQLSTR =''
	SET @SQLSTR =   'Select Bills,GrosAmount=SUM(ItemTotal),TaxAmount=Sum(ItemTaxAmt)+Sum(MainTaxAmt),DiscountAmt=Sum(ItemDiscount)-Sum(MainDiscount),
					NetAmount=Sum(ItemTotal)+Sum(ItemTaxAmt)+Sum(MainTaxAmt)+Sum(ItemDiscount)-Sum(MainDiscount) FROM ##TmpDcMain A INNER JOIN ##TmpDcItem B
					ON A.Row=B.Row GROUP BY Bills'
	PRINT @SQLSTR
	EXEC SP_EXECUTESQL  @SQLSTR						
END
else
Begin
	PRINT 'KISHOR'
	SET @SQLSTR =''
	SET @SQLSTR =   'SELECT PayMode,sum(Totalvalue) as Totalvalue FROM PSPAYDETAIL PS INNER JOIN DCMAIN M ON M.Tran_cd=PS.Tran_cd
					WHERE PS.[user_name]='''+@UserName+''' AND isnull(M.POSOUTTRAN,0) = '+@Trancd+' group by PayMode'
	PRINT 'KISHOR1'
	print @SQLSTR				
	EXEC SP_EXECUTESQL  @SQLSTR						

	SET @SQLSTR =''
	SET @SQLSTR =   'SELECT ROW_NUMBER() OVER(ORDER BY USER_NAME) as Row ,ItemGrosAmt =ISNULL(SUM(A.gro_amt),0),ItemTaxAmt=ISNULL(sum(A.taxamt),0),
					ItemDiscount=ISNULL(SUM(A.tot_fdisc),0),ItemTotal=ISNULL(SUM(A.gro_amt),0)-ISNULL(sum(A.taxamt),0)-ISNULL(SUM(A.tot_fdisc),0)
					INTO ##TmpDcItem FROM DCITEM A INNER JOIN DCMAIN B ON A.TRAN_CD=B.TRAN_CD 
					WHERE ISNULL(POSOUTTRAN,0)='+@Trancd+' AND B.entry_ty in (''PS'',''HS'') AND B.[user_name]='''+@UserName+'''
					GROUP BY B.[USER_NAME]'
	PRINT @SQLSTR					
	EXEC SP_EXECUTESQL  @SQLSTR	
	
	SET @SQLSTR =''
	SET @SQLSTR =   'SELECT ROW_NUMBER() OVER(ORDER BY USER_NAME) as Row,MainTaxAmt=ISNULL(SUM(taxamt),0),
					MainDiscount=ISNULL(SUM(tot_fdisc),0), Count(*) as Bills
					INTO ##TmpDcMain FROM DCMAIN WHERE ISNULL(POSOUTTRAN,0)='+@Trancd+' AND entry_ty in (''PS'',''HS'') AND [user_name]='''+@UserName+'''
					GROUP BY [USER_NAME]' 
	PRINT @SQLSTR
	EXEC SP_EXECUTESQL  @SQLSTR	
	
	SET @SQLSTR =''
	SET @SQLSTR =   'Select Bills,GrosAmount=SUM(ItemTotal),TaxAmount=Sum(ItemTaxAmt)+Sum(MainTaxAmt),DiscountAmt=Sum(ItemDiscount)-Sum(MainDiscount),
					NetAmount=Sum(ItemTotal)+Sum(ItemTaxAmt)+Sum(MainTaxAmt)+Sum(ItemDiscount)-Sum(MainDiscount) FROM ##TmpDcMain A INNER JOIN ##TmpDcItem B
					ON A.Row=B.Row GROUP BY Bills'
	EXEC SP_EXECUTESQL  @SQLSTR						


End
	
	Drop Table ##TmpDcItem
	Drop Table ##TmpDcMain
END