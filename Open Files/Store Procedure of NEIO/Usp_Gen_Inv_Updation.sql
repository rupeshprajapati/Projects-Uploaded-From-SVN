
DROP PROCEDURE [Usp_Gen_Inv_Updation]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:Rupesh Prajapati		
-- Create date: 22/11/2011
-- Description:	This Stored procedure is useful to renumbering doc_no field.
-- MODIFIED BY: PRIYANKA B. FOR BUG-31076
-- MODIFY DATE: 06/01/2018
-- REMARK:
-- =============================================


create   PROCEDURE [Usp_Gen_Inv_Updation]
@Entry_ty varchar(2),@FinYear varchar(9)
AS
BEGIN
	Print 'Entry Ty = '+@Entry_ty
	--DECLARE @DT DATETIME,@INVNO varchar(20),@INV_ARR INT,@DOCNO INT,@DOC INT,@tran_cd numeric(10),@tblName varchar(10),@tblName1 varchar(10),@Entry_ty1 varchar(2),@tmpTable varchar(20),@SqlCommand nvarchar(4000)
	--DECLARE @SqlCommand nvarchar(4000),@SeriesMaxValue varchar(10),@SeriesValue varchar(10),@SeriesDate datetime  --Commented by Priyanka B on 05012018 for Bug-31076
	DECLARE @SqlCommand nvarchar(4000),@SeriesMaxValue varchar(50),@SeriesValue varchar(50),@SeriesDate datetime  --Modified by Priyanka B on 05012018 for Bug-31076
	Declare @invno_size int,@spfx varchar(10)  --Added by Priyanka B on 05012018 for Bug-31076
	DECLARE @tblName varchar(10),@SeriesName varchar(20),@SeriesPfx varchar(10),@SeriesSfx varchar(10)
	set @SeriesPfx=''
	set @SeriesSfx=''
	set @SeriesName=''
	set @SeriesMaxValue=''
	set @SeriesValue=''
	--select @tblName=(case when ext_vou=0 then Entry_Ty else bCode_Nm end)+'Main' from lcode where entry_ty=@Entry_ty  --Commented by Priyanka B on 05012018 for Bug-31076
	select @invno_size=invno_size,@tblName=(case when ext_vou=0 then Entry_Ty else bCode_Nm end)+'Main' from lcode where entry_ty=@Entry_ty  --Modified by Priyanka B on 05012018 for Bug-31076


	set @SqlCommand='declare currSeries cursor for select distinct inv_sr from '+@tblName +' where l_yn='+char(39)+@FinYear+char(39)
	print @SqlCommand
	execute sp_ExecuteSql @SqlCommand
	open currSeries
	fetch next from currSeries into @SeriesName
	while (@@fetch_status=0)
	begin
		print 'Series Name : '+@SeriesName+'  :End'
		
--		set @SqlCommand='select i_prefix,i_suffix,inv_sr into ##Series_vw  from series where inv_sr='+char(39)+rtrim(@SeriesName)+char(39)
		set @SqlCommand='select @SeriesPfx=i_prefix,@SeriesSfx=i_suffix from series where inv_sr='+char(39)+rtrim(@SeriesName)+char(39)
		print @SqlCommand
--		execute sp_ExecuteSql @SqlCommand
		execute sp_ExecuteSql @SqlCommand,N'@SeriesPfx varchar(10) output,@SeriesSfx varchar(10) output',@SeriesPfx=@SeriesPfx output,@SeriesSfx=@SeriesSfx output
