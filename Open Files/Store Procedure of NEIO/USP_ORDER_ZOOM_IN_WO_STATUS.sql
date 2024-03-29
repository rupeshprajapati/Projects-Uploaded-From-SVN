DROP PROCEDURE [USP_ORDER_ZOOM_IN_WO_STATUS]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*:*****************************************************************************
*:        System: UDYOG Software (I) Ltd.
*:    Programmer: Birendra Prasa
*:	  Date      : 02/03/2014
*:	  AIM		: Order Zoom-In Report
**:******************************************************************************
**:******************************************************************************/

CREATE PROCEDURE [USP_ORDER_ZOOM_IN_WO_STATUS]
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

--IF @ReportType IS NULL OR @ReportType = ''
--BEGIN 
--	RAISERROR ('Please Pass Report Type...', 16,1) 
--	Return 
--END
set @ReportType = 'WK'
/* Internale Variable declaration and Assigning [Start] */
DECLARE @Balance Numeric(17,2),@TBLNM VARCHAR(50),@TBLNAME1 Varchar(50),
	@TBLNAME2 Varchar(50),@TBLNAME3 Varchar(50),@TBLNAME4 Varchar(50),
	@SQLCOMMAND as NVARCHAR(4000),@PrimaryFld As Int,@Stop_Loop Bit,
	@ParmDefinition nvarchar(500),@LevelCode Int,@CaseSQL nvarchar(500),
	@Expand Bit

SELECT @ParmDefinition = '',@CaseSQL = '',@Expand = 1
DECLARE @FCON as NVARCHAR(2000),@VSAMT DECIMAL(14,2),@VEAMT DECIMAL(14,2),@nLength Int

SELECT @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
		+ (DATEPART(ss, GETDATE()) * 1000 )+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No),
		@Balance = 0,@SQLCOMMAND = ''

SELECT @nLength = COLUMNPROPERTY(Object_Id('ORDZM_VW_ITREF'),'RItserial','Precision')
SELECT @TBLNAME1 = '##TMP1'+@TBLNM,@TBLNAME2 = '##TMP2'+@TBLNM
SELECT @TBLNAME3 = '##TMP3'+@TBLNM,@TBLNAME4 = '##TMP4'+@TBLNM
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
--Biru
	SET @SQLCOMMAND = 'Select a.Entry_Ty+Space(1)+CONVERT(VARCHAR(20),a.Tran_Cd)+Space(1)+a.itserial As ETI,
		a.Entry_Ty As rentry_ty,a.Tran_cd As Itref_Tran,a.itserial As Ritserial,
		a.Entry_Ty,a.Date,a.Tran_cd,a.itserial,a.Cate,a.Dept,a.INV_SR,a.Party_nm,
		a.Item,a.Qty,a.Rate,it_mast.rateunit,1 As levelcode,00 As sublevel,a.Inv_no,a.bomid,space(20) as batchno 
		,coalesce((select trm_qty from item where entry_ty=a.entry_ty and tran_cd=a.tran_cd and itserial=a.itserial and it_code=a.it_code ),0) as trm_qty 
		'+@XTRAFLDS+'
		INTO '+@TBLNAME1+' FROM Ordzm_vw_Item a
		JOIN Ordzm_vw_Main d On (a.Entry_Ty = d.Entry_Ty And a.Tran_cd = d.Tran_cd)
		JOIN AC_MAST  On (AC_MAST.Ac_id = d.ac_Id)
		JOIN IT_MAST  On (IT_MAST.IT_CODE = a.IT_CODE)'
		SET @SQLCOMMAND = @SQLCOMMAND+@FCON
		SET @SQLCOMMAND = @SQLCOMMAND+' AND a.Entry_Ty In (Select Entry_Ty From LCode Where (Entry_Ty = '+CHAR(39)+@ReportType+CHAR(39)+'))'
	EXEC Sp_executeSQL @SQLCOMMAND
END


/* Find Sub Level Records and Insert That Into Final Temp Table [Start] */
SELECT @ParmDefinition = N'@nLength Int, @LevelCode Int'
SELECT @LevelCode = 1,@Stop_Loop = 1
IF  @ZoomType = 'I'				/* Item wise */
BEGIN
	WHILE @Stop_Loop <> 0 
	BEGIN 
		SET @LevelCode = @LevelCode + 1
