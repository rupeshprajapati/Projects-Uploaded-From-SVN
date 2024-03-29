
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create VIEW [dbo].[Eou_LItem_vw]
AS
SELECT     Tran_cd, entry_ty, date, It_code, itserial, inv_no, item_no, inv_sr, qty, rate, re_qty, u_asseamt,examt,BCDAMT,u_basduty,
		U_CESSAMT,U_HCESAMT,CCDAMT,HCDAMT,U_CVDAMT,BCDPER,U_CESSPER ,U_HCESSPER,CCDPER,HCDPER,U_CVDPER,U_CUSTAMT,U_CUSTPER  
		,addlvat1,advatper1,TAX_NAME,TAXAMT -- BIRENDRA : FM COSTING 
FROM         dbo.PTITEM
UNION
SELECT     Tran_cd, entry_ty, date, It_code, itserial, inv_no, item_no, inv_sr, qty, rate, re_qty, u_asseamt,examt,BCDAMT,u_basduty,
		U_CESSAMT,U_HCESAMT,CCDAMT=0,HCDAMT=0,U_CVDAMT,BCDPER,U_CESSPER ,U_HCESSPER,CCDPER=0,HCDPER=0,U_CVDPER,U_CUSTAMT =0,U_CUSTPER=0  
		,0 as addlvat1,0 as advatper1,TAX_NAME,TAXAMT -- BIRENDRA : FM COSTING 
	
FROM         dbo.IRITEM
UNION
SELECT     Tran_cd, entry_ty, date, It_code, itserial, inv_no, item_no, inv_sr, qty, rate, re_qty, u_asseamt,examt,BCDAMT=0,u_basduty,
		U_CESSAMT,U_HCESAMT,CCDAMT=0,HCDAMT=0,U_CVDAMT,BCDPER=0,U_CESSPER ,U_HCESSPER,CCDPER=0,HCDPER=0,U_CVDPER,U_CUSTAMT =0,U_CUSTPER=0 
		,0 as addlvat1,0 as advatper1,TAX_NAME,TAXAMT -- BIRENDRA : FM COSTING 
FROM         dbo.ARITEM
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

