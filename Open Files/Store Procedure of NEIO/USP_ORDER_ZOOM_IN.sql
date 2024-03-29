DROP PROCEDURE [USP_ORDER_ZOOM_IN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*:*****************************************************************************
*:       Program: USP BALANCE LISTING
*:        System: UDYOG Software (I) Ltd.
*:    Programmer: RAGHAVENDRA B. JOSHI
*: Last modified: 19/11/2009
*:		AIM		: Order Zoom-In Report
**:******************************************************************************
*: Changes done on 19/11/2009 : Rateunit Column added
Modified by :Shrikant S. on 31/05/2013 for Bug-548
Modified by :Sumit Gavate. on 16/02/2016 for Bug - 26995
Modified by :Suraj K. on 29/01/2018 for Bug -28404
**:******************************************************************************/
CREATE PROCEDURE [USP_ORDER_ZOOM_IN]
 @TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000)
,@SDATE SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60),@SAMT FLOAT
,@EAMT FLOAT,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20),@ReportType As Varchar(2)
,@ZoomType As Varchar(1),@C_St_Date SmalldateTime
,@XTRAFLDS VARCHAR(8000)
AS
IF @ZoomType IS NULL OR @ZoomType = ''
BEGIN 
	RAISERROR ('Please Pass Zoom Type...', 16,1) 
	Return 
END

IF @ReportType IS NULL OR @ReportType = ''
BEGIN 
	RAISERROR ('Please Pass Report Type...', 16,1) 
	Return 
END	
print @ReportType		

/* Internale Variable declaration and Assigning [Start] */
DECLARE @Balance Numeric(17,2),@TBLNM VARCHAR(50),@TBLNAME1 Varchar(50),
	@TBLNAME2 Varchar(50),@TBLNAME3 Varchar(50),@TBLNAME4 Varchar(50),
	@SQLCOMMAND as nVARCHAR(max),@PrimaryFld As Int,@Stop_Loop Bit,
	@ParmDefinition nvarchar(500),@LevelCode Int,@CaseSQL nvarchar(500),
	@Expand Bit
	,@Main_Tbl Varchar(2)--added by Prajakta B. on 19092017 for Bug 30451

SELECT @ParmDefinition = '',@CaseSQL = '',@Expand = 1
DECLARE @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2),@nLength Int

Declare @collation Varchar(100)
select @collation=Convert(Varchar(100),DATABASEPROPERTYEX(db_name(), 'Collation'))

SELECT @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
		+ (DATEPART(ss, GETDATE()) * 1000 )+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No),
		@Balance = 0,@SQLCOMMAND = ''

SELECT @nLength = COLUMNPROPERTY(Object_Id('ORDZM_VW_ITREF'),'RItserial','Precision')
SELECT @TBLNAME1 = '##TMP1'+@TBLNM,@TBLNAME2 = '##TMP2'+@TBLNM
SELECT @TBLNAME3 = '##TMP3'+@TBLNM,@TBLNAME4 = '##TMP4'+@TBLNM
 
--added by Prajakta B. on 19092017 for Bug 30451 Start
select 
	@Main_Tbl=(select case when(lcode.bcode_nm='') then LCODE.Entry_ty else lcode.bcode_nm end from LCODE where Entry_ty=@ReportType)
print @Main_Tbl	
--added by Prajakta B. on 19092017 for Bug 30451 end
/* Internale Variable declaration and Assigning [End] */

/* Standard Condition String Maker [Start] */
EXECUTE USP_REP_FILTCON @VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
	,@VSDATE=@SDATE,@VEDATE=@EDATE,@VSAC =@SAC,@VEAC =@EAC,@VSIT=@SIT,@VEIT=@EIT
	,@VSAMT=@SAMT,@VEAMT=@EAMT,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT,@VSCATE =@SCATE,@VECATE =@ECATE
	,@VSWARE =@SWARE,@VEWARE  =@EWARE,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
	,@VMAINFILE='d',@VITFILE='a',@VACFILE=' ',@VDTFLD ='DATE',@VLYN=NULL
	,@VEXPARA=NULL,@VFCON=@FCON OUTPUT
