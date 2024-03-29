If Exists(Select [name] From SysObjects Where xtype='P' and [Name]='Usp_Rep_ISDBill')
Begin
	Drop Procedure Usp_Rep_ISDBill
End
GO


-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 25/11/2009
-- Description:	This Stored procedure is useful to generate ISD Bill.
-- Modification Date/By/Reason: 11/09/2009 Rupesh Prajapati. Modified for Blank Record For 3<->4 part.
-- Modification Date/By/Reason: By Ajay jaiswal on 17/05/2010 for TKT-461.
-- Remark:
-- Modification Date/By/Reason: 13/03/15 Nilesh Yadav for Bug 25547
-- =============================================
Create Procedure [dbo].[Usp_Rep_ISDBill] 
@ENTRYCOND NVARCHAR(254)
as
begin
	--->Entry_Ty and Tran_Cd Separation
		declare @ent varchar(2),@trn int,@pos1 int,@pos2 int,@pos3 int--,@ENTRYCOND NVARCHAR(254)
		print @ENTRYCOND
		set @pos1=charindex('''',@ENTRYCOND,1)+1
		set @ent= substring(@ENTRYCOND,@pos1,2)
		set @pos2=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos1))+1
		set @pos3=charindex('=',@ENTRYCOND,charindex('''',@ENTRYCOND,@pos2))+1
		set @trn= substring(@ENTRYCOND,@pos2,@pos2-@pos3)
	---<---Entry_Ty and Tran_Cd Separation

	SELECT M.DATE,M.INV_NO
	--,m1.inv_no,m1.date,m1.serty,m1.u_pinvno,m1.u_pinvdt           -- Commented by nilesh for bug 25547 on 13/03/2015
	,m1.inv_no,m1.date,i.serty,m1.u_pinvno,m1.u_pinvdt				-- Added by nilesh for bug 25547 on 13/03/2015
	,i.serbamt,i.sercamt,i.serhamt
	,AC_MAST.AC_NAME,ac_mast.eccno,ac_mast.i_tax,cexregno,ac_mast.division,ac_mast.coll,ac_mast.[range],ac_mast.add1,ac_mast.add2,ac_mast.add3,ac_mast.city,ac_mast.zip
	,m.entry_ty,m.tran_cd,m1entry_ty=m1.entry_ty,m1tran_cd=m1.tran_cd
	,MailName = (CASE WHEN ISNULL(ac_mast.MailName,'')='' THEN ac_mast.ac_name ELSE ac_mast.mailname END)
	FROM SDMAIN M
	INNER JOIN AC_MAST ON (M.AC_ID=AC_MAST.AC_ID)
	inner join ISDAllocation i on (i.entry_ty=m.entry_ty and i.tran_cd=m.tran_cd)
	inner join SerTaxMain_vw m1 on (i.aentry_ty=m1.entry_ty and i.atran_cd=m1.tran_cd)
	WHERE  m.ENTRY_TY= @ent  and m.tran_cd=@trn
end


