DROP PROCEDURE [Usp_DocNo_Renumbering]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Rupesh Prajapati		
-- Create date: 22/11/2011
-- Description:	This Stored procedure is useful to renumbering doc_no field.
-- =============================================

create   PROCEDURE [Usp_DocNo_Renumbering]
@Entry_ty varchar(2),@SDATE SMALLDATETIME,@EDATE SMALLDATETIME,@INVSR VARCHAR(20)
AS
BEGIN

	Print 'Entry Ty = '+@Entry_ty
	DECLARE @DT DATETIME,@INVNO varchar(20),@INV_ARR INT,@DOCNO INT,@DOC INT,@tran_cd numeric(10),@tblName varchar(10),@tblName1 varchar(10),@Entry_ty1 varchar(2),@tmpTable varchar(20),@SqlCommand nvarchar(4000)
	
	select @tblName=(case when ext_vou=0 then Entry_Ty else bCode_Nm end)+'Main' from lcode where entry_ty=@Entry_ty
	
	set @tmpTable='##TempCurrDoc_noList'
	set @SqlCommand='select entry_ty,date,max(cast(doc_no as numeric(5))) doc_no,0 compid into '+@tmpTable+' from '+@tblName+' where entry_ty='+char(39)+@Entry_ty+char(39)+ ' group by  entry_ty,date'
	print @SqlCommand
	execute sp_ExecuteSql @SqlCommand

	
	set @SqlCommand='DECLARE C1 CURSOR FOR SELECT DISTINCT date from '+@tblName+' where (date between '+char(39)+cast(@sDate as varchar)+char(39)+' and '+char(39)+cast(@eDate as varchar)+char(39)+')'
	print @SqlCommand
	execute sp_ExecuteSql @SqlCommand
	OPEN C1
	FETCH NEXT FROM C1 INTO @DT
	WHILE(@@FETCH_STATUS=0)
    BEGIN
		
		set @SqlCommand='DECLARE DOC_REARR CURSOR FOR SELECT INV_NO,Tran_cd FROM  '+@tblName+' WHERE DATE='+char(39)+cast(@DT as varchar)+char(39)+' ORDER BY inv_sr,INV_NO'
		print @SqlCommand
		execute sp_ExecuteSql @SqlCommand
		set @DOCNO=0
	 	OPEN DOC_REARR
		FETCH NEXT FROM DOC_REARR INTO @INVNO,@Tran_cd
		WHILE (@@FETCH_STATUS=0)
		BEGIN
			set @DOCNO=@DOCNO+1
			print @DOCNO
			set @SqlCommand='update '+@tblName+' set doc_no=Replicate(''0'',5-len(rtrim('+char(39)+cast(@DOCNO as varchar)+char(39)+')))+rtrim('+char(39)+cast(@DOCNO as varchar)+char(39)+') where tran_cd='+cast(@Tran_Cd as varchar)
			--set @SqlCommand='update '+@tblName+' set doc_no=Replicate(''0'',5-len(rtrim('+char(39)+cast(@DOC as varchar)
			print 'A '
			print @SqlCommand
			execute sp_ExecuteSql @SqlCommand
			if @tran_cd=157
			begin
				select @tblName,date,doc_no,tran_cd from stmain  where tran_cd=157
			end	
			FETCH NEXT FROM DOC_REARR INTO @INVNO,@Tran_cd
		END
		CLOSE DOC_REARR
		DEALLOCATE DOC_REARR
	   FETCH NEXT FROM C1 INTO @DT
	END
	CLOSE C1
	DEALLOCATE C1
	
	set @SqlCommand='update a set a.Doc_No=b.Doc_No from '+replace(@tblName,'main','item' )+' a inner join  '+@tblName+'  b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)'
	print 'Item -'+@SqlCommand
	execute sp_ExecuteSql @SqlCommand
	
