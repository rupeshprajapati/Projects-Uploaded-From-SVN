DROP PROCEDURE [USP_ENT_WO_TERMINATE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		SATISH PAL
-- Create date: 30/10/2012
-- Description:	This Stored procedure is useful to Termination of Work Order(BUG-3335)
-- Modification Date/By/Reason: 
-- Remark:
-- =============================================
create PROCEDURE [USP_ENT_WO_TERMINATE]
AS
SELECT ENTRY_TY,TRAN_CD,ITSERIAL,I.INV_NO,I.DATE,I.IT_CODE,IT.IT_NAME,BOMID,BOMLEVEL,ORGQTY=I.QTY,IPQTY=I.QTY,OPQTY=I.QTY,QTY,BALQTY=QTY,trm_date,trm_qty
INTO #WKOPITEM
FROM ITEM I
INNER JOIN IT_MAST IT ON (I.IT_CODE=IT.IT_CODE)

UPDATE #WKOPITEM SET OPQTY=0,QTY=0,BALQTY=0,IPQTY=0
	select aentry_ty,atran_cd,aitserial,qty=sum(qty) into #PROJECTITREF from PROJECTITREF b  WHERE   ENTRY_TY='OP' group by aentry_ty,atran_cd,aitserial		
	update a SET OPQTY=b.qty from #WKOPITEM a inner join #PROJECTITREF b on (a.entry_ty=b.aentry_ty and a.tran_cd=b.atran_cd and a.itserial=b.aitserial)
	
SELECT INV_NO,IT_NAME,IT_CODE,ORGQTY,ENTRY_TY,TRAN_CD,ITSERIAL,BOMID,BOMLEVEL INTO #WKOPITEM1 FROM #WKOPITEM

SELECT A.INV_NO,A.IT_NAME,A.IT_CODE,A.ORGQTY,A.ENTRY_TY,A.TRAN_CD,A.ITSERIAL,A.BOMID,A.BOMLEVEL
,C.RMQTY ,B.FGQTY,C.RMITEMID,C.RMITEM
,REQQTY=(A.ORGQTY*C.RMQTY)/B.FGQTY
,ISSUEDQTY=B.FGQTY,IPQTY=B.FGQTY
,D.TLISSPERM,TLISSPERMQ=B.FGQTY 
INTO  #WKOPITEM2
FROM #WKOPITEM1 A 
INNER JOIN BOMHEAD B ON (A.BOMID=B.BOMID AND A.BOMLEVEL=B.BOMLEVEL)
INNER JOIN BOMDET  C ON (C.BOMID=B.BOMID AND C.BOMLEVEL=B.BOMLEVEL)
Inner Join IT_MAST D ON (C.RMITEMID = D.IT_CODE) 
ORDER BY A.TRAN_CD
UPDATE #WKOPITEM2 SET ISSUEDQTY=0,IPQTY=0 ,TLISSPERMQ=(REQQTY*TLISSPERM)/100

SELECT A.BOMID,A.BOMLEVEL,A.IT_CODE,A.ITEM,qty=sum(A.QTY),B.AENTRY_TY,B.ATRAN_CD,B.AITSERIAL 
INTO #IBAL1 
FROM IPITEM A 
INNER JOIN PROJECTITREF B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL) 
group by A.BOMID,A.BOMLEVEL,A.IT_CODE,A.ITEM,B.AENTRY_TY,B.ATRAN_CD,B.AITSERIAL

UPDATE A SET ISSUEDQTY=QTY FROM #WKOPITEM2 A INNER JOIN #IBAL1 B ON (A.ENTRY_TY=B.AENTRY_TY AND A.TRAN_CD=B.ATRAN_CD AND A.ITSERIAL=B.AITSERIAL AND B.IT_CODE=A.RMITEMID)

update #WKOPITEM2 set ISSUEDQTY=ReqQty where  (reqqty-ISSUEDQTY)<=TLISSPERMQ

UPDATE #WKOPITEM2 SET IPQTY =(ORGQTY*ISSUEDQTY)/REQQTY



SELECT ENTRY_TY,TRAN_CD,ITSERIAL,IT_CODE,ORGQTY,IPQTY=round(max(IPQTY),0)
INTO #WKOPITEM3 FROM #WKOPITEM2 GROUP BY ENTRY_TY,TRAN_CD,ITSERIAL,IT_CODE,ORGQTY ORDER BY ENTRY_TY,TRAN_CD,ITSERIAL,IT_CODE


UPDATE A SET A.IPQTY=B.IPQTY
FROM #WKOPITEM A INNER JOIN #WKOPITEM3 B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL =B.ITSERIAL) --,IT_CODE

UPDATE A SET A.BALQTY=A.ORGQTY-A.IPQTY-A.trm_qty FROM #WKOPITEM A 

UPDATE #WKOPITEM  SET IPQTY=IPQTY-OPQTY

declare @fldlist varchar(4000),@fld_nm varchar(20),@sqlcommand nvarchar(4000)
set @fldlist=' '
declare cur_lth cursor for select fld_nm from lother where e_code='WK' and att_file=0 order by serial 
open cur_lth
fetch next from cur_lth into @fld_nm
while (@@fetch_status=0)
begin
	set @fldlist=rtrim(@fldlist)+',B.'+rtrim(@fld_nm)
	fetch next from cur_lth into @fld_nm
end
close cur_lth
deallocate cur_lth
print @fldlist
set @sqlcommand='select a.*'+@fldlist+',''Y''  as Expand,''Y'' as Expanded from #WKOPITEM a left join item b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd and a.itserial=b.itserial)'
print @sqlcommand
execute sp_executesql @sqlcommand
GO
