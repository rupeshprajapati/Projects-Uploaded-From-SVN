If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_PR_BILL')
Begin
	Drop Procedure USP_REP_PR_BILL
End
/****** Object:  StoredProcedure [dbo].[USP_REP_PR_BILL]    Script Date: 08/25/2018 15:51:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXECUTE USP_REP_PR_BILL "PRMAIN.Entry_ty = 'PR' And PRMAIN.Tran_cd = 1"
-- =============================================
-- Author	  :	Ruchit Shah
-- Create date: 02/12/2016
-- Description:	This Stored procedure is useful to generate Purchase Return Invoice .
-- Remark: 
-- =============================================

Create PROCEDURE [dbo].[USP_REP_PR_BILL]
	@ENTRYCOND NVARCHAR(254)
	AS

Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250)
	
	SET @TBLCON=RTRIM(@ENTRYCOND)
			Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
			Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)

	Select Entry_ty,Tran_cd=0 Into #PRMAIN from PRMAIN Where 1=0
	set @sqlcommand='Insert Into #PRMAIN Select PRMAIN.Entry_ty,PRMAIN.Tran_cd from PRMAIN Where '+@TBLCON
		print @sqlcommand
		execute sp_executesql @sqlcommand
		

		select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact

--ruchit

declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max),@GSTReceivable nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where  code in( 'D','F')  and att_file=0 and Entry_ty='PR'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='PR'  FOR XML PATH ('')), 1, 0, ''
                 --(select case when fld_nm<>'' then '+'+fld_nm else ''  end from dcmast where code='T' and att_file=0 and entry_ty='PR' and bef_aft=2  FOR XML PATH ('')), 1, 0, ''
               ),0)
              
--Commented Start By Prajakta B on 28082017              
--SELECT 
--    @ItemNTX = isnull(STUFF(
--                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='AR' and fld_nm not in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
--               ),0)  

--Modified Start By Prajakta B on 28082017               
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='PR' and fld_nm not in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','Comrpcess','Compcess','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)      
--itemwise non tax

/*cgstreceivable*/
SELECT 
    @GSTReceivable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='PR' and fld_nm in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM')/*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)
/*cgstreceivable*/

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='PR'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='PR'  FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='PR'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--ruchit


Declare @sta_dt datetime, @end_dt datetime 
set @SQLCOMMAND1='select top 1 @sta_dt=sta_dt,@end_dt=end_dt from vudyog..co_mast where dbname=db_name() and ( select top 1 PRMAIN.date  from PRMAIN inner join PRITEM on (PRMAIN.tran_cd=PRITEM.tran_cd) where '+@TBLCON+' ) between sta_dt and end_dt '	
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
		set @stkl_qty= @stkl_qty +', '+'PRITEM.'+@fld_nm

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
	set @stkl_qty=',PRITEM.QTY'
End

Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15),@tempsql varchar(50)
Select case when att_file=1 then 'PRMAIN.'+RTRIM(FLD_NM) else 'PRITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code='PR'
union all
Select case when att_file=1 then 'PRMAIN.'+RTRIM(FLD_NM) else 'PRITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty='PR'

