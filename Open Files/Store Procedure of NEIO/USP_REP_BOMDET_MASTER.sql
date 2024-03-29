DROP PROCEDURE [USP_REP_BOMDET_MASTER]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [USP_REP_BOMDET_MASTER]
@TBLCOND VARCHAR(2000)
AS
Declare @FCON as NVARCHAR(2000),@SQLCOMMAND as NVARCHAR(4000)

SELECT DISTINCT Bomid into #tmpInv FROM BOMHEAD WHERE 1=2
SET @SQLCOMMAND='INSERT INTO #tmpInv SELECT DISTINCT BOMID FROM BOMHEAD INNER JOIN IT_MAST ON (BOMHEAD.ITEMID=IT_MAST.IT_CODE) WHERE '+@TBLCOND
EXECUTE SP_EXECUTESQL @SQLCOMMAND

select bomhead.BomId,bomhead.Item,bomhead.fgqty,it_mast.rateper,it_mast.rateunit,it_desc=convert(varchar(200),it_mast.it_desc)
,bomdet.rmitem,bomdet.rmqty,bomdet.bomlevel,bomdet.isbom,bomdet.srno,bomdet.bomdetid,bomdet.particular
,it.rateper as rm_rateper,it.rateunit as rm_rateunit,rm_desc=convert(varchar(200),it.it_desc)
Into #tmpBom from bomhead inner join bomdet on (bomhead.bomid=bomdet.bomid and bomhead.bomlevel=bomdet.bomlevel) 
INNER JOIN #tmpInv ON (#tmpInv.BomId=bomhead.BomId)
Inner join it_mast on (it_mast.it_code=bomhead.itemid) 
Inner join it_mast it on (it.it_code=bomdet.rmitemid)  
Order by bomdet.Bomid,bomdet.bomlevel



/*Add Enternal Columns [Start]*/
ALTER TABLE #tmpBom Add [Level] INT,OrderLevel VARCHAR(100)
/*Add Enternal Columns [End]*/

/*Set Initilize Values of External Columns [Start]*/
UPDATE #tmpBom SET [Level] = 0,OrderLevel = ''
/*Set Initilize Values of External Columns [End]*/

Update #tmpBom SET [Level] = 1,OrderLevel = REPLICATE('0',3-LEN(LTrim(RTrim(STR(srno)))))+LTrim(RTrim(STR(srno))) where Bomlevel=0

declare @BomId Varchar(6), @BomLevel Numeric, @OrderLevel varchar(500),@Bomdetid Numeric
declare @BomId1 Varchar(6), @BomLevel1 Numeric, @OrderLevel1 varchar(500),@Bomdetid1 Numeric,@BomId2 Varchar(6)
Declare @iLevel Int ,@uLevelId Int,@RecCount Int,@BomdId2 varchar(6),@cnt int,@tmp varchar(6)

set @iLevel=1
set @cnt=1
Declare Outer_Cursor cursor for 
select distinct BomId from #tmpBom
Open Outer_Cursor
Fetch Next from Outer_Cursor Into @BomId2
while @@Fetch_status=0
Begin
	while @cnt>0
	Begin
		DECLARE Cur_BomId CURSOR FOR 
		SELECT distinct a.BomId,a.Bomdetid,a.Bomlevel,a.OrderLevel,a.[Level] FROM #tmpBom a
		where a.[Level]=@iLevel and a.Bomid=@BomId2 ORDER By a.Bomid,a.Bomlevel
		OPEN Cur_BomId
		FETCH NEXT FROM Cur_BomId INTO @BomId,@Bomdetid,@BomLevel,@OrderLevel,@iLevel
		set @BomdId2=@BomId
		WHILE @@FETCH_STATUS = 0
		BEGIN
				Declare cur_Bomdet cursor for
				Select a.BomId,a.Bomdetid,a.Bomlevel,a.OrderLevel FROM #tmpBom a
				where a.BomId=@BomId and a.BomLevel=@Bomdetid and a.[Level]=0 
				
				Open cur_Bomdet
				Fetch Next From cur_Bomdet Into @BomId1,@Bomdetid1,@BomLevel1,@OrderLevel1  
				WHILE @@FETCH_STATUS = 0
				BEGIN
					Update #tmpBom set [level]=@iLevel+1,
					OrderLevel=RTrim(@OrderLevel)+'/'+REPLICATE('0',3-LEN(LTrim(RTrim(STR(srno)))))+LTrim(RTrim(STR(srno)))
					Where BomId=@BomId  and BomLevel=@Bomdetid 
				
				Fetch Next From cur_Bomdet Into @BomId1,@Bomdetid1,@BomLevel1,@OrderLevel1  
				END
				CLOSE cur_Bomdet
				DEALLOCATE cur_Bomdet

			FETCH NEXT FROM Cur_BomId INTO @BomId,@Bomdetid,@BomLevel,@OrderLevel,@iLevel
		END
		CLOSE Cur_BomId
		DEALLOCATE Cur_BomId

		set @iLevel=@iLevel+1
		select @cnt=count(*) from #tmpBom where [level]=@iLevel
		set @cnt=isnull(@cnt,0)
	End
Fetch Next from Outer_Cursor Into @BomId2
End
CLOSE Outer_Cursor
DEALLOCATE Outer_Cursor		

select * from #tmpBom Order by BomId,OrderLevel
drop table #tmpBom
GO
