set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go

-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful to generate Karanataka Vat Purchase Register Report.
-- Modify date: 16/05/2007
-- Modified By: 
-- Modify date: 
-- Remark:
-- =============================================
ALTER PROCEDURE [dbo].[USP_REP_KV_PTREG]
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


SET QUOTED_IDENTIFIER OFF
DECLARE @FCON AS NVARCHAR(2000),@VSAMT DECIMAL(14,4),@VEAMT DECIMAL(14,4)
DECLARE @FDATE VARCHAR(15)
SELECT @FDATE=CASE WHEN DBDATE=1 THEN 'DATE' ELSE 'U_CLDT' END FROM MANUFACT
EXECUTE   USP_REP_FILTCON 
@VTMPAC =@TMPAC,@VTMPIT =@TMPIT,@VSPLCOND =@SPLCOND
,@VSDATE=@SDATE
,@VEDATE=@EDATE
,@VSAC =@SAC,@VEAC =@EAC
,@VSIT=@SIT,@VEIT=@EIT
,@VSAMT=@SAMT,@VEAMT=@EAMT
,@VSDEPT=@SDEPT,@VEDEPT=@EDEPT
,@VSCATE =@SCATE,@VECATE =@ECATE
,@VSWARE =@SWARE,@VEWARE  =@EWARE
,@VSINV_SR =@SINV_SR,@VEINV_SR =@SINV_SR
,@VMAINFILE='STMAIN',@VITFILE='STITEM',@VACFILE=' '
,@VDTFLD =@FDATE
,@VLYN=@LYN
,@VEXPARA=NULL
,@VFCON =@FCON OUTPUT
DECLARE @SQLCOMMAND NVARCHAR(4000),@VCOND NVARCHAR(1000)

SELECT entry_ty,FLD_NM=SPACE(1000) INTO #DCMAST FROM DCMAST WHERE 1=2

declare @dcentry_ty varchar(2),@dcfld_nm varchar(1000)
declare @mdcentry_ty varchar(2),@mdcfld_nm varchar(1000),@v1 int

--select entry_ty,fld_nm from dcmast where  entry_ty in ('PT','AR','ST') AND ATT_FILE=0 
--AND (BEF_AFT=1 OR CODE IN ('D','T','E','A')) 
--order by entry_ty,corder

--select top 1 entry_ty into #entryty from stmaIn where 1=2
select distinct entry_ty=case when ext_vou=1 then bcode_nm else entry_ty end into #entryty from lcode where  entry_ty in ('ST','PT','AR')
declare  cur_dcmast cursor for 
select entry_ty,fld_nm=rtrim(fld_nm) from dcmast where  entry_ty in ('PT','AR','ST') AND ATT_FILE=0 
AND (BEF_AFT=1 OR CODE IN ('D','T','E','A')) 
order by entry_ty,corder
open cur_dcmast
fetch next from cur_dcmast into @dcentry_ty,@dcfld_nm
set @mdcentry_ty=@dcentry_ty
set @mdcfld_nm=' '
set @v1=0
while (@@fetch_status=0)
begin
	if 	(@mdcentry_ty=@dcentry_ty)
	begin
		set @v1=@v1+1
		set @mdcfld_nm=@mdcfld_nm+'+'+@dcfld_nm	
	end
	else
	begin
		set @v1=0
		insert into #dcmast (entry_ty,fld_nm) values (@mdcentry_ty,@mdcfld_nm)
		set @mdcentry_ty=@dcentry_ty
		set @mdcfld_nm='+'+@dcfld_nm
	end
	fetch next from cur_dcmast into @dcentry_ty,@dcfld_nm
end
close cur_dcmast
deallocate cur_dcmast
if(@v1>0)
begin
	print @v1	
	insert into #dcmast (entry_ty,fld_nm) values (@mdcentry_ty,@mdcfld_nm)
end
--select * from #dcmast
--print replace('abc','a','1')
update #dcmast set fld_nm=replace(fld_nm,'+','+i.')
--select tax_name,level1,amtexpr into #stax_mas from stax_mas 



