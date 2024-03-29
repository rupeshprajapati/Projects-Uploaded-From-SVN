If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Rep_Pharma_MIS_POS')
Begin
	Drop Procedure Usp_Rep_Pharma_MIS_POS
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Rep_Pharma_MIS_POS]    Script Date: 12/19/2018 17:48:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[Usp_Rep_Pharma_MIS_POS]
(@FrmDate SMALLDATETIME,@Todate SMALLDATETIME,@FParty nvarchar(100),@TParty nvarchar(100),@FSupply nvarchar(100),@TSupply nvarchar(100)
,@FSeries nvarchar(100),@TSeries nvarchar(100),@FDept nvarchar(100),@TDept nvarchar(100))
AS
DECLARE @SQLCOMMAND NVARCHAR(4000)

Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50)
Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
				+ (DATEPART(ss, GETDATE()) * 1000 )
				+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
Set @TBLNAME1 = '##TMP1'+@TBLNM
-----Added by Prajakta B. on 11/12/2018 --Start
	SET @SQLCOMMAND = 'SELECT ENTRY_TY,TRAN_CD,
					   [CASH]=ISNULL([CASH],0),[COUPON]=ISNULL([COUPON],0),[CHEQUE]=ISNULL([CHEQUE],0),[CARD]=ISNULL([CARD],0),[EWALLET]=ISNULL([EWALLET],0) 
					   INTO '+@TBLNAME1+'
					   FROM 
					   (
						SELECT ENTRY_TY,TRAN_CD,PAYMODE,TOTALVALUE FROM pspaydetail A where A.entry_ty=''HS''
					   ) AS SOURCETABLE
					   PIVOT
					   (
						SUM(TOTALVALUE) FOR PAYMODE IN ([CASH],[COUPON],[CHEQUE],[CARD],[EWALLET])
					   ) AS PIVOTTABLE'
	EXECUTE SP_SQLEXEC 	@sqlcommand
-----Added by Prajakta B. on 11/12/2018 --End

SET @SQLCOMMAND='SELECT DI.DATE,DI.INV_NO,DM.INV_SR,DI.ITSERIAL,DM.DEPT,DM.CATE,DI.ITEM,DI.QTY,DI.RATE,DI.U_ASSEAMT,'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'DI.CGST_PER,DI.CGST_AMT,DI.SGST_PER,DI.SGST_AMT,'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'DI.GRO_AMT,DI.BATCHNO,DI.MFGDT,DI.EXPDT,pm.pstatus,PP.[CASH],PP.[COUPON],PP.[CHEQUE],PP.[CARD],PP.[EWALLET]'
SET @SQLCOMMAND=@SQLCOMMAND+' '+',DI.ware_nm' 
SET @SQLCOMMAND=@SQLCOMMAND+' '+',DM.tot_deduc,DM.tot_tax,DM.tot_nontax,DM.tot_fdisc,DM.net_amt,abs(DI.tot_deduc) as itdisc  '
SET @SQLCOMMAND=@SQLCOMMAND+' '+',DI.gpqty,DI.gprate,DI.looseqty,DI.freeqty,DI.gpunit,DI.stkunit,DM.NMOBILENO,dm.drname,totcash=pp.cash+pp.coupon,totbankpay=pp.cheque+pp.card+pp.ewallet' 
SET @SQLCOMMAND=@SQLCOMMAND+' '+' from DCMAIN DM'
SET @SQLCOMMAND=@SQLCOMMAND+' '+' INNER JOIN DCITEM DI ON (DM.ENTRY_TY=DI.ENTRY_TY AND DM.TRAN_CD=DI.TRAN_CD)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+' INNER JOIN IT_MAST IT on (DI.IT_CODE=IT.IT_CODE)'
SET @SQLCOMMAND=@SQLCOMMAND+' '+' left join '+@TBLNAME1+' pp on pp.entry_ty=DM.entry_ty and pp.tran_cd=DM.tran_cd '
SET @SQLCOMMAND=@SQLCOMMAND+' '+' left join pRetPatientMast pm on DM.PATIENTNM=pm.name'
SET @SQLCOMMAND=@SQLCOMMAND+' '+' left join pRetDrMast pdm on pdm.name=dm.DRNAME'
SET @SQLCOMMAND=@SQLCOMMAND+' '+' WHERE (DI.DATE BETWEEN '+CHAR(39)+cast(@FrmDate as varchar)+CHAR(39)
+' AND '+CHAR(39)+cast(@Todate as varchar)+CHAR(39)
+') AND (DM.INV_SR BETWEEN '''+@FSeries+''' AND '''+@TSeries+''') AND (DM.DEPT BETWEEN '''+@FDept+''' AND '''+@TDept+''')'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'AND (IT.IT_NAME BETWEEN '''+@FSupply+''' AND '''+@TSupply+''')'
SET @SQLCOMMAND=@SQLCOMMAND+' '+'AND DM.ENTRY_TY=''HS'''

PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND



