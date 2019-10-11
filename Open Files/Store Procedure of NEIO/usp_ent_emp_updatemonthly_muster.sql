DROP PROCEDURE [usp_Ent_Emp_UpdateMonthly_Muster]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 30/05/2012
-- Description:	This Stored procedure is useful to generate processing Month in Entry Module.
-- Modification Date/By/Reason: Sachin N. S. on 08/01/2014 for Bug-21047
-- Modification Date/By/Reason: Sachin N. S. on 18/02/2014 for Bug-20933 & Bug-20934
-- Modification Date/By/Reason: Sachin N. S. on 04/07/2014 for Bug-21114
-- Remark: 
-- =============================================

Create Procedure [usp_Ent_Emp_UpdateMonthly_Muster]
	@Year varchar(30),@Month int,@Loc_Code varchar(10),@MonthDays Decimal(12,3)
as
Declare @SqlCommand nvarchar(4000),@LV_Code varchar(3),@Seffect varchar(1)

--Update Emp_Monthly_Muster Set SalPaidDays=@MonthDays where Pay_Year=@Year and Pay_Month=@Month
Update a Set SalPaidDays=
		case when isnull(dol,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000' or 
				(month(dol)>=@Month and year(dol)>=@Year) then 
				case when month(dol)=@Month and isnull(dol,'1900-01-01 00:00:00.000')<>'1900-01-01 00:00:00.000' then 
					day(dol) 
				else 
					-- Changed by Sachin N. S. on 12/02/2014 for Bug-20933 & Bug-20934 -- Start
					case when isnull(doj,'1900-01-01 00:00:00.000')='1900-01-01 00:00:00.000' or 
						(month(doj)<=@Month and year(doj)<=@Year) then 
							case when month(doj)=@Month then 
								@MonthDays-day(doj)+1
							else 
								@MonthDays 
							end
					else @MonthDays end 
					-- Changed by Sachin N. S. on 12/02/2014 for Bug-20933 & Bug-20934 -- End
				end 
		else 0 end	-- Changed by Sachin N. S. on 08/01/2014 for Bug-21047
		*(case when b.CalcPeriod='HOURWISE' then a.WrkHrs else 1 end) -- Added by Sachin N. S. on 04/07/2014 for Bug-21114
,Monthdays=@MonthDays*(case when b.CalcPeriod='HOURWISE' then a.WrkHrs else 1 end)		-- Changed by Sachin N. S. on 04/07/2014 for Bug-21114
,PR=@MonthDays*(case when b.CalcPeriod='HOURWISE' then a.WrkHrs else 1 end)		-- Changed by Sachin N. S. on 04/07/2014 for Bug-21114
--,Monthdays=@MonthDays		-- Changed by Sachin N. S. on 04/07/2014 for Bug-21114
from Emp_Monthly_Muster a
	inner join Employeemast b on a.Employeecode=b.EmployeeCode
where Pay_Year=@Year and Pay_Month=@Month /*Ramya*/

-- Update Emp_Monthly_Muster Set PR=@MonthDays where Pay_Year=@Year and Pay_Month=@Month		-- Changed by Sachin N. S. on 04/07/2014 for Bug-21114

Set @SqlCommand='Declare cur_AttSet Cursor  for select Distinct Att_Code as LV_Code,Seffect=SalPaidDayseffect from Emp_Attendance_Setting Where LDeactive=0'
print @SqlCommand
execute sp_executeSql @SqlCommand
open cur_AttSet 
fetch next From cur_AttSet into @LV_Code,@Seffect
While (@@Fetch_Status=0)	
begin
	if(@Seffect='A')
	begin
		Set @SqlCommand ='Update Emp_Monthly_Muster Set PR=PR-'+@LV_Code+' where Pay_Year='+char(39)+@Year+char(39) +' and Pay_Month='+cast(@Month as varchar)
		print  @SqlCommand
		execute sp_executeSql @SqlCommand
	end
	if(@Seffect='D')
	begin
		Set @SqlCommand ='Update Emp_Monthly_Muster Set PR=PR-'+@LV_Code+' where Pay_Year='+char(39)+@Year+char(39) +' and Pay_Month='+cast(@Month as varchar)
		print  @SqlCommand
		execute sp_executeSql @SqlCommand
		Set @SqlCommand ='Update Emp_Monthly_Muster Set SalPaidDays=SalPaidDays-'+@LV_Code+' where Pay_Year='+char(39)+@Year+char(39) +' and Pay_Month='+cast(@Month as varchar)
		print  @SqlCommand
		execute sp_executeSql @SqlCommand
	end
--	Update Emp_Monthly_Muster Set LOP=@MonthDays-SalPaidDays where Pay_Year=@Year and Pay_Month=@Month		-- Commented by Sachin N. S. on 04/07/2014 for Bug-21114
	fetch next From cur_AttSet into @LV_Code,@Seffect
end
close cur_AttSet
DeAllocate cur_AttSet

Update a Set LOP=((case when b.CalcPeriod='HOURWISE' then a.WrkHrs else 1 end) * @MonthDays)-SalPaidDays 
	from Emp_Monthly_Muster a 
		inner join Employeemast b on a.Employeecode=b.EmployeeCode
	where Pay_Year=@Year and Pay_Month=@Month			-- Added by Sachin N. S. on 04/07/2014 for Bug-21114

Execute usp_Ent_Emp_Update_Leave_Maintenance @Year,@Month,@Loc_Code

--Select * from
GO
