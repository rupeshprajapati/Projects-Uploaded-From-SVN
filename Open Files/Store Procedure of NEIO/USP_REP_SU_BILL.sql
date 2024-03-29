If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_SU_BILL')
Begin
	Drop Procedure USP_REP_SU_BILL
End
GO
/****** Object:  StoredProcedure [dbo].[USP_REP_SU_BILL]    Script Date: 11/29/2018 17:48:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXECUTE USP_REP_SU_BILL "SRMAIN.Entry_ty = 'SU' And SRMAIN.Tran_cd = 1"
-- =============================================
-- Author	  :	Ruchit Shah
-- Create date: 02/12/2016
-- Description:	This Stored procedure is useful to generate Sales Order Invoice .
-- Remark: 
-- =============================================

create PROCEDURE [dbo].[USP_REP_SU_BILL]
	@ENTRYCOND NVARCHAR(254)
	AS

Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250)
	
	SET @TBLCON=RTRIM(@ENTRYCOND)
			Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
			Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)

	Select Entry_ty,Tran_cd=0 Into #SRMAIN from SRMAIN Where 1=0
	set @sqlcommand='Insert Into #SRMAIN Select SRMAIN.Entry_ty,SRMAIN.Tran_cd from SRMAIN Where '+@TBLCON
		print @sqlcommand
		execute sp_executesql @sqlcommand

		select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact

--ruchit

declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where code in( 'D','F') and att_file=0 and Entry_ty='SU'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='SU'  FOR XML PATH ('')), 1, 0, ''
                 --(select case when fld_nm<>'' then '+'+fld_nm else ''  end from dcmast where code='T' and att_file=0 and entry_ty='SU' and bef_aft=2  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
               
                
--Commented By Prajakta B. on 28082017               
--SELECT 
--    @ItemNTX = isnull(STUFF(
--                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='SU' /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
--               ),0)     
           
 --Modified By Prajakta B. on 28082017   
 SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='SU' and fld_nm not in ('Compcess') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)  

--itemwise non tax

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='SU'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='SU'  FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='SU'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--ruchit


Declare @sta_dt datetime, @end_dt datetime 
set @SQLCOMMAND1='select top 1 @sta_dt=sta_dt,@end_dt=end_dt from vudyog..co_mast where dbname=db_name() and ( select top 1 srmain.date  from srmain inner join sritem on (srmain.tran_cd=sritem.tran_cd) where '+@TBLCON+' ) between sta_dt and end_dt '	
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
		set @stkl_qty= @stkl_qty +', '+'sritem.'+@fld_nm

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
	set @stkl_qty=',sritem.QTY'
End

Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15),@tempsql varchar(50)
Select case when att_file=1 then 'srmain.'+RTRIM(FLD_NM) else 'sritem.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code='SU'
union all
Select case when att_file=1 then 'srmain.'+RTRIM(FLD_NM) else 'sritem.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty='SU'

SET @QueryString ='SELECT AC_MAST.AC_NAME,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,SRMAIN.INV_NO,SRMAIN.DATE,SRMAIN.GRO_AMT AS V_GRO_AMT,
SRMAIN.TAX_NAME,SRMAIN.TAXAMT,SRMAIN.TOT_DEDUC,SRMAIN.TOT_ADD,SRMAIN.TOT_TAX,SRMAIN.TOT_NONTAX,SRMAIN.NET_AMT,SRITEM.ITEM_NO,SRITEM.ITEM,SRMAIN.TRAN_CD,
CONVERT(VARCHAR(254),SRMAIN.NARR) AS NARR,SRITEM.QTY,SRITEM.RATE,SRITEM.GRO_AMT,SRITEM.CGST_AMT,SRITEM.SGST_AMT,SRITEM.IGST_AMT,SRITEM.U_ASSEAMT,
IT_MAST.RATEUNIT,IT_DESC=(CASE WHEN ISNULL(IT_MAST.IT_ALIAS,'''')='''' THEN IT_MAST.IT_NAME ELSE IT_MAST.IT_ALIAS END),
MAILNAME=(CASE WHEN ISNULL(MAILNAME,'''')='''' THEN AC_NAME ELSE MAILNAME END)
,SRITEM.Compcess  -- Added By Prajakta B. On 28082017
,SRITEM.batchno,SRITEM.mfgdt,SRITEM.expdt'
SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''--ruchit
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
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM SRMAIN ' 
--INNER JOIN #srmain ON (sritem.TRAN_CD=#srmain.TRAN_CD and sritem.Entry_ty=#srmain.entry_ty and sritem.ITSERIAL=#srmain.itserial)
SET @SQLCOMMAND= @SQLCOMMAND+' INNER JOIN SRITEM  ON SRMAIN.TRAN_CD=SRITEM.TRAN_CD LEFT JOIN IT_MAST ON IT_MAST.IT_CODE=SRITEM.IT_CODE INNER JOIN AC_MAST ON SRMAIN.AC_ID=AC_MAST.AC_ID '
SET @SQLCOMMAND= @SQLCOMMAND+' INNER JOIN #SRMAIN ON (SRMAIN.TRAN_CD=#SRMAIN.TRAN_CD and SRMAIN.Entry_ty=#SRMAIN.entry_ty ) '
--WHERE  srmain.ENTRY_TY=''SU''

execute sp_executesql @sqlcommand


