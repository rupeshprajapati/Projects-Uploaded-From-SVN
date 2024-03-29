DROP PROCEDURE [USP_REP_UB_BILL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Priyanka B.
-- Create date: 29/06/2017
-- Description:	This Stored procedure is useful to generate Self Invoice .
-- Remark: 
-- =============================================
CREATE PROCEDURE [USP_REP_UB_BILL]
	@ENTRYCOND NVARCHAR(254)
	AS

Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max)	
	SET @TBLCON=RTRIM(@ENTRYCOND)

declare @ITAddLess varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where att_file=0 and Entry_ty='UB' and code in( 'D','F')  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
--itemwise taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='UB'  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
--itemwise non taxable          
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='UB' /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)     

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='UB'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='UB'  FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='UB'  FOR XML PATH ('')), 1, 0, ''
               ),0)

Declare @Addtblnm Varchar(1000)
set @Addtblnm  =''
if Exists(Select Top 1 [Name] From SysObjects Where xType='U' and [Name]='StmainAdd')
Begin
	set @Addtblnm =' LEFT JOIN STMAINADD ON (STMAIN.TRAN_CD=STMAINADD.TRAN_CD) '
end

	Select Entry_ty,Tran_cd=0,Date,inv_no,itserial=space(6) Into #stmain from stmain Where 1=0
	Create NonClustered Index Idx_tmpStmain On #stmain (Entry_ty asc, Tran_cd Asc, Itserial asc)

		set @sqlcommand='Insert Into #stmain Select stmain.Entry_ty,stmain.Tran_cd,stmain.date,stmain.inv_no,stitem.itserial from stmain Inner Join stitem on (stmain.Entry_ty=stitem.Entry_ty and stmain.Tran_cd=stitem.Tran_cd) Where '+@TBLCON
		print @sqlcommand
		execute sp_executesql @sqlcommand

Declare @uom_desc as Varchar(100),@len int,@fld_nm varchar(10),@fld_desc Varchar(10),@stkl_qty Varchar(100)

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

Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15)

Select case when att_file=1 then (CASE WHEN RTRIM(TBL_NM)='STMAINADD' THEN 'STMAINADD.' ELSE 'STMAIN.' END )+RTRIM(FLD_NM) else 'STITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code='UB'
union all
Select case when att_file=1 then 'STMAIN.'+RTRIM(FLD_NM) else 'STITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty='UB'

	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,STMAIN.INV_SR,STMAIN.TRAN_CD,STMAIN.ENTRY_TY,STMAIN.INV_NO,STMAIN.DATE,STMAIN.U_TIMEP,STMAIN.U_TIMEP1 ,STMAIN.U_REMOVDT'
	SET @QueryString =@QueryString+',STMAIN.U_DELIVER,STMAIN.DUE_DT,STMAIN.U_CLDT,STMAIN.U_CHALNO,STMAIN.U_CHALDT,STMAIN.U_PONO,STMAIN.U_PODT,STMAIN.U_LRNO,STMAIN.U_LRDT,STMAIN.U_DELI,STMAIN.U_VEHNO,STITEM.GRO_AMT AS IT_GROAMT,STMAIN.GRO_AMT GRO_AMT1,STMAIN.TAX_NAME,STITEM.TAX_NAME AS IT_TAXNAME,STMAIN.TAXAMT,STITEM.TAXAMT AS IT_TAXAMT,STMAIN.NET_AMT,STITEM.U_PKNO'+@stkl_qty+',STITEM.RATE,STITEM.U_ASSEAMT,STITEM.U_MRPRATE,STITEM.U_EXPDESC,STITEM.U_APPACK,STITEM.PACKSIZE1, cast (STITEM.NARR AS VARCHAR(2000)) AS NARR,STITEM.TOT_EXAMT'
	SET @QueryString =@QueryString+',IT_MAST.IT_NAME,IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.IDMARK,IT_MAST.RATEUNIT,IT_MAST.HSNCODE,IT_mast.U_ITPARTCD,stitem.item_no'
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
	SET @QueryString =@QueryString+',STITEM.ITSERIAL,item_fdisc=stitem.tot_fdisc'
	SET @QueryString =@QueryString+',STMAIN.ctdsamt,STMAIN.stdsamt,STMAIN.itdsamt,Stitem.Tariff,STMAIN.roundoff'
	SET @QueryString =@QueryString+',STITEM.CGST_PER,STITEM.CGST_AMT,STITEM.SGST_PER,STITEM.SGST_AMT,STITEM.IGST_PER,STITEM.IGST_AMT'
	SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''
	SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+''

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

SET @SQLCOMMAND=''
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM STMAIN' 
print @sqlcommand
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD AND STMAIN.ENTRY_TY=STITEM.ENTRY_TY)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN #stmain ON (STITEM.TRAN_CD=#stmain.TRAN_CD and STITEM.Entry_ty=#stmain.entry_ty and STITEM.ITSERIAL=#stmain.itserial) '
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=STMAIN.AC_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+CASE WHEN @Addtblnm<>'' THEN @Addtblnm ELSE '' END
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S1 ON (STMAIN.AC_ID=S1.AC_ID AND STMAIN.SAC_ID=S1.SHIPTO_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S2 ON (STMAIN.CONS_ID=S2.AC_ID AND STMAIN.SCONS_ID=S2.SHIPTO_ID)'
SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY STMAIN.INV_SR,STMAIN.INV_NO'
print @SQLCOMMAND
execute sp_executesql @SQLCOMMAND
GO