--	set @SqlCommand='update a set a.Doc_No=b.Doc_No from  '+replace(@tblName,'main','acdet' )+' a inner join  '+@tblName+'  b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)'
--	--print 'AcDet -'+@SqlCommanRd
--	execute sp_ExecuteSql @SqlCommand
--	
--	set @SqlCommand='update a set a.Doc_No=b.Doc_No from  '+replace(@tblName,'main','ItRef' )+' a inner join  '+@tblName+'  b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)'
--	print 'ItRef -'+@SqlCommand
--	execute sp_ExecuteSql @SqlCommand
--
--	
--
--	set @SqlCommand='update a set a.Doc_No=b.Doc_No from  '+replace(@tblName,'main','Mall' )+' a inner join  '+@tblName+'  b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd)'
--	print 'Mall -'+@SqlCommand
--	execute sp_ExecuteSql @SqlCommand
	
	delete from Gen_Doc where Entry_ty=@Entry_ty 

--	set @SqlCommand='select entry_ty,date,max(cast(doc_no as numeric(5))),0 into '+@tmpTable+' from '+@tblName+' where entry_ty='+char(39)+@Entry_ty+char(39)
--	print @SqlCommand
--	execute sp_ExecuteSql @SqlCommand
	
	set @SqlCommand='insert into Gen_Doc (entry_ty,date,doc_no,CompId) select entry_ty,date,max(cast(doc_no as numeric(5))),0 from '+@tblName+' where Date not in (select distinct Date from Gen_Doc where entry_ty='+char(39)+@Entry_ty+char(39)+') group by  entry_ty,date'
	print @SqlCommand
	execute sp_ExecuteSql @SqlCommand

	set @SqlCommand='update a set a.Doc_no=b.Doc_no from Gen_Doc a inner join '+@tmpTable+' b on (a.entry_ty=b.entry_ty and a.date=b.date)'

--	set @SqlCommand='insert into Gen_Doc (entry_ty,date,doc_no,CompId) select entry_ty,date,max(cast(doc_no as numeric(5))),0 from '+@tblName+' where entry_ty='+char(39)+@Entry_ty+char(39)
--	set @SqlCommand=rtrim(@SqlCommand)+' and date not in (select ditinct Date from Gen_Doc where entry_ty='+@Entry_ty+')'
--	set @SqlCommand=rtrim(@SqlCommand)+' group by  entry_ty,date'
	print @SqlCommand
	execute sp_ExecuteSql @SqlCommand

	set @SqlCommand='DECLARE DOC_REARR1 CURSOR FOR select distinct Entry_ty from ORDZM_VW_ITREF where rentry_ty='+char(39)+@entry_ty+char(39)
	print @SqlCommand
	execute sp_ExecuteSql @SqlCommand
	OPEN DOC_REARR1
	FETCH NEXT FROM DOC_REARR1 INTO @Entry_ty1
	WHILE (@@FETCH_STATUS=0)
	BEGIN
--		select @tblName1=(case when ext_vou=0 then Entry_Ty else bCode_Nm end)+'Main' from lcode where entry_ty=@Entry_ty1
		select @tblName1=(case when ext_vou=0 then Entry_Ty else bCode_Nm end)+'Itref' from lcode where entry_ty=@Entry_ty1			-- Changed by Sachin N. S. on 25/10/2012 for Bug-5837
--		set @SqlCommand='update a set a.Rdoc_no =b.doc_no from '+@tblName1 +' a inner join '+@tblName+ 'b on (a.rentry_ty=b.entry_ty and a.itRef_Tran=b.tran_cd)'
		set @SqlCommand='update a set a.Rdoc_no =b.doc_no from '+@tblName1 +
			' a inner join '+@tblName+ ' b on (a.rentry_ty=b.entry_ty and a.itRef_Tran=b.tran_cd)'		-- Changed by Sachin N. S. on 25/10/2012 for Bug-5837
		print @SqlCommand
		execute sp_ExecuteSql @SqlCommand
		FETCH NEXT FROM DOC_REARR1 INTO @Entry_ty1
	end
	CLOSE DOC_REARR1
	DEALLOCATE DOC_REARR1
	--execute Usp_DocNo_Renumbering 'ST','2011/11/01','2011/11/22',''
	drop table ##TempCurrDoc_noList
END
GO
