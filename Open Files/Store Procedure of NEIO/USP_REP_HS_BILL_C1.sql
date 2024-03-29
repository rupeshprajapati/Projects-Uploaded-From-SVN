If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_HS_BILL_C1')
Begin
	Drop Procedure USP_REP_HS_BILL_C1
End
GO
/****** Object:  StoredProcedure [dbo].[USP_REP_HS_BILL_C1]    Script Date: 12/17/2018 14:35:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--execute USP_REP_HS_BILL_C1 1
	Create PROCEDURE [dbo].[USP_REP_HS_BILL_C1] 
		--@TRANCD INT
		@TRANCD NVARCHAR(254)
	AS
	BEGIN

		SET NOCOUNT ON;

		DECLARE @SQLCOMMAND NVARCHAR(MAX), @DISCCHRGS NVARCHAR(MAX),@TBLCON NVARCHAR(max)
		DECLARE @V_DISC BIT, @I_DISC BIT, @STAX_TRAN BIT, @STAX_ITEM BIT
		
		SET @TBLCON=RTRIM(@TRANCD)
		print @tblcon
		print @Trancd
		
Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50)
Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
				+ (DATEPART(ss, GETDATE()) * 1000 )
				+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
Set @TBLNAME1 = '##TMP1'+@TBLNM

		SELECT @V_DISC=V_DISC, @I_DISC=I_DISC, @STAX_TRAN=STAX_TRAN, @STAX_ITEM=STAX_ITEM FROM LCODE WHERE ENTRY_TY='HS'
		SELECT @DISCCHRGS=''
		IF @V_DISC = 1
		BEGIN
			SELECT @DISCCHRGS=COALESCE(@DISCCHRGS,'')+CASE WHEN @DISCCHRGS='' THEN '' ELSE ',' END+'A.'+LTRIM(RTRIM(FLD_NM))+ ' AS HD_'+LTRIM(RTRIM(FLD_NM)) + CASE WHEN PERT_NAME='' THEN '' ELSE ',A.'+LTRIM(RTRIM(PERT_NAME))+' AS HD_'+LTRIM(RTRIM(PERT_NAME)) END FROM DCMAST WHERE ENTRY_TY='HS' AND ATT_FILE=1
		END
		IF @I_DISC = 1
		BEGIN
			SELECT @DISCCHRGS=COALESCE(@DISCCHRGS,'')+CASE WHEN @DISCCHRGS='' THEN '' ELSE ',' END+'B.'+LTRIM(RTRIM(FLD_NM))+ ' AS DT_'+LTRIM(RTRIM(FLD_NM)) + CASE WHEN PERT_NAME='' THEN '' ELSE ',B.'+LTRIM(RTRIM(PERT_NAME))+' AS DT_'+LTRIM(RTRIM(PERT_NAME)) END FROM DCMAST WHERE ENTRY_TY='HS' AND ATT_FILE=0
		END
		IF @STAX_TRAN = 1
		BEGIN
			SELECT @DISCCHRGS=@DISCCHRGS+CASE WHEN @DISCCHRGS='' THEN '' ELSE ',' END+'A.TAX_NAME,A.TAXAMT'
		END
		IF @STAX_ITEM = 1
		BEGIN
			SELECT @DISCCHRGS=@DISCCHRGS+CASE WHEN @DISCCHRGS='' THEN '' ELSE ',' END+'B.TAX_NAME,B.TAXAMT'
		END
-----Added by Prajakta B. on 11/12/2018 --Start
	SET @SQLCOMMAND = 'SELECT ENTRY_TY,TRAN_CD,
					   [CASH]=ISNULL([CASH],0),[COUPON]=ISNULL([COUPON],0),[CHEQUE]=ISNULL([CHEQUE],0),[CARD]=ISNULL([CARD],0),[EWALLET]=ISNULL([EWALLET],0) 
					   INTO '+@TBLNAME1+'
					   FROM 
					   (
						SELECT ENTRY_TY,TRAN_CD,PAYMODE,TOTALVALUE FROM pspaydetail A where '+@TRANCD +'
					   ) AS SOURCETABLE
					   PIVOT
					   (
						SUM(TOTALVALUE) FOR PAYMODE IN ([CASH],[COUPON],[CHEQUE],[CARD],[EWALLET])
					   ) AS PIVOTTABLE'
	EXECUTE SP_SQLEXEC 	@sqlcommand
-----Added by Prajakta B. on 11/12/2018 --End
		SET @SQLCOMMAND = 'SELECT  A.ENTRY_TY, A.DATE, A.TRAN_CD, A.DEPT, A.CATE, A.PARTY_NM,A.CUST_NM, A.INV_NO, A.INV_SR, A.L_YN, A.GRO_AMT, '
		SET @SQLCOMMAND = @SQLCOMMAND+' A.NET_AMT, A.SYSDATE, A.AC_ID,A.GRO_AMT,B.ITEM_NO, B.ITEM, B.QTY,B.gpqty,c.hsncode, B.RATE, B.GRO_AMT AS ITGRO_AMT, ac_mast.gstin,'
		SET @SQLCOMMAND = @SQLCOMMAND+' B.IT_CODE, B.U_ASSEAMT,B.SGST_PER,B.SGST_AMT,B.CGST_PER,B.CGST_AMT,A.BALAMT,c.rateunit,IT_DESC=cast(c.it_desc as varchar(4000)), A.TOTALPAID, A.ROUNDOFF '+CASE WHEN @DISCCHRGS='' THEN '' ELSE ',' END+@DISCCHRGS   --B.itdiscamt,
		SET @SQLCOMMAND = @SQLCOMMAND+' ,B.batchno, B.mfgdt,B.expdt, A.PATIENTNM ,A.DRNAME,patient_Address=pm.add1 + pm.add2 + pm.add3 ,Dr_Addr=dm.add1 + dm.add2 + dm.add3 , A.tot_fdisc, C.p_unit,B.tot_fdisc as itemdisc,PS.SCHEDULE,pmm.name as mrf' --Prajakta
		SET @SQLCOMMAND = @SQLCOMMAND+' ,SDrugLicNo=ac_mast.prDrugLicNo,SDrugLicExpDt= ac_mast.prDrugExpDate,SFoodLicNo=ac_mast.prFoodLicNo,SFoodLicExpDt=ac_mast.prFoodExpDate,pmm.mcode,PP.CASH,PP.COUPON,PP.CHEQUE,PP.CARD,PP.EWALLET'
		SET @SQLCOMMAND = @SQLCOMMAND+' ,abs(B.tot_deduc) as itdisc,B.LOOSEQTY,B.FREEQTY' 
		SET @SQLCOMMAND = @SQLCOMMAND+' FROM DCMAIN A '
		SET @SQLCOMMAND = @SQLCOMMAND+' INNER JOIN DCITEM B ON A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD '
		SET @SQLCOMMAND = @SQLCOMMAND+' left JOIN it_mast C ON b.it_code=C.it_code'
		SET @SQLCOMMAND = @SQLCOMMAND+' left join pretsalt_master ps on (c.prSalt=ps.Salt)'
		SET @SQLCOMMAND = @SQLCOMMAND+' left join pRetManufacturerMast pmm on (c.prManufacturer=pmm.Name)'
		SET @SQLCOMMAND = @SQLCOMMAND+' left join pRetPatientMast pm on a.PATIENTNM=pm.name'
		SET @SQLCOMMAND = @SQLCOMMAND+' left join pRetDrMast dm on a.DRNAME=dm.name'
		SET @SQLCOMMAND = @SQLCOMMAND+' left join '+@TBLNAME1+' pp on pp.entry_ty=A.entry_ty and pp.tran_cd=A.tran_cd '
		SET @SQLCOMMAND = @SQLCOMMAND+' left join ac_mast on ac_mast.ac_id=a.ac_id'
		SET @SQLCOMMAND = @SQLCOMMAND+' WHERE ' +@TBLCON
		print @SQLCOMMAND
		EXECUTE SP_EXECUTESQL @SQLCOMMAND 		
	END
	
set @sqlcommand='Drop Table '+@TBLNAME1
execute sp_executesql @sqlcommand		



