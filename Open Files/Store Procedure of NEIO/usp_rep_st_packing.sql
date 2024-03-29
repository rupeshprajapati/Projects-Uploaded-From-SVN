DROP PROCEDURE [USP_REP_ST_packing]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Birendra Prasad.
-- Create date: 07/12/2010
-- Description:	This Stored procedure is useful to Generate data for Packing slip in sales transation.
-- Modification Date/By/Reason: 10/01/2012 Shrikant S. for Bug-1460(Multi UOM qty fields are require in default)	
-- =============================================


Create PROCEDURE  [USP_REP_ST_packing]
	@ENTRYCOND NVARCHAR(254)
	AS
DECLARE @SQLCOMMAND AS NVARCHAR(4000),@TBLCON AS NVARCHAR(4000)
DECLARE @CHAPNO VARCHAR(30),@EIT_NAME  VARCHAR(100),@MCHAPNO VARCHAR(250),@MEIT_NAME  VARCHAR(250)

-- Added By Shrikant S. on 10/01/2012 for Bug-1460		--Start
Select Entry_ty,Tran_cd=0,Date,inv_no,itserial=space(6) Into #stmain from stmain Where 1=0
Create NonClustered Index Idx_tmpStmain On #stmain (Entry_ty asc, Tran_cd Asc, Itserial asc)

SET @TBLCON=RTRIM(@ENTRYCOND)
set @sqlcommand='Insert Into #stmain Select stmain.Entry_ty,stmain.Tran_cd,stmain.date,stmain.inv_no,stitem.itserial from stmain Inner Join stitem on (stmain.Entry_ty=stitem.Entry_ty and stmain.Tran_cd=stitem.Tran_cd) Where '+@TBLCON
execute sp_executesql @sqlcommand


Declare @uom_desc as Varchar(100),@len int,@fld_nm varchar(10),@fld_desc Varchar(10),@count int,@stkl_qty Varchar(100)

select @uom_desc=isnull(uom_desc,'') from vudyog..co_mast where dbname =rtrim(db_name())
Create Table #qty_desc (fld_nm varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS, fld_desc varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)
set @len=len(@uom_desc)
set @stkl_qty=''
If @len>0 
Begin
	while @len>0
	Begin
		set @fld_nm=substring(@uom_desc,1,charindex(':',@uom_desc)-1)
		set @uom_desc=substring(@uom_desc,charindex(':',@uom_desc)+1,@len)
		set @stkl_qty= @stkl_qty +', '+'STITEM.'+@fld_nm

		if @len>0 and charindex(';',@uom_desc)=0
		begin
			set @uom_desc=@uom_desc
			set @fld_desc=@uom_desc
			SET @len=0
		End
		else
		begin
				set @fld_desc=substring(@uom_desc,1,charindex(';',@uom_desc)-1)
				set @uom_desc=substring(@uom_desc,charindex(';',@uom_desc)+1,@len)
				set @len=len(@uom_desc)
		End
		insert into #qty_desc values (@fld_nm,@fld_desc)
	End
End
Else
Begin
	set @stkl_qty=',STITEM.QTY'
End

