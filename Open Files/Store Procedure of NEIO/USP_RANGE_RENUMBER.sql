DROP PROCEDURE [USP_RANGE_RENUMBER]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*:*****************************************************************************
*:       Program: USP_RANGE_RENUMBER
*:        System: UDYOG Software (I) Ltd.
*:    Programmer: SACHIN N. S.
*: Last modified: 18/03/2010
*:		AIM		: Com Menu Range Renumbering
**:******************************************************************************/

CREATE PROCEDURE [USP_RANGE_RENUMBER]
AS
DECLARE @MAX_RANGE NUMERIC(12), @RANGE NUMERIC(12), @PADNAME VARCHAR(50), @BARNAME VARCHAR(50), @STOP_LOOP NUMERIC(3)

SET @STOP_LOOP = 0 
SET @RANGE   = 0
SET @PADNAME = ''
SET @BARNAME = ''

DECLARE	_TMPRANGE CURSOR FOR 
	SELECT A.[RANGE], A.PADNAME, A.BARNAME FROM COM_MENU A, COM_MENU B WHERE A.PADNAME = B.BARNAME AND A.[RANGE] < B.[RANGE] ORDER BY A.[RANGE]
OPEN _TMPRANGE
FETCH NEXT FROM _TMPRANGE INTO @RANGE, @PADNAME, @BARNAME
IF @@FETCH_STATUS = 0
BEGIN
	SET @STOP_LOOP = 1
END

WHILE @STOP_LOOP <> 0
BEGIN

	SELECT @MAX_RANGE=MAX([RANGE]) FROM COM_MENU 
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE COM_MENU SET [RANGE] = @MAX_RANGE + 1, PROGNAME = REPLACE(PROGNAME,LTRIM(RTRIM(STR(@RANGE))),LTRIM(RTRIM(STR(@MAX_RANGE+1))))
			WHERE [RANGE] = @RANGE AND PADNAME = @PADNAME AND BARNAME = @BARNAME
		SET @MAX_RANGE = @MAX_RANGE + 1
		FETCH NEXT FROM _TMPRANGE INTO @RANGE, @PADNAME, @BARNAME
	END
	CLOSE _TMPRANGE
	DEALLOCATE _TMPRANGE

	SET @STOP_LOOP = 0 
	DECLARE	_TMPRANGE CURSOR FOR 
	SELECT A.[RANGE], A.PADNAME, A.BARNAME FROM COM_MENU A, COM_MENU B WHERE A.PADNAME = B.BARNAME AND A.[RANGE] < B.[RANGE] ORDER BY A.[RANGE]
	OPEN _TMPRANGE
	FETCH NEXT FROM _TMPRANGE INTO @RANGE, @PADNAME, @BARNAME
	IF @@FETCH_STATUS = 0
	BEGIN
		SET @STOP_LOOP = 1
	END
END
CLOSE _TMPRANGE
DEALLOCATE _TMPRANGE
GO
