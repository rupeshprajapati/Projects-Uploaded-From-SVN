If Exists(Select [name] From SysObjects Where xType='P' and [name]='Ent_Item_wise_Pickup')
Begin
	Drop Procedure Ent_Item_wise_Pickup
End
/****** Object:  StoredProcedure [dbo].[Ent_Item_wise_Pickup]    Script Date: 01/17/2018 14:08:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Description:	This is useful for Item wise Pickup of Purchase, Import Purchase and Goods Receipt entries in Input to Production report.
-- Updated By Sachin N. S. on 08/11/2011 for Bug-150. Import Purchase not displayed in the Pickup button list.
-- Updated By Birendra on 08/12/2011 for Bug-845. PO-AR-PT Then transaction is not showing in IP.
-- Updated By Birendra on 23/12/2011 for Bug-1085. (after updation Bug-845)AR-PT Then transaction is not showing in IP.
-- Updated By Amrendra On 28/03/2012 for New QC
-- Updated By Birendra on 17/05/2012 for Bug-4124. issue in solution Bug-845.
-- Updated By Birendra on 18/05/2012 for Bug-4106. data filteration for date.
-- Updated By Birendra on 28/07/2012 for Bug-5498. 
-- Updated By Birendra:Bug-5371 on 26/07/2012:"item pickup from date" taken from manufact table(field itempickdt)
-- Updated By Shrikant:Bug-5930, 5931 on 31/08/2012 for quantity change at item level
-- Updated By Birendra:Bug-5212 on 11/07/2012:start:Additional info field
-- Updated By Shrikant:Bug-6362, 6416 on 02/10/2012 for Rate issue and Sales return 
-- Updated By Amrendra:Bug-4973 On 03/12/2012 Quality Control Module Related Issue
-- Updated By Birendra:Bug-9167 on 10/06/2013:change done for take it_code instead of It_name while checking item
-- Updated By Birendra:Bug-9174 on 19/06/2013:change done for Rate calculation include voucher wise charges if there.
-- Updated By Birendra:Bug-21081 on 16/12/2013:change done for length issue of variable.
-- Updated By Pankaj B.:Bug-22827 on 21/06/2014
--- changes by Suraj Kumawat for gst date on 26-05-2017 
-- Updated By Shrikant:Auto updater 13.0.5 
---changes by Suraj Kumawat for bug-31112 Date on 09-01-2018
-- Changed by Sachin N. S. on 23/05/2018 for Bug-31382
-- Changed by Sachin N. S. on 08/09/2018 for Bug-31756
-- Changed by Priyanka B on 17/01/2019 for Bug-31850
-- Changed by Shrikant S. on 13/09/2019 for Bug-32823
-- =============================================
Create Procedure [dbo].[Ent_Item_wise_Pickup]
(
	@paraEntry_Ty Varchar(2),
	@paraTran_Cd Int,
	@paraCDept as Varchar(20),
	@paraIt_name as Varchar(50),
	@paraLcrule as varchar(20),
	@paraLProd as varchar(10),   -- Added by Amrendra on 28/03/2012 for New QC
	@paraLcdate as varchar(20)  --Birendra : Bug-4106 on 18/05/2012
	,@paraWarenm as varchar(50)=null			--Added by Shrikant S. on 27/01/2018 for Bug-31083
)
As
/* Internale Variable declaration and Assigning [Start] */
print 'sss'
print @paraLcrule  
DECLARE @Fld_Nm Varchar(10),@Pert_Name Varchar(10),@entry_ty Varchar(2),@data_ty varchar(20),@zdata_ty varchar(20),@att_file bit,@tblname varchar(20),@vouchrg varchar(max)
--DECLARE @FldName Varchar(500),@FldPerName Varchar(500),@Qrystr1 Varchar(1000),@Qrystr2 Varchar(1000),@Qrystr3 Varchar(1000),@Qrystr4 Varchar(1000),@Qrystr5 Varchar(1000),@Qrystr6 Varchar(1000)	--Changed by Shrikant S. on 02/10/2012 for Bug-6416 
--Birendra:Bug-21081 on 16/12/2013:modified above line with below one.
---DECLARE @FldName Varchar(500),@FldPerName Varchar(500),@Qrystr1 Varchar(max),@Qrystr2 Varchar(max),@Qrystr3 Varchar(max),@Qrystr4 Varchar(max),@Qrystr5 Varchar(max),@Qrystr6 Varchar(max) --- Commented by Suraj K. Date on 09-01-2018 for bug-31112 	
DECLARE @FldName Varchar(max),@FldPerName Varchar(max),@Qrystr1 nVarchar(max),@Qrystr2 nVarchar(max),@Qrystr3 nVarchar(max),@Qrystr4 nVarchar(max),@Qrystr5 nVarchar(max),@Qrystr6 nVarchar(max)  --- Added by Suraj K. Date on 09-01-2018 for bug-31112
Declare @Qrystr7 nVarchar(max)  --- Added by Sachin N. S. on 23/05/2018 for Bug-31382

SELECT @FldName = '',@FldPerName = '',@Qrystr1 = '',@Qrystr2 = '', @Qrystr3 = '', @Qrystr4 = '', @Qrystr5 = '',@Qrystr6 = '',@vouchrg=''	--Changed by Shrikant S. on 02/10/2012 for Bug-6416 
Select @Qrystr7= ''		--- Added by Sachin N. S. on 23/05/2018 for Bug-31382
--Amrendra Bug-4973 03/12/2012 ---->
DECLARE @ItemType varchar(100),@it_code int,@QcEnabledItem bit
set @ItemType=''
set @it_code=0
set @QcEnabledItem=0
--select @ItemType=Type,@it_code=it_code from it_mast where it_name=@paraIt_name --Amrendra Bug-4973
-- Birendra : Bug-9167 on 10/06/2013 :Modified as per below:
select @ItemType=Type,@it_code=it_code from it_mast where it_code=@paraIt_name 

print @it_code
print @paraIt_name
select @QcEnabledItem=qcprocess from it_advance_setting where it_code=@it_code
print @QcEnabledItem

--Amrendra Bug-4973 03/12/2012 <----


Declare @TBLNM Varchar(50),@TBLNAME1 Varchar(50),@TBLNAME2 Varchar(50),
	@TBLNAME3 Varchar(50),@TBLNAME4 Varchar(50),
	@SQLCOMMAND as NVARCHAR(4000)

Select @TBLNM = (SELECT substring(rtrim(ltrim(str(RAND( (DATEPART(mm, GETDATE()) * 100000 )
		+ (DATEPART(ss, GETDATE()) * 1000 )+ DATEPART(ms, GETDATE())) , 20,15))),3,20) as No)
		
Select @TBLNAME1 = '##TMP1'+@TBLNM,@TBLNAME2 = '##TMP2'+@TBLNM
Select @TBLNAME3 = '##TMP3'+@TBLNM,@TBLNAME4 = '##TMP4'+@TBLNM
/* Internale Variable declaration and Assigning [End] */
--DECLARE DcmastCur CURSOR FOR 
--	Select Fld_Nm,Pert_Name From Dcmast
--		Where Code = 'E' And Entry_Ty in ('PT','P1','AR') AND Att_File = 0 and stkval = 1 --Birendra : Added stkval
--Birendra:Bug-5371 on 26/07/2012:"item pickup from date" taken from manufact table(field itempickdt):Start:
declare @itempickdt varchar(20)
select top 1 @itempickdt=ltrim(rtrim(str(day(itempickdt))))+'/'+ltrim(rtrim(str(month(itempickdt))))+'/'+ltrim(rtrim(str(Year(itempickdt)))) from manufact
--Birendra:Bug-5371 on 26/07/2012:"item pickup from date" taken from manufact table(field itempickdt):End:

if ltrim(rtrim(@paraLProd))='QC' -- Added by Amrendra on 28/03/2012 for New QC
begin
	--set @Qrystr1 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.qcholdqty,I.qcaceptqty,I.qcrejqty,'			-- Commented by Pankaj B. on 21-06-2014 for Bug-22827 
		--set @Qrystr1 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.qcholdqty,I.qcaceptqty,I.qcrejqty,I.lastqc_dt,' -- Added by Pankaj B. on 21-06-2014 for Bug-22827			--Commented by Shrikant S. on 27/01/2018 for Bug-31083
		--set @Qrystr1 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.qcholdqty,I.qcaceptqty,I.qcrejqty,I.lastqc_dt,I.ware_nm,' -- Added by Shrikant S. on 27/01/2018 for Bug-31083
		set @Qrystr1 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.qcholdqty,Q.qcaceptqty,I.qcrejqty,I.lastqc_dt,I.ware_nm,' -- Changed by Sachin N. S. on 08/09/2018 for Bug-31756
--	set @Qrystr2 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.qcholdqty,I.qcaceptqty,I.qcrejqty,'
--	set @Qrystr3 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.qcholdqty,I.qcaceptqty,I.qcrejqty,'
--	set @Qrystr4 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.qcholdqty,I.qcaceptqty,I.qcrejqty,'
--	set @Qrystr5 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.qcholdqty,I.qcaceptqty,I.qcrejqty,'	--Added by Shrikant S. on 02/10/2012 for Bug-6416 
	set @Qrystr2 =@Qrystr1
	set @Qrystr3 =@Qrystr1
	set @Qrystr4 =@Qrystr1
	set @Qrystr5 =@Qrystr1
	set @Qrystr6 =REPLACE(@Qrystr1,'I.u_asseamt','0 AS u_asseamt')			--Added by Suraj K. on 09/01/2018 for Bug-31112
	set @Qrystr7 =REPLACE(@Qrystr1,'I.u_asseamt','0 AS u_asseamt')		--Added by Shrikant S. on 11/09/2018 for Installer 2.0.0 PRO
