DROP PROCEDURE [USP_REP_DCWISE_REGISTER]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Execute USP_REP_DCWISE_REGISTER '04/01/2016','03/31/2017','ST'
CREATE Procedure [USP_REP_DCWISE_REGISTER]
@SDATE VARCHAR(20),@EDATE VARCHAR(20), @ENTRY_TY VARCHAR(5)
AS 


Declare @fldList Varchar(max),@SqlCmd NVarchar(max),@TaxableFld Varchar(15),@BillFlds Varchar(100),@multi_cur Bit,@Entry_tbl Varchar(2),@Consigneefld Varchar(500)
Declare @IsServItem Bit,@TBLNM as VARCHAR(50),@TBLNAME1 as VARCHAR(50)

Select @TaxableFld=Case when IsservItem=1 Then 'Staxamt' else 'U_ASSEAMT' End 
	,@multi_cur=multi_cur
	,@BillFlds=Case When ENTRY_TY in ('PT','P1','E1') THEN ',a.pinvno as [Bill No.],a.pinvdt as [Bill Date]' else '' end
	,@Entry_tbl=Case when Bcode_nm<>'' then Bcode_nm else (Case when ext_vou=1 then '' else Entry_ty End) end
	,@Consigneefld=Case when consignee=1 then ',Case When Cons_id >0 Then (Case when ac1.mailname<>'''' then ac1.mailname else ac1.ac_name end) else '''' End as [Consignee/Consignor]' else '' end
	,@IsServItem=IsservItem
	From LCODE 
		Where Entry_ty = @ENTRY_TY

			

Select ROWNUMER=IDENTITY (int, 1, 1),Pert_Name,Fld_nm,Head_nm,fcfld_nm=Case when @multi_cur=1 then fcfld_nm else '' end,att_file
,corder=Case when att_file=0 then 'A' else (Case when att_file=1 then 'C' else 'B' end) end+ (case when Code='D' then 'A' else 
				(Case when Code='T' then 'B' else  
					(Case When Code='E' then 'D' else 
						(Case When code='A' then 'E' else 
							(Case When code='S' then 'F' else  
								(Case When code='N' then 'G' else 'H' end)
							end)
						end)
					end)
				end)
			end)
	+case when bef_aft=1 then 'A' else 'B' end+replicate('0',3-len(corder))+rtrim(corder)
,capCount=CONVERT(INT,0) --row_number() over(partition by head_nm order by head_nm)		
Into #tmpDc
From DcMast dc
where Entry_ty = @ENTRY_TY
and Not (ldeactive = 1 and deactfrom between @SDATE and @EDATE)
and head_nm<>''

Declare @rownum Int ,@Head_nm varchar(100),@Fld_nm Varchar(15),@capcount int
Declare capcountcur cursor for
	Select ROWNUMER,Head_nm,Fld_nm from #tmpDc order by ROWNUMER
	
Open capcountcur
Fetch Next from capcountcur Into @rownum,@Head_nm,@Fld_nm 
While @@FETCH_STATUS=0
Begin
	Select @capcount=count(Head_nm) From #tmpDc Where Head_nm=@Head_nm and ROWNUMER<=@rownum
	if @capcount >1
	Begin
		Update #tmpDc set capCount= @capcount,head_nm=@Head_nm+convert(Varchar(5),@capcount) Where Fld_nm=@Fld_nm
	End
	
	Fetch Next from capcountcur Into @rownum,@Head_nm,@Fld_nm 
End
Close capcountcur
Deallocate capcountcur

--Select * From #tmpDc

Insert Into #tmpDc (pert_name,Fld_nm,head_nm,fcfld_nm,att_file,corder) 
	values ('',@TaxableFld,'Taxable Value','',0,'ACB001')

Insert Into #tmpDc (pert_name,Fld_nm,head_nm,fcfld_nm,att_file,corder) 
	values ('','Gro_amt','Gross Amt.','',0,'AIB001')
	
Insert Into #tmpDc (pert_name,Fld_nm,head_nm,fcfld_nm,att_file,corder) 
	values ('','Net_Amt','Invoice Value','',1,'ZZZ001')


