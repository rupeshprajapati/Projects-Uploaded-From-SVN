DROP PROCEDURE [USP_REP_FORM27A]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		
-- Create date: 
-- Description:	This Stored procedure is useful to generate TDS Form 27A Annexure Report.
-- Modified By:Date:Reason: Rupesh. 17/03/2010. TKT-589. Changes done because it was giving wrong output. Refrence SP USP_REP_FORM26Q,USP_REP_FORM16.
-- Remark:
-- =============================================
CREATE PROCEDURE [USP_REP_FORM27A]
@TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),  
 @SDATE SMALLDATETIME,@EDATE SMALLDATETIME,  
 @SNAME NVARCHAR(60),@ENAME NVARCHAR(60),  
 @SITEM NVARCHAR(60),@EITEM NVARCHAR(60),  
 @SAMT NUMERIC,@EAMT NUMERIC,  
 @SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),  
 @SCAT NVARCHAR(60),@ECAT NVARCHAR(60),  
 @SWARE NVARCHAR(60),@EWARE NVARCHAR(60),  
 @SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),  
 @FINYR NVARCHAR(20), @EXPARA NVARCHAR(60)  
AS
begin

Declare @FCON as NVARCHAR(4000),@SQLCOMMAND as NVARCHAR(4000)
 EXECUTE USP_REP_FILTCON   
  @VTMPAC=@TMPAC,@VTMPIT=null,@VSPLCOND=@SPLCOND,  
  @VSDATE=@SDATE,@VEDATE=@EDATE,  
  @VSAC =@SNAME,@VEAC =@ENAME,  
  @VSIT=null,@VEIT=null,  
  @VSAMT=@SAMT,@VEAMT=@EAMT,  
  @VSDEPT=@SDEPT,@VEDEPT=@EDEPT,  
  @VSCATE =@SCAT,@VECATE =@ECAT,  
  @VSWARE =null,@VEWARE  =null,  
  @VSINV_SR =@SINVSR,@VEINV_SR =@EINVSR,  
  @VMAINFILE='M',@VITFILE=null,@VACFILE=NULL,  
  @VDTFLD = 'U_CLDT',@VLYN=null,@VEXPARA='',  
  @VFCON =@FCON OUTPUT  
 PRINT @FCON  
 SET @SQLCOMMAND = ''  

Declare @tot_anne numeric(3),@RcNo varchar(15)
set @RcNo=''
if charindex('RCNO1=',@EXPARA)>0
begin	
	set @RcNo=substring(@EXPARA,charindex('RCNO1=',@EXPARA)+6,15)
end 

SELECT DISTINCT SVC_CATE,SECTION=SEC_CODE INTO #TDSMASTER FROM TDSMASTER 

Select ac_mast.ac_id,m.u_chalno,tm.SECTION
,tdspay=m.net_amt
,dTDSAmt=mall.new_all,TotTDSAmt=mall.new_all
,mall.entry_all,mall.main_tran,mall.acseri_all 
into #table1
from tdsmain_vw m
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd) 
inner join mainall_vw mall on (ac.entry_ty=mall.entry_ty and ac.tran_cd=mall.tran_cd and ac.acserial=mall.acserial)
inner join ac_mast on (ac_mast.ac_id=ac.ac_id)
inner join #TDSMASTER tm on (m.svc_cate=tm.svc_cate)
where 1=2


 
set @SqlCommand = 'insert into #table1 Select ac_mast.ac_id,m.u_chalno,tm.section'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',tdspay=m1.net_amt'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',dTDSAmt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',TotTDSAmt=sum(case when AC_MAST1.TYP IN (''TDS'',''TDS-SUR'',''TDS-ECESS'',''TDS-HCESS'') then new_all else 0 end)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',mall.entry_all,mall.main_tran,mall.acseri_all'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'from tdsmain_vw m'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd) '
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join mainall_vw mall on (ac.entry_ty=mall.entry_ty and ac.tran_cd=mall.tran_cd and ac.acserial=mall.acserial)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join ac_mast ac_mast1 on (ac_mast1.ac_id=ac.ac_id)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join tdsmain_vw m1 on (m1.entry_ty=mall.entry_all and m1.tran_cd=mall.main_tran)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join ac_mast on (ac_mast.ac_id=m1.ac_id)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+'inner join #TDSMASTER tm on (m1.svc_cate=tm.svc_cate)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+rtrim(@fcon)
set @SqlCommand=RTRIM(@SqlCommand)+' '+' and isnull(mall.new_all,0)>0 '
set @SqlCommand=RTRIM(@SqlCommand)+' '+' and AC_MAST1.TYP IN (''TDS'',''TDS-ECESS'',''TDS-HCESS'',''TDS-SUR'')'
set @SqlCommand=RTRIM(@SqlCommand)+' '+' group by ac_mast.ac_id,m.u_chalno,tm.section,m1.net_amt'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',mall.entry_all,mall.main_tran,mall.acseri_all'
PRINT @SQLCOMMAND  
EXECUTE SP_EXECUTESQL @SQLCOMMAND 


