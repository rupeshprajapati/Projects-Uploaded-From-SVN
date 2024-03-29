DROP PROCEDURE [USP_Dbexport_4compcd_get_Linked_with]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_Dbexport_4compcd_get_Linked_with] (@Entry_Ty Varchar(2),@Tran_cd Int,@dbname varchar(20),@Comp_cd Varchar(6))
As
--[USP_Dbexport_4compcd_get_Linked_with] 'AR',259,'M011010','MUM'
--Select Tran_cd,* From M011010..ARMAIN Where Linked_with = 'MUM-AR2592011-2011'
Declare @Sqlstr NVarchar(500),@Entry_tbl Varchar(2),@Linked_With Varchar(50)
Declare @DclSQlstr Nvarchar(500)
Select @DclSQlstr = N'@Linked_WithOutput Varchar(50) OUT'

SELECT @Entry_tbl = case When BCode_nm <> ''Then BCode_nm Else Entry_ty End From LCode
Where Entry_Ty = @Entry_Ty

SELECT @Sqlstr = 'SELECT @Linked_WithOutput = Entry_ty+Cast(Tran_cd as Varchar(20))+L_Yn FROM '+@Entry_tbl+'Main WHERE Entry_Ty = '''+@Entry_Ty+''' AND Tran_cd = '+Cast(@Tran_cd as Varchar(50))
EXEC Sp_Executesql @Sqlstr,@DclSQlstr,@Linked_WithOutput = @Linked_With OUTPUT;

SET @Comp_cd = Rtrim(Ltrim(@Comp_cd))  --Added by Priyanka B on 07102017

IF @Linked_With IS NOT NULL
BEGIN
	IF @Comp_cd <> ''
	BEGIN
		SELECT @Linked_With = @Comp_cd+'-'+@Linked_With
	END
	SELECT @Sqlstr = 'SELECT Tran_cd,Linked_with FROM '+Rtrim(@dbname)+'..'+@Entry_tbl+'MAIN Where Linked_With = '''+RTrim(@Linked_With)+''''
	EXEC Sp_Executesql @Sqlstr
END
ELSE
BEGIN
	SELECT 0 as Tran_Cd,'' as Linked_With
END
GO