set @sqlcommand=''
set @sqlcommand=@sqlcommand+' '+'SELECT ''REPORT HEADER'' AS REP_HEAD,STMAIN.INV_SR,STMAIN.TRAN_CD,STMAIN.ENTRY_TY,STMAIN.INV_NO,STMAIN.DATE'
set @sqlcommand=@sqlcommand+' '+',STMAIN.U_TIMEP,STMAIN.U_TIMEP1 ,STMAIN.U_REMOVDT,STMAIN.U_EXPLA,STMAIN.U_EXRG23II,STMAIN.U_RG2AMT'
set @sqlcommand=@sqlcommand+' '+',STITEM.EXAMT,STITEM.U_BASDUTY,STITEM.U_CESSPER,STITEM.U_CESSAMT,STITEM.U_HCESSPER,STITEM.U_HCESAMT'
set @sqlcommand=@sqlcommand+' '+',STMAIN.U_DELIVER,STMAIN.DUE_DT,STMAIN.U_CLDT,U_CHALNO=SPACE(1),U_CHALDT=STMAIN.DATE,STMAIN.U_PONO,STMAIN.U_PODT,STMAIN.U_LRNO,STMAIN.U_LRDT,STMAIN.U_DELI,STMAIN.U_VEHNO,STMAIN.GRO_AMT GRO_AMT1,STMAIN.TAX_NAME,STMAIN.TAXAMT,STMAIN.NET_AMT,STMAIN.U_PLASR,STMAIN.U_RG23NO,STMAIN.U_RG23CNO'
set @sqlcommand=@sqlcommand+' '+',STITEM.U_PKNO,STITEM.QTY,STITEM.RATE,STITEM.U_ASSEAMT,STITEM.U_MRPRATE,STITEM.U_EXPDESC,STITEM.U_EXPMARK,STITEM.U_EXPGWT,STITEM.U_EXPNWT'
set @sqlcommand=@sqlcommand+' '+',STMAIN.u_fdesti,cast(stitem.u_pkno as int) as U_PKNO1,STMAIN.U_BLNO,STMAIN.U_countain,STMAIN.U_COUNTAI2'
set @sqlcommand=@sqlcommand+' '+',STMAIN.U_TSEAL,STMAIN.U_TSEAL2,STMAIN.U_PRECARRI,STMAIN.U_RECEIPT,STMAIN.U_LOADING,STMAIN.U_PORT,''India'' as U_ORIGIN'
set @sqlcommand=@sqlcommand+' '+',STMAIN.U_EXPDEL,IT_MAST.IT_NAME,CAST(IT_MAST.IT_DESC AS VARCHAR(4000)) AS IT_DESC'
set @sqlcommand=@sqlcommand+' '+',IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.IDMARK,IT_MAST.RATEUNIT'
set @sqlcommand=@sqlcommand+' '+',AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.S_TAX,AC_MAST.I_TAX'
set @sqlcommand=@sqlcommand+' '+',AC_MAST.ECCNO ,AC_MAST1.ADD1 ADD11,AC_MAST1.ADD2 ADD22,AC_MAST1.ADD3 ADD33,AC_MAST1.CITY CITY1'
set @sqlcommand=@sqlcommand+' '+',AC_MAST1.ZIP ZIP1,AC_MAST1.S_TAX S_TAX1,AC_MAST1.I_TAX I_TAX1,AC_MAST1.ECCNO ECCNO1,STITEM.ITSERIAL' 
set @sqlcommand=@sqlcommand+' '+',mChapno=cast(isnull(substring((Select '', '' +rtrim(chapno) From Stitem Inner Join It_mast on (Stitem.It_code=It_mast.It_code) Where stitem.Entry_ty=stmain.Entry_ty and stitem.tran_cd=stmain.Tran_cd Group by chapno Order By chapno For XML Path('''')),2,2000),'''') as Varchar)'
set @sqlcommand=@sqlcommand+' '+',mEIT_NAME=cast(isnull(substring((Select '', '' +rtrim(eit_name) From Stitem Inner Join It_mast on (Stitem.It_code=It_mast.It_code) Where stitem.Entry_ty=stmain.Entry_ty and stitem.tran_cd=stmain.Tran_cd Group by Eit_name Order By Eit_name For XML Path('''')),2,2000),'''') as Varchar(2000))'
set @sqlcommand=@sqlcommand+' '+'FROM STMAIN  INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD)'
set @sqlcommand=@sqlcommand+' '+'INNER JOIN #stmain ON (STITEM.TRAN_CD=#stmain.TRAN_CD and STITEM.Entry_ty=#stmain.entry_ty and STITEM.ITSERIAL=#stmain.itserial) '
set @sqlcommand=@sqlcommand+' '+'INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE)'
set @sqlcommand=@sqlcommand+' '+'INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID) '
set @sqlcommand=@sqlcommand+' '+'LEFT JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_NAME=STMAIN.U_DELIVER)' 
set @sqlcommand=@sqlcommand+' '+'ORDER BY STMAIN.INV_SR,CAST(STMAIN.INV_NO  AS INT)'
execute sp_executesql @sqlcommand
-- Added By Shrikant S. on 10/01/2012 for Bug-1460		--End

