DROP PROCEDURE [USP_DBEXPORT_UPDATE_RE_ALL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_DBEXPORT_UPDATE_RE_ALL]
(@Maintbl Varchar(10)='',@Entry_Ty Varchar(2),@Tran_cd Int,@cType Varchar(1))
As
IF OBJECT_ID(@Maintbl) IS NULL 
BEGIN
	Select 'Please pass valid table name...'
RETURN
END
Declare @Entry_All Varchar(2),@Main_tran Int,@Acseri_all Varchar(5)
Declare @Tblname varchar(10)

SELECT TOP 1 @Tblname as Tblname,a.Entry_all,a.Main_tran,a.Acseri_all
	,a.Entry_ty,a.Tran_cd,a.Acserial,a.New_all
	INTO #Tmptbl
	FROM Mainall_vw a Where 1 = 2 

Declare @Updtsql NVarchar(Max),@ParmDef NVarchar(Max)
SELECT @ParmDef = N'@Entry_Ty Varchar(2),@Tran_cd Int'

SELECT @Updtsql = 'Insert #Tmptbl 
Select Case When b.BCode_nm <> '''' Then b.BCode_nm Else b.Entry_ty End
	,a.Entry_all,a.Main_tran,a.Acseri_all
	,a.Entry_ty,a.Tran_cd,a.Acserial,a.New_all	
FROM '+@Maintbl+' a
INNER JOIN LCode b ON (a.Entry_all = b.Entry_ty)
WHERE a.Entry_Ty = @Entry_Ty AND a.Tran_cd = @Tran_cd'

Exec Sp_executesql @Updtsql,@ParmDef,@Entry_Ty=@Entry_Ty,@Tran_cd=@Tran_cd

declare mallCur Cursor for 
Select Dbo.[Fun_Dbexport_Update_re_all_statement]
	(Tblname,Cast(New_all as Varchar(50)),Entry_ty,Main_tran,Acseri_all,@cType) as Updtsql
	From #Tmptbl

Open mallCur

fetch next from mallCur into @Updtsql
while (@@fetch_status=0)
begin
	print @Updtsql
	Exec Sp_executesql @Updtsql
	fetch next from mallCur into @Updtsql
End
Close mallCur
Deallocate mallCur

Drop table #Tmptbl
GO
