If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Rep_MIS_MOP')
Begin
	Drop Procedure Usp_Rep_MIS_MOP
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Rep_MIS_MIP]    Script Date: 2019-05-06 15:11:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Created By Prajakta B. on 14062019
Create PROCEDURE [dbo].[Usp_Rep_MIS_MOP] 
	(@FrmDate SMALLDATETIME,@Todate SMALLDATETIME,@FParty nvarchar(100),@TParty nvarchar(100)) 	
	AS
Declare @SQLCOMMAND NVARCHAR(max),@TBLCON NVARCHAR(max),@SQLCOMMAND1 NVARCHAR(max),
		@ParmDefinition NVARCHAR(max),@SQLCOMMAND2 NVARCHAR(max)
Declare @chapno varchar(30),@eit_name  varchar(100),
		@mchapno varchar(250),@meit_name  varchar(250)
Declare @pformula varchar(100),@progcond varchar(250),@progopamt numeric(17,2)
Declare @Entry_ty Varchar(2),@Tran_cd Numeric,@Date smalldatetime,@Progtotal Numeric(19,2),
		@Inv_no Varchar(20),@Progcurrtotal Numeric(19,2)
select @pformula=isnull(pformula,''),@progcond=isnull(progcond,''),@progopamt=isnull(progopamt,0)  from manufact
		
Declare @uom_desc as Varchar(100),@len int,@fld_nm varchar(10),@fld_desc Varchar(10),@count int,@stkl_qty Varchar(100)

select @uom_desc=isnull(uom_desc,'') from vudyog..co_mast where dbname =rtrim(db_name())
Create Table #qty_desc (fld_nm varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS, fld_desc varchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS)
set @len=len(@uom_desc)
set @stkl_qty=''
If @len>0 
Begin
	while @len>0
	Begin
		set @fld_nm=substring(@uom_desc,1,charindex(':',@uom_desc)-1)
		set @uom_desc=substring(@uom_desc,charindex(':',@uom_desc)+1,@len)
		set @stkl_qty= @stkl_qty +', '+'opitem.'+@fld_nm

		if @len>0 and charindex(';',@uom_desc)=0
		begin
			set @uom_desc=@uom_desc
			set @fld_desc=@uom_desc
			SET @len=0
		End
		else
		begin
				set @fld_desc=substring(@uom_desc,1,charindex(';',@uom_desc)-1)
				set @uom_desc=substring(@uom_desc,charindex(';',@uom_desc)+1,@len)
				set @len=len(@uom_desc)
		End
		insert into #qty_desc values (@fld_nm,@fld_desc)
	End
End
Else
Begin
	set @stkl_qty=',opitem.QTY'
End

Declare @QueryString NVarchar(max)

	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,opmain.TRAN_CD,opmain.ENTRY_TY,opmain.INV_NO,opmain.DATE,opitem.qty'
	SET @QueryString =@QueryString+',opitem.GRO_AMT AS IT_GROAMT,opmain.GRO_AMT GRO_AMT1,opmain.NET_AMT,opitem.RATE, cast (opitem.NARR AS VARCHAR(2000)) AS NARR'
	SET @QueryString =@QueryString+',IT_MAST.IT_NAME,IT_MAST.RATEUNIT,HSNCODE = (CASE WHEN ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END),opitem.item_no'
	SET @QueryString =@QueryString+',It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)'
	SET @QueryString =@QueryString+',opmain.Party_nm,ac_mast.GSTIN,ac_mast.State,opitem.item,opitem.stkunit as Unit,Total=opitem.rate*opitem.qty'
	SET @QueryString =@QueryString+',opitem.mfgdt,opitem.expdt,opitem.batchno,opitem.supbatchno,opitem.supmfgdt,opitem.supexpdt'
	SET @QueryString =@QueryString+',projectitref.aentry_ty,projectitref.aqty'
	SET @SQLCOMMAND=''
	SET @SQLCOMMAND = N''+@QueryString+''+' into '+'##opmain11'+' FROM opmain' 
	SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN opitem ON (opmain.TRAN_CD=opitem.TRAN_CD AND opmain.ENTRY_TY=opitem.ENTRY_TY)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' left join projectitref on(opitem.entry_ty=projectitref.entry_ty and opitem.Tran_cd=projectitref.tran_cd and opitem.itserial=projectitref.Itserial)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' left JOIN IT_MAST ON (opitem.IT_CODE=IT_MAST.IT_CODE)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' left JOIN AC_MAST ON (AC_MAST.AC_ID=opmain.AC_ID)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S1 ON (opmain.AC_ID=S1.AC_ID)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' WHERE (opmain.date BETWEEN '+CHAR(39)+cast(@FrmDate as varchar)+CHAR(39)+'  AND '+CHAR(39)+cast(@Todate as varchar )+CHAR(39)+') and (opmain.Party_nm BETWEEN '+CHAR(39)+@FParty+CHAR(39)+' AND '+CHAR(39)+@TParty+CHAR(39)+')'
	SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY opmain.INV_SR,opmain.INV_NO'
	print @sqlcommand
	execute sp_executesql @SQLCOMMAND

SET @SQLCOMMAND ='select Date,inv_no,Party_nm,item,HSNCODE,qty,Unit,rate,Total,IT_GROAMT,net_amt,mfgdt,expdt,batchno,supmfgdt,supexpdt,supbatchno,aentry_ty,aqty from ##opmain11'
execute sp_executesql @SQLCOMMAND
drop table ##opmain11


--exec sp_executesql N'execute Usp_Rep_MIS_MOP @FDate,@TDate,@FParty,@TParty',N'@FParty nvarchar(4000),@TParty nvarchar(10),@FDate nvarchar(10),@TDate nvarchar(10)',@FParty=N'',@TParty=N'WORK ORDER',@FDate=N'04/01/2019',@TDate=N'03/31/2020'
--go





