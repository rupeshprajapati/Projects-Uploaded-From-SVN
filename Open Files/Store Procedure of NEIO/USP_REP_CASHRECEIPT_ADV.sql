DROP PROCEDURE [USP_REP_CASHRECEIPT_ADV]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Prajakta B.
-- Create date: 21/07/2017
-- Description:	This Stored procedure is useful to generate Bank Receipt voucher .
-- Remark: 
-- =============================================
create PROCEDURE [USP_REP_CASHRECEIPT_ADV]
	@ENTRYCOND NVARCHAR(254)
	AS

Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250)
	
	SET @TBLCON=RTRIM(@ENTRYCOND)
			Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
			Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)


		select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact

--ruchit

declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max),@GSTReceivable nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where att_file=0 and Entry_ty='CR' and code in( 'D','F')  FOR XML PATH ('')), 1, 0, ''
               ),0)

               
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='CR'  FOR XML PATH ('')), 1, 0, ''
                 --(select case when fld_nm<>'' then '+'+fld_nm else ''  end from dcmast where code='T' and att_file=0 and Entry_ty='CR' and bef_aft=2  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
               
--Commented Start By Prajakta B on 28082017              
--SELECT 
--    @ItemNTX = isnull(STUFF(
--                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='AR' and fld_nm not in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
--               ),0)  

--Modified Start By Prajakta B on 28082017               
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='cR' and fld_nm not in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','Comrpcess','Compcess','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)  
               
               
SELECT 
    @GSTReceivable = isnull(STUFF(
                 (SELECT  '+'+'cRitem.'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='cR' and fld_nm in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM')/*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)               
               
               

SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='CR'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='CR'  FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='CR'  FOR XML PATH ('')), 1, 0, ''
               ),0)
--ruchit


Declare @sta_dt datetime, @end_dt datetime 
set @SQLCOMMAND1='select top 1 @sta_dt=sta_dt,@end_dt=end_dt from vudyog..co_mast where dbname=db_name() and ( select top 1 CRMAIN.date  from CRMAIN inner join CRITEM on (CRMAIN.tran_cd=CRITEM.tran_cd) where '+@TBLCON+' ) between sta_dt and end_dt '	
set @ParmDefinition =N' @sta_dt datetime Output, @end_dt datetime Output'
EXECUTE sp_executesql @SQLCOMMAND1,@ParmDefinition,@sta_dt=@sta_dt Output, @end_dt=@end_dt Output

	Select Entry_ty,Tran_cd=0 Into #CRMAIN from CRMAIN Where 1=0
	Create NonClustered Index Idx_tmpStmain On #CRMAIN (Entry_ty asc, Tran_cd Asc)

		set @sqlcommand='Insert Into #CRMAIN Select CRMAIN.Entry_ty,CRMAIN.Tran_cd from CRMAIN Inner Join CRITEM on (CRMAIN.Entry_ty=CRITEM.Entry_ty and CRMAIN.Tran_cd=CRITEM.Tran_cd) Where '+@TBLCON
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
		set @stkl_qty= @stkl_qty +', '+'CRITEM.'+@fld_nm

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
	set @stkl_qty=',CRITEM.QTY'
End

Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@tempsql varchar(50),@fld_type  varchar(15)
Select case when att_file=1 then 'CRMAIN.'+RTRIM(FLD_NM) else 'CRITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code='CR'
union all
Select case when att_file=1 then 'CRMAIN.'+RTRIM(FLD_NM) else 'CRITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty='CR'

	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,CRMAIN.INV_SR,CRMAIN.TRAN_CD,CRMAIN.ENTRY_TY,CRMAIN.INV_NO,CRMAIN.DATE,CRITEM.item,CRITEM.AMTINCGST
