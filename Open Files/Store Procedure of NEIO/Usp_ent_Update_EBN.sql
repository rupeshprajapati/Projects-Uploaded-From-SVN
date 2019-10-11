If Exists (Select [Name] From SysObjects Where xType='P' and [Name]='Usp_ent_Update_EBN')
Begin
	Drop Procedure Usp_ent_Update_EBN
End
Go
Create Procedure Usp_ent_Update_EBN
@Inv_no Varchar(20),@ebn Varchar(25),@ewbdt Datetime,@ewb_validity Datetime,@ewbqrcode image,@pEntry_ty Varchar(2),@Invdt Smalldatetime 
AS
Declare @Tran_cd Numeric(10,0),@Entry_ty Varchar(2),@tbl_nm Varchar(10),@sqlcmd Nvarchar(4000)
DECLARE @ParmDefinition nvarchar(500)

set @Tran_cd=0
Select Top 1 @Tran_cd=Tran_Cd,@Entry_ty=Entry_ty from Lmain_vw where rtrim(Inv_no)=rtrim(@Inv_no) and Entry_ty=@pEntry_ty and Date=@Invdt

If @Tran_cd >0
Begin
	SET @ParmDefinition = N'@ewayn image'
	
	
	Select @tbl_nm=Case when bcode_nm<>'' then Bcode_nm else (Case when ext_vou=1 then '' else Entry_ty end) end+'Main' from Lcode Where Entry_ty=@Entry_ty
	set @sqlcmd ='Update '+@tbl_nm+' Set EWBN ='''+case when year(@ewbdt)<=1900 then 'Cancelled' else RTRIM(@ebn) end+''',ewbdt='''+Convert(varchar(50),@ewbdt)+''',EWBVTD='''+Convert(varchar(50),@ewb_validity)
			+''',EWBVTT='''+Convert(varchar(50),@ewb_validity,108)+''', EWBVFD='''+Convert(varchar(50),@ewbdt)+''',EWBVFT='''+Convert(varchar(50),@ewbdt,108)+'''
				,ewbqrcode=@ewayn Where Entry_ty='''+ @Entry_ty+''' and Tran_cd='+Convert(varchar(10),@Tran_cd)
	execute sp_executesql @sqlcmd , @ParmDefinition,@ewayn= @ewbqrcode
	
End
print 'a'

if year(@ewbdt)>2017
Begin
	Insert Into EwaybillDet(DocNo,EBN,EWBDT,VALID_UPTO,EWBStatus,EWBLogTime) values (@Inv_no,@ebn,@ewbdt,@ewb_validity,'Generated',getdate())
end
else
begin
	
	--set @sqlcmd ='Select Top 1 @ewayn=EWBN from '+@tbl_nm+' Where Entry_ty='''+ @Entry_ty+''' and Tran_cd='+Convert(varchar(10),@Tran_cd)
	--SET @ParmDefinition = N'@ewayn varchar(25) OUTPUT';
	--execute sp_executesql @sqlcmd , @ParmDefinition, @ewayn=@ebn OUTPUT;
	
	Insert Into EwaybillDet(DocNo,EBN,EWBDT,VALID_UPTO,EWBStatus,EWBLogTime) values (@Inv_no,@ebn,@ewbdt,@ewb_validity,'Cancelled',getdate())
End

