DROP PROCEDURE [USP_ENT_BOMDET_RN]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Shrikant S. 		
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful In Material Requisition Note
-- Remark: 			
-- Remark: 
-- =============================================
CREATE PROCEDURE [USP_ENT_BOMDET_RN]
@ENTRY_TY  VARCHAR(2),@TRAN_CD  INT,@SDATE SMALLDATETIME,@RULE VARCHAR(20),@INV_SR VARCHAR(20),@CATE VARCHAR(20),@DEPT VARCHAR(20),@ProdName VARCHAR(10)
,@proc_Id varchar(10) 
AS
DECLARE @SQLCOMMAND NVARCHAR(4000)
Declare @mpqty numeric(18,4) 
SELECT @INV_SR ='',@CATE='',@DEPT =''
select wi.inv_no,wi.date,it1.it_name
,wi.it_code,item=it.it_name,wi.entry_ty,wi.tran_cd,wi.itserial,wi.qty,wi.bomid,wi.bomlevel
,d.rmitemid,rmitem=it1.it_name,rqty=wi.qty,reqty=wi.qty
,iqty=wi.qty,aiqty=wi.qty,balqty=wi.qty
,sqtym=wi.qty
,orgqty=wi.qty 
,posqty=wi.qty,wkqty=wi.qty
,mclear=wi.qty,mpending=wi.qty
,wi.trm_qty									
,d.isbom 
,it.rate 
,d.rmqty,h.fgqty  
into #bomdet1
from item wi  
inner join it_mast it on (wi.it_code=it.it_code)
inner join bomhead h on (wi.bomid=h.bomid and wi.bomlevel=h.bomlevel)
inner join bomdet d on (h.bomid=d.bomid and h.bomlevel=d.bomlevel)
inner join it_mast it1 on (d.rmitemid=it1.it_code )
where 1=2 order by wi.Entry_ty,wi.Tran_cd,wi.Itserial

SET @SQLCOMMAND ='INSERT INTO #bomdet1 select wi.inv_no,wi.date,it1.it_name'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',wi.it_code,item=it.it_name,wi.entry_ty,wi.tran_cd,wi.itserial,wi.qty,wi.bomid,wi.bomlevel'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',d.rmitemid,rmitem=it1.it_name,rqty=d.rmqty/h.fgqty,reqty=(wi.qty*d.rmqty)/h.fgqty ' 
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',iqty=wi.qty,aiqty=wi.qty,balqty=wi.qty,sqtym=wi.qty'

SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',orgqty=wi.qty'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',posqty=wi.qty,wkqty=0'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',mclear=0,mpending=0,wi.trm_qty'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',d.isbom' 
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',it.rate' 
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',d.rmqty,h.fgqty' 
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'from item wi  '
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'inner join it_mast it on (wi.it_code=it.it_code)'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'inner join bomhead h on (wi.bomid=h.bomid and wi.bomlevel=h.bomlevel)'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'inner join bomdet d on (h.bomid=d.bomid and h.bomlevel=d.bomlevel)'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'inner join it_mast it1 on (d.rmitemid=it1.it_code )'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'where wi.entry_ty='+CHAR(39)+'WK'+CHAR(39)
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'AND WI.DATE< ='+CHAR(39)+CAST(@SDATE AS VARCHAR)+CHAR(39)
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'and wi.proc_ID='+CHAR(39)+ltrim(rtrim(@proc_id))+CHAR(39)
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'order by wi.Entry_ty,wi.Tran_cd,wi.Itserial'
print @SQLCOMMAND
EXECUTE SP_EXECUTESQL  @SQLCOMMAND


update #bomdet1 set iqty=0,balqty=0,aiqty=0,qty=0


select i.it_code,sqtym=sum(i.qty),rate=max(i.Rate) into #it_bal  from STKL_VW_ITEM i WHERE 1=2 group by i.it_code
SET @SQLCOMMAND ='INSERT INTO #it_bal select i.it_code'   

