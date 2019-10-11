
/****** Object:  StoredProcedure [dbo].[Usp_CSV_Export_pharmaretail]    Script Date: 09-03-2019 19:05:56 ******/
If Exists(Select [Name] From SysObjects Where xType='P' and [Name]='Usp_CSV_Export_pharmaretail')
Begin
	DROP PROCEDURE [dbo].[Usp_CSV_Export_pharmaretail]
End
GO




Create Procedure [dbo].[Usp_CSV_Export_pharmaretail]
@fcond varchar(4000)
,@Entry_ty Varchar(2)
as
begin
Declare @SQLCOMMAND NVARCHAR(max)


Declare @fld Varchar(50),@fld_nm1 Varchar(50),@att_file bit,@Tot_flds Varchar(4000),@QueryString NVarchar(max),@fld_type  varchar(15),@Entry_tbl Varchar(2)

Select @Entry_tbl=Case when bcode_nm<>'' then Bcode_nm else (case when ext_vou=1 then '' else Entry_ty End) end from Lcode Where Entry_ty=@Entry_ty

Select case when att_file=1 then (CASE WHEN CHARINDEX('ADD',TBL_NM)>0 THEN 'MADD.' ELSE 'MAIN.'END) +RTRIM(FLD_NM) else 'ITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty 
Into #tmpFlds 
From Lother Where e_code=@Entry_ty
union all
Select case when att_file=1 then 'MAIN.'+RTRIM(FLD_NM) else 'ITEM.'+RTRIM(FLD_NM) end as flds,FLD_NM=RTRIM(FLD_NM),att_file,data_ty=''  From DcMast
Where Entry_ty=@Entry_ty




	SET @QueryString = ''
	SET @QueryString = 'MAIN.entry_ty,pinvdt=MAIN.date,MAIN.dept,MAIN.cate,pinvno=MAIN.inv_no,MAIN.inv_sr,'
	SET @QueryString =@QueryString+'MAIN.net_amt,'
	SET @QueryString =@QueryString+'MAIN.roundoff,MAIN.due_days'
	SET @QueryString =@QueryString+',Party_nm=cm.Co_Name,GSTState=cm.state,GSTSCODE=Cast(st.Gst_State_Code as varchar) '
	SET @QueryString =@QueryString+',ITEM.itserial,ITEM.item_no,ITEM.item,ITEM.qty,ITEM.rate,ITEM.gro_amt,'
	SET @QueryString =@QueryString+'ITEM.u_asseamt,ITEM.BATCHNO,ITEM.expdt,ITEM.mfgdt,'
	SET @QueryString =@QueryString+'ITEM.CGST_PER,ITEM.CGST_AMT,ITEM.SGST_PER,ITEM.SGST_AMT,ITEM.IGST_PER,ITEM.IGST_AMT'
	SET @QueryString =@QueryString+',ITEM.LineRule,ITEM.CCESSRATE,ITEM.COMPCESS,ITEM.GSTRATE,ITEM.gpunit,ITEM.stkunit,ITEM.gpqty'
	SET @QueryString =@QueryString+',ITEM.gprate,ITEM.gstincl'
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
SET @SQLCOMMAND=''
set @sql= cAST(REPLICATE(@Tot_flds,4000) as nvarchar(100))

 SET @SQLCOMMAND = N'select '+@QueryString+''+N''+@Tot_flds+''+' FROM '+@Entry_tbl+'MAIN MAIN'  
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN '+@Entry_tbl+'ITEM  ITEM ON (MAIN.TRAN_CD=ITEM.TRAN_CD AND MAIN.ENTRY_TY=ITEM.ENTRY_TY)' 
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN '+@Entry_tbl+'MAINADD  MADD ON (MAIN.TRAN_CD=MADD.TRAN_CD AND MAIN.ENTRY_TY=MADD.ENTRY_TY)' 
 SET @SQLCOMMAND =	@SQLCOMMAND+' inner join vudyog..Co_mast cm on (cm.compid=MAIN.COMPID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' Left Join vudyog..state st on (cm.state=st.state)'
 SET @SQLCOMMAND=@SQLCOMMAND+ ' where '+ @fcond
 execute sp_executesql @sqlcommand

end

GO


