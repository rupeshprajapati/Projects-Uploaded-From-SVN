If Exists(Select [name] From SysObjects Where xType='P' and [Name]='Usp_DataExport_BR')
Begin
	DROP PROCEDURE Usp_DataExport_BR
End
GO
Create Procedure [Usp_DataExport_BR]
@CommanPara varchar(4000)
as
Begin
	Declare @TablNm varchar(60),@FileType varchar(3),@ExpCode varchar(200),@ExpDataVol varchar(30),@DtFld varchar(30),@sDate Varchar(30),@eDate Varchar(30)
	Declare @TempTbl varchar(100)

	Set @TempTbl = '##DATAImp'+(SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
	
	execute Usp_GetCommanParaVal @CommanPara,'TablNm',@TablNm out
	execute Usp_GetCommanParaVal @CommanPara,'FileType',@FileType out
	execute Usp_GetCommanParaVal @CommanPara,'ExpCode',@ExpCode out
	execute Usp_GetCommanParaVal @CommanPara,'ExpDataVol',@ExpDataVol  out
	execute Usp_GetCommanParaVal @CommanPara,'DtFld',@DtFld out
	execute Usp_GetCommanParaVal @CommanPara,'sDate',@sDate out
	execute Usp_GetCommanParaVal @CommanPara,'eDate',@eDate out
	
		
	Declare @SqlCommand nvarchar(4000)
	Declare @Manu_Det_Cmd nvarchar(4000)
	set @ExpCode=replace(@ExpCode,'`','''')

	if @TablNm='BRMAIN' 
	begin
		print 'b'
--Commented by Archana K. on 31/05/13 for Bug-5837 start
--		if @FileType='xsd'
--		begin
--			set @SqlCommand='SELECT Dataexport1='+@ExpCode
----			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a' --Commented by Archana K. on 09/04/13 for Bug-5837
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837
--
--			print '6.'
--			print @SqlCommand
--			execute sp_executesql @SqlCommand
--			set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
--			set @SqlCommand=rtrim(@SqlCommand)+' where 1=2 FOR XML auto,XMLSCHEMA,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
--			print '7.'
--			print @SqlCommand
--			execute sp_executesql @SqlCommand
--		end
--Commented by Archana K. on 31/05/13 for Bug-5837 end
		if @FileType='xml'
		begin
			set @SqlCommand='SELECT Dataexport1='+@ExpCode
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'--Commented by Archana K. on 09/04/13 for Bug-5837
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837
			
			set @SqlCommand=rtrim(@SqlCommand)+'  where '
			
			if @ExpDataVol='Updated' 
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' isnull(a.DataExport,'''')='''' '
			end
			else
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' 1=1'
			end
			if isnull(@DtFld,'')<>''
			begin
				set @SqlCommand = rtrim(@SqlCommand)+ ' and ('+@DtFld+' between '+char(39)+@sDate+Char(39)+' and '+char(39)+@eDate+Char(39)+')'
			end				
		end
		print '8.'
		print @SqlCommand

		set @SqlCommand=@SqlCommand+' '+' and a.apgen=''YES'' '			--Added by Shrikant S. on 15/01/2019 for Bug-31784
		
		execute sp_executesql @SqlCommand
		set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
		set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
		print '9.'
		print @SqlCommand
		execute sp_executesql @SqlCommand
	end
----****
	if @TablNm='BRITEM' 
	begin
		print 'b'
--Commented by Archana K. on 31/05/13 for Bug-5837 start
--		if @FileType='xsd'
--		begin
--			set @SqlCommand='SELECT Dataexport1='+@ExpCode
----			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'--Commented by Archana K. on 09/04/13 for Bug-5837
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837
--
--			print '6.'
--			print @SqlCommand
--			execute sp_executesql @SqlCommand
--			set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
--			set @SqlCommand=rtrim(@SqlCommand)+' where 1=2 FOR XML auto,XMLSCHEMA,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
--			print '7.'
--			print @SqlCommand
--			execute sp_executesql @SqlCommand
--		end
--Commented by Archana K. on 31/05/13 for Bug-5837 end
		if @FileType='xml'
		begin
			set @SqlCommand='SELECT Dataexport1='+@ExpCode
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'--Commented by Archana K. on 09/04/13 for Bug-5837
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837

			set @SqlCommand=rtrim(@SqlCommand)+'  where '
			
			if @ExpDataVol='Updated' 
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' isnull(a.DataExport,'''')='''' '
			end
			else
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' 1=1'
			end
			if isnull(@DtFld,'')<>''
			begin
				set @SqlCommand = rtrim(@SqlCommand)+ ' and ('+@DtFld+' between '+char(39)+@sDate+Char(39)+' and '+char(39)+@eDate+Char(39)+')'
			end				
		end
		print '8.'
		print @SqlCommand

		execute sp_executesql @SqlCommand
		set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
		set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
		print '9.'
		print @SqlCommand
		execute sp_executesql @SqlCommand
	end

----****
	if @TablNm='BRACDET' 
	begin
		print 'b'
--Commented by Archana K. on 31/05/13 for Bug-5837 start
--		if @FileType='xsd'
--		begin
--			set @SqlCommand='SELECT Dataexport1='+@ExpCode
----			set @SqlCommand=rtrim(@SqlCommand)+',Ac_Name=b.Ac_Name'
----			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'--Commented by Archana K. on 09/04/13 for Bug-5837
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837
--			set @SqlCommand=rtrim(@SqlCommand)+' left join ac_mast b on (a.Ac_ID=b.ac_id) where 1=2'
--
--			print '14.'
--			print @SqlCommand
--			execute sp_executesql @SqlCommand
--			set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
--			set @SqlCommand=rtrim(@SqlCommand)+' where 1=2 FOR XML auto,XMLSCHEMA,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
--			print '15.'
--			print @SqlCommand
--			execute sp_executesql @SqlCommand
--		end
--Commented by Archana K. on 31/05/13 for Bug-5837 end
		if @FileType='xml'
		begin
			set @SqlCommand='SELECT Dataexport1='+@ExpCode
--			set @SqlCommand=rtrim(@SqlCommand)+',Ac_Name=b.Ac_Name'
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'--Commented by Archana K. on 09/04/13 for Bug-5837
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837

			set @SqlCommand=rtrim(@SqlCommand)+' left join ac_mast b on (a.Ac_ID=b.ac_id)'
			
			set @SqlCommand=rtrim(@SqlCommand)+'  where '
			
			if @ExpDataVol='Updated' 
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' isnull(a.DataExport,'''')='''' '
			end
			else
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' 1=1'
			end
			if isnull(@DtFld,'')<>''
			begin
				set @SqlCommand = rtrim(@SqlCommand)+ ' and ('+@DtFld+' between '+char(39)+@sDate+Char(39)+' and '+char(39)+@eDate+Char(39)+')'
			end				
		end
		print '16.'
		print @SqlCommand

		execute sp_executesql @SqlCommand
		set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
		set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
		print '17.'
		print @SqlCommand
		execute sp_executesql @SqlCommand
	end
--****
--****
----Added by Archana K. on 12/04/13 for Bug-5837 start
----Commented by Archana K. on 11/12/13 for Bug-20512 start
--	if @TablNm='GEN_SRNO' 
--	begin
--		print 'b'
----Commented by Archana K. on 31/05/13 for Bug-5837 start
----		if @FileType='xsd'
----		begin
----			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode
----			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,* FROM '+@TablNm
----
----			set @SqlCommand=rtrim(@SqlCommand)+' where 1=2 FOR XML auto,XMLSCHEMA,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
----			print '7.'
----			print @SqlCommand
----			execute sp_executesql @SqlCommand
----		end
----Commented by Archana K. on 31/05/13 for Bug-5837 end
--		set @SqlCommand=''
--		if @FileType='xml'
--		begin
--			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,* FROM '+@TablNm
--
--			set @SqlCommand=rtrim(@SqlCommand)+'  where '
--			
--			if @ExpDataVol='Updated' 
--			begin
--				set @SqlCommand=rtrim(@SqlCommand)+' isnull(DataExport,'''')='''' '
--			end
--			else
--			begin
--				set @SqlCommand=rtrim(@SqlCommand)+' 1=1'
--			end
--			if isnull(@DtFld,'')<>''
--			begin
--				set @SqlCommand = rtrim(@SqlCommand)+ ' and ('+@DtFld+' between '+char(39)+@sDate+Char(39)+' and '+char(39)+@eDate+Char(39)+')'
--			end				
--		
--	
--			set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
--			print '9. Amrendra'
--			print @SqlCommand
--			execute sp_executesql @SqlCommand
--		end
--	end
----Commented by Archana K. on 11/12/13 for Bug-20512 end
	if @TablNm='BRMAIN' or @TablNm='BRITEM' or @TablNm='BRACDET' 
		begin
		SET @SQLCOMMAND = 'DROP TABLE '+@TempTbl+@TablNm
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	end
----Added by Archana K. on 12/04/13 for Bug-5837 end
end