select m.entry_ty,m.tran_cd,m.u_pinvno,m.u_pinvdt,m.inv_no,m.date,dcinv_no=m1.inv_no,dcdate=m1.date
,ac.ac_name,ac.s_tax,qty=i.qty-isnull(ref.rqty,0)
,taxabl_amt=i.examt+i.u_cessamt+i.u_hcesamt,i.taxamt
,rentry_ty=ref.entry_ty,rtran_cd=ref.tran_cd
,st.level1,dcm.fld_nm
,mqty=i.qty,aqty=ref.rqty,part=1
into #kv_purreg1
from ptmain m
inner join ptitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)
left join stkl_vw_itref ref on (i.entry_ty=ref.rentry_ty and i.tran_cd=ref.itref_tran and i.itserial=ref.ritserial)
left join stkl_vw_item i1 on (i.entry_ty=i1.entry_ty and i.tran_cd=i1.tran_cd and i.itserial=i1.itserial)
left join stkl_vw_main m1 on (i1.entry_ty=m1.entry_ty and i1.tran_cd=m1.tran_cd)
left join stax_mas st on (m.tax_name=st.tax_name)
left join #dcmast dcm on (m.entry_ty=dcm.entry_ty)
inner join ac_mast ac on (m.ac_id=ac.ac_id)
where 
--case when isnull(st.amtexpr,space(1))<>space(1),st.amtexpr,0)
--m.entry_ty in ('PT','AR') OR (M.ENTRY_TY='ST' and m.u_imporm='Purchase Return') and 
1=2

select @dcfld_nm=fld_nm from #dcmast where entry_ty='PT'
set @sqlcommand='insert into #kv_purreg1 select m.entry_ty,m.tran_cd,m.u_pinvno,m.u_pinvdt,m.inv_no,m.date,dcinv_no=m1.inv_no,dcdate=m1.date'
set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.ac_name,ac.s_tax,qty=i.qty-isnull(ref.rqty,0)'
set @sqlcommand=rtrim(@sqlcommand)+' '+',taxabl_amt=round((i.qty*i.rate),0)'+@dcfld_nm+',i.taxamt'
set @sqlcommand=rtrim(@sqlcommand)+' '+',rentry_ty=ref.entry_ty,rtran_cd=ref.tran_cd'
set @sqlcommand=rtrim(@sqlcommand)+' '+',st.level1,dcm.fld_nm'
set @sqlcommand=rtrim(@sqlcommand)+' '+',mqty=i.qty,aqty=ref.rqty,part=1'
set @sqlcommand=rtrim(@sqlcommand)+' '+'from ptmain m'
set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ptitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stkl_vw_itref ref on (i.entry_ty=ref.rentry_ty and i.tran_cd=ref.itref_tran and i.itserial=ref.ritserial)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stkl_vw_item i1 on (i.entry_ty=i1.entry_ty and i.tran_cd=i1.tran_cd and i.itserial=i1.itserial)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stkl_vw_main m1 on (i1.entry_ty=m1.entry_ty and i1.tran_cd=m1.tran_cd)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast ac on (m.ac_id=ac.ac_id)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stax_mas st on (m.tax_name=st.tax_name)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join #dcmast dcm on (m.entry_ty=dcm.entry_ty)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'where  m.taxamt<>0 and m.entry_ty in ('+'''PT'''+')'
set @sqlcommand=rtrim(@sqlcommand)+' '+'and m.date between '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'  AND '+CHAR(39)+CAST(@EDATE AS VARCHAR)+CHAR(39)
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

