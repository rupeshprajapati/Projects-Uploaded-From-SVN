DROP PROCEDURE [usp_rep_progressiveTotal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [usp_rep_progressiveTotal]
@pFormula nvarchar(50),@pProgCond varchar(50),@pInvNo varchar(20),@pInvDate smalldatetime,@@spOutput numeric (20,5) output
as
declare @spFormula varchar(50),@spProgCond varchar(50),@spString nvarchar(1000),@spprogTotal numeric(20,5)
if ltrim(rtrim(@pformula)) != ''
	begin
		set @spFormula = @pFormula
	end
else
	begin
		set @spFormula = 'qty * rate'
	end

if  ltrim(rtrim(@pProgcond)) != '' --[ Sales ]
	begin
		  set @spString = 'declare mainSTcurs cursor for (select sum('+@spFormula+') as stprogtot from stmain a left join stitem b on a.entry_ty = b.entry_ty and a.tran_cd = b.tran_cd where a.entry_ty = '+char(39)+'ST'+char(39)+' and CONVERT(decimal(15),a.inv_no)<='+@pInvno+' and a.date <='+char(39)+cast(@pInvdate as varchar)+char(39)+' and '+@pProgcond+')'
	end
else
	begin
		  set @spString = 'declare mainSTcurs cursor for (select sum('+@spFormula+') as stprogtot from stmain a left join stitem b on a.entry_ty = b.entry_ty and a.tran_cd = b.tran_cd where a.entry_ty = '+char(39)+'ST'+char(39)+' and CONVERT(decimal(15),a.inv_no)<='+@pInvno+' and a.date <='+char(39)+cast(@pInvdate as varchar)+char(39)+')'
	end
print @spstring
execute SP_EXECUTESQL @spString

set @spString = ''
declare @spSTprogtot numeric(20,5)
set @spSTprogtot = 0
open mainSTcurs
fetch next from mainSTcurs into @spSTprogtot
print @spSTprogtot
close mainSTcurs
deallocate mainSTcurs

if ltrim(rtrim(@pProgcond)) != '' --[ Sales Return]
	begin
		  set @spString = 'declare mainSRcurs cursor for (select sum('+@spFormula+') as srprogtot from srmain a left join sritem b on a.entry_ty = b.entry_ty and a.tran_cd = b.tran_cd where a.entry_ty = '+char(39)+'ST'+char(39)+' and CONVERT(decimal(15),a.inv_no)<='+@pInvno+' and a.date <='+char(39)+cast(@pInvdate as varchar)+char(39)+' and '+@pProgcond+')'
	end
else
	begin
		  set @spString = 'declare mainSRcurs cursor for (select sum('+@spFormula+') as srprogtot from srmain a left join sritem b on a.entry_ty = b.entry_ty and a.tran_cd = b.tran_cd where a.entry_ty = '+char(39)+'ST'+char(39)+' and CONVERT(decimal(15),a.inv_no)<='+@pInvno+' and a.date <='+char(39)+cast(@pInvdate as varchar)+char(39)+')'
	end

execute SP_EXECUTESQL @spString

declare @spSRprogtot numeric(20,5)
set @spSRprogtot = 0
open mainSRcurs
fetch next from mainSRcurs into @spSRprogtot
set @spSTprogtot = isnull(@spSTprogtot,0)
set @spSRprogtot = isnull(@spSRprogtot,0)
close mainSRcurs
deallocate mainSRcurs
set @@spOutput = (@spSTprogtot - @spSrprogtot)
GO
