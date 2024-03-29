If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_PT_BILLBARCODE')
Begin
	Drop Procedure USP_REP_PT_BILLBARCODE
End
GO
/****** Object:  StoredProcedure [dbo].[USP_REP_PT_BILLBARCODE]    Script Date: 11/16/2018 12:16:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--EXECUTE USP_REP_PT_BILLBARCODE "PTMAIN.Entry_ty = 'PT' And PTMAIN.Tran_cd = 0"
-- =============================================
-- Author	  :	Prajakta B
-- Create date: 29/11/2018
-- Description:	This Stored procedure is useful to generate Barcode on Purchase Bill Invoice .
-- Remark: 
-- =============================================

Create PROCEDURE [dbo].[USP_REP_PT_BILLBARCODE]
	@ENTRYCOND NVARCHAR(254)
	AS

Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250)

--added by Prajakta B. on 29/11/2018 for Bug 32062 --Start
Declare @TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50),@TBLNAME2 as VARCHAR(50)
Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
				+ (DATEPART(ss, GETDATE()) * 1000 )
				+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
Set @TBLNAME1 = '##TMP1'+@TBLNM
Set @TBLNAME2 = '##TMP2'+@TBLNM

Declare @BarcodeFldNm as Varchar(50)
Set @BarcodeFldNm = ''
select Top 1 @BarcodeFldNm = Fld_Nm1 from barcodemast where Entry_ty = 'IM'
If @BarcodeFldNm = ''
Begin
	Set @BarcodeFldNm = 'Cast('' '' as Varchar(10))'
End
Else
Begin
	Set @BarcodeFldNm = 'It_mast.'+@BarcodeFldNm
End
--added by Prajakta B. on 29/11/2018 for Bug 32062 --Start


	SET @TBLCON=RTRIM(@ENTRYCOND)
			Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
			Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)

	Select Entry_ty,Tran_cd=0 Into #PTMAIN from PTMAIN Where 1=0
	set @sqlcommand='Insert Into #PTMAIN Select PTMAIN.Entry_ty,PTMAIN.Tran_cd from PTMAIN Where '+@TBLCON
		print @sqlcommand
		execute sp_executesql @sqlcommand


		select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact

declare @ITAddLess varchar(500),@NonTaxIT varchar(500),@HeaderDisc varchar(500),@HeaderTAX nvarchar(max),@HeaderNTX nvarchar(max),@ItemTaxable nvarchar(max),@ItemNTX nvarchar(max),@ItemAddl nvarchar(max),@GSTReceivable nvarchar(max)

SELECT 
    @ITAddLess = isnull(STUFF(
                 (SELECT Case when a_s<>'' then a_s else (case when code in( 'D','F') THEN '-' else '+' end ) end + fld_nm FROM Dcmast where att_file=0 and Entry_ty='PT' AND code in ('D','F') FOR XML PATH ('')), 1, 0, ''
               ),0)
               
print '@ITAddLess= '+@ITAddLess               

SELECT 
    @ItemTaxable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=0 and Entry_ty='PT' FOR XML PATH ('')), 1, 0, ''
               ),0)
 
SELECT 
    @ItemNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='PT' and fld_nm not in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','Comrpcess','Compcess','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM') /*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)      

SELECT 
    @GSTReceivable = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=0 and Entry_ty='PT' and fld_nm in ('CGSRT_AMT','SGSRT_AMT','IGSRT_AMT','FCCGSRT_AM','FCSGSRT_AM','FCIGSRT_AM')/*and bef_aft=2*/  FOR XML PATH ('')), 1, 0, ''
               ),0)

SELECT 
    @HeaderDisc = isnull(STUFF(
                 (SELECT  '-'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('D','F') and att_file=1  and Entry_ty='PT'  FOR XML PATH ('')), 1, 0, ''
               ),0)


SELECT 
    @HeaderTAX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code='T' and att_file=1 and Entry_ty='PT'  FOR XML PATH ('')), 1, 0, ''
               ),0)



SELECT 
    @HeaderNTX = isnull(STUFF(
                 (SELECT  '+'+ltrim(rtrim(fld_nm)) FROM Dcmast where code in ('N','A') and att_file=1 and Entry_ty='PT'  FOR XML PATH ('')), 1, 0, ''
               ),0)