select @dcfld_nm=fld_nm from #dcmast where entry_ty='ST'
set @sqlcommand='insert into #kv_purreg1 select m.entry_ty,m.tran_cd,m.u_pinvno,m.u_pinvdt,m.inv_no,m.date,dcinv_no=m1.inv_no,dcdate=m1.date'
set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.ac_name,ac.s_tax,qty=i.qty-isnull(ref.rqty,0)'
set @sqlcommand=rtrim(@sqlcommand)+' '+',taxabl_amt=(round((i.qty*i.rate),0))*(-1)'+@dcfld_nm+',i.taxamt*(-1)'
set @sqlcommand=rtrim(@sqlcommand)+' '+',rentry_ty=ref.entry_ty,rtran_cd=ref.tran_cd'
set @sqlcommand=rtrim(@sqlcommand)+' '+',st.level1,dcm.fld_nm'
set @sqlcommand=rtrim(@sqlcommand)+' '+',mqty=i.qty,aqty=ref.rqty,part=1'
set @sqlcommand=rtrim(@sqlcommand)+' '+'from stmain m'
set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join stitem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stkl_vw_itref ref on (i.entry_ty=ref.rentry_ty and i.tran_cd=ref.itref_tran and i.itserial=ref.ritserial)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stkl_vw_item i1 on (i.entry_ty=i1.entry_ty and i.tran_cd=i1.tran_cd and i.itserial=i1.itserial)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stkl_vw_main m1 on (i1.entry_ty=m1.entry_ty and i1.tran_cd=m1.tran_cd)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stax_mas st on (m.tax_name=st.tax_name)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join #dcmast dcm on (m.entry_ty=dcm.entry_ty)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast ac on (m.ac_id=ac.ac_id)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'where  m.taxamt<>0 and m.entry_ty in ('+'''ST'''+') and m.u_imporm='+'''Purchase Return'''
set @sqlcommand=rtrim(@sqlcommand)+' '+'and m.date between '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'  AND '+CHAR(39)+CAST(@EDATE AS VARCHAR)+CHAR(39)
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

select @dcfld_nm=fld_nm from #dcmast where entry_ty='AR'
set @sqlcommand='insert into #kv_purreg1 select m.entry_ty,m.tran_cd,m.u_pinvno,m.u_pinvdt,m.inv_no,m.date,dcinv_no=m1.inv_no,dcdate=m1.date'
set @sqlcommand=rtrim(@sqlcommand)+' '+',ac.ac_name,ac.s_tax,qty=i.qty-isnull(ref.rqty,0)'
set @sqlcommand=rtrim(@sqlcommand)+' '+',taxabl_amt=round((i.qty*i.rate),0)'+@dcfld_nm+',i.taxamt'
set @sqlcommand=rtrim(@sqlcommand)+' '+',rentry_ty=ref.entry_ty,rtran_cd=ref.tran_cd'
set @sqlcommand=rtrim(@sqlcommand)+' '+',st.level1,dcm.fld_nm'
set @sqlcommand=rtrim(@sqlcommand)+' '+',mqty=i.qty,aqty=ref.rqty,part=3'
set @sqlcommand=rtrim(@sqlcommand)+' '+'from armain m'
set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join aritem i on (m.entry_ty=i.entry_ty and m.tran_cd=i.tran_cd)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stkl_vw_itref ref on (i.entry_ty=ref.rentry_ty and i.tran_cd=ref.itref_tran and i.itserial=ref.ritserial)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stkl_vw_item i1 on (i.entry_ty=i1.entry_ty and i.tran_cd=i1.tran_cd and i.itserial=i1.itserial)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stkl_vw_main m1 on (i1.entry_ty=m1.entry_ty and i1.tran_cd=m1.tran_cd)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join stax_mas st on (m.tax_name=st.tax_name)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'left join #dcmast dcm on (m.entry_ty=dcm.entry_ty)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'inner join ac_mast ac on (m.ac_id=ac.ac_id)'
set @sqlcommand=rtrim(@sqlcommand)+' '+'where  (i.qty-isnull(ref.rqty,0)>0)  and m.entry_ty in ('+'''AR'''+')'
set @sqlcommand=rtrim(@sqlcommand)+' '+'and m.date between '+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)+'  AND '+CHAR(39)+CAST(@EDATE AS VARCHAR)+CHAR(39)
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND



select part=(case when part=3 then 5 else 4 end)
,level1--=(case when part=3 then 0 else level1 end)
,taxamt=sum(taxamt) 
into #kv_purreg2
from #kv_purreg1 group by (case when part=3 then 5 else 4 end)
,level1--(case when part=3 then 0 else level1 end)