/*		Commented By Shrikant S. on 10/01/2012 for Bug-1460		--Start
	--->ENTRY_TY AND TRAN_CD SEPARATION
		DECLARE @ENT VARCHAR(2),@TRN INT,@POS1 INT,@POS2 INT,@POS3 INT
		
		PRINT @ENTRYCOND
		SET @POS1=CHARINDEX('''',@ENTRYCOND,1)+1
		SET @ENT= SUBSTRING(@ENTRYCOND,@POS1,2)
		SET @POS2=CHARINDEX('=',@ENTRYCOND,CHARINDEX('''',@ENTRYCOND,@POS1))+1
		SET @POS3=CHARINDEX('=',@ENTRYCOND,CHARINDEX('''',@ENTRYCOND,@POS2))+1
		SET @TRN= SUBSTRING(@ENTRYCOND,@POS2,@POS2-@POS3)
	SET @TBLCON=RTRIM(@ENTRYCOND)
	
	-- 	
	SELECT 'REPORT HEADER' AS REP_HEAD,STMAIN.INV_SR,STMAIN.TRAN_CD,STMAIN.ENTRY_TY,STMAIN.INV_NO,STMAIN.DATE
	,STMAIN.U_TIMEP,STMAIN.U_TIMEP1 ,STMAIN.U_REMOVDT,STMAIN.U_EXPLA,STMAIN.U_EXRG23II,STMAIN.U_RG2AMT
	,STITEM.EXAMT,STITEM.U_BASDUTY,STITEM.U_CESSPER,STITEM.U_CESSAMT,STITEM.U_HCESSPER,STITEM.U_HCESAMT
	,STMAIN.U_DELIVER,STMAIN.DUE_DT,STMAIN.U_CLDT,U_CHALNO=SPACE(1),U_CHALDT=STMAIN.DATE,STMAIN.U_PONO,STMAIN.U_PODT,STMAIN.U_LRNO,STMAIN.U_LRDT,STMAIN.U_DELI,STMAIN.U_VEHNO,STMAIN.GRO_AMT GRO_AMT1,STMAIN.TAX_NAME,STMAIN.TAXAMT,STMAIN.NET_AMT,STMAIN.U_PLASR,STMAIN.U_RG23NO,STMAIN.U_RG23CNO
	,STITEM.U_PKNO,STITEM.QTY,STITEM.RATE,STITEM.U_ASSEAMT,STITEM.U_MRPRATE,STITEM.U_EXPDESC,STITEM.U_EXPMARK,STITEM.U_EXPGWT,STITEM.U_EXPNWT
	,STMAIN.u_fdesti
	,cast(stitem.u_pkno as int) as U_PKNO1
	,STMAIN.U_BLNO
	,STMAIN.U_countain,STMAIN.U_COUNTAI2
	,STMAIN.U_TSEAL,STMAIN.U_TSEAL2
	,STMAIN.U_PRECARRI
	,STMAIN.U_RECEIPT
	,STMAIN.U_LOADING
	,STMAIN.U_PORT
	,'India' as U_ORIGIN
	,STMAIN.U_EXPDEL
	,IT_MAST.IT_NAME
	,CAST(IT_MAST.IT_DESC AS VARCHAR(4000)) AS IT_DESC 
	,IT_MAST.EIT_NAME
	,IT_MAST.CHAPNO
	,IT_MAST.IDMARK,IT_MAST.RATEUNIT 
	,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.S_TAX,AC_MAST.I_TAX
	,AC_MAST.ECCNO ,AC_MAST1.ADD1 ADD11,AC_MAST1.ADD2 ADD22,AC_MAST1.ADD3 ADD33,AC_MAST1.CITY CITY1
	,AC_MAST1.ZIP ZIP1,AC_MAST1.S_TAX S_TAX1,AC_MAST1.I_TAX I_TAX1,AC_MAST1.ECCNO ECCNO1,STITEM.ITSERIAL  
	INTO #STMAIN
	FROM STMAIN  INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD) 
	INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE) 
	INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID) 
	LEFT JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_NAME=STMAIN.U_DELIVER) 
	WHERE  STMAIN.ENTRY_TY= @ENT  AND STMAIN.TRAN_CD=@TRN
	ORDER BY STMAIN.INV_SR,CAST(STMAIN.INV_NO  AS INT)
	SET @MCHAPNO=' '
	SET @MEIT_NAME=' '
	
	DECLARE CUR_STBILL CURSOR FOR SELECT DISTINCT CHAPNO FROM #STMAIN
	OPEN CUR_STBILL 
	FETCH NEXT FROM CUR_STBILL INTO @CHAPNO
	WHILE(@@FETCH_STATUS=0)
	BEGIN
		SET @MCHAPNO=RTRIM(@MCHAPNO)+','+RTRIM(@CHAPNO)
		FETCH NEXT FROM CUR_STBILL INTO @CHAPNO
	END
	CLOSE CUR_STBILL
	DEALLOCATE CUR_STBILL
	
	DECLARE CUR_STBILL CURSOR FOR SELECT DISTINCT EIT_NAME FROM #STMAIN
	OPEN CUR_STBILL 
	FETCH NEXT FROM CUR_STBILL INTO @EIT_NAME
	WHILE(@@FETCH_STATUS=0)
	BEGIN
		SET @MEIT_NAME=RTRIM(@MEIT_NAME)+','+RTRIM(@EIT_NAME)
		FETCH NEXT FROM CUR_STBILL INTO @EIT_NAME
	END
	CLOSE CUR_STBILL
	DEALLOCATE CUR_STBILL	

	SET @MCHAPNO=CASE WHEN LEN(@MCHAPNO)>1 THEN SUBSTRING(@MCHAPNO,2,LEN(@MCHAPNO)-1) ELSE '' END
	SET @MEIT_NAME=CASE WHEN LEN(@MEIT_NAME)>1 THEN SUBSTRING(@MEIT_NAME,2,LEN(@MEIT_NAME)-1) ELSE '' END
	SELECT * 
	,MCHAPNO=ISNULL(@MCHAPNO,'')
	,MEIT_NAME=ISNULL(@MEIT_NAME,'')
	FROM #STMAIN


Commented By Shrikant S. on 10/01/2012 for Bug-1460		--End */
GO