end
else -- Added by Amrendra on 28/03/2012 for New QC
begin
	--Birendra
	--set @Qrystr1 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,'			--Commented by Shrikant S. on 27/01/2018 for Bug-31083
	set @Qrystr1 = 'I.Tran_cd, I.entry_ty, I.date, I.It_code, I.itserial, I.inv_no, I.item_no, I.inv_sr, I.qty, I.rate, I.re_qty, I.u_asseamt,I.TAX_NAME,I.TAXAMT,I.WARE_NM,'			-- Added by Shrikant S. on 27/01/2018 for Bug-31083
--	set @Qrystr2 = 'Tran_cd, entry_ty, date, It_code, itserial, inv_no, item_no, inv_sr, qty, rate, re_qty, u_asseamt,TAX_NAME,TAXAMT,'
--	set @Qrystr3 = 'Tran_cd, entry_ty, date, It_code, itserial, inv_no, item_no, inv_sr, qty, rate, re_qty, u_asseamt,TAX_NAME,TAXAMT,'
--	--added by amrendra for FM Costing On 13/04/2011 --- Start
--	set @Qrystr4 = 'Tran_cd, entry_ty, date, It_code, itserial, inv_no, item_no, inv_sr, qty, rate, re_qty, u_asseamt,TAX_NAME,TAXAMT,'
--	--added by amrendra for FM Costing On 13/04/2011 --- Start
--	set @Qrystr5 = 'Tran_cd, entry_ty, date, It_code, itserial, inv_no, item_no, inv_sr, qty, rate, re_qty, u_asseamt,TAX_NAME,TAXAMT,'				--Added by Shrikant S. on 02/10/2012 for Bug-6416 
	set @Qrystr2 = @Qrystr1
	set @Qrystr3 = @Qrystr1
	set @Qrystr4 = @Qrystr1
	set @Qrystr5 = @Qrystr1
	set @Qrystr6 =REPLACE(@Qrystr1,'I.u_asseamt','0 AS u_asseamt')	--Added by Suraj K. on 09/01/2018 for Bug-31112
	set @Qrystr7 =REPLACE(@Qrystr1,'I.u_asseamt','0 AS u_asseamt')		--Added by Shrikant S. on 11/09/2018 for Installer 2.0.0 PRO
end

print @Fld_Nm
--Birendra:Bug-5212 on 11/07/2012:start:Additional info field
DECLARE lotherCur CURSOR FOR 
	Select distinct Fld_Nm,Data_ty,att_file From lother --Birendra : bug-9174 on 18/06/2013
		Where e_code in ('PT','AR','P1','OS','SR','OP','ES','LR') and inpickup = 1	--Added by Shrikant S. on 13/09/2019 for Bug-32823
		--Where e_code in ('PT','AR','P1','OS','SR','OP','ES') and inpickup = 1	--Added by Sachin N. S. on 23/05/2018 for Bug-31382		--Commented by Shrikant S. on 13/09/2019 for Bug-32823
		--Where e_code in ('PT','AR','P1','OS','SR','OP') and inpickup = 1	--Added by Suraj K. date on 09-01-2018 for  bug-31112
		----Where e_code in ('PT','AR','P1','OS','SR')  and inpickup = 1				--Commented by Suraj K. for Bug-31112 date on 01-09-2018
--		Where e_code in ('PT','AR','P1','OS','SR') AND Att_File = 0 and inpickup = 1				--Added by Shrikant S. on 02/10/2012 for Bug-6416 
		--Where e_code in ('PT','AR','P1','OS') AND Att_File = 0 and inpickup = 1					--Commented By Shrikant S. on 02/10/2012 for Bug-6416

OPEN lotherCur

FETCH NEXT FROM lotherCur INTO @Fld_Nm,@Data_ty,@att_file --Birendra : Bug-9174 on 18/06/2013

WHILE @@FETCH_STATUS = 0
   BEGIN
	  IF @Fld_Nm IS NOT NULL AND @Fld_Nm <> ''	
	  BEGIN	
			set @zdata_ty=case when @data_ty='Decimal' then ' 0 as ' else 'space(1) as' end 		
			set @tblname =case when @att_file=1 then 'MAIN' else 'ITEM' end --Birendra : Bug-9174 on 18/06/2013
		  SET @FldName = @FldName+'b.'+LTrim(RTrim(@Fld_Nm))+','
			---PTITem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'PT'+ltrim(rtrim(@tblname)) ))
			Begin 
				set @Qrystr1 = @Qrystr1 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr1 = @Qrystr1 +@zdata_ty + LTrim(RTrim(@Fld_Nm))  +','
			end 
			--IRItem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'IR'+ltrim(rtrim(@tblname)) ))
			Begin 
				set @Qrystr2 = @Qrystr2 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr2 = @Qrystr2 +@zdata_ty + LTrim(RTrim(@Fld_Nm))  +','
			end 
			--ARItem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'AR'+ltrim(rtrim(@tblname)) ))
			Begin 
				set @Qrystr3 = @Qrystr3 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr3 = @Qrystr3 +@zdata_ty + LTrim(RTrim(@Fld_Nm))  +','
			end 

			--OSItem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'OS'+ltrim(rtrim(@tblname)) ))
			Begin 
				set @Qrystr4 = @Qrystr4 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr4 = @Qrystr4 +@zdata_ty + LTrim(RTrim(@Fld_Nm))  +','
			end 
			
			--Added by Shrikant S. on 02/10/2012 for bug-6416	--Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'SR'+ltrim(rtrim(@tblname)) ))
			Begin 
				set @Qrystr5 = @Qrystr5 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				--set @Qrystr5 = @Qrystr5 +' 0 as ' + LTrim(RTrim(@Fld_Nm))  +',' --Commented By Prajakta B. on 17012018 for Bug 31146
				set @Qrystr5 = @Qrystr5 +@zdata_ty + LTrim(RTrim(@Fld_Nm))  +','  --Added By Prajakta B. on 17012018 for Bug 31146
			end
			--Added by Shrikant S. on 02/10/2012 for bug-6416	--End

			--Added by Suraj K. on 09/01/2018 for Bug-31112		--Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'OP'+ltrim(rtrim(@tblname)) ))
			Begin 
				set @Qrystr6 = @Qrystr6 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr6 = @Qrystr6 +@zdata_ty + LTrim(RTrim(@Fld_Nm))  +','		
			end
			--Added by Suraj K. on 09/01/2018 for Bug-31112		--End

			--Added by Sachin N. S. on 23/05/2018 for Bug-31382		--Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'ES'+ltrim(rtrim(@tblname)) ))
			Begin 
				set @Qrystr7 = @Qrystr7 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr7 = @Qrystr7 +@zdata_ty + LTrim(RTrim(@Fld_Nm))  +','
			end
			--Added by Sachin N. S. on 23/05/2018 for Bug-31382		--End
			
	  END
      FETCH NEXT FROM lotherCur INTO @Fld_Nm,@Data_ty,@att_file;
  END

CLOSE lotherCur
DEALLOCATE lotherCur
--Birendra:Bug-5212 on 11/07/2012:End:Additional info fields:
--Birendra: Bug-9174 on 13/06/2013 :Start:
declare @zsqlfld varchar(255)
select @zsqlfld =''
--Birendra: Bug-9174 on 13/06/2013 :End:
	
DECLARE DcmastCur CURSOR FOR 
	Select distinct Fld_Nm,Pert_Name,att_file From Dcmast --Birendra : Bug-9174 on 18/06/2013
		Where Entry_Ty in ('PT','AR','P1','OS','SR','OP','ES','LR') AND stkval = 1		--Added by Shrikant S. on 13/09/2019 for Bug-32823
		--Where Entry_Ty in ('PT','AR','P1','OS','SR','OP','ES') AND stkval = 1		--Added by Sachin N. S. on 23/05/2018 for Bug-31382			--Commented by Shrikant S. on 13/09/2019 for Bug-32823
		--Where Entry_Ty in ('PT','AR','P1','OS','SR','OP') AND stkval = 1		--Added by Suraj Kumawat dat on 09-01-2018 for Bug-31112
		---Where Entry_Ty in ('PT','AR','P1','OS','SR') AND stkval = 1		--Commented by Suraj K. Date on 09-01-2018 for bug-31112
		-- Where Code in ('E','N') And Entry_Ty in ('PT','AR') AND Att_File = 0		-- Changed By Sachin N. S. on 08/11/2011 for Bug-150

OPEN DcmastCur

FETCH NEXT FROM DcmastCur INTO @Fld_Nm,@Pert_Name,@att_file

