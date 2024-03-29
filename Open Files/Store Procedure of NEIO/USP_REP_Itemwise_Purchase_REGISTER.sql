DROP PROCEDURE [USP_REP_Itemwise_Purchase_REGISTER]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Satish Pal.
-- Create date: 02/11/2011
-- Description:	This Stored procedure is useful to generate Itemwise Purchase REGISTER.
-- Modify date: By: Sandeep shah for bug-1444 on 18/01/2012.
-- Modify date: By: Sandeep shah for bug-1724 on 16/04/2012.
-- Remark:
-- =============================================

create PROCEDURE   [USP_REP_Itemwise_Purchase_REGISTER]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(500)= NULL
AS

DECLARE @FCON AS NVARCHAR(2000)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='PTMAIN',@VITFILE='PTITEM',@VACFILE='AC'
,@VDTFLD ='date'
,@VLYN=Null
,@VEXPARA=null
,@VFCON =@FCON OUTPUT
print @FCON
DECLARE @SQLCOMMAND NVARCHAR(4000)
SET @SQLCOMMAND='SELECT PTMAIN.TRAN_CD,PTMAIN.DATE,PTMAIN.INV_NO,PTMAIN.PINVNO as U_PINVNO,PTMAIN.PINVDT AS U_PINVDT,PTMAIN.PARTY_NM,PTMAIN.[RULE],AC_NAME=(CASE WHEN PTMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.mailname END)' 
SET @SQLCOMMAND=@SQLCOMMAND+' '+',PTMAIN.CATE,PTMAIN.INV_SR,PTITEM.ITEM,qty=(case when isnull(ptitem.dc_no,'+''''''+')<>'+'''DI'''+' then PTITEM.QTY else 0 end),PTITEM.RATE,PTITEM.U_ASSEAMT'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',PTITEM.BCDPER,PTITEM.BCDAMT'  
SET @SQLCOMMAND=@SQLCOMMAND+' '+',PTITEM.GRO_AMT,IT_MAST.[GROUP],IT_MAST.RATEUNIT,PTITEM.CGST_AMT,PTITEM.SGST_AMT,PTITEM.IGST_AMT,PTITEM.CGST_PER
								,PTITEM.SGST_PER,PTITEM.IGST_PER,ptitem.cgsrt_amt,ptitem.sgsrt_amt,ptitem.igsrt_amt '
SET @SQLCOMMAND=@SQLCOMMAND+' '+'FROM PTMAIN  inner join ptitem on ptmain.tran_cd=ptitem.tran_cd 
                                              left join it_mast on it_mast.it_code=ptitem.it_code 
                                              INNER JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_ID=PTMAIN.CONS_ID) 
                                              LEFT JOIN SHIPTO ON (SHIPTO.AC_ID=PTMAIN.Ac_id AND SHIPTO.Shipto_id=PTMAIN.sac_id) 
                                              LEFT JOIN SHIPTO SHIPTO1 ON(SHIPTO1.AC_ID=PTMAIN.CONS_id AND SHIPTO1.Shipto_id =PTMAIN.scons_id)
--                                              INNER JOIN PTMAIN ptmain01 ON (PTMAIN.TRAN_CD=ptmain01.TRAN_CD and PTMAIN.Entry_ty=ptmain01.entry_ty ) 
                                              inner join ac_mast on ptmain.ac_id=ac_mast.ac_id'  
SET @SQLCOMMAND =@SQLCOMMAND+' '+RTRIM(@FCON)
SET @SQLCOMMAND =@SQLCOMMAND+' ORDER BY PTITEM.ITEM,PTMAIN.DATE,PTMAIN.PARTY_NM'
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
