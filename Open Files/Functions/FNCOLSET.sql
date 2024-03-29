DROP FUNCTION [FNCOLSET]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [FNCOLSET] (@TblName Varchar(50),@FldName Varchar(50))  
Returns VarChar(100)
As
BEGIN 
Declare @ColumnSet varchar(100),@VarType varchar(20),@Length VarChar(3)
Declare @Prec VarChar(3),@Scale VarChar(3)
Select @VarType = TYPE_NAME(a.XType),@Length = a.Length,@Prec = a.xPrec,@Scale = a.xScale
	From SysColumns	a Where a.[Id] = OBJECT_ID(@TblName) And a.[Name] = @FldName
Set @ColumnSet = @VarType+'('+@Prec+','+@Scale+')'
Return @ColumnSet
END
GO