SELECT @FCON = CASE WHEN @FCON IS NULL THEN 'WHERE 1 = 2' ELSE @FCON END
/* Standard Condition String Maker [End] */

/* Main Table Creation [Start] */
IF @ZoomType = 'I'				/* Itemwise */
BEGIN
	-- Modified by :Sumit Gavate. on 16/02/2016 for Bug - 26995 ** Start **
	SET @SQLCOMMAND = 'SELECT A.*,ISNULL(ROUND(((A.Qty * A.TOT_ADD_CHRGS) / B.Sum_QTY),2) + A.Gro_amt,0) as Amount,
		ISNULL((((A.Qty * A.TOT_ADD_CHRGS / B.Sum_QTY)) + A.Gro_amt) / A.Qty,0) as RRate,(a.Qty * a.Rate) as BRAmount
		,(a.Qty * a.Rate) as Bbalamt,(a.Qty * a.Rate) as GRAmount,(a.Qty * a.Rate) as GBalamt,(a.Qty * a.Rate) as CAmount  INTO '+@TBLNAME1+' FROM 
		(Select a.Entry_Ty+Space(1)+CONVERT(VARCHAR(20),a.Tran_Cd)+Space(1)+a.itserial As ETI,a.Entry_Ty As rentry_ty,
		a.Tran_cd As Itref_Tran,a.itserial As Ritserial,a.Entry_Ty,a.Date,a.Tran_cd,a.itserial,a.Cate,a.Dept,a.INV_SR,a.Party_nm,
		a.Item,a.Qty,a.Rate,it_mast.rateunit,1 As levelcode,00 As sublevel,a.Inv_no,ISNULL(a.gro_amt,0) as Gro_amt,
		ISNULL((SOH.Tot_tax + SOH.Tot_nontax + SOH.tot_add) - (SOH.Tot_fdisc + SOH.Tot_deduc),0) as TOT_ADD_CHRGS'+@XTRAFLDS+' FROM Ordzm_vw_Item a 
		JOIN Ordzm_vw_Main d On (a.Entry_Ty = d.Entry_Ty And a.Tran_cd = d.Tran_cd) JOIN '
	--SET @SQLCOMMAND = @SQLCOMMAND + RTRIM(LTRIM(@ReportType))  --Commented by Prajakta B. on 19092017 for Bug 30451
	SET @SQLCOMMAND = @SQLCOMMAND + RTRIM(LTRIM(@Main_Tbl))  --Modified by Prajakta B. on 19092017 for Bug 30451
	SET @SQLCOMMAND = @SQLCOMMAND + 'MAIN SOH On (a.Entry_Ty = SOH.Entry_Ty And a.Tran_cd = SOH.Tran_cd) JOIN AC_MAST  On (AC_MAST.Ac_id = d.ac_Id)
		JOIN IT_MAST  On (IT_MAST.IT_CODE = a.IT_CODE)'
	SET @SQLCOMMAND = @SQLCOMMAND+@FCON
	SET @SQLCOMMAND = @SQLCOMMAND+' AND a.Entry_Ty In (Select Entry_Ty From LCode Where (Entry_Ty = '+CHAR(39)+@ReportType+CHAR(39)+'))) A INNER JOIN'
	SET @SQLCOMMAND = @SQLCOMMAND+' (SELECT Tran_cd,Entry_ty,ISNULL(SUM(qty),0) as Sum_qty from Ordzm_vw_Item WHERE Entry_Ty = '+CHAR(39)+@ReportType+CHAR(39)
	SET @SQLCOMMAND = @SQLCOMMAND+' GROUP BY Tran_cd,Entry_ty) B on (A.rentry_ty = B.Entry_ty AND A.TRAN_CD = B.TRAN_CD) '
	-- Modified by :Sumit Gavate. on 16/02/2016 for Bug - 26995 ** End **
	EXEC Sp_executeSQL @SQLCOMMAND
END
print @SQLCOMMAND
IF  @ZoomType = 'P'				/* Party wise */
BEGIN
	SELECT @ParmDefinition = N'@nLength Int'

	SET @SQLCOMMAND = 'SELECT a.Entry_Ty,a.Tran_cd,Sum(a.Qty) as Qty
		,(sum(a.Qty * a.Rate)/Sum(a.Qty)) as Rate,Sum(a.Qty * a.Rate) as BRAmount,SUM(a.Qty * a.Rate) as Bbalamt,SUM(a.Qty * a.Rate) as GRAmount,SUM(a.Qty * a.Rate) as GBalamt,SUM(a.Qty * a.Rate) as CAmount				--Added by Shrikant S. on 06/11/2017 for Bug-30858
		INTO '+@TBLNAME2+' FROM Ordzm_vw_Item a
		JOIN Ordzm_vw_Main d On (a.Entry_Ty = d.Entry_Ty And a.Tran_cd = d.Tran_cd)
		JOIN AC_MAST  On (AC_MAST.AC_ID = d.AC_ID)
		JOIN IT_MAST  On (IT_MAST.IT_CODE = a.IT_CODE)'
		SET @SQLCOMMAND = @SQLCOMMAND+@FCON
		SET @SQLCOMMAND = @SQLCOMMAND+' AND a.Entry_Ty In (Select Entry_Ty From LCode Where (Entry_Ty = '+CHAR(39)+@ReportType+CHAR(39)+'))'
		SET @SQLCOMMAND = @SQLCOMMAND+' GROUP BY a.Entry_Ty,a.Tran_cd'
		EXEC Sp_executeSQL @SQLCOMMAND

	SET @SQLCOMMAND = 'Select a.Entry_Ty+Space(1)+CONVERT(VARCHAR(20),a.Tran_Cd)+Space(1)+Space(@nLength) As ETI,
		a.Entry_Ty As rentry_ty,a.Tran_cd As Itref_Tran,Space(5) As Ritserial,
		a.Entry_Ty,d.Date,a.Tran_cd,Space(5) as itserial,d.Cate,d.Dept,d.INV_SR,d.Party_nm,
		SPACE(50) as Item,a.Qty,a.Rate,space(10) as Rateunit,1 As levelcode,00 As sublevel,d.Inv_no
		,ISNULL(d.gro_amt,0) as Gro_amt,ISNULL((d.Tot_tax + d.Tot_nontax + d.tot_add) - (d.Tot_fdisc + d.Tot_deduc),0) as TOT_ADD_CHRGS				--Added by Shrikant S. on 06/11/2017 for Bug-30858
		'+@XTRAFLDS+'
		,ISNULL(ROUND((ISNULL((d.Tot_tax + d.Tot_nontax + d.tot_add) - (d.Tot_fdisc + d.Tot_deduc),0)),2) + d.Gro_amt,0) as Amount					--Added by Shrikant S. on 06/11/2017 for Bug-30858
		,ISNULL(((ISNULL((d.Tot_tax + d.Tot_nontax + d.tot_add) - (d.Tot_fdisc + d.Tot_deduc),0)) + d.Gro_amt) / a.Qty,0) as RRate
		,a.BRAmount,a.BBalamt,a.GRAmount,a.GBalamt,a.CAmount  		--Added by Shrikant S. on 06/11/2017 for Bug-30858
		INTO '+@TBLNAME1+' FROM '+@TBLNAME2+' a
		JOIN Ordzm_vw_Main d On (a.Entry_Ty = d.Entry_Ty And a.Tran_cd = d.Tran_cd)'
--SPACE(50) as Item,a.Qty,0 as Rate,space(10) as Rateunit,1 As levelcode,00 As sublevel,d.Inv_no		--Commented by Shrikant S. on 06/11/2017 for GST Bug-30858		
	EXEC Sp_executeSQL @SQLCOMMAND,@ParmDefinition,@nLength = @nLength


	SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME2
	EXECUTE sp_executesql @SQLCOMMAND

END
/* Main Table Creation [Start] */

	SET @SQLCOMMAND = 'UPDATE '+@TBLNAME1+' set BRAmount=0,BBalamt=0,GRAmount=0,GBalamt=0'			--Added by Shrikant S. on 06/11/2017 for Bug-30858
	EXECUTE sp_executesql @SQLCOMMAND																--Added by Shrikant S. on 06/11/2017 for Bug-30858


	--SET @SQLCOMMAND = 'SELECT * FROM '+@TBLNAME1
	--EXECUTE sp_executesql @SQLCOMMAND


/* Find Sub Level Records and Insert That Into Final Temp Table [Start] */
SELECT @ParmDefinition = N'@nLength Int, @LevelCode Int'
SELECT @LevelCode = 1,@Stop_Loop = 1
IF  @ZoomType = 'I'				/* Item wise */
BEGIN
	WHILE @Stop_Loop <> 0 
	BEGIN 
		SET @LevelCode = @LevelCode + 1

		SET @SQLCOMMAND = 'SELECT a.ENTRY_TY+SPACE(1)+CONVERT(VARCHAR(10),a.TRAN_CD)+SPACE(1)+a.Itserial as ETI,
			a.Entry_Ty,a.Tran_cd,a.Itserial,a.RENTRY_TY,a.ITREF_TRAN,a.RItserial,
			a.RQty,b.Rate
			,(ISNULL(ROUND(((b.Qty * (ISNULL((d.Tot_tax + d.Tot_nontax + d.tot_add) - (d.Tot_fdisc + d.Tot_deduc),0))) / c.Sum_QTY),2) + b.Gro_amt,0)/b.Qty) as RRate		--Changed by Shrikant S. on 06/11/2017 for Bug-30858
			,(ISNULL(ROUND(((b.Qty * (ISNULL((d.Tot_tax + d.Tot_nontax + d.tot_add) - (d.Tot_fdisc + d.Tot_deduc),0))) / c.Sum_QTY),2) + b.Gro_amt,0)/b.Qty)* a.Rqty as GRAmount		--Changed by Shrikant S. on 06/11/2017 for Bug-30858
			INTO '+@TBLNAME2+' FROM ORDZM_VW_ITREF a	
			JOIN ORDZM_VW_ITEM b On (a.REntry_ty=b.Entry_ty and a.Itref_Tran=b.Tran_cd and a.RItserial=b.Itserial)
			JOIN ORDZM_VW_main d On (b.Entry_ty=d.Entry_ty AND b.TRAN_CD = d.TRAN_CD)
			JOIN (SELECT Tran_cd,Entry_ty,ISNULL(SUM(qty),0) as Sum_qty from Ordzm_vw_Item 
			 GROUP BY Tran_cd,Entry_ty) C on (b.Entry_ty=c.Entry_ty AND b.TRAN_CD = c.TRAN_CD) 
			WHERE a.TRAN_CD <> 0 AND a.ITREF_TRAN <> 0
			AND a.RENTRY_TY+SPACE(1)+CONVERT(VARCHAR(10),a.ITREF_TRAN)+SPACE(1)+a.RItserial IN 
				(SELECT ETI FROM '+@TBLNAME1+' )'
		EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition
				,@nLength = @nLength,@LevelCode = @LevelCode
				
	set @SQLCOMMAND=' Alter Table '+@TBLNAME2+' Alter Column Rrate Numeric(20,4)'			--Added by SURAJ K. on 29/01/2018 for Bug-28404
	EXECUTE sp_executesql @SQLCOMMAND														--Added by SURAJ K. on 29/01/2018 for Bug-28404
				

/* Commented By Shrikant S. on 31/05/2013 for Bug-548		Start */
		--SET @SQLCOMMAND = 'INSERT INTO '+@TBLNAME1+' SELECT e.ETI,e.rentry_ty,e.Itref_Tran,e.RItserial,
		--		e.Entry_Ty,d.Date,e.Tran_cd,e.itserial,d.Cate,d.Dept,d.INV_SR,d.Party_nm,
		--		a.Item,e.RQty as QTY,a.Rate,it_mast.rateunit,@LevelCode As levelcode,
		--		00 As sublevel,d.Inv_no '+@XTRAFLDS+' FROM '+@TBLNAME2+' E
		--		JOIN Ordzm_vw_Main d On (e.Entry_Ty = d.Entry_Ty And e.Tran_cd = d.Tran_cd)
		--		JOIN Ordzm_vw_Item a On (e.Entry_Ty = a.Entry_Ty And e.Tran_cd = a.Tran_cd And e.itserial = a.itserial)
		--		JOIN IT_MAST ON (IT_MAST.IT_CODE = a.IT_CODE)
		--		WHERE e.ETI NOT IN (SELECT ETI FROM '+@TBLNAME1+' )'
		--EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition
		--		,@nLength = @nLength,@LevelCode = @LevelCode
/* Commented By Shrikant S. on 31/05/2013 for Bug-548		End */

	/* Added By Shrikant S. on 31/05/2013 for Bug-548		Start */
	-- Modified by :Sumit Gavate. on 16/02/2016 for Bug - 26995 ** Start **
		SET @SQLCOMMAND = 'INSERT INTO '+@TBLNAME1+' SELECT e.ETI,e.rentry_ty,e.Itref_Tran,e.RItserial,
			e.Entry_Ty,d.Date,e.Tran_cd,e.itserial,d.Cate,d.Dept,d.INV_SR,d.Party_nm,
			Item=Isnull(a.Item,''''),e.RQty as QTY,Rate=Isnull(a.Rate,0),rateunit=Isnull(it_mast.rateunit,''''),@LevelCode As levelcode,00 As sublevel,
			d.Inv_no,000000.00 as Gro_amt,000000000.00 as TOT_ADD_CHRGS '+@XTRAFLDS+',e.GRAmount as Amount,e.RRate
			,0 as BRAmount,0 as BBalamt ,0 as GRAmount,0 as GBalamt,(e.Rqty * e.Rate) as CAmount					--Added by Shrikant S. on 06/11/2017 for Bug-30858
			FROM '+@TBLNAME2+' E
			LEFT JOIN Ordzm_vw_Main d On (e.Entry_Ty = d.Entry_Ty And e.Tran_cd = d.Tran_cd)
			LEFT JOIN Ordzm_vw_Item a On (e.Entry_Ty = a.Entry_Ty And e.Tran_cd = a.Tran_cd And e.itserial = a.itserial)
			LEFT JOIN IT_MAST ON (IT_MAST.IT_CODE = a.IT_CODE)
			WHERE e.ETI NOT IN (SELECT ETI FROM '+@TBLNAME1+' )'
	-- Modified by :Sumit Gavate. on 16/02/2016 for Bug - 26995 ** End **
		EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition
				,@nLength = @nLength,@LevelCode = @LevelCode
	/* Added By Shrikant S. on 31/05/2013 for Bug-548		End */			
		IF @@Rowcount = 0 
		BEGIN	
			SET @Stop_Loop = 0
		END
		SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME2
		EXECUTE sp_executesql @SQLCOMMAND
	END
END


IF  @ZoomType = 'P'				/* Party wise */
BEGIN
	WHILE @Stop_Loop <> 0 
	BEGIN 
		SET @LevelCode = @LevelCode + 1

		SET @SQLCOMMAND = 'SELECT a.ENTRY_TY+SPACE(1)+CONVERT(VARCHAR(10),a.TRAN_CD)+SPACE(1)+SPACE(@nLength) as ETI,
			a.Entry_Ty,a.Tran_cd,SPACE(@nLength) As Itserial,a.RENTRY_TY,a.ITREF_TRAN,SPACE(@nLength) As RItserial,
			SUM(a.RQty) As RQty,0 as Gro_amt
			, sum(a.RQty * b.Rate) as BRamount,0 as BBalamt								--Added by Shrikant S. on 06/11/2017 for Bug-30858
			,sum((ISNULL(ROUND(((b.QTY * (ISNULL((d.Tot_tax + d.Tot_nontax + d.tot_add) - (d.Tot_fdisc + d.Tot_deduc),0))) / c.Sum_QTY),2) + b.Gro_amt,0)/b.QTY)* a.Rqty)/sum(b.QTY) as RRate	--Added by Shrikant S. on 06/11/2017 for Bug-30858
			,sum((ISNULL(ROUND(((b.QTY * (ISNULL((d.Tot_tax + d.Tot_nontax + d.tot_add) - (d.Tot_fdisc + d.Tot_deduc),0))) / c.Sum_QTY),2) + b.Gro_amt,0)/b.QTY)* a.Rqty) as GRAmount	--Added by Shrikant S. on 06/11/2017 for Bug-30858
			,0 as GBalamt, sum(a.RQty * b.Rate) as Camount					--Added by Shrikant S. on 06/11/2017 for Bug-30858
			INTO '+@TBLNAME2+' FROM ORDZM_VW_ITREF a 
				INNER JOIN ORDZM_VW_ITEM b On (a.REntry_ty=b.Entry_ty and a.Itref_Tran=b.Tran_cd and a.RItserial=b.Itserial)
				INNER JOIN ORDZM_VW_main d On (b.Entry_ty=d.Entry_ty AND b.TRAN_CD = d.TRAN_CD)									--Added by Shrikant S. on 06/11/2017 for Bug-30858
				INNER JOIN (SELECT Tran_cd,Entry_ty,ISNULL(SUM(qty),0) as Sum_qty from Ordzm_vw_Item  GROUP BY Tran_cd,Entry_ty) c on (b.Entry_ty=c.Entry_ty AND b.TRAN_CD = c.TRAN_CD) '
				IF @TMPIT<>''
				BEGIN
					SET @SQLCOMMAND = @SQLCOMMAND+ ' INNER JOIN '+@TMPIT+' f on (f.IT_Name COLLATE '+@collation+'=b.item)'
				END
				
				SET @SQLCOMMAND = @SQLCOMMAND+ ' WHERE a.TRAN_CD <> 0 AND a.ITREF_TRAN <> 0
			AND a.RENTRY_TY+SPACE(1)+CONVERT(VARCHAR(10),a.ITREF_TRAN)+SPACE(1)+SPACE(@nLength) IN 
				(SELECT ETI FROM '+@TBLNAME1+' ) GROUP BY a.Entry_Ty,a.Tran_cd,a.RENTRY_TY,a.ITREF_TRAN'
				
--AND a.RENTRY_TY+SPACE(1)+CONVERT(VARCHAR(10),a.ITREF_TRAN)+SPACE(1)+SPACE(@nLength) IN 
--				(SELECT ETI FROM '+@TBLNAME1+' ) GROUP BY a.Entry_Ty,a.Tran_cd,a.RENTRY_TY,a.ITREF_TRAN'
								
		EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition
				,@nLength = @nLength,@LevelCode = @LevelCode


		SET @SQLCOMMAND = 'INSERT INTO '+@TBLNAME1+' SELECT a.ETI,a.rentry_ty,a.Itref_Tran,a.RItserial,
				a.Entry_Ty,d.Date,a.Tran_cd,a.itserial,d.Cate,d.Dept,d.INV_SR,d.Party_nm,
				SPACE(50) as Item,a.RQty as QTY,0 as Rate,space(10) as rateunit,@LevelCode As levelcode,
				00 As sublevel,d.Inv_no,000000000.00 as Gro_amt,000000000.00 as TOT_ADD_CHRGS '+@XTRAFLDS+',a.GRAmount as Amount,a.RRate
				,0 as BRAmount,0 as BBalamt,0 as GRAmount,0 as GBalamt,a.BRAmount as CAmount		--Added by Shrikant S. on 06/11/2017 for Bug-30858
				FROM '+@TBLNAME2+' a	
				JOIN Ordzm_vw_Main d On (a.Entry_Ty = d.Entry_Ty And a.Tran_cd = d.Tran_cd)
				WHERE a.ETI NOT IN (SELECT ETI FROM '+@TBLNAME1+' )'
		--00 As sublevel,d.Inv_no '+@XTRAFLDS+' FROM '+@TBLNAME2+' a					--Commented by Shrikant S. on 06/11/2017 for Bug-30858
		EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition
				,@nLength = @nLength,@LevelCode = @LevelCode

		IF @@Rowcount = 0 
		BEGIN	
			SET @Stop_Loop = 0
		END
		SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME2
		EXECUTE sp_executesql @SQLCOMMAND
	END
END



SET @SQLCOMMAND = 'SELECT CHAR(a.LevelCode+64)+Space(10) As CharLevel,
	a.RENTRY_TY+SPACE(1)+CONVERT(VARCHAR(10),a.ITREF_TRAN)+SPACE(1)+a.RItserial as RFETI,
	a.QTY as RQTY,* INTO '+@TBLNAME2+' FROM '+@TBLNAME1+' a ORDER BY Itref_tran,Item,CharLevel,Date'
EXECUTE sp_executesql @SQLCOMMAND



SET @SQLCOMMAND = 'SELECT a.RFETI,SUM(a.QTY) AS RQTY,COUNT(a.RFETI) as Sublevel,sum(Amount) as GRAmount,sum(CAmount) as BRAmount  INTO '+@TBLNAME3+' 
	FROM '+@TBLNAME2+' a WHERE a.ETI <> a.RFETI GROUP BY a.RFETI'
EXECUTE sp_executesql @SQLCOMMAND


SET @SQLCOMMAND = 'UPDATE '+@TBLNAME2+' SET RQTY = 0
	FROM '+@TBLNAME2+' a'
EXECUTE sp_executesql @SQLCOMMAND


SET @SQLCOMMAND = 'UPDATE '+@TBLNAME2+' SET RQty = b.RQty,Sublevel = b.Sublevel
				,BRAmount=b.BRAmount,BBalamt=a.CAmount-Isnull(b.BRAmount,0),GRAmount=b.GRAmount,GBalamt=a.Amount-Isnull(b.GRAmount,0) --Added by Shrikant S. on 10/11/2017 for Bug-30858
	FROM '+@TBLNAME2+' a, '+@TBLNAME3+' b WHERE a.ETI = b.RFETI'
EXECUTE sp_executesql @SQLCOMMAND


SET @SQLCOMMAND = 'UPDATE '+@TBLNAME2+' SET BBalamt=CAmount-Isnull(BRAmount,0),GBalamt=Amount-Isnull(GRAmount,0)'		--Added by Shrikant S. on 10/11/2017 for Bug-30858
EXECUTE sp_executesql @SQLCOMMAND					--Added by Shrikant S. on 10/11/2017 for Bug-30858

SELECT @ParmDefinition = N'@Expand Bit'

IF @ZoomType = 'I'				/* Itemwise */		--Added by Shrikant S.on 06/11/2017 for GST Bug-30858
BEGIN

	-- Modified by :Sumit Gavate. on 16/02/2016 for Bug - 26995 ** Start **
	SET @SQLCOMMAND = 'SELECT a.*,a.QTY-a.RQty as Balqty,@Expand as Expand,''Y'' as Expanded,
		Space(99) as UnderLevel,Space(1) as RepType,Space(25) as ColorCode,
		a.date as RDate
		FROM '+@TBLNAME2+' a'
		--,ISNULL((a.RQty * ROUND(a.RRate,2)),0) as RAmount,ISNULL((a.Qty * ROUND(a.RRate,2)) - (a.RQty * ROUND(a.RRate,2)),0) as BalAmt	--Commented by Shrikant S. on 10/11/2017 for Bug-30858
	-- Modified by :Sumit Gavate. on 16/02/2016 for Bug - 26995 ** End **
	EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition,@Expand = @Expand
	/* Find Sub Level Records and Insert That Into Final Temp Table [End] */
END				--Added by Shrikant S.on 06/11/2017 for GST Bug-30858



--Added by Shrikant S.on 06/11/2017 for GST Bug-30858		--Start
IF  @ZoomType = 'P'				/* Party wise */
BEGIN
	set @SQLCOMMAND=' Alter Table '+@TBLNAME2+' Alter Column Rrate Numeric(20,4)'			--Added by Shrikant S. on 12/12/2017 for Auto updater 13.0.5
	EXECUTE sp_executesql @SQLCOMMAND														--Added by Shrikant S. on 12/12/2017 for Auto updater 13.0.5

	SET @SQLCOMMAND = 'SELECT a.*,
		a.QTY-a.RQty as Balqty,@Expand as Expand,''Y'' as Expanded,
		Space(99) as UnderLevel,Space(1) as RepType,Space(25) as ColorCode,
		a.date as RDate 
		FROM '+@TBLNAME2+' a'
	EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition,@Expand = @Expand
END
--Added by Shrikant S.on 06/11/2017 for GST Bug-30858		--End

/* Droping Temp tables [Start] */
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME1
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME2
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME3
EXECUTE sp_executesql @SQLCOMMAND
/* Droping Temp tables [End] */
GO
