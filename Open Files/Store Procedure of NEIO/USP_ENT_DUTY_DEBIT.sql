DROP PROCEDURE [USP_ENT_DUTY_DEBIT]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE  [USP_ENT_DUTY_DEBIT]
@input varchar(30),@SDATE  SMALLDATETIME
,@EDATE  SMALLDATETIME
,@ENTRY_TY VARCHAR(2),@TRAN_CD INT
,@SINV_SR AS VARCHAR(60)
,@SCATE AS VARCHAR(60)
,@SDEPT AS VARCHAR(60)
AS

SET QUOTED_IDENTIFIER OFF
DECLARE @FCON AS NVARCHAR(2000)
DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(1000),@SPLCOND VARCHAR(1000)
DECLARE @FDATE VARCHAR(15)
SELECT @FDATE=CASE WHEN DBDATE=1 THEN 'DATE' ELSE 'U_CLDT' END FROM MANUFACT
SET @SPLCOND = ' YEAR(AC.U_CLDT)>1900 '
EXECUTE   USP_REP_FILTCON 
@VTMPAC =null,@VTMPIT =null,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE
,@VEDATE=null
,@VSAC =null,@VEAC =null
,@VSIT=null,@VEIT=null
,@VSAMT=0,@VEAMT=0
,@VSDEPT=@SDEPT,@VEDEPT=''
,@VSCATE =@SCATE,@VECATE =''
,@VSWARE ='',@VEWARE  =''
,@VSINV_SR =@SINV_SR,@VEINV_SR =''
,@VMAINFILE='m',@VITFILE='ac',@VACFILE=' '
,@VDTFLD ='u_cldt'--@FDATE
,@VLYN=''
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT

select srno,shortnm,ac_name into #er_excise from er_excise where 1=2

IF  CHARINDEX('m.U_CLDT', @FCON)<>0
BEGIN
	SET @FCON=REPLACE(@FCON, 'm.U_CLDT','ac.U_CLDT')
END
IF  CHARINDEX('m.DATE', @FCON)<>0
BEGIN
	SET @FCON=REPLACE(@FCON, 'm.DATE','ac.U_CLDT')
END

if (@input='GST')
begin
	print 'GST'
	insert into #er_excise (srno,shortnm,ac_name) select srno,shortnm,ac_name from er_excise where (crac=1) and (ac_name like '%GST pay%' or ac_name like '%cess pay%') group by srno,shortnm,ac_name
end

select sel=cast (0 as bit)
,ex.srno,ex.shortnm,ac.ac_id,ac_mast.ac_name
,balamt =AC.AMOUNT,mbalamt =AC.AMOUNT
,adjamt=AC.AMOUNT
,intamt=AC.AMOUNT,fee=AC.AMOUNT,AdvAmt=AC.AMOUNT,OtherAmt=AC.AMOUNT,intac=ac_mast.ac_name,feeac=ac_mast.ac_name,advac=ac_mast.ac_name,otherac=ac_mast.ac_name
,ac.entry_ty,ac.Tran_cd,ac.acserial,ac.date
,RCM_OR_NOTRCM=CAST(0 as bit)
,cast('' as varchar(500)) as AGAINSTGS
Into #exdebit1
from vw_GST_Ac_Det ac  
inner join ac_mast on (ac.ac_id=ac_mast.ac_id)
inner join er_excise ex on (ac_mast.ac_name=ex.ac_name)   
WHERE 1=2

--select * from #exdebit1

print @fcon
print @FDATE

IF (@input='GST')
BEGIN

	select entry_ty,tran_cd
	into #malloc 
	from Acdetalloc 
	Where Entry_ty in ('BP','CP','B1','C1','IF','OF') 
	and (IGSRT_AMT + CGSRT_AMT+ SGSRT_AMT ) >0


