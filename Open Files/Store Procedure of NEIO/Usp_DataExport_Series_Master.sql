DROP PROCEDURE [Usp_DataExport_Series_Master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [Usp_DataExport_Series_Master]
@CommanPara varchar(4000)
as
Begin
	Declare @TablNm varchar(60),@FileType varchar(3),@ExpCode varchar(200),@ExpDataVol varchar(30),@DtFld varchar(30),@sDate smalldatetime,@eDate smallDateTime
	
	execute Usp_GetCommanParaVal @CommanPara,'TablNm',@TablNm out
	execute Usp_GetCommanParaVal @CommanPara,'FileType',@FileType out
	execute Usp_GetCommanParaVal @CommanPara,'ExpCode',@ExpCode out
	execute Usp_GetCommanParaVal @CommanPara,'ExpDataVol',@ExpDataVol  out
	execute Usp_GetCommanParaVal @CommanPara,'DtFld',@DtFld out
	execute Usp_GetCommanParaVal @CommanPara,'sDate',@sDate out
	execute Usp_GetCommanParaVal @CommanPara,'eDate',@eDate out
	
	 --select @TablNm ,@FileType ,@ExpCode ,@ExpDataVol,@DtFld ,@sDate ,@eDate 

	--execute Usp_GetCommanParaVal @CommanPara,'TablNm',@TablNm out

	
	

	Declare @SqlCommand nvarchar(4000)
	set @ExpCode=replace(@ExpCode,'`','''')
		print 'a'
	if @TablNm='Series'
	begin
		print 'b'
--Commented by Archana K. on 31/05/13 for Bug-5837 start
--		if @FileType='xsd'
--		begin
--			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode+',* FROM '+@TablNm+' where 1=2 FOR XML auto,XMLSCHEMA,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
--		end
--Commented by Archana K. on 31/05/13 for Bug-5837 end
		if @FileType='xml'
		begin
			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode+',* FROM '+@TablNm+' where '
		end
		if  @FileType='xml'
		begin
			if @ExpDataVol='Updated' and @FileType='xml'
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' isnull(DataExport,'''')='''' '
			end
			else
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' 1=1'
			end
			if isnull(@DtFld,'')<>''
			begin
				set @SqlCommand = rtrim(@SqlCommand)+ ' and ('+@DtFld+' between '+char(39)+cast(@sDate as varchar)+Char(39)+' and '+char(39)+cast(@eDate as varchar)+Char(39)+')'
			end
			if @FileType='xml'
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
			end
		end
	
		print @SqlCommand
		execute sp_executesql @SqlCommand
	end
end
GO
