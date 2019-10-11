If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Rep_MIS_MPURAR')
Begin
	Drop Procedure Usp_Rep_MIS_MPURAR
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Rep_MIS_MPURAR]    Script Date: 2019-05-06 17:03:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Created By Prajakta B. on 14062019
Create PROCEDURE [dbo].[Usp_Rep_MIS_MPURAR] 
	(@FrmDate SMALLDATETIME,@Todate SMALLDATETIME,@FParty nvarchar(100),@TParty nvarchar(100)) 	
	AS
	
	Declare @SQLCOMMAND NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250)
			Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
			Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)

	
		select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact
	declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max),@GSTReceivable nvarchar(max)

	declare @CGSTReceivable nvarchar(max),@SGSTReceivable nvarchar(max),@IGSTReceivable nvarchar(max),@CESSReceivable nvarchar(max)

--itemwise 
SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where att_file=0 and Entry_ty in( 'AR') AND code in ('D','F')  group by fld_nm,a_s,code FOR XML PATH ('')), 1, 0, ''
               ),0)
               
print '@ITAddLess= '+@ITAddLess               
--itemwise taxable and non taxable
SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty in( 'AR') group by fld_nm FOR XML PATH ('')), 1, 0, ''
                 --(select case when fld_nm<>'' then '+'+fld_nm else ''  end from dcmast where code='T' and att_file=0 and Entry_ty in( 'AR') and bef_aft=2  FOR XML PATH ('')), 1, 0, ''
               ),0)                                                          
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty in( 'AR') and fld_nm not in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','Comrpcess','Compcess','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM') group by fld_nm /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)      
          
--itemwise non tax

SELECT 
    @GSTReceivable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty in( 'AR') and fld_nm in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM') group by fld_nm /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)



SELECT 
    @CGSTReceivable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty in( 'AR') and fld_nm in ('CGSRT_AMT') group by fld_nm /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)