---Biru
		SET @SQLCOMMAND = 'SELECT a.ENTRY_TY+SPACE(1)+CONVERT(VARCHAR(10),a.TRAN_CD)+SPACE(1)+a.Itserial as ETI,
			a.Entry_Ty,a.Tran_cd,a.Itserial,a.RENTRY_TY,a.ITREF_TRAN,a.RItserial,
			a.RQty,a.batchno,a.trm_qty,a.bomid INTO '+@TBLNAME2+' FROM (select *,space(10) as bomid,'''' as batchno,0 as trm_qty from ORDZM_VW_ITREF UNION SELECT Entry_ty,getdate() as [Date],'''' as Doc_no,Itserial,Tran_cd,aentry_ty as Rentry_ty,getdate() as Rdate,'''' as Rdoc_no,atran_cd as Itref_Tran,aitserial as Ritserial,Qty as RQty,bomid,batchno,0 as trm_qty FROM projectitref) a WHERE TRAN_CD <> 0 AND a.ITREF_TRAN <> 0
			AND a.RENTRY_TY+SPACE(1)+CONVERT(VARCHAR(10),a.ITREF_TRAN)+SPACE(1)+a.RItserial IN 
				(SELECT ETI FROM '+@TBLNAME1+' )'
		EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition
				,@nLength = @nLength,@LevelCode = @LevelCode

--print @SQLCOMMAND

		SET @SQLCOMMAND = 'INSERT INTO '+@TBLNAME1+' SELECT e.ETI,e.rentry_ty,e.Itref_Tran,e.RItserial,
				e.Entry_Ty,d.Date,e.Tran_cd,e.itserial,d.Cate,d.Dept,d.INV_SR,d.Party_nm,
				a.Item,e.RQty as QTY,a.Rate,it_mast.rateunit,@LevelCode As levelcode,
				00 As sublevel,d.Inv_no,e.bomid,e.batchno,e.trm_qty '+@XTRAFLDS+' FROM '+@TBLNAME2+' E
				JOIN Ordzm_vw_Main d On (e.Entry_Ty = d.Entry_Ty And e.Tran_cd = d.Tran_cd)
				JOIN Ordzm_vw_Item a On (e.Entry_Ty = a.Entry_Ty And e.Tran_cd = a.Tran_cd And e.itserial = a.itserial)
				JOIN IT_MAST ON (IT_MAST.IT_CODE = a.IT_CODE)
				WHERE e.ETI NOT IN (SELECT ETI FROM '+@TBLNAME1+' )'
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
	a.QTY as RQTY,a.* INTO '+@TBLNAME2+' FROM '+@TBLNAME1+' a ORDER BY Itref_tran,Item,CharLevel,Date'
EXECUTE sp_executesql @SQLCOMMAND


--Biru
SET @SQLCOMMAND = 'SELECT a.RFETI,a.item,SUM(a.QTY) AS RQTY,COUNT(a.RFETI) as Sublevel,a.bomid INTO '+@TBLNAME3+' 
	FROM '+@TBLNAME2+' a WHERE a.ETI <> a.RFETI GROUP BY a.RFETI,a.item,a.bomid'
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'UPDATE '+@TBLNAME2+' SET RQTY = 0
	FROM '+@TBLNAME2+' a'
EXECUTE sp_executesql @SQLCOMMAND


SET @SQLCOMMAND = 'UPDATE '+@TBLNAME2+' SET RQty = b.RQty,Sublevel = b.Sublevel
	FROM '+@TBLNAME2+' a, '+@TBLNAME3+' b WHERE a.ETI = b.RFETI'
EXECUTE sp_executesql @SQLCOMMAND

---Biru:start:
SET @SQLCOMMAND = 'select p1.qty*b.ratio as adjqty
	,p1.aentry_ty+convert(varchar(10),p1.atran_cd)+p1.bomid as atb
	,p1.it_code
	,p1.ENTRY_TY+SPACE(1)+CONVERT(VARCHAR(10),P1.TRAN_CD)+SPACE(1)+P1.itserial as ETI
		into '+@TBLNAME4+'
	 from projectitref p1
	left join
	(select b1.fgqty/b2.rmqty as ratio,b1.bomid,b2.rmitemid,b1.itemid from bomhead b1
	inner join bomdet b2 on (b1.bomid=b2.bomid))b
	on (p1.bomid=b.bomid and p1.it_code=b.rmitemid) '

EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'UPDATE '+@TBLNAME2+' SET RQty = b.adjQty
	FROM '+@TBLNAME2+' a inner join (select * from '+@TBLNAME4+' where  isnull(adjqty,0)<>0 ) b on (a.eti = b.eti)'
EXECUTE sp_executesql @SQLCOMMAND

--SET @SQLCOMMAND = 'select * from '+@TBLNAME2 --biru
--EXEC Sp_executeSQL @SQLCOMMAND

SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME4
EXECUTE sp_executesql @SQLCOMMAND

SET @SQLCOMMAND = 'select sum(p1.qty*b.ratio) as adjqty
	,p1.aentry_ty+convert(varchar(10),p1.atran_cd)+p1.bomid as atb
	,sum(p1.qty) as totqty
	,p1.it_code
	into '+@TBLNAME4+'
	 from projectitref p1
	left join
	(select b1.fgqty/b2.rmqty as ratio,b1.bomid,b2.rmitemid,b1.itemid from bomhead b1
	inner join bomdet b2 on (b1.bomid=b2.bomid))b
	on (p1.bomid=b.bomid and p1.it_code=b.rmitemid)
	group by p1.aentry_ty+convert(varchar(10),p1.atran_cd)+p1.bomid,p1.it_code'

--SET @SQLCOMMAND = 'SELECT * from '+@TBLNAME2
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'UPDATE '+@TBLNAME2+' SET RQty = b.adjQty
	FROM '+@TBLNAME2+' a, '+@TBLNAME4+' b WHERE a.entry_ty+convert(varchar(10),a.tran_cd)+a.bomid = b.atb'
EXECUTE sp_executesql @SQLCOMMAND
---Biru:End:


SELECT @ParmDefinition = N'@Expand Bit'

SET @SQLCOMMAND = 'SELECT a.*,
	case when charlevel=''A'' then a.QTY-a.RQty-a.trm_qty else 0 end as Balqty,@Expand as Expand,''Y'' as Expanded,
	Space(99) as UnderLevel,Space(1) as RepType,Space(25) as ColorCode,
	a.date as RDate,0 as Ipbalqty FROM '+@TBLNAME2+' a'

EXECUTE sp_executesql @SQLCOMMAND,@ParmDefinition,@Expand = @Expand
/* Find Sub Level Records and Insert That Into Final Temp Table [End] */
/* Droping Temp tables [Start] */
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME1
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME2
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME3
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME4
EXECUTE sp_executesql @SQLCOMMAND
/* Droping Temp tables [End] */
GO
