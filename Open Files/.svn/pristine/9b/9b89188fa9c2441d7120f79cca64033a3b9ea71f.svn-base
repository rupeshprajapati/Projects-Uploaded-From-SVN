if EXISTS(SELECT [NAME] FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='USP_REP_FS_BILL')
BEGIN
	DROP PROCEDURE [USP_REP_FS_BILL]
END
GO

CREATE PROCEDURE [USP_REP_FS_BILL]
	@ENTRYCOND NVARCHAR(254)
	AS

Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250)
	
	SET @TBLCON=RTRIM(@ENTRYCOND)
			Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
			Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)


		select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact

declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where att_file=0 and Entry_ty='FS' and code in( 'D','F')  FOR XML PATH ('')), 1, 0, ''
               ),0)

               
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='FS'  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
 SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='FS' and fld_nm not in ('Compcess') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)   
             
--itemwise non tax

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='FS'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='FS'  FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='FS'  FOR XML PATH ('')), 1, 0, ''
               ),0)

Declare @Addtblnm Varchar(1000)
set @Addtblnm  =''
if Exists(Select Top 1 [Name] From SysObjects Where xType='U' and [Name]='StmainAdd')
Begin
	set @Addtblnm =' LEFT JOIN STMAINADD ON (STMAIN.TRAN_CD=STMAINADD.TRAN_CD) '
end

