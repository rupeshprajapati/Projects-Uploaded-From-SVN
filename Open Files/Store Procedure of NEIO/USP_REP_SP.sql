DROP PROCEDURE [USP_REP_SP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Nilesh Yadav on dated 26/02/2015 for Bug 25365
-- EXECUTE USP_REP_SP "main.Entry_ty = 'SP' And main.Tran_cd = 0"
-- =============================================

Create PROCEDURE  [USP_REP_SP]
@ENTRYCOND NVARCHAR(254)
AS
Declare @SQLCOMMAND as NVARCHAR(4000),@TBLCON as NVARCHAR(4000)
SET @TBLCON=RTRIM(@ENTRYCOND)

Select Entry_ty,Tran_cd=0,Date,inv_no Into #main from main Where 1=0
Create Clustered Index Idx_tmpmain On #main (Entry_ty asc, Tran_cd Asc)

set @sqlcommand='Insert Into #main Select main.Entry_ty,main.Tran_cd,main.date,main.inv_no
from main 
Where '+@TBLCON
execute sp_executesql @sqlcommand



set @SqlCommand='select m.inv_no,m.date,s.item_no,s.item,s.SP_partynm,s.sp_segment,s.qty,it.rateunit,s.rate,s.gro_amt,m.salesman,'
SET @SQLCOMMAND=@SQLCOMMAND+' '+ 'ac.ac_name,ac.add1,ac.add2,ac.add3,ac.city,ac.mailname'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'from main m'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'inner join item s on (m.entry_ty=s.entry_ty and m.tran_cd=s.tran_cd)'
set @sqlcommand=@sqlcommand+' '+'INNER JOIN #main ON (s.TRAN_CD=#main.TRAN_CD and s.Entry_ty=#main.entry_ty)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'inner join ac_mast ac on (ac.ac_id=m.ac_id)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'INNER JOIN IT_MAST it ON (s.IT_CODE=it.IT_CODE)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'where m.entry_ty=''sp'''
EXECUTE SP_EXECUTESQL @SQLCOMMAND
PRINT @SQLCOMMAND
GO
