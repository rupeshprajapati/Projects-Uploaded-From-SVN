If Exists(Select [name] From SysObjects Where xType='P' and [name]='CostCentrewise_Trial_Balance')
Begin
	Drop Procedure CostCentrewise_Trial_Balance
End
/****** Object:  StoredProcedure [dbo].[CostCentrewise_Trial_Balance]    Script Date: 4/27/2018 3:54:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Prajakta B. 
-- Create date: 11/01/2018 
-- Description:	Created for CostCentrewise Trial Balance Dynamic Report
-- =============================================

Create PROCEDURE [dbo].[CostCentrewise_Trial_Balance]
@FrmDate SMALLDATETIME,@Todate SMALLDATETIME,
@FcostCen AS VARCHAR(60),@TcostCen AS VARCHAR(60)
As

If @FrmDate IS NULL OR @Todate IS NULL
Begin
	RAISERROR ('Please pass valid parameters..',16,1)
	Return 
End

if @FcostCen IS NULL OR @TcostCen IS NULL
Begin
	RAISERROR ('Please pass valid parameters..',16,1)
	Return
End

if exists(select [name]  from sys.tables where [name] = 'outputtbl') 
begin
	drop table outputtbl
end

Declare @Balance Numeric(17,2),@TBLNM VARCHAR(50),@TBLNAME1 Varchar(50),
		@TBLNAME2 Varchar(50),@TBLNAME3 Varchar(50),@TBLNAME4 Varchar(50),
		@SQLCOMMAND as NVARCHAR(MAX),@TIME SMALLDATETIME, @newTdate SMALLDATETIME,
		@nFdate VARCHAR(50),@nTdate VARCHAR(50),
		@cols AS NVARCHAR(MAX),@SQLCOMMAND1 as NVARCHAR(MAX)

Select @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 10000)
				+ (DATEPART(ss, GETDATE()) * 1000 )+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No),
	   @Balance = 0,@SQLCOMMAND = ''

Select @TBLNAME1 = '##TMP1_'+@TBLNM,@TBLNAME2 = '##TMP2_'+@TBLNM
Select @TBLNAME3 = '##TMP3_'+@TBLNM,@TBLNAME4 = '##TMP4_'+@TBLNM

SET @SQLCOMMAND =  'SELECT AVW.TRAN_CD,AVW.ENTRY_TY,AVW.DATE,mCall.AMOUNT,AVW.AMT_TY,MVW.INV_NO,AVW.AC_ID,AC_MAST.[TYPE],AVW.AC_NAME,AVW.ACSERIAL, mCall.cost_cen_name as INV_Sr
					INTO '+@TBLNAME1+' 
					FROM LAC_VW AVW (NOLOCK)
					INNER JOIN AC_MAST (NOLOCK) ON AVW.AC_ID = AC_MAST.AC_ID
					INNER JOIN LMAIN_VW MVW (NOLOCK) ON AVW.TRAN_CD = MVW.TRAN_CD AND AVW.ENTRY_TY = MVW.ENTRY_TY
					inner join MainCall_vw mCall on (MVW.tran_cd=mCall.tran_cd AND MVW.ENTRY_TY=mCall.ENTRY_TY and AVW.ac_id=mCall.ac_id ) 
					WHERE (MVW.DATE < = '''+cast(@Todate as varchar)+''' )  '
					
EXECUTE sp_executesql @SQLCOMMAND

SET @SQLCOMMAND = 'DELETE FROM '+@TBLNAME1+' WHERE AC_NAME = ''CLOSING STOCK'' AND [DATE] < '''+CONVERT(VARCHAR(50),@FrmDate)+'''' 

EXECUTE sp_executesql @SQLCOMMAND 

SET @SQLCOMMAND = 'UPDATE '+@TBLNAME1+' SET AC_NAME = ''OPENING STOCK'', AC_ID=(SELECT AC_ID FROM AC_MAST WHERE AC_NAME = ''OPENING STOCK'') WHERE AC_NAME = ''CLOSING STOCK'' AND [DATE] < '''+CONVERT(VARCHAR(50),@FrmDate)+''' '

EXECUTE sp_executesql @SQLCOMMAND

SET @SQLCOMMAND = 'DELETE FROM '+@TBLNAME1+' WHERE CONVERT(VARCHAR(20),TRAN_CD)+''-''+ENTRY_TY IN 
				  (SELECT CONVERT(VARCHAR(20),TRAN_CD)+''-''+ENTRY_TY AS COMEID FROM '+@TBLNAME1+' 
				  WHERE [TYPE] IN (''T'',''P'') AND [DATE] NOT BETWEEN '''+CONVERT(VARCHAR(50),@FrmDate)+''' AND '''+CONVERT(VARCHAR(50),@Todate)+''') AND [TYPE] IN (''T'',''P'') '

EXECUTE sp_executesql @SQLCOMMAND

SET @SQLCOMMAND = 'DECLARE @OPTRAN_CD as INT,@OPDATE as DATETIME,@OPACNAME as varchar(250) DECLARE openingentry_cursor CURSOR FOR
	SELECT TRAN_CD,AC_NAME,DATE FROM '+@TBLNAME1+' WHERE 
	ENTRY_TY IN (''OB'') 
	OPEN openingentry_cursor
	FETCH NEXT FROM openingentry_cursor into @OPTRAN_CD,@OPACNAME,@OPDATE
	WHILE @@FETCH_STATUS = 0
	BEGIN
	   DELETE FROM '+@TBLNAME1+' WHERE DATE < @OPDATE		--Changes done by vasant on 05/05/2012 as per Bug 3450 (Balance sheet report Problem).
			AND AC_NAME IN (SELECT AC_NAME FROM '+@TBLNAME1+' WHERE AC_NAME = @OPACNAME AND ENTRY_TY IN (''OB'') AND TRAN_CD = @OPTRAN_CD )		--Changes done by vasant on 05/05/2012 as per Bug 3450 (Balance sheet report Problem).
	   FETCH NEXT FROM openingentry_cursor into @OPTRAN_CD,@OPACNAME,@OPDATE
	END
CLOSE openingentry_cursor
DEALLOCATE openingentry_cursor'

EXECUTE SP_EXECUTESQL @SQLCOMMAND

SET @SQLCOMMAND = 'IF EXISTS(SELECT TOP 1 A.DATE FROM LITEM_VW A,LCODE B,LMAIN_VW C 
							 WHERE A.ENTRY_TY = B.ENTRY_TY AND A.ENTRY_TY = C.ENTRY_TY AND A.TRAN_CD = C.TRAN_CD 
							 AND A.DATE < '''+CONVERT(VARCHAR(50),@FrmDate)+''' AND B.INV_STK<>'' '' AND A.DC_NO='''' 
							 AND C.[RULE] NOT IN (''EXCISE'',''NON-EXCISE'')
							) '		
  
SET @SQLCOMMAND = @SQLCOMMAND + ' DELETE FROM '+@TBLNAME1+' 
								WHERE ENTRY_TY IN (SELECT (CASE WHEN EXT_VOU=1 THEN BCODE_NM ELSE ENTRY_TY END) AS BHENT 
													FROM LCODE 
													WHERE ENTRY_TY = ''OS'' OR BCODE_NM = ''OS''
												   ) '

EXECUTE sp_executesql @SQLCOMMAND

SET @SQLCOMMAND = 'Update '+@TBLNAME1+' Set Amount = 0 Where AC_NAME in (''OPENING BALANCES'')'		

EXECUTE sp_executesql @SQLCOMMAND

SET @SQLCOMMAND = 'SELECT TVW.TRAN_CD,TVW.ENTRY_TY,DATE = '''+CONVERT(VARCHAR(50),@FrmDate)+''',
					AMOUNT=ISNULL(SUM(CASE WHEN TVW.AMT_TY = ''DR'' THEN TVW.AMOUNT ELSE -TVW.AMOUNT END),0),
					TVW.AC_ID,TVW.AC_NAME,TVW.ACSERIAL,AMT_TY=''A''--,INV_NO='''',INV_SR=''''
					,TVW.INV_NO, TVW.INV_SR 
					INTO '+@TBLNAME2+' FROM '+@TBLNAME1+' TVW
					WHERE (TVW.DATE < '''+CONVERT(VARCHAR(50),@FrmDate)+''' 
					OR TVW.ENTRY_TY IN (Select Entry_Ty From LCode	
										Where bCode_Nm = ''OB'' OR Entry_Ty = ''OB'' OR bCode_Nm = ''OS'' OR Entry_Ty = ''OS'')
						   )
					GROUP BY TVW.AC_ID,TVW.AC_NAME,TVW.ACSERIAL,TVW.INV_NO, TVW.INV_SR, TVW.TRAN_CD,TVW.ENTRY_TY
				UNION
					SELECT TVW.TRAN_CD,TVW.ENTRY_TY,TVW.DATE,AMOUNT=(CASE WHEN TVW.AMT_TY=''DR'' THEN TVW.AMOUNT ELSE -TVW.AMOUNT END),
					TVW.AC_ID,TVW.AC_NAME,TVW.ACSERIAL,TVW.AMT_TY,TVW.INV_NO, TVW.INV_SR
					FROM '+@TBLNAME1+' TVW
					LEFT JOIN LAC_VW LVW (NOLOCK) ON (TVW.TRAN_CD = LVW.TRAN_CD AND TVW.ENTRY_TY = LVW.ENTRY_TY AND TVW.AC_ID <> LVW.AC_ID)
					WHERE ((TVW.DATE BETWEEN '''+CONVERT(VARCHAR(50),@FrmDate)+''' AND '''+CONVERT(VARCHAR(50),@Todate)+''') 
					AND TVW.ENTRY_TY NOT IN (Select Entry_Ty From LCode 
											 Where bCode_Nm = ''OB'' OR Entry_Ty = ''OB'' OR bCode_Nm = ''OS'' OR Entry_Ty = ''OS'')
						   )'

EXECUTE sp_executesql @SQLCOMMAND

declare @trflg Varchar(1), @se vARCHAR(100), @mth int
Set @mth = 1

while @mth > 0

Begin
	SET @SQLCOMMAND = 'SELECT a.Ac_id, a.INV_SR,
		Opening = CASE WHEN Amt_Ty =''A'' THEN SUM(a.Amount)END,
		Debit = CASE WHEN Amt_Ty =''DR'' THEN SUM(a.Amount)END,
		Credit = CASE WHEN Amt_Ty =''CR'' THEN SUM(a.Amount) END
		Into '+@TBLNAME3+' from '+@TBLNAME2+' a
		group by a.Ac_id,a.amt_ty, a.INV_SR'
	EXECUTE sp_executesql @SQLCOMMAND

	SET @SQLCOMMAND = 'SELECT a.INV_SR, b.Ac_id, Sum(a.Opening) as OpBal, Sum(a.Debit) as Debit,
		Sum(a.Credit) as Credit,CAST(0 AS Numeric(17,2)) As ClBal
		Into '+@TBLNAME4+' from '+@TBLNAME3+' a Right Join Ac_Mast b 
		ON (b.Ac_id = a.Ac_id) group by a.INV_SR, b.Ac_id'
	EXECUTE sp_executesql @SQLCOMMAND

	SET @SQLCOMMAND = 'Update '+@TBLNAME4+' SET OPbal = (CASE WHEN OpBal IS NULL THEN 0 ELSE OPBAL END),
		Debit = (CASE WHEN Debit IS NULL THEN 0 ELSE Debit END),
		Credit = (CASE WHEN Credit IS NULL THEN 0 ELSE Credit END),
		Clbal = (CASE WHEN Clbal IS NULL THEN 0 ELSE Clbal END)'
	EXECUTE sp_executesql @SQLCOMMAND
	
	Select AC_GROUP_NAME+space(100) as Ac_Name, Space(150) as mGroup, Space(1) as MainFlg, Space(1) as Expanded, 
	CAST(0 AS Numeric(5)) As level, CAST(0 AS Numeric(17,2)) As OpBal,CAST(0 AS Numeric(17,2)) As Debit,
	CAST(0 AS Numeric(17,2)) As Credit, CAST(0 AS Numeric(17,2)) As DrBal, 
	CAST(0 AS Numeric(17,2)) As ClBal, Ac_group_id As Mid, Space(150) as Maing,
	SPACE(25) as INV_SR, CAST(0 AS Numeric(5)) As mCnt, CAST(0 AS Int) As mLevel, CAST(0 AS Int) As IDs, SPACE(1500) As ParentIDs, 
	CAST(0 AS Numeric(15,2)) As CrBal, SPACE(75) As Parentname, SPACE(1) as FlgDel
	INTO #tmpAC
	From Ac_Group_Mast
	
	IF OBJECT_ID('tempdb..#Fintbl') IS NOT NULL
	BEGIN
		PRINT 'Table Exists'
	END
	Else
	BEGIN

		SELECT space(100) AS mDt,CAST(0 AS Numeric(5)) As mTh, space(30) as HFM_Code, Ac_Name, mGroup, MainFlg, Expanded, level, 
		OpBal,Debit,Credit, DrBal, ClBal, CAST(0 AS Numeric(5)) As Mid, Maing, INV_SR, mCnt, mLevel, IDs, ParentIDs, CrBal, Parentname,
		CAST(0 AS decimal(18,2)) As Fnclbal, FlgDel, 99999 as updown
		INTO #Fintbl
		From #TmpAC where 1 = 2
	END
	Select * into #tmp2 From #tmpAC where 1 = 2
	
	Declare @Ac_name as nVarchar(150), @mid as int, @Inv_Sr as nVarchar(50)
	
	IF OBJECT_ID (N'fintbl1', N'U') IS NOT NULL
	begin
		Drop table fintbl1
	end
	
	DECLARE @Cnt1 int
	Set @Cnt1 = (Select MAX(ac_group_id) From AC_GROUP_MAST)
	Set @Cnt1 = @Cnt1 + 2	
	
	SET @SQLCOMMAND = 'Select * into fintbl1 From (
		Select b.ac_id as Ids, ac_Group_id as ParentIDs, b.Ac_Name+space(100) as Ac_Name,b.[Group] mGroup, Space(1) as MainFlg, ''N'' as Expanded, 99 as level,
		a.OpBal, ABS(a.Debit) as Debit, ABS(a.Credit) as Credit,
		Case when a.OpBal+a.Debit-ABS(a.Credit) > 0 then a.OpBal+a.Debit-ABS(a.Credit) else 0 end as DrBal,
		Case when a.OpBal+a.Debit-ABS(a.Credit) < 0 then abs(a.OpBal+a.Debit-ABS(a.Credit)) else 0 end as CrBal,
		' +CAST(@Cnt1 AS VARCHAR(1000))+ '+ b.ac_id as mCnt, Space(150) as Maing, a.INV_SR
		From '+@TBLNAME4+'  a
		Inner Join Ac_Mast b ON (b.Ac_id = a.Ac_id)
		where (ABS(a.Credit) > 0 OR ABS(a.Debit) > 0 OR ABS(a.OpBal)>0)
	    ) A Order By  a.inv_sr, A.Maing, A.mCnt, A.Level, A.mGroup, A.Ac_Name'

	EXECUTE sp_executesql @SQLCOMMAND
	Delete From #tmpAC
	
	DECLARE Ac_CURSOR CURSOR FOR
	Select distinct inv_sr From fintbl1 A order by inv_sr

	OPEN  Ac_CURSOR
	FETCH NEXT FROM Ac_CURSOR INTO @Inv_Sr
	WHILE @@FETCH_STATUS = 0
	Begin
		Select *, ID = A.IDs, CAST(0 AS Int) As ParentID into #tp
		From
		(
			Select A.Ac_Name+space(100) as Ac_Name, a.mGroup, 'G' as MainFlg, 'N' as Expanded,
			Sum(a.OpBal) as OpBal, Sum(a.Debit) as Debit, Sum(ABS(a.Credit)) as Credit,
			Sum(Case when a.OpBal+a.Debit-ABS(a.Credit) > 0 then a.OpBal+a.Debit-ABS(a.Credit) else 0 end) as DrBal,
			Sum(Case when a.OpBal+a.Debit-ABS(a.Credit) < 0 then abs(a.OpBal+a.Debit-ABS(a.Credit)) else 0 end) as CrBal,
			a.mcnt, A.Maing, a.INV_SR, a.IDs, 'N' as FlgDel
			From fintbl1 a
			Where A.Inv_Sr = @Inv_Sr
			Group by A.Ac_Name, a.mGroup, a.mcnt, A.maing, a.INV_SR, a.Maing, a.IDs
			Union all
			Select AC_GROUP_NAME+space(100) as Ac_Name, [Group] as mGroup, Space(1) as MainFlg, Space(1) as Expanded,
			CAST(0 AS Numeric(17,2)) As OpBal,CAST(0 AS Numeric(17,2)) As Debit,
			CAST(0 AS Numeric(17,2)) As Credit, CAST(0 AS Numeric(17,2)) As DrBal,
			CAST(0 AS Numeric(17,2)) As CrBal, Ac_group_id As mCnt, Space(150) as Maing, @inv_sr as INV_SR, Ac_group_id, '' as FlgDel
			From Ac_Group_Mast
		) A
		order by inv_sr, maing
		
		Update #tp Set ParentID = A.Mcnt
		From (Select Mcnt, ac_name From #tp) A
		Where A.ac_name = #tp.mGroup
		
		Begin
			WITH FamilyTree (Ids, Parent, ParentIDs, mPad, OpBal, Debit, Credit, DrBal, CrBal, mcnt, INV_SR, mlevel, FlgDel)
			AS
			(
				SELECT ID, CAST(ac_name AS VARCHAR(1000)),CAST(mCnt AS VARCHAR(1000)), REPLICATE('0', 3-LEN(mCnt)),
				OpBal, Debit, Credit, DrBal, CrBal, mcnt, INV_SR, 1, FlgDel
				FROM #tp
				WHERE ParentID = 0
				
				UNION ALL
				
				SELECT ID, CAST(ac_name AS VARCHAR(1000)), 
				CAST(ParentIDs+','+ CAST(Fam.mCnt AS VARCHAR(5)) AS VARCHAR(1000)), REPLICATE('0', 5-LEN(Fam.mCnt)) mPad,
				Fam.OpBal, Fam.Debit, Fam.Credit, Fam.DrBal, Fam.CrBal, Fam.mcnt, Fam.INV_SR, mlevel + 1, Fam.FlgDel
				FROM #tp Fam
				INNER JOIN FamilyTree
				ON Fam.ParentID = FamilyTree.mCnt
			)
			
			Insert into #tmpac (Ids, ac_name, ParentIDs , OpBal, Debit, Credit, DrBal, CrBal, mcnt, INV_SR, mLevel, FlgDel)
			SELECT Ids, case when mlevel <> 1 then Space(Len(mPad) + Len(ParentIDs))+Parent Else Parent end as Ac_name
			,ParentIDs, OpBal, Debit, Credit, DrBal, CrBal, mcnt, INV_SR, mLevel, FlgDel
			FROM FamilyTree
			OPTION (MAXRECURSION 0)

		End

		Drop table #tp
		
		FETCH NEXT FROM Ac_CURSOR INTO @Inv_Sr
	END
	CLOSE Ac_CURSOR
	DEALLOCATE Ac_CURSOR
	
	Set @nFdate = Convert(varchar(2),Day(@FrmDate))+'/' + Convert(varchar(2),month(@FrmDate))+'/' + Convert(varchar(4),year(@FrmDate))--- added by sharad 22th Mar 2017
	Set @nTdate = Convert(varchar(2),Day(@Todate))+'/' + Convert(varchar(2),month(@Todate))+'/' + Convert(varchar(4),year(@Todate))--- added by sharad 22th Mar 2017
	
	Insert into #Fintbl (mDt, mTh,  Ac_Name, mGroup, MainFlg, Expanded, level, OpBal,Debit,Credit, DrBal, ClBal,
	Mid, Maing, INV_SR, mCnt,  mLevel, IDs, ParentIDs, CrBal, Parentname,Fnclbal,FlgDel, Updown)

	SELECT 'date'+convert(varchar(1),@mth) , @mth, t.Ac_Name, t.mGroup, t.MainFlg, t.Expanded, t.level,
	t.OpBal,t.Debit,t.Credit,t.DrBal,t.ClBal,t.Mid,t.Maing,t.INV_SR,t.mCnt,t.mLevel,t.IDs,t.ParentIDs,t.CrBal,t.Parentname
	,isnull(t.DrBal,0)+isnull(t.CrBal,0), FlgDel, 99999 as Updown
	From #tmpac t
	LEFT JOIN AC_MAST ON LTRIM(T.AC_NAME)=AC_MAST.AC_NAME
	order by INV_SR, ParentIDs
	
	Update #Fintbl set updown = a.Updown
	From AC_GROUP_MAST a where #Fintbl.IDs = ac_group_id
	and a.[group] = ''
	and #Fintbl.updown = 99999
	
	Update #Fintbl set updown = a.Updown
	From AC_GROUP_MAST a 
	where LTRIM(#Fintbl.ParentIDs) like convert(varchar(10), ac_group_id) + ',%' and a.[group] = ''

	Set @newTdate = Convert(SMALLDATETIME, Convert(varchar(2),Month(@Todate))+'/01/' + Convert(varchar(4),year(@Todate)))
	
	SET @SQLCOMMAND = 'Delete from '+@TBLNAME2+
	' WHERE DATE BETWEEN '''+CONVERT(VARCHAR(50),@newTdate)+''' AND '''+CONVERT(VARCHAR(50),@Todate)+''''

	EXECUTE sp_executesql @SQLCOMMAND
	
	Set @Todate = @newTdate - 1
	
	SET @SQLCOMMAND = 'Drop table ' +@TBLNAME3
	EXECUTE sp_executesql @SQLCOMMAND
	
	SET @SQLCOMMAND = 'Drop table ' +@TBLNAME4
	EXECUTE sp_executesql @SQLCOMMAND
	
	Drop table #tmp2

	Select distinct a.*, SUBSTRING(a.ParentIds, 1, Len(rtrim(a.ParentIds)) - len(a.mCnt)-1) as subId   ---- add distinct 
	, case when mLevel > 1 then SUBSTRING(a.ParentIds, 1, charindex(',', a.ParentIds,1)-1) else a.ParentIds end as mainId
	into #CalVal
	From #fintbl a, fintbl1 b
	where a.ids = b.ids
	and A.fnclbal <> 0
	and a.mtH = @mtH 

	--print @mtH
	
	Set @trflg = 'T'
	while @trflg = 'T'
	Begin
		Set @se = (Select top 1 subId from #CalVal where subId like '%,%')
		
		if @se <> ''
		Begin
			Update #Fintbl set FlgDel = 'N'
			from #CalVal a 
			where #Fintbl.ParentIDs = a.subId
			
			Update #CalVal set subId = REPLACE(#CalVal.subId, ','+convert(varchar(100), a.mcnt), '')
			From #Fintbl a
			where #CalVal.subId = a.ParentIDs 
		End
		Else
		Begin
			Set @trflg = 'F'
		End
	End

	Update #fintbl Set fnclbal = a.fnclbal, FlgDel = 'N'
	From(
		Select sum(fnclbal) as fnclbal, subId,INV_SR From #CalVal Group by subId,INV_SR
		) A
	Where #fintbl.ParentIDs = a.subId and #fintbl.inv_sr = a.inv_sr and #fintbl.mtH = @mtH

	Set @mth = @mth-1

	Drop table #CalVal
	drop table #tmpac
End 

DELETE FROM #Fintbl WHERE FlgDel <> 'N'

Insert into #Fintbl(Ac_Name, OpBal,	Debit,	Credit,	DrBal,	CrBal,updown,inv_sr,mtH) 
Values ('Total',0.00,0.00,0.00,0.00,0.00,1000,@FcostCen,1)

--UPDATE #Fintbl SET OpBal= A.OPBAL,Debit=A.Debit,Credit=A.Credit,DrBal=A.DrBal,CrBal=A.CrBal
--FROM ( 
--		SELECT OpBal AS OpBal,Debit AS Debit,Credit AS Credit,DrBal AS DrBal,CrBal AS CrBal,INV_SR  
--		FROM #Fintbl group by INV_SR,OpBal,Debit,Credit,DrBal,CrBal
--	  )A WHERE #Fintbl.inv_sr=a.inv_sr and #Fintbl.AC_NAME='Total'

set @SQLCOMMAND = 'create table outputtbl(ac_name varchar(250),MTH VARCHAR(15),UPDOWN INT,PARENTIDS VARCHAR(250)'

select distinct cost_cen_name into #a from cost_cen_mast
where cost_cen_name between ''+@FcostCen+'' and ''+@TcostCen+''  -- added by Prajakta B on 05012018 for Bug 30928

print 1

declare @inv_sr1 varchar(50)
declare tempcursor1 cursor for
select cost_cen_name from #a
open tempcursor1
fetch next from tempcursor1 into @inv_sr1
while @@FETCH_STATUS = 0
begin

	set @sqlcommand = @sqlcommand+','+replace(rtrim(@inv_sr1),' ','_')+'_opbal numeric(15,4),'
	set @sqlcommand = @sqlcommand+replace(rtrim(@inv_sr1),' ','_')+'_debit numeric(15,4),'
	set @sqlcommand = @sqlcommand+replace(rtrim(@inv_sr1),' ','_')+'_credit numeric(15,4),'
	set @sqlcommand = @sqlcommand+replace(rtrim(@inv_sr1),' ','_')+'_drbal numeric(15,4),'
	set @sqlcommand = @sqlcommand+replace(rtrim(@inv_sr1),' ','_')+'_crbal numeric(15,4)'

fetch next from tempcursor1 into @inv_sr1
end
close tempcursor1
deallocate tempcursor1
set @sqlcommand = @sqlcommand+')'

EXECUTE sp_executesql @SQLCOMMAND

select distinct a.inv_sr into #b from  (select distinct cost_cen_name as inv_sr from cost_cen_mast 
										where cost_cen_name between ''+@FcostCen+'' and ''+@TcostCen+'') a  -- added by Prajakta B on 05012018 for Bug 30928

;with #b
as
(
	select a.cost_cen_name,a.costunder
		from cost_cen_mast a
			where cost_cen_name Between ''+@FcostCen+'' and ''+@TcostCen+''
	union all
	select a.cost_cen_name,a.costunder
		from cost_cen_mast a
			inner join #b b on (a.cost_cen_name=b.costunder)
)select cost_cen_name as Inv_sr
into #b11 from #b group by cost_cen_name

;with #c
as
(
	select a.cost_cen_name,a.costunder
		from cost_cen_mast a
			inner join #b11 b on a.cost_cen_name=b.Inv_sr
	union all
	select a.cost_cen_name,a.costunder
		from cost_cen_mast a
			inner join #c b on (b.cost_cen_name=a.costunder)
)
select cost_cen_name as Inv_sr
into #b12 from #c group by cost_cen_name


select * into #b13 from #b11 
union
select * from #b12 order by Inv_sr

;with #b
as
(
		select a.cost_cen_name,a.costunder,b.opbal,b.debit,b.credit,b.drbal,b.crbal,b.Ac_Name
			from cost_cen_mast a
			inner join #fintbl b on(b.inv_sr=a.cost_cen_name)
			inner join #b13 c on a.cost_cen_name = c.inv_sr
	union all
		select a.cost_cen_name,a.costunder,b.opbal,b.debit,b.credit,b.drbal,b.crbal,b.Ac_Name
			from cost_cen_mast a
			inner join #b b on (a.cost_cen_name=b.costunder)
)
select cost_cen_name as Inv_sr,sum(opbal) as opbal,sum(debit) as debit,sum(credit)  as credit,sum(drbal) as drbal,sum(crbal) as crbal,ac_name 
	into #b15 from #b group by cost_cen_name,Ac_Name order by Inv_sr,ac_name

---------------------------------added by Prajakta B. on 11012018 end

select distinct ac_name into #c from #Fintbl

insert into outputtbl(ac_name)select DISTINCT ac_name from #Fintbl

UPDATE OUTPUTTBL SET OUTPUTTBL.MTH = #Fintbl.MTH,
					 OUTPUTTBL.PARENTIDS = #Fintbl.PARENTIDS,
			         OUTPUTTBL.UPDOWN = #FINTBL.UPDOWN
FROM OUTPUTTBL 
JOIN #FINTBL ON OUTPUTTBL.AC_NAME = #FINTBL.AC_NAME

print 2

declare tempcursor2 cursor for
select inv_sr from #b where inv_sr is not null
open tempcursor2
fetch next from tempcursor2 into @inv_sr1
while @@FETCH_STATUS = 0
begin

	declare tempcursor4 cursor for 
	select ac_name from #c where ac_name is not null
	open tempcursor4
	fetch next from tempcursor4 into @ac_name
	while @@FETCH_STATUS=0
	begin
		
	--print @inv_sr1
	--print @ac_name
	print 3
	set @sqlcommand  = 'update outputtbl set '+replace(ltrim(rtrim(@inv_sr1)),' ','_')+'_opbal=( select opbal from #b15 where ltrim(rtrim(ac_name)) ='''+ltrim(rtrim(@Ac_name))+''' and inv_sr = '''+ltrim(rtrim(@inv_sr1))+''' ) where ltrim(rtrim(ac_name))='''+ltrim(rtrim(@Ac_name))+''''
	 print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
	 
	set @sqlcommand  = 'update outputtbl set '+replace(ltrim(rtrim(@inv_sr1)),' ','_')+'_debit=( select debit from #b15 where ltrim(rtrim(ac_name)) ='''+ltrim(rtrim(@Ac_name))+''' and inv_sr = '''+ltrim(rtrim(@inv_sr1))+''') where ltrim(rtrim(ac_name))='''+ltrim(rtrim(@Ac_name))+''''
	-- print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
	 
	set @sqlcommand  = 'update outputtbl set '+replace(ltrim(rtrim(@inv_sr1)),' ','_')+'_credit=( select credit from #b15 where ltrim(rtrim(ac_name)) ='''+ltrim(rtrim(@Ac_name))+''' and inv_sr = '''+ltrim(rtrim(@inv_sr1))+''') where ltrim(rtrim(ac_name))='''+ltrim(rtrim(@Ac_name))+''''
	-- print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
	 
	set @sqlcommand  = 'update outputtbl set '+replace(ltrim(rtrim(@inv_sr1)),' ','_')+'_drbal=( select drbal from #b15 where ltrim(rtrim(ac_name)) ='''+ltrim(rtrim(@Ac_name))+''' and inv_sr = '''+ltrim(rtrim(@inv_sr1))+''') where ltrim(rtrim(ac_name))='''+ltrim(rtrim(@Ac_name))+''''
	-- print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
	 
	set @sqlcommand  = 'update outputtbl set '+replace(ltrim(rtrim(@inv_sr1)),' ','_')+'_crbal=(select crbal from #b15 where ltrim(rtrim(ac_name)) ='''+ltrim(rtrim(@Ac_name))+''' and inv_sr = '''+ltrim(rtrim(@inv_sr1))+''') where ltrim(rtrim(ac_name))='''+ltrim(rtrim(@Ac_name))+''''
	-- print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND

	fetch next from tempcursor4 into @ac_name
	end
	close tempcursor4
	deallocate tempcursor4

fetch next from tempcursor2 into @inv_sr1
end
close tempcursor2
deallocate tempcursor2

print @sqlcommand

declare tempcursor1 cursor for
select cost_cen_name from #a
open tempcursor1
fetch next from tempcursor1 into @inv_sr1
while @@FETCH_STATUS = 0
begin
	--print @inv_sr1

	set @sqlcommand = 'update outputtbl set '+replace(rtrim(@inv_sr1),' ','_')+'_opbal = 0.00 where '+replace(rtrim(@inv_sr1),' ','_')+'_opbal is null'
	--print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
	 
	set @sqlcommand = 'update outputtbl set '+replace(rtrim(@inv_sr1),' ','_')+'_debit = 0.00 where '+replace(rtrim(@inv_sr1),' ','_')+'_debit is null'
	--print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
	 
	set @sqlcommand = 'update outputtbl set '+replace(rtrim(@inv_sr1),' ','_')+'_credit = 0.00 where '+replace(rtrim(@inv_sr1),' ','_')+'_credit is null'
	--print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
	 
	set @sqlcommand = 'update outputtbl set '+replace(rtrim(@inv_sr1),' ','_')+'_drbal = 0.00 where '+replace(rtrim(@inv_sr1),' ','_')+'_drbal is null'
	--print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
	 
	set @sqlcommand = 'update outputtbl set '+replace(rtrim(@inv_sr1),' ','_')+'_crbal = 0.00 where '+replace(rtrim(@inv_sr1),' ','_')+'_crbal is null'
	--print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
	 
	  --total column calculation start
	 set @sqlcommand = 'UPDATE outputtbl SET '+replace(rtrim(@inv_sr1),' ','_')+'_OpBal=a.OpBal,'+replace(rtrim(@inv_sr1),' ','_')+'_debit = a.Debit,
											 '+replace(rtrim(@inv_sr1),' ','_')+'_credit = a.Credit,'+replace(rtrim(@inv_sr1),' ','_')+'_drbal = a.DrBal,
											 '+replace(rtrim(@inv_sr1),' ','_')+'_crbal = a.CrBal
						FROM ( SELECT sum('+replace(rtrim(@inv_sr1),' ','_')+'_OpBal) AS OpBal,
									  SUM('+replace(rtrim(@inv_sr1),' ','_')+'_debit) AS Debit,
						              SUM('+replace(rtrim(@inv_sr1),' ','_')+'_credit) AS Credit,
						              SUM('+replace(rtrim(@inv_sr1),' ','_')+'_drbal) AS DrBal,
						              SUM('+replace(rtrim(@inv_sr1),' ','_')+'_crbal) AS CrBal
								FROM outputtbl 
							 )A WHERE outputtbl.AC_NAME=''Total'''

	--print @sqlcommand
	 EXECUTE sp_executesql @SQLCOMMAND
 
fetch next from tempcursor1 into @inv_sr1
end
close tempcursor1
deallocate tempcursor1

set @SQLCOMMAND = 'SELECT AC_NAME '

declare tempcursor1 cursor for
select cost_cen_name from #a
where cost_cen_name <>'Primary'
open tempcursor1
fetch next from tempcursor1 into @inv_sr1
while @@FETCH_STATUS = 0
begin
	--print @inv_sr1

	set @sqlcommand = @sqlcommand+','+replace(rtrim(@inv_sr1),' ','_')+'_opbal ,'
	set @sqlcommand = @sqlcommand+replace(rtrim(@inv_sr1),' ','_')+'_debit,'
	set @sqlcommand = @sqlcommand+replace(rtrim(@inv_sr1),' ','_')+'_credit ,'
	set @sqlcommand = @sqlcommand+replace(rtrim(@inv_sr1),' ','_')+'_drbal ,'
	set @sqlcommand = @sqlcommand+replace(rtrim(@inv_sr1),' ','_')+'_crbal '

fetch next from tempcursor1 into @inv_sr1
end
close tempcursor1
deallocate tempcursor1

set @sqlcommand = @sqlcommand+' FROM OUTPUTTBL ORDER BY MTH,UPDOWN,PARENTIDS '
print '==================================================================='
EXECUTE sp_executesql @SQLCOMMAND

SET @SQLCOMMAND = 'Drop table '+@TBLNAME1
EXECUTE sp_executesql @SQLCOMMAND
SET @SQLCOMMAND = 'Drop table '+@TBLNAME2
EXECUTE sp_executesql @SQLCOMMAND

DROP TABLE Fintbl1

IF OBJECT_ID (N'##STKVAL', N'U') IS NOT NULL
	begin
		Drop table ##STKVAL
	end

IF OBJECT_ID (N'##STKVAL1', N'U') IS NOT NULL
	begin
		Drop table ##STKVAL1
	end

IF OBJECT_ID (N'##STKVALConfig', N'U') IS NOT NULL
	begin
		Drop table ##STKVALConfig
	end