WHILE @@FETCH_STATUS = 0
   BEGIN
	  IF @Fld_Nm IS NOT NULL AND @Fld_Nm <> ''	
	  BEGIN	
		  SET @FldName = @FldName+'b.'+LTrim(RTrim(@Fld_Nm))+','
		--Birendra
			---PTITem
			set @tblname =case when @att_file=1 then 'MAIN' else 'ITEM' end --Birendra : Bug-9174 on 18/06/2013
			if exists(select b.[name] from syscolumns a join sysobjects b on a.id=b.id  where a.[name] = LTrim(RTrim(@Fld_Nm)) and b.[name] ='PT'+ltrim(rtrim(@tblname)))
			Begin 
				set @Qrystr1 = @Qrystr1 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
				if @att_file=1
				set @vouchrg = case when len(@vouchrg)>0 then @vouchrg+',' + LTrim(RTrim(@Fld_Nm)) +'=(('+LTrim(RTrim(@Fld_Nm))+'* qty * Rate)/Rateper)/asseamt1' else +LTrim(RTrim(@Fld_Nm)) +'=(('+LTrim(RTrim(@Fld_Nm))+'* qty * Rate)/Rateper)/asseamt1' end
			end
			else
			Begin
				set @Qrystr1 = @Qrystr1 +' 0 as ' + LTrim(RTrim(@Fld_Nm))  +','
			end 
			--IRItem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'IR'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr2 = @Qrystr2 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr2 = @Qrystr2 +' 0 as ' + LTrim(RTrim(@Fld_Nm))  +','
			end 
			--ARItem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'AR'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr3 = @Qrystr3 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr3 = @Qrystr3 +' 0 as ' + LTrim(RTrim(@Fld_Nm))  +','
			end 
--added by amrendra for FM Costing On 13/04/2011 --- Start

			--OSItem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'OS'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr4 = @Qrystr4 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr4 = @Qrystr4 +' 0 as ' + LTrim(RTrim(@Fld_Nm))  +','
			end 
--added by amrendra for FM Costing On 13/04/2011 --- End

		--end Birendra
			--Added by Shrikant S. on 02/10/2012 for bug-6416	--Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'SR'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr5 = @Qrystr5 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr5 = @Qrystr5 +' 0 as ' + LTrim(RTrim(@Fld_Nm))  +','
			end
			--Added by Shrikant S. on 02/10/2012 for bug-6416	--End
			
			--Added by Suraj K. on 09-01-2018 for Bug-31112	--Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'OP'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr6 = @Qrystr6 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr6 = @Qrystr6 +' 0 as ' + LTrim(RTrim(@Fld_Nm))  +','
			end
			--Added by Suraj K. on 09-01-2018 for Bug-31112	--End

			--Added by Sachin N. S. on 23/05/2018 for Bug-31382 --Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Fld_Nm)) and id in (select id from sysobjects where [name] = 'ES'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr7 = @Qrystr7 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Fld_Nm))  +','
			end
			else
			Begin
				set @Qrystr7 = @Qrystr7 +' 0 as ' + LTrim(RTrim(@Fld_Nm))  +','
			end
			--Added by Sachin N. S. on 23/05/2018 for Bug-31382 --End
			
	  END
	  IF @Pert_Name IS NOT NULL AND @Pert_Name <> ''	
	  BEGIN	
		  SET @FldPerName = @FldPerName+'b.'+LTrim(RTrim(@Pert_Name))+','
		--Birendra
			set @tblname =case when @att_file=1 then 'MAIN' else 'ITEM' end --Birendra : Bug-9174 on 18/06/2013
			---PTITem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Pert_Name)) and id in (select id from sysobjects where [name] ='PT'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr1 = @Qrystr1 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Pert_Name))  +','
			end
			else
			Begin
				set @Qrystr1 = @Qrystr1 +' 0 as ' + LTrim(RTrim(@Pert_Name))  +','
			end 
			--IRItem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Pert_Name)) and id in (select id from sysobjects where [name] ='IR'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr2 = @Qrystr2 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Pert_Name))  +','
			end
			else
			Begin
				set @Qrystr2 = @Qrystr2 +' 0 as ' + LTrim(RTrim(@Pert_Name))  +','
			end 
			--ARItem
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Pert_Name)) and id in (select id from sysobjects where [name] = 'AR'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr3 = @Qrystr3 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Pert_Name))  +','
			end
			else
			Begin
				set @Qrystr3 = @Qrystr3 +' 0 as ' + LTrim(RTrim(@Pert_Name))  +','
			end 
--added by amrendra for FM Costing On 13/04/2011 --- Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Pert_Name)) and id in (select id from sysobjects where [name] ='OS'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr4 = @Qrystr4 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Pert_Name))  +','
			end
			else
			Begin
				set @Qrystr4 = @Qrystr4 +' 0 as ' + LTrim(RTrim(@Pert_Name))  +','
			end 
--added by amrendra for FM Costing On 13/04/2011 --- end
		--end Birendra
			--Added by Shrikant S. on 02/10/2012 for bug-6416	--Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Pert_Name)) and id in (select id from sysobjects where [name] = 'SR'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr5 = @Qrystr5 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Pert_Name))  +','
			end
			else
			Begin
				set @Qrystr5 = @Qrystr5 +' 0 as ' + LTrim(RTrim(@Pert_Name))  +','
			end 
			--Added by Shrikant S. on 02/10/2012 for bug-6416	--End

			--Added by Suraj k. on 09/01/2018 for Bug-31112		--Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Pert_Name)) and id in (select id from sysobjects where [name] = 'OP'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr6 = @Qrystr6 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Pert_Name))  +','
			end
			else
			Begin
				set @Qrystr6 = @Qrystr6 +' 0 as ' + LTrim(RTrim(@Pert_Name))  +','
			end 
			--Added by Suraj k. on 09/01/2018 for Bug-31112		--End

			--Added by Sachin N. S. on 23/05/2018 for Bug-31382 --Start
			if exists(select * from syscolumns where [name] = LTrim(RTrim(@Pert_Name)) and id in (select id from sysobjects where [name] = 'ES'+ltrim(rtrim(@tblname))))
			Begin 
				set @Qrystr7 = @Qrystr7 +rtrim(left(@tblname,1))+'.'+ LTrim(RTrim(@Pert_Name))  +','
			end
			else
			Begin
				set @Qrystr7 = @Qrystr7 +' 0 as ' + LTrim(RTrim(@Pert_Name))  +','
			end 
			--Added by Sachin N. S. on 23/05/2018 for Bug-31382 --End			
	  END
      FETCH NEXT FROM DcmastCur INTO @Fld_Nm,@Pert_Name,@att_file;
  END

CLOSE DcmastCur
DEALLOCATE DcmastCur
DECLARE @Select as Bit,@SQLStr nVarchar(Max),
	@ParmDefinition nvarchar(500)

--Added by Priyanka B on 17012019 for Bug-31850 Start
DECLARE	@SQLStr_1 nVarchar(Max) 
set @SQLStr_1=''
--Added by Priyanka B on 17012019 for Bug-31850 End


--Birendra
SET @Qrystr1  = LEFT(LTrim(RTrim(@Qrystr1 )),Len(LTrim(RTrim(@Qrystr1 )))-1)
SET @Qrystr2  = LEFT(LTrim(RTrim(@Qrystr2 )),Len(LTrim(RTrim(@Qrystr2 )))-1)
SET @Qrystr3  = LEFT(LTrim(RTrim(@Qrystr3 )),Len(LTrim(RTrim(@Qrystr3 )))-1)
--added by amrendra for FM Costing On 13/04/2011 --- Start
SET @Qrystr4  = LEFT(LTrim(RTrim(@Qrystr4 )),Len(LTrim(RTrim(@Qrystr4 )))-1)
SET @Qrystr5  = LEFT(LTrim(RTrim(@Qrystr5 )),Len(LTrim(RTrim(@Qrystr5 )))-1)			--Added By Shrikant S. on 02/10/2012 for Bug-6416
SET @Qrystr6  = LEFT(LTrim(RTrim(@Qrystr6 )),Len(LTrim(RTrim(@Qrystr6 )))-1)			--Added By Suraj K. on 09/01/2018 for Bug-31112
SET @Qrystr7  = LEFT(LTrim(RTrim(@Qrystr7 )),Len(LTrim(RTrim(@Qrystr7 )))-1)			--Added by Sachin N. S. on 18/09/2018 for Bug-31382

--Birendra: Bug-9174 on 13/06/2013 :Start:

-- Added by Sachin N. S. on 18/09/2018 for Bug-31756 -- Start
;WITH qcRecords AS
(
	SELECT A.ENTRY_TY,A.Tran_cd,B.itserial,B.QCACEPTQTY AS QCACEPTQTY
		FROM QC_INSPECTION_MASTER A
			INNER JOIN QC_INSPECTION_ITEM B ON A.INSP_ID=B.INSP_ID 
	WHERE A.INSP_DATE<=@paraLcdate 
	UNION ALL
	SELECT A.ENTRY_TY,A.Tran_cd,A.itserial,A.QCACEPTQTY AS QCACEPTQTY
		FROM QCHISTORY A
	WHERE A.Qc_Dt<=@paraLcdate 
		
)
SELECT ENTRY_TY,Tran_cd,itserial,SUM(QCACEPTQTY) AS QCACEPTQTY into ##tmpQCRec FROM qcRecords
	GROUP BY ENTRY_TY,Tran_cd,itserial
-- Added by Sachin N. S. on 18/09/2018 for Bug-31756 -- End



