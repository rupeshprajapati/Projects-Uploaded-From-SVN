DROP PROCEDURE [AUTO_OP_Update_OP_PTTaxDet]
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

CREATE Procedure [AUTO_OP_Update_OP_PTTaxDet]
(
@Tran_cd int			--- IP Transaction
,@Tran_cd_op int		--- OP Transaction
)
AS 
UPDATE OP_PTTaxDet SET Entry_Ty = 'OP',Tran_cd = @Tran_cd_op,Itserial = '00001'
	WHERE Entry_Ty = 'IP' AND Tran_cd = @Tran_cd
GO
