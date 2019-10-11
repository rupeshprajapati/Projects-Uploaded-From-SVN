DROP PROCEDURE [USP_REP_ST_BILLQ]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amrendra Kumar Singh
-- Create date: 22/05/2012
-- Description:	This Stored procedure is useful to generate Quality Certificate Report.
-- Modification Date/By/Reason:
-- Remark:
-- =============================================
CREATE PROCEDURE [USP_REP_ST_BILLQ]
	@ENTRYCOND NVARCHAR(254)
	AS
Declare @SQLCOMMAND as NVARCHAR(4000),@TBLCON as NVARCHAR(4000),@SQLCOMMAND1 NVARCHAR(4000),@ParmDefinition NVARCHAR(500)
Declare @chapno varchar(30),@eit_name  varchar(100),@mchapno varchar(250),@meit_name  varchar(250)

	SET @TBLCON=RTRIM(@ENTRYCOND)
	Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
	Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),@Inv_no Varchar(20)


select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact

Select Entry_ty ,Tran_cd=0,Date,inv_no,itserial=space(6) COLLATE DATABASE_DEFAULT  Into #stmain from stmain Where 1=0 	
		set @sqlcommand='Insert Into #stmain Select stmain.Entry_ty,stmain.Tran_cd,stmain.date,stmain.inv_no,stitem.itserial from stmain Inner Join stitem on (stmain.Entry_ty=stitem.Entry_ty and stmain.Tran_cd=stitem.Tran_cd) Where '+@TBLCON
		print @sqlcommand
		execute sp_executesql @sqlcommand


SELECT   STMAIN.INV_NO,STMAIN.DATE  
,STITEM.QTY,STITEM.RATE,STITEM.It_code 
,PROJECTITREF.BATCHNO,PROJECTITREF.MFGDT,PROJECTITREF.EXPDT,STITEM.ITSERIAL   
,It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'')='' THEN it_mast.it_name ELSE it_mast.it_alias END) 
into #stmain1 FROM STMAIN           
INNER JOIN STITEM ON (STMAIN.TRAN_CD=STITEM.TRAN_CD)          
INNER JOIN #stmain ON (STITEM.TRAN_CD=#stmain.TRAN_CD and STITEM.Entry_ty=#stmain.entry_ty and STITEM.ITSERIAL=#stmain.itserial)
LEFT JOIN PROJECTITREF ON (PROJECTITREF.ENTRY_TY=STITEM.ENTRY_TY AND PROJECTITREF.TRAN_CD=STITEM.TRAN_CD 
AND PROJECTITREF.ITSERIAL=STITEM.ITSERIAL)      
INNER JOIN IT_MAST ON (STITEM.IT_CODE=IT_MAST.IT_CODE)       
ORDER BY STMAIN.INV_SR,STMAIN.INV_NO
,PROJECTITREF.BATCHNO,PROJECTITREF.ITSERIAL  

SELECT a.* ,val.smp_value,
   QcPara.Qc_para,QcPara.[desc],QcPara.std_value,QcPara.low_tol,QcPara.up_tol,QcPara.is_Tol_in_percent,QcPara.DataType,
	case when QcPara.low_tol <> '' then 
			case when QcPara.is_Tol_in_percent = 1 and QcPara.DataType = 'Numeric' 
			  then (cast(QcPara.std_value as numeric(10,4))* cast(isnull(QcPara.low_tol,0) as numeric(10,4))/100)
			  else cast(QcPara.low_tol as numeric(10,4))
			end 
		else 0
	end as nlow,
	case when QcPara.up_tol <> '' then 
			case when (QcPara.is_Tol_in_percent = 1 and QcPara.DataType = 'Numeric')
			  then (cast(isnull(QcPara.std_value,0) as numeric(10,4))* cast(isnull(QcPara.up_tol,0) as numeric(10,4))/100)
			  else cast(isnull(QcPara.up_tol,0) as numeric(10,4))
			end 
		else 0
	end as nHigh
	
	FROM #STMAIN1 a
	inner join qc_inspection_item qcItem on (qcItem.batchno=a.batchno)
inner join qc_inspection_Parameter  QcPara on (QcPara.insp_id=qcItem.Insp_id)
inner join QcSampleValue val on (qcPara.Qc_para=val.Qc_Para and val.insp_id =qcItem.insp_id and qcPara.itserial=val.itserial)
Order by a.INV_NO  ,a.BATCHNO,a.ITSERIAL		





	
Drop table #stmain
Drop table #stmain1
GO
