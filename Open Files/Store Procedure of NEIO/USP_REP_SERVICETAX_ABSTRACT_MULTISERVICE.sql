DROP PROCEDURE [USP_REP_SERVICETAX_ABSTRACT_MULTISERVICE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 22/05/2010
-- Description:	This Stored procedure is useful for [Service Tax Self Assessment Audit] Report.
-- Modification Date/By/Reason: 26/07/2010. Rupesh. TKT-794 Add GTA 
-- Remark:
-- =============================================
CREATE PROCEDURE [USP_REP_SERVICETAX_ABSTRACT_MULTISERVICE]  
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
,serty=cast('' as varchar(250))
,ac_mast.ac_name,ac.amt_ty,amount,inout=2,m.l_yn
into #serabs1
from bpmain m
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
inner join ac_mast on (ac.ac_id=ac_mast.ac_id)
inner join lcode l  on (m.entry_ty=l.entry_ty)
where 1=2

SET @SQLCOMMAND='insert into #serabs1'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'select m.entry_ty,m.date,m.tran_cd,m.inv_no,typ'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',ac.serty'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',ac_mast.ac_name,ac.amt_ty,amount,inout=1,m.l_yn'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'from SerTaxMain_vw m'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join SerTaxAcDet_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join ac_mast on (ac.ac_id=ac_mast.ac_id)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join lcode l  on (m.entry_ty=l.entry_ty)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'and typ in (''Service Tax Payable'',''Service Tax Payable-Ecess'',''Service Tax Payable-Hcess'',''GTA Service Tax Payable'',''GTA Service Tax Payable-Ecess'',''GTA Service Tax Payable-Hcess'')' /*TKT-794 Add GTA*/
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
SET @SQLCOMMAND='insert into #serabs1'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'select m.entry_ty,m.date,m.tran_cd,m.inv_no,typ'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',ac.serty'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',ac_mast.ac_name,ac.amt_ty,amount,inout=2,m.l_yn'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'from SerTaxMain_vw m'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join SerTaxAcDet_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join ac_mast on (ac.ac_id=ac_mast.ac_id)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'inner join lcode l  on (m.entry_ty=l.entry_ty)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'and typ in (''Service Tax Available'',''Service Tax Available-Ecess'',''Service Tax Available-Hcess'')'
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
,typ,srno=0
into #serabs
FROM #serabs1
where date<=@EDATE
GROUP BY SERTY,inout,typ
UPDATE  #serabs SET OPAMT_TY=(CASE WHEN OPBAL<0 THEN 'Cr' ELSE 'Dr' END),CLAMT_TY=(CASE WHEN BALAMT<0 THEN 'Cr' ELSE 'Dr' END)
select * from #serabs ORDER BY inout,SERTY,srno,typ
GO
