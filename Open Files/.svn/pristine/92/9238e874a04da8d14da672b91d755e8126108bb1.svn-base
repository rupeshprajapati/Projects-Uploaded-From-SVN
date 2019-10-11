If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Rep_MIS_MQC')
Begin
	Drop Procedure Usp_Rep_MIS_MQC
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Rep_MIS_MQC]    Script Date: 2019-05-03 16:34:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Created By Prajakta B. on 14062019
Create PROCEDURE [dbo].[Usp_Rep_MIS_MQC] 
	(@FrmDate SMALLDATETIME,@Todate SMALLDATETIME) 	
	AS
Declare @SQLCOMMAND NVARCHAR(max)

SET @SQLCOMMAND ='select a.batchno,a.qc_by,a.QC_DT,a.qcholdqty,a.qcaceptqty,a.qcrejqty,a.qcsampqty,a.qcwasteqty,a.qcprocloss,a.entry_ty,a.[Date],it_mast.it_name 
				  from QCHistory a
				  left join It_mast on (it_mast.it_code=a.it_code)'
execute sp_executesql @SQLCOMMAND



--exec sp_executesql N'execute Usp_Rep_MIS_MQC @FDate,@TDate',N'@FDate nvarchar(10),@TDate nvarchar(10)',@FDate=N'04/01/2019',@TDate=N'03/31/2020'
--go


