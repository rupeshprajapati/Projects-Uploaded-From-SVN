DROP PROCEDURE [USP_ENT_Gen_BankReco]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [USP_ENT_Gen_BankReco]
@sdate smalldatetime,@edate smalldatetime
as

--DECLARE @GRPID AS INT,@MCOND AS BIT,@LVL  AS INT,@GRP AS VARCHAR(100)

--SET @GRP='CASH & BANK BALANCES'
--CREATE TABLE #ACGRPID (GACID DECIMAL(9),LVL DECIMAL(9))
--SET @LVL=0
--INSERT INTO #ACGRPID SELECT AC_GROUP_ID,@LVL  FROM AC_GROUP_MAST WHERE AC_GROUP_NAME=@GRP
--SET @MCOND=1
--WHILE @MCOND=1
--BEGIN
--	IF EXISTS (SELECT AC_GROUP_ID FROM AC_GROUP_MAST WHERE GAC_ID IN (SELECT DISTINCT GACID  FROM #ACGRPID WHERE LVL=@LVL)) --WHERE LVL=@LVL
--	BEGIN
--		PRINT @LVL
--		INSERT INTO #ACGRPID SELECT AC_GROUP_ID,@LVL+1 FROM AC_GROUP_MAST WHERE GAC_ID IN (SELECT DISTINCT GACID  FROM #ACGRPID WHERE LVL=@LVL)
--		SET @LVL=@LVL+1
--	END
--	ELSE
--	BEGIN
--		SET @MCOND=0	
--	END
--END

Select bankreco.* from bankreco Inner Join Ac_Mast On (Ac_Mast.Ac_Name=bankreco.Ac_Name) 
Where Ac_Mast.typ='Bank'
--Where Ac_Mast.ac_group_id in (Select GACID from #ACGRPID)
and (BankReco.Cl_Date=0 or (BankReco.Cl_Date between @sdate  and @edate))
GO