SET @SQLCOMMAND='insert into #exdebit1 select sel=cast (0 as bit),ex.srno,ex.shortnm'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,ac.ac_id,ac_mast.ac_name,balamt =(isnull(CASE WHEN AC.AMT_TY=''CR'' THEN AC.AMOUNT ELSE -AC.AMOUNT END,0)),mbalamt =0'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,adjamt=cast(0 as decimal(17,2) ),intamt=0,fee=0,AdvAmt=0,OtherAmt=0,intac='''',feeac='''',advac='''',otherac=''''	'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,ac.entry_ty,ac.tran_cd,ac.acserial,date=case when year(m.u_cldt)>2000 then m.u_cldt else m.date end'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' ,RCM_OR_NOTRCM=CAST(0 as bit)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' ,m.AGAINSTGS'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' from lac_vw ac '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join vw_gst_main m on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join ac_mast on (ac.ac_id=ac_mast.ac_id)  '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' inner join #er_excise ex on (ac_mast.ac_name=ex.ac_name)  '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' WHERE (m.u_cldt <= '''+CONVERT(VARCHAR(50),@EDATE)+''' and year(m.u_cldt)>2000 ) '
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND (ac_mast.Typ like ''%GST PAY%'' or ac_mast.Typ like ''%COMP CESS PAY%'')'
SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+' AND NOT (M.ENTRY_TY='+CHAR(39)+@ENTRY_TY+CHAR(39)+' AND M.TRAN_CD='+LTRIM(CAST(@TRAN_CD AS VARCHAR))+')'
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND
END

Delete a from #exdebit1 A LEFT JOIN MAINALL_VW MV ON (A.ENTRY_TY=MV.ENTRY_ALL AND A.TRAN_CD=MV.MAIN_TRAN AND A.ACSERIAL=MV.ACSERI_ALL) 
--Where a.entry_ty in ('E1','BP','CP','UB','PT','P1','GC','GD')   --Commented by Priyanka B on 30082018 for Bug-31756
Where a.entry_ty in ('E1','BP','CP','UB','PT','P1','GC')  --Modified by Priyanka B on 30082018 for Bug-31756
AND a.AC_NAME LIKE '%Payable%' AND a.AGAINSTGS NOT IN ('SALES')

SELECT * iNTO #exdebit2 FROM #exdebit1 WHERE 1=2

INSERT INTO #exdebit2 select sel=cast (0 as bit),ex.srno,ex.shortnm
,ac.ac_id,ac_mast.ac_name,balamt =(isnull(CASE WHEN AC.AMT_TY='CR' THEN AC.AMOUNT ELSE -AC.AMOUNT END,0)),mbalamt =0
,adjamt=cast(0 as decimal(17,2) ),intamt=0,fee=0,AdvAmt=0,OtherAmt=0,intac='',feeac='',advac='',otherac=''	
,ac.entry_ty,ac.tran_cd,ac.acserial,date=case when year(m.u_cldt)>2000 then m.u_cldt else m.date end
,RCM_OR_NOTRCM=CAST(0 as bit)
,m.AGAINSTGS
from lac_vw ac 
inner join vw_gst_main m on (m.entry_ty=ac.entry_ty and m.tran_cd=ac.tran_cd)
inner join ac_mast on (ac.ac_id=ac_mast.ac_id)  
inner join #er_excise ex on (ac_mast.ac_name=ex.ac_name)  
WHERE (m.u_cldt <=@EDATE)  and year(m.u_cldt)>2000  
AND (ac_mast.Typ like '%GST PAY%' or ac_mast.Typ like '%COMP CESS PAY%')
and (ac.entry_ty +QUOTENAME(ac.Tran_cd)+ac.ACSERIAL) in (select (entry_ALL +QUOTENAME(MAIN_TRAN)+ACSERI_ALL) from  Mainall_vw where entry_ty='GB' and (Entry_ty+QUOTENAME(tran_cd)) not in(@entry_ty+QUOTENAME(@TRAN_CD)))

UPDATE A SET BALAMT=(CASE WHEN (A.BALAMT=B.NEW_ALL) THEN A.BALAMT ELSE B.NEW_ALL END)
FROM #exdebit2 A INNER JOIN MAINALL_VW B ON (A.ENTRY_TY=B.ENTRY_ALL AND A.TRAN_CD=B.MAIN_TRAN AND A.ACSERIAL=B.ACSERI_ALL)

