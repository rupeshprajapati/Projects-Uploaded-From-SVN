DROP FUNCTION [FixAssetPeriod]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Function [FixAssetPeriod]
(@Date smalldatetime)
returns int
Begin
	return Case when Month(@Date) between 4 and 9 then 1 else 2 end
End
GO
