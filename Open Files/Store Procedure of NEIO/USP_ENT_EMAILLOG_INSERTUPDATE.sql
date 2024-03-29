DROP PROCEDURE [USP_ENT_EMAILLOG_INSERTUPDATE]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [USP_ENT_EMAILLOG_INSERTUPDATE]
@id varchar(20),
@to varchar(1000)='',
@cc varchar(1000)='',
@bcc varchar(1000)='',
@subject varchar(1000)='',
@body varchar(1000)='',
@filepath varchar(100)='',
@filename varchar(100)='',
@removefiles bit=0,
@status varchar(20)='',
@remarks varchar(1000)='',
@emaillogfiles bit=0,
@logemailid varchar(1000)=''
As
Begin
if(Not Exists(Select * from eMailLog Where id=@id and [filename]=@filename))
	Begin
		Insert into eMailLog(id,[to],cc,bcc,[subject],body,filepath,[filename],removefiles,[status],remarks,emaillogfiles,logemailid)
		values(@id,@to,@cc,@bcc,@subject,@body,@filepath,@filename,@removefiles,@status,@remarks,@emaillogfiles,@logemailid)
	End
else
	Begin
		Update eMailLog set [to]=@to,cc=@cc,bcc=@bcc,[subject]=@subject,body=@body,filepath=@filepath,removefiles=@removefiles,
		[status]=@status,remarks=@remarks,emaillogfiles=@emaillogfiles,logemailid=@logemailid Where [id]=@id and [filename]=@filename
	End
End
GO
