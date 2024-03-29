If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Rep_MIS_MISSUE3')
Begin
	Drop Procedure Usp_Rep_MIS_MISSUE3
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Rep_MIS_MISSUE3]    Script Date: 2019-06-13 14:01:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Created By Prajakta B. on 14062019
Create PROCEDURE [dbo].[Usp_Rep_MIS_MISSUE3] 
	(@FrmDate SMALLDATETIME,@Todate SMALLDATETIME,@FParty nvarchar(100),@TParty nvarchar(100)) 	
	AS
Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@QueryString NVARCHAR(max),
		@ParmDefinition NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),
		@mchapno varchar(250),@meit_name  varchar(250)
Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),
		@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)
select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact
	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,iimain.TRAN_CD,iimain.ENTRY_TY,iimain.INV_NO,iimain.DATE'
	SET @QueryString =@QueryString+',iimain.u_nopro,iimain.prodtype,iimain.DUE_DT,iimain.U_LRNO,iimain.U_LRDT,iimain.U_DELI,iimain.U_VEHNO,iiitem.GRO_AMT AS IT_GROAMT,iimain.GRO_AMT GRO_AMT1,iimain.TAX_NAME,iiitem.TAX_NAME AS IT_TAXNAME,iimain.TAXAMT,iiitem.TAXAMT AS IT_TAXAMT,iimain.NET_AMT,iiitem.RATE,iiitem.U_ASSEAMT, cast (iiitem.NARR AS VARCHAR(2000)) AS NARR,iiitem.TOT_EXAMT'
	SET @QueryString =@QueryString+',IT_MAST.IT_NAME,IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.RATEUNIT
	,HSNCODE = (CASE WHEN ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END) ,IT_mast.U_ITPARTCD,iiitem.item_no'
	SET @QueryString =@QueryString+',It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)'
	SET @QueryString =@QueryString+',ST_TYPE=CASE WHEN iimain.SCONS_ID >0 THEN S2.ST_TYPE ELSE AC.ST_TYPE END'			
	SET @QueryString =@QueryString+',iiitem.ITSERIAL,item_fdisc=iiitem.tot_fdisc,iiitem.qty'	
	SET @QueryString =@QueryString+',iiitem.CGST_PER,iiitem.CGST_AMT,iiitem.SGST_PER,iiitem.SGST_AMT,iiitem.IGST_PER,iiitem.IGST_AMT'
	SET @QueryString =@QueryString+',iiitem.Compcess,iiitem.CCESSRATE'
	SET @QueryString =@QueryString+',iimain.Party_nm,ac_mast.GSTIN,ac_mast.State,iiitem.item,iiitem.stkunit,Total=iiitem.rate*iiitem.qty'
	SET @QueryString =@QueryString+',TotalGST=iiitem.CGST_AMT+iiitem.SGST_AMT+iiitem.IGST_AMT,iimain.EWBN,iimain.EWBDT,iimain.EWBDIST'
	SET @QueryString =@QueryString+',iimain.u_deli as transname,iimain.EWBVTD,iiitem.u_rule,iiitem.pinvno,iiitem.pinvdt'

SET @SQLCOMMAND=''
SET @SQLCOMMAND = N''+@QueryString+''+N''+' into '+'##main11'+' FROM iimain' 

 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN iiitem ON (iimain.TRAN_CD=iiitem.TRAN_CD AND iimain.ENTRY_TY=iiitem.ENTRY_TY)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN IT_MAST ON (iiitem.IT_CODE=IT_MAST.IT_CODE)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=iimain.AC_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST AC ON (AC.AC_ID=iimain.CONS_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S1 ON (iimain.AC_ID=S1.AC_ID AND iimain.SAC_ID=S1.SHIPTO_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S2 ON (iimain.CONS_ID=S2.AC_ID AND iimain.SCONS_ID=S2.SHIPTO_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+'WHERE iimain.entry_ty=''I5'' and (iimain.date BETWEEN '+CHAR(39)+cast(@FrmDate as varchar)+CHAR(39)+'  AND '+CHAR(39)+cast(@Todate as varchar )+CHAR(39)+') and (iimain.Party_nm BETWEEN '+CHAR(39)+@FParty+CHAR(39)+' AND '+CHAR(39)+@TParty+CHAR(39)+')'
 SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY iimain.INV_SR,iimain.INV_NO'
 print @sqlcommand
execute sp_executesql @SQLCOMMAND

SET @SQLCOMMAND ='select Date,inv_no,Party_nm,GSTIN,State,st_type,item,HSNCODE,qty,stkunit,rate,Total,u_asseamt,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,TotalGST,EWBN,EWBDT,EWBDIST,IT_GROAMT,net_amt,transname,u_vehno,U_LRDT,u_lrno,EWBVTD,CCESSRATE=case when CCESSRATE=''NO-CESS'' then '''' else CCESSRATE end,COMPCESS
					,u_nopro,prodtype,u_rule,pinvno,pinvdt from ##main11'
execute sp_executesql @SQLCOMMAND
drop table ##main11

--exec sp_executesql N'execute Usp_Rep_MIS_MISSUE3 @FDate,@TDate,@FParty,@TParty',N'@FParty nvarchar(4000),@TParty nvarchar(10),@FDate nvarchar(10),@TDate nvarchar(10)',@FParty=N'',@TParty=N'WORK ORDER',@FDate=N'04/01/2019',@TDate=N'03/31/2020'
--go





