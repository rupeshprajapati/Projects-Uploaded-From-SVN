If Exists(Select [name] From SysObjects Where xType='P' and [name]='Usp_Rep_MIS_MREV4')
Begin
	Drop Procedure Usp_Rep_MIS_MREV4
End
GO
/****** Object:  StoredProcedure [dbo].[Usp_Rep_MIS_MREV4]    Script Date: 2019-06-13 14:01:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--Created By Prajakta B. on 14062019
Create PROCEDURE [dbo].[Usp_Rep_MIS_MREV4] 
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

Select Entry_ty,Tran_cd,itserial
,MINVNO=Inv_no,MDATE=Date,MITEM=Item
,Qty_used=Qty,Wastage=Qty,rmqty=qty,MQTY=Qty,liTran_cd=Tran_cd,Lientry=Entry_ty,li_itser=itserial
Into #iritem From iritem Where 1=2

Declare @Itserial Varchar(5),@it_code Numeric
Declare @LiEntry_ty Varchar(2), @Li_Tran_cd Numeric, @Li_itser Varchar(5)


Select Entry_ty,tran_cd,itserial Into #tmpRec FROM iritem WHERE 1=2
set @SQLCOMMAND='Insert Into #tmpRec Select distinct irmain.Entry_ty,irmain.tran_cd,iritem.itserial
			from iritem Inner join irmain ON (irmain.Entry_ty=iritem.Entry_ty and irmain.Tran_cd=iritem.Tran_cd) 
			Where irmain.entry_ty=''LR'''
execute sp_executesql @SQLCOMMAND

-- Finding Issues of condition
Declare IssueCur Cursor for
Select iritem.Entry_ty,iritem.date,iritem.tran_cd,iritem.itserial,iritem.inv_no,iritem.it_code FROM iritem
	Inner join #tmpRec b on (iritem.Entry_ty=b.Entry_ty and iritem.Tran_cd=b.Tran_cd )
Open IssueCur
Fetch next from IssueCur Into @Entry_ty ,@date ,@tran_cd ,@Itserial ,@inv_no ,@it_code 
While @@Fetch_Status=0
Begin
--print @Itserial
--IssueCur	ReceiptCur
	-- Finding  the labour job tran_cd
	print @Entry_ty
	print @Tran_cd
	print @Itserial
	Declare ReceiptCur Cursor for
	Select distinct LiEntry_ty, Li_Tran_cd, Li_itser from irrmdet 
	Where Entry_ty=@Entry_ty and Tran_cd =@Tran_cd and itserial=@Itserial
	Open ReceiptCur
	Fetch Next From ReceiptCur Into @LiEntry_ty,@Li_Tran_cd,@Li_itser 
	print @LiEntry_ty
	print @Li_Tran_cd
	print @Li_itser
	While @@Fetch_Status=0
	Begin
		
		Insert Into #iritem Select Entry_ty=@Entry_ty,Tran_cd=@tran_cd,Itserial=@Itserial,ii.pinvno,ii.pinvdt
		,ii.item,qty=sum(rm.Qty_used),Wastage=sum(rm.Wastage),rmqty=sum(rm.qty)
		,Qty=ii.qty,Li_Tran_cd=@Li_Tran_cd,LiEntry_ty=@LiEntry_ty,Li_itser=@Li_itser
		from irrmdet rm
		Inner Join iritem i on (rm.Tran_cd=i.Tran_cd and rm.Entry_ty=i.Entry_ty and rm.itserial=i.itserial)
		Inner join Iiitem ii on (rm.LiEntry_ty=ii.Entry_ty and rm.Li_Tran_cd=ii.Tran_cd and Li_itser=ii.itserial)
		Where LiEntry_ty=@LiEntry_ty and Li_Tran_cd=@Li_Tran_cd and Li_itser=@Li_itser 
		and i.Date<= @date AND i.inv_no  < = (CASE WHEN i.DATE<@date THEN '999999' ELSE @inv_no END )
		Group by ii.pinvno,ii.pinvdt,ii.item,ii.qty

		Fetch Next From ReceiptCur Into @LiEntry_ty,@Li_Tran_cd,@Li_itser 
	End
	Close ReceiptCur 
	Deallocate ReceiptCur 	
Fetch next from IssueCur Into @Entry_ty ,@date ,@tran_cd ,@Itserial ,@inv_no ,@it_code 
End
Close IssueCur 
Deallocate IssueCur 



	SET @QueryString = ''
	SET @QueryString = 'SELECT ''REPORT HEADER'' AS REP_HEAD,irmain.TRAN_CD,irmain.ENTRY_TY,irmain.INV_NO,irmain.DATE'
	SET @QueryString =@QueryString+',irmain.prodtype,irmain.DUE_DT,irmain.U_LRNO,irmain.U_LRDT,irmain.U_DELI,irmain.U_VEHNO,iritem.GRO_AMT AS IT_GROAMT,irmain.GRO_AMT GRO_AMT1,irmain.TAX_NAME,iritem.TAX_NAME AS IT_TAXNAME,irmain.TAXAMT,iritem.TAXAMT AS IT_TAXAMT,irmain.NET_AMT,iritem.RATE,iritem.U_ASSEAMT, cast (iritem.NARR AS VARCHAR(2000)) AS NARR,iritem.TOT_EXAMT'
	SET @QueryString =@QueryString+',IT_MAST.IT_NAME,IT_MAST.EIT_NAME,IT_MAST.CHAPNO,IT_MAST.RATEUNIT
									,HSNCODE = (CASE WHEN ISSERVICE=1 THEN IT_MAST.SERVTCODE ELSE IT_MAST.HSNCODE END) ,IT_mast.U_ITPARTCD,iritem.item_no'
	SET @QueryString =@QueryString+',It_Desc=(CASE WHEN ISNULL(it_mast.it_alias,'''')='''' THEN it_mast.it_name ELSE it_mast.it_alias END)'
	SET @QueryString =@QueryString+',ST_TYPE=CASE WHEN irmain.SCONS_ID >0 THEN S2.ST_TYPE ELSE AC.ST_TYPE END'			
	SET @QueryString =@QueryString+',iritem.ITSERIAL,item_fdisc=iritem.tot_fdisc,iritem.qty'	
	SET @QueryString =@QueryString+',iritem.CGST_PER,iritem.CGST_AMT,iritem.SGST_PER,iritem.SGST_AMT,iritem.IGST_PER,iritem.IGST_AMT'
	SET @QueryString =@QueryString+',iritem.Compcess,iritem.CCESSRATE'
	SET @QueryString =@QueryString+',irmain.Party_nm,ac_mast.GSTIN,ac_mast.State,iritem.item,iritem.stkunit,Total=iritem.rate*iritem.qty'
	SET @QueryString =@QueryString+',TotalGST=iritem.CGST_AMT+iritem.SGST_AMT+iritem.IGST_AMT,irmain.EWBN,irmain.EWBDT,irmain.EWBDIST'
	SET @QueryString =@QueryString+',irmain.u_deli as transname,irmain.EWBVTD,iritem.u_rule,iritem.pinvno,iritem.pinvdt'
	SET @QueryString =@QueryString+',RM.MINVNO,RM.MDATE,RM.MITEM,RM.MQTY,RM.QTY_USED,RM.WASTAGE,BALQTY=RM.MQTY -(RM.QTY_USED+RM.WASTAGE)
									,RM.liTran_cd,RM.Lientry,RM.li_itser,rm.rmqty' 
SET @SQLCOMMAND=''
SET @SQLCOMMAND = N''+@QueryString+''+N''+' into '+'##main11'+' FROM irmain' 

 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN iritem ON (irmain.TRAN_CD=iritem.TRAN_CD AND irmain.ENTRY_TY=iritem.ENTRY_TY)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN IT_MAST ON (iritem.IT_CODE=IT_MAST.IT_CODE)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST ON (AC_MAST.AC_ID=irmain.AC_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN AC_MAST AC ON (AC.AC_ID=irmain.CONS_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S1 ON (irmain.AC_ID=S1.AC_ID AND irmain.SAC_ID=S1.SHIPTO_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' LEFT JOIN SHIPTO S2 ON (irmain.CONS_ID=S2.AC_ID AND irmain.SCONS_ID=S2.SHIPTO_ID)'
 SET @SQLCOMMAND =	@SQLCOMMAND+' INNER JOIN #iritem RM ON (iritem.ENTRY_TY=RM.ENTRY_TY AND iritem.TRAN_CD=RM.TRAN_CD AND iritem.ITSERIAL=RM.ITSERIAL) '
 SET @SQLCOMMAND =	@SQLCOMMAND+'WHERE irmain.entry_ty=''LR'' and (irmain.date BETWEEN '+CHAR(39)+cast(@FrmDate as varchar)+CHAR(39)+'  AND '+CHAR(39)+cast(@Todate as varchar )+CHAR(39)+') and (irmain.Party_nm BETWEEN '+CHAR(39)+@FParty+CHAR(39)+' AND '+CHAR(39)+@TParty+CHAR(39)+')'
 SET @SQLCOMMAND =	@SQLCOMMAND+' ORDER BY irmain.INV_SR,irmain.INV_NO'
 print @sqlcommand
execute sp_executesql @SQLCOMMAND
print 1

SET @SQLCOMMAND ='select Date,inv_no,Party_nm,GSTIN,State,st_type,item,HSNCODE,qty,stkunit,rate,Total,u_asseamt,CGST_PER,CGST_AMT,SGST_PER,SGST_AMT,IGST_PER,IGST_AMT,TotalGST,EWBN,EWBDT,EWBDIST,IT_GROAMT,net_amt,transname,u_vehno,U_LRDT,u_lrno,EWBVTD,CCESSRATE=case when CCESSRATE=''NO-CESS'' then '''' else CCESSRATE end,COMPCESS
					,prodtype,MINVNO,MDATE,qty_used,BALQTY=MQTY -(QTY_USED+WASTAGE),rmqty
					from ##main11'
print 2
execute sp_executesql @SQLCOMMAND
drop table ##main11

--exec sp_executesql N'execute Usp_Rep_MIS_MREV4 @FDate,@TDate,@FParty,@TParty',N'@FParty nvarchar(4000),@TParty nvarchar(10),@FDate nvarchar(10),@TDate nvarchar(10)',@FParty=N'',@TParty=N'WORK ORDER',@FDate=N'04/01/2019',@TDate=N'03/31/2020'
--go





