DROP PROCEDURE [USP_ENT_EMAILLOG_DELETE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [USP_ENT_EMAILLOG_DELETE]
@id varchar(20)='',
@filename varchar(100)=''
As
Begin
	Delete From eMailLog Where id=@id and [filename]=@filename
End
GO
