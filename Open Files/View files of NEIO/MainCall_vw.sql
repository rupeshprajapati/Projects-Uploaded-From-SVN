
/****** Object:  View [dbo].[MainCall_vw]    Script Date: 12/22/2017 15:57:54 ******/
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[MainCall_vw]'))
DROP VIEW [dbo].[MainCall_vw]
GO


-- =============================================
-- Author:
-- Create date: 
-- Description:	
-- =============================================

CREATE VIEW [dbo].[MainCall_vw]
AS
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.ARCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.BPCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.BRCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.CNCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.CPCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.CRCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.DCCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.DNCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.EPCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.EQCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.ESCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.IICALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.IPCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.IRCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.JVCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.OBCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.OPCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.PCCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.POCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.PTCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.PRCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.SOCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.SQCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.SRCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.SSCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.STCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.TRCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.SBCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.SDCALL
UNION ALL
SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
FROM         dbo.OSCALL
--UNION ALL
--SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial
--FROM         dbo.CALL
--UNION ALL
--SELECT      Tran_cd, ENTRY_TY, date, doc_no, inv_no, Ac_name, inv_sr, Ac_name l_yn,  Ac_id, date_all,cost_cen_id,COMPID,cost_cen_name,Amount, Acserial 
--FROM         dbo.NEWYEAR_ALLOC



GO


