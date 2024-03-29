-- =============================================
-- Author:		Ruepesh Prajapati.
-- Create date: 16/05/2007
-- Description:	This Stored procedure is useful In IPOP For OP-->WK Allocation Entry.
-- Modification Date/By/Reason: 14/08/2009 Rupesh Prajapati. Modified for WIP QTY Calculation in #IBAL1 
---Modify By : Hetal L Patel
-- Remark: TKT-909 (Tolerance Check of Raw Material Issue)
---Modify By : Sandeep Shah
-- Remark: TKT-3069 The "Finished Material" Quantity in "Output to Production" is not showing as per the "Input to Production".
---Modify By : Birendra :for TKT-8638 on 22 July 2011
-- Remark: TKT-8638 (Auto Rate for Output from production as per Input to Production)
-- Modification Date/By/Reason: 17/11/2012 Satish Pal for Bug-3335 
-- Modification Date/By/Reason: 20/12/2012 Birendra for Bug-4426
-- Modification Date/By/Reason: By Kishor A. for Bug-28558 on 06-10-2016
-- =============================================
ALTER PROCEDURE [dbo].[USP_ENT_WkOp_ALLOCATION]
@ENTRY_TY VARCHAR(2),@TRAN_CD INT ,@SDATE SMALLDATETIME
,@proc_Id varchar(10) --Birendra Bug-4543 on 31/07/2012
,@Prodtype Varchar(25) 
AS
SELECT SEL=0,I.INV_NO,I.DATE,I.IT_CODE,IT.IT_NAME,ORGQTY=I.QTY,ALLQTY=I.QTY,QTY,BALQTY=QTY,ENTRY_TY,TRAN_CD,ITSERIAL,BOMID,BOMLEVEL,WIPQTY=I.QTY
,tlrecperp=isnull(it.tlrecperp,0),tlrecperm=isnull(it.tlrecperm,0),tlrecqtyp=I.QTY,tlrecqtym=I.QTY
,rate=0 --Birendra TKT-8638
,trm_qty--Added by satish for bug-3335
INTO #WKOPITEM
FROM ITEM I
INNER JOIN IT_MAST IT ON (I.IT_CODE=IT.IT_CODE)
where I.DATE< =@SDATE
and proc_id=@proc_id --Birendra : Bug-4543 on 07/08/2012

UPDATE #WKOPITEM SET ALLQTY=0,QTY=0,BALQTY=0,WIPQTY=0,tlrecqtyp=0,tlrecqtym=0
-->Calculate Allocated Quantity
--	select aentry_ty,atran_cd,aitserial,qty=sum(qty) into #PROJECTITREF from PROJECTITREF b  WHERE NOT (ENTRY_TY=@ENTRY_TY AND TRAN_CD=@TRAN_CD) AND ENTRY_TY='OP' group by aentry_ty,atran_cd,aitserial	
--Birendra : Bug-4543 on 07/08/2012:commented above one and modified below one:
	select aentry_ty,atran_cd,aitserial,qty=sum(qty) into #PROJECTITREF from PROJECTITREF b  WHERE NOT (ENTRY_TY=@ENTRY_TY AND TRAN_CD=@TRAN_CD) AND ENTRY_TY in('OP','WO') group by aentry_ty,atran_cd,aitserial	
--Birendra :Bug-4426(Auto transaction)sTART
	select aentry_ty,atran_cd,aitserial,qty=sum(qty) into #PROJECTITREF_ST from PROJECTITREF b  WHERE ENTRY_TY=@ENTRY_TY AND TRAN_CD=@TRAN_CD group by aentry_ty,atran_cd,aitserial	
--Birendra:END

	update a SET ALLQTY=b.qty from #WKOPITEM a inner join #PROJECTITREF b on (a.entry_ty=b.aentry_ty and a.tran_cd=b.atran_cd and a.itserial=b.aitserial)
	---update #WKOPITEM SET BALQTY=ORGQTY-ALLQTY--commented by satish pal for bug-3335
--Birendra :Bug-4426(Auto transaction)sTART
	update a SET ALLQTY=0 from #WKOPITEM a inner join #PROJECTITREF_ST b on (a.entry_ty=b.aentry_ty and a.tran_cd=b.atran_cd and a.itserial=b.aitserial )
--Birendra :End

	update #WKOPITEM SET BALQTY=ORGQTY-ALLQTY-trm_qty---added by satish pal for bug-3335
