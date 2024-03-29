DROP PROCEDURE [Usp_Ent_Upd_Mnthly_Muster_As_Per_HrsWise_Muster]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sachin N. S.
-- Create date: 20/06/2014
-- Description: This procedure is used to Update Monthly Muster from Hourwise Muster.
-- Modification Date/By/Reason:
-- Remark:	
-- =============================================

Create procedure [Usp_Ent_Upd_Mnthly_Muster_As_Per_HrsWise_Muster]
@vPay_Year varchar(12),@vPay_month int
as 
begin

	declare @vMonthDay int,@lCounter int,@DayColList varchar(max),@isHalfDay bit,@vHAttCode varchar(3)
	declare @vEmployeeCode varchar(50),@sqlCmd nvarchar(max),@vAttCode Numeric(5,2),@vAttCode1 Numeric(5,2),@col_lst as varchar(1000)
	declare @OTColList varchar(max)

	set @sqlCmd='' + replicate(' ',20000)
--	select top 1 @vMonthDay=monthdays from emp_monthly_muster where Pay_Year=@vPay_Year and Pay_Month=@vPay_Month
	
	select @vMonthDay=Day(DateAdd(mm,DateDiff(mm,-1,'01-'+cast(@vPay_Month as varchar)+'-'+@vPay_Year),-1))		-- Added by Sachin N. S. on 09/07/2014 for Bug-21114

--	select @vMonthDay
	set @lCounter=1
	set @DayColList=''
	set @OTColList=''
	while(@lCounter<=@vMonthDay)
	begin
		set @DayColList=@DayColList+CASE WHEN @DayColList<>'' THEN '+' ELSE '' END+'CASE WHEN b.WrkHrs>0 THEN CASE WHEN b.Day'+rtrim(cast(@lCounter as varchar(2)))+' > b.WrkHrs THEN b.WrkHrs ELSE b.Day'+rtrim(cast(@lCounter as varchar(2)))+' END ELSE b.Day'+rtrim(cast(@lCounter as varchar(2)))+' END '
		set @OTColList=@OTColList+CASE WHEN @OTColList<>'' THEN '+' ELSE '' END+'CASE WHEN b.WrkHrs>0 THEN CASE WHEN b.Day'+rtrim(cast(@lCounter as varchar(2)))+' > b.WrkHrs THEN b.Day'+rtrim(cast(@lCounter as varchar(2)))+'-b.WrkHrs ELSE 0 END ELSE 0 END '
		set @lCounter=@lCounter+1
	end 

	set @sqlCmd='Update a set a.SalPaidDays='+ @DayColList + ', a.OT='+@OTColList+', a.PR='+ @DayColList + ', a.WrkHrs=b.WrkHrs '+
				' from Emp_Monthly_Muster a '+
					'inner join Emp_Daily_Hourwise_Muster b on a.EmployeeCode=b.EmployeeCode and a.Pay_Year=b.Pay_Year and a.Pay_Month=b.Pay_Month and b.Approve=1 '+
					'inner join EmployeeMast c on a.EmployeeCode=c.Employeecode '+
					'where a.Pay_year='''+@vPay_Year+''' and a.Pay_Month='+CAST(@vPay_Month AS VARCHAR)
	
--	select @sqlCmd
	execute sp_executesql @sqlCmd

end
GO
