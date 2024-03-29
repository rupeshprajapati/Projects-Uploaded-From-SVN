DROP PROCEDURE [Usp_Ent_Emp_Get_Attendance_Approval]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amrendra Kumar Singh
-- Create date: 24/07/2012
-- Description:
-- Modification Date/By/Reason:
-- Remark:
-- =============================================

create procedure [Usp_Ent_Emp_Get_Attendance_Approval] 
@P_year varchar(12),@p_month int
as
begin
	declare @col_lst as varchar(1000),@sql as nvarchar(4000),@Table_Name as varchar(100),@TBLNM as Varchar(50)
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
	print @col_lst
	SELECT @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
		+ (DATEPART(ss, GETDATE()) * 1000 )+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
		
	Set @Table_Name='##Temp'+@TBLNM
	Set @Sql='select att_nm,att_code into '+@Table_Name+' from emp_attendance_setting 
	union
	select h_att_nm,h_att_code from emp_attendance_setting '
print @sql
	execute sp_executesql @sql

set @sql='Select	isnull(d.ID,0) [ID],isnull([Upload],0) [Upload],isnull(d.[Approve],0) [Approve],m.[EmployeeCode]
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day1),'''') day1 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day2),'''') day2 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day3),'''') day3 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day4),'''') day4 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day5),'''') day5 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day6),'''') day6 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day7),'''') day7 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day8),'''') day8 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day9),'''') day9 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day10),'''') day10 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day11),'''') day11 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day12),'''') day12 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day13),'''') day13 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day14),'''') day14 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day15),'''') day15 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day16),'''') day16 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day17),'''') day17 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day18),'''') day18 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day19),'''') day19 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day20),'''') day20 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day21),'''') day21 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day22),'''') day22 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day23),'''') day23
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day24),'''') day24 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day25),'''') day25 
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day26),'''') day26
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day27),'''') day27
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day28),'''') day28
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day29),'''') day29
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day30),'''') day30
,isnull((select att_nm from '+ @Table_Name+'  where att_code=d.day31),'''') day31
,isnull(m.[Pay_Year],'''') [Pay_Year],isnull(m.[Pay_Month],0) [Pay_month],isnull([WO],0) [WO],isnull([HD],0) [HD]
,EmployeeName=(Case when isnull(e.pMailName,'''')='''' then e.EmployeeName else e.pMailName end)
,Supervisor=(Case when isnull(e1.pMailName,'''')='''' then e1.EmployeeName else e1.pMailName end)
,monthDays,'+@col_lst+' 
	from Emp_daily_Muster d
	right join Emp_Monthly_Muster m on d.employeeCode=m.employeeCode and d.pay_month=m.Pay_month  and d.Pay_year=m.Pay_year
	inner join Emp_Leave_Maintenance l  on m.employeeCode=l.EmployeeCode and l.Pay_month=m.Pay_month and l.Pay_year=m.Pay_year

inner join employeeMast e on d.employeeCode=e.employeeCode
inner join employeeMast e1 on e1.employeeCode=e.RepCode	and isnull(e.RepCode,'''')<>''''		
	where d.Pay_year='+char(39)+@P_year+Char(39)+' and d.Pay_month='+cast(@p_month as Varchar(10))+' and e.ActiveStatus=1 and e.PackageSal<>0 order by e.EmployeeName '

	print @sql
	execute sp_executesql @sql
set @sql='drop table '+@Table_Name
execute sp_executesql @sql
end 

---Usp_Ent_Emp_Get_Attendance_Approval '2012',2
-- select * from Emp_Leave_Maintenance


--and isnull(e.repcode,'')<>''

--select * from employeemast
--
--CL_Balance, PL_Balance, SL_Balance, SP_Balance, 

--update employeemast set repcode='',supervisor='' where employeecode='S00025' or employeecode='R0009'
GO
