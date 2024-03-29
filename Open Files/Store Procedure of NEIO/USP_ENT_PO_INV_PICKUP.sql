DROP PROCEDURE [USP_ENT_PO_INV_PICKUP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_ENT_PO_INV_PICKUP] (@Party_nm Varchar(Max))
As
declare @Ac_Id Int,@Lc_tran_cd int

Select @Lc_tran_cd = 0

Select @Ac_id = (Select Ac_Id From Ac_mast Where Ac_name = @Party_nm)


SELECT Tran_cd,Date,Inv_no,Party_nm,U_Lcno,U_lcdt,@Lc_tran_cd as Lc_tran_cd

      INTO #Tblpoinv

      FROM POMain WHERE Entry_ty IN ('P5')

            And Ac_id = @Ac_id

 

UPDATE #Tblpoinv SET Lc_tran_cd = b.Tran_cd, u_lcno = c.U_Lcno, U_lcdt = c.u_lcdt

      FROM #Tblpoinv a

      INNER JOIN OTHItref b ON (b.REntry_ty = 'P5' AND a.Tran_cd = b.Itref_tran)

      INNER JOIN POMain c ON (c.Entry_ty = b.Entry_ty AND c.Tran_cd = b.Tran_cd)

      WHERE b.Entry_ty = 'LC' ----AND b.REntry_ty = 'PO'


SELECT * FROM #Tblpoinv a


--- Execute USP_ENT_PO_INV_PICKUP 'Shrikant'
GO
