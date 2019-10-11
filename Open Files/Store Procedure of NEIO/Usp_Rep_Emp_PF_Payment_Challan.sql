DROP PROCEDURE [Usp_Rep_Emp_PF_Payment_Challan]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI
-- CREATE DATE: 20/04/2009
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO GENERATE Employee PF CHALLAN REPORT.
-- MODIFY DATE/BY/Reason:
-- REMARK:
-- =============================================
CREATE PROCEDURE   [Usp_Rep_Emp_PF_Payment_Challan]
	@ENTRYCOND NVARCHAR(254)
AS
Begin
	Declare @Month varchar(100)
	print 'R'
	SET QUOTED_IDENTIFIER OFF
	DECLARE @SQLCOMMAND NVARCHAR(4000),@FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)
	Select Tran_cd into #PFChal1 From CRItem where 1=2
	
		declare @ent varchar(2),@trn int,@pos1 int,@pos2 int,@pos3 int--,@ENTRYCOND NVARCHAR(254)
		if(charindex('m.Date between',@ENTRYCOND)>0) /*Sp Called from USP_REP_EMP_TDS_CHALLAN_MENU*/
		begin
			set @SQLCOMMAND='insert into #PFChal1 Select Tran_Cd From Bpmain m where Entry_ty=''FH'' and '+@ENTRYCOND
			print @SQLCOMMAND
			execute Sp_ExecuteSql @SQLCOMMAND
		end
		else/*Sp Called from Voucher*/
		Begin
			/*--->Entry_Ty and Tran_Cd Separation*/
			print @ENTRYCOND
			set @pos1=charindex('''',@ENTRYCOND,1)+1
			set @ent= substring(@ENTRYCOND,@pos1,2)
			set @pos2=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos1))+1
			set @pos3=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos2))+1
			set @trn= substring(@ENTRYCOND,@pos2,@pos2-@pos3)
			print 'ent '+ @ent
			print @trn
			insert into #PFChal1 (Tran_cd) values (@trn)
			/*<---Entry_Ty and Tran_Cd Separation*/
		end
	--Select * From #PFChal1
	Select Part=3,SrNo=1,CheueNo=Space(30),RefNo=Space(30),u_chalno=Space(30),Particulars=Space(250)
	,Ac1=NetPayment,Ac2=NetPayment,Ac10=NetPayment,Ac21=NetPayment,Ac22=NetPayment,tAmt=NetPayment into #PFChal From Emp_Monthly_Payroll Where 1=2

	
	insert into #PFChal  
	Select 
	Part=3,SrNo=1,m.Cheq_No,RefNo=m.Inv_no,ChalNo=m.u_chalno,Particulars='EMPLOYER''S SHARE OF CONT'
	,Ac1=m.PFEmpR,Ac2=0,Ac10=(m.EPSAMT+m.VEPFAmt),Ac21=m.EDLIContr,Ac22=0,tAmt=0--m.EDLIAdChg
	from BpMain m 
	inner join #PFChal1 tem on (tem.Tran_cd=m.Tran_cd)
	where m.Tran_cd in  (Select Distinct FH_Trn_Cd From Emp_Monthly_Payroll)
	--inner join Emp_Monthly_Payroll mnp on (m.entry_ty=mnp.FH_Ent_TY and m.tran_cd=mnp.FH_Trn_Cd)

	insert into #PFChal  
	Select 
	Part=3,SrNo=2,m.Cheq_No,RefNo=m.Inv_no,ChalNo=m.u_chalno,Particulars='EMPLOYEES''S SHARE OF CONT'
	,Ac1=m.PFEmpE,Ac2=0,Ac10=0,Ac21=0,Ac22=0,tAmt=0
	from BpMain m 
	inner join #PFChal1 tem on (tem.Tran_cd=m.Tran_cd)
	where m.Tran_cd in  (Select Distinct FH_Trn_Cd From Emp_Monthly_Payroll)

--	insert into #PFChal  
--	Select 
--	Part=3,SrNo=3,m.Cheq_No,RefNo=m.Inv_no,ChalNo=m.u_chalno,Particulars='EMPLOYEES SHARE OF CONT'
--	,Ac1=0,Ac2=PFAdChg,Ac10=0,Ac21=0,Ac22=0,tAmt=0
--	from BpMain m 
--	inner join #PFChal1 tem on (tem.Tran_cd=m.Tran_cd)
--	where m.Tran_cd in  (Select Distinct FH_Trn_Cd From Emp_Monthly_Payroll)

	insert into #PFChal  
	Select 
	Part=3,SrNo=4,m.Cheq_No,RefNo=m.Inv_no,ChalNo=m.u_chalno,Particulars='ADMIN CHARGES'
	,Ac1=0,Ac2=m.PFAdChg,Ac10=0,Ac21=0,Ac22=m.EDLIAdChg,tAmt=0
	from BpMain m 
	inner join #PFChal1 tem on (tem.Tran_cd=m.Tran_cd)
	where m.Tran_cd in  (Select Distinct FH_Trn_Cd From Emp_Monthly_Payroll)

	insert into #PFChal  
	Select 
	Part=3,SrNo=5,m.Cheq_No,RefNo=m.Inv_no,ChalNo=m.u_chalno,Particulars='PENAL DAMAGES'
	,Ac1=0,Ac2=0,Ac10=0,Ac21=0,Ac22=0,tAmt=0
	from BpMain m 
	inner join #PFChal1 tem on (tem.Tran_cd=m.Tran_cd)
	where m.Tran_cd in  (Select Distinct FH_Trn_Cd From Emp_Monthly_Payroll)
	print 'P-3'
	insert into #PFChal  
	Select 
	Part=3,SrNo=6,m.Cheq_No,RefNo=m.Inv_no,ChalNo=m.u_chalno,Particulars='MISC PAYMENT (INTEREST U/S 7Q)'
	,Ac1=0,Ac2=0,Ac10=0,Ac21=0,Ac22=0,tAmt=0
	from BpMain m 
	inner join #PFChal1 tem on (tem.Tran_cd=m.Tran_cd)
	where m.Tran_cd in  (Select Distinct FH_Trn_Cd From Emp_Monthly_Payroll)
	
	Select distinct EmployeeCode into #EmpList From Emp_Monthly_Payroll mnp inner join #PFChal1 tem on (tem.Tran_cd=mnp.FH_Trn_Cd)
	Select top 1 @Month=DATENAME(month, GETDATE())+'-'+substring(l_yn,1,4) From BpMain m inner join #PFChal1 tem on (tem.Tran_cd=m.Tran_cd)
	print 'P-1'
	insert into #PFChal  
	Select
	Part=1,SrNo=1,Cheq_No='',RefNo='',ChalNo='',Particulars='TOTAL SUBSCRIBERS'
	,Ac1= count(employeeCode),Ac2=0,Ac10=0,Ac21=0,Ac22=0,tAmt=0
	from #EmpList
	print 'P-2'
	insert into #PFChal
	Select 
	Part=2,SrNo=1,Cheq_No='',RefNo='',ChalNo='',Particulars='TOTAL WAGES'-- ''
	,Ac1=sum(Ac1),Ac2=sum(Ac2),Ac10=sum(Ac10),Ac21=sum(Ac21),Ac22=sum(Ac22),tAmt=0
	from #PFChal
	
	update #PFChal set Ac1=isnull(Ac1,0),Ac2=isnull(Ac2,0),Ac10=isnull(Ac10,0),Ac21=isnull(Ac21,0),Ac22=isnull(Ac22,0)
	
	update #PFChal set tAmt=Ac1+Ac2+Ac10+Ac21+Ac22

	--Where Tran_cd in (Select distinct Tran_cd From )
	--,CheueNo=Space(30),RefNo=Space(30),Particulars=Space(250),Ac1=NetPayment,Ac2=NetPayment,Ac21=NetPayment,Ac22=NetPayment,tAmt=NetPayment
	
	Select cMonth=@Month,* From #PFChal order by Part,SrNo
	
	--EXECUTE [Usp_Rep_Emp_PF_Payment_Challan] "A.ENTRY_TY = 'FH' AND A.TRAN_CD =1375 " 
end
GO
