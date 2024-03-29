DROP PROCEDURE [USP_REP_SERVICETAX_SUMMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 
-- Description:	This Stored procedure is useful to Service Tax ACCOUNTS Summary Report (Same as Balance Listing Expcept Order by.).
-- Modification Date/By/Reason: 03/09/2009 Rupesh Prajapati. Modified for whole process.
-- Remark:
-- =============================================
--alter PROCEDURE [dbo].[USP_REP_BALLIST_SERVICETAX]  
CREATE PROCEDURE [USP_REP_SERVICETAX_SUMMARY]  
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= null
AS
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=null,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M',@VITFILE=Null,@VACFILE='AC'
,@VDTFLD ='DATE'
,@VLYN=Null
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT


select m.entry_ty,m.date,m.tran_cd,m.inv_no,typ
,m.serty
,ac_mast.ac_name,ac.amt_ty,amount,inout=2,m.l_yn,srno=9
into #serabs1
from bpmain m
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
inner join ac_mast on (ac.ac_id=ac_mast.ac_id)
inner join lcode l  on (m.entry_ty=l.entry_ty)
where 1=2

SET @SQLCOMMAND='insert into #serabs1'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'select m.entry_ty,m.date,m.tran_cd,m.inv_no,typ'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',serty=(case'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''JV'' or l.bcode_nm=''JV'' then jvm.serty'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''BR'' or l.bcode_nm=''BR'' then brm.serty'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''CR'' or l.bcode_nm=''CR'' then crm.serty' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''BP'' or l.bcode_nm=''BP'' then bpm.serty'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''CP'' or l.bcode_nm=''CP'' then cpm.serty' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''SB'' or l.bcode_nm=''SB'' then sbm.serty' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'else '''' end)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',ac_mast.ac_name,ac.amt_ty,amount,inout=1,m.l_yn'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',srno=(case'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when typ in(''Service Tax Payable'',''Service Tax Payable-Ecess'',''Service Tax Payable-Hcess'') then 4 ' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when typ in(''Output Service Tax'',''Output Service Tax-Ecess'',''Output Service Tax-Hcess'') then 3 ' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when typ in(''Service Tax Available'',''Service Tax Available-Ecess'',''Service Tax Available-Hcess'') then 2 ' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when typ in(''Input Service Tax'',''Input Service Tax-Ecess'',''Input Service Tax-Hcess'') then 1 ' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'else 0 end)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'from stkl_vw_main m'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join brmain brm on (m.entry_ty=brm.entry_ty and m.tran_Cd=brm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join crmain crm on (m.entry_ty=crm.entry_ty and m.tran_Cd=crm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join jvmain jvm on (m.entry_ty=jvm.entry_ty and m.tran_Cd=jvm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join bpmain bpm on (m.entry_ty=bpm.entry_ty and m.tran_Cd=bpm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join cpmain cpm on (m.entry_ty=cpm.entry_ty and m.tran_Cd=cpm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join sbmain sbm on (m.entry_ty=sbm.entry_ty and m.tran_Cd=sbm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join ac_mast on (ac.ac_id=ac_mast.ac_id)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join lcode l  on (m.entry_ty=l.entry_ty)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'and typ in (''Service Tax Payable'',''Service Tax Payable-Ecess'',''Service Tax Payable-Hcess'',''Output Service Tax'',''Output Service Tax-Ecess'',''Output Service Tax-Hcess'')'
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
SET @SQLCOMMAND='insert into #serabs1'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'select m.entry_ty,m.date,m.tran_cd,m.inv_no,typ'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',serty=(case'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''JV'' or l.bcode_nm=''JV'' then jvm.sertyi'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''BP'' or l.bcode_nm=''BP'' then bpm.serty'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''CP'' or l.bcode_nm=''CP'' then cpm.serty' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when l.entry_ty=''EP'' or l.bcode_nm=''EP'' then epm.serty' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'else '''' end)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',ac_mast.ac_name,ac.amt_ty,amount,inout=2,m.l_yn'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',srno=(case'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when typ in(''Service Tax Payable'',''Service Tax Payable-Ecess'',''Service Tax Payable-Hcess'') then 4 ' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when typ in(''Output Service Tax'',''Output Service Tax-Ecess'',''Output Service Tax-Hcess'') then 3 ' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when typ in(''Service Tax Available'',''Service Tax Available-Ecess'',''Service Tax Available-Hcess'') then 2 ' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'when typ in(''Input Service Tax'',''Input Service Tax-Ecess'',''Input Service Tax-Hcess'') then 1 ' 
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'else 0 end)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'from stkl_vw_main m'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join bpmain bpm on (m.entry_ty=bpm.entry_ty and m.tran_Cd=bpm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join cpmain cpm on (m.entry_ty=cpm.entry_ty and m.tran_Cd=cpm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join jvmain jvm on (m.entry_ty=jvm.entry_ty and m.tran_Cd=jvm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left join epmain epm on (m.entry_ty=epm.entry_ty and m.tran_Cd=epm.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join ac_mast on (ac.ac_id=ac_mast.ac_id)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join lcode l  on (m.entry_ty=l.entry_ty)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'and typ in (''Service Tax Available'',''Service Tax Available-Ecess'',''Service Tax Available-Hcess'',''Input Service Tax'',''Input Service Tax-Ecess'',''Input Service Tax-Hcess'')'
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

DELETE FROM #serabs1 WHERE 
DATE < (SELECT TOP 1 DATE FROM #serabs1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN)
AND AC_NAME IN (SELECT AC_NAME FROM #serabs1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN GROUP BY AC_NAME) 



--select * from #serabs1

SELECT 
OPBAL=SUM(CASE WHEN (ENTRY_TY='OB' OR DATE<@SDATE) THEN (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END)
,DAMT=SUM(CASE WHEN NOT (ENTRY_TY='OB' OR DATE<@SDATE) AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
,CAMT=SUM(CASE WHEN NOT (ENTRY_TY='OB' OR DATE<@SDATE) AND AMT_TY='CR' THEN AMOUNT ELSE 0 END)
,BALAMT=SUM(CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END)
,SERTY,inout
,OPAMT_TY=SPACE(2)
,CLAMT_TY=SPACE(2)
,typ,srno
into #serabs
FROM #serabs1
where date<=@EDATE
GROUP BY SERTY,inout,typ,srno
UPDATE  #serabs SET OPAMT_TY=(CASE WHEN OPBAL<0 THEN 'Cr' ELSE 'Dr' END),CLAMT_TY=(CASE WHEN BALAMT<0 THEN 'Cr' ELSE 'Dr' END)

select * from #serabs ORDER BY inout,SERTY,srno,typ

--
--UPDATE  #AC_BAL SET 
-- OPBAL=(CASE WHEN OPBAL<0 THEN OPBAL*(-1) ELSE OPBAL END)
--,BALAMT=(CASE WHEN BALAMT<0 THEN BALAMT*(-1) ELSE BALAMT END)
--
--delete from #AC_BAL where OPBAL+DAMT+CAMT+BALAMT=0
--SELECT OPBAL,DAMT,CAMT,BALAMT,srno,typ,SERTY ,OPAMT_TY,CLAMT_TY,inout
--FROM #AC_BAL
--ORDER BY inout,SERTY,srno,typ


--SELECT 
--AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY
--,MN.L_YN
--,AC_MAST.AC_ID,AC_MAST.AC_NAME
--,srno=3,ac_mast.typ,MN.SERTY,SERTYi=MN.SERTY
--,inout=3
--INTO #AC_BAL1
--FROM LAC_VW AC
--INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID)
--INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY) 
--WHERE 1=2
--
--SET @SQLCOMMAND='INSERT INTO #AC_BAL1 SELECT '
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',MN.L_YN'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',AC_MAST.AC_ID,AC_MAST.AC_NAME'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',srno=(case when typ like '+'''Input Service Tax%'''+' then 1 else (case when typ like '+'''Service Tax Available%'''+' then 2 else (case when typ like '+'''Output Service Tax%'''+' then 3 else 4 end) end) end),AC_MAST.TYP'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SERTY=ISNULL(MN.SERTY,SPACE(1))'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',SERTYi=ISNULL(jm.SERTYi,SPACE(1))'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',inout=1'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'FROM LAC_VW AC'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID)'
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY) '
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'left JOIN jvmain jm ON (AC.TRAN_CD = jm.TRAN_CD AND AC.ENTRY_TY = jm.ENTRY_TY) '
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' and Ac_mast.typ like '+'''%service tax%'''
--
--
--PRINT @SQLCOMMAND
--EXECUTE SP_EXECUTESQL @SQLCOMMAND
--
--DELETE FROM #AC_BAL1 WHERE 
--DATE < (SELECT TOP 1 DATE FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN)
--AND AC_NAME IN (SELECT AC_NAME FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN GROUP BY AC_NAME) 
--
--
--UPDATE #AC_BAL1 SET SERTY=SERTYI WHERE SRNO IN (2) AND SERTYI<>''
--SELECT * FROM #AC_BAL1
--
--select m.serty,inout=1 into #inout from sbmain m where isnull(m.serty,'')<>''
--union 
--select m.serty
--,inout=(case when serrule='Imported' then 1 else 2 end) 
--from epmain m 
--where isnull(m.serty,'')<>''
--select * from #ac_bal1
--
--UPDATE a SET a.inout=b.inout from #ac_bal1 a inner join #inout b on (a.serty=b.serty)
--
--SELECT 
--OPBAL=SUM(CASE WHEN (ENTRY_TY='OB' OR DATE<@SDATE) THEN (CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END) ELSE 0 END)
--,DAMT=SUM(CASE WHEN NOT (ENTRY_TY='OB' OR DATE<@SDATE) AND AMT_TY='DR' THEN AMOUNT ELSE 0 END)
--,CAMT=SUM(CASE WHEN NOT (ENTRY_TY='OB' OR DATE<@SDATE) AND AMT_TY='CR' THEN AMOUNT ELSE 0 END)
--,BALAMT=SUM(CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END)
--,srno,typ
--,SERTY,inout
--,OPAMT_TY=SPACE(2)
--,CLAMT_TY=SPACE(2)
--into #AC_BAL
--FROM #AC_BAL1
--where date<=@EDATE
--GROUP BY 
--srno,typ,SERTY,inout
--UPDATE  #AC_BAL SET 
-- OPAMT_TY=(CASE WHEN OPBAL<0 THEN 'Cr' ELSE 'Dr' END)
--,CLAMT_TY=(CASE WHEN BALAMT<0 THEN 'Cr' ELSE 'Dr' END)
--
--UPDATE  #AC_BAL SET 
-- OPBAL=(CASE WHEN OPBAL<0 THEN OPBAL*(-1) ELSE OPBAL END)
--,BALAMT=(CASE WHEN BALAMT<0 THEN BALAMT*(-1) ELSE BALAMT END)
--
--delete from #AC_BAL where OPBAL+DAMT+CAMT+BALAMT=0
--SELECT OPBAL,DAMT,CAMT,BALAMT,srno,typ,SERTY ,OPAMT_TY,CLAMT_TY,inout
--FROM #AC_BAL
--ORDER BY inout,SERTY,srno,typ
GO