--<Calculate Allocated Quantity
SELECT INV_NO,IT_NAME,IT_CODE,ORGQTY,ENTRY_TY,TRAN_CD,ITSERIAL,BOMID,BOMLEVEL INTO #WKOPITEM1 FROM #WKOPITEM

SELECT A.INV_NO,A.IT_NAME,A.IT_CODE,A.ORGQTY,A.ENTRY_TY,A.TRAN_CD,A.ITSERIAL,A.BOMID,A.BOMLEVEL
,C.RMQTY ,B.FGQTY,C.RMITEMID,C.RMITEM
,REQQTY=(A.ORGQTY*C.RMQTY)/B.FGQTY
,ISSUEDQTY=B.FGQTY,WIPQTY=B.FGQTY
,D.TLISSPERM,TLISSPERMQ=B.FGQTY /*TKT-909*/
,rate=0 --Birendra TKT-8638
INTO  #WKOPITEM2
FROM #WKOPITEM1 A 
INNER JOIN BOMHEAD B ON (A.BOMID=B.BOMID AND A.BOMLEVEL=B.BOMLEVEL)
INNER JOIN BOMDET  C ON (C.BOMID=B.BOMID AND C.BOMLEVEL=B.BOMLEVEL)
Inner Join IT_MAST D ON (C.RMITEMID = D.IT_CODE) /*TKT-909*/
ORDER BY A.TRAN_CD

UPDATE #WKOPITEM2 SET ISSUEDQTY=0,WIPQTY=0			--Added by Shrikant S. on 20/12/2017 for Bug-30549
--UPDATE #WKOPITEM2 SET ISSUEDQTY=0,WIPQTY=0 TKT-909
--UPDATE #WKOPITEM2 SET ISSUEDQTY=0,WIPQTY=0 ,TLISSPERMQ=(REQQTY*TLISSPERM)/100  --Commented by Priyanka B on 31072017

--Commented by Shrikant S. on 04/11/2017 for GST		--Start
--SELECT A.BOMID,A.BOMLEVEL,A.IT_CODE,A.ITEM,qty=sum(A.QTY),B.AENTRY_TY,B.ATRAN_CD,B.AITSERIAL 
--,rate=sum(a.rate*a.qty)--Birendra TKT-8638
--INTO #IBAL1 
--FROM IPITEM A 
--INNER JOIN PROJECTITREF B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL) 
--where a.DATE <=@SDATE -- TKT Add by Sandeep Shah Dt.16/07/2010
--group by A.BOMID,A.BOMLEVEL,A.IT_CODE,A.ITEM,B.AENTRY_TY,B.ATRAN_CD,B.AITSERIAL--AENTRY_TY AND A.TRAN_CD=B.ATRAN_CD AND A.ITSERIAL=B.AITSERIAL AND B.IT_CODE=A.RMITEMID
--Commented by Shrikant S. on 04/11/2017 for GST		--End

--Added by Shrikant S. on 04/11/2017 for GST Bug-30549		--Start		
Declare @sqlcmd nvarchar(max)

SELECT A.BOMID,A.BOMLEVEL,A.IT_CODE,A.ITEM,qty=sum(A.QTY),B.AENTRY_TY,B.ATRAN_CD,B.AITSERIAL 
,rate=sum(a.rate*a.qty)
INTO #IBAL1 
FROM IPITEM A 
INNER JOIN PROJECTITREF B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL) 
where 1=2
group by A.BOMID,A.BOMLEVEL,A.IT_CODE,A.ITEM,B.AENTRY_TY,B.ATRAN_CD,B.AITSERIAL

