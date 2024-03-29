If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Rep_MIS_MIP')
Begin
	Drop Procedure Usp_Rep_MIS_MIP
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Rep_MIS_MIP]    Script Date: 2019-05-06 15:11:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Created By Prajakta B. on 14062019
Create PROCEDURE [dbo].[Usp_Rep_MIS_MIP] 
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
		set @stkl_qty= @stkl_qty +', '+'ipitem.'+@fld_nm

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
	set @stkl_qty=',ipitem.QTY'
End

Declare @QueryString NVarchar(max)

	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,ipmain.TRAN_CD,ipmain.ENTRY_TY,ipmain.INV_NO,ipmain.DATE,ipitem.qty'
	SET @QueryString =@QueryString+',ipitem.GRO_AMT AS IT_GROAMT,ipmain.GRO_AMT GRO_AMT1,ipmain.NET_AMT,ipitem.RATE,ipitem.U_ASSEAMT, cast (ipitem.NARR AS VARCHAR(2000)) AS NARR'
	SET @QueryString =@QueryString+',IT_MAST.IT_NAME,IT_MAST.RATEUNIT,HSNCODE = (CASE WHEN ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END),ipitem.item_no'
	SET @QueryString =@QueryString+',It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)'
	SET @QueryString =@QueryString+',ipmain.Party_nm,ac_mast.GSTIN,ac_mast.State,ipitem.item,ipitem.stkunit as Unit,Total=ipitem.rate*ipitem.qty'
	SET @QueryString =@QueryString+',ipitem.mfgdt,ipitem.expdt,ipitem.batchno,ipitem.supbatchno,ipitem.supmfgdt,ipitem.supexpdt'
	SET @QueryString =@QueryString+',OTHITREF.rentry_ty,othitref.rqty,othitref.rinv_no'
	SET @SQLCOMMAND=''
	SET @SQLCOMMAND = N''+@QueryString+''+' into '+'##ipmain11'+' FROM ipmain' 
	SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN ipitem ON (ipmain.TRAN_CD=ipitem.TRAN_CD AND ipmain.ENTRY_TY=ipitem.ENTRY_TY)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' left join othitref on(ipitem.entry_ty=OTHITREF.entry_ty and ipitem.Tran_cd=OTHITREF.tran_cd and ipitem.itserial=othitref.Itserial)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' left JOIN IT_MAST ON (ipitem.IT_CODE=IT_MAST.IT_CODE)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' left JOIN AC_MAST ON (AC_MAST.AC_ID=ipmain.AC_ID)'
	SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S1 ON (ipmain.AC_ID=S1.AC_ID)'
	SET @SQLCOMMAND =	@SQLCOMMAND+'WHERE (ipmain.date BETWEEN '+CHAR(39)+cast(@FrmDate as varchar)+CHAR(39)+'  AND '+CHAR(39)+cast(@Todate as varchar )+CHAR(39)+') and (ipmain.Party_nm BETWEEN '+CHAR(39)+@FParty+CHAR(39)+' AND '+CHAR(39)+@TParty+CHAR(39)+')'
	SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY ipmain.INV_SR,ipmain.INV_NO'
	print @sqlcommand
	execute sp_executesql @SQLCOMMAND

SET @SQLCOMMAND ='select Date,inv_no,Party_nm,item,HSNCODE,qty,Unit,rate,Total,u_asseamt,IT_GROAMT,net_amt,mfgdt,expdt,batchno,supmfgdt,supexpdt,supbatchno,rentry_ty,rinv_no,rqty from ##ipmain11'
execute sp_executesql @SQLCOMMAND
drop table ##ipmain11


--exec sp_executesql N'execute Usp_Rep_MIS_MIP @FDate,@TDate,@FParty,@TParty',N'@FParty nvarchar(4000),@TParty nvarchar(10),@FDate nvarchar(10),@TDate nvarchar(10)',@FParty=N'',@TParty=N'WORK ORDER',@FDate=N'04/01/2019',@TDate=N'03/31/2020'
--go





