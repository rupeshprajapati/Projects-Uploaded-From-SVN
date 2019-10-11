DROP PROCEDURE [AUTO_OP_GET_BOM_DETAIL]
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

CREATE Procedure [AUTO_OP_GET_BOM_DETAIL]
(@PrimaryId Int,@Fin_qty Numeric(14,3))
as   
declare @AutoOP_id Int
SELECT @AutoOP_id as PrimaryId
	,@AutoOP_id as Fk_PrimaryId	
	,Cast(b.BomdetId as Varchar(5)) as Itserial
	,b.Srno
	,b.Rmqty as Raw_Qty
	,c.It_code
	,c.It_name
	,d.Rate
	,a.FGqty as Fg_qty
	,Req_qty = Cast((b.Rmqty*(@Fin_qty/a.FGqty)) as Numeric(14,3))
	FROM BOMHead a
	INNER JOIN Bomdet b On (a.BomId = b.BomId AND a.BomLevel = b.BomLevel)
	INNER JOIN It_mast c ON (b.RmitemId = c.It_code)
	LEFT JOIN Auto_op_detail d ON (d.PrimaryId = (-1))
	WHERE a.PrimaryId = @PrimaryId
GO
