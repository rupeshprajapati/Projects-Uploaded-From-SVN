DROP PROCEDURE [USP_Chk_ComMenuRange]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 04/12/2009
-- Description:	This Stored Procedure is useful to Check if Range is Exists or Not. If Range is exists or passed value is 0 then it will return New value. If  value is not zero and range is not exists it will return same value.
-- Modification Date/By/Reason:
-- Remark:
-- =============================================
CREATE PROCEDURE [USP_Chk_ComMenuRange] 
@irange numeric
,@rrange  numeric OUTPUT
AS
begin
	PRINT 'A1'
	PRINT 	@irange
	set @rrange=0
	if isnull(@irange,0)<>0
	begin
		if exists(select [range] from com_menu where [range]=@irange)
		begin
			select @rrange=max(cast([range] as numeric)) from com_menu 
			set @rrange=@rrange+1
		end
		else
		begin
			set @rrange=@irange
		end
	end
	else
	begin
		select @rrange=max(cast([range] as numeric)) from com_menu 
		set @rrange=@rrange+1
	end
	
end
GO