-- Changed by Sachin N. S. on 08/09/2018 for Bug-31756 -- Start
--set @SQLStr = 'SELECT '+replace(replace(@Qrystr1,'I.',''),'M.','') +' into ##table2 FROM (select '+@Qrystr1+' from PTITEM I join ptmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no) Ptitem '
--set @SQLStr = @SQLStr+' UNION '
--set @SQLStr = @SQLStr+ ' Select '+replace(replace(@Qrystr2,'I.',''),'M.','') + ' FROM (select '+@Qrystr2+' from IRITEM I join IRmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no) IRitem '
--set @SQLStr = @SQLStr+' UNION '
--set @SQLStr = @SQLStr+ ' Select '+replace(replace(@Qrystr3,'I.',''),'M.','') + ' FROM (select '+@Qrystr3+' from ARITEM I join ARmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no) ARitem '
--set @SQLStr = @SQLStr+' UNION '
--set @SQLStr = @SQLStr+ ' Select '+replace(replace(@Qrystr4,'I.',''),'M.','') + ' FROM (select '+@Qrystr4+' from OSITEM I join OSmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no) OSitem '
--set @SQLStr = @SQLStr+' UNION '
--set @SQLStr = @SQLStr+ ' Select '+replace(replace(@Qrystr5,'I.',''),'M.','') + ' FROM (select '+@Qrystr5+' from SRITEM I join SRmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no) SRitem '
--set @SQLStr = @SQLStr+' UNION '				
--set @SQLStr = @SQLStr+ ' Select '+replace(replace(@Qrystr6,'I.',''),'M.','') + ' FROM (select '+@Qrystr6+' from OPITEM I join OPmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no) Opitem '	--Added By Suraj K. on 09/01/2018 for Bug-31112
--set @SQLStr = @SQLStr+' UNION '				
--set @SQLStr = @SQLStr+ ' Select '+replace(replace(@Qrystr7,'I.',''),'M.','') + ' FROM (select '+@Qrystr7+' from ESITEM I join ESmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no) ESitem '	--Added By Sachin N. S. on 23/05/2018 for Bug-31382

set @SQLStr = 'SELECT '+replace(replace(replace(@Qrystr1,'I.',''),'M.',''),'Q.','') +' into ##table2 FROM (select '+@Qrystr1+' from PTITEM I join ptmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no '+case when ltrim(rtrim(@paraLProd))='QC' then ' left join (select entry_ty,Tran_cd,itserial,QcAceptQty From ##tmpQCRec ) Q on Q.entry_ty=I.entry_ty and Q.Tran_cd=I.Tran_cd and q.itserial=i.itserial ' else '' end+') Ptitem '
set @SQLStr = @SQLStr+' UNION '
set @SQLStr = @SQLStr+ ' Select '+replace(replace(replace(@Qrystr2,'I.',''),'M.',''),'Q.','') + ' FROM (select '+@Qrystr2+' from IRITEM I join IRmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no '+case when ltrim(rtrim(@paraLProd))='QC' then ' left join (select entry_ty,Tran_cd,itserial,QcAceptQty From ##tmpQCRec ) Q on Q.entry_ty=I.entry_ty and Q.Tran_cd=I.Tran_cd and q.itserial=i.itserial ' else '' end+') IRitem '
set @SQLStr = @SQLStr+' UNION '
set @SQLStr = @SQLStr+ ' Select '+replace(replace(replace(@Qrystr3,'I.',''),'M.',''),'Q.','') + ' FROM (select '+@Qrystr3+' from ARITEM I join ARmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no '+case when ltrim(rtrim(@paraLProd))='QC' then ' left join (select entry_ty,Tran_cd,itserial,QcAceptQty From ##tmpQCRec ) Q on Q.entry_ty=I.entry_ty and Q.Tran_cd=I.Tran_cd and q.itserial=i.itserial ' else '' end+') ARitem '
set @SQLStr = @SQLStr+' UNION '
set @SQLStr = @SQLStr+ ' Select '+replace(replace(replace(@Qrystr4,'I.',''),'M.',''),'Q.','') + ' FROM (select '+@Qrystr4+' from OSITEM I join OSmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no '+case when ltrim(rtrim(@paraLProd))='QC' then ' left join (select entry_ty,Tran_cd,itserial,QcAceptQty From ##tmpQCRec ) Q on Q.entry_ty=I.entry_ty and Q.Tran_cd=I.Tran_cd and q.itserial=i.itserial ' else '' end+') OSitem '
set @SQLStr = @SQLStr+' UNION '
set @SQLStr = @SQLStr+ ' Select '+replace(replace(replace(@Qrystr5,'I.',''),'M.',''),'Q.','') + ' FROM (select '+@Qrystr5+' from SRITEM I join SRmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no '+case when ltrim(rtrim(@paraLProd))='QC' then ' left join (select entry_ty,Tran_cd,itserial,QcAceptQty From ##tmpQCRec ) Q on Q.entry_ty=I.entry_ty and Q.Tran_cd=I.Tran_cd and q.itserial=i.itserial ' else '' end+') SRitem '
set @SQLStr = @SQLStr+' UNION '				
set @SQLStr = @SQLStr+ ' Select '+replace(replace(replace(@Qrystr6,'I.',''),'M.',''),'Q.','') + ' FROM (select '+@Qrystr6+' from OPITEM I join OPmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no '+case when ltrim(rtrim(@paraLProd))='QC' then ' left join (select entry_ty,Tran_cd,itserial,QcAceptQty From ##tmpQCRec ) Q on Q.entry_ty=I.entry_ty and Q.Tran_cd=I.Tran_cd and q.itserial=i.itserial ' else '' end+') Opitem '	--Added By Suraj K. on 09/01/2018 for Bug-31112
set @SQLStr = @SQLStr+' UNION '						--Commented by Shrikant S. on 11/09/2018 for Installer 2.0.0 PRO		
set @SQLStr = @SQLStr+ ' Select '+replace(replace(replace(@Qrystr7,'I.',''),'M.',''),'Q.','') + ' FROM (select '+@Qrystr7+' from ESITEM I join ESmain M on I.tran_cd=M.tran_cd and I.entry_ty=M.entry_ty and I.date=M.date and I.inv_no=M.inv_no '+case when ltrim(rtrim(@paraLProd))='QC' then ' left join (select entry_ty,Tran_cd,itserial,QcAceptQty From ##tmpQCRec ) Q on Q.entry_ty=I.entry_ty and Q.Tran_cd=I.Tran_cd and q.itserial=i.itserial ' else '' end+') ESitem '	--Added By Sachin N. S. on 23/05/2018 for Bug-31382		--Commented by Shrikant S. on 11/09/2018 for Installer 2.0.0 PRO		

-- Changed by Sachin N. S. on 08/09/2018 for Bug-31756 -- End


--set @SQLStr = 'SELECT '+@Qrystr1 +' into ##table1 FROM PTITEM  UNION SELECT ' + @Qrystr2 + ' FROM IRITEM UNION SELECT 
--				'+ @Qrystr3+' FROM ARITEM UNION SELECT '+@Qrystr4 +' FROM OSITEM UNION SELECT '+@Qrystr5+' FROM SRITEM '		--Added By Shrikant S. on 02/10/2012 for Bug-6416	

--'+ @Qrystr3+' FROM ARITEM UNION SELECT '+@Qrystr4 +' FROM OSITEM'		--Commented By Shrikant S. on 02/10/2012 for Bug-6416	

--added by amrendra for FM Costing On 13/04/2011 --- End

--Commented by amrendra for FM Costing On 13/04/2011 --- Start
--set @SQLStr = 'SELECT '+@Qrystr1 +' into ##table1 FROM PTITEM UNION SELECT ' + @Qrystr2 + ' FROM IRITEM UNION SELECT 
--				'+ @Qrystr3+' FROM ARITEM'
--Commented by amrendra for FM Costing On 13/04/2011 --- End
print @SQLStr
EXECUTE sp_executesql @SQLStr

----select * from ##table2
print 'abc'

