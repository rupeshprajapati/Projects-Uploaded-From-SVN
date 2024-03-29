DROP FUNCTION [Fun_Get_Item_desc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Fun_Get_Item_desc]
(@Entry_ty Varchar(2),@Tran_cd Int)
RETURNS Varchar(Max)
WITH EXECUTE AS CALLER
AS
BEGIN
	DECLARE @Item_desc Varchar(Max)
	SELECT @Item_desc = (Select ISNULL(c.It_desc,'') from Pomain a
		Inner Join Poitem b ON (a.Entry_ty = b.Entry_ty AND a.Tran_cd = b.Tran_cd)
		Inner Join It_Mast c ON (b.It_code = c.It_code) WHERE a.Entry_ty = @Entry_ty
			AND a.Tran_cd = @Tran_cd 
			FOR XML PATH(''))
	Return @Item_desc
END
GO
