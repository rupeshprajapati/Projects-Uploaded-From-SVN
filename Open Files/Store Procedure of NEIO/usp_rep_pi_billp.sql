DROP PROCEDURE [USP_REP_PI_BILLP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE   [USP_REP_PI_BILLP]
	@ENTRYCOND NVARCHAR(254)
	AS
	
DECLARE @SQLCOMMAND AS NVARCHAR(max),@TBLCON AS NVARCHAR(4000),@QueryString NVarchar(max),@Tot_flds Varchar(4000)
DECLARE @CHAPNO VARCHAR(30),@EIT_NAME  VARCHAR(100),@MCHAPNO VARCHAR(250),@MEIT_NAME  VARCHAR(250)

SET @TBLCON=RTRIM(@ENTRYCOND)

--ruchit
Select Entry_ty,Tran_cd=0 Into #PIMAIN from PIMAIN Where 1=0
set @sqlcommand='Insert Into #PIMAIN Select PIMAIN.Entry_ty,PIMAIN.Tran_cd from PIMAIN Where '+@TBLCON
print @sqlcommand
execute sp_executesql @sqlcommand
		

declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where code in( 'D','F') and att_file=0 and Entry_ty='PI'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='PI'   FOR XML PATH ('')), 1, 0, ''
                 --(select case when fld_nm<>'' then '+'+fld_nm else ''  end from dcmast where code='T' and att_file=0 and entry_ty='PI' and bef_aft=2  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
               
   --Commented By Prajakta B. on 28082017                  
--SELECT 
--    @ItemNTX = isnull(STUFF(
--                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='PI' /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
--               ),0)     
   --Modified By Prajakta B. on 28082017   
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='PI' and fld_nm not in ('Compcess') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)   

--itemwise non tax

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='PI'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='PI'  FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='PI'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--ruchit
	
	--->ENTRY_TY AND TRAN_CD SEPARATION
		--DECLARE @ENT VARCHAR(2),@TRN INT,@POS1 INT,@POS2 INT,@POS3 INT--,@ENTRYCOND NVARCHAR(254)
		
