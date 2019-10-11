If Exists(Select [name] From SysObjects Where xType='P' and [name]='Ent_Item_wise_Pickup_export')
Begin
	Drop Procedure Ent_Item_wise_Pickup_export
End
GO
-- =============================================
-- Description:	This is useful for Item wise Pickup of Purchase Quotation entries in Sales Quotation Export.
-- =============================================
CREATE Procedure [dbo].[Ent_Item_wise_Pickup_export]
(
	@paraEntry_Ty Varchar(2),
	@paraTran_Cd Int,
	@paraCDept as Varchar(20),
	@paraIt_name as Varchar(50),
	@paraLcrule as varchar(20),
	@paraLProd as varchar(10),
	@paraLcdate as varchar(20),
	@paraWarenm as varchar(50)=null
	--@refEntry_Ty Varchar(2),
	--@refTran_Cd Int
)
As
/* Internale Variable declaration and Assigning [Start] */
print @paraLcrule  
DECLARE @Fld_Nm Varchar(10),@Pert_Name Varchar(10),@entry_ty Varchar(2),@data_ty varchar(20),@zdata_ty varchar(20),@att_file bit,@tblname varchar(20),@vouchrg varchar(max)
DECLARE @FldName Varchar(max),@FldPerName Varchar(max),@Qrystr1 nVarchar(max),@Qrystr2 nVarchar(max),@Qrystr3 nVarchar(max),@Qrystr4 nVarchar(max),@Qrystr5 nVarchar(max),@Qrystr6 nVarchar(max)
Declare @Qrystr7 nVarchar(max)

SELECT @FldName = '',@FldPerName = '',@Qrystr1 = '',@Qrystr2 = '', @Qrystr3 = '', @Qrystr4 = '', @Qrystr5 = '',@Qrystr6 = '',@vouchrg=''
Select @Qrystr7= ''
DECLARE @ItemType varchar(100),@it_code int,@QcEnabledItem bit
set @ItemType=''
set @it_code=0
set @QcEnabledItem=0
select @ItemType=Type,@it_code=it_code from it_mast where it_code=@paraIt_name 

print @it_code
print @paraIt_name

Declare @TBLNM Varchar(50),@TBLNAME1 Varchar(50),@TBLNAME2 Varchar(50),
	@TBLNAME3 Varchar(50),@TBLNAME4 Varchar(50),
	@SQLCOMMAND as NVARCHAR(4000)

Select @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
		+ (DATEPART(ss, GETDATE()) * 1000 )+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
		
Select @TBLNAME1 = '##TMP1'+@TBLNM,@TBLNAME2 = '##TMP2'+@TBLNM
Select @TBLNAME3 = '##TMP3'+@TBLNM,@TBLNAME4 = '##TMP4'+@TBLNM
/* Internale Variable declaration and Assigning [End] */

declare @itempickdt varchar(20)
select top 1 @itempickdt=ltrim(rtrim(str(day(itempickdt))))+'/'+ltrim(rtrim(str(month(itempickdt))))+'/'+ltrim(rtrim(str(Year(itempickdt)))) from manufact

set @Qrystr1 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.WARE_NM,'

print @Fld_Nm
DECLARE lotherCur CURSOR FOR 
	Select distinct Fld_Nm,Data_ty,att_file From lother
		Where e_code in ('PQ')
		and inpickup = 1
OPEN lotherCur

FETCH NEXT FROM lotherCur INTO @Fld_Nm,@Data_ty,@att_file

WHILE @@FETCH_STATUS = 0
   BEGIN
	  IF @Fld_Nm IS NOT NULL AND @Fld_Nm <> ''	
	  BEGIN	
			set @zdata_ty=case when @data_ty='Decimal' then ' 0 as ' else 'space(1) as' end 		
			set @tblname =case when @att_file=1 then 'MAIN' else 'ITEM' end
		  SET @FldName = @FldName+'b.'+LTrim(RTrim(@Fld_Nm))+','
			---PQITem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'PQ'+ltrim(rtrim(@tblname)) ))
			Begin 
				set @Qrystr1 = @Qrystr1 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr1 = @Qrystr1 +@zdata_ty + LTrim(RTrim(@Fld_Nm))  +','
			end 
	  END
      FETCH NEXT FROM lotherCur INTO @Fld_Nm,@Data_ty,@att_file;
  END