set @sqlcmd='INSERT INTO #IBAL1 SELECT A.BOMID,A.BOMLEVEL,A.IT_CODE,A.ITEM,qty=sum(A.QTY),B.AENTRY_TY,B.ATRAN_CD,B.AITSERIAL '
set @sqlcmd=@sqlcmd+' ,rate=sum(a.rate*a.qty) '
set @sqlcmd=@sqlcmd+' FROM IPITEM A '
set @sqlcmd=@sqlcmd+' INNER JOIN PROJECTITREF B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL=B.ITSERIAL) '
set @sqlcmd=@sqlcmd+' INNER JOIN IPMAIN C ON (A.ENTRY_TY=C.ENTRY_TY AND A.TRAN_CD=C.TRAN_CD) '
set @sqlcmd=@sqlcmd+' where a.DATE <='''+Convert(varchar(50),@SDATE)+''' '
If @Prodtype ='ANNEXURE III' OR @Prodtype ='ANNEXURE V'
Begin
	set @sqlcmd=@sqlcmd+' and C.PRODTYPE ='''+@Prodtype+''' '
end
ELSE
Begin
	set @sqlcmd=@sqlcmd+' and C.PRODTYPE NOT IN (''ANNEXURE III'',''ANNEXURE V'')'
end

set @sqlcmd=@sqlcmd+' group by A.BOMID,A.BOMLEVEL,A.IT_CODE,A.ITEM,B.AENTRY_TY,B.ATRAN_CD,B.AITSERIAL'
execute sp_executesql @sqlcmd

--Added by Shrikant S. on 04/11/2017 for GST Bug-30549		--End



--UPDATE A SET ISSUEDQTY=QTY FROM #WKOPITEM2 A INNER JOIN #IBAL1 B ON (A.ENTRY_TY=B.AENTRY_TY AND A.TRAN_CD=B.ATRAN_CD AND A.ITSERIAL=B.AITSERIAL AND B.IT_CODE=A.RMITEMID)
--birendra TKT-8638
UPDATE A SET ISSUEDQTY=QTY,Rate=isnull(b.rate,0) FROM #WKOPITEM2 A INNER JOIN #IBAL1 B ON (A.ENTRY_TY=B.AENTRY_TY AND A.TRAN_CD=B.ATRAN_CD AND A.ITSERIAL=B.AITSERIAL AND B.IT_CODE=A.RMITEMID)

--TKT-909 Hetal L Patel Dt130410
	update #WKOPITEM2 set ISSUEDQTY=ReqQty where  (reqqty-ISSUEDQTY)<=TLISSPERMQ
--TKT-909 Hetal L Patel Dt130410


UPDATE #WKOPITEM2 SET WIPQTY =(ORGQTY*ISSUEDQTY)/REQQTY
UPDATE #WKOPITEM2 SET WIPQTY =(CAST(WIPQTY as Decimal(15,2))) --Added By Kishor A. for Bug-28558 on 06-10-2016


SELECT ENTRY_TY,TRAN_CD,ITSERIAL,IT_CODE,WIPQTY=MIN(WIPQTY) 
,rate=case when min(wipqty)<=0 then sum(isnull(rate,0)) else sum(isnull(rate,0))/min(wipqty) end--Birendra TKT-8638
INTO #WKOPITEM3 FROM #WKOPITEM2 GROUP BY ENTRY_TY,TRAN_CD,ITSERIAL,IT_CODE ORDER BY ENTRY_TY,TRAN_CD,ITSERIAL,IT_CODE

-->Calculate WIP Quantity
UPDATE A SET A.WIPQTY=B.WIPQTY-A.ALLQTY 
,a.rate=case when a.wipqty<=0 then isnull(b.rate,0) else isnull(b.rate,0)/(a.wipqty) end -- Birendra TKT-8638
FROM #WKOPITEM A INNER JOIN #WKOPITEM3 B ON (A.ENTRY_TY=B.ENTRY_TY AND A.TRAN_CD=B.TRAN_CD AND A.ITSERIAL =B.ITSERIAL) --,IT_CODE

--<Calculate WIP Quantity
--select 'b',* from #WKOPITEM
UPDATE #WKOPITEM SET tlrecqtyp=(orgqty*tlrecperp)/100,tlrecqtym=(orgqty*tlrecperm)/100

delete from #WKOPITEM where WIPQTY<=0
delete from #WKOPITEM where balqty-tlrecqtym<=0

declare @fldlist varchar(4000),@fld_nm varchar(20),@sqlcommand nvarchar(4000)
set @fldlist=' '
--declare cur_lth cursor for select fld_nm from lother where e_code='WK' and inter_use=0 order by serial &&commented by Shrikant S.
declare cur_lth cursor for select fld_nm from lother where e_code='WK' and att_file=0 order by serial -- Changed by shrikant S.
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
set @sqlcommand='select a.*'+@fldlist+' from #WKOPITEM a inner join item b on (a.entry_ty=b.entry_ty and a.tran_cd=b.tran_cd and a.itserial=b.itserial)'
print @sqlcommand
execute sp_executesql @sqlcommand