PRINT @ENTRYCOND
		--SET @POS1=CHARINDEX('''',@ENTRYCOND,1)+1
		--SET @ENT= SUBSTRING(@ENTRYCOND,@POS1,2)
		--SET @POS2=CHARINDEX('=',@ENTRYCOND,CHARINDEX('''',@ENTRYCOND,@POS1))+1
		--SET @POS3=CHARINDEX('=',@ENTRYCOND,CHARINDEX('''',@ENTRYCOND,@POS2))+1
		--SET @TRN= SUBSTRING(@ENTRYCOND,@POS2,@POS2-@POS3)
		--SELECT * FROM BPMAIN WHERE ENTRY_TY=@ENT AND TRAN_CD=@TRN
	---<---ENTRY_TY AND TRAN_CD SEPARATION
--	SET @TBLCON=RTRIM(@ENTRYCOND)
	
	
	-- 	,AC_MAST1.AC_NAME AS U_DELIVER
print 'issue is here'
	SET @QueryString ='SELECT ''REPORT HEADER'' AS REP_HEAD,PIMAIN.INV_NO,PIMAIN.TRAN_CD,PIMAIN.ENTRY_TY,PIMAIN.INV_NO,PIMAIN.DATE
	,PIMAIN.U_TIMEP,PIMAIN.U_TIMEP1 ,PIMAIN.U_REMOVDT,cast (PIMAIN.NARR AS VARCHAR(2000)) AS NARR
	,PIMAIN.DUE_DT,PIMAIN.U_CLDT,U_CHALNO=SPACE(1),U_CHALDT=PIMAIN.DATE,PIMAIN.U_PONO,PIMAIN.U_PODT,PIMAIN.U_LRNO,PIMAIN.U_LRDT,PIMAIN.U_DELI,PIMAIN.U_VEHNO,PIMAIN.GRO_AMT GRO_AMT1,PIMAIN.TAX_NAME,PIMAIN.TAXAMT,PIMAIN.NET_AMT,PIMAIN.U_PLASR
	,PIITEM.U_PKNO,PIITEM.QTY,PIITEM.RATE,PIITEM.GRO_AMT AS IT_GROAMT,PIITEM.U_ASSEAMT,PIITEM.U_MRPRATE,PIITEM.U_EXPDESC,PIITEM.U_EXPMARK,PIITEM.U_EXPGWT 
	,PIMAIN.U_FDESTI,PIITEM.CGST_AMT,PIITEM.SGST_AMT,PIITEM.IGST_AMT,piitem.Compcess
	,PIMAIN.U_PAYMENT
	,PIITEM.U_EXPNWT
	,IT_MAST.IT_NAME
	,CAST(IT_MAST.IT_DESC AS VARCHAR(4000)) AS IT_DESC 
	,IT_MAST.EIT_NAME
	,IT_MAST.CHAPNO,IT_MAST.HSNCODE
	,IT_MAST.IDMARK,IT_MAST.RATEUNIT
	,ac_name=(CASE WHEN PIMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.ac_name END)
,ADD1=(CASE WHEN PIMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add1,'''')='''' THEN AC_MAST.add1 ELSE SHIPTO.ADD1 END) ELSE AC_MAST.ADD1 END)
,ADD2=(CASE WHEN PIMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add2,'''')='''' THEN AC_MAST.add2 ELSE SHIPTO.add2 END) ELSE AC_MAST.ADD2 END)
,ADD3=(CASE WHEN PIMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add3,'''')='''' THEN AC_MAST.add3 ELSE SHIPTO.add3 END) ELSE AC_MAST.ADD3 END)
,City=(CASE WHEN PIMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.city,'''')='''' THEN AC_MAST.city ELSE SHIPTO.city END) ELSE AC_MAST.city END)
,State=(CASE WHEN PIMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.state,'''')='''' THEN AC_MAST.State ELSE SHIPTO.State END) ELSE AC_MAST.State END)
,Zip=(CASE WHEN PIMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.zip,'''')='''' THEN AC_MAST.zip ELSE SHIPTO.zip END) ELSE AC_MAST.zip END)
,i_tax=(CASE WHEN PIMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.i_tax,'''')='''' THEN AC_MAST.i_tax ELSE SHIPTO.i_tax END) ELSE AC_MAST.i_tax END)
,GSTIN=(CASE WHEN PIMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.GSTIN,'''')='''' THEN AC_MAST.GSTIN ELSE SHIPTO.GSTIN END) ELSE AC_MAST.GSTIN END)' 


--gstin=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.gstin,'''')='''' THEN AC_MAST.gstin ELSE SHIPTO.gstin END) ELSE AC_MAST.gstin END)
--state=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.[state],'''')='''' THEN AC_MAST.[state] ELSE SHIPTO.[state] END) ELSE AC_MAST.[state] END)
--supp_type=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.[supp_type],'''')='''' THEN AC_MAST.[supp_type] ELSE SHIPTO.[supp_type] END) ELSE AC_MAST.[supp_type] END)

	--,AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.I_TAX
	--,AC_MAST1.ADD1 ADD11,AC_MAST1.ADD2 ADD22,AC_MAST1.ADD3 ADD33,AC_MAST1.CITY CITY1
	--,AC_MAST1.ZIP ZIP1,AC_MAST1.I_TAX I_TAX1,PIITEM.ITSERIAL  
	
	SET @QueryString =@QueryString+--	,ac_name=(CASE WHEN PIMAIN.sac_id > 0 THEN SHIPTO1.mailname ELSE AC_MAST1.ac_name END)
',U_DELIVER=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.MailName,'''')='''' THEN AC_MAST1.ac_name ELSE SHIPTO1.mailname END) ELSE AC_MAST1.AC_NAME END)
,ADD11=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add1,'''')='''' THEN AC_MAST1.add1 ELSE SHIPTO1.ADD1 END) ELSE AC_MAST1.ADD1 END)
,ADD22=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add2,'''')='''' THEN AC_MAST1.add2 ELSE SHIPTO1.add2 END) ELSE AC_MAST1.ADD2 END)
,ADD33=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add3,'''')='''' THEN AC_MAST1.add3 ELSE SHIPTO1.add3 END) ELSE AC_MAST1.ADD3 END)
,City1=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.city,'''')='''' THEN AC_MAST1.city ELSE SHIPTO1.city END) ELSE AC_MAST1.city END)
,State1=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.State,'''')='''' THEN AC_MAST1.State ELSE SHIPTO1.State END) ELSE AC_MAST1.State END)
,Zip1=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.zip,'''')='''' THEN AC_MAST1.zip ELSE SHIPTO1.zip END) ELSE AC_MAST1.zip END)
,i_tax1=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.i_tax,'''')='''' THEN AC_MAST1.i_tax ELSE SHIPTO1.i_tax END) ELSE AC_MAST1.i_tax END)
,GSTIN1=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.GSTIN,'''')='''' THEN AC_MAST1.GSTIN ELSE SHIPTO1.GSTIN END) ELSE AC_MAST1.GSTIN END)'

--	gstin1=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.gstin,'''')='''' THEN AC_MAST1.gstin ELSE SHIPTO1.gstin END) ELSE AC_MAST1.gstin END)
--state1=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.[state],'''')='''' THEN AC_MAST1.[state] ELSE SHIPTO1.[state] END) ELSE AC_MAST1.[state] END)
--supp_type1=(CASE WHEN PIMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.[supp_type],'''')='''' THEN AC_MAST1.[supp_type] ELSE SHIPTO1.[supp_type] END) ELSE AC_MAST1.[supp_type] END)
	
	SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''--ruchit
	SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+''
	--INTO #PIMAIN
	Set @Tot_flds=''
	SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM PIMAIN '
	SET @SQLCOMMAND =	@SQLCOMMAND+'INNER JOIN PIITEM ON (PIMAIN.TRAN_CD=PIITEM.TRAN_CD) 
	INNER JOIN IT_MAST ON (PIITEM.IT_CODE=IT_MAST.IT_CODE) 
	INNER JOIN AC_MAST ON (AC_MAST.AC_ID=PIMAIN.AC_ID) 
	INNER JOIN #PIMAIN ON (PIMAIN.TRAN_CD=#PIMAIN.TRAN_CD and PIMAIN.Entry_ty=#PIMAIN.entry_ty ) 
	LEFT JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_ID=PIMAIN.CONS_ID) 
	LEFT JOIN SHIPTO ON (SHIPTO.AC_ID=PIMAIN.Ac_id AND SHIPTO.Shipto_id=PIMAIN.sac_id)
		LEFT JOIN SHIPTO SHIPTO1 ON(SHIPTO1.AC_ID=PIMAIN.CONS_id AND SHIPTO1.Shipto_id =PIMAIN.scons_id)
	ORDER BY PIMAIN.INV_SR,PIMAIN.INV_NO'

	
	print @sqlcommand
	execute sp_executesql @sqlcommand
	
	--AND PIMAIN.TRAN_CD=@TRN
	--SET @MCHAPNO=' '
	--SET @MEIT_NAME=' '
	--DECLARE CUR_PIBILL CURSOR FOR SELECT DISTINCT CHAPNO FROM #PIMAIN
	--OPEN CUR_PIBILL 
	--FETCH NEXT FROM CUR_PIBILL INTO @CHAPNO
	--WHILE(@@FETCH_STATUS=0)
	--BEGIN
	--	SET @MCHAPNO=RTRIM(@MCHAPNO)+','+RTRIM(@CHAPNO)
	--	FETCH NEXT FROM CUR_PIBILL INTO @CHAPNO
	--END
	--CLOSE CUR_PIBILL
	--DEALLOCATE CUR_PIBILL
	
	--DECLARE CUR_PIBILL CURSOR FOR SELECT DISTINCT EIT_NAME FROM #PIMAIN
	--OPEN CUR_PIBILL 
	--FETCH NEXT FROM CUR_PIBILL INTO @EIT_NAME
	--WHILE(@@FETCH_STATUS=0)
	--BEGIN
	--	SET @MEIT_NAME=RTRIM(@MEIT_NAME)+','+RTRIM(@EIT_NAME)
	--	FETCH NEXT FROM CUR_PIBILL INTO @EIT_NAME
	--END
	--CLOSE CUR_PIBILL
	--DEALLOCATE CUR_PIBILL	
	
	--SET @MCHAPNO=CASE WHEN LEN(@MCHAPNO)>1 THEN SUBSTRING(@MCHAPNO,2,LEN(@MCHAPNO)-1) ELSE '' END
	--SET @MEIT_NAME=CASE WHEN LEN(@MEIT_NAME)>1 THEN SUBSTRING(@MEIT_NAME,2,LEN(@MEIT_NAME)-1) ELSE '' END
	--SELECT * 
	--,MCHAPNO=ISNULL(@MCHAPNO,'')
	--,MEIT_NAME=ISNULL(@MEIT_NAME,'')
	--FROM #PIMAIN
GO
