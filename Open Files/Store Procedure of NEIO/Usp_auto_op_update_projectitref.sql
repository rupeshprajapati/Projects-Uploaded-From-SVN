DROP PROCEDURE [Usp_auto_op_update_projectitref]
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

CREATE Procedure [Usp_auto_op_update_projectitref](@PrimaryId Int)
As 
declare @Wk_tran_cd Int,@Ip_tran_cd Int,@Op_tran_cd Int

SELECT @Wk_tran_cd=Wk_tran_cd,@Ip_tran_cd=Ip_tran_cd,@Op_tran_cd=Op_tran_cd From Auto_op_head
	Where PrimaryId = @PrimaryId
/*Deleting old records from <Projectitref> table*/
Delete From Projectitref Where Entry_ty = 'IP' And Tran_cd = @Ip_tran_cd
Delete From Projectitref Where Entry_ty = 'OP' And Tran_cd = @Op_tran_cd

Insert Into Projectitref (Entry_ty,tran_cd,Itserial,ac_id,It_code,Item,Qty,BomId,Bomlevel,Pmkey,AEntry_ty,ATran_cd,AItserial,AQty)
Select a.Entry_ty,a.tran_cd,a.Itserial,b.ac_id,a.It_code,a.Item,a.Qty,a.BomId,a.Bomlevel,c.Inv_stk as Pmkey
	,b.Entry_ty as AEntry_ty,b.tran_cd as ATran_cd,b.Itserial as AItserial,b.Qty as AQty
	From (Select @PrimaryId as Auto_op_id,Entry_ty,Tran_cd,Itserial,ac_id,It_code,Item,Qty,BomId,Bomlevel
	From IPItem Where Entry_ty = 'IP' And Tran_cd = @Ip_tran_cd) a
Inner Join 
(Select @PrimaryId as Auto_op_id,Entry_ty,Tran_cd,ac_id,Itserial,It_code,Item,Qty,BomId,Bomlevel
	From Item Where Entry_ty = 'WK' And Tran_cd = @Wk_tran_cd) b ON (a.Auto_op_id = b.Auto_op_id)
Inner Join LCode c ON (a.Entry_ty = c.Entry_ty) 	
Where a.Auto_op_id = @PrimaryId

Insert Into Projectitref (Entry_ty,tran_cd,Itserial,ac_id,It_code,Item,Qty,BomId,Bomlevel,Pmkey,AEntry_ty,ATran_cd,AItserial,AQty)
Select a.Entry_ty,a.tran_cd,a.Itserial,b.ac_id,a.It_code,a.Item,a.Qty,a.BomId,a.Bomlevel,c.Inv_stk as Pmkey
	,b.Entry_ty as AEntry_ty,b.tran_cd as ATran_cd,b.Itserial as AItserial,b.Qty as AQty
	From (Select @PrimaryId as Auto_op_id,Entry_ty,Tran_cd,Itserial,ac_id,It_code,Item,Qty,BomId,Bomlevel
	From OPItem Where Entry_ty = 'OP' And Tran_cd = @Op_tran_cd) a
Inner Join 
(Select @PrimaryId as Auto_op_id,Entry_ty,Tran_cd,ac_id,Itserial,It_code,Item,Qty,BomId,Bomlevel
	From Item Where Entry_ty = 'WK' And Tran_cd = @Wk_tran_cd) b ON (a.Auto_op_id = b.Auto_op_id)
Inner Join LCode c ON (a.Entry_ty = c.Entry_ty) 	
Where a.Auto_op_id = @PrimaryId
GO
