If Exists(Select [name] From SysObjects Where xType='P' and [Name]='Usp_DataExport_OP')
Begin
	DROP PROCEDURE Usp_DataExport_OP
End
GO
CREATE Procedure [Usp_DataExport_OP]
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
	
	 --select @TablNm ,@FileType ,@ExpCode ,@ExpDataVol,@DtFld ,@sDate ,@eDate 

	--execute Usp_GetCommanParaVal @CommanPara,'TablNm',@TablNm out

	

		
	Declare @SqlCommand nvarchar(4000)
	Declare @Manu_Det_Cmd nvarchar(4000)
	set @ExpCode=replace(@ExpCode,'`','''')
--	if  @TablNm='Manu_det'
--	begin
--		if @FileType='xsd'
--		begin
--			set @SqlCommand='SELECT Dataexport1='+@ExpCode
----			set @SqlCommand=rtrim(@SqlCommand)+',manuAc_Name=b.Ac_Name,manuSAc_Name=c.Location_Id'
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'
----			set @SqlCommand=rtrim(@SqlCommand)+' Left join ac_mast b on (a.ManuAc_ID=b.ac_id) left join shipto c on (a.ManuSAc_Id=c.Shipto_Id) where 1=2'
--			print '1.'
--			print @SqlCommand
----			execute sp_executesql @SqlCommand
----			set @SqlCommand='Select (select * from 	'+@TempTbl+' manu_det'	
----			set @SqlCommand=rtrim(@SqlCommand)+' where 1=2 FOR XML auto,XMLSCHEMA,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
----			execute sp_executesql @SqlCommand
----			print '2.'
----			print @SqlCommand
--		end
--		if @FileType='xml'
--		begin
--			---
--			set @SqlCommand=' SELECT Dataexport1='+@ExpCode
----			set @SqlCommand=rtrim(@SqlCommand)+',manuAc_Name=b.Ac_Name,manuSAc_Name=c.Location_Id '
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.*  into '+@TempTbl+' FROM  '+@TablNm+' a '
----			set @SqlCommand=rtrim(@SqlCommand)+' Left join ac_mast b on (a.ManuAc_ID=b.ac_id) left join shipto c on (a.ManuSAc_Id=c.Shipto_Id)'
--			set @SqlCommand=rtrim(@SqlCommand)+'  where '
--
--			if @ExpDataVol='Updated' 
--			begin
--				set @SqlCommand=rtrim(@SqlCommand)+' isnull(a.DataExport,'''')='''' '
--			end
--			
--			if isnull(@DtFld,'')<>''
--			begin
--				set @SqlCommand = rtrim(@SqlCommand)+ ' and (a.'+@DtFld+' between '+char(39)+@sDate+Char(39)+' and '+char(39)+@eDate+Char(39)+')'
--			end
--
--			set @SqlCommand = rtrim(@SqlCommand)+ ' and (Entry_ty in (''AR''))'
--			print '3.'
--			print @SqlCommand
--
----			execute sp_executesql @SqlCommand
----			set @SqlCommand='Select (select * from 	'+@TempTbl+' manu_det'
--			set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
--			print '4.'
--			print @SqlCommand
--			execute sp_executesql @SqlCommand
--		end
--	end		


	if @TablNm='OPMAIN' 
	begin
		print 'b'
--Commented by Archana K. on 31/05/13 for Bug-5837 start
--		if @FileType='xsd'
--		begin
--			set @SqlCommand='SELECT Dataexport1='+@ExpCode
----			set @SqlCommand=rtrim(@SqlCommand)+',cons_Name=b.Ac_Name,Scons_Name=c.Location_Id,sAc_Name=d.Location_id,sAc_Name=d.Location_id  '
----			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'--Commented by Archana K. on 09/04/13 for Bug-5837
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837
------			set @SqlCommand=rtrim(@SqlCommand)+' left join ac_mast b on (a.cons_id=b.ac_id)'
------			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto c on (a.scons_id=c.shipto_id)'
------			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto d on (a.scons_id=d.shipto_id) where 1=2'
----			print '5.'
----			print @SqlCommand
----			execute sp_executesql @SqlCommand
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
--			set @SqlCommand=rtrim(@SqlCommand)+',cons_Name=b.Ac_Name,Scons_Name=c.Location_Id,sAc_Name=d.Location_id'
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'--Commented by Archana K. on 09/04/13 for Bug-5837
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837
--			set @SqlCommand=rtrim(@SqlCommand)+' left join ac_mast b on (a.cons_id=b.ac_id)'
--			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto c on (a.scons_id=c.shipto_id)'
--			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto d on (a.scons_id=d.shipto_id)'
			
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
	if @TablNm='OPITEM' 
	begin
		print 'b'
--Commented by Archana K. on 31/05/13 for Bug-5837 start
--		if @FileType='xsd'
--		begin
--			set @SqlCommand='SELECT Dataexport1='+@ExpCode
----			set @SqlCommand=rtrim(@SqlCommand)+',manuAc_Name=b.Ac_Name,manuSAc_Name=c.Location_Id'
----			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'--Commented by Archana K. on 09/04/13 for Bug-5837
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837
--
----			set @SqlCommand=rtrim(@SqlCommand)+' left join ac_mast b on (a.manuAc_ID=b.ac_id)'
----			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto c on (a.ManuSAc_Id=c.shipto_id) where 1=2'
----			print '5.'
----			print @SqlCommand
----			execute sp_executesql @SqlCommand
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
--			set @SqlCommand=rtrim(@SqlCommand)+',manuAc_Name=b.Ac_Name,manuSAc_Name=c.Location_Id'
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+' FROM '+@TablNm+' a'--Commented by Archana K. on 09/04/13 for Bug-5837
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,a.* into '+@TempTbl+@TablNm+' FROM '+@TablNm+' a'--Changed by Archana K. on 09/04/13 for Bug-5837

--			set @SqlCommand=rtrim(@SqlCommand)+' left join ac_mast b on (a.manuAc_ID=b.ac_id)'
--			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto c on (a.ManuSAc_Id=c.shipto_id) '
			
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
--****
	if @TablNm='GEN_SRNO' 
	begin
		print 'b'
--Commented by Archana K. on 31/05/13 for Bug-5837 start
--		if @FileType='xsd'
--		begin
--			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode
--			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,* FROM '+@TablNm
----			set @SqlCommand=rtrim(@SqlCommand)+' left join ac_mast b on (a.cons_id=b.ac_id)'
----			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto c on (a.scons_id=c.shipto_id)'
----			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto d on (a.scons_id=d.shipto_id) where 1=2'
----			print '5.'
----			print @SqlCommand
----			execute sp_executesql @SqlCommand
----			print '6.'
----			print @SqlCommand
----			execute sp_executesql @SqlCommand
----			set @SqlCommand='Select (select * from 	'+@TempTbl+' armain'
--			set @SqlCommand=rtrim(@SqlCommand)+' where 1=2 FOR XML auto,XMLSCHEMA,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
--			print '7.'
--			print @SqlCommand
--			execute sp_executesql @SqlCommand
--		end
--Commented by Archana K. on 31/05/13 for Bug-5837 end
		set @SqlCommand=''
		if @FileType='xml'
		begin
			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode
--			set @SqlCommand=rtrim(@SqlCommand)+',cons_Name=b.Ac_Name,Scons_Name=c.Location_Id,sAc_Name=d.Location_id '
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,* FROM '+@TablNm
--			set @SqlCommand=rtrim(@SqlCommand)+' left join ac_mast b on (a.cons_id=b.ac_id)'
--			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto c on (a.scons_id=c.shipto_id)'
--			set @SqlCommand=rtrim(@SqlCommand)+' left join shipto d on (a.scons_id=d.shipto_id)'
			
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
	
			set @SqlCommand = rtrim(@SqlCommand)+ ' and entry_ty=''OP'''--Added by Archana K. on 10/12/13 for Bug-20512

	--		print '8.'
	--		print @SqlCommand

	--		execute sp_executesql @SqlCommand
	--		set @SqlCommand='Select (select * from 	'+@TempTbl+' armain'
			set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
			print '9. Amrendra'
			print @SqlCommand
			execute sp_executesql @SqlCommand
		end
	end
--------------****-----------------------*****------------------------------
--Added By Kishor A. for bug-26960 on 21/09/2015 Start..
	
	
		if @TablNm='IT_SRSTK' 
	begin		
		set @SqlCommand=''
		if @FileType='xml'
		begin
			--set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode+',TmpKey='+SUBSTRING(@ExpCode,1,4)+CHAR(39)+'+''#''+CAST(iTran_cd AS VARCHAR)'  --Commented by Priyanka B on 10022018 for Bug-30849
			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode+',TmpKey='+SUBSTRING(@ExpCode,1,charindex('+',@ExpCode)-1)+'+'+char(39)+'#'+char(39)+'+CAST(iTran_cd AS VARCHAR)'   --Modified by Priyanka B on 19022018 for Bug-30849
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=InTran_cd,IT_CODE,IT_NAME,QTY,InEntry_ty,InDate,InTran_cd
												,InItserial,InInv_No,BATCHNO,SERIALNO,SPLITNO,LOTNO,DataExport,DataImport FROM '+@TablNm 
			set @SqlCommand=rtrim(@SqlCommand)+'  where '
			
			if @ExpDataVol='Updated' 
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' isnull(DataExport,'''')='''' '
			end
			else
			begin
				set @SqlCommand=rtrim(@SqlCommand)+' 1=1'
			end
			if isnull('In'+@DtFld,'')<>''
			begin
				set @SqlCommand = rtrim(@SqlCommand)+ ' and ('+'In'+@DtFld+' between '+char(39)+@sDate+Char(39)+' and '+char(39)+@eDate+Char(39)+')'
			end				
			
			set @SqlCommand = rtrim(@SqlCommand)+ ' and InEntry_ty=''OP'''

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
			--set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode+',TmpKey='+SUBSTRING(@ExpCode,1,4)+CHAR(39)+'+''#''+CAST(iTran_cd AS VARCHAR)'  --Commented by Priyanka B on 10022018 for Bug-30849
			set @SqlCommand='Select (SELECT Dataexport1='+@ExpCode+',TmpKey='+SUBSTRING(@ExpCode,1,charindex('+',@ExpCode)-1)+'+'+char(39)+'#'+char(39)+'+CAST(iTran_cd AS VARCHAR)'   --Modified by Priyanka B on 19022018 for Bug-30849
			set @SqlCommand=rtrim(@SqlCommand)+',oldTran_cd=Tran_cd,Entry_ty,[Date],Tran_cd,inv_no,Itserial,It_code,Qty,REntry_ty,
												RDate,RTran_cd,Rinv_no,RItserial,Rqty,Dc_No,iTran_cd,pmKey,WARE_NM,WARE_NMFR,DataExport,DataImport FROM '+@TablNm
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
			
			set @SqlCommand = rtrim(@SqlCommand)+ ' and Entry_ty=''OP'''

			set @SqlCommand=rtrim(@SqlCommand)+' FOR XML auto,ROOT('+char(39)+@TablNm+char(39)+'))  as cxml'
			
			print @SqlCommand
			execute sp_executesql @SqlCommand
		end
	end	
--Added By Kishor A. for bug-26960 on 21/09/2015 End..

--****
	
----Added by Archana K. on 12/04/13 for Bug-5837 start
	if @TablNm='OPMAIN' or @TablNm='OPITEM' 
		begin
		SET @SQLCOMMAND = 'DROP TABLE '+@TempTbl+@TablNm
		EXECUTE SP_EXECUTESQL @SQLCOMMAND
	end
----Added by Archana K. on 12/04/13 for Bug-5837 end
--****
end