CLOSE lotherCur
DEALLOCATE lotherCur
declare @zsqlfld varchar(255)
select @zsqlfld =''
	
DECLARE DcmastCur CURSOR FOR 
	Select distinct Fld_Nm,Pert_Name,att_file From Dcmast
		Where Entry_Ty in ('PQ') AND stkval = 1
OPEN DcmastCur

FETCH NEXT FROM DcmastCur INTO @Fld_Nm,@Pert_Name,@att_file

WHILE @@FETCH_STATUS = 0
   BEGIN
	  IF @Fld_Nm IS NOT NULL AND @Fld_Nm <> ''	
	  BEGIN	
		  SET @FldName = @FldName+'b.'+LTrim(RTrim(@Fld_Nm))+','
			---PQITem
			set @tblname =case when @att_file=1 then 'MAIN' else 'ITEM' end
			if exists(select b.[name] from syscolumns a join sysobjects b on a.id=b.id  where a.[name] = LTrim(RTrim(@Fld_Nm)) and b.[name] ='PQ'+ltrim(rtrim(@tblname)))
			Begin 
				set @Qrystr1 = @Qrystr1 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
				if @att_file=1
				set @vouchrg = case when len(@vouchrg)>0 then @vouchrg+',' + LTrim(RTrim(@Fld_Nm)) +'=(('+LTrim(RTrim(@Fld_Nm))+'* qty * Rate)/Rateper)/asseamt1' else +LTrim(RTrim(@Fld_Nm)) +'=(('+LTrim(RTrim(@Fld_Nm))+'* qty * Rate)/Rateper)/asseamt1' end
			end
			else
			Begin
				set @Qrystr1 = @Qrystr1 +' 0 as ' + LTrim(RTrim(@Fld_Nm))  +','
			end 
	  END

	  IF @Pert_Name IS NOT NULL AND @Pert_Name <> ''	
	  BEGIN	
		  SET @FldPerName = @FldPerName+'b.'+LTrim(RTrim(@Pert_Name))+','
			set @tblname =case when @att_file=1 then 'MAIN' else 'ITEM' end
			---PQITem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Pert_Name)) and id in (select id from sysobjects where [name] ='PQ'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr1 = @Qrystr1 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Pert_Name))  +','
			end
			else
			Begin
				set @Qrystr1 = @Qrystr1 +' 0 as ' + LTrim(RTrim(@Pert_Name))  +','
			end
	  END
      FETCH NEXT FROM DcmastCur INTO @Fld_Nm,@Pert_Name,@att_file;
  END

CLOSE DcmastCur
DEALLOCATE DcmastCur
DECLARE @Select as Bit,@SQLStr nVarchar(Max),
	@ParmDefinition nvarchar(500)

DECLARE	@SQLStr_1 nVarchar(Max) 
set @SQLStr_1=''

SET @Qrystr1  = LEFT(LTrim(RTrim(@Qrystr1 )),Len(LTrim(RTrim(@Qrystr1 )))-1)

set @SQLStr = 'SELECT '+replace(replace(replace(@Qrystr1,'I.',''),'M.',''),'Q.','') +' into ##table22 
FROM (select '+@Qrystr1+' 
from PQITEM I join PQMAIN M on (I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date)) PQitem '
print @SQLStr
EXECUTE sp_executesql @SQLStr

print 'abc'

