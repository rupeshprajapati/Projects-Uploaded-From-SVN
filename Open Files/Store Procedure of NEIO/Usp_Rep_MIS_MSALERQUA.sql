If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Rep_MIS_MSALERQUA')
Begin
	Drop Procedure Usp_Rep_MIS_MSALERQUA
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Rep_MIS_MSALERQUA]    Script Date: 2019-05-03 16:34:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Created By Prajakta B. on 14062019
CREATE PROCEDURE [dbo].[Usp_Rep_MIS_MSALERQUA] 
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
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where att_file=0 and Entry_ty='SQ' and code in( 'D','F')  FOR XML PATH ('')), 1, 0, ''
               ),0)               
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='SQ'  FOR XML PATH ('')), 1, 0, ''
               ),0)
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='SQ' and fld_nm not in ('Compcess') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)   
             
--itemwise non tax

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='SQ'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='SQ'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='SQ'  FOR XML PATH ('')), 1, 0, ''
               ),0)


Declare @Addtblnm Varchar(1000)
set @Addtblnm  =''
if Exists(Select Top 1 [Name] From SysObjects Where xType='U' and [Name]='SQMAINAdd')
Begin
	set @Addtblnm =' LEFT JOIN SQMAINADD ON (SQMAIN.TRAN_CD=SQMAINADD.TRAN_CD) '
end	
		
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
		set @stkl_qty= @stkl_qty +', '+'SQITEM.'+@fld_nm

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
	set @stkl_qty=',SQITEM.QTY'
End

Declare @QueryString NVarchar(max)

	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,SQMAIN.INV_SR,SQMAIN.TRAN_CD,SQMAIN.ENTRY_TY,SQMAIN.INV_NO,SQMAIN.DATE,sqitem.qty'
	SET @QueryString =@QueryString+',SQITEM.GRO_AMT AS IT_GROAMT,SQMAIN.GRO_AMT GRO_AMT1,SQMAIN.NET_AMT,SQITEM.RATE,SQITEM.U_ASSEAMT, cast (SQITEM.NARR AS VARCHAR(2000)) AS NARR'
	SET @QueryString =@QueryString+',IT_MAST.CHAPNO	,HSNCODE = (CASE WHEN ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END),SQITEM.item_no'
	SET @QueryString =@QueryString+',It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)'
	SET @QueryString =@QueryString+',MailName=(CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)'
	SET @QueryString =@QueryString+',SAC_NAME=(CASE WHEN ISNULL(S1.MailName,'''')='''' THEN (CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)  ELSE S1.mailname END)'
	SET @QueryString =@QueryString+',CAC_NAME=(CASE WHEN ISNULL(S2.MailName,'''')='''' THEN (CASE WHEN ISNULL(ac.MailName,'''')='''' THEN ac.ac_name ELSE ac.mailname END)  ELSE S2.mailname END)'
	SET @QueryString =@QueryString+',ST_TYPE=CASE WHEN SQMAIN.SCONS_ID >0 THEN S2.ST_TYPE ELSE AC.ST_TYPE END'			
	SET @QueryString =@QueryString+',SQITEM.ITSERIAL,SQITREF.RDATE,SQITREF.RINV_NO'
	SET @QueryString =@QueryString+',SQITEM.CGST_PER,SQITEM.CGST_AMT,SQITEM.SGST_PER,SQITEM.SGST_AMT,SQITEM.IGST_PER,SQITEM.IGST_AMT'
	SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''
	SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+''
	SET @QueryString =@QueryString+',SQMAIN.Party_nm,ac_mast.GSTIN,ac_mast.State,SQITEM.item,SQITEM.stkunit,Total=SQITEM.rate*SQITEM.qty'
	SET @QueryString =@QueryString+',TotalGST=SQITEM.CGST_AMT+SQITEM.SGST_AMT+SQITEM.IGST_AMT'

SET @SQLCOMMAND=''
SET @SQLCOMMAND = N''+@QueryString+''+' into '+'##main11'+' FROM SQMAIN' 


 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN SQITEM ON (SQMAIN.TRAN_CD=SQITEM.TRAN_CD AND SQMAIN.ENTRY_TY=SQITEM.ENTRY_TY)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN IT_MAST ON (SQITEM.IT_CODE=IT_MAST.IT_CODE)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=SQMAIN.AC_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SQITREF ON SQITEM.ENTRY_TY=SQITREF.ENTRY_TY AND SQITEM.TRAN_CD=SQITREF.TRAN_CD AND SQITEM.ITSERIAL=SQITREF.ITSERIAL'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST AC ON (AC.AC_ID=SQMAIN.CONS_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S1 ON (SQMAIN.AC_ID=S1.AC_ID AND SQMAIN.SAC_ID=S1.SHIPTO_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S2 ON (SQMAIN.CONS_ID=S2.AC_ID AND SQMAIN.SCONS_ID=S2.SHIPTO_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+'WHERE (SQMAIN.date BETWEEN '+CHAR(39)+cast(@FrmDate as varchar)+CHAR(39)+'  AND '+CHAR(39)+cast(@Todate as varchar )+CHAR(39)+') and (SQMAIN.Party_nm BETWEEN '+CHAR(39)+@FParty+CHAR(39)+' AND '+CHAR(39)+@TParty+CHAR(39)+')'
 SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY SQMAIN.INV_SR,SQMAIN.INV_NO'
 print @sqlcommand
execute sp_executesql @SQLCOMMAND

SET @SQLCOMMAND ='select Date,RDATE,inv_no,RINV_NO,Party_nm,GSTIN,State,st_type,item,HSNCODE,qty,stkunit,rate,Total,u_asseamt,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,TotalGST,IT_GROAMT,net_amt from ##main11'
execute sp_executesql @SQLCOMMAND
drop table ##main11





