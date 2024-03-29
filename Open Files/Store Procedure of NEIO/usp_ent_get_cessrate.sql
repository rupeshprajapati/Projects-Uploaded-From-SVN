DROP PROCEDURE [usp_ent_get_cessrate]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [usp_ent_get_cessrate]
@HsnCode Varchar(10),@StateCode Varchar(2),@TDate SmallDateTime
as

Declare @Inserted bit
set @Inserted=0
Select Top 1 CessRate,SupplyDesc=Left(SupplyDesc,250),CessExpr=CessRateExpr Into #CessRate from CessRate Where 1=2

Print 'a'

if @Inserted=0
Begin
	Print 'b'
	insert Into #CessRate Select Top 1 with TIES CessRate,SupplyDesc=Left(SupplyDesc,250),CessRateExpr  from CessRate Where  Hsncode=@HsnCode and statecode=@StateCode
				 and Activefrom < @TDate order by Activefrom desc 
	Select @Inserted=count(*) from #CessRate			 
End
if @Inserted=0
Begin
	Print 'c'
	insert Into #CessRate Select Top 1 with TIES CessRate,SupplyDesc=Left(SupplyDesc,250),CessRateExpr  from CessRate Where  Hsncode=Left(@HsnCode,6) and statecode=@StateCode
				 and Activefrom < @TDate order by Activefrom desc 
	Select @Inserted=count(*) from #CessRate
End

if @Inserted=0
Begin
	Print 'c'
	insert Into #CessRate Select Top 1 with TIES CessRate,SupplyDesc=Left(SupplyDesc,250),CessRateExpr  from CessRate Where  Hsncode=Left(@HsnCode,4) and statecode=@StateCode
				 and Activefrom < @TDate order by Activefrom desc 
	Select @Inserted=count(*) from #CessRate
End

if @Inserted=0
Begin
	Print 'd'
	insert Into #CessRate Select Top 1 with TIES CessRate,SupplyDesc=Left(SupplyDesc,250),CessRateExpr from CessRate Where  Hsncode=@HsnCode and statecode='00'
				 and Activefrom < @TDate order by Activefrom desc
	Select @Inserted=count(*) from #CessRate
end
if @Inserted=0
Begin
	Print 'e'
	insert Into #CessRate Select Top 1 with TIES  CessRate,SupplyDesc=Left(SupplyDesc,250),CessRateExpr from CessRate Where  Hsncode=Left(@HsnCode,6) and statecode='00'
				 and Activefrom < @TDate order by Activefrom desc 
	Select @Inserted=count(*) from #CessRate
End

if @Inserted=0
Begin
	Print 'e'
	insert Into #CessRate Select Top 1 with TIES  CessRate,SupplyDesc=Left(SupplyDesc,250),CessRateExpr from CessRate Where  Hsncode=Left(@HsnCode,4) and statecode='00'
				 and Activefrom < @TDate order by Activefrom desc 
	Select @Inserted=count(*) from #CessRate
End
Print 'f'
select * from #CessRate group by CessRate,SupplyDesc,CessExpr Order by CessRate
GO
