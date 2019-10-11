DROP PROCEDURE [Usp_DataImport_Account_Master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- AUTHOR	  :	
-- CREATE DATE: 
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO IMPORT ACCOUNT MASTER.
-- MODIFIED BY: PRIYANKA B. FOR BUG-30849
-- MODIFY DATE: 26/12/2017
-- REMARK:
-- =============================================

CREATE procedure [Usp_DataImport_Account_Master]
@Code Varchar(3),@fName varchar(100),@Loc_Code Varchar(7),@Tbl Varchar (50)
as 
Begin
	Declare @SqlCommand nvarchar(max),@SqlCommand1 nvarchar(max),@UpdateSql nvarchar(max),@PreUpdateSql nvarchar(max),@fld_Name varchar(60),@Table_Names Varchar (100),@Table_Name Varchar (100), @pos int -- Changed by Archana K. on 16/10/2012 for Bug-5837
	Declare @TblFldList as VARCHAR(50)
	Declare @UpdateStmt nvarchar(max),@FilterCondition nvarchar(max),@SqlCommnad nvarchar(max) -- Changed by Archana K. on 16/10/2012 for Bug-5837
	Declare @SqlCommand3 nvarchar(max),@UpdateSql3 nvarchar(max)		-- Changed by Archana K. on 09-04-2013

	--set @Table_Names='PTMain,PTItem,PTAcDet,PTItRef,PTMall'
	set @Table_Names=@tbl
	
	Set @TblFldList = '##TblFldList'+(SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000)
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
	select * into #lcode_vw from lcode where entry_ty='AR' -- Lcode View 
--	select * from #lcode_vw
	--print @TblFldList
	--execute USP_DataImport_GetFiledSchema @Code,@fName,'PTMain,PTItem,PTAcDet,PTItRef,PTMall',@TblFldList
	execute USP_DataImport_GetFiledSchema @Code,@fName,@Table_Names,@TblFldList
	print 'a '+@TblFldList

	set @Table_Names=@Table_Names+','
	set @pos=2
	while (@pos>1)
	begin
	set @pos=charindex(',',@Table_Names)
		set @Table_Name=substring(@Table_Names,0,@pos)
		print @pos
		set @Table_Names=substring(@Table_Names,@pos+1,len(@Table_Names)-@pos)
		Print '@Table_name->'+@Table_Names	
		Print '@Code-->'+@Code
		set @SqlCommand=''
		set @UpdateSql=''
		if (@Table_Name<>'')
		begin
/*--->Blow Part is for future use : when ST entry shoud imported as PT in some company.*/
			Declare Cur_DataImp1 Cursor for select UpdateStmt,FilterCondition from ImpDataTableUpdate where Code=@Code and TableName=@Table_Name order by updOrder
			open Cur_DataImp1
			fetch next from Cur_DataImp1 into @UpdateStmt,@FilterCondition
			while (@@Fetch_Status=0)
			begin
				set @SqlCommnad='Update '+@Table_Name+' Set '+rtrim(@UpdateStmt) +' Where '+rtrim(@FilterCondition)
				--print @SqlCommnad
				--execute sp_executesql @SqlCommnad
				fetch next from Cur_DataImp1 into @UpdateStmt,@FilterCondition
			end
			close Cur_DataImp1
			DeAllocate Cur_DataImp1
/*<---*/
			set @SqlCommand1 ='Declare cur_AcMast cursor for select distinct Fld_Name from '+@TblFldList+' where Tbl_Name='+char(39)+@Table_Name+'_'+@fName+char(39)
			print @SqlCommand1
			execute sp_executesql @SqlCommand1
			open cur_AcMast
			fetch next from cur_AcMast into  @fld_Name
			while (@@fetch_Status=0)	
			begin
				
				set @UpdateSql=LTRIM(rtrim(@UpdateSql))+ RTRIM(cast(replicate(' ',100) as nvarchar(max)))+',a.['+@fld_name+']=b.['+@fld_name+']' -- Changed by Archana K. on 16/10/2012 for Bug-5837
				set @SqlCommand=rtrim(@SqlCommand)+',['+@fld_Name+']'
				
				fetch next from cur_AcMast into  @fld_Name

			end
			close cur_AcMast
			deallocate cur_AcMast
			
		
			--print 'aaa '+@SqlCommand
			Print 'aaa'+@SqlCommand
			if (@SqlCommand<>'')
			begin

				set @SqlCommand=substring(@SqlCommand,2,len(@SqlCommand)-1)
				set @UpdateSql=substring(@UpdateSql,2,len(@UpdateSql)-1)
				
				set @SqlCommand3=' insert into '+@Table_Name+' ('+rtrim(@SqlCommand)+',DataImport'+') '+' Select '+rtrim(@SqlCommand)+',DataExport1 from '+@Table_Name+'_'+@fName
--				set @SqlCommand=rtrim(@SqlCommand)+' where '+char(39)+@Loc_Code+char(39)+'+sEntry_ty+cast(Tran_cd as Varchar) not in (Select distinct DataImport From '+@Table_Name+')'
				set @SqlCommand3=rtrim(@SqlCommand3)+' where ac_name not in (Select distinct ac_name From '+@Table_Name+' ) and DataExport1 not in (Select distinct DataImport From '+@Table_Name+')'
				print ' Insert Statement:- '+ @SqlCommand3  --Added by Priyanka B on 27022019 for Bug-31707
				EXECUTE SP_EXECUTESQL @SqlCommand3  --Added by Priyanka B on 27022019 for Bug-31707

--				set @UpdateSql='Update a set '+rtrim(@UpdateSql)+' from '+@Table_Name+' a inner join '+@Table_Name+'_'+@fName+' b on (a.DataImport=b.DataExport1)'-- Commented by Archana K. on 16/10/2012 for Bug-5837
				set @UpdateSql3=N'Update a set '+LTRIM(rtrim(@UpdateSql))+' from '+@Table_Name+' a inner join '+@Table_Name+'_'+@fName+' b on (a.DataImport=b.DataExport1)'-- Changed by Archana K. on 16/10/2012 for Bug-5837 
				--print ' Insert Statement:- '+ @SqlCommand3  --Commented by Priyanka B on 27022019 for Bug-31707
				print ' Update Statement:- '+@UpdateSql3 
				EXECUTE SP_EXECUTESQL @UpdateSql3				
				--EXECUTE SP_EXECUTESQL @SqlCommand3  --Commented by Priyanka B on 27022019 for Bug-31707

				if @Table_Name='AC_MAST'
				begin
					set @UpdateSql='update a set a.ac_group_id=b.ac_group_id from ac_mast a inner join ac_group_mast b on (a.[group]=b.ac_group_name)'
					print ' Update Ac_Group_ID :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql		

					set @UpdateSql='update a set a.ac_type_id=b.ac_type_id from ac_mast a inner join ac_type_mast b on (a.typ=b.typ)'
					print ' Update TypeID :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql		

					-- ' Update Country ID :-We have to Export Country Table Inorder to update this'
					-- ' Update City ID :-We have to Export City Table Inorder to update this  '
					-- ' Update State ID :-We have to Export State Table Inorder to update this '

--Added by Priyanka B on 26122017 for Bug-30849 Start
					set @UpdateSql='update a set a.city_id=b.city_id
						from ac_mast a inner join city b on (b.city=a.city)'
					print ' Update city_id :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql
					
					set @UpdateSql='update a set a.state_id=b.state_id
						from ac_mast a inner join state b on (b.state=a.state)'
					print ' Update state_id :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql
					
					set @UpdateSql='update a set a.country_id=b.country_id
						from ac_mast a inner join country b on (b.country=a.country)'
					print ' Update country_id :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql
--Added by Priyanka B on 26122017 for Bug-30849 End

					set @UpdateSql='update AC_MAST set country_id=251 where country_id is NULL'
					print ' Update ContryID :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql		

				end
				
				if @Table_Name='ShipTo'
				begin
					---Birendra : Bug-20512  on 13/02/2014:Start:

--					set @UpdateSql='update a set  a.ac_id=b.ac_id 
--						from shipto a inner join shipto_'+@fName+' c on (a.dataimport=c.dataexport1) 
--						inner join ac_mast_'+@fName+' d on (c.ac_id=d.ac_id) 
--						inner join ac_mast b on (b.dataimport=d.dataexport1)'
--					print ' Update shipto :- '+@UpdateSql 
--					EXECUTE SP_EXECUTESQL @UpdateSql	

--Added by Priyanka B on 26122017 for Bug-30849 Start
					set @UpdateSql='update a set a.ac_id=b.ac_id
						from shipto a 
						inner join shipto_'+@fName+' c on (a.dataimport=c.dataexport1) 
						inner join ac_mast_'+@fName+' d on (d.ac_id=c.ac_id) 
						inner join ac_mast b on (b.dataimport=d.dataexport1)'						
					print ' Update shipto :- '+@UpdateSql
					EXECUTE SP_EXECUTESQL @UpdateSql
					
					set @UpdateSql='update a set a.city_id=b.city_id
						from shipto a inner join city b on (b.city=a.city)'
					print ' Update city_id :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql
					
					set @UpdateSql='update a set a.state_id=b.state_id
						from shipto a inner join state b on (b.state=a.state)'
					print ' Update state_id :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql
					
					set @UpdateSql='update a set a.country_id=b.country_id
						from shipto a inner join country b on (b.country=a.country)'
					print ' Update country_id :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql
--Added by Priyanka B on 26122017 for Bug-30849 End

--Commented by Priyanka B on 26122017 for Bug-30849 Start
					/*set @UpdateSql='update a set  a.ac_id=b.ac_id, a.country_id=d.country_id,a.state_id=d.state_id,a.city_id=d.city_id
						from shipto a inner join shipto_'+@fName+' c on (a.dataimport=c.dataexport1) 
						inner join ac_mast_'+@fName+' d on (d.ac_id=c.ac_id) 
						inner join ac_mast b on (b.dataimport=d.dataexport1)'
					print ' Update shipto :- '+@UpdateSql 
					EXECUTE SP_EXECUTESQL @UpdateSql	
					*/
--Commented by Priyanka B on 26122017 for Bug-30849 End

					set @UpdateSql='update shipto set country_id=251 where country_id is NULL'
					EXECUTE SP_EXECUTESQL @UpdateSql		
					---Birendra : Bug-20512  on 13/02/2014:End:
	
				end
				-- Below Updating Nulls to their default Values.
				set @UpdateSql='execute Update_table_column_default_value '+char(39)+@Table_Name+char(39)+',1'
				EXECUTE SP_EXECUTESQL @UpdateSql

			end
		end
	end
end
