DROP PROCEDURE [Usp_Rep_Emp_ESIC_Payment_Challan]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		RUEPESH PRAJAPATI
-- CREATE DATE: 20/04/2009
-- DESCRIPTION:	THIS STORED PROCEDURE IS USEFUL TO GENERATE Employee ESIC CHALLAN REPORT.
-- MODIFY DATE/BY/Reason:
-- REMARK:
-- =============================================
Create PROCEDURE   [Usp_Rep_Emp_ESIC_Payment_Challan]
	@ENTRYCOND NVARCHAR(254)
AS
Begin
	Declare @Cnt int
	Declare @RangeFrom Decimal(17,2),@RangeTo Decimal(17,2),@Amount Decimal(17,2)
	print 'R'
	SET QUOTED_IDENTIFIER OFF
	DECLARE @SQLCOMMAND NVARCHAR(4000),@FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)
	Select Tran_cd into #PTChal1 From CRItem where 1=2
	
		declare @ent varchar(2),@trn int,@pos1 int,@pos2 int,@pos3 int--,@ENTRYCOND NVARCHAR(254)
		if(charindex('m.u_Cldt between',@ENTRYCOND)>0) /*Sp Called from USP_REP_EMP_TDS_CHALLAN_MENU*/
		begin
			set @SQLCOMMAND='insert into #PTChal1 Select Tran_Cd From Bpmain m where Entry_ty=''EH'' and '+@ENTRYCOND
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
			insert into #PTChal1 (Tran_cd) values (@trn)
			/*<---Entry_Ty and Tran_Cd Separation*/
		end
	--EXECUTE [Usp_Rep_Emp_ESIC_Payment_Challan] "A.ENTRY_TY = 'EH' AND A.TRAN_CD =1377 " 
	Select distinct EmployeeCode into #EmpList From Emp_Monthly_Payroll m inner join #PTChal1 p on(p.Tran_Cd=m.EH_Trn_Cd)
	Select @Cnt=count(EmployeeCode) From #EmpList
	SELECT DISTINCT M.L_YN ,CHALNO=ISNULL(M.U_CHALNO,''),CHALDT=ISNULL(M.U_CHALDT,''),M.CHEQ_NO,M.u_chqdt,M.DATE,BANK_NM=ISNULL(M.BANK_NM,''),m.u_ClDt 
	,ESICEmpR=sum(m.ESICEmpR) 
	,ESICEmpE=sum(m.ESICEmpE) 
	,DRAWN_ON=ISNULL(M.DRAWN_ON,'') 
	,NoEmp=isNull(@Cnt,0)
	INTO #PTChal
	FROM BpMain M 
	INNER JOIN BpAcDet AC ON (M.ENTRY_TY=AC.ENTRY_TY AND M.TRAN_CD=AC.TRAN_CD) 
	INNER JOIN AC_MAST A ON (AC.AC_ID=A.AC_ID)
	inner join #PTChal1 tem on (tem.Tran_cd=m.Tran_cd)
	group by M.L_YN ,ISNULL(M.U_CHALNO,''),ISNULL(M.U_CHALDT,''),CHEQ_NO,m.u_chqdt,m.DATE,ISNULL(M.BANK_NM,''),m.u_ClDt,M.DRAWN_ON 
	SELECT * FROM #PTChal order by Chaldt,ChalNo
end
GO