Declare @sta_dt datetime, @end_dt datetime 
set @SQLCOMMAND1='select top 1 @sta_dt=sta_dt,@end_dt=end_dt from vudyog..co_mast where dbname=db_name() and ( select top 1 PTMAIN.date  from PTMAIN inner join PTITEM on (PTMAIN.tran_cd=PTITEM.tran_cd) where '+@TBLCON+' ) between sta_dt and end_dt '	
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
		set @stkl_qty= @stkl_qty +', '+'PTITEM.'+@fld_nm

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
	set @stkl_qty=',PTITEM.QTY'
End

Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15),@tempsql varchar(50)
Select case when att_file=1 then 'PTMAIN.'+RTRIM(FLD_NM) else 'PTITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code='PT'
union all
Select case when att_file=1 then 'PTMAIN.'+RTRIM(FLD_NM) else 'PTITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty='PT'


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
           WHERE TABLE_NAME = N'PTTmpBrcd')
BEGIN
  Drop table PTTmpBrcd
END


SET @QueryString ='Select AC_NAME=(CASE WHEN PTMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.mailname END)
,ADD1=(CASE WHEN PTMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add1,'''')='''' THEN AC_MAST.add1 ELSE SHIPTO.ADD1 END) ELSE AC_MAST.ADD1 END)
,ADD2=(CASE WHEN PTMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add2,'''')='''' THEN AC_MAST.add2 ELSE SHIPTO.add2 END) ELSE AC_MAST.ADD2 END)
,ADD3=(CASE WHEN PTMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.add3,'''')='''' THEN AC_MAST.add3 ELSE SHIPTO.add3 END) ELSE AC_MAST.ADD3 END)
,City=(CASE WHEN PTMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.city,'''')='''' THEN AC_MAST.city ELSE SHIPTO.city END) ELSE AC_MAST.city END)
,Zip=(CASE WHEN PTMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.zip,'''')='''' THEN AC_MAST.zip ELSE SHIPTO.zip END) ELSE AC_MAST.zip END),ptmain.inv_no,ptmain.date,ptmain.gro_amt as v_gro_amt,it_mast.mrprate,
ptmain.tot_deduc,ptmain.tot_add,ptmain.tot_tax,ptmain.tot_nontax,ptmain.net_amt,ptitem.item_no,ptitem.item,cast(ptmain.narr as varchar(400)) AS narr,ptitem.entry_ty,
ptitem.qty,ptitem.rate,ptitem.gro_amt,it_mast.rateunit,It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END),
MailName=(CASE WHEN PTMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.MailName,'''')='''' THEN AC_MAST.mailname ELSE SHIPTO.mailname END) ELSE AC_MAST.mailname END)
,U_DELIVER=(CASE WHEN PTMAIN.scons_id > 0 THEN (CASE WHEN ISNULL(SHIPTO1.MailName,'''')='''' THEN AC_MAST1.ac_name ELSE SHIPTO1.mailname END) ELSE AC_MAST1.AC_NAME END)
,ADD11=(CASE WHEN PTMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add1,'''')='''' THEN AC_MAST1.add1 ELSE SHIPTO1.ADD1 END) ELSE AC_MAST1.ADD1 END)
,ADD22=(CASE WHEN PTMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add2,'''')='''' THEN AC_MAST1.add2 ELSE SHIPTO1.add2 END) ELSE AC_MAST1.ADD2 END)
,ADD33=(CASE WHEN PTMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.add3,'''')='''' THEN AC_MAST1.add3 ELSE SHIPTO1.add3 END) ELSE AC_MAST1.ADD3 END)
,City1=(CASE WHEN PTMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.city,'''')='''' THEN AC_MAST1.city ELSE SHIPTO1.city END) ELSE AC_MAST1.city END)
,Zip1=(CASE WHEN PTMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.zip,'''')='''' THEN AC_MAST1.zip ELSE SHIPTO1.zip END) ELSE AC_MAST1.zip END)
,PTITEM.CGST_PER,PTITEM.SGST_PER,PTITEM.IGST_PER,PTMAIN.CGST_AMT,PTMAIN.SGST_AMT,PTMAIN.IGST_AMT,PTMAIN.Tran_cd,PTITEM.U_ASSEAMT
,item_fdisc=ptitem.tot_fdisc,Ptitem.ITSERIAL
,Ptitem.compcess,Ptitem.comrpcess' 
SET @QueryString =@QueryString+',gstin=(CASE WHEN PTMAIN.sac_id> 0 THEN (CASE WHEN ISNULL(SHIPTO.gstin,'''')='''' THEN AC_MAST.gstin ELSE SHIPTO.gstin END) ELSE AC_MAST.gstin END)'  
SET @QueryString =@QueryString+',gstin1=(CASE WHEN PTMAIN.scons_id> 0 THEN (CASE WHEN ISNULL(SHIPTO1.gstin,'''')='''' THEN AC_MAST1.gstin ELSE SHIPTO1.gstin END) ELSE AC_MAST1.gstin END)'
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
--SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+' into PTTmpBrcd FROM PTMAIN ' 
--SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+',ptitem.bc_no1 into PTTmpBrcd FROM ptmain ' --Commented by Prajakta B. on 29/11/2018
SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+','+@BarcodeFldNm+' As BC_NO1 into ' + @TBLNAME1 + ' FROM ptmain ' --Modified by Prajakta B. on 29/11/2018
--SET @SQLCOMMAND = N''+@QueryString+''+N''+@Tot_flds+''+',it_mast.bc_no1 FROM ptmain ' 

SET @SQLCOMMAND= @SQLCOMMAND+'
inner join ptitem on ptmain.tran_cd=ptitem.tran_cd 
left join it_mast on it_mast.it_code=ptitem.it_code 
INNER JOIN AC_MAST AC_MAST1 ON (AC_MAST1.AC_ID=PTMAIN.CONS_ID) 
LEFT JOIN SHIPTO ON (SHIPTO.AC_ID=PTMAIN.Ac_id AND SHIPTO.Shipto_id=PTMAIN.sac_id) 
LEFT JOIN SHIPTO SHIPTO1 ON(SHIPTO1.AC_ID=PTMAIN.CONS_id AND SHIPTO1.Shipto_id =PTMAIN.scons_id)
INNER JOIN #PTMAIN ON (PTMAIN.TRAN_CD=#PTMAIN.TRAN_CD and PTMAIN.Entry_ty=#PTMAIN.entry_ty ) 
inner join ac_mast on ptmain.ac_id=ac_mast.ac_id where ptmain.entry_ty=''PT'''
SET @SQLCOMMAND= @SQLCOMMAND+' Order by item_no'  --Added by Priyanka B on 15122017 for AU 13.0.5
print @sqlcommand
execute sp_executesql @sqlcommand

--Select * into #tmp from PTTmpBrcd where 1 = 2  --Commented by Prajakta B. on 29/11/2018

Select @sqlcommand='SELECT * Into '+@TBLNAME2+' FROM '+@TBLNAME1+' where 1 = 2'
execute sp_executesql @sqlcommand	

--------------Commented by Prajakta B. on 29/11/2018 --Start
--Declare @ItSerial Varchar(10),@Qty NUMERIC(20) 
--DECLARE CurOP CURSOR FOR SELECT ItSerial,Qty From PTTmpBrcd
--OPEN CurOP
--FETCH NEXT FROM CurOP INTO @ItSerial,@Qty
--WHILE @@FETCH_STATUS=0
--BEGIN
--	WHILE @Qty > 0
--	BEGIN
--		Insert Into #tmp Select * From PTTmpBrcd Where ItSerial = @ItSerial 
--		Set @Qty = @Qty - 1
--	End	
--	FETCH NEXT FROM CurOP INTO @ItSerial,@Qty
--END
--CLOSE CurOP
--DEALLOCATE CurOP
--------------Commented by Prajakta B. on 29/11/2018 --End


--------------Modified by Prajakta B. on 29/11/2018 --Start
Select @sqlcommand='Declare @ItSerial Varchar(10),@Qty NUMERIC(20) 
DECLARE CurOP CURSOR FOR SELECT ItSerial,Qty From '+@TBLNAME1+' 
OPEN CurOP
FETCH NEXT FROM CurOP INTO @ItSerial,@Qty
WHILE @@FETCH_STATUS=0
BEGIN
	WHILE @Qty > 0
	BEGIN
		Insert Into '+@TBLNAME2+' Select * From '+@TBLNAME1+' Where ItSerial = @ItSerial 
		Set @Qty = @Qty - 1
	End	
	FETCH NEXT FROM CurOP INTO @ItSerial,@Qty
END
CLOSE CurOP
DEALLOCATE CurOP'
execute sp_executesql @sqlcommand	
--------------Modified by Prajakta B. on 29/11/2018 --End

--Select * From #tmp order by itserial  --Commented by Prajakta B. on 29/11/2018
--Drop table PTTmpBrcd  --Commented by Prajakta B. on 29/11/2018
--Drop table #tmp       --Commented by Prajakta B. on 29/11/2018
set @sqlcommand='SELECT * FROM '+@TBLNAME2+'  order by itserial'
execute sp_executesql @sqlcommand	

set @sqlcommand='Drop Table '+@TBLNAME1
execute sp_executesql @sqlcommand	
