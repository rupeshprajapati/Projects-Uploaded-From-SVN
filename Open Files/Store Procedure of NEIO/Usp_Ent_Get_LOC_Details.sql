DROP PROCEDURE [Usp_Ent_Get_LOC_Details]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amrendra Kumar Singh
-- Create date: 07/06/2012
-- Description:	This Stored procedure is useful to get Column Description From SQL Table MetaData 
-- Modification Date/By/Reason: 
-- Remark:
-- =============================================

Create Procedure [Usp_Ent_Get_LOC_Details]
@TableName varchar(60)--,@uniqueCol varchar(60)
as
Begin

Declare @SqlCommand nvarchar(4000),@Col_Desc varchar(60) ,@Value varchar(60)

set @SqlCommand= ''

if exists (select * from sysobjects where [name]=@TableName ) 
begin 
	set @SqlCommand = 'select Top 1 RetValue from '+ @TableName
	execute sp_executeSql @SqlCommand
	set @SqlCommand ='drop table '+@TableName
	execute sp_executeSql @SqlCommand
end
else
begin
select '' RetValue
end 
end
GO