SET @QueryString ='SELECT AC_NAME=(CASE WHEN PRMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.mailname END)
,ADD1=(CASE WHEN PRMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add1,'''')='''' THEN AC_MAST.add1 ELSE SHIPTO.ADD1 END) ELSE AC_MAST.ADD1 END)
,ADD2=(CASE WHEN PRMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add2,'''')='''' THEN AC_MAST.add2 ELSE SHIPTO.add2 END) ELSE AC_MAST.ADD2 END)
,ADD3=(CASE WHEN PRMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add3,'''')='''' THEN AC_MAST.add3 ELSE SHIPTO.add3 END) ELSE AC_MAST.ADD3 END)
,City=(CASE WHEN PRMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.city,'''')='''' THEN AC_MAST.city ELSE SHIPTO.city END) ELSE AC_MAST.city END)
,Zip=(CASE WHEN PRMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.zip,'''')='''' THEN AC_MAST.zip ELSE SHIPTO.zip END) ELSE AC_MAST.zip END)
,State=(CASE WHEN PRMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.State,'''')='''' THEN AC_MAST.state ELSE SHIPTO.state END) ELSE AC_MAST.state END)
,PRMAIN.INV_NO,PRMAIN.DATE,PRMAIN.GRO_AMT AS V_GRO_AMT,
PRMAIN.CGST_AMT,PRMAIN.SGST_AMT,PRMAIN.IGST_AMT,PRMAIN.TOT_DEDUC,PRMAIN.TOT_ADD,PRMAIN.TOT_TAX,PRMAIN.TOT_NONTAX,PRMAIN.NET_AMT,PRITEM.ITEM_NO,
PRITEM.ITEM,CAST(PRMAIN.NARR AS VARCHAR(400)) AS NARR,PRITEM.QTY,PRITEM.RATE,PRITEM.GRO_AMT,IT_MAST.RATEUNIT,PRMAIN.Tran_cd,PRITEM.U_ASSEAMT,ac_mast.gstin,ac_mast1.gstin as gstin1,
It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END),
MailName=(CASE WHEN PRMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.mailname END)
,U_DELIVER=(CASE WHEN PRMAIN.scons_id > 0 THEN (CASE WHEN ISNULL(SHIPTO1.MailName,'''')='''' THEN AC_MAST1.ac_name ELSE SHIPTO1.mailname END) ELSE AC_MAST1.AC_NAME END)
,ADD11=(CASE WHEN PRMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add1,'''')='''' THEN AC_MAST1.add1 ELSE SHIPTO1.ADD1 END) ELSE AC_MAST.ADD1 END)
,ADD22=(CASE WHEN PRMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add2,'''')='''' THEN AC_MAST1.add2 ELSE SHIPTO1.add2 END) ELSE AC_MAST.ADD2 END)
,ADD33=(CASE WHEN PRMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add3,'''')='''' THEN AC_MAST1.add3 ELSE SHIPTO1.add3 END) ELSE AC_MAST1.ADD3 END)
,City1=(CASE WHEN PRMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.city,'''')='''' THEN AC_MAST1.city ELSE SHIPTO1.city END) ELSE AC_MAST1.city END)
,Zip1=(CASE WHEN PRMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.zip,'''')='''' THEN AC_MAST1.zip ELSE SHIPTO1.zip END) ELSE AC_MAST1.zip END)
,State1=(CASE WHEN PRMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.state,'''')='''' THEN AC_MAST1.state ELSE SHIPTO1.state END) ELSE AC_MAST1.state END)
,item_fdisc=pritem.tot_fdisc,pritem.cgst_per,pritem.sgst_per,pritem.igst_per,statecode=ac_mast.statecode,statecode1=ac_mast1.statecode
,pritem.compcess,pritem.comrpcess,it_mast.hsncode,pritem.sbillno,pritem.sbdate,pritem.cgsrt_amt,pritem.sgsrt_amt,pritem.igsrt_amt' -- added By Prajakta B on 28082017
SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''--ruchit
SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+',GSTReceivable='+@GSTReceivable+''
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
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM PRMAIN ' 
SET @SQLCOMMAND= @SQLCOMMAND+'
INNER JOIN PRITEM ON PRMAIN.TRAN_CD=PRITEM.TRAN_CD 
LEFT JOIN IT_MAST ON IT_MAST.IT_CODE=PRITEM.IT_CODE 
INNER JOIN AC_MAST ON PRMAIN.AC_ID=AC_MAST.AC_ID 
INNER JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_ID=PRMAIN.CONS_ID)
LEFT JOIN SHIPTO ON (SHIPTO.AC_ID=PRMAIN.Ac_id AND SHIPTO.Shipto_id=PRMAIN.sac_id) 
LEFT JOIN SHIPTO SHIPTO1 ON(SHIPTO1.AC_ID=PRMAIN.CONS_id AND SHIPTO1.Shipto_id =PRMAIN.scons_id)
INNER JOIN #PRMAIN ON (PRMAIN.TRAN_CD=#PRMAIN.TRAN_CD and PRMAIN.Entry_ty=#PRMAIN.entry_ty ) 
'


execute sp_executesql @sqlcommand