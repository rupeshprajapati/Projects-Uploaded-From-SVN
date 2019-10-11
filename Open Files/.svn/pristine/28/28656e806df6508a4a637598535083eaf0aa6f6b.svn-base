If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_ITC_04_BackJW')
Begin
	Drop Procedure USP_REP_ITC_04_BackJW
End
/****** Object:  StoredProcedure [dbo].[USP_REP_ITC_04_BackJW]    Script Date: 05/07/2018 13:08:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- EXECUTE USP_REP_ITC_04_BackJW '04/01/2018','03/31/2019'
-- Author: Prajakta B.
-- Create date:05/07/2018
-- Description:	This Stored procedure is useful to generate Form GST ITC-04 Excel.
-- Remark:
-- =============================================

Create PROCEDURE [dbo].[USP_REP_ITC_04_BackJW] 
@LSTARTDATE  SMALLDATETIME,@LENDDATE SMALLDATETIME
AS

SET DATEFORMAT dmy	SELECT * FROM (

--SELECT distinct GSTIN=case when ac_mast.GSTIN='UNREGISTERED' THEN '' else ac_mast.GSTIN end,ir_state=st.LetrCode  --Commented by Priyanka B on 16082019 for Bug-32739
SELECT GSTIN=case when ac_mast.GSTIN='UNREGISTERED' THEN '' else ac_mast.GSTIN end,ir_state=st.LetrCode  --Modified by Priyanka B on 16082019 for Bug-32739
,irname='Goods Received back from JW',
ir_invno=case when iiitem.pinvno='' then iiitem.inv_no else IIITEM.Pinvno end,
ir_date=case when iiitem.pinvdt='' then iiitem.date else IIITEM.pinvdt end
,'' as chno_jw,iim.[date] as chdt_jw, '' as chgstin_jw,'' as chstate_jw,'' as invno_sjw,'' as date_sjw,
ir_It_Desc=(CASE WHEN ISNULL(IT_MAST.it_alias,'')='' THEN IT_MAST.it_name ELSE IT_MAST.it_alias END),
ir_p_unit=case when iii.QTY>0 then IT_MAST.P_UNIT else '' end,ir_qty=iii.qty,ir_taxamt=iii.U_ASSEAMT,
TypeofGoods= case when IT_MAST.[type]='Machinery/Stores' then 'Capital' else 'Input' end
FROM iritem iii
INNER JOIN irmain iim ON  (iii.TRAN_CD=iim.TRAN_CD and iii.entry_ty=iim.entry_ty) 
LEFT JOIN IRRMDET ON (iii.TRAN_CD=IRRMDET.TRAN_CD AND iii.ENTRY_TY=IRRMDET.ENTRY_TY AND iii.ITSERIAL=IRRMDET.itserial)
left Join IIITEM on(IIITEM.entry_ty=IRRMDET.lientry_ty and IIITEM.Tran_cd=IRRMDET.li_Tran_cd AND IIITEM.ITSERIAL=IRRMDET.LI_ITSER  )
INNER JOIN AC_MAST ac_mast ON (ac_mast.AC_ID=iii.AC_ID)
INNER JOIN [STATE] st on (st.State_id = ac_mast.State_id)
INNER JOIN IT_MAST IT_MAST ON (iii.IT_CODE=IT_MAST.IT_CODE)
where iim.entry_ty='LR'	and (iim.date BETWEEN @LSTARTDATE AND @LENDDATE)

union all

--SELECT distinct GSTIN=case when ac_mast1.GSTIN='UNREGISTERED' THEN '' else ac_mast1.GSTIN end,st1.LetrCode as ir_state  --Commented by Priyanka B on 16082019 for Bug-32739
SELECT GSTIN=case when ac_mast1.GSTIN='UNREGISTERED' THEN '' else ac_mast1.GSTIN end,st1.LetrCode as ir_state  --Modified by Priyanka B on 16082019 for Bug-32739
,irname='Goods Sent out to another JW',
case when IIITEM.pinvno='' then IIITEM.inv_no else IIITEM.pinvno end as ir_invno,
case when IIITEM.pinvdt='' then IIITEM.date else IIITEM.Pinvdt end as ir_date,
chno_jw=iim.inv_no,chdt_jw=iim.[date],
chgstin_jw=ac_mast.GSTIN,chstate_jw=st.LetrCode,'' as invno_sjw,'' as date_sjw,
ir_It_Desc=(CASE WHEN ISNULL(IT_MAST.it_alias,'')='' THEN IT_MAST.it_name ELSE IT_MAST.it_alias END),
ir_p_unit=case when iii.QTY>0 then IT_MAST.P_UNIT else '' end,ir_qty=iii.qty,ir_taxamt=iii.U_ASSEAMT,
TypeofGoods= case when IT_MAST.[type]='Machinery/Stores' then 'Capital' else 'Input' end
FROM iritem iii
INNER JOIN irmain iim ON  (iii.TRAN_CD=iim.TRAN_CD and iii.entry_ty=iim.entry_ty) 
LEFT JOIN IRRMDET ON (iii.TRAN_CD=IRRMDET.TRAN_CD AND iii.ENTRY_TY=IRRMDET.ENTRY_TY AND iii.ITSERIAL=IRRMDET.itserial)
left Join IIITEM on(IIITEM.entry_ty=IRRMDET.lientry_ty and IIITEM.Tran_cd=IRRMDET.li_Tran_cd AND IIITEM.ITSERIAL=IRRMDET.LI_ITSER  )
INNER JOIN AC_MAST ac_mast ON (ac_mast.AC_ID=iii.AC_ID)
INNER JOIN [STATE] st on (st.State_id = ac_mast.State_id)
inner join AC_MAST ac_mast1 on (ac_mast1.Ac_id=IIITEM.Ac_id)
INNER JOIN [STATE] st1 on (st1.State_id = ac_mast1.State_id)
INNER JOIN IT_MAST IT_MAST ON (iii.IT_CODE=IT_MAST.IT_CODE) 	
where iim.entry_ty='R1' and (iim.date BETWEEN @LSTARTDATE AND @LENDDATE)

union all

--SELECT  distinct  '' as GSTIN,st.LetrCode as ir_state  --Commented by Priyanka B on 16082019 for Bug-32739
SELECT '' as GSTIN,st.LetrCode as ir_state  --Modified by Priyanka B on 16082019 for Bug-32739
,irname='Goods Supplied from JW',iii.U_INVNOPSP as ir_invno,iii.U_INVDTPSP as ir_date,'' as chno_jw
,iim.[date] as chdt_jw, '' as chgstin_jw,'' as chstate_jw,invno_sjw=iim.inv_no,date_sjw=iim.date,
ir_It_Desc=(CASE WHEN ISNULL(IT_MAST.it_alias,'')='' THEN IT_MAST.it_name ELSE IT_MAST.it_alias END),
ir_p_unit=case when iii.QTY>0 then IT_MAST.P_UNIT else '' end,ir_qty=iii.qty,ir_taxamt=iii.U_ASSEAMT,
TypeofGoods= case when IT_MAST.[type]='Machinery/Stores' then 'Capital' else 'Input' end
FROM stitem iii
INNER JOIN stmain iim ON  (iii.TRAN_CD=iim.TRAN_CD and iii.entry_ty=iim.entry_ty) 
INNER JOIN AC_MAST ac_mast ON (ac_mast.AC_ID=iii.AC_ID)
INNER JOIN [STATE] st on (st.State_id = ac_mast.State_id)
INNER JOIN IT_MAST IT_MAST ON (iii.IT_CODE=IT_MAST.IT_CODE)	
where iim.entry_ty='ST' and iii.u_invnopsp<>'' and iii.u_invdtpsp<>''  and (iim.date BETWEEN @LSTARTDATE AND @LENDDATE)
)aa
order by aa.chdt_jw
