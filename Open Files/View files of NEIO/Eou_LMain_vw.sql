
/****** Object:  View [dbo].[Eou_LMain_vw]    Script Date: 23-01-2019 03:24:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER  VIEW [dbo].[Eou_LMain_vw]
AS
SELECT     Tran_cd, entry_ty, date, doc_no, inv_no, l_yn, Ac_id, [rule], dept, inv_sr, cate, pinvno AS u_beno, pinvdt as u_pinvdt
FROM         dbo.PTMAIN
UNION
SELECT     Tran_cd, entry_ty, date, doc_no, inv_no, l_yn, Ac_id, [rule], dept, inv_sr, cate, Pinvno AS u_beno, pinvdt as U_Pinvdt
FROM         dbo.IRMAIN
UNION
SELECT     Tran_cd, entry_ty, date, doc_no, inv_no, l_yn, Ac_id, [rule], dept, inv_sr, cate, Pinvno AS u_beno, pinvdt as U_Pinvdt
FROM         dbo.ARMAIN
UNION
SELECT     Tran_cd, entry_ty, date, doc_no, inv_no, l_yn, Ac_id, [rule], dept, inv_sr, cate, Pinvno AS u_beno, pinvdt as u_pinvdt
FROM         dbo.OSMAIN
UNION
SELECT     Tran_cd, entry_ty, date, doc_no, inv_no, l_yn, Ac_id, [rule], dept, inv_sr, cate, Pinvno AS u_beno, pinvdt as u_pinvdt
FROM         dbo.SRMAIN			
UNION
SELECT     Tran_cd, entry_ty, date, doc_no, inv_no, l_yn, Ac_id, [rule], dept, inv_sr, cate, Pinvno AS u_beno, pinvdt as u_pinvdt
FROM         dbo.OPMAIN	--Added OPMAIN table for Bug-31112 by Suraj K. on 09/01/2018
UNION
SELECT     Tran_cd, entry_ty, date, doc_no, inv_no, l_yn, Ac_id, [rule], dept, inv_sr, cate, Pinvno AS u_beno, pinvdt as u_pinvdt
FROM         dbo.ESMAIN	--Added by Sachin N. S. on 05/04/2018 for Bug-31382
--Added by Priyanka B on 23012019 for Bug-32210 Start
UNION
SELECT     Tran_cd, entry_ty, date, doc_no, inv_no, l_yn, Ac_id, [rule], dept, inv_sr, cate, Pinvno AS u_beno, pinvdt as u_pinvdt
FROM         dbo.PQMAIN 
--Added by Priyanka B on 23012019 for Bug-32210 End
GO


