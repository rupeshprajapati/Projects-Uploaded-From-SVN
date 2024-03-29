DROP PROCEDURE [USP_AC_MASTDRCR]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [USP_AC_MASTDRCR]
@FDate SMALLDATETIME,@TDate SMALLDATETIME
AS
SELECT a.Ac_id,
Debit = isnull(CASE Amt_Ty WHEN 'DR' THEN Sum(a.Amount)END,0),
Credit = isnull(CASE Amt_Ty WHEN 'CR' THEN Sum(a.Amount) END,0)
from lac_vw a,lmain_vw b
where (a.entry_ty = b.entry_ty and a.Tran_cd = b.Tran_cd)
and a.entry_ty <> 'OB'
and (b.Date Between @FDate AND @TDate)
group by a.Ac_id,a.amt_ty
GO
