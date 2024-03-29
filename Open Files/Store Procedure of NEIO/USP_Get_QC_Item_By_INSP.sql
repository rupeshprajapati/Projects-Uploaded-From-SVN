DROP PROCEDURE [USP_Get_QC_Item_By_INSP]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [USP_Get_QC_Item_By_INSP]
@insp_id int
as
begin
declare @SQLCMD NVARCHAR (4000),@colList varchar(1000),@colName varchar(30),@FldLst varchar(1000)

--select @colList=entry_ty from qc_inspection_master where insp_id=@insp_id				-- COMMENTED BY SURAJ DATE ON 11-06-2014 FOR BUG-22163
SELECT  @colList =(CASE WHEN BCODE_NM <> '' THEN BCODE_NM WHEN BCODE_NM = '' THEN ENTRY_TY END)  FROM LCODE WHERE ENTRY_TY IN(SELECT DISTINCT ENTRY_TY FROM  qc_inspection_master WHERE insp_id=@insp_id) -- Added BY SURAJ DATE ON 11-06-2014 FOR BUG-22163
set @colList=isnull(@colList,'')

print isnull(@colList,'Null')
set @FldLst=''
if exists (select * from syscolumns where [name]='BatchNo' and id=object_ID(isnull(@colList,'Null')+'ITEM'))
set @FldLst=@FldLst+'t.Batchno,'
else
set @FldLst=@FldLst+'Batchno=space(10),'

if exists (select * from syscolumns where [name]='mfgdt' and id=object_ID(isnull(@colList,'Null')+'ITEM'))
set @FldLst=@FldLst+'t.mfgdt,'
else
set @FldLst=@FldLst+'mfgdt=cast('''' as datetime),'

if exists (select * from syscolumns where [name]='expdt' and id=object_ID(isnull(@colList,'Null')+'ITEM'))
set @FldLst=@FldLst+'t.expdt,'
else
set @FldLst=@FldLst+'expdt=cast('''' as datetime),'

---------
set @FldLst=''
if exists (select * from syscolumns where [name]='supBatchNo' and id=object_ID(isnull(@colList,'Null')+'ITEM'))
set @FldLst=@FldLst+'t.supBatchno,'
else
set @FldLst=@FldLst+'supBatchno=space(10),'

if exists (select * from syscolumns where [name]='supmfgdt' and id=object_ID(isnull(@colList,'Null')+'ITEM'))
set @FldLst=@FldLst+'t.supmfgdt,'
else
set @FldLst=@FldLst+'supmfgdt=cast('''' as datetime),'

if exists (select * from syscolumns where [name]='supexpdt' and id=object_ID(isnull(@colList,'Null')+'ITEM'))
set @FldLst=@FldLst+'t.supexpdt,'
else
set @FldLst=@FldLst+'supexpdt=cast('''' as datetime),'

---------

--SET @SQLCMD='SELECT s.*,t.item,'+@FldLst+'t.itserial,QC_MAST.QC_PROCESS FROM  qc_inspection_item'				--Commented by Shrikant S. on 26/09/2014 for Bug-23879
SET @SQLCMD='SELECT s.*,t.item,'+@FldLst+'t.itserial,QC_MAST.QC_PROCESS,IT.it_alias FROM  qc_inspection_item'				--Added by Shrikant S. on 26/09/2014 for Bug-23879
SET @SQLCMD=@SQLCMD+' S inner join qc_inspection_master m on (s.insp_id=m.Insp_id) ' 
SET @SQLCMD=@SQLCMD+' inner join '+rtrim(ltrim(@colList))+'ITEM t on (m.tran_cd=t.tran_cd and s.it_code=t.it_code)'
SET @SQLCMD=@SQLCMD+' INNER JOIN QC_PROCESS_MASTER QC_MAST ON s.QC_PROCESS_ID=QC_MAST.QC_PROCESS_ID '
SET @SQLCMD=@SQLCMD+' INNER JOIN IT_MAST IT ON (IT.IT_CODE=S.IT_CODE)'		--Added by Shrikant S. on 26/09/2014 for Bug-23879
SET @SQLCMD=@SQLCMD+' where S.insp_id= '+ cast(@Insp_id as varchar(10))
SET @SQLCMD=@SQLCMD+' and t.ENTRY_TY<>''OS'' '				--Added by Shrikant S. on 26/09/2014 for Bug-23879
PRINT @SQLCMD
EXECUTE SP_EXECUTESQL @SQLCMD

end
GO
