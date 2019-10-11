If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_RV_VOU')
Begin
	Drop Procedure USP_REP_RV_VOU
End
/****** Object:  StoredProcedure [dbo].[USP_REP_RV_VOU]    Script Date: 04/23/2018 16:08:45 ******/
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
Create PROCEDURE [dbo].[USP_REP_RV_VOU]
	@ENTRYCOND NVARCHAR(254)
	AS

Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max)	
	SET @TBLCON=RTRIM(@ENTRYCOND)

declare @ITAddLess varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max)
--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where att_file=0 and Entry_ty='RV' and code in( 'D','F')  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
--itemwise taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='RV'  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
--itemwise non taxable          
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+BPITEM.'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='RV' /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)     

--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='RV'  FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='RV'  FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='RV'  FOR XML PATH ('')), 1, 0, ''
               ),0)

Declare @Addtblnm Varchar(1000)
set @Addtblnm  =''
if Exists(Select Top 1 [Name] From SysObjects Where xType='U' and [Name]='BPMAINADD')
Begin
	set @Addtblnm =' LEFT JOIN BPMAINADD ON (BPMAIN.TRAN_CD=BPMAINADD.TRAN_CD) '
end

	Select Entry_ty,Tran_cd=0,Date,inv_no,itserial=space(6) Into #BPMAIN from BPMAIN Where 1=0
	Create NonClustered Index Idx_tmpBPMAIN On #BPMAIN (Entry_ty asc, Tran_cd Asc, Itserial asc)

		set @sqlcommand='Insert Into #BPMAIN Select BPMAIN.Entry_ty,BPMAIN.Tran_cd,BPMAIN.date,BPMAIN.inv_no,BPITEM.itserial from BPMAIN Inner Join BPITEM on (BPMAIN.Entry_ty=BPITEM.Entry_ty and BPMAIN.Tran_cd=BPITEM.Tran_cd)  Where '+@TBLCON
		print @sqlcommand
		execute sp_executesql @sqlcommand

Declare @uom_desc as Varchar(100),@len int,@fld_nm varchar(10),@fld_desc Varchar(10),@stkl_qty Varchar(100)

	set @stkl_qty=',BPITEM.QTY'


Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15)

Select case when att_file=1 then (CASE WHEN RTRIM(TBL_NM)='BPMAINADD' THEN 'BPMAINADD.' ELSE 'BPMAIN.' END )+RTRIM(FLD_NM) else 'BPITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code='RV'
union all
Select case when att_file=1 then 'BPMAIN.'+RTRIM(FLD_NM) else 'BPITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty='RV'

	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,BPMAIN.INV_SR,BPMAIN.TRAN_CD,BPMAIN.ENTRY_TY,BPMAIN.INV_NO,BPMAIN.DATE'
	SET @QueryString =@QueryString+',BPMAIN.DUE_DT,BPMAIN.U_CLDT,BPITEM.GRO_AMT AS IT_GROAMT,BPMAIN.GRO_AMT GRO_AMT1,BPMAIN.NET_AMT'+@stkl_qty+',BPITEM.RATE,BPITEM.U_ASSEAMT, cast (BPITEM.NARR AS VARCHAR(2000)) AS NARR,BPITEM.TOT_EXAMT'
	SET @QueryString =@QueryString+',IT_MAST.IT_NAME,IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.IDMARK,IT_MAST.RATEUNIT,HSNCODE=(CASE WHEN IT_MAST.ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END),IT_mast.U_ITPARTCD,BPITEM.item_no'
	SET @QueryString =@QueryString+',It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)'
	SET @QueryString =@QueryString+',MailName=(CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)'
	SET @QueryString =@QueryString+',SAC_NAME=(CASE WHEN ISNULL(S1.MailName,'''')='''' THEN (CASE WHEN ISNULL(ac_mast.MailName,'''')='''' THEN ac_mast.ac_name ELSE ac_mast.mailname END)  ELSE S1.mailname END)'
	SET @QueryString =@QueryString+',SADD1=CASE WHEN BPMAIN.SAC_ID >0 THEN S1.ADD1 ELSE AC_MAST.ADD1 END'
	SET @QueryString =@QueryString+',SADD2=CASE WHEN BPMAIN.SAC_ID >0 THEN S1.ADD2 ELSE AC_MAST.ADD2 END'
	SET @QueryString =@QueryString+',SADD3=CASE WHEN BPMAIN.SAC_ID >0 THEN S1.ADD3 ELSE AC_MAST.ADD3 END'
	SET @QueryString =@QueryString+',SCITY=CASE WHEN BPMAIN.SAC_ID >0 THEN S1.CITY ELSE AC_MAST.CITY END'
	SET @QueryString =@QueryString+',SSTATE=CASE WHEN BPMAIN.SAC_ID >0 THEN S1.STATE ELSE AC_MAST.STATE END'
	SET @QueryString =@QueryString+',SZIP=CASE WHEN BPMAIN.SAC_ID >0 THEN S1.ZIP ELSE AC_MAST.ZIP END'
	SET @QueryString =@QueryString+',SPHONE=CASE WHEN BPMAIN.SAC_ID >0 THEN S1.PHONE ELSE AC_MAST.PHONE END'
	SET @QueryString =@QueryString+',SUNIQUEID=CASE WHEN BPMAIN.SAC_ID >0 THEN (CASE WHEN S1.UID<>'''' THEN S1.UID ELSE S1.GSTIN END) ELSE (CASE WHEN AC_MAST.UID<>'''' THEN AC_MAST.UID ELSE AC_MAST.GSTIN END) END'
	SET @QueryString =@QueryString+',SSTATECODE=(SELECT TOP 1 GST_STATE_CODE FROM STATE WHERE STATE=CASE WHEN BPMAIN.SAC_ID >0 THEN S1.STATE ELSE AC_MAST.STATE END)'	
	SET @QueryString =@QueryString+',BPITEM.ITSERIAL,item_fdisc=BPITEM.tot_fdisc'
	SET @QueryString =@QueryString+',BPMAIN.ctdsamt,BPMAIN.stdsamt,BPMAIN.itdsamt,BPITEM.Tariff,BPMAIN.roundoff'
	SET @QueryString =@QueryString+',BPITEM.CGST_PER,BPITEM.CGST_AMT,BPITEM.SGST_PER,BPITEM.SGST_AMT,BPITEM.IGST_PER,BPITEM.IGST_AMT'
	SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''
	SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+''
	SET @QueryString =@QueryString+',RECENO=BRMAIN.INV_NO,RECEDATE=BRMAIN.DATE'
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
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' FROM BPMAIN' 
print @sqlcommand
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN BPITEM ON (BPMAIN.TRAN_CD=BPITEM.TRAN_CD AND BPMAIN.ENTRY_TY=BPITEM.ENTRY_TY)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN #BPMAIN ON (BPITEM.TRAN_CD=#BPMAIN.TRAN_CD and BPITEM.Entry_ty=#BPMAIN.entry_ty and BPITEM.ITSERIAL=#BPMAIN.itserial) '
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN IT_MAST ON (BPITEM.IT_CODE=IT_MAST.IT_CODE)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=BPMAIN.AC_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+CASE WHEN @Addtblnm<>'' THEN @Addtblnm ELSE '' END
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN BRMAIN ON (BRMAIN.INV_NO=BPMAIN.PAYMENTNO)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S1 ON (BPMAIN.AC_ID=S1.AC_ID AND BPMAIN.SAC_ID=S1.SHIPTO_ID)'
SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY BPMAIN.INV_SR,BPMAIN.INV_NO'
print @SQLCOMMAND
execute sp_executesql @SQLCOMMAND