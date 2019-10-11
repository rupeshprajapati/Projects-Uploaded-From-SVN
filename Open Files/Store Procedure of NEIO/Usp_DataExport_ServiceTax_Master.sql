IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='Usp_DataExport_ServiceTax_Master')
BEGIN
	DROP PROCEDURE Usp_DataExport_ServiceTax_Master
END

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- AUTHOR	  :	PRIYANKA B.
-- CREATE DATE: 29/12/2017
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO EXPORT SERVICE TAX MASTER.
-- MODIFIED BY: 
-- MODIFY DATE: 
-- REMARK:
-- =============================================

CREATE Procedure [dbo].[Usp_DataExport_ServiceTax_Master]
@CommanPara varchar(4000)
as
Begin
	Declare @TablNm varchar(60),@FileType varchar(3),@ExpCode varchar(200),@ExpDataVol varchar(30),@DtFld varchar(30),@sDate smalldatetime,@eDate smallDateTime
	--set @CommanPara='<<TablNm=ac_group_mast>><<FileTye=xsd>><<ExpCode=''ALM''+''#''+Ac_Group_Name>><<ExpDataVol=Full>><<DtFld=Date>><<sDate=11/1/2011>><<eDate=11/24/2011>>'
	execute Usp_GetCommanParaVal @CommanPara,'TablNm',@TablNm out
	execute Usp_GetCommanParaVal @CommanPara,'FileType',@FileType out
	execute Usp_GetCommanParaVal @CommanPara,'ExpCode',@ExpCode out
	execute Usp_GetCommanParaVal @CommanPara,'ExpDataVol',@ExpDataVol  out
	execute Usp_GetCommanParaVal @CommanPara,'DtFld',@DtFld out
	execute Usp_GetCommanParaVal @CommanPara,'sDate',@sDate out
	execute Usp_GetCommanParaVal @CommanPara,'eDate',@eDate out
	
	Declare @SqlCommand nvarchar(4000)
	set @ExpCode=replace(@ExpCode,'`','''')
		print 'a'
	if @TablNm='SerTax_Mast'
	begin
		print 'b'
		if @FileType='xml'
		begin
		print 'c'
			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode+',* FROM '+@TablNm+' where '
		end
		if  @FileType='xml'		
		begin		
		print 'd'
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

