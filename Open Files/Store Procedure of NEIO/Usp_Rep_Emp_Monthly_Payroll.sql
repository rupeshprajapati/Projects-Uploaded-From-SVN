DROP PROCEDURE [Usp_Rep_Emp_Monthly_Payroll]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pratap.
-- Create date: 21/05/2012
-- Description:	This Stored Procedure is useful for Monthly Payroll Details in Dados reports
-- =============================================
CREATE procedure [Usp_Rep_Emp_Monthly_Payroll]
@Location Varchar(60),
@Year varchar(20),
@Month varchar(30),
@EmployeeName varchar(20)
as 
begin 
Declare @mth int,@SqlCommand nvarchar(4000)
Declare @Short_Nm varchar(60),@Fld_Nm varchar(60)
SELECT @mth=DATEPART(mm,CAST(@Month+ ' 1900' AS DATETIME))


set @SqlCommand='select E.EmployeeName as [Employee Name] ,e.Department,e.Category,l.Loc_Desc as Location'
set @SqlCommand=rtrim(@SqlCommand)+' '+',M.Pay_Year as [Year],DateName( Month , DateAdd( month , cast(M.Pay_Month as int), 0 )-1  ) as [Month],M.ProcDate as [Process Date],M.EmployeeCode as [Employee Code]'
set @SqlCommand=rtrim(@SqlCommand)+' '+',M.SalPaidDays as [Salary Paid Days],M.NetPayment as [Net Payment]'

Declare curPayHeadDet cursor for Select a.Short_Nm,a.Fld_Nm From Emp_Pay_Head_Master a inner join Emp_Pay_Head b on (a.HeadTypeCOde=b.HeadTypeCode) order by b.SortOrd,a.SortOrd
open curPayHeadDet
fetch next from curPayHeadDet into @Short_Nm,@Fld_Nm
while (@@Fetch_Status=0)
begin
	set @SqlCommand=rtrim(@SqlCommand)+','+rtrim(@Fld_Nm)+' as ['+rtrim(@Short_Nm)+']'
	fetch next from curPayHeadDet into @Short_Nm,@Fld_Nm
end
Close curPayHeadDet
DeAllocate curPayHeadDet
--Select * From Lother where e_Code='EM'

Declare curLother cursor for Select Head_Nm,Fld_Nm From Lother where e_Code='EM' order by Serial
open curLother
fetch next from curLother into @Short_Nm,@Fld_Nm
while (@@Fetch_Status=0)
begin
	set @SqlCommand=rtrim(@SqlCommand)+','+rtrim(@Fld_Nm)+' as ['+rtrim(@Short_Nm)+']'
	fetch next from curLother into @Short_Nm,@Fld_Nm
end
Close curLother
DeAllocate curLother


set @SqlCommand=rtrim(@SqlCommand)+' '+',M.PayGenerated as [PayRoll Generated]'
set @SqlCommand=rtrim(@SqlCommand)+' '+',M.Inv_No as [Reference Number],'
set @SqlCommand=rtrim(@SqlCommand)+' '+'M.Narr as [Narration]'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.othDedAmt as [Other Deductions Amount]'
set @SqlCommand=rtrim(@SqlCommand)+' '+'from emp_monthly_payroll M left join EmployeeMast E on (M.Employeecode=E.employeecode)' 
set @SqlCommand=rtrim(@SqlCommand)+' '+'left join Loc_Master L on (L.Loc_code=E.Loc_Code)' 
set @SqlCommand=rtrim(@SqlCommand)+' '+'where M.Pay_Year='+char(39)+@Year+char(39)
set @SqlCommand=rtrim(@SqlCommand)+' '+' and Pay_Month='+cast(@mth as varchar)

if isnull(@EmployeeName,'')<>''
begin
	set @SqlCommand=rtrim(@SqlCommand)+' '+' and E.EmployeeName='+char(39)+@EmployeeName+char(39)
end
print @SqlCommand
execute Sp_ExecuteSql @SqlCommand

--set @SqlCommand=rtrim(@SqlCommand)+' '+',M.BasicAmt as [Basic Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.HRAAmt as [HRA Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.DAAMT as [Dearness Allowance Amount]'
--set @SqlCommand=rtrim(@SqlCommand)+' '+',M.MediAmt as [Medical Allowance Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.CONWAMT as [Convayance Allowance Amount] ,'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.dAllowAmt as [Driver Allowances Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.ArrAmt as  [Arrears Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.BonusAmt as [Bonus Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.oAllowAmt as [Other Allowance Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.OtWagAmt as [OT Wages Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.PTaxAmt as [Professional Tax Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.PFEmpE as [Provident Fund( EmpE ) AcNo-1],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.PFEmpR as [Provident Fund ( EmpR )],M.ESICEmpE as [ESIC ( EmpE)],M.ESICEmpR as [ESIC ( EmpR)],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.TDSAmt as [TDS Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.InsAmt as [Insurence Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.LoanAmt as [Loan Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.AdvAmt as [Advance Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.VEPFAmt as [Voluntary PF A/C No.-10],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.EDLIContr as [EDLI Contribution A/c No.-21],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.GratuityAmt as [Gratuity Amount],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.EPSAmt as [Employer EPS A/C No.-10],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.EDLIAdChg as [EDLI Admin Charges A/c No.-22],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.PFAdChg as [PF Admin Charges A/c No.-2],'
--set @SqlCommand=rtrim(@SqlCommand)+' '+'M.MLWFAmt as [MLWF Amount],'

end
GO
