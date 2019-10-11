If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_DF_BILL')
Begin
	Drop Procedure USP_REP_DF_BILL
End
GO
/****** Object:  StoredProcedure [dbo].[USP_REP_DF_BILL]    Script Date: 10/08/2018 16:43:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[USP_REP_DF_BILL]
	@ENTRYCOND NVARCHAR(254)
	AS

Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250)
	
	SET @TBLCON=RTRIM(@ENTRYCOND)
			Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
			Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)

	Select Entry_ty,Tran_cd=0 Into #DCMAIN from DCMAIN Where 1=0
	set @sqlcommand='Insert Into #DCMAIN Select DCMAIN.Entry_ty,DCMAIN.Tran_cd from DCMAIN Where '+@TBLCON
		print @sqlcommand
		execute sp_executesql @sqlcommand
		
		select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact

declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where code in( 'D','F') and att_file=0 and Entry_ty='DF'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='DF'  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='DF' and fld_nm not in ('Compcess') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)   
          
--itemwise non tax

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='DF'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='DF'  FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='DF'  FOR XML PATH ('')), 1, 0, ''
               ),0)

Declare @sta_dt datetime, @end_dt datetime 
set @SQLCOMMAND1='select top 1 @sta_dt=sta_dt,@end_dt=end_dt from vudyog..co_mast where dbname=db_name() and ( select top 1 DCMAIN.date  from DCMAIN inner join dcitem on (DCMAIN.tran_cd=dcitem.tran_cd) where '+@TBLCON+' ) between sta_dt and end_dt '	
set @ParmDefinition =N' @sta_dt datetime Output, @end_dt datetime Output'
EXECUTE sp_executesql @SQLCOMMAND1,@ParmDefinition,@sta_dt=@sta_dt Output, @end_dt=@end_dt Output


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
		set @stkl_qty= @stkl_qty +', '+'dcitem.'+@fld_nm

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
	set @stkl_qty=',dcitem.QTY'
End

Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15),@tempsql varchar(50)
Select case when att_file=1 then 'DCMAIN.'+RTRIM(FLD_NM) else 'dcitem.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code='DF'
union all
Select case when att_file=1 then 'DCMAIN.'+RTRIM(FLD_NM) else 'dcitem.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty='DF'

SET @QueryString =
'Select AC_NAME=(CASE WHEN DCMAIN.sac_id> 0 THEN SHIPTO.MAILNAME ELSE AC_MAST.AC_NAME END)
,ADD1=(CASE WHEN DCMAIN.sac_id> 0 THEN SHIPTO.ADD1 ELSE AC_MAST.ADD1 END)
,ADD2=(CASE WHEN DCMAIN.sac_id> 0 THEN SHIPTO.ADD2 ELSE AC_MAST.ADD2 END)
,ADD3=(CASE WHEN DCMAIN.sac_id> 0 THEN SHIPTO.ADD3 ELSE AC_MAST.ADD3 END)
,City=(CASE WHEN DCMAIN.sac_id> 0 THEN SHIPTO.city ELSE AC_MAST.city END)
,Zip=(CASE WHEN DCMAIN.sac_id> 0 THEN SHIPTO.zip ELSE AC_MAST.zip END)
,GSTIN=(CASE WHEN DCMAIN.sac_id> 0 THEN SHIPTO.GSTIN ELSE AC_MAST.GSTIN END)
,state=(CASE WHEN DCMAIN.sac_id> 0 THEN SHIPTO.STATE ELSE AC_MAST.STATE END)
,STATECODE=(CASE WHEN DCMAIN.sac_id> 0 THEN SHIPTO.STATECODE ELSE AC_MAST.STATECODE END)

,DCMAIN.TRAN_CD,DCMAIN.INV_NO,DCMAIN.DATE,cast (DCMAIN.NARR AS VARCHAR(2000)) AS NARR,DCMAIN.ROUNDOFF,DCMAIN.U_DELI,
DCMAIN.GRO_AMT AS V_GRO_AMT,DCMAIN.TAX_NAME,DCMAIN.TAXAMT,DCMAIN.TOT_DEDUC,DCMAIN.TOT_ADD,DCMAIN.TOT_TAX,DCMAIN.TOT_NONTAX,DCMAIN.U_VEHNO,DCMAIN.U_LRNO,DCMAIN.U_LRDT,DCMAIN.U_TMODE,
DCMAIN.NET_AMT,DCITEM.ITEM_NO,DCITEM.ITEM,DCITEM.QTY,DCITEM.RATE,DCITEM.GRO_AMT,IT_MAST.RATEUNIT,dcmain.CGST_AMT,dcmain.SGST_AMT,DCITEM.U_ASSEAMT,IT_MAST.HSNCODE,cast (DCITEM.NARR AS VARCHAR(2000)) AS iTNARR,
DCMAIN.IGST_AMT,It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END),
MailName=(CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.ac_name ELSE SHIPTO.mailname END)
,U_DELIVER=(CASE WHEN DCMAIN.sCONS_id> 0 THEN SHIPTO1.MAILNAME ELSE AC_MAST1.AC_NAME END)
,ADD11=(CASE WHEN DCMAIN.sCONS_id> 0 THEN  SHIPTO1.ADD1 ELSE AC_MAST1.ADD1 END)
,ADD22=(CASE WHEN DCMAIN.sCONS_id> 0 THEN SHIPTO1.ADD2 ELSE AC_MAST1.ADD2 END)
,ADD33=(CASE WHEN DCMAIN.sCONS_id> 0 THEN SHIPTO1.ADD3 ELSE AC_MAST1.ADD3 END)
,City1=(CASE WHEN DCMAIN.sCONS_id> 0 THEN SHIPTO1.city ELSE AC_MAST1.city END)
,Zip1=(CASE WHEN DCMAIN.sCONS_id> 0 THEN SHIPTO1.zip ELSE AC_MAST1.zip END)
,GSTIN1=(CASE WHEN DCMAIN.sCONS_id> 0 THEN SHIPTO1.GSTIN ELSE AC_MAST1.GSTIN END)
,STATE1=(CASE WHEN DCMAIN.sCONS_id> 0 THEN SHIPTO1.STATE ELSE AC_MAST1.STATE END)
,STATECODE1=(CASE WHEN DCMAIN.sCONS_id> 0 THEN SHIPTO1.STATECODE ELSE AC_MAST1.STATECODE END)
 ,Dcitem.compcess'
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
declare @sql as nvarchar(max)
set @sql= cAST(REPLICATE(@Tot_flds,4000) as nvarchar(100))
set @Tot_flds =''
SET @SQLCOMMAND=''
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM DCMAIN ' 
SET @SQLCOMMAND= @SQLCOMMAND+' INNER JOIN DCITEM ON DCMAIN.TRAN_CD=DCITEM.TRAN_CD LEFT JOIN IT_MAST ON IT_MAST.IT_CODE=DCITEM.IT_CODE INNER JOIN AC_MAST ON DCMAIN.AC_ID=AC_MAST.AC_ID INNER JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_ID=DCMAIN.CONS_ID) LEFT JOIN SHIPTO ON (SHIPTO.AC_ID=DCMAIN.Ac_id AND SHIPTO.Shipto_id=DCMAIN.sac_id) LEFT JOIN SHIPTO SHIPTO1 ON(SHIPTO1.AC_ID=DCMAIN.CONS_id AND SHIPTO1.Shipto_id =DCMAIN.scons_id)'
SET @SQLCOMMAND= @SQLCOMMAND+' INNER JOIN #DCMAIN ON (DCMAIN.TRAN_CD=#DCMAIN.TRAN_CD and DCMAIN.Entry_ty=#DCMAIN.entry_ty )' 

execute sp_executesql @sqlcommand