select a.*,asseamt1=(select sum(u_asseamt) from ##table2 b where b.tran_cd=a.tran_cd and b.entry_ty=a.entry_ty ),c.rateper into ##table1 from ##table2 a left join it_mast c on a.it_code=c.it_code   --Biru

if LEN(RTRIM(ltrim(@vouchrg)))>0
begin
	set @vouchrg=replace(@vouchrg,'asseamt1','(Case when asseamt1=0 then 1 else asseamt1 end)')			--Added by Shrikant S. on 09/12/2017 for Auto updater 13.0.5
	-----set @SQLStr = 'Update  ##table1 SET '+@vouchrg  --- Commented by Suraj K. for Bug-31112  Date on 09-01-2018
	set @SQLStr = 'Update  ##table1 SET '+@vouchrg+' Where asseamt1 > 0 '		--Added by Suraj K. for Bug-31112  Date on 09-01-2018
	EXECUTE sp_executesql @SQLStr
end

print @vouchrg
--Birendra: Bug-9174 on 13/06/2013 :End:
---Rup
--set @SQLStr = 'update a set a.taxamt=0  from ##table1 a inner join stax_mas b on (a.TAX_NAME=b.TAX_NAME AND a.ENTRY_TY=b.ENTRY_TY) and b.st_type=''LOCAL'' '
--EXECUTE sp_executesql @SQLStr
---

SET @FldName = LEFT(LTrim(RTrim(@FldName)),Len(LTrim(RTrim(@FldName)))-1)
SET @FldPerName = LEFT(LTrim(RTrim(@FldPerName)),Len(LTrim(RTrim(@FldPerName)))-1)

IF @FldName IS NOT NULL AND @FldName <> ''
BEGIN 
	IF @FldPerName IS NOT NULL AND @FldPerName <> ''
	BEGIN
		SELECT @FldName = LTrim(RTrim(@FldName))+','		
	END
END	

--DECLARE @Select as Bit,@SQLStr nVarchar(4000),
--	@ParmDefinition nvarchar(500)
print 'abc-1'

SELECT @Select = 0

SET @ParmDefinition = N'@Select Bit,@paraEntry_Ty Varchar(2),@paraTran_Cd Int,@paraLcrule varchar(20),@paraLcDate varchar(20)';
--SELECT @SQLStr = 'Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
--	a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
--	a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
--	a.u_beno,a.U_pinvdt,B.It_Code,a.Entry_Ty,a.Date,a.Doc_No,c.RItserial as Itserial,
--	c.REntry_Ty as _REntry_Ty,c.Itref_Tran as _Itref_Tran,c.RItserial as _RItserial,
--	Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
--	b.Itserial as RItserial,b.u_asseamt,b.Qty,b.rate,000000000.0000 As adjqty,
--	000000000.0000 As adjrepqty,b.Re_qty as RQty,b.Qty-b.Re_qty
--	- isnull((select y.rqty from othitref x left join eou_itref_vw y on x.rentry_ty=y.rentry_ty and x.itref_tran=y.itref_tran
--	where x.entry_ty = a.entry_ty and x.tran_cd=a.tran_cd and x.it_code= b.it_code and x.itserial=b.itserial),0)
--	- isnull((select x.rqty-b.Re_qty from othitref x 
--	where x.rentry_ty = a.entry_ty and x.itref_tran=a.tran_cd and x.it_code= b.it_code ),0)
--	As BalQty,
--	B.TAX_NAME,B.TAXAMT,' --Added by Birendra for fm costing
--select * from ##table1 --Birendra

--Birendra : AR and PT Both record come either pickup AR -  PT :Start: 

--SELECT @SQLStr = 'Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
--	a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
--	a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
--	a.u_beno,a.U_pinvdt,B.It_Code,a.Entry_Ty,a.Date,a.Doc_No,c.RItserial as Itserial,
--	c.REntry_Ty as _REntry_Ty,c.Itref_Tran as _Itref_Tran,c.RItserial as _RItserial,
--	Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
--	b.Itserial as RItserial,b.u_asseamt,b.Qty,b.rate,000000000.0000 As adjqty,
--	000000000.0000 As adjrepqty,isnull(c.rqty,0) as RQty,b.Qty-isnull(c.Rqty,0)	
--	- isnull((select sum(y.rqty) from othitref x left join eou_itref_vw y on x.rentry_ty=y.rentry_ty and x.itref_tran=y.itref_tran
--	where y.rentry_ty = a.entry_ty and y.itref_tran=a.tran_cd and x.it_code= b.it_code and y.ritserial=x.ritserial),0)
--	As BalQty,
--	B.TAX_NAME,B.TAXAMT,' --Added by Birendra for fm costing
if ltrim(rtrim(@paraLProd))='QC' and @QcEnabledItem=1 -- Added by Amrendra on 28/03/2012 for New QC
begin
--SELECT @SQLStr = 'set dateformat dmy Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
--	a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
--	a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
--	a.u_beno,a.U_pinvdt,B.It_Code,a.Entry_Ty,a.Date,a.Doc_No,c.RItserial as Itserial,
--	c.REntry_Ty as _REntry_Ty,c.Itref_Tran as _Itref_Tran,c.RItserial as _RItserial,
--	Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
--	b.Itserial as RItserial,b.u_asseamt,b.Qty ,b.rate,000000000.0000 As adjqty,
--	000000000.0000 As adjrepqty,isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) as RQty
--	,b.qcaceptQty-isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty  and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0)	
--	As BalQty,
--	B.TAX_NAME,B.TAXAMT,b.qcholdqty,b.qcaceptqty,b.qcrejqty,' --changedb.Qty ---to--->  b.QcAceptQty - Isnull....
--Birendra- Bug-5498 on 28/07/2012:start:

