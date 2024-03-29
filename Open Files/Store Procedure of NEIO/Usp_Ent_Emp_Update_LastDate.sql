DROP PROCEDURE [Usp_Ent_Emp_Update_LastDate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Created By : Rupesh
-- Create date: 25/09/2012
-- Description:	This Stored Procedure is used to update Last Date
-- Remark	  : 
-- Modified By and Date : Sanjay Choudhari 09/12/2011 
-- =============================================
CREATE Procedure [Usp_Ent_Emp_Update_LastDate]
as
Begin
	set DateFormat YMD
	Declare @LastDate SmallDateTime,@Pay_Month int ,@Pay_Year varchar(30),@sLastDate varchar(30)
	Declare CurLastDate cursor for Select Distinct Pay_Month,Pay_Year From Emp_Monthly_Payroll where isnull(mnthLastDt,'')=''
	open CurLastDate
	Fetch Next From CurLastDate into @Pay_Month,@Pay_Year
	While(@@Fetch_Status=0)
	Begin
		set @sLastDate=@Pay_Year+'/'+cast(@Pay_Month as varchar)+'/'+cast(dbo.funMonthDays(@Pay_Month,@Pay_Year) as varchar)
		Set @LastDate=cast(@sLastDate as smalldatetime)
		update Emp_Monthly_Payroll set mnthLastDt=@LastDate where Pay_Year=@Pay_Year and Pay_Month=@Pay_month
		Print @Pay_Year
		Print @Pay_Month
		print @sLastDate
		print @LastDate
		Fetch Next From CurLastDate into @Pay_Month,@Pay_Year
	end

	Close CurLastDate
	DeAllocate CurLastDate
End
GO
