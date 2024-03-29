DROP PROCEDURE [USP_REP_EMP_PT_CHALLAN_MENU]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:Rupesh		
-- Create date: 16/09/2012
-- Description:	This Stored procedure is useful to generate PF Challan Report From Menu Option.
-- Modified By:Date:Reason: 
-- Remark:
-- =============================================

CREATE Procedure [USP_REP_EMP_PT_CHALLAN_MENU]
@TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),  
 @SDATE SMALLDATETIME,@EDATE SMALLDATETIME,  
 @SNAME NVARCHAR(60),@ENAME NVARCHAR(60),  
 @SITEM NVARCHAR(60),@EITEM NVARCHAR(60),  
 @SAMT NUMERIC,@EAMT NUMERIC,  
 @SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),  
 @SCAT NVARCHAR(60),@ECAT NVARCHAR(60),  
 @SWARE NVARCHAR(60),@EWARE NVARCHAR(60),  
 @SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),  
 @FINYR NVARCHAR(20), @EXPARA NVARCHAR(60)  
AS
begin
	--EXECUTE USP_REP_EMP_PT_CHALLAN_MENU'','','','04/01/2012','03/31/2013','','','','',0,0,'','','','','','','','','2012-2013',''
	Declare @FCON as VARCHAR(4000)
	set @FCon='m.U_Cldt between '+char(39)+cast(@sDate as varchar)+Char(39)+ ' and '+Char(39)+cast(@eDate as varchar)+Char(39)
	print @FCon
	EXECUTE Usp_Rep_Emp_PT_Payment_Challan @FCon
End
GO
