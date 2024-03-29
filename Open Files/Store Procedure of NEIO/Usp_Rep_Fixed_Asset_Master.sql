DROP PROCEDURE [USP_REP_Fixed_Asset_Master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author	  :	Birendra.
-- Create date: 11/10/2012
-- Description:	This Stored procedure is useful to generate ACCOUNTS  Fixed Asset Master Report.
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
Create PROCEDURE [USP_REP_Fixed_Asset_Master]  
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
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000),@DIFFDAY as numeric(5)
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

PRINT @FCON
--EXECUTE USP_REP_FIXED_ASSET '','','','04/01/2007','03/31/2008','1% HIGHER EDU.CESS                                          ','ZAMFABAR CORPORATION                                        ','','',0,99999999999.00,'','','','WASTE & SCRAP       ','','','','YAWAT               ','2007-2008',''
SET @DIFFDAY = convert(int,@edate) - convert(int,@sdate) + 1
DECLARE @GRPID AS INT,@MCOND AS BIT,@LVL  AS INT,@GRP AS VARCHAR(100)

select it_name,vendnm,methodnm,assetty,usgunit,pvalue,comncdt,salvage,estimate,deprper,noofyr,acdepr from it_mast where methodnm<>' '
GO
