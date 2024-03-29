DROP PROCEDURE [USP_REP_SERVICE_PURBILL_REG]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_REP_SERVICE_PURBILL_REG]
	
@TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),
	@SDATE SMALLDATETIME,@EDATE SMALLDATETIME,
	@SNAME NVARCHAR(60),@ENAME NVARCHAR(60),
	@SITEM NVARCHAR(60),@EITEM NVARCHAR(60),
	@SAMT NUMERIC,@EAMT NUMERIC,
	@SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),
	@SCAT NVARCHAR(60),@ECAT NVARCHAR(60),
	@SWARE NVARCHAR(60),@EWARE NVARCHAR(60),
	@SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),
	@FINYR NVARCHAR(20),@expara NVARCHAR(1000)
	AS

Declare @FCON as NVARCHAR(4000),@SQLCOMMAND as NVARCHAR(4000)

EXECUTE USP_REP_FILTCON 
		@VTMPAC=@TMPAC,@VTMPIT=@TMPIT,@VSPLCOND=@SPLCOND, 
		@VSDATE=@SDATE,@VEDATE=@EDATE,    --Added @sdate para. by sandeep for bug-18638 on 26-Aug-13
		@VSAC =@SNAME,@VEAC =@ENAME, --Added @SNAME & @ENAME para. by sandeep for bug-18638 on 26-Aug-13  
		@VSIT=@SITEM,@VEIT=@EITEM,
		@VSAMT=@SAMT,@VEAMT=@EAMT, --Added @SAMT & @EAMT para. by sandeep for bug-18638 on 26-Aug-13  
		@VSDEPT=@SDEPT,@VEDEPT=@EDEPT,
		@VSCATE =@SCAT,@VECATE =@ECAT,
		@VSWARE =@SWARE,@VEWARE  =@EWARE,
		@VSINV_SR =@SINVSR,@VEINV_SR =@EINVSR,
		@VMAINFILE='EPMAIN',@VITFILE=null,@VACFILE=null,
		@VDTFLD = 'DATE',@VLYN=null,@VEXPARA=@expara,
		@VFCON =@FCON OUTPUT

	declare @RuleCondition varchar(1000)
	set @RuleCondition=''
	if charindex('$>Rule',@expara)<>0
	begin
		set @RuleCondition=@expara
		SET @RuleCondition=REPLACE(@RuleCondition, '`','''')
		set @RuleCondition=substring(@RuleCondition,charindex('$>Rule',@RuleCondition)+6,len(@RuleCondition)-(charindex('$>Rule',@RuleCondition)+5))
		set @RuleCondition=substring(@RuleCondition,1,charindex('<$Rule',@RuleCondition)-1)
	end
print @FCON
	SET @SQLCOMMAND = ''
	SET @SQLCOMMAND = 'SELECT EPITEM.INV_NO,EPITEM.party_nm,EPITEM.DATE,EPITEM.ITEM,EPITEM.gro_amt
					   ,EPITEM.CGST_PER,EPITEM.CGST_AMT,EPITEM.SGST_PER,EPITEM.SGST_AMT,EPITEM.IGST_PER,EPITEM.IGST_AMT,EPITEM.CGSRT_AMT,EPITEM.SGSRT_AMT,EPITEM.IGSRT_AMT
					   ,AcdetAlloc.Amount,AcdetAlloc.sAbtPer,AcdetAlloc.sAbtAmt,AcdetAlloc.sTaxable,AcdetAlloc.SExpAmt
						FROM EPMAIN 
						LEFT JOIN EPITEM ON EPMAIN.TRAN_CD=EPITEM.TRAN_CD
						INNER JOIN AcdetAlloc ON (EPITEM.entry_ty=AcdetAlloc.Entry_ty AND EPITEM.Tran_cd=AcdetAlloc.TRAN_CD AND EPITEM.ITSERIAL=AcdetAlloc.itserial)
						 INNER JOIN AC_MAST ON EPMAIN.AC_ID=AC_MAST.AC_ID'
						SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)+' '+@RuleCondition +'and EPITEM.entry_ty=''E1'''
	SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' ORDER BY EPITEM.DATE,EPITEM.INV_NO'
	PRINT @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
