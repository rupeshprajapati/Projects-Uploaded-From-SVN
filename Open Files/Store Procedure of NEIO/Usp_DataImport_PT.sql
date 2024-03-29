
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='Usp_DataImport_PT')
BEGIN
	DROP PROCEDURE Usp_DataImport_PT
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR	  :	
-- CREATE DATE: 
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO IMPORT PURCHASES.
-- MODIFIED BY: 
-- MODIFY DATE: 
-- REMARK:
-- =============================================

CREATE procedure [dbo].[Usp_DataImport_PT]
@Code Varchar(3),@fName varchar(100),@Loc_Code Varchar(7),@Tbl Varchar (50)
as 
Begin
	Declare @SqlCommand nvarchar(max),@SqlCommand1 nvarchar(max),@UpdateSqlTmp nvarchar(max),@UpdateSql nvarchar(max),@fld_Name varchar(60),@Table_Names Varchar (100),@Table_Name Varchar (100), @pos int
	Declare @TblFldList as VARCHAR(50)
	Declare @UpdateStmt nvarchar(max),@FilterCondition nvarchar(max),@SqlCommnad nvarchar(max)
	Declare @SqlCommand3 nvarchar(max),@UpdateSql3 nvarchar(max)
	
	set @Table_Names=@Tbl
	
	Set @TblFldList = '##TblFldList'+(SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
	select * into #lcode_vw from lcode where entry_ty='PT' -- Lcode View 
		
	execute USP_DataImport_GetFiledSchema @Code,@fName,@Table_Names,@TblFldList

	set @Table_Names=@Table_Names+','
	set @pos=2
	
	while (@pos>1)
	begin
		set @pos=charindex(',',@Table_Names)
		set @Table_Name=substring(@Table_Names,0,@pos)
		set @Table_Names=substring(@Table_Names,@pos+1,len(@Table_Names)-@pos)

		set @SqlCommand=''
		set @UpdateSql=''
		if (@Table_Name<>'')
		begin
		print 'p1'
			Declare Cur_DataImp1 Cursor for select UpdateStmt,FilterCondition from ImpDataTableUpdate where Code=@Code and TableName=@Table_Name order by updOrder
			open Cur_DataImp1
			fetch next from Cur_DataImp1 into @UpdateStmt,@FilterCondition
			while (@@Fetch_Status=0)
			begin
			print 'p2'
				set @SqlCommnad='Update '+@Table_Name+' Set '+rtrim(@UpdateStmt) +' Where '+rtrim(@FilterCondition)
			
				fetch next from Cur_DataImp1 into @UpdateStmt,@FilterCondition
			end
			close Cur_DataImp1
			DeAllocate Cur_DataImp1

			set @SqlCommand1 ='Declare cur_AcMast cursor for select distinct Fld_Name from '+@TblFldList+' where Tbl_Name='+char(39)+@Table_Name+'_'+@fName+char(39)
			execute sp_executesql @SqlCommand1
			open cur_AcMast
			fetch next from cur_AcMast into  @fld_Name
			while (@@fetch_Status=0)	
			begin
				set @UpdateSql=LTRIM(rtrim(@UpdateSql))+ RTRIM(cast(replicate(' ',100) as nvarchar(max)))+',a.['+@fld_name+']=b.['+@fld_name+']'
				set @SqlCommand=rtrim(@SqlCommand)+',['+@fld_Name+']'
				print @SqlCommand
				fetch next from cur_AcMast into  @fld_Name

			end
			close cur_AcMast
			deallocate cur_AcMast
			
--			set @UpdateSqlTmp = 'select * into sss from '+@Table_Name+'_'+@fName
--			EXECUTE SP_EXECUTESQL @UpdateSqlTmp
		
			if (@SqlCommand<>'')
			begin
			print 'p4'
			print substring(@Table_Name,3,5)
			
				if substring(@Table_Name,3,4)='Main'
				begin
				print 'p5'
	
					set @UpdateSqlTmp='Update a set a.compid=b.compid  from '+@Table_Name+'_'+@fName+ ' a inner join vudyog..co_mast b on (a.l_yn=cast(year(b.sta_dt)as varchar(4))+''-''+cast(year(b.end_dt) as varchar(4)) and b.dbname=db_name())'		
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp 
				end

				if substring(@Table_Name,3,4)='Item'
				begin
				print 'p6'
				
					set @UpdateSqlTmp='Update a set a.it_code=b.it_code  from '+@Table_Name+'_'+@fName+ ' a inner join it_mast b on (a.item=b.it_name)'
					Print '5. '+@UpdateSqlTmp
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp
					
					set @UpdateSqlTmp='Update a set a.ac_id=b.ac_id  from '+@Table_Name+'_'+@fName+ ' a inner join ac_mast b on (a.party_nm=b.ac_name)'
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp
					set @UpdateSqlTmp='Update a set a.compid=b.compid  from '+@Table_Name+'_'+@fName+ ' a inner join vudyog..co_mast b on (a.l_yn=cast(year(b.sta_dt)as varchar(4))+''-''+cast(year(b.end_dt) as varchar(4)) and b.dbname=db_name())'		
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp 
					set @UpdateSqlTmp='execute Usp_ItBal_ItBalW'+char(39)+@Table_Name+'_'+@fName+char(39)+','+char(39)+replace(@Table_Name,'item','main')+'_'+@fName+char(39)+','+char(39)+@Table_Name+char(39)+','+char(39)+replace(@Table_Name,'item','main')+char(39)+','+char(39)+replace(@Table_Name,'item','qty')+char(39)
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp
				end

				if substring(@Table_Name,3,5)='acdet'
				begin
				print 'p7'
					set @UpdateSqlTmp='Update a set a.ac_id=b.ac_id  from '+@Table_Name+'_'+@fName+ ' a inner join ac_mast b on (a.ac_name=b.ac_name)'
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp 
					set @UpdateSqlTmp='Update a set a.compid=b.compid  from '+@Table_Name+'_'+@fName+ ' a inner join vudyog..co_mast b on (a.l_yn=cast(year(b.sta_dt)as varchar(4))+''-''+cast(year(b.end_dt) as varchar(4)) and b.dbname=db_name())'		
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp 
					set @UpdateSqlTmp='execute Usp_Import_ac_bal'+char(39)+@Table_Name+'_'+@fName+char(39)+','+char(39)+@Table_Name+char(39)
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp
				end
				
				if substring(@Table_Name,3,5)='Itref'
				begin
				print 'p8'
					set @UpdateSqlTmp='Update a set a.it_code=b.it_code  from '+@Table_Name+'_'+@fName+ ' a inner join it_mast b on (a.item=b.it_name)'
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp
				end
				
				if @Table_Name ='IT_SRTRN'
				begin	
				print 'p9'								
					set @SqlCommand=substring(@SqlCommand,2,len(@SqlCommand)-1)
					set @UpdateSql=substring(@UpdateSql,2,len(@UpdateSql)-1)

					set @SqlCommand3=' insert into '+@Table_Name+' ('+rtrim(@SqlCommand)+',DataImport,ImpKey'+') '+' Select '+rtrim(@SqlCommand)+',DataExport1,TmpKey from '+@Table_Name+'_'+@fName
					set @SqlCommand3=rtrim(@SqlCommand3)+' where DataExport1+TmpKey not in (Select distinct DataImport+ImpKey From '+@Table_Name+')'
				end
				else
				begin
				print 'p10'							
					set @SqlCommand=substring(@SqlCommand,2,len(@SqlCommand)-1)
					set @UpdateSql=substring(@UpdateSql,2,len(@UpdateSql)-1)
					set @SqlCommand3='insert into '+@Table_Name+' ('+rtrim(@SqlCommand)+',DataImport'+') '+' Select '+rtrim(@SqlCommand)+',DataExport1 from '+@Table_Name+'_'+@fName
					set @SqlCommand3=rtrim(@SqlCommand3)+' where DataExport1 not in (Select distinct DataImport From '+@Table_Name+')'
					print @SqlCommand3
				end
								
				set @UpdateSql3=N'Update a set '+LTRIM(rtrim(@UpdateSql))+' from '+@Table_Name+' a inner join '+@Table_Name+'_'+@fName+' b on (a.DataImport=b.DataExport1)'

				Print '2. '				
				print ' Update Statement:- '+@UpdateSql3 
				EXECUTE SP_EXECUTESQL @UpdateSql3	
				Print '2a. '
				print ' Insert Statement:- '+ @SqlCommand3			
				EXECUTE SP_EXECUTESQL @SqlCommand3
				
						
				if substring(@Table_Name,3,4)='Main'
				begin
				print 'p11'
					set @UpdateSql='Update a set a.ac_id=isnull(b.ac_id,0),
												 a.cons_id=isnull(b.ac_id,0)
												 from '+@Table_Name+' a
												 left join PTmain_'+@fName+ ' e on (a.dataimport=e.dataexport1) 
												 left join ac_mast b on (a.party_nm=b.ac_name)'
					Print '3. Main Ac_Id Update : ' +@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql
					
					set @UpdateSql='Update a set a.scons_id=isnull(c.shipto_id,0)
												  from '+@Table_Name+' a
												 inner join PTmain_'+@fName+ ' e on (a.dataimport=e.dataexport1) 
												 inner join shipto c on (e.Scons_name=c.location_id)'
					Print '3. Main Scons_Id Update : ' +@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql

					set @UpdateSql='Update a set a.sac_id=isnull(d.shipto_id,0)  from '+@Table_Name+' a
												 inner join PTmain_'+@fName+ ' e on (a.dataimport=e.dataexport1) 
												 inner join shipto d on (e.Sac_name=d.location_id)'
					
					Print '3.c ' +@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql

					set @UpdateSql='Update PTmain set cons_id=0  where cons_id is null'
					Print 'Update for Nulls 1 : ' +@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql
					
					set @UpdateSql='Update PTmain set sac_id=0  where sac_id is null'
					Print 'Update for Nulls 1 : ' +@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql
					set @UpdateSql='Update PTmain set scons_id=0  where scons_id is null'
					Print 'Update for Nulls 1 : ' +@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql
												 
					Print '3.Main sAc_Id Update : ' +@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql
				end
				if substring(@Table_Name,3,4)='Item'
				begin
				print 'p12'
				set @UpdateSql='Update a set a.ac_id=b.ac_id  from '+@Table_Name+' a inner join ac_mast b on (a.party_nm=b.ac_name)'
					EXECUTE SP_EXECUTESQL @UpdateSql
					Print '4. '+@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql
					
					set @SqlCommand = 'update a set a.Tran_Cd = c.Tran_cd 
					from PTitem_' +@fName+' a 
					inner join  PTmain_'+@fName+ ' b on (a.oldTran_cd=b.oldTran_cd)
					inner join PTmain c on (b.dataExport1=c.dataimport)'
					Print '6. '
					print @SqlCommand					
					EXECUTE SP_EXECUTESQL @SqlCommand
					set @SqlCommand = 'update a set a.Tran_cd=b.Tran_cd
					from PTitem a 
					inner join PTitem_'+@fName+' b on (a.dataimport=b.dataExport1)
					inner join PTmain_'+@fName+' c on(b.oldTran_cd=c.OldTran_cd)'
					Print '7. '
					print @SqlCommand
					EXECUTE SP_EXECUTESQL @SqlCommand
				end
				
				if substring(@Table_Name,3,5)='Acdet'
				begin
				print 'p13'
				set @UpdateSql='Update a set a.ac_id=b.ac_id  from '+@Table_Name+' a inner join ac_mast b on (a.ac_name=b.ac_name)'
					EXECUTE SP_EXECUTESQL @UpdateSql 

					Print '14. '+@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql

					set @SqlCommand = 'update a set a.Tran_Cd = c.Tran_cd 
					from PTacdet_' +@fName+' a 
					inner join  PTmain_'+@fName+ ' b on (a.oldTran_cd=b.oldTran_cd)
					inner join PTmain c on (b.dataExport1=c.dataimport)'
					Print '15. '
					print @SqlCommand					
					EXECUTE SP_EXECUTESQL @SqlCommand
					set @SqlCommand = 'update a set a.Tran_cd=b.Tran_cd
					from PTacdet a 
					inner join PTacdet_'+@fName+' b on (a.dataimport=b.dataExport1)
					inner join PTmain_'+@fName+' c on(b.oldTran_cd=c.OldTran_cd)'
					Print '16. '
					print @SqlCommand
					EXECUTE SP_EXECUTESQL @SqlCommand
				end
				
				if substring(@Table_Name,3,5)='Mall'
				begin
					print 'p14'
					set @SqlCommand = 'update a set a.ac_id=c.ac_id,a.Tran_Cd = c.Tran_cd 
					from PTmall_' +@fName+' a 
					inner join  PTmain_'+@fName+ ' b on (a.oldTran_cd=b.oldTran_cd)
					inner join PTmain c on (b.dataExport1=c.dataimport)'
					Print '15. '
					print @SqlCommand					
					EXECUTE SP_EXECUTESQL @SqlCommand
					set @SqlCommand = 'update a set a.ac_id=c.ac_id,a.Tran_cd=b.Tran_cd
					from PTmall a 
					inner join PTmall_'+@fName+' b on (a.dataimport=b.dataExport1)
					inner join PTmain_'+@fName+' c on(b.oldTran_cd=c.OldTran_cd)'
					Print '16. '
					print @SqlCommand
					EXECUTE SP_EXECUTESQL @SqlCommand
					set @UpdateSqlTmp='Update a set a.compid=b.compid  from '+@Table_Name+'_'+@fName+ ' a inner join vudyog..co_mast b on (a.l_yn=cast(year(b.sta_dt)as varchar(4))+''-''+cast(year(b.end_dt) as varchar(4)) and b.dbname=db_name())'
					EXECUTE SP_EXECUTESQL @UpdateSqlTmp 
				end
				
				if substring(@Table_Name,3,5)='Itref'
				begin
				print 'p15'
					set @SqlCommand = 'update a set a.Tran_Cd = c.Tran_cd 
					from PTitref_' +@fName+' a 
					inner join  PTmain_'+@fName+ ' b on (a.oldTran_cd=b.oldTran_cd)
					inner join PTmain c on (b.dataExport1=c.dataimport)'
					Print '15. '
					print @SqlCommand					
					EXECUTE SP_EXECUTESQL @SqlCommand
					set @SqlCommand = 'update a set a.Tran_cd=b.Tran_cd,a.it_code=i.it_code
					from PTitref a 
					inner join PTitref_'+@fName+' b on (a.dataimport=b.dataExport1)
					inner join PTmain_'+@fName+' c on(b.oldTran_cd=c.OldTran_cd)
					inner join PTitem_'+@fName+' i on(a.item=i.item)'
					Print '16. '
					print @SqlCommand
					EXECUTE SP_EXECUTESQL @SqlCommand
				end
				
----xxxxx Gen_SRNo Generation xxxxx----
				if substring(@Table_Name,3,4)='GEN_SRNO'
				begin
				print 'p16'
					set @SqlCommand = 'update a set  a.Tran_Cd = c.Tran_Cd 
						from gen_srno a 
						inner join PTmain_' +@fName+' b on (a.Tran_cd=b.oldTran_cd)
						inner join PTmain c on (b.DataExport1=c.DataImport)'
					Print '11. ' +@SqlCommand
					EXECUTE SP_EXECUTESQL @SqlCommand
				End
----xxxxx Gen_SRNo Generation xxxxx----
											
				if @Table_Name='IT_SRTRN'
				begin
				print 'p17'								
					set @SqlCommand ='update a set  a.Tran_Cd = c.Tran_Cd 
					from it_SrTrn a
					inner join PTmain_' +@fName+' b on (a.Tran_cd=b.oldTran_cd)
					inner join PTmain c on (b.DataExport1=c.DataImport)'
					EXECUTE SP_EXECUTESQL @SqlCommand
					UPDATE T SET iTran_cd = S.iTran_cd,It_code=s.It_Code from IT_SRTRN T INNER JOIN  IT_SRSTK S ON  S.ImpKey=T.ImpKey
				End
			end
		end
	end
----xxxxx Doc_no Generation xxxxx----
	declare @Sdate varchar(10),@Edate varchar(10)
	set @Sdate =''
	set @Edate =''
	print 'p18'
	
	set @UpdateSql='select @EdateOut=max(convert(varchar(10),date,103)) from PTMAIN_'+@fName
	Print '11. '+@UpdateSql
	EXECUTE SP_EXECUTESQL @UpdateSql,N'@EdateOut varchar(10) output',@EdateOut=@Edate output
	set @UpdateSql='select @SdateOut=min(convert(varchar(10),date,103)) from PTMAIN_'+@fName
	Print '12. '+@UpdateSql
	EXECUTE SP_EXECUTESQL @UpdateSql,N'@SdateOut varchar(10) output',@SdateOut=@Sdate output
	print isnull(@Sdate,'NULL')
	print isnull(@Edate,'NULL')
	if isnull(@Sdate,'')<>'' or isnull(@Edate,'')<>''
		execute Usp_DocNo_Renumbering 'PT',@Sdate,@Edate,''
----xxxxx Doc_no Generation xxxxx----

----xxxxx Gen_Inv Updation xxxxx----	
	declare @FinYear varchar(9)
	set @UpdateSql='select distinct l_yn into ##FinYear from PTMAIN_'+@fName
	Print '13. '+@UpdateSql
	EXECUTE SP_EXECUTESQL @UpdateSql
	while exists( select top 1 l_yn from ##FinYear)
	begin
		select top 1 @FinYear=l_yn from ##FinYear
		print 'Found :' + @FinYear
		execute Usp_Gen_Inv_Updation 'PT',@FinYear
		delete from ##FinYear where l_yn=@FinYear
	end
	drop table ##FinYear
----xxxxx Gen_Inv Updation xxxxx----	
end