IF NOT EXISTS(SELECT * FROM #exdebit1 A INNER JOIN #exdebit2 B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD)
WHERE A.ENTRY_TY='GB' AND A.AC_NAME<>B.AC_NAME AND A.ACSERIAL<>B.ACSERIAL) 
BEGIN 
	PRINT 1
	DELETE FROM #exdebit2 WHERE ENTRY_TY IN ('GD') AND AC_NAME LIKE '%Payable%'
END

INSERT INTO #exdebit1 SELECT * FROM #exdebit2

DROP TABLE #exdebit2

Select sel,srno,shortnm,ac_id,ac_name
,balamt =SUM(balamt),mbalamt =Convert(Numeric(18,2),0)
,adjamt=Convert(Numeric(18,2),0)
,intamt=Convert(Numeric(18,2),0),fee=Convert(Numeric(18,2),0),AdvAmt=Convert(Numeric(18,2),0),OtherAmt=Convert(Numeric(18,2),0),intac,feeac,advac,otherac
Into #exdebit 
from #exdebit1 
group by sel,srno,SHORTNM,ac_id,ac_name,intac,feeac,advac,otherac 
order by sel,srno,SHORTNM,ac_id,ac_name

--select * from #exdebit 
--return

drop table #exdebit1

update #exdebit set mbalamt=balamt

delete from #exdebit where  mbalamt <=0

insert into #exdebit 
select sel=cast (0 as bit),ex.srno,ex.shortnm
,ac_mast.ac_id,ac_mast.ac_name
,balamt =0,adjamt=0,mbalamt=0,intamt=0,fee=0,AdvAmt=0,OtherAmt=0,intac='',feeac='',advac='',otherac=''
from #er_excise ex
inner join ac_mast on (ac_mast.ac_name=ex.ac_name)
WHERE rtrim(ex.ac_name) not in (select distinct rtrim(ac_name) from #exdebit)

Declare @cintamt Numeric(12,2),@cfee Numeric(12,2),@cAdvAmt Numeric(12,2),@sintamt Numeric(12,2),@sfee Numeric(12,2),@sAdvAmt Numeric(12,2),@iintamt Numeric(12,2),@ifee Numeric(12,2),@iAdvAmt Numeric(12,2),@ccintamt Numeric(12,2),@ccfee Numeric(12,2),@ccAdvAmt Numeric(12,2)

Select @cintamt=0,@cfee=0,@cAdvAmt=0,@sintamt=0,@sfee=0,@sAdvAmt=0,@iintamt=0,@ifee=0,@iAdvAmt=0,@ccintamt=0,@ccfee=0,@ccAdvAmt=0 

Select @cintamt=cintamt,@cfee=cfeeamt,@cAdvAmt=cTaxAmt,@sintamt=sintamt,@sfee=sfeeamt,@sAdvAmt=sTaxAmt
	,@iintamt=iintamt,@ifee=ifeeamt,@iAdvAmt=iTaxAmt,@ccintamt=ccintamt,@ccfee=ccfeeamt,@ccAdvAmt=ccTaxAmt  From Bpmain where  Entry_ty=@ENTRY_TY  and Tran_cd=@TRAN_CD

Update #exdebit set intac='State GST Interest Payable A/C'
,feeac='State GST Late Fee Payable A/C'
,advac='State GST Payable A/C',intamt=@sintamt,fee=@sfee,AdvAmt=@sAdvAmt where ac_name='State GST Payable A/C'
Update #exdebit set intac='Central GST Interest Payable A/C'
,feeac='Central GST Late Fee Payable A/C'
,advac='Central GST Payable A/C',intamt=@cintamt,fee=@cfee,AdvAmt=@cAdvAmt where ac_name='Central GST Payable A/C '
Update #exdebit set intac='Integrated GST Interest Payable A/C'
,feeac='Integrated GST Late Fee Payable A/C'
,advac='Integrated GST Payable A/C',intamt=@iintamt,fee=@ifee,AdvAmt=@iAdvAmt where ac_name='Integrated GST Payable A/C'
Update #exdebit set intac='Compensation Cess Interest Payable A/C'
,feeac='Compensation Cess Late Fee Payable A/C'
,advac='Compensation Cess Payable A/C',intamt=@ccintamt,fee=@ccfee,AdvAmt=@ccAdvAmt where ac_name='Compensation Cess Payable A/C'

select * from #exdebit oRDER BY SRNO