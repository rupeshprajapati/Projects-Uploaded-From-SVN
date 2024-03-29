DROP PROCEDURE [USP_REP_TDS_LATE_INT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dinesh Sh.
-- Create date: 14/05/2012
-- Reference  : [--USP_REP_FORM26Q]
-- Description:	This Stored procedure is useful to generate TDS Report.
-- Remark:
-- =============================================
create PROCEDURE [USP_REP_TDS_LATE_INT]
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
SET NOCOUNT ON 

SET QUOTED_IDENTIFIER OFF
Declare @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2)

DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(2000),@FDATE VARCHAR(10),@RcNo varchar(15)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='M1',@VITFILE='',@VACFILE='AC'
,@VDTFLD ='U_CLDT'
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT

Declare @Int_Rate Int,@TDSIntPayDay int,@DaysofYear Int
select @EXPARA =case when  isnull(@EXPARA,'')='' then ' 18, 7' else @EXPARA end
SET @Int_Rate=Convert(int,substring(@EXPARA,1,charindex(',',@EXPARA)-1))
set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))
print @Int_Rate
set @TDSIntPayDay=CONVERT(int,@EXPARA)-1
print @TDSIntPayDay
--set @EXPARA=LTRIM(substring(@expara,charindex(',',@expara)+1,len(@EXPARA)))

--set @DaysofYear=CONVERT(int,@EXPARA)
--print @DaysofYear 


Declare @date smalldatetime,@u_chalno varchar(10),@u_chaldt smalldatetime,@section varchar(10),@mentry_ty varchar(10),@mtran_cd varchar(10)

SELECT DISTINCT SVC_CATE,SECTION=SEC_CODE INTO #TDSMASTER FROM TDSMASTER 


Select ac_mast.ac_id,AC_MAST.ac_name,m.cheq_no,m.u_chalno,m.u_chaldt,m.bsrcode  /*m.entry_ty,m.tran_cd,ac.acserial,mall.new_all,*/
,m.svc_cate,m.TDSonAmt,m.date,tm.section,tdspay=m.net_amt
,TDSAmt=mall.new_all,scamt=mall.new_all,ecamt=mall.new_all,hcamt=mall.new_all
,aTotAmt=mall.new_all,atdsamt=mall.new_all,ascamt=mall.new_all,aecamt=mall.new_all
,DED_RATE=cast(0 as decimal(12,4))
,mall.entry_all,mall.main_tran /*,mall.acseri_all*/
,m.INV_NO,m.pinvno
into #etds26q
from tdsmain_vw m
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd) 
inner join mainall_vw mall on (ac.entry_ty=mall.entry_ty and ac.tran_cd=mall.tran_cd and ac.acserial=mall.acserial)
inner join ac_mast on (ac_mast.ac_id=ac.ac_id)
inner join #TDSMASTER tm on (m.svc_cate=tm.svc_cate)
where 1=2

set @SqlCommand = 'insert into #etds26q Select ac_mast.ac_id,AC_MAST.ac_name,m.cheq_no,m.u_chalno,m.u_chaldt,m.bsrcode' /*m.entry_ty,m.tran_cd,ac.acserial,mall.new_all,*/
set @SqlCommand=RTRIM(@SqlCommand)+' '+',m1.svc_cate,m1.TDSonAmt,m1.date,tm.section,tdspay=m1.net_amt'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',TDSAmt=0,scamt=0,ecamt=0,hcamt=0'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',aTotAmt=sum(case when AC_MAST1.TYP IN (''TDS'',''TDS-SUR'',''TDS-ECESS'',''TDS-HCESS'') then new_all else 0 end)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',aTDSAmt=sum(case when AC_MAST1.TYP IN (''TDS'') then new_all else 0 end)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',ascamt=sum(case when  AC_MAST1.TYP IN (''TDS-SUR'') then new_all else 0 end)'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',aecamt=sum(case when  AC_MAST1.TYP IN (''TDS-ECESS'',''TDS-HCESS'') then new_all else 0 end)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+',DED_RATE=cast(   (M1.tds_tp)+   ( (M1.tds_tp*M1.sc_tp)/100 ) + ( (( (M1.tds_tp*M1.sc_tp)/100 )*M1.ec_tp)/100  ) + ( (( (M1.tds_tp*M1.sc_tp)/100 )*M1.hc_tp)/100  ) as numeric(17,2))'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',mall.entry_all,mall.main_tran'/*,mall.acseri_all*/
set @SqlCommand=RTRIM(@SqlCommand)+' '+',m.INV_NO,m.pinvno'
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
set @SqlCommand=RTRIM(@SqlCommand)+' '+' group by ac_mast.ac_id,AC_MAST.ac_name,m.cheq_no,m.u_chalno,m.u_chaldt,m.bsrcode'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',m1.svc_cate,m1.TDSonAmt,m1.date,tm.section,m1.net_amt,m1.tds_tp,m1.sc_tp,m1.ec_tp,m1.hc_tp'
set @SqlCommand=RTRIM(@SqlCommand)+' '+',mall.entry_all,mall.main_tran,m.INV_NO,m.pinvno'/*,mall.acseri_all*/
--print @SQLCOMMAND  
EXECUTE SP_EXECUTESQL @SQLCOMMAND 
--print @SQLCOMMAND  




Select m.Entry_ty,m.Tran_cd
,TDSAmt=sum(case when AC_MAST1.TYP IN ('TDS') then amount else 0 end)
,scamt=sum(case when AC_MAST1.TYP IN ('TDS-SUR') then amount else 0 end)
,ecamt=sum(case when AC_MAST1.TYP IN ('TDS-ECESS') then amount else 0 end)
,hcamt=sum(case when AC_MAST1.TYP IN ('TDS-HCESS') then amount else 0 end)
into #lac1
from tdsmain_vw m 
inner join lac_vw ac on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
inner join ac_mast ac_mast1 on (ac_mast1.ac_id=ac.ac_id)
where ac.date<=@edate and ac.amt_ty='CR'
group by m.Entry_ty,m.Tran_cd

update a set a.tdsamt=b.tdsamt,a.scamt=b.scamt,a.ecamt=b.ecamt,a.hcamt=b.hcamt
from #etds26q a inner join #lac1 b on (b.entry_ty=a.entry_all and b.tran_cd=a.main_tran)

SELECT  TDS_CODE = a.SECTION
,Party_Nm=ac_name,A.AC_ID
,a.inv_no, a.pinvno
,date_deduct = A.date
,due_date =  DATEADD(d,@TDSIntPayDay,DATEADD(mm, DATEDIFF(m,0,a.date)+1,0))
,PAID_ON = A.U_CHALDT
,VOU_AMT = A.TDSONAMT
,RATE = A.DED_RATE
,TDS_AMT = A.aTotAmt
,u_chalno
INTO #INT_DATE
FROM #etds26q A
Order by 1,A.DATE


SELECT *,
LATE_DAYS = DATEDIFF(d,due_date,Paid_On)
,INT_RATE = @Int_Rate
,INT_AMT = ROUND(((TDS_AMT * @INT_RATE/100) / 365) * DATEDIFF(d,due_date,Paid_On),0)
,act_INT_AMT = ((TDS_AMT * @INT_RATE/100) / 365) * DATEDIFF(d,due_date,Paid_On)
FROM #INT_DATE
where DATEDIFF(d,due_date,Paid_On) > 0
Order by 1,date_deduct, Party_Nm


drop table #TDSMASTER
drop table #etds26q
drop table #lac1
GO
