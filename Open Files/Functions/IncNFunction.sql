DROP FUNCTION [IncNFunction]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE function [IncNFunction](@mOrderLevel varchar(50))
returns varchar(50)
as
begin 
	set @mOrderLevel = @mOrderLevel +'/ '
return @mOrderLevel
end
GO
