DROP PROCEDURE [Usp_Ent_Holiday_Master]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ramya.
-- Create date: 07/03/2012
-- Description:	
-- =============================================

Create procedure [Usp_Ent_Holiday_Master]
@LeaveYear varchar(10),@sDate datetime,@eDate datetime,@Category varchar(20),@Dept varchar(20),@LocDesc varchar(20),@Id int
as
Begin
	Declare @tDate smalldatetime
	declare @startdate datetime, @enddate datetime,@RetVal varchar(200),@RetDate Datetime,@LocCode varchar(10),@WhereCond nvarchar(200),@SqlCommand nvarchar(250),@LvsDate smalldatetime,@LveDate smalldatetime
	
    Select @LvsDate=sDate,@LveDate =eDate From Emp_Leave_Year_Master where Lv_year=@LeaveYear

	Select sDate as hDate into #Holiday From Emp_Holiday_Master  where 1=2
	set @RetVal=''
	set @RetDate=''
	--Select * From #Holiday
	set @WhereCond	=' where lv_year='+char(39)+@LeaveYear+char(39)
	if(isnull(@Category,'')!='')
	begin
		set @WhereCond=@WhereCond+' and cate='+char(39)+@Category+char(39)
	end
	print @WhereCond
	if(isnull(@Dept,'')!='') 
	begin
		set @WhereCond=@WhereCond+' and dept='+char(39)+@Dept+char(39)
	end
	--print 'a '+@WhereCond
	if(isnull(@LocDesc,'')!='')
	begin
		Select @LocCode=Loc_Code from Loc_Master where Loc_Desc=@LocDesc
		if(isnull(@LocCode,'')<>'')
		begin
			set @WhereCond=@WhereCond+' and Loc_Code='+char(39)+@LocCode+char(39)
		end
	end
	 --print 'b '+@WhereCond
	if(isnull(@Id,0)!=0)
	begin
		set @WhereCond=@WhereCond+' and id!='+cast(@Id as varchar)
	end

	--print 'r '+@WhereCond

	set @SqlCommand='declare c1 cursor for select distinct sDate,eDate from emp_holiday_master' +@WhereCond
	print @SqlCommand
	EXEC SP_EXECUTESQL  @SqlCommand
	open c1
	fetch next from c1 into @startdate,@enddate
	  while(@@fetch_status=0)
		begin
			set @tDate=@startdate
			while(@tDate<=@enddate)
			begin
					print 'r1'
					print @tDate
					print @eDate
					insert into #Holiday (hDate) Values (@tDate)
					set @tDate= @tDate+1
			end

		fetch next from c1 into @startdate,@enddate
	  end
	close c1
	deallocate c1
	--select * From #Holiday
	set @tDate=@sDate
	while(@tDate<=@eDate and @RetVal='')
	begin
		if exists (select hDate from #holiday where hDate=@tdate)
		begin
             print @tDate
			--Select @RetVal='Already Holiday on '+cast(@tdate as varchar),@RetDate=@tdate
            Select @RetVal='Already Holiday on '+Convert(varchar(10),@tdate,103),@RetDate=@tdate
		end

		if (@tDate<@LvsDate or @tDate>@LveDate)
		begin
			--Select @RetVal=cast(@tdate as varchar)+ ' is not in the Year '+@LeaveYear ,@RetDate=@tdate
           Select @RetVal=Convert(varchar(10),@tdate,103)+ ' is not in the Leave Year '+@LeaveYear+'.Please select the date between '+Convert(varchar(10),@LvsDate,103)+' and '+Convert(varchar(10),@LveDate,103),@RetDate=@tdate
		end
		set @tDate=@tDate+1
	end	
	select @RetVal as RetVal,@RetDate as RetDate
end
GO