select distinct section,u_chalno  into #t4 from #table1 /*Dont Change Row position*/
set @tot_anne=@@rowcount /*Dont Change Row position*/


/*Update Deduction Amount--->*/
Select m.Entry_ty,m.Tran_cd
,dTDSAmt=sum(case when AC_MAST1.TYP IN ('TDS','TDS-SUR','TDS-ECESS','TDS-HCESS') then amount else 0 end)
into #lac1
from tdsmain_vw m 
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
inner join ac_mast ac_mast1 on (ac_mast1.ac_id=ac.ac_id)
where ac.date<=@edate and ac.amt_ty='CR'
group by m.Entry_ty,m.Tran_cd

update a set a.dtdsamt=b.dtdsamt
from #table1 a inner join #lac1 b on (b.entry_ty=a.entry_all and b.tran_cd=a.main_tran)
/*<---Update Deduction Amount*/

select  ac_id,tdspay,dtdsamt,tottdsamt=sum(tottdsamt),tot_anne=@tot_anne,RcNo=isnull(@RcNo,0) from #table1 group by ac_id,tdspay,dtdsamt order by ac_id

drop table #TDSMASTER
drop table #table1
drop table #t4 
drop table #lac1
  
/*	Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50)
	
	Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
	Set @TBLNAME1 = '##TMP1'+@TBLNM
	
	EXECUTE USP_REP_FILTCON 
		@VTMPAC=@TMPAC,@VTMPIT=null,@VSPLCOND=@SPLCOND,
		@VSDATE=@SDATE,@VEDATE=@EDATE,
		@VSAC =@SNAME,@VEAC =@ENAME,
		@VSIT=null,@VEIT=null,
		@VSAMT=@SAMT,@VEAMT=@EAMT,
		@VSDEPT=@SDEPT,@VEDEPT=@EDEPT,
		@VSCATE =@SCAT,@VECATE =@ECAT,
		@VSWARE =null,@VEWARE  =null,
		@VSINV_SR =@SINVSR,@VEINV_SR =@EINVSR,
		@VMAINFILE='MVW',@VITFILE=null,@VACFILE=null,
		@VDTFLD = 'U_CLDT',@VLYN=null,@VEXPARA=@EXTPAR,
		@VFCON =@FCON OUTPUT

	SET @SQLCOMMAND = ''
	SET @SQLCOMMAND = 'SELECT MVW.ENTRY_TY,MVW.TRAN_CD,MVW.AC_ID,MVW.TDSONAMT,MVW.TDSAMT,MVW.SCAMT,MVW.ECAMT,MVW.HCAMT INTO '+@TBLNAME1+' FROM TDSMAIN_VW MVW,AC_MAST '+@FCON+' AND  MVW.AC_ID = AC_MAST.AC_ID AND MVW.SVC_CATE <> '' '' AND MVW.TDSONAMT<>0'
	PRINT @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND

	SET @SQLCOMMAND = ''
	SET @SQLCOMMAND = 'SELECT A.*,TOTPAY=ISNULL(B.NEW_ALL,0) FROM '+@TBLNAME1+' A '
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'LEFT JOIN MAINALL_VW B ON (A.ENTRY_TY=B.ENTRY_ALL  AND A.TRAN_CD = B.MAIN_TRAN) '
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN AC_MAST D ON (D.AC_ID=B.AC_ID and D.TYP IN (''TDS'',''TDS-ECESS'',''TDS-HCESS'',''TDS-SUR'')) '	
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' UNION ALL'
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'SELECT A.*,TOTPAY=ISNULL(B.NEW_ALL,0) FROM '+@TBLNAME1+' A '
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'LEFT JOIN MAINALL_VW B ON (A.ENTRY_TY=B.ENTRY_TY  AND A.TRAN_CD = B.TRAN_CD) '
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'INNER JOIN AC_MAST D ON (D.AC_ID=B.AC_ID and D.TYP IN (''TDS'',''TDS-ECESS'',''TDS-HCESS'',''TDS-SUR'')) '	
	SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+'ORDER BY A.AC_ID'	
	PRINT @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND

	SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME1
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
*/
end
GO
