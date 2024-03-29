DROP VIEW [lmain_vw]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date: 
-- Description:	
-- Modification Date/By/Reason: 15/03/2012 Amrendra : For Multi Currency Bug-1365
-- Guid line to update Bug-1365-->As your view may have some costomization so just manually add following in your view  
--		0 as fcnet_amt --->(1) for All except for multicurrency enabled transaction 
--		fcnet_amt      --->(2) for enabling Multicurrency in Taransaction 
-- Example:  add (1) in all select section
--          If you want Multi currency in PT just add (2) in PTMAIN Table column list
-- =============================================


CREATE VIEW [lmain_vw] AS
--Please read instruction above then add it manualy in all select downwards
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id,party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.ARMAIN
UNION ALL
SELECT  Tran_cd, entry_ty,Case when Entry_ty='GB' then u_cldt else date end, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, u_nature,l_yn, due_dt, 
		[rule],tax_name,serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC ,
		compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,TDSPAYTYPE,u_chqdt, U_BRANCH,BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.BPMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC ,
		compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,TDSPAYTYPE, u_chqdt, U_BRANCH,BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.BRMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt
		,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.CNMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, u_nature,l_yn, due_dt, [rule],tax_name,
		serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC ,compid,cons_id=ac_id,
		scons_id=0,sac_id=0, SPACE(10) AS u_broker, TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.CPMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC ,compid,
		cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM
		,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.CRMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id,  party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.DCMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt
		,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.DNMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, Pinvno, Pinvdt, narr, space(1) as u_nature,l_yn, due_dt, [rule],tax_name,serty,
		'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC ,compid,cons_id=ac_id,
		scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.EPMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,''
		AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.EQMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,''
		AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.ESMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,''as salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.IIMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,
		'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.IPMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.IRMAIN
UNION ALL
SELECT  Tran_cd, entry_ty,Case when Entry_ty='GA' then adj_date else date end, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, u_nature,l_yn, due_dt, [rule],tax_name,
		serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC ,compid,cons_id=ac_id,
		scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.JVMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, Pinvno, Pinvdt, narr, space(1) as u_nature,l_yn, due_dt, [rule],tax_name,
		space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC ,compid,
		cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.OBMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt
		,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.OPMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt
		,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.PCMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id,  party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.POMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id,  party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, Pinvno, Pinvdt, narr, space(1) as u_nature,  l_yn, due_dt,[rule],tax_name,
		space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC ,compid,
		cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , u_broker,0 as TDSPAYTYPE
		,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.PTMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.PRMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.SOMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id,  party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt, 
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.SQMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt, 
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.SRMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt, 
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt
		,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.SSMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id,  party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt, 
		[rule],tax_name,serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,compid,
		cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , u_broker,0 as TDSPAYTYPE
		,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.STMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id,  party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,TOT_FDISC,compid,
		cons_id=(case when isnull(cons_id,0)=0 then ac_id else cons_id end),
		scons_id=(case when isnull(scons_id,0)=0 then sac_id else scons_id end),sac_id , SPACE(10) AS u_broker,
		0 as TDSPAYTYPE,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,''as salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.SBMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE
		,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.TRMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,3 as TDSPAYTYPE
		,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.OSMAIN
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE
		,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS  --Added by Priyanka B on 28052018 for Bug-31569
		,'' as MTRNTYPE  --Added by Prajakta B. on 17072018 for Bug-31625
FROM         dbo.MAIN
--Added by Priyanka B on 25032019 for Bug-32067 Start
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE
		,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS
		,'' as MTRNTYPE
FROM         dbo.IBMAIN
--Added by Priyanka B on 25032019 for Bug-32067 End
--Added by Prajakta B on 06082019 for Bug-32775 Start
UNION ALL
SELECT  Tran_cd, entry_ty, date, doc_no, ac_id, party_nm, cate, dept, inv_no, inv_sr, gro_amt, net_amt, cheq_no,
		drawn_on,date as cheq_dt, inv_no AS Pinvno, date AS Pinvdt, narr, space(1) as u_nature,l_yn, due_dt,
		[rule],tax_name,space(1) as serty,'' AS U_IMPORM,TOT_DEDUC,TOT_TAX,TOT_EXAMT,TOT_ADD,TAXAMT,TOT_NONTAX,
		TOT_FDISC ,compid,cons_id=ac_id,scons_id=0,sac_id=0, SPACE(10) AS u_broker,0 as TDSPAYTYPE
		,'1900-01-01 00:00:00.000' AS u_chqdt,'' AS U_BRANCH,'' AS BANK_NM,salesman,0 as fcnet_amt
		,'' as AGAINSTGS
		,'' as MTRNTYPE
FROM         dbo.PIMAIN
--Added by Prajakta B on 06082019 for Bug-32775 End
GO

