DROP PROCEDURE [usp_QC_Queue]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [usp_QC_Queue] as 
begin
select l.code_nm,i.it_name,a.ac_name,m.*
from STKL_VW_ITEM m inner join lcode l on m.entry_ty=l.entry_ty 
		inner join it_mast i on m.it_code=i.it_code
		inner join ac_mast a on m.ac_id=a.ac_id
		inner join It_Advance_Setting adv on i.it_code=adv.it_code
where l.inv_stk='+' and m.QcHoldQty>0 and adv.qcprocess=1 and m.dc_no='' and l.qc_module=1 -- && added by suraj k on date 12-03-2015 for bug-25365 and l.qc_module=1 

end
GO
