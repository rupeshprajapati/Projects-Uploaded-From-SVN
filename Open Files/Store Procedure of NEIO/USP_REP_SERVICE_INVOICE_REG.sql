DROP PROCEDURE [USP_REP_SERVICE_INVOICE_REG]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [USP_REP_SERVICE_INVOICE_REG]
	
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
		@VMAINFILE='SBMAIN',@VITFILE=null,@VACFILE=null,
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

	SET @SQLCOMMAND = ''
	SET @SQLCOMMAND = 'SELECT SBITEM.INV_NO,SBITEM.party_nm,SBITEM.DATE,SBITEM.ITEM,SBITEM.gro_amt
					   ,SBITEM.CGST_PER,SBITEM.CGST_AMT,SBITEM.SGST_PER,SBITEM.SGST_AMT,SBITEM.IGST_PER,SBITEM.IGST_AMT
					   ,AcdetAlloc.Amount,AcdetAlloc.sAbtPer,AcdetAlloc.sAbtAmt,AcdetAlloc.sTaxable,AcdetAlloc.SExpAmt
					   ,SBITEM.CGSRT_AMT,SBITEM.SGSRT_AMT,SBITEM.IGSRT_AMT
					   FROM SBMAIN
					   LEFT JOIN SBITEM ON SBMAIN.TRAN_CD=SBITEM.TRAN_CD
                       INNER JOIN AcdetAlloc ON (SBITEM.entry_ty=AcdetAlloc.Entry_ty AND SBITEM.Tran_cd=AcdetAlloc.TRAN_CD AND SBITEM.ITSERIAL=AcdetAlloc.itserial)
                       INNER JOIN AC_MAST ON SBMAIN.AC_ID=AC_MAST.AC_ID'
	SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+RTRIM(@FCON)+' '+@RuleCondition +'and SBITEM.entry_ty=''S1'''
	SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' ORDER BY SBITEM.DATE,SBITEM.INV_NO'
	PRINT @SQLCOMMAND
	EXECUTE SP_EXECUTESQL @SQLCOMMAND
GO
