set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
 -- Author:  Hetal L. Patel
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate TN CST FORM 01 ANNX I & II
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
ALTER procedure [dbo].[USP_REP_TN_CST_FORM1_Annex12]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= NULL
AS
Declare @FCON as NVARCHAR(2000)
Declare @SQLCOMMAND NVARCHAR(4000)
Declare @gro_amt decimal(12,2),@taxamt decimal(12,2)

EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE --null
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='m',@VITFILE='',@VACFILE=''
,@VDTFLD ='DATE'
,@VLYN =NULL
,@VEXPARA=@EXPARA
,@VFCON =@FCON OUTPUT


select part=3,blno=m.inv_no,bldt=m.date,m.cate,a.ac_name,a.add1,a.add2,a.add3
,m.u_pinvno,m.u_pinvdt,i.gro_amt,sh_party=a1.ac_name,sh_add1=a1.add1,sh_add2=a1.add2,sh_add3=a1.add3
,endo_date=m.date,land_date=m.date,transist_invno=m.inv_no,transist_date=m.date,st_invno=m.inv_no,st_date=m.date,st_gro_amt=m.gro_amt
,buyer_name=a2.ac_name,buyer_add1=a2.add1,buyer_add2=a2.add2,buyer_add3=a2.add3
into #tn_CST_FORM1_PART2
from ptmain m
inner join ptitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)
inner join ac_mast a on (m.ac_id=a.ac_id)
inner join ac_mast a1 on (m.ac_id=a1.ac_id) --change to shipment party field.
inner join ac_mast a2 on (m.ac_id=a2.ac_id) --change to Buyer party field.
where 1=2

Declare @MultiCo	VarChar(3)
Declare @MCON as NVARCHAR(2000)
IF Exists(Select A.ID From SysObjects A Inner Join SysColumns B On(A.ID = B.ID) Where A.[Name] = 'STMAIN' And B.[Name] = 'DBNAME')
	Begin	------Fetch Records from Multi Co. Data
		Set @MultiCo = 'YES'

		if not exists(select * from #tn_CST_FORM1_PART2 where part=1)
		begin
			insert into #tn_CST_FORM1_PART2
			(part,blno,bldt,cate,ac_name,add1,add2,add3
			,u_pinvno,u_pinvdt,gro_amt,sh_party,sh_add1,sh_add2,sh_add3
			,endo_date,land_date,transist_invno,transist_date,st_invno,st_date,st_gro_amt
			,buyer_name,buyer_add1,buyer_add2,buyer_add3
			)
			values
			(1,'','','','','','',''
			,'','',0,'','','',''
			,'','','','','','',0
			,'','','',''
			)
		end
		if not exists(select * from #tn_CST_FORM1_PART2 where part=2)
		begin
			insert into #tn_CST_FORM1_PART2
			(part,blno,bldt,cate,ac_name,add1,add2,add3
			,u_pinvno,u_pinvdt,gro_amt,sh_party,sh_add1,sh_add2,sh_add3
			,endo_date,land_date,transist_invno,transist_date,st_invno,st_date,st_gro_amt
			,buyer_name,buyer_add1,buyer_add2,buyer_add3
			)
			values
			(2,'','','','','','',''
			,'','',0,'','','',''
			,'','','','','','',0
			,'','','',''
			)
		end
	End
Else
	Begin	------Fetch Records from Multi Co. Data
		Set @MultiCo = 'NO'

		if not exists(select * from #tn_CST_FORM1_PART2 where part=1)
		begin
			insert into #tn_CST_FORM1_PART2
			(part,blno,bldt,cate,ac_name,add1,add2,add3
			,u_pinvno,u_pinvdt,gro_amt,sh_party,sh_add1,sh_add2,sh_add3
			,endo_date,land_date,transist_invno,transist_date,st_invno,st_date,st_gro_amt
			,buyer_name,buyer_add1,buyer_add2,buyer_add3
			)
			values
			(1,'','','','','','',''
			,'','',0,'','','',''
			,'','','','','','',0
			,'','','',''
			)
		end
		if not exists(select * from #tn_CST_FORM1_PART2 where part=2)
		begin
			insert into #tn_CST_FORM1_PART2
			(part,blno,bldt,cate,ac_name,add1,add2,add3
			,u_pinvno,u_pinvdt,gro_amt,sh_party,sh_add1,sh_add2,sh_add3
			,endo_date,land_date,transist_invno,transist_date,st_invno,st_date,st_gro_amt
			,buyer_name,buyer_add1,buyer_add2,buyer_add3
			)
			values
			(2,'','','','','','',''
			,'','',0,'','','',''
			,'','','','','','',0
			,'','','',''
			)
		end
	End
select * from #tn_CST_FORM1_PART2
DROP TABLE #tn_CST_FORM1_PART2
--Print 'TN VAT ANNEXURE TO CAPITAL I & II'