,CRITEM.AMTEXCGST,It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)
,CRITEM.u_asseamt,CRITEM.CGST_PER,CRITEM.CGST_AMT,CRITEM.SGST_PER,CRITEM.SGST_AMT,CRITEM.IGST_PER,CRITEM.IGST_AMT
,CRMAIN.DUE_DT,cast (CRITEM.NARR AS VARCHAR(2000)) AS NARR,CRITEM.TOT_EXAMT
,IT_MAST.EIT_NAME,IT_MAST.IDMARK,IT_MAST.RATEUNIT,HSNCODE=CASE WHEN IT_MAST.ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END,IT_mast.U_ITPARTCD,CRITEM.item_no,CRITEM.GRO_AMT AS IT_GROAMT
,MailName=(CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)
,SAC_NAME=(CASE WHEN ISNULL(S1.MailName,'''')='''' THEN (CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)  ELSE S1.mailname END)
,SADD1=CASE WHEN CRMAIN.AC_ID >0 THEN S1.ADD1 ELSE AC_MAST.ADD1 END
,SADD2=CASE WHEN CRMAIN.AC_ID >0 THEN S1.ADD2 ELSE AC_MAST.ADD2 END
,SADD3=CASE WHEN CRMAIN.AC_ID >0 THEN S1.ADD3 ELSE AC_MAST.ADD3 END
,SCITY=CASE WHEN CRMAIN.AC_ID >0 THEN S1.CITY ELSE AC_MAST.CITY END
,SSTATE=CASE WHEN CRMAIN.AC_ID >0 THEN S1.STATE ELSE AC_MAST.STATE END
,SCOUNTRY=CASE WHEN CRMAIN.AC_ID >0 THEN S1.COUNTRY ELSE AC_MAST.COUNTRY END
,SZIP=CASE WHEN CRMAIN.AC_ID >0 THEN S1.ZIP ELSE AC_MAST.ZIP END
,SPHONE=CASE WHEN CRMAIN.AC_ID >0 THEN S1.PHONE ELSE AC_MAST.PHONE END
,SUNIQUEID=CASE WHEN CRMAIN.AC_ID >0 THEN (CASE WHEN S1.UID<>'''' THEN S1.UID ELSE S1.GSTIN END) ELSE (CASE WHEN AC_MAST.UID<>'''' THEN AC_MAST.UID ELSE AC_MAST.GSTIN END) END
,SSTATECODE=(SELECT TOP 1 GST_STATE_CODE FROM STATE WHERE STATE=CASE WHEN CRMAIN.AC_ID >0 THEN S1.STATE ELSE AC_MAST.STATE END)
,CRITEM.ITSERIAL,item_fdisc=CRITEM.tot_fdisc,CRMAIN.roundoff,CRMAIN.bank_nm,CRMAIN.net_amt
,CRITEM.compcess,CRITEM.comrpcess,CRITEM.ccessrate,CRITEM.cgsrt_amt,CRITEM.sgsrt_amt,CRITEM.igsrt_amt' -- added By Prajakta B on 28082017
	SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''--ruchit, NONTAXIT='+@NonTaxIT+'
	SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+',GSTReceivable='+@GSTReceivable+''


print 'demo'

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

print 'demo1'

SET @SQLCOMMAND=''
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM CRMAIN' 
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN CRITEM ON (CRMAIN.TRAN_CD=CRITEM.TRAN_CD AND CRMAIN.ENTRY_TY=CRITEM.ENTRY_TY)
  INNER JOIN IT_MAST ON (CRITEM.IT_CODE=IT_MAST.IT_CODE)
  INNER JOIN AC_MAST ON (AC_MAST.AC_ID=CRMAIN.AC_ID)
  LEFT JOIN SHIPTO S1 ON (CRMAIN.AC_ID=S1.AC_ID AND CRMAIN.AC_ID=S1.SHIPTO_ID)
   inner JOIN #CRMAIN ON (CRMAIN.TRAN_CD=#CRMAIN.TRAN_CD and CRMAIN.Entry_ty=#CRMAIN.entry_ty ) 
 ORDER BY CRMAIN.INV_SR,CRMAIN.INV_NO'

execute sp_executesql @sqlcommand
print @sqlcommand
GO