--Amrendra Bug-4973 03/12/2012 ---->
	if Upper(Rtrim(@ItemType))='RAW MATERIAL' and (@paraEntry_Ty='ST' or @paraEntry_Ty='DC')
	begin

		SELECT @SQLStr = 'set dateformat dmy Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
			a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
			a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
			a.u_beno,a.U_pinvdt,B.It_Code,c.Entry_Ty,c.Tran_cd,a.Date,a.Doc_No,c.Itserial,
			c.REntry_Ty as _REntry_Ty,c.Itref_Tran as _Itref_Tran,c.RItserial as _RItserial,
			Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
			b.Itserial as RItserial,b.u_asseamt,b.Qty ,b.rate,isnull((select Qty from ##table1 where 1=2),0) As adjqty,
			----isnull((select Qty from ##table1 where 1=2),0) As adjrepqty,isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) as RQty ---Commented by Suraj Kumawat date on 21-04-2017 for GST
			isnull((select Qty from ##table1 where 1=2),0) As adjrepqty,isnull((select sum(rqty) from othitref where entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) as RQty  --- Added by Suraj Kumawat date on 21-04-2017 for GST
			----,b.qcaceptQty-isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty  and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) + b.qcRejQty ----Commented by Suraj Kumawat date on 21-04-2017 for GST
			,b.qcaceptQty-isnull((select sum(rqty) from othitref where   entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty  and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) + b.qcRejQty --- Added by Suraj Kumawat date on 21-04-2017 for GST
			As BalQty,
			B.TAX_NAME,B.TAXAMT,b.qcholdqty,b.qcaceptqty,b.qcrejqty,b.lastqc_dt,'			-- Added by Pankaj B. on 21-06-2014 for Bug-22827 start
			--B.TAX_NAME,B.TAXAMT,b.qcholdqty,b.qcaceptqty,b.qcrejqty,' --changedb.Qty ---to--->  b.QcAceptQty - Isnull....			--Commented by Pankaj B. on 21-06-2014 for Bug-22827 start
	end
	else
	begin
--Amrendra Bug-4973 03/12/2012 <----

		SELECT @SQLStr = 'set dateformat dmy Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
			a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
			a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
			a.u_beno,a.U_pinvdt,B.It_Code,c.Entry_Ty,c.Tran_cd,a.Date,a.Doc_No,c.Itserial,
			c.REntry_Ty as _REntry_Ty,c.Itref_Tran as _Itref_Tran,c.RItserial as _RItserial,
			Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
			b.Itserial as RItserial,b.u_asseamt,b.Qty ,b.rate,isnull((select Qty from ##table1 where 1=2),0) As adjqty,
			---isnull((select Qty from ##table1 where 1=2),0) As adjrepqty,isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) as RQty ----Commented by Suraj Kumawat date on 21-04-2017 for GST
			isnull((select Qty from ##table1 where 1=2),0) As adjrepqty,isnull((select sum(rqty) from othitref where   entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) as RQty --- Added by Suraj Kumawat date on 21-04-2017 for GST
			---,b.qcaceptQty-isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty  and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0)	----Commented by Suraj Kumawat date on 21-04-2017 for GST
			,b.qcaceptQty-isnull((select sum(rqty) from othitref where  entry_ty not in(''GC'',''GD'') and  rentry_ty=b.entry_ty  and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0)	--- Added by Suraj Kumawat date on 21-04-2017 for GST
			As BalQty,
			B.TAX_NAME,B.TAXAMT,b.qcholdqty,b.qcaceptqty,b.qcrejqty,b.lastqc_dt,' -- Added by Pankaj B. on 21-06-2014 for Bug-22827 start
			--B.TAX_NAME,B.TAXAMT,b.qcholdqty,b.qcaceptqty,b.qcrejqty,' --changedb.Qty ---to--->  b.QcAceptQty - Isnull....		--Commented by Pankaj B. on 21-06-2014 for Bug-22827 start
			--a.u_beno,a.U_pinvdt,B.It_Code,a.Entry_Ty,a.Date,a.Doc_No,c.RItserial as Itserial,			---- Changed the line By Shrikant:Bug-5930, 5931 on 31/08/2012 from the above query for "Entry_ty,Tran_cd" field 
--Birendra- Bug-5498 on 28/07/2012:End:
	end 
end
else
begin
--Birendra : AR and PT Both record come either pickup AR -  PT :End: 

--SELECT @SQLStr = 'set dateformat dmy Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
--	a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
--	a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
--	a.u_beno,a.U_pinvdt,B.It_Code,a.Entry_Ty,a.Date,a.Doc_No,c.RItserial as Itserial,
--	c.REntry_Ty as _REntry_Ty,c.Itref_Tran as _Itref_Tran,c.RItserial as _RItserial,
--	Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
--	b.Itserial as RItserial,b.u_asseamt,b.Qty ,b.rate,000000000.0000 As adjqty,
--	000000000.0000 As adjrepqty,isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) as RQty
--	,b.Qty-isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty  and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0)	
--	As BalQty,
--	B.TAX_NAME,B.TAXAMT,' --Added by Birendra for fm costing
--Birendra- Bug-5498 on 28/07/2012:start:

--Added by Priyanka B on 17012019 for Bug-31850 Start
	If Upper(Rtrim(@ItemType))='FINISHED'
	Begin
	print '1'
		SELECT @SQLStr = 'set dateformat dmy Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
		a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
		a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
		a.u_beno,a.U_pinvdt,B.It_Code,c.Entry_ty ,c.Tran_cd,a.Date,a.Doc_No,c.Itserial ,
		c.AEntry_Ty as _REntry_Ty,c.ATran_cd as _Itref_Tran,c.AItserial as _RItserial,
		Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
		b.Itserial as RItserial,b.u_asseamt,b.Qty ,b.rate,isnull((select Qty from ##table1 where 1=2),0) As adjqty ,
		isnull((select Qty from ##table1 where 1=2),0) As adjrepqty
		,isnull((select isnull(sum(qty),0) from projectitref where  entry_ty not in(''GC'',''GD'') and aentry_ty=b.entry_ty and atran_cd = b.tran_cd and aitserial= b.itserial and it_code =  b.it_code)
		+ (select isnull(sum(rqty),0) from othitref where entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code)
		,0) as RQty
		,b.Qty-isnull((select isnull(sum(qty),0) from projectitref where  entry_ty not in(''GC'',''GD'') and aentry_ty=b.entry_ty  and atran_cd = b.tran_cd and aitserial= b.itserial and it_code =  b.it_code)
					+ (select isnull(sum(rqty),0) from othitref where entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code)
		,0)	As BalQty,B.TAX_NAME,B.TAXAMT,'

		SELECT @SQLStr_1 = 'Union all Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
		a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
		a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
		a.u_beno,a.U_pinvdt,B.It_Code,c.Entry_ty ,c.Tran_cd,a.Date,a.Doc_No,c.Itserial ,
		c.REntry_Ty as _REntry_Ty,c.Itref_Tran as _Itref_Tran,c.RItserial as _RItserial,
		Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
		b.Itserial as RItserial,b.u_asseamt,b.Qty ,b.rate,isnull((select Qty from ##table1 where 1=2),0) As adjqty ,
		isnull((select Qty from ##table1 where 1=2),0) As adjrepqty
		,isnull((select isnull(sum(qty),0) from projectitref where  entry_ty not in(''GC'',''GD'') and aentry_ty=b.entry_ty and atran_cd = b.tran_cd and aitserial= b.itserial and it_code =  b.it_code)
		+ (select isnull(sum(rqty),0) from othitref where entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code)
		,0) as RQty
		,b.Qty-isnull((select isnull(sum(qty),0) from projectitref where  entry_ty not in(''GC'',''GD'') and aentry_ty=b.entry_ty  and atran_cd = b.tran_cd and aitserial= b.itserial and it_code =  b.it_code)
					+ (select isnull(sum(rqty),0) from othitref where entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code)
		,0)	As BalQty,B.TAX_NAME,B.TAXAMT,'
	End
	Else
	Begin
	print '2'
	--Added by Priyanka B on 17012019 for Bug-31850 End

		SELECT @SQLStr = 'set dateformat dmy Select @Select as lSelect,a.Entry_Ty as REntry_Ty,
		a.Date as RDate,a.Doc_No as RDoc_no,b.Item_no,a.Inv_No as RInv_No,a.L_Yn as RL_Yn,
		a.Tran_cd as ITref_tran,a.Dept,a.Cate,a.[Rule],a.Inv_Sr as RInv_Sr,
		a.u_beno,a.U_pinvdt,B.It_Code,c.Entry_ty ,c.Tran_cd,a.Date,a.Doc_No,c.Itserial ,
		c.REntry_Ty as _REntry_Ty,c.Itref_Tran as _Itref_Tran,c.RItserial as _RItserial,
		Ac_Mast.Ac_Name as RParty_nm,It_Mast.It_Name as Item,Space(100) as litemkey,
		b.Itserial as RItserial,b.u_asseamt,b.Qty ,b.rate,isnull((select Qty from ##table1 where 1=2),0) As adjqty ,
		---isnull((select Qty from ##table1 where 1=2),0) As adjrepqty,isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) as RQty ----Commented by Suraj Kumawat date on 21-04-2017 for GST
		isnull((select Qty from ##table1 where 1=2),0) As adjrepqty,isnull((select sum(rqty) from othitref where  entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0) as RQty --- Added by Suraj Kumawat date on 21-04-2017 for GST
		---,b.Qty-isnull((select sum(rqty) from othitref where rentry_ty=b.entry_ty  and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0)	----Commented by Suraj Kumawat date on 21-04-2017 for GST
		,b.Qty-isnull((select sum(rqty) from othitref where  entry_ty not in(''GC'',''GD'') and rentry_ty=b.entry_ty  and itref_tran = b.tran_cd and ritserial= b.itserial and it_code =  b.it_code),0)	 --- Added by Suraj Kumawat date on 21-04-2017 for GST
		As BalQty,
		B.TAX_NAME,B.TAXAMT,' --Added by Birendra for fm costing
		--a.u_beno,a.U_pinvdt,B.It_Code,a.Entry_Ty,a.Date,a.Doc_No,c.RItserial as Itserial,				---- Changed the line By Shrikant:Bug-5930, 5931 on 31/08/2012 from the above query for "Entry_ty,Tran_cd" field 
--Birendra- Bug-5498 on 28/07/2012:End:
	End  --Added by Priyanka B on 17012019 for Bug-31850

end

IF @FldName = '' AND @FldPerName = ''
	BEGIN 
		SET @SQLStr = LEFT(LTrim(RTrim(@SQLStr)),Len(LTrim(RTrim(@SQLStr)))-1)
		--Added by Priyanka B on 17012019 for Bug-31850 Start
		If Upper(Rtrim(@ItemType))='FINISHED'
		Begin
			SET @SQLStr_1 = LEFT(LTrim(RTrim(@SQLStr_1)),Len(LTrim(RTrim(@SQLStr_1)))-1) 
		End
		--Added by Priyanka B on 17012019 for Bug-31850 End
	END	
ELSE
	BEGIN
		SELECT @SQLStr = @SQLStr+@FldName+@FldPerName
		--Added by Priyanka B on 17012019 for Bug-31850 Start
		If Upper(Rtrim(@ItemType))='FINISHED'
		Begin
			SELECT @SQLStr_1 = @SQLStr_1+@FldName+@FldPerName  
		End
		--Added by Priyanka B on 17012019 for Bug-31850 End
	END

-- Birendra : Bug-845 on 19/12/2011 :Start:
--select itref_tran into ##tableitref from eou_itref_vw where entry_ty in ('PT','OS','AR','P1') and tran_cd not in ( select itref_tran from eou_itref_vw where entry_ty in ('PT','OS','AR','P1'))
--select  case when exists(select itref_tran from othitref where rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial) then tran_cd else itref_tran end as itref_tran
-- into ##tableitref from eou_itref_vw where entry_ty in ('PT','OS','AR','P1') and tran_cd not in ( select itref_tran from eou_itref_vw where entry_ty in ('PT','OS','AR','P1'))
select  
		--- case when exists(select itref_tran from othitref where rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial)  ----Commented by Suraj Kumawat date on 21-04-2017 for GST
		case when exists(select itref_tran from othitref where  entry_ty not in('GC','GD') and rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial)  ---Added by Suraj Kumawat date on 21-04-2017 for GST
		or exists(select tran_cd from ##table1 where entry_ty=eou_itref_vw.rentry_ty and tran_cd=eou_itref_vw.itref_tran and itserial=eou_itref_vw.ritserial and qty<>eou_itref_vw.rqty)
		then tran_cd else itref_tran end as itref_tran
--Birendra : Bug-4124 on 17/05/2012:Start:
		,
		---case when exists(select itref_tran from othitref where rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial) ----Commented by Suraj Kumawat date on 21-04-2017 for GST
		  case when exists(select itref_tran from othitref where  entry_ty not in('GC','GD') and rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial) ----- Added by Suraj Kumawat date on 21-04-2017 for GST
		or exists(select tran_cd from ##table1 where entry_ty=eou_itref_vw.rentry_ty and tran_cd=eou_itref_vw.itref_tran and itserial=eou_itref_vw.ritserial and qty<>eou_itref_vw.rqty)
		then entry_ty else rentry_ty end as entry_ty
		--Added By Shrikant S. on 02/10/2012 for Bug-6362		--Start
		----,case when exists(select itref_tran from othitref where rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial)----Commented by Suraj Kumawat date on 21-04-2017 for GST
		,case when exists(select itref_tran from othitref where  entry_ty not in('GC','GD') and rentry_ty=eou_itref_vw.rentry_ty and itref_tran=eou_itref_vw.itref_tran and ritserial=eou_itref_vw.ritserial)--- Added by Suraj Kumawat date on 21-04-2017 for GST
		or exists(select tran_cd from ##table1 where entry_ty=eou_itref_vw.rentry_ty and tran_cd=eou_itref_vw.itref_tran and itserial=eou_itref_vw.ritserial and qty<>eou_itref_vw.rqty)
		then Itserial else RItserial end as Itserial		
		,eou_itref_vw.rEntry_ty,eou_itref_vw.Itref_tran as RTran_Cd,eou_itref_vw.Ritserial			
		--Added By Shrikant S. on 02/10/2012 for Bug-6362		--End
--Birendra : Bug-4124 on 17/05/2012:End:
 ---- into ##tableitref from eou_itref_vw where entry_ty in ('PT','OS','AR','P1','SR') and tran_cd not in ( select itref_tran from eou_itref_vw where entry_ty in ('PT','OS','AR','P1','SR'))		----Commented by Suraj K. on 09/01/2018 for Bug-31112
 ----Added by Suraj K. on 09/01/2018 for Bug-31112 Start
 into ##tableitref from eou_itref_vw where entry_ty in ('PT','OS','AR','P1','SR','OP','ES','LR')		--Added by Shrikant S. on 13/09/2019 for Bug-32823
 --into ##tableitref from eou_itref_vw where entry_ty in ('PT','OS','AR','P1','SR','OP','ES')		-- Changed by Sachin N. S. on 23/05/2018 for Bug-31382		--Commented by Shrikant S. on 13/09/2019 for Bug-32823
	and Entry_ty+convert(varchar(10),tran_cd) not in ( select rentry_ty+convert(varchar(10),itref_tran) from eou_itref_vw 
	where entry_ty in ('PT','OS','AR','P1','SR','OP','ES') )	-- Changed by Sachin N. S. on 23/05/2018 for Bug-31382
----Added by Suraj K. on 09/01/2018 for Bug-31112 End

--select tran_cd into ##tableitref from eou_itref_vw where entry_ty in ('PT','OS','AR','P1') and tran_cd not in ( select itref_tran from eou_itref_vw where entry_ty in ('PT','OS','AR','P1'))

----select * from ##tableitref
-- Birendra : Bug-845 on 19/12/2011 :End:
--SELECT @SQLStr = @SQLStr+' From AC_Mast,IT_Mast,EOU_LMain_vw a,EOU_LItem_vw b

--SELECT @SQLStr = @SQLStr+' into ##tableitref1  From AC_Mast,IT_Mast,EOU_LMain_vw a,##table1 b		----Changed By Shrikant S. on 02/10/2012 for Bug-6362		

--Added by Priyanka B on 17012019 for Bug-31850 Start
	If Upper(Rtrim(@ItemType))='FINISHED'
	Begin

		SELECT @SQLStr = @SQLStr+' into ##tableitref1  From AC_Mast,IT_Mast,EOU_LMain_vw a,##table1 b		
		Left Join projectitref c ON (B.Entry_Ty = C.AEntry_Ty AND B.Tran_cd = C.ATran_cd AND B.Itserial = C.AItserial ) 
		WHERE a.Entry_Ty = B.Entry_Ty AND a.Tran_cd = b.Tran_cd 
		AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'',''P1'',''SR'',''OP'',''RL'',''MR'',''ES'',''LR'') and a.[Rule] = @paraLcrule			--Added by Shrikant S. on 13/09/2019 for Bug-32823
		--AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'',''P1'',''SR'',''OP'',''RL'',''MR'',''ES'') and a.[Rule] = @paraLcrule			--Commented by Shrikant S. on 13/09/2019 for Bug-32823
		And a.Date<= '''+@paraLcDate+'''
		And (a.Date>= '''+@itempickdt+''' or a.entry_ty=''OS'')
		AND A.Ac_Id = Ac_Mast.Ac_Id 
		and a.tran_cd not in (select ITREF_Tran  from ##tableitref where entry_ty=a.entry_ty ) '

		SELECT @SQLStr_1 = @SQLStr_1+' From AC_Mast,IT_Mast,EOU_LMain_vw a,##table1 b		
		inner Join othitref c ON (B.Entry_Ty = C.REntry_Ty AND B.Tran_cd = C.Itref_Tran AND B.Itserial = C.RItserial ) 
		WHERE a.Entry_Ty = B.Entry_Ty AND a.Tran_cd = b.Tran_cd 
		--AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'',''P1'',''SR'',''OP'',''RL'',''MR'',''ES'') and a.[Rule] = @paraLcrule			--Commented by Shrikant S. on 13/09/2019 for Bug-32823
		AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'',''P1'',''SR'',''OP'',''RL'',''MR'',''ES'',''LR'') and a.[Rule] = @paraLcrule			--Added by Shrikant S. on 13/09/2019 for Bug-32823
		And a.Date<= '''+@paraLcDate+'''
		And (a.Date>= '''+@itempickdt+''' or a.entry_ty=''OS'')
		AND A.Ac_Id = Ac_Mast.Ac_Id 
		and a.tran_cd not in (select ITREF_Tran  from ##tableitref where entry_ty=a.entry_ty ) '
	End
	Else
	Begin
	--Added by Priyanka B on 17012019 for Bug-31850 End

		SELECT @SQLStr = @SQLStr+' into ##tableitref1  From AC_Mast,IT_Mast,EOU_LMain_vw a,##table1 b		
		Left Join othitref c ON (B.Entry_Ty = C.REntry_Ty AND B.Tran_cd = C.ITREF_Tran 
		AND B.Itserial = C.RItserial ) 
		WHERE a.Entry_Ty = B.Entry_Ty AND a.Tran_cd = b.Tran_cd 
		----AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'',''P1'',''SR'',''ES'') and a.[Rule] = @paraLcrule --- Commented by Suraj Kumawat for GST Date on 26-05-2017
		----AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'',''P1'',''SR'',''RL'',''ES'') and a.[Rule] = @paraLcrule --- Commented by Suraj Kumawat for Bug-3112 Date on 09-01-2018
		--AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'',''P1'',''SR'',''OP'',''RL'',''MR'',''ES'') and a.[Rule] = @paraLcrule  --- Added by Suraj K. for Bug-3112 Date on 09-01-2018		--Commented by Shrikant S. on 13/09/2019 for Bug-32823
		AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'',''P1'',''SR'',''OP'',''RL'',''MR'',''ES'',''LR'') and a.[Rule] = @paraLcrule  --- Added by Suraj K. for Bug-3112 Date on 09-01-2018		--Added by Shrikant S. on 13/09/2019 for Bug-32823
		And a.Date<= '''+@paraLcDate+'''
		And (a.Date>= '''+@itempickdt+''' or a.entry_ty=''OS'')
		AND A.Ac_Id = Ac_Mast.Ac_Id 
		and a.tran_cd not in (select ITREF_Tran  from ##tableitref where entry_ty=a.entry_ty ) ' --Birendra : Bug-4124 on 17/05/2012
	End  --Added by Priyanka B on 17012019 for Bug-31850

  --AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'',''P1'') and a.[Rule] = @paraLcrule	--Commented By Shrikant S. on 02/10/2012 for Bug-6416 from above query
--Birendra:Bug-5371 on 26/07/2012:"item pickup from date" taken from manufact table(field itempickdt):	And (a.Date>= '''+@itempickdt+''' or a.entry_ty=''OS''):
-- Birendra : Bug-4106 on 18/05/2012 :Added '	And a.Date<= @paraLcDate' condition for date filteration in where clouse:
--	and a.tran_cd not in (select ITREF_Tran  from ##tableitref) '--Birendra : for Bug-845 on 19 DEc 2011 
--	and a.tran_cd not in  (select x.tran_cd from eou_itref_vw x join eou_itref_vw y on x.entry_ty=y.rentry_ty and x.tran_cd = y.itref_tran and x.itserial=y.ritserial where x.rentry_ty=a.entry_ty and x.itref_tran = a.tran_cd)'
-- Birendra : Bug-845 on 08/12/2011 
--	and a.tran_cd not in (select tran_cd from eou_itref_vw where entry_ty=a.entry_ty and tran_cd = a.tran_cd) '--Birendra : 27 may 2011 

--AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'') and a.[Rule] = @paraLcrule -- Changed By Sachin N. S. on 08/11/2011 for Bug-150

--AND c.Entry_Ty +Convert(Varchar(15),c.Tran_cd) <> @paraEntry_Ty+Convert(Varchar(15),@paraTran_Cd)
--Birendra :27 May 2011 :Start:
--SELECT @SQLStr = @SQLStr+' From AC_Mast,IT_Mast,EOU_LMain_vw a,##table1 b
--	Left Join Othitref c ON (B.Entry_Ty = C.REntry_Ty AND B.Tran_cd = C.ITREF_Tran
--	AND B.Itserial = C.RItserial AND c.Entry_Ty +Convert(Varchar(15),c.Tran_cd) <> @paraEntry_Ty+Convert(Varchar(15),@paraTran_Cd)) 
--	WHERE a.Entry_Ty = B.Entry_Ty AND a.Tran_cd = b.Tran_cd
--	AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'',''AR'') and a.[Rule] = @paraLcrule
--	AND A.Ac_Id = Ac_Mast.Ac_Id '
-- AND B.It_Code = It_Mast.It_Code AND A.Entry_Ty In (''PT'',''OS'') and a.[Rule] = @paraLcrule  --Replaced this line above by Amrendra on 25/04/2011 For FM Costing
--Birendra : 27 may 2011 :End:


	If RTrim(@paraCDept) <> ''
	Begin
		SELECT @SQLStr = @SQLStr+'AND I.Dept = '+Char(39)+RTrim(@paraCDept)+Char(39)
		--Added by Priyanka B on 17012019 for Bug-31850 Start
		If Upper(Rtrim(@ItemType))='FINISHED'
		Begin
			SELECT @SQLStr_1 = @SQLStr_1+'AND I.Dept = '+Char(39)+RTrim(@paraCDept)+Char(39)
		End
		--Added by Priyanka B on 17012019 for Bug-31850 End
	End

	if rtrim(@parawarenm)<>''
	Begin
		SELECT @SQLStr = @SQLStr+'AND b.ware_nm = '+Char(39)+RTrim(@parawarenm)+Char(39)
		--Added by Priyanka B on 17012019 for Bug-31850 Start
		If Upper(Rtrim(@ItemType))='FINISHED'
		Begin
			SELECT @SQLStr_1 = @SQLStr_1+'AND b.ware_nm = '+Char(39)+RTrim(@parawarenm)+Char(39)
		End
		--Added by Priyanka B on 17012019 for Bug-31850 End
	End
	
	If RTrim(@paraIt_name) <> ''
	Begin
--		SELECT @SQLStr = @SQLStr+'AND It_Mast.It_name = '+Char(39)+RTrim(@paraIt_name)+Char(39)
-- Birendra : Bug-9167 on 10/06/2013 :Modified as per below:
		SELECT @SQLStr = @SQLStr+'AND It_Mast.It_code = '+Char(39)+RTrim(@paraIt_name)+Char(39)
		--Added by Priyanka B on 17012019 for Bug-31850 Start
		If Upper(Rtrim(@ItemType))='FINISHED'
		Begin
			SELECT @SQLStr_1 = @SQLStr_1+'AND It_Mast.It_code = '+Char(39)+RTrim(@paraIt_name)+Char(39)
		End
		--Added by Priyanka B on 17012019 for Bug-31850 End
	End

--SELECT @SQLStr = @SQLStr+' order by a.date' --Birendra : Bug-4106 on 18/05/2012  --Commented by Priyanka B on 17012019 for Bug-31850
SELECT @SQLStr = @SQLStr+char(13)+@SQLStr_1+' order by a.date' --Birendra : Bug-4106 on 18/05/2012  --Modified by Priyanka B on 17012019 for Bug-31850
print @sqlstr
print @paraLcrule
EXECUTE sp_executesql @SQLStr , @ParmDefinition,@Select = @Select,	@paraTran_Cd = @paraTran_Cd,@paraEntry_Ty = @paraEntry_Ty, @paraLcrule = @paraLcrule,@paraLcdate = @paraLcdate


--Added by Shrikant S. on 02/10/2012 for Bug-6362	--Start

select a.*,refEntry_ty=b.Rentry_ty,refTran_cd=b.RTran_cd,refItserial=b.ritserial Into ##tableitref2 from ##tableitref1 a
	Inner join ##tableitref b on (a.rentry_ty=b.Entry_ty and a.itref_tran=b.Itref_Tran and a.rItserial=b.Itserial)
Declare @fldList Varchar(4000)	
--Select @fldList=isnull(substring((Select Distinct ', ' +Rtrim(Fld_nm)+'=sum('+Rtrim(Fld_nm)+')' From Dcmast Where Entry_ty In ('PT','AR','P1','OS','SR') AND Att_File = 0 For XML Path('')),1,2000),'')
--Birendra: Bug-9174 on 13/06/2013
---Select @fldList=isnull(substring((Select Distinct ', ' +Rtrim(Fld_nm)+'=sum('+Rtrim(Fld_nm)+')' From Dcmast Where Entry_ty In ('PT','AR','P1','OS','SR') and stkval=1  For XML Path('')),1,2000),'') --Commented by Suraj K. date on 09-01-2018 for Bug-31112
--Select @fldList=isnull(substring((Select Distinct ', ' +Rtrim(Fld_nm)+'=sum('+Rtrim(Fld_nm)+')' From Dcmast Where Entry_ty In ('PT','AR','P1','OS','SR','OP') and stkval=1  For XML Path('')),1,2000),'') --Added by Suraj K. date on 09-01-2018 for Bug-31112
Select @fldList=isnull(substring((Select Distinct ', ' +Rtrim(Fld_nm)+'=sum('+Rtrim(Fld_nm)+')' From Dcmast Where Entry_ty In ('PT','AR','P1','OS','SR','OP','ES','LR') and stkval=1  For XML Path('')),1,2000),'')			--Added by Shrikant S. on 13/09/2019 for Bug-32823
--Select @fldList=isnull(substring((Select Distinct ', ' +Rtrim(Fld_nm)+'=sum('+Rtrim(Fld_nm)+')' From Dcmast Where Entry_ty In ('PT','AR','P1','OS','SR','OP','ES') and stkval=1  For XML Path('')),1,2000),'') --Changed by Sachin N. S. on 23/05/2018 for Bug-31382			--Commented by Shrikant S. on 13/09/2019 for Bug-32823
set @fldList=case when @fldList is null then '' else @fldList End
if @fldList<>''
Begin
	set @SQLStr='Select refEntry_ty,RefTran_cd,refItserial,u_asseamt=sum(u_asseamt),refqty=Sum(qty),Taxamt=sum(taxamt) '+@fldList+' Into ##tableitref3 from ##tableitref2 '
	set @SQLStr=@SQLStr+' '+'Group by refEntry_ty,RefTran_cd,refItserial'
	print @SQLStr
	EXECUTE sp_executesql @SQLStr 
end
set @SQLStr=''
Select @fldList=isnull(substring((Select ', '+Rtrim(sc.[Name])+'=isnull(b.'+Rtrim(sc.[Name])+',0)' From tempdb..syscolumns sc inner join tempdb..sysobjects so on sc.id = so.id where so.[name] = '##tableitref3' and sc.[Name] Not In ('refEntry_ty','RefTran_cd','refItserial','refQty') For XML Path('')),2,2000),'')
set @fldList=case when @fldList is null then '' else @fldList end
print @fldList
if @fldList<>''
Begin
	set @SQLStr='Update ##tableitref1 Set '+@fldList+' from ##tableitref3 b Inner join ##tableitref1 a on (a.rentry_ty=b.refEntry_ty and a.Itref_tran=b.refTran_cd and a.rItserial=b.refItserial)'
	set @SQLStr=@SQLStr+' '+'where a.rentry_ty+cast(a.itref_tran as varchar(10))+a.ritserial Not in (select rentry_ty+cast(itref_tran as varchar(10))+ritserial  from ##tableitref ) 	'
	print @SQLStr
	EXECUTE sp_executesql @SQLStr 
End

-- Added by Pankaj B. on 21-06-2014 for Bug-22827 start
if ltrim(rtrim(@paraLProd))='QC' and @QcEnabledItem=1
begin
set @SQLStr='set dateformat DMY delete from ##tableitref1 where lastqc_dt >'+CHAR(39)+CAST(@paraLcDate AS VARCHAR)+CHAR(39)+''
print @SQLStr
EXECUTE sp_executesql @SQLStr 
end


--update ##tableitref1 set balqty = (balqty -(select isnull(sum(b.rqty),0) from uLitref b where b.rentry_ty =##tableitref1.rentry_ty and b.itref_tran =##tableitref1.itref_tran and ##tableitref1.rItserial=b.rItserial )) --- added by suraj Kumawat date on 21-04-2017 for GST  --Commented by Priyanka B on 17012019 for Bug-31850

--added for Bug-31120		--Start
IF @paraLcrule='ANNEXURE V'
begin
	
	Select qty_used=sum(qty_used),lientry_ty,li_tran_cd,li_itser Into #tmpref From iirmdet Group by lientry_ty,li_tran_cd,li_itser

	update ##tableitref1 set balqty = (balqty -B.qty_used) from ##tableitref1 A, #tmpref B Where A.rEntry_ty=B.lientry_ty AND 
				A.Itref_tran=B.li_tran_cd AND A.ritserial=B.li_itser AND A.rEntry_ty='RL'
	
	--select * from ##tableitref1 where Not(Isnull(Entry_ty,0)=@paraEntry_Ty and isnull(Tran_cd,0)=@paraTran_Cd)
	
	Delete From ##tableitref1 Where balqty=0 AND rEntry_ty='RL' and Not(Isnull(Entry_ty,0)=@paraEntry_Ty and isnull(Tran_cd,0)=@paraTran_Cd)
	
End
--added for Bug-31120		--End

Update ##tableitref1 set Entry_ty=Isnull(Entry_ty,''),tran_cd=Isnull(tran_cd,0),Itserial=Isnull(Itserial,'')		--Added by Shrikant S. on 13/09/2019 for Bug-32823

-- Added by Pankaj B. on 21-06-2014 for Bug-22827 End
select a.*,b.refQty from ##tableitref1 a
	left Join ##tableitref3 b on (b.refEntry_ty=a.Rentry_ty and b.refTran_cd=a.itref_tran and b.refItserial=a.rItserial)
	where rentry_ty+cast(itref_tran as varchar(10))+ritserial not in (select entry_ty+cast(itref_tran as varchar(10))+itserial  from ##tableitref ) 		--vasant
	
--Added by Shrikant S. on 02/10/2012 for Bug-6362	--End

drop table ##table1
drop table ##table2
drop table ##tableitref
drop table ##tableitref1		--Added by Shrikant S. on 02/10/2012 for Bug-6362	
drop table ##tableitref2		--Added by Shrikant S. on 02/10/2012 for Bug-6362	
drop table ##tableitref3		--Added by Shrikant S. on 02/10/2012 for Bug-6362	
drop table ##tmpQCRec  --Added by Priyanka B on 17012019 for Bug-31850