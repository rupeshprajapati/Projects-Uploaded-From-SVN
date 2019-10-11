DROP PROCEDURE [Usp_Ent_Emp_Get_Daily_Hourwise]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sachin N. S.
-- Create date: 24/07/2012
-- Description: For Bug-21114 -- Get the Data from the Table
-- Modification Date/By/Reason:
-- Remark:
-- =============================================
Create procedure [Usp_Ent_Emp_Get_Daily_Hourwise] 
@P_year varchar(12),@p_month int
as
begin
	declare @col_lst as varchar(1000),@sql as nvarchar(max),@Table_Name as varchar(100),@TBLNM as Varchar(50)
	;WITH ABC (FId, att_code) AS
	(
		SELECT 1, CAST('' AS VARCHAR(8000)) 
		UNION ALL
		SELECT B.FId + 1, B.att_code +  A.att_code + '_Balance, ' 
		FROM (SELECT Row_Number() OVER (ORDER BY Id) AS RN, att_code FROM Emp_attendance_setting where isleave=1 ) A 
		INNER JOIN ABC B ON A.RN = B.FId 
	)

	SELECT TOP 1 @col_lst=att_code FROM ABC ORDER BY FId DESC 
	select @col_lst=case when len(@col_lst)>0 then substring(@col_lst,1,len(rtrim(@col_lst))-1) else '' end 
--	print @col_lst

	set @sql = '' + replicate(' ',10000)

set @sql='Select	isnull(d.ID,0) [ID],isnull([Upload],0) [Upload],isnull(d.[Approve],0) [Approve],m.[EmployeeCode]
	,d.day1 ,d.day2 ,d.day3 ,d.day4 ,d.day5 ,d.day6 ,d.day7 ,d.day8 ,d.day9 ,d.day10 ,d.day11 ,d.day12 ,d.day13 ,d.day14 ,d.day15 ,d.day16 
	,d.day17 ,d.day18 ,d.day19 ,d.day20 ,d.day21 ,d.day22 ,d.day23 ,d.day24 ,d.day25 ,d.day26 ,d.day27 ,d.day28 ,d.day29 ,d.day30 ,d.day31
	,isnull(m.[Pay_Year],'''') [Pay_Year],isnull(m.[Pay_Month],0) [Pay_month],isnull([WO],0) [WO],isnull([HD],0) [HD]
	,EmployeeName=(Case when isnull(e.pMailName,'''')='''' then e.EmployeeName else e.pMailName end)
	,Supervisor=(Case when isnull(e1.pMailName,'''')='''' then isnull(e1.EmployeeName,'''') else e1.pMailName end)
	,MonthDays as monthDays, D.WrkHrs,
	case when d.WrkHrs=0 then d.day1 else case when d.WrkHrs>=d.day1 then d.day1 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day2 else case when d.WrkHrs>=d.day2 then d.day2 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day3 else case when d.WrkHrs>=d.day3 then d.day3 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day4 else case when d.WrkHrs>=d.day4 then d.day4 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day5 else case when d.WrkHrs>=d.day5 then d.day5 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day6 else case when d.WrkHrs>=d.day6 then d.day6 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day7 else case when d.WrkHrs>=d.day7 then d.day7 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day8 else case when d.WrkHrs>=d.day8 then d.day8 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day9 else case when d.WrkHrs>=d.day9 then d.day9 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day10 else case when d.WrkHrs>=d.day10 then d.day10 else d.WrkHrs end end+	
	case when d.WrkHrs=0 then d.day11 else case when d.WrkHrs>=d.day11 then d.day11 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day12 else case when d.WrkHrs>=d.day12 then d.day12 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day13 else case when d.WrkHrs>=d.day13 then d.day13 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day14 else case when d.WrkHrs>=d.day14 then d.day14 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day15 else case when d.WrkHrs>=d.day15 then d.day15 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day16 else case when d.WrkHrs>=d.day16 then d.day16 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day17 else case when d.WrkHrs>=d.day17 then d.day17 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day18 else case when d.WrkHrs>=d.day18 then d.day18 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day19 else case when d.WrkHrs>=d.day19 then d.day19 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day20 else case when d.WrkHrs>=d.day20 then d.day20 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day21 else case when d.WrkHrs>=d.day21 then d.day21 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day22 else case when d.WrkHrs>=d.day22 then d.day22 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day23 else case when d.WrkHrs>=d.day23 then d.day23 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day24 else case when d.WrkHrs>=d.day24 then d.day24 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day25 else case when d.WrkHrs>=d.day25 then d.day25 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day26 else case when d.WrkHrs>=d.day26 then d.day26 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day27 else case when d.WrkHrs>=d.day27 then d.day27 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day28 else case when d.WrkHrs>=d.day28 then d.day28 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day29 else case when d.WrkHrs>=d.day29 then d.day29 else d.WrkHrs end end+case when d.WrkHrs=0 then d.day30 else case when d.WrkHrs>=d.day30 then d.day30 else d.WrkHrs end end+
	case when d.WrkHrs=0 then d.day31 else case when d.WrkHrs>=d.day31 then d.day31 else d.WrkHrs end end as WrkdHrs,
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day1 then d.day1-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day2 then d.day2-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day3 then d.day3-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day4 then d.day4-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day5 then d.day5-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day6 then d.day6-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day7 then d.day7-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day8 then d.day8-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day9 then d.day9-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day10 then d.day10-d.WrkHrs else 0 end end+	
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day11 then d.day11-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day12 then d.day12-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day13 then d.day13-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day14 then d.day14-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day15 then d.day15-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day16 then d.day16-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day17 then d.day17-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day18 then d.day18-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day19 then d.day19-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day20 then d.day20-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day21 then d.day21-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day22 then d.day22-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day23 then d.day23-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day24 then d.day24-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day25 then d.day25-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day26 then d.day26-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day27 then d.day27-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day28 then d.day28-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day29 then d.day29-d.WrkHrs else 0 end end+case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day30 then d.day30-d.WrkHrs else 0 end end+
	case when d.WrkHrs=0 then 0 else case when d.WrkHrs<d.day31 then d.day31-d.WrkHrs else 0 end end as WrkdOTHrs,
	d.day1+d.day2+d.day3+d.day4+d.day5+d.day6+d.day7+d.day8+d.day9+d.day10+d.day11+d.day12+d.day13+d.day14+d.day15+d.day16+
	d.day17+d.day18+d.day19+d.day20+d.day21+d.day22+d.day23+d.day24+d.day25+d.day26+d.day27+d.day28+d.day29+d.day30+d.day31 as TotalHrs, '+@col_lst+' 
	from Emp_daily_Hourwise_Muster d
		inner join Emp_Monthly_Muster m on d.employeeCode=m.employeeCode and d.pay_month=m.Pay_month  and d.Pay_year=m.Pay_year
		inner join Emp_Leave_Maintenance l  on m.employeeCode=l.EmployeeCode and l.Pay_month=m.Pay_month and l.Pay_year=m.Pay_year
		inner join employeeMast e on d.employeeCode=e.employeeCode
		Left join employeeMast e1 on e1.employeeCode=e.RepCode	and isnull(e.RepCode,'''')<>''''		
	where d.Pay_year='+char(39)+@P_year+Char(39)+' and d.Pay_month='+cast(@p_month as Varchar(10))+' and e.ActiveStatus=1 and e.CalcPeriod=''HOURWISE'' order by e.EmployeeName '
	PRINT @sql
	execute sp_executesql @sql

	set @sql='drop table '+@Table_Name
	execute sp_executesql @sql
end
GO
