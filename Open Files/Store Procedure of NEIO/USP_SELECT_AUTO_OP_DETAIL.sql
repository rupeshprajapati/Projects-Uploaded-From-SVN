DROP PROCEDURE [USP_SELECT_AUTO_OP_DETAIL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author      : Raghavendra Joshi
-- Create date : 04/01/2012
-- Description :	
-- =============================================

CREATE Procedure [USP_SELECT_AUTO_OP_DETAIL]
(
@PrimaryId Int = 0
)
As
SELECT TOP 1
	' ' as [Action]
	, a.*
	,c.It_name
	,e.BomId
	,e.BomLevel
	FROM Auto_op_detail a
	Inner Join It_Mast c ON (a.It_code = c.It_code)
	Inner Join Auto_op_head d ON (d.PrimaryId = a.Fk_PrimaryId)
	Inner Join Bomhead e ON (e.PrimaryId = d.FkBomid)
	Where a.Fk_PrimaryId = @PrimaryId
GO
