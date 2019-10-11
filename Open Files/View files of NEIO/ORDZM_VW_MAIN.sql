DROP VIEW [ORDZM_VW_MAIN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date: 
-- Description: 
-- Modification Date/By/Reason: 27/08/2012 Amrendra : Added Query for PIMAIN Table for Bug-4909 
-- Guid line to update Bug-4909 -->As your view may have some costomization so just manually add following in your view  
--		union all then Query for PIMAIN Table
-- =============================================


CREATE VIEW [ORDZM_VW_MAIN] AS
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM STMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM SBMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Pinvdt as U_Pinvdt,PInvno as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM PTMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM ARMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM OBMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM BPMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM BRMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM CNMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM CPMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM IIMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM PCMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM POMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM SQMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM SRMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM DCMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM CRMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM DNMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Pinvdt as U_Pinvdt,Pinvno as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM EPMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM ESMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM IPMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM IRMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM JVMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM OPMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM PRMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM SSMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM EQMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM TRMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM OSMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM SOMAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM MAIN
UNION ALL
SELECT TRAN_CD, [DATE], ENTRY_TY, DOC_NO, AC_ID, PARTY_NM, NET_AMT, GRO_AMT, DEPT, CATE, INV_SR, [RULE], INV_NO,Date as U_Pinvdt,INV_NO as U_Pinvno,Tot_tax,Tot_nontax,tot_add,Tot_fdisc,Tot_deduc FROM PIMAIN
GO