insert into #kv_purreg1 (part,level1,taxamt,tran_cd,ac_name) select part,level1,taxamt,0,' ' from #kv_purreg2 
-------->6
SELECT DISTINCT level1,AC_NAME=SUBSTRING(AC_NAME3,2,CHARINDEX('"',SUBSTRING(AC_NAME3,2,100))-1) INTO #VATAC_MAST FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"') AND AC_NAME3 NOT IN ('"PURCHASES"') AND ISNULL(AC_NAME1,'')<>'' AND ISNULL(AC_NAME3,'')<>''
INSERT INTO #VATAC_MAST SELECT DISTINCT level1,AC_NAME=SUBSTRING(AC_NAME1,2,CHARINDEX('"',SUBSTRING(AC_NAME1,2,100))-1)  FROM STAX_MAS WHERE AC_NAME1 NOT IN ('"SALES"') AND AC_NAME3 NOT IN ('"PURCHASES"') AND ISNULL(AC_NAME1,'')<>'' AND ISNULL(AC_NAME3,'')<>''
--select * from #VATAC_MAST

SELECT 
AC.TRAN_CD,AC.ENTRY_TY,AC.DATE,AC.AMOUNT,AC.AMT_TY
,MN.L_YN
,AC_MAST.AC_ID,AC_MAST.AC_NAME,#VATAC_MAST.LEVEL1
into #AC_BAL1
FROM LAC_VW AC
INNER JOIN AC_MAST  ON (AC.AC_ID = AC_MAST.AC_ID)
INNER JOIN LMAIN_VW MN ON (AC.TRAN_CD = MN.TRAN_CD AND AC.ENTRY_TY = MN.ENTRY_TY) 
inner join #VATAC_MAST ON (AC_MAST.AC_NAME=#VATAC_MAST.AC_NAME)

DELETE FROM #AC_BAL1 WHERE 
DATE < (SELECT TOP 1 DATE FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN)
AND AC_NAME IN (SELECT AC_NAME FROM #AC_BAL1 WHERE ENTRY_TY IN ('OB') AND L_YN = @LYN GROUP BY AC_NAME) 


SELECT AC_NAME,AC_ID,LBAL=SUM(CASE WHEN AMT_TY='DR' THEN AMOUNT ELSE -AMOUNT END),LEVEL1
INTO #AC_BAL
FROM #AC_BAL1
GROUP BY AC_NAME,AC_ID,LEVEL1
ORDER BY AC_NAME,AC_ID

--SELECT * FROM #AC_BAL
insert into #kv_purreg1 (part,level1,taxamt,tran_cd,ac_name) select 6,level1,taxamt=lbal,0,ac_name from #AC_BAL
---<----6

update #kv_purreg1 set qty=isnull(qty,0),taxabl_amt=isnull(taxabl_amt,0),level1=isnull(level1,0)

select * from #kv_purreg1 
order by part,level1
,(case when entry_ty='pt' then 'a' else (case when entry_ty='st' then 'b' else 'c' end) end) 
,tran_cd




--SET @SQLCOMMAND='SELECT SRNO=0,STMAIN.PARTY_NM,STITEM.DATE,STITEM.INV_NO,STITEM.TRAN_CD,STMAIN.[RULE],STITEM.U_ASSEAMT,STITEM.EXAMT,STITEM.U_CESSAMT,STITEM.U_HCESAMT '
--SET @SQLCOMMAND=RTRIM(@SQLCOMMAND)+' '+ ' FROM STITEM  INNER JOIN STMAIN  ON (STITEM.TRAN_CD=STMAIN.TRAN_CD)INNER JOIN IT_MAST  ON (STITEM.IT_CODE=IT_MAST.IT_CODE)  INNER JOIN AC_MAST ON (STMAIN.AC_ID=AC_MAST.AC_ID)'
--PRINT @SQLCOMMAND
--EXECUTE SP_EXECUTESQL @SQLCOMMAND