Declare @sta_dt datetime, @end_dt datetime 
set @SQLCOMMAND1='select top 1 @sta_dt=sta_dt,@end_dt=end_dt from vudyog..co_mast where dbname=db_name() and ( select top 1 stmain.date  from stmain inner join stitem on (stmain.tran_cd=stitem.tran_cd) where '+@TBLCON+' ) between sta_dt and end_dt '	
set @ParmDefinition =N' @sta_dt datetime Output, @end_dt datetime Output'
EXECUTE sp_executesql @SQLCOMMAND1,@ParmDefinition,@sta_dt=@sta_dt Output, @end_dt=@end_dt Output

	Select Entry_ty,Tran_cd=0,Date,inv_no,itserial=space(6) Into #stmain from stmain Where 1=0
	Create NonClustered Index Idx_tmpStmain On #stmain (Entry_ty asc, Tran_cd Asc, Itserial asc)

		set @sqlcommand='Insert Into #stmain Select stmain.Entry_ty,stmain.Tran_cd,stmain.date,stmain.inv_no,stitem.itserial from stmain Inner Join stitem on (stmain.Entry_ty=stitem.Entry_ty and stmain.Tran_cd=stitem.Tran_cd) Where '+@TBLCON
		print @sqlcommand
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

Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15),@tempsql varchar(50)
Select case when att_file=1 then (CASE WHEN RTRIM(TBL_NM)='STMAINADD' THEN 'STMAINADD.' ELSE 'STMAIN.' END )+RTRIM(FLD_NM) else 'STITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code='FS'
union all
Select case when att_file=1 then 'STMAIN.'+RTRIM(FLD_NM) else 'STITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty='FS'

	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,STMAIN.INV_SR,STMAIN.TRAN_CD,STMAIN.ENTRY_TY,STMAIN.INV_NO,STMAIN.DATE,STMAIN.U_TIMEP,STMAIN.U_TIMEP1 ,STMAIN.U_REMOVDT'
	SET @QueryString =@QueryString+',STMAIN.U_DELIVER,STMAIN.DUE_DT,STMAIN.U_CLDT,STMAIN.U_CHALNO,STMAIN.U_CHALDT,STMAIN.U_PONO,STMAIN.U_PODT,STMAIN.U_LRNO,STMAIN.U_LRDT,STMAIN.U_DELI,STMAIN.U_VEHNO
		,(CASE WHEN STMAIN.EXPOTYPE<>'''' THEN (STITEM.GRO_AMT - STITEM.IGST_AMT) ELSE STITEM.GRO_AMT END) AS IT_GROAMT,STMAIN.EXPOTYPE
	,STMAIN.GRO_AMT GRO_AMT1,STMAIN.TAX_NAME,STITEM.TAX_NAME AS IT_TAXNAME,STMAIN.TAXAMT,STITEM.TAXAMT AS IT_TAXAMT
	,(CASE WHEN STMAIN.EXPOTYPE<>'''' THEN (STMAIN.NET_AMT - STMAIN.IGST_AMT) ELSE STMAIN.NET_AMT END) AS NET_AMT
	,STITEM.U_PKNO'+@stkl_qty+',STITEM.RATE,STITEM.U_ASSEAMT,STITEM.U_MRPRATE,STITEM.U_EXPDESC,STITEM.U_APPACK,STITEM.PACKSIZE1, cast (STITEM.NARR AS VARCHAR(2000)) AS NARR,STITEM.TOT_EXAMT'
	SET @QueryString =@QueryString+',IT_MAST.IT_NAME,IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.IDMARK,IT_MAST.RATEUNIT
	,HSNCODE = (CASE WHEN ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END)
	,IT_mast.U_ITPARTCD,stitem.item_no'
	SET @QueryString =@QueryString+',It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)'
	SET @QueryString =@QueryString+',MailName=(CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)'
	SET @QueryString =@QueryString+',SAC_NAME=(CASE WHEN ISNULL(S1.MailName,'''')='''' THEN (CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)  ELSE S1.mailname END)'
	SET @QueryString =@QueryString+',SADD1=CASE WHEN STMAIN.SAC_ID >0 THEN S1.ADD1 ELSE AC_MAST.ADD1 END'
	SET @QueryString =@QueryString+',SADD2=CASE WHEN STMAIN.SAC_ID >0 THEN S1.ADD2 ELSE AC_MAST.ADD2 END'
	SET @QueryString =@QueryString+',SADD3=CASE WHEN STMAIN.SAC_ID >0 THEN S1.ADD3 ELSE AC_MAST.ADD3 END'
	SET @QueryString =@QueryString+',SCITY=CASE WHEN STMAIN.SAC_ID >0 THEN S1.CITY ELSE AC_MAST.CITY END'
	SET @QueryString =@QueryString+',SSTATE=CASE WHEN STMAIN.SAC_ID >0 THEN S1.STATE ELSE AC_MAST.STATE END'
	SET @QueryString =@QueryString+',SZIP=CASE WHEN STMAIN.SAC_ID >0 THEN S1.ZIP ELSE AC_MAST.ZIP END'
	SET @QueryString =@QueryString+',SPHONE=CASE WHEN STMAIN.SAC_ID >0 THEN S1.PHONE ELSE AC_MAST.PHONE END'
	SET @QueryString =@QueryString+',SUNIQUEID=CASE WHEN STMAIN.SAC_ID >0 THEN (CASE WHEN S1.UID<>'''' THEN S1.UID ELSE S1.GSTIN END) ELSE (CASE WHEN AC_MAST.UID<>'''' THEN AC_MAST.UID ELSE AC_MAST.GSTIN END) END'
	SET @QueryString =@QueryString+',SSTATECODE=(SELECT TOP 1 GST_STATE_CODE FROM STATE WHERE STATE=CASE WHEN STMAIN.SAC_ID >0 THEN S1.STATE ELSE AC_MAST.STATE END)'	
	SET @QueryString =@QueryString+',SCOUNTRY=CASE WHEN STMAIN.SAC_ID >0 THEN S1.COUNTRY ELSE AC_MAST.COUNTRY END'
	SET @QueryString =@QueryString+',CAC_NAME=(CASE WHEN ISNULL(S2.MailName,'''')='''' THEN (CASE WHEN ISNULL(ac.MailName,'''')='''' THEN ac.ac_name ELSE ac.mailname END)  ELSE S2.mailname END)'
	SET @QueryString =@QueryString+',CADD1=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.ADD1 ELSE AC.ADD1 END'
	SET @QueryString =@QueryString+',CADD2=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.ADD2 ELSE AC.ADD2 END'
	SET @QueryString =@QueryString+',CADD3=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.ADD3 ELSE AC.ADD3 END'
	SET @QueryString =@QueryString+',CCITY=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.CITY ELSE AC.CITY END'
	SET @QueryString =@QueryString+',CSTATE=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.STATE ELSE AC.STATE END'
	SET @QueryString =@QueryString+',CZIP=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.ZIP ELSE AC.ZIP END'
	SET @QueryString =@QueryString+',CPHONE=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.PHONE ELSE AC.PHONE END'
	SET @QueryString =@QueryString+',CUNIQUEID=CASE WHEN STMAIN.SCONS_ID >0 THEN (CASE WHEN S2.UID<>'''' THEN S2.UID ELSE S2.GSTIN END) ELSE (CASE WHEN AC.UID<>'''' THEN AC.UID ELSE AC.GSTIN END) END'	
	SET @QueryString =@QueryString+',CSTATECODE=(SELECT TOP 1 GST_STATE_CODE FROM STATE WHERE STATE=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.STATE ELSE AC.STATE END)'	
	SET @QueryString =@QueryString+',CCOUNTRY=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.COUNTRY ELSE AC.COUNTRY END'
	SET @QueryString =@QueryString+',GSTSTATE,ST_TYPE=CASE WHEN STMAIN.SCONS_ID >0 THEN S2.ST_TYPE ELSE AC.ST_TYPE END'
	SET @QueryString =@QueryString+',STITEM.ITSERIAL,item_fdisc=stitem.tot_fdisc'
	SET @QueryString =@QueryString+',STMAIN.ctdsamt,STMAIN.stdsamt,STMAIN.itdsamt,Stitem.Tariff,STMAIN.roundoff'
	SET @QueryString =@QueryString+',STITEM.CGST_PER,STITEM.CGST_AMT,STITEM.SGST_PER,STITEM.SGST_AMT,STITEM.IGST_PER,STITEM.IGST_AMT'
	SET @QueryString =@QueryString+',STITEM.Compcess,stitem.CCESSRATE'
	SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''
	SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+''
	
print 'demo'
print @QueryString


set @Tot_flds =''

Declare addi_flds cursor for
Select flds,fld_nm,att_file,data_ty from #tmpFlds
Open addi_flds
Fetch Next from addi_flds Into @fld,@fld_nm1,@att_file,@fld_type
While @@Fetch_Status=0
Begin
	if  charindex(@fld,@QueryString)=0
	begin
		if  charindex(@fld_type,'text')<>0
			begin
			 Set @Tot_flds=@Tot_flds+','+'CONVERT(VARCHAR(500),'+@fld+') AS '+substring(@fld,charindex('.',@fld)+1,len(@fld))  
			end
		else
		begin
			Set @Tot_flds=@Tot_flds+','+@fld   
		end
	End
	Fetch Next from addi_flds Into @fld,@fld_nm1,@att_file,@fld_type 
End
Close addi_flds 
Deallocate addi_flds 
declare @sql as nvarchar(max)
set @sql= cAST(REPLICATE(@Tot_flds,4000) as nvarchar(100))

Declare @soBarcode Bit,@sobarcodeflist Varchar(1000),@SOHdrbarcode Varchar(20),@SODdrbarcode Varchar(20)
if Exists(Select * from BARCODEMAST Where Entry_ty='SO')
	Begin
		select @soBarcode =1,@SOHdrbarcode = isnull(STUFF(
                 (SELECT  ','+ltrim(rtrim(tbl_nm1))+'.'+ltrim(rtrim(fld_nm1)) FROM BARCODEMAST where Entry_ty='SO' and BC_HD='H' FOR XML PATH ('')), 1, 0, ''
               ),'')
               ,@SODdrbarcode = isnull(STUFF(
                 (SELECT  ','+ltrim(rtrim(tbl_nm1))+'.'+ltrim(rtrim(fld_nm1)) FROM BARCODEMAST where Entry_ty='SO' and BC_HD='D' FOR XML PATH ('')), 1, 0, ''
               ),'')
               ,@sobarcodeflist=isnull(STUFF(
                 (SELECT  ','+ltrim(rtrim(tbl_nm1))+'.'+ltrim(rtrim(fld_nm1))+' AS '+Entry_ty+ltrim(rtrim(fld_nm1)) FROM BARCODEMAST where Entry_ty='SO'  FOR XML PATH ('')), 1, 0, ''
               ),'')
	End	
ELSE
	SELECT @soBarcode =0
	
 IF @soBarcode =1
 Begin
	set @Tot_flds=@Tot_flds+ ' '+@sobarcodeflist
 end


print 'demo1'
PRINT @Addtblnm
SET @SQLCOMMAND=''
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM STMAIN' 
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD AND STMAIN.ENTRY_TY=STITEM.ENTRY_TY)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN #stmain ON (STITEM.TRAN_CD=#stmain.TRAN_CD and STITEM.Entry_ty=#stmain.entry_ty and STITEM.ITSERIAL=#stmain.itserial) '
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+CASE WHEN @Addtblnm<>'' THEN @Addtblnm ELSE '' END
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST AC ON (AC.AC_ID=STMAIN.CONS_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S1 ON (STMAIN.AC_ID=S1.AC_ID AND STMAIN.SAC_ID=S1.SHIPTO_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S2 ON (STMAIN.CONS_ID=S2.AC_ID AND STMAIN.SCONS_ID=S2.SHIPTO_ID)'
 
 IF @soBarcode =1
 Begin
	SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN STITREF SOREF ON (SOREF.ENTRY_TY=STMAIN.ENTRY_TY AND SOREF.TRAN_CD=STMAIN.TRAN_CD AND SOREF.ITSERIAL=STITEM.ITSERIAL)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN (SELECT ENTRY_TY,TRAN_CD,ITSERIAL'+@SODdrbarcode+' FROM SOITEM) SOITEM ON (SOREF.RENTRY_TY=SOITEM.ENTRY_TY AND SOREF.ITREF_TRAN=SOITEM.TRAN_CD AND SOREF.RITSERIAL=SOITEM.ITSERIAL)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN (SELECT ENTRY_TY,TRAN_CD'+@SOHdrbarcode+' FROM SOMAIN) SOMAIN ON (SOITEM.ENTRY_TY=SOMAIN.ENTRY_TY AND SOITEM.TRAN_CD=SOMAIN.TRAN_CD)' 
 End
 
SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY STMAIN.INV_SR,STMAIN.INV_NO'
execute sp_executesql @SQLCOMMAND
print @SQLCOMMAND
GO
