If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Rep_MIS_MSALERENQ')
Begin
	Drop Procedure Usp_Rep_MIS_MSALERENQ
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Rep_MIS_MSALERENQ]    Script Date: 2019-05-03 16:34:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Created By Prajakta B. on 14062019
Create PROCEDURE [dbo].[Usp_Rep_MIS_MSALERENQ] 
	(@FrmDate SMALLDATETIME,@Todate SMALLDATETIME,@FParty nvarchar(100),@TParty nvarchar(100)) 	
	AS
Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),
		@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),
		@mchapno varchar(250),@meit_name  varchar(250)
Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),
		@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)
select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact
declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where att_file=0 and Entry_ty='EQ' and code in( 'D','F')  FOR XML PATH ('')), 1, 0, ''
               ),0)               
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='EQ'  FOR XML PATH ('')), 1, 0, ''
                 --(select case when fld_nm<>'' then '+'+fld_nm else ''  end from dcmast where code='T' and att_file=0 and entry_ty='ST' and bef_aft=2  FOR XML PATH ('')), 1, 0, ''
               ),0)
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='EQ' and fld_nm not in ('Compcess') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)   
             
--itemwise non tax

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='EQ'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='EQ'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='EQ'  FOR XML PATH ('')), 1, 0, ''
               ),0)
		
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
		set @stkl_qty= @stkl_qty +', '+'EQITEM.'+@fld_nm

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
	set @stkl_qty=',EQITEM.QTY'
End

Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds nVarchar(max),@QueryString NVarchar(max),@fld_type  varchar(15),@tempsql varchar(50)

	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,EQMAIN.INV_SR,EQMAIN.TRAN_CD,EQMAIN.ENTRY_TY,EQMAIN.INV_NO,EQMAIN.DATE,eqitem.qty'
	SET @QueryString =@QueryString+',EQITEM.GRO_AMT AS IT_GROAMT,EQMAIN.NET_AMT,EQITEM.RATE,EQITEM.U_ASSEAMT, cast (eqmain.NARR AS VARCHAR(2000)) AS NARR'
	SET @QueryString =@QueryString+',IT_MAST.IT_NAME,HSNCODE = (CASE WHEN ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END),EQITEM.item_no'
	SET @QueryString =@QueryString+',It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)'
	SET @QueryString =@QueryString+',SAC_NAME=(CASE WHEN ISNULL(S1.MailName,'''')='''' THEN (CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)  ELSE S1.mailname END)'
	SET @QueryString =@QueryString+',SADD1=CASE WHEN EQMAIN.SAC_ID >0 THEN S1.ADD1 ELSE AC_MAST.ADD1 END'
	SET @QueryString =@QueryString+',SADD2=CASE WHEN EQMAIN.SAC_ID >0 THEN S1.ADD2 ELSE AC_MAST.ADD2 END'
	SET @QueryString =@QueryString+',SADD3=CASE WHEN EQMAIN.SAC_ID >0 THEN S1.ADD3 ELSE AC_MAST.ADD3 END'
	SET @QueryString =@QueryString+',SCITY=CASE WHEN EQMAIN.SAC_ID >0 THEN S1.CITY ELSE AC_MAST.CITY END'
	SET @QueryString =@QueryString+',SSTATE=CASE WHEN EQMAIN.SAC_ID >0 THEN S1.STATE ELSE AC_MAST.STATE END'
	SET @QueryString =@QueryString+',SZIP=CASE WHEN EQMAIN.SAC_ID >0 THEN S1.ZIP ELSE AC_MAST.ZIP END'
	SET @QueryString =@QueryString+',SPHONE=CASE WHEN EQMAIN.SAC_ID >0 THEN S1.PHONE ELSE AC_MAST.PHONE END'
	SET @QueryString =@QueryString+',SUNIQUEID=CASE WHEN EQMAIN.SAC_ID >0 THEN (CASE WHEN S1.UID<>'''' THEN S1.UID ELSE S1.GSTIN END) ELSE (CASE WHEN AC_MAST.UID<>'''' THEN AC_MAST.UID ELSE AC_MAST.GSTIN END) END'
	SET @QueryString =@QueryString+',SSTATECODE=(SELECT TOP 1 GST_STATE_CODE FROM STATE WHERE STATE=CASE WHEN EQMAIN.SAC_ID >0 THEN S1.STATE ELSE AC_MAST.STATE END)'	
	SET @QueryString =@QueryString+',SCOUNTRY=CASE WHEN EQMAIN.SAC_ID >0 THEN S1.COUNTRY ELSE AC_MAST.COUNTRY END'			
	SET @QueryString =@QueryString+',EQITEM.ITSERIAL,EQITEM.CGST_PER,EQITEM.CGST_AMT,EQITEM.SGST_PER,EQITEM.SGST_AMT,EQITEM.IGST_PER,EQITEM.IGST_AMT'
	SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''
	SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+''

set @Tot_flds =''


declare @sql as nvarchar(max)
set @sql= cAST(REPLICATE(@Tot_flds,4000) as nvarchar(100))

SET @SQLCOMMAND=''
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' into '+'##main11'+' FROM EQMAIN' 


 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN EQITEM ON (EQMAIN.TRAN_CD=EQITEM.TRAN_CD AND EQMAIN.ENTRY_TY=EQITEM.ENTRY_TY)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN IT_MAST ON (EQITEM.IT_CODE=IT_MAST.IT_CODE)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=EQMAIN.AC_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S1 ON (EQMAIN.AC_ID=S1.AC_ID AND EQMAIN.SAC_ID=S1.SHIPTO_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+'WHERE (EQMAIN.date BETWEEN '+CHAR(39)+cast(@FrmDate as varchar)+CHAR(39)+'  AND '+CHAR(39)+cast(@Todate as varchar )+CHAR(39)+') and (EQMAIN.Party_nm BETWEEN '+CHAR(39)+@FParty+CHAR(39)+' AND '+CHAR(39)+@TParty+CHAR(39)+')'
 SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY EQMAIN.INV_SR,EQMAIN.INV_NO'
 print @sqlcommand
execute sp_executesql @SQLCOMMAND

SET @SQLCOMMAND ='select Date,SAC_NAME,inv_no,IT_NAME,HSNCODE,qty,rate,u_asseamt,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,net_amt,NARR from ##main11'
execute sp_executesql @SQLCOMMAND
drop table ##main11