if ltrim(rtrim(@ProdName))='QC'
begin   
	SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',sqtym=sum(case when m.[rule] in ('+char(39)+'MODVATABLE'+char(39)+','+char(39)+'ANNEXURE IV'+char(39)+','+char(39)+'CAPTIVE USE'+char(39)+') then (isnull(case when pmkey='+CHAR(39)+'+'+CHAR(39)+' then CASE WHEN IT.QCPROCESS=1 THEN i.qcaceptqty ELSE I.QTY END else CASE WHEN IT.QCPROCESS=1 THEN -i.qcaceptqty ELSE -QTY END end,0)) else 0 end)'
end
else
begin

	SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',sqtym=sum(case when m.[rule] in ('+char(39)+'MODVATABLE'+char(39)+','+char(39)+'ANNEXURE IV'+char(39)+','+char(39)+'CAPTIVE USE'+char(39)+') then (isnull(case when pmkey='+CHAR(39)+'+'+CHAR(39)+' then i.qty else -i.qty end,0))-i.qcrejqty else 0 end)'		--Changed by Shrikant S. on 06/09/2010 For TKT-3787
end

SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+',Rate=max(i.Rate)'

SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'from STKL_VW_ITEM i' 
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'INNER JOIN STKL_VW_MAIN M ON (M.TRAN_CD=I.TRAN_CD AND M.ENTRY_TY=I.ENTRY_TY)'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'LEFT OUTER JOIN it_advance_setting IT ON (I.IT_CODE=IT.IT_CODE)'		
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'WHERE NOT (I.ENTRY_TY='+CHAR(39)+@ENTRY_TY+CHAR(39)+' AND I.TRAN_CD='+CAST(@TRAN_CD AS VARCHAR)+')'
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+'and i.dc_no='''''
SET @SQLCOMMAND =RTRIM(@SQLCOMMAND)+' '+' group by i.it_code'
PRINT @SQLCOMMAND
EXECUTE SP_EXECUTESQL @SQLCOMMAND


--select * from #it_bal


update a set a.sqtym=b.sqtym,a.rate=b.rate from  #bomdet1 a inner join #it_bal b on (a.rmitemid=b.it_code)	

select b.it_code,b.bomid,b.bomlevel,iqty=sum(isnull(b.qty,0)),aentry_ty,atran_cd,aitserial into #PROJECTITREF from PROJECTITREF b  WHERE NOT (ENTRY_TY=@ENTRY_TY AND TRAN_CD=@TRAN_CD ) AND ENTRY_TY in('RN','WI','IP','MR') group by b.it_code,b.bomid,b.bomlevel,aentry_ty,atran_cd,aitserial

--select * from #PROJECTITREF

update a set a.iqty=b.iqty from  #bomdet1 a inner join #PROJECTITREF b on (a.bomid=b.bomid and a.bomlevel=b.bomlevel and a.entry_ty=b.aentry_ty and a.tran_cd=b.atran_cd and a.itserial=b.aitserial and a.rmitemid=b.it_code and a.rmitemid=b.it_code ) 

update #bomdet1 set balqty=reqty-iqty-(trm_qty*rqty),qty=0 

declare @fldlist varchar(4000),@fld_nm varchar(20)
set @fldlist=' '
declare cur_bomdetip cursor for select fld_nm from lother where e_code='WK' and att_file=0 order by serial
open cur_bomdetip
fetch next from cur_bomdetip into @fld_nm
while (@@fetch_status=0)
begin
	set @fldlist=rtrim(@fldlist)+',b.'+rtrim(@fld_nm)
	fetch next from cur_bomdetip into @fld_nm
end
close cur_bomdetip
deallocate cur_bomdetip

print @fldlist

update #bomdet1 set mpending=(orgqty*balqty)/reqty

select @mpqty=max(mpending) from #bomdet1

update #bomdet1 set mpending=isnull(@mpqty,0) 

update #bomdet1 set posqty=mpending where mpending<posqty

set @sqlcommand='select a.*'+@fldlist+' from #bomdet1 a inner join item b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd and a.itserial=b.itserial) order by a.bomid'
print @sqlcommand
execute sp_executesql @sqlcommand
GO