--		select @SeriesPfx=i_prefix from ##Series_vw
--		select @SeriesSfx=i_suffix from ##Series_vw

		print 'Prefix : '+@SeriesPfx
		print 'Suffix : '+@SeriesSfx
		if (len(@SeriesPfx)>0)
		begin
			--set @SqlCommand='select inv_no,substring(inv_no,len(replace(@SeriesPfx,char(39),''''))+1,len(inv_no)-len(replace(@SeriesPfx,char(39),''''))) from '+@tblName+' where inv_sr='+char(39)+rtrim(@SeriesName)+char(39)+' and l_yn='+char(39)+@FinYear+char(39)
			--set @SqlCommand = 'select @spfx=substring(@SeriesPfx,charindex(char(39),@SeriesPfx)+1,charindex(char(39),@SeriesPfx,charindex(char(39),@SeriesPfx)+1)-charindex(char(39),@SeriesPfx)-1)'  --Added by Priyanka B on 06012018 for Bug-31076  --Commented by Priyanka B on 14072018 for Bug-31707
			set @SqlCommand = 'select @spfx=@SeriesPfx'  --Added by Priyanka B on 06012018 for Bug-31076  --Modified by Priyanka B on 14072018 for Bug-31707
			--set @SqlCommand='select @SeriesValue=inv_no,@SeriesDate=date,@oSeriesMaxValue=max(substring(inv_no,len(replace(@SeriesPfx,char(39),''''))+1,len(inv_no)-len(replace(@SeriesPfx,char(39),'''')))) from '+@tblName+' where inv_sr='+char(39)+Rtrim(@SeriesName)+char(39)+' and l_yn='+char(39)+@FinYear+char(39)+' group by inv_no,date'  --Commented by Priyanka B on 05012018 for Bug-31076
			set @SqlCommand = @SqlCommand + ' ' + 'select @SeriesValue=inv_no,@SeriesDate=date'
							--,@SeriesMaxValue=cast(max(substring(inv_no,len(replace(@spfx,char(39),''''))+len(inv_no)+1-'+cast(@invno_size as varchar)+',len(inv_no)-len(replace(@spfx,char(39),'''')))) as numeric)'    --Commented by Priyanka B on 14072018 for Bug-31707
							+',@SeriesMaxValue=cast(max(substring(inv_no,len(replace(@spfx,char(39),''''))+1,len(inv_no)-(len(@SeriesSfx)+len(@SeriesPfx)))) as numeric)'  --Modified by Priyanka B on 14072018 for Bug-31707
							+' from '+@tblName+' where inv_sr='+char(39)+Rtrim(@SeriesName)+char(39)
							+' and l_yn='+char(39)+@FinYear+char(39)+' group by inv_no,date'  --Modified by Priyanka B on 05012018 for Bug-31076

			print @SqlCommand
			--execute sp_ExecuteSql @SqlCommand
			--execute sp_ExecuteSql @SqlCommand,N'@SeriesPfx varchar(10),@oSeriesMaxValue varchar(10) output,@SeriesValue varchar(10) output,@SeriesDate datetime output',@SeriesPfx=@SeriesPfx,@oSeriesMaxValue=@SeriesMaxValue output,@SeriesValue=@SeriesValue output,@SeriesDate=@SeriesDate output  --Commented by Priyanka B on 05012018 for Bug-31076
			--execute sp_ExecuteSql @SqlCommand,N'@SeriesPfx varchar(10),@spfx varchar(10) output,@SeriesMaxValue varchar(50) output,@SeriesValue varchar(50) output,@SeriesDate datetime output',@SeriesPfx=@SeriesPfx,@spfx=@spfx output,@SeriesMaxValue=@SeriesMaxValue output,@SeriesValue=@SeriesValue output,@SeriesDate=@SeriesDate output  --Modified by Priyanka B on 05012018 for Bug-31076  --Commented by Priyanka B on 14072018 for Bug-31707
			execute sp_ExecuteSql @SqlCommand,N'@SeriesSfx Varchar(10), @SeriesPfx varchar(10),@spfx varchar(10) output,@SeriesMaxValue varchar(50) output,@SeriesValue varchar(50) output,@SeriesDate datetime output',@SeriesSfx=@SeriesSfx, @SeriesPfx=@SeriesPfx,@spfx=@spfx output,@SeriesMaxValue=@SeriesMaxValue output,@SeriesValue=@SeriesValue output,@SeriesDate=@SeriesDate output  --Modified by Priyanka B on 05012018 for Bug-31076  --Modified by Priyanka B on 14072018 for Bug-31707
			print @SeriesValue
			Print 'SeriesMaxValue : ' + @SeriesMaxValue
			Print 'SeriesValue : '+@SeriesValue
			Print 'SeriesDate : '+convert(varchar(10),@SeriesDate,103)
			print 'reached in print statement'
			print 'SeriesName : '+@SeriesName
			print 'finYear : '+@finYear
----Gen_Inv
			if exists (select * from gen_inv where entry_ty=@entry_ty and inv_sr=@SeriesName and l_yn=@FinYear)
			begin
			print 'Gen_inv Update'
				update gen_inv set inv_no=@SeriesMaxValue,inv_dt=@SeriesDate where entry_ty=@entry_ty and inv_sr=@SeriesName and l_yn=@FinYear
			Print 'Status : Updated'
			end 
			else
			begin
			print 'Gen_inv Insert'
				insert gen_inv values(@entry_ty,@SeriesName,isnull(@SeriesMaxValue,0),@finYear,@SeriesDate,0)
				Print 'Status : Inserted'
			end
		end
		fetch next from currSeries into @SeriesName
--		drop table ##Series_vw
		end 
	CLOSE currSeries
	DEALLOCATE currSeries
END
GO