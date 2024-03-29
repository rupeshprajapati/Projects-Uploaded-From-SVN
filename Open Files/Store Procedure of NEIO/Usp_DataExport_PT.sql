
IF EXISTS(SELECT * FROM SYSOBJECTS WHERE XTYPE='P' AND [NAME]='Usp_DataExport_PT')
BEGIN
	DROP PROCEDURE Usp_DataExport_PT
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR	  :	
-- CREATE DATE: 
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO EXPORT PURCHASES.
-- MODIFIED BY: 
-- MODIFY DATE: 
-- REMARK:
-- =============================================

CREATE Procedure [dbo].[Usp_DataExport_PT]
@CommanPara varchar(4000)
as
Begin
	Declare @TablNm varchar(60),@FileType varchar(3),@ExpCode varchar(200),@ExpDataVol varchar(30),@DtFld varchar(30),@sDate Varchar(30),@eDate Varchar(30)
	Declare @TempTbl varchar(100)

	Set @TempTbl = '##DATAImp'+(SELECT subsTring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
					+ (DATEPART(ss, GETDATE()) * 1000 )
					+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
	
	execute Usp_GetCommanParaVal @CommanPara,'TablNm',@TablNm out
	execute Usp_GetCommanParaVal @CommanPara,'FileType',@FileType out
	execute Usp_GetCommanParaVal @CommanPara,'ExpCode',@ExpCode out
	execute Usp_GetCommanParaVal @CommanPara,'ExpDataVol',@ExpDataVol  out
	print @CommanPara
	execute Usp_GetCommanParaVal @CommanPara,'DtFld',@DtFld out
	execute Usp_GetCommanParaVal @CommanPara,'sDate',@sDate out
	execute Usp_GetCommanParaVal @CommanPara,'eDate',@eDate out
	
	PRINT @ExpCode
	 --select @TablNm ,@FileType ,@ExpCode ,@ExpDataVol,@DtFld ,@sDate ,@eDate 

	--execute Usp_GetCommanParaVal @CommanPara,'TablNm',@TablNm out
		
	Declare @SqlCommand nvarchar(4000)
	Declare @Manu_Det_Cmd nvarchar(4000)
	set @ExpCode=replace(@ExpCode,'`','''')

	if @TablNm='PTMAIN' 
	begin
		print 'b'
		if @FileType='xml'
		begin
			set @SqlCommand='SELECT Dataexport1='+@ExpCode
			set @SqlCommand=rtrim(@SqlCommand)+',cons_Name=b.Ac_Name,Scons_Name=c.Location_Id,sAc_Name=d.Location_id '
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'
			set @SqlCommand=rtrim(@SqlCommand)+' left join ac_mast b on (a.cons_id=b.ac_id)'
			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto c on (a.scons_id=c.shipto_id)'
			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto d on (a.scons_id=d.shipto_id)'
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
			print @DtFld
				set @SqlCommand = rtrim(@SqlCommand)+ ' and ('+@DtFld+' between '+char(39)+@sDate+Char(39)+' and '+char(39)+@eDate+Char(39)+')'
			end				
		end

		print '8.'
		print @SqlCommand
		execute sp_executesql @SqlCommand


--------------------------------------
--Exclude fields From Table
---------------------------------------
		
		Declare @pos1 int, @ExclFld varchar(50), @fld_nm varchar(50)
		set @ExclFld=(select ExcludFld from exp_master where [Code]='PT')
		Print @ExclFld

		set @ExclFld=@ExclFld+','

		if  (@ExclFld<>'')
		begin
			while(charindex(',',@ExclFld)>0)
			begin
				set @pos1=charindex(',',@ExclFld)
				
				set @fld_nm=substring(@ExclFld,1,@pos1-1)
				set @SqlCommand='Alter table '+@TempTbl+@TablNm+' Drop column '+@fld_nm
				Print @SqlCommand
				execute sp_executesql @SqlCommand
				
				set @ExclFld=substring(@ExclFld,@pos1,len(@ExclFld))
				if (substring(@ExclFld,1,1)=',') 
				begin	
					set @ExclFld=substring(@ExclFld,2,len(@ExclFld)-1)
				end
			end
		end
		
--------------------------------------
--Exclude fields From Table
---------------------------------------
		
		set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
		set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
		print '9.'
		print @SqlCommand
		execute sp_executesql @SqlCommand
	end
----****
	if @TablNm='PTITEM' 
	begin
		print 'b'

		if @FileType='xml'
		begin
			set @SqlCommand='SELECT Dataexport1='+@ExpCode
			set @SqlCommand=rtrim(@SqlCommand)+',Ac_Name=b.Ac_Name'
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'
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
		print '12.'
		print @SqlCommand

		execute sp_executesql @SqlCommand
		set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
		set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
		print '13.'
		print @SqlCommand
		execute sp_executesql @SqlCommand
	end
----****
	if @TablNm='PTACDET' 
	begin
		print 'b'
		if @FileType='xml'
		begin
			set @SqlCommand='SELECT Dataexport1='+@ExpCode
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'
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
	if @TablNm='PTMALL' 
	begin
		if @FileType='xml'
		begin
			set @SqlCommand='SELECT Dataexport1='+@ExpCode
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'
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
		print '20.'
		print @SqlCommand

		execute sp_executesql @SqlCommand
		set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
		set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
		print '21.'
		print @SqlCommand
		execute sp_executesql @SqlCommand
	end
	if @TablNm='PTITREF' 
	begin
		if @FileType='xml'
		begin
			set @SqlCommand='SELECT Dataexport1='+@ExpCode
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'
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
		print '24.'
		print @SqlCommand

		execute sp_executesql @SqlCommand
		set @SqlCommand='Select (select * from '+@TempTbl+@TablNm+' as '+@TablNm
		set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
		print '25.'
		print @SqlCommand
		execute sp_executesql @SqlCommand
	end

	if @TablNm='GEN_SRNO' 
	begin
		set @SqlCommand=''
		if @FileType='xml'
		begin
			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,* FROM '+@TablNm 
			set @SqlCommand=rtrim(@SqlCommand)+'  where '
			if @ExpDataVol='Updated' 
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' isnull(DataExport,'''')='''' '
			end
			else
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' 1=1'
			end
			if isnull(@DtFld,'')<>''
			begin
				set @SqlCommand = rtrim(@SqlCommand)+ ' and ('+@DtFld+' between '+char(39)+@sDate+Char(39)+' and '+char(39)+@eDate+Char(39)+')'
			end				
			
			set @SqlCommand = rtrim(@SqlCommand)+ ' and entry_ty=''PT'''

			set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
			print @SqlCommand
			execute sp_executesql @SqlCommand
		end
	end

	if @TablNm='IT_SRTRN' 
	begin						
		set @SqlCommand=''
		if @FileType='xml'
		begin
			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode+',TmpKey='+SUBSTRING(@ExpCode,1,charindex('+',@ExpCode)-1)+'+'+char(39)+'#'+char(39)+'+cast(iTran_cd as varchar)'
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,Entry_ty,[Date],Tran_cd,inv_no,Itserial,It_code,Qty,REntry_ty,RDate,RTran_cd
												,Rinv_no,RItserial,Rqty,Dc_No,iTran_cd,pmKey,WARE_NM,WARE_NMFR,DataExport,DataImport FROM '+@TablNm
			set @SqlCommand=rtrim(@SqlCommand)+'  where '
			
			if @ExpDataVol='Updated' 
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' isnull(DataExport,'''')='''' '
			end
			else
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' 1=1'
			end
			if isnull(@DtFld,'')<>''
			begin
				set @SqlCommand = rtrim(@SqlCommand)+ ' and ('+@DtFld+' between '+char(39)+@sDate+Char(39)+' and '+char(39)+@eDate+Char(39)+')'
			end				
			
			set @SqlCommand = rtrim(@SqlCommand)+ ' and Entry_ty=''PT'''

			set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
			
			print @SqlCommand
			execute sp_executesql @SqlCommand
		end
	end	

	if @TablNm='PTMAIN' or @TablNm='PTITEM' OR  @TablNm='PTACDET' OR  @TablNm='PTMALL' OR  @TablNm='PTITREF'
		begin
		SET @SQLCOMMAND = 'DROP TABLE '+@TempTbl+@TablNm
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	END
END