SELECT 
    @SGSTReceivable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty in( 'AR') and fld_nm in ('SGSRT_AMT') group by fld_nm/*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)

SELECT 
    @IGSTReceivable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty in( 'AR') and fld_nm in ('IGSRT_AMT')  group by fld_nm /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
SELECT 
    @CESSReceivable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty in( 'AR') and fld_nm in ('COMRPCESS')  group by fld_nm /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)
               
--headerwise disc
SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty in( 'AR') group by fld_nm FOR XML PATH ('')), 1, 0, ''
               ),0)

--headerwise taxable chargs
SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty in( 'AR')  group by fld_nm FOR XML PATH ('')), 1, 0, ''
               ),0)


--headerwise non taxable chargs
SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty in( 'AR') group by fld_nm FOR XML PATH ('')), 1, 0, ''
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
		set @stkl_qty= @stkl_qty +', '+'ARITEM.'+@fld_nm

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
	set @stkl_qty=',ARITEM.QTY'
End

Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15),@tempsql varchar(50)
Select case when att_file=1 then 'ARMAIN.'+RTRIM(FLD_NM) else 'ARITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code in ('AR')
union all
Select case when att_file=1 then 'ARMAIN.'+RTRIM(FLD_NM) else 'ARITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty in ('AR')

SET @QueryString ='Select AC_NAME=(CASE WHEN ARMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.mailname END)
,ADD1=(CASE WHEN ARMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add1,'''')='''' THEN AC_MAST.add1 ELSE SHIPTO.ADD1 END) ELSE AC_MAST.ADD1 END)
,ADD2=(CASE WHEN armain.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add2,'''')='''' THEN AC_MAST.add2 ELSE SHIPTO.add2 END) ELSE AC_MAST.ADD2 END)
,ADD3=(CASE WHEN armain.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add3,'''')='''' THEN AC_MAST.add3 ELSE SHIPTO.add3 END) ELSE AC_MAST.ADD3 END)
,City=(CASE WHEN armain.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.city,'''')='''' THEN AC_MAST.city ELSE SHIPTO.city END) ELSE AC_MAST.city END)
,Zip=(CASE WHEN armain.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.zip,'''')='''' THEN AC_MAST.zip ELSE SHIPTO.zip END) ELSE AC_MAST.zip END),armain.inv_no,armain.date,aritem.gro_amt as v_gro_amt,
armain.tot_deduc,armain.tot_add,armain.tot_tax,armain.tot_nontax,armain.net_amt,aritem.item_no,aritem.item,cast(armain.narr as varchar(400)) AS narr,
aritem.qty,aritem.rate,aritem.gro_amt,it_mast.rateunit,It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END),
MailName=(CASE WHEN armain.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.mailname END)
,U_DELIVER=(CASE WHEN armain.scons_id > 0 THEN (CASE WHEN ISNULL(SHIPTO1.MailName,'''')='''' THEN AC_MAST1.ac_name ELSE SHIPTO1.mailname END) ELSE AC_MAST1.AC_NAME END)
,ADD11=(CASE WHEN armain.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add1,'''')='''' THEN AC_MAST1.add1 ELSE SHIPTO1.ADD1 END) ELSE AC_MAST1.ADD1 END)
,ADD22=(CASE WHEN armain.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add2,'''')='''' THEN AC_MAST1.add2 ELSE SHIPTO1.add2 END) ELSE AC_MAST1.ADD2 END)
,ADD33=(CASE WHEN armain.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add3,'''')='''' THEN AC_MAST1.add3 ELSE SHIPTO1.add3 END) ELSE AC_MAST1.ADD3 END)
,City1=(CASE WHEN armain.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.city,'''')='''' THEN AC_MAST1.city ELSE SHIPTO1.city END) ELSE AC_MAST1.city END)
,Zip1=(CASE WHEN armain.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.zip,'''')='''' THEN AC_MAST1.zip ELSE SHIPTO1.zip END) ELSE AC_MAST1.zip END)
,aritem.CGST_PER,aritem.SGST_PER,aritem.IGST_PER,aritem.CGST_AMT,aritem.SGST_AMT,aritem.IGST_AMT,armain.Tran_cd,aritem.U_ASSEAMT
,item_fdisc=aritem.tot_fdisc
,aritem.compcess,aritem.comrpcess' 

SET @QueryString =@QueryString+',gstin=(CASE WHEN armain.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.gstin,'''')='''' THEN AC_MAST.gstin ELSE SHIPTO.gstin END) ELSE AC_MAST.gstin END)'  
SET @QueryString =@QueryString+',gstin1=(CASE WHEN armain.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.gstin,'''')='''' THEN AC_MAST1.gstin ELSE SHIPTO1.gstin END) ELSE AC_MAST1.gstin END)'
SET @QueryString =@QueryString+',ITADDLESS='+@ITAddLess+',ITEMTAX='+@ItemTaxable+',ITEMNTX='+@ItemNTX+',HEADERDISC='+@HeaderDisc+''--ruchit
SET @QueryString =@QueryString+',HEADERTAX='+@HeaderTAX+',HEADERNTX='+@HeaderNTX+',GSTReceivable='+@GSTReceivable+',CGSTReceivable='+@CGSTReceivable+',SGSTReceivable='+@SGSTReceivable+',IGSTReceivable='+@IGSTReceivable+''
SET @QueryString =@QueryString+',armain.Pinvno,armain.Pinvdt,armain.party_nm,AC_MAST.state,HSNCODE = (CASE WHEN ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END)'
SET @QueryString =@QueryString+',ST_TYPE=CASE WHEN armain.SCONS_ID >0 THEN SHIPTO1.ST_TYPE ELSE AC_MAST.ST_TYPE END,armain.EWBN,armain.EWBDT,armain.EWBDIST,armain.roundoff,aritem.LINERULE,aritem.CCESSRATE,CESSReceivable='+@CESSReceivable+''

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
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' into ##main11 FROM armain ' 
SET @SQLCOMMAND= @SQLCOMMAND+'
inner join aritem on armain.tran_cd=aritem.tran_cd 
left join it_mast on it_mast.it_code=aritem.it_code 
INNER JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_ID=armain.CONS_ID) 
LEFT JOIN SHIPTO ON (SHIPTO.AC_ID=armain.Ac_id AND SHIPTO.Shipto_id=armain.sac_id) 
LEFT JOIN SHIPTO SHIPTO1 ON(SHIPTO1.AC_ID=armain.CONS_id AND SHIPTO1.Shipto_id =armain.scons_id)
 
inner join ac_mast on armain.ac_id=ac_mast.ac_id'
SET @SQLCOMMAND =	@SQLCOMMAND+' WHERE  (armain.date BETWEEN '+CHAR(39)+cast(@FrmDate as varchar)+CHAR(39)+'  AND '+CHAR(39)+cast(@Todate as varchar )+CHAR(39)+') and (armain.Party_nm BETWEEN '+CHAR(39)+@FParty+CHAR(39)+' AND '+CHAR(39)+@TParty+CHAR(39)+')'

SET @SQLCOMMAND= @SQLCOMMAND+' Order by item_no' 
print @sqlcommand
execute sp_executesql @sqlcommand

SET @SQLCOMMAND ='select date,inv_no,Pinvno,Pinvdt,ST_TYPE,party_nm,GSTIN,state,item,HSNCODE,qty,rateunit,rate,total=(qty*rate),ITEMTAX,U_ASSEAMT'
SET @SQLCOMMAND=@SQLCOMMAND+',CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT'
SET @SQLCOMMAND=@SQLCOMMAND+',TotalGST=CGST_AMT+SGST_AMT+IGST_AMT,EWBN,EWBDT, EWBDIST,ITAddLess as discount,roundoff,v_gro_amt,ITEMNTX,net_amt ,'
SET @SQLCOMMAND=@SQLCOMMAND+'CGSTReceivable,SGSTReceivable,IGSTReceivable,U_FREIGHT='''',LINERULE,PKGFRWD='''',CCESSRATE=case when CCESSRATE=''NO-CESS'' then '''' else CCESSRATE end ,COMPCESS,CESSReceivable from ##main11'
execute sp_executesql @SQLCOMMAND
drop table ##main11
	