select a.*,asseamt1=(select sum(u_asseamt) from ##table22 b where b.tran_cd=a.tran_cd and b.entry_ty=a.entry_ty ),c.rateper into ##table11 from ##table22 a left join it_mast c on a.it_code=c.it_code

if LEN(RTRIM(ltrim(@vouchrg)))>0
begin
	set @vouchrg=replace(@vouchrg,'asseamt1','(Case when asseamt1=0 then 1 else asseamt1 end)')
	set @SQLStr = 'Update ##table11 SET '+@vouchrg+' Where asseamt1 > 0 '
	EXECUTE sp_executesql @SQLStr
end

print @vouchrg
print '@FldName : ' + @FldName

IF @FldName IS NOT NULL AND @FldName <> ''
begin
	SET @FldName = LEFT(LTrim(RTrim(@FldName)),Len(LTrim(RTrim(@FldName)))-1)
end

IF @FldPerName IS NOT NULL AND @FldPerName <> ''
begin
	SET @FldPerName = LEFT(LTrim(RTrim(@FldPerName)),Len(LTrim(RTrim(@FldPerName)))-1)
end

IF @FldName IS NOT NULL AND @FldName <> ''
BEGIN 
	IF @FldPerName IS NOT NULL AND @FldPerName <> ''
	BEGIN
		SELECT @FldName = LTrim(RTrim(@FldName))+','		
	END
END	

print 'abc-1'

SELECT @Select = 0

--SET @ParmDefinition = N'@Select Bit,@paraEntry_Ty Varchar(2),@paraTran_Cd Int,@paraLcDate varchar(20),@refEntry_Ty Varchar(2),@refTran_Cd Int';
SET @ParmDefinition = N'@Select Bit,@paraEntry_Ty Varchar(2),@paraTran_Cd Int,@paraLcrule varchar(20),@paraLcDate varchar(20)';
	SELECT @SQLStr = 'set dateformat dmy Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
	a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
	a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
	a.u_beno,a.U_pinvdt,B.It_Code,isnull(c.Entry_ty,'''') as Entry_ty ,isnull(c.Tran_cd,0) as Tran_cd,a.Date,a.Doc_No,isnull(c.Itserial,'''') as Itserial ,
	isnull(c.REntry_Ty,'''') as _REntry_Ty,isnull(c.Itref_Tran,0) as _Itref_Tran,isnull(c.RItserial,'''') as _RItserial,
	Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
	b.Itserial as RItserial,b.u_asseamt,b.Qty ,b.rate,isnull((select Qty from ##table11 where 1=2),0) As adjqty ,
	isnull((select Qty from ##table11 where 1=2),0) As adjrepqty,isnull((select sum(rqty) from othitref where  entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) as RQty
	,b.Qty-isnull((select sum(rqty) from othitref where  entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty  and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0)
	As BalQty,B.TAX_NAME,B.TAXAMT,'

IF @FldName = '' AND @FldPerName = ''
	BEGIN 
		SET @SQLStr = LEFT(LTrim(RTrim(@SQLStr)),Len(LTrim(RTrim(@SQLStr)))-1)
	END	
ELSE
	BEGIN
		SELECT @SQLStr = @SQLStr+@FldName+@FldPerName
	END

	select case when exists(select itref_tran from othitref where  entry_ty not in('GC','GD') and rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial)
		or exists(select tran_cd from ##table11 where entry_ty=eou_itref_vw.rentry_ty and tran_cd=eou_itref_vw.itref_tran and itserial=eou_itref_vw.ritserial and qty<>eou_itref_vw.rqty)
		then tran_cd else itref_tran end as itref_tran
		,case when exists(select itref_tran from othitref where  entry_ty not in('GC','GD') and rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial)
		or exists(select tran_cd from ##table11 where entry_ty=eou_itref_vw.rentry_ty and tran_cd=eou_itref_vw.itref_tran and itserial=eou_itref_vw.ritserial and qty<>eou_itref_vw.rqty)
		then entry_ty else rentry_ty end as entry_ty
		,case when exists(select itref_tran from othitref where  entry_ty not in('GC','GD') and rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial)
		or exists(select tran_cd from ##table11 where entry_ty=eou_itref_vw.rentry_ty and tran_cd=eou_itref_vw.itref_tran and itserial=eou_itref_vw.ritserial and qty<>eou_itref_vw.rqty)
		then Itserial else RItserial end as Itserial
		,eou_itref_vw.rEntry_ty,eou_itref_vw.Itref_tran as RTran_Cd,eou_itref_vw.Ritserial
		into ##tableitref1 from eou_itref_vw where entry_ty in ('PQ')
		and Entry_ty+convert(varchar(10),tran_cd) not in ( select rentry_ty+convert(varchar(10),itref_tran) from eou_itref_vw 
		where entry_ty in ('PQ'))

		SELECT @SQLStr = @SQLStr+' into ##tableitref11  From AC_Mast,IT_Mast,EOU_LMain_vw a,##table11 b		
		Left Join othitref c ON (B.Entry_Ty = C.REntry_Ty AND B.Tran_cd = C.ITREF_Tran AND B.Itserial = C.RItserial ) '
		--inner join autotranref d on (b.entry_ty=d.rentry_ty and b.tran_cd=d.rtran_cd and b.itserial=d.ritserial 
		--and d.entry_ty='''+@refEntry_Ty+''' and d.tran_cd='+rtrim(ltrim(str(@refTran_cd)))+')'
		+' WHERE a.Entry_Ty = B.Entry_Ty AND a.Tran_cd = b.Tran_cd 
		AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PQ'')
		And a.Date<= '''+@paraLcDate+'''
		And (a.Date>= '''+@itempickdt+''' or a.entry_ty=''OS'')
		AND A.Ac_Id = Ac_Mast.Ac_Id 
		and a.tran_cd not in (select ITREF_Tran from ##tableitref1 where entry_ty=a.entry_ty ) '

	If RTrim(@paraCDept) <> ''
	Begin
		SELECT @SQLStr = @SQLStr+'AND I.Dept = '+Char(39)+RTrim(@paraCDept)+Char(39)
	End

	if rtrim(@parawarenm)<>''
	Begin
		SELECT @SQLStr = @SQLStr+'AND b.ware_nm = '+Char(39)+RTrim(@parawarenm)+Char(39)
	End
	
	If RTrim(@paraIt_name) <> ''
	Begin
		SELECT @SQLStr = @SQLStr+'AND It_Mast.It_code = '+Char(39)+RTrim(@paraIt_name)+Char(39)
	End
	
SELECT @SQLStr = @SQLStr+char(13)+@SQLStr_1+' order by a.date'
print @sqlstr
print @paraLcrule
EXECUTE sp_executesql @SQLStr , @ParmDefinition,@Select = @Select,	@paraTran_Cd = @paraTran_Cd,@paraEntry_Ty = @paraEntry_Ty, @paraLcrule = @paraLcrule,@paraLcdate = @paraLcdate
--,@refEntry_ty=@refEntry_ty,@refTran_cd=@refTran_cd

select a.*,refEntry_ty=b.Rentry_ty,refTran_cd=b.RTran_cd,refItserial=b.ritserial Into ##tableitref22 from ##tableitref11 a
	Inner join ##tableitref1 b on (a.rentry_ty=b.Entry_ty and a.itref_tran=b.Itref_Tran and a.rItserial=b.Itserial)

set @SQLStr='Select refEntry_ty,RefTran_cd,refItserial,u_asseamt=sum(u_asseamt),refqty=Sum(qty),Taxamt=sum(taxamt) Into ##tableitref33 from ##tableitref22 '
set @SQLStr=@SQLStr+' '+'Group by refEntry_ty,RefTran_cd,refItserial'
print @SQLStr
EXECUTE sp_executesql @SQLStr 

Declare @fldList Varchar(4000)
set @SQLStr=''
Select @fldList=isnull(substring((Select ', '+Rtrim(sc.[Name])+'=isnull(b.'+Rtrim(sc.[Name])+',0)' From tempdb..syscolumns sc inner join tempdb..sysobjects so on sc.id = so.id where so.[name] = '##tableitref33' and sc.[Name] Not In ('refEntry_ty','RefTran_cd','refItserial','refQty') For XML Path('')),2,2000),'')
set @fldList=case when @fldList is null then '' else @fldList end
print @fldList
if @fldList<>''
Begin
	set @SQLStr='Update ##tableitref11 Set '+@fldList+' from ##tableitref33 b Inner join ##tableitref11 a on (a.rentry_ty=b.refEntry_ty and a.Itref_tran=b.refTran_cd and a.rItserial=b.refItserial)'
	set @SQLStr=@SQLStr+' '+'where a.rentry_ty+cast(a.itref_tran as varchar(10))+a.ritserial Not in (select rentry_ty+cast(itref_tran as varchar(10))+ritserial  from ##tableitref1 ) 	'
	print @SQLStr
	EXECUTE sp_executesql @SQLStr 
End

select a.*,b.refQty from ##tableitref11 a
	left Join ##tableitref33 b on (b.refEntry_ty=a.Rentry_ty and b.refTran_cd=a.itref_tran and b.refItserial=a.rItserial)
	where rentry_ty+cast(itref_tran as varchar(10))+ritserial not in (select entry_ty+cast(itref_tran as varchar(10))+itserial  from ##tableitref1 ) 		--vasant
	
drop table ##table11
drop table ##table22
drop table ##tableitref1
drop table ##tableitref11
drop table ##tableitref22
drop table ##tableitref33