select @fldList = STUFF((SELECT  Case when rtrim(pert_name)<>'' then +','+case when att_file=1 then 'a.' else 'b.' end + rtrim(ltrim(pert_name))+' As [% of ('+rtrim(ltrim(Head_nm))+')]' else '' end
							+','+case when att_file=1 then 'a.' else 'b.' end  + rtrim(ltrim(Fld_nm))+' As ['+ rtrim(ltrim(Head_nm))+']'
							+Case when rtrim(fcFld_nm)<>'' then ',' +case when att_file=1 then 'a.' else 'b.' end + rtrim(ltrim(fcFld_nm))+' As [FC '+rtrim(ltrim(Head_nm))+']' else '' end
							
				From #tmpDc
				order by corder
		FOR XML PATH(''), TYPE
		).value('.', 'NVARCHAR(MAX)') 
	,1,0,''
)

Print @fldList
Set @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
				+ (DATEPART(ss, GETDATE()) * 1000 )
				+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
Set @TBLNAME1 = '##TMP1'+@TBLNM

set @SqlCmd='Select a.Inv_no as [Transaction No.], a.Date as [Trans. Date],a.Party_nm as [Party Name]'+@Consigneefld
set @SqlCmd=@SqlCmd+' '+@BillFlds
set @SqlCmd=@SqlCmd+' '+',b.Item_No as [Sr. No.],b.Item as '+case when @IsServItem=1 then '[Service Name]' else '[Goods Name]' end
set @SqlCmd=@SqlCmd+' '+case when @IsServItem=1 then '' else ',b.Qty as [Quantity],b.Rate,(b.qty * b.Rate) as [Asse. Value]' end
set @SqlCmd=@SqlCmd+' '+@fldList
set @SqlCmd=@SqlCmd+' '+',a.Entry_ty,a.Tran_cd,Rownum=ROW_NUMBER() OVER(PARTITION BY a.Entry_ty,a.Tran_cd ORDER BY b.Itserial)'
set @SqlCmd=@SqlCmd+' '+'Into '+@TBLNAME1
set @SqlCmd=@SqlCmd+' '+'From '+@Entry_tbl+'MAIN a'
set @SqlCmd=@SqlCmd+' '+'INNER JOIN '+@Entry_tbl+'ITEM b on(a.Entry_ty=b.Entry_ty and a.Tran_cd=b.Tran_cd)'
set @SqlCmd=@SqlCmd+' '+'INNER JOIN ac_mast ac on (a.Ac_id=ac.Ac_id)'
if @Consigneefld<>''
Begin
	set @SqlCmd=@SqlCmd+' '+'LEFT JOIN ac_mast ac1 on (a.Cons_id=ac1.Ac_id)'
End
set @SqlCmd=@SqlCmd+' '+' Where a.'+Case When @ENTRY_TY in ('PT','P1','E1') then 'pinvdt' else 'date' end+' between '''+Convert(Varchar(50),@SDATE)+''' AND  '''+Convert(Varchar(50),@EDATE)+''' '
set @SqlCmd=@SqlCmd+' AND a.Entry_ty not in (''P1'',''EI'',''SI'',''UB'')'   --Added by Priyanka B on 03072017 for Export
print @SqlCmd
execute sp_executesql @SqlCmd

if Exists(Select Top 1 Fld_nm From #tmpDc Where att_file=1)
Begin
	set @fldList='' 
	set @fldList='Update '+@TBLNAME1+' Set ' 
	select @fldList =@fldList + STUFF((SELECT  Case when rtrim(pert_name)<>'' then +','+ '[% of ('+rtrim(ltrim(Head_nm))+')]=0' else '' end
								+','+'['+ rtrim(ltrim(Head_nm))+']=0'
								+Case when rtrim(fcFld_nm)<>'' then ',' + '[FC '+rtrim(ltrim(Head_nm))+']=0' else '' end
								
					From #tmpDc
					Where att_file=1
			FOR XML PATH(''), TYPE
			).value('.', 'NVARCHAR(MAX)') 
		,1,1,''
	)
	set @SqlCmd=@fldList+' Where Rownum<>1 '	
	execute sp_executesql @SqlCmd
End

set @SqlCmd='Alter table '+@TBLNAME1+ ' drop column rownum'
execute sp_executesql @SqlCmd

set @SqlCmd='Select * From '+@TBLNAME1+ ' Order by [Trans. Date],[Transaction No.]'
execute sp_executesql @SqlCmd
GO
