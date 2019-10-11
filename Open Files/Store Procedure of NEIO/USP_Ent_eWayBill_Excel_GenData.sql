IF EXISTS(SELECT * FROM SYSOBJECTS WHERE TYPE = 'P' AND name ='USP_Ent_eWayBill_Excel_GenData')
BEGIN
	DROP PROCEDURE USP_Ent_eWayBill_Excel_GenData
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:Suraj Kumawat
-- Create date: 02/02/2018
-- Description:	This Stored procedure is useful for eWayBill Excel Data Generation Screen
-- Modify By/date/Reason: 
-- Remark:
-- =============================================
CREate  Procedure [dbo].[USP_Ent_eWayBill_Excel_GenData]
(
	@Bcode_nm varchar(2),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME,@FromInv varchar(30),@ToInv varchar(30)
)
As
Begin
    declare @OrgCode varchar(20), @SqlCommand nvarchar(4000)
    set @OrgCode = (select TOP 1 ISNULL(GSTIN,'') from vudyog..co_mast where dbname=dbname)
	Select sel=cast(0 as bit) ,DATE=Cast(0 as SMALLDATETIME),Entry_Ty='ST',SuppTyp=cast('' as varchar(20)),SubTyp=cast('' as varchar(20)),DocTyp=cast('' as varchar(20)),DocNo=cast('' as varchar(20)),DocDt=cast('' as varchar(20)),OrgCode=cast('' as varchar(25)),PartyCode=cast('' as varchar(100))
	,LgNm=cast('' as varchar(100)),ConCity=cast('' as varchar(20)),	ConState=cast('' as varchar(30))
	,LgADD = cast('' as varchar(250)),LgGstin = cast('' as varchar(15)),LgArea = cast('' as varchar(15)),LgpinCode = cast('' as varchar(15))
	,TranDocNo=cast('' as varchar(20)),	TranDocDt=cast('' as varchar(20)),TranMode=cast('' as varchar(10)),AproxDis=cast('' as varchar(100))
	,eWAYN=cast('' as varchar(20)),eWAYDt=cast('' as varchar(20))
	,Product=cast('' as varchar(250)),ProdDesc=cast('' as varchar(250)),HSN=cast('' as varchar(25)),Unit=cast('' as varchar(30)),qty=cast('' as decimal(18,2))
	,AssValue=cast('' as decimal(18,2)),TaxRate=cast('' as decimal(18,2)),CessAmt=cast('' as decimal(18,2)),U_deli=cast('' as varchar(50)),Trans_id=cast('' as varchar(25)),U_vehno=cast('' as varchar(25))
	,Remark1=cast('' as varchar(250)),Remark2=cast('' as varchar(250))
	,ConEmail=cast('' as varchar(70)),CessRate=cast('' as varchar(70)),IGST_AMT=CAST(0.00 as decimal(18,2)),CGST_AMT=CAST(0.00 as decimal(18,2))
	,SGST_AMT=CAST(0.00 as decimal(18,2)),CESS_AMT=CAST(0.00 as decimal(18,2)),TranEmail =CAST('' AS VARCHAR(70)),itemid =CAST(0 as int)
	,DFadd1=cast('' as varchar(50)),DFadd2=cast('' as varchar(50)),DFPlace=cast('' as varchar(50)),DFPin=cast('' as varchar(50)),DFstate=cast('' as varchar(50))
	,STadd1=cast('' as varchar(50)),STadd2=cast('' as varchar(50)),STPlace=cast('' as varchar(50)),STPin=cast('' as varchar(50)),STstate=cast('' as varchar(50))
	,TOCargo=cast('' as varchar(50)),SubTypDes=cast('' as varchar(100)),Tot_AMT=CAST(0.00 as decimal(18,2))
	into #eWayBillExcel where 1=2
	if (@Bcode_nm in ('ST','EI',''))
	BEGIN
		Set @SqlCommand= ''
		Set @SqlCommand='Insert into #eWayBillExcel' 
		--Set @SqlCommand=@SqlCommand+' Select sel= 1, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Outward'',SubTyp=isnull(sm.EWBSUPTYP,''''),DocTyp=''Tax Invoice'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,105) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Commented by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' Select sel= 0, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Outward'',SubTyp=isnull(sm.EWBSUPTYP,''''),DocTyp=''Tax Invoice'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,103) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Modified by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+'  ,PartyCode ='''''
		Set @SqlCommand=@SqlCommand+' ,LgNm=case WHEN isnull(m.scons_id, 0) > 0 THEN  (CASE WHEN ISNULL(SH.MAILNAME,'''') = '''' THEN  Acm.Ac_Name ELSE SH.MAILNAME END ) ELSE AC.AC_NAME END '
		Set @SqlCommand=@SqlCommand+' ,ConCity=case WHEN isnull(m.scons_id, 0) > 0 THEN sh.City ELSE AC.City END '
		Set @SqlCommand=@SqlCommand+',ConState=case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.[state] ELSE AC.[state] END'
		Set @SqlCommand=@SqlCommand+',LgADD = case WHEN isnull(m.scons_id, 0) > 0 THEN  RTRIM(LTRIM(ISNULL(SH.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD3,''''))) ELSE RTRIM(LTRIM(ISNULL(AC.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD3,'''')))  END '
		Set @SqlCommand=@SqlCommand+',LgGstin = case WHEN isnull(m.scons_id, 0) > 0 THEN  Case when  sh.gstin in('''',''Unregistered'') THEN '''' ELSE SH.GSTIN END  ELSE (Case when  AC.gstin in('''',''Unregistered'') THEN '''' ELSE AC.GSTIN END) END '
		Set @SqlCommand=@SqlCommand+' ,LgArea = case WHEN isnull(m.scons_id, 0) > 0 THEN sh.area ELSE AC.AREA END '
		Set @SqlCommand=@SqlCommand+' ,LgpinCode =  case WHEN isnull(m.scons_id, 0) > 0 THEN sh.zip ELSE AC.zip END '
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=case when  year(m.U_LrDt) > 2000 then convert(varchar(11),m.U_LrDt,103)else '''' end ,TranMode=m.u_tMode,AproxDis= isnull(sm.EWBDIST,0)'
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=case when  year(m.EWBDt) > 2000 then convert(varchar(11),m.EWBDt,103)else '''' end'
		Set @SqlCommand=@SqlCommand+' ,Product=it.it_name,ProdDesc=cast(it.it_desc as varchar(250)),HSN=it.hsncode,Unit=IT.S_UNIT,qty=D.QTY'
		Set @SqlCommand=@SqlCommand+' ,AssValue=D.u_asseamt,TaxRate=(case when (isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)) = 0 then d.gstrate else (isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)) end ),CessAmt=d.compcess'
		Set @SqlCommand=@SqlCommand+' ,m.u_deli,m.trans_id,m.u_vehno ,Remark1='''',Remark2='''''
		Set @SqlCommand=@SqlCommand+' ,ConEmail =(case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.email ELSE AC.email END) '
		Set @SqlCommand=@SqlCommand+' ,CessRate = '''',IGST_AMT=isnull(d.igst_amt,0),CGST_AMT=isnull(d.cgst_amt,0),sGST_AMT=isnull(d.sgst_amt,0),Cess_AMT=isnull(d.compcess,0),TranEmail = isnull(sm.TranEmail,''''),itemid =d.item_no'
		
		Set @SqlCommand=@SqlCommand+',DFadd1=isnull(lm.add1,'''')'
		Set @SqlCommand=@SqlCommand+',DFadd2=isnull(lm.add2,'''')'
		Set @SqlCommand=@SqlCommand+',DFPlace=isnull(lm.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',DFPin=isnull(lm.PINCode,'''')'
		Set @SqlCommand=@SqlCommand+',DFstate=isnull(lm.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',STadd1=isnull(sh.add1,'''')'
		Set @SqlCommand=@SqlCommand+',STadd2=isnull(sh.add2,'''')'
		Set @SqlCommand=@SqlCommand+',STPlace=isnull(sh.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',STPin=isnull(sh.zip,'''')'
		Set @SqlCommand=@SqlCommand+',STstate=isnull(sh.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',TOCargo=sm.CARGO_TYP'
		Set @SqlCommand=@SqlCommand+',SubTypDes=sm.SubTypDes'
		Set @SqlCommand=@SqlCommand+',Tot_AMT=m.net_amt'
		
		Set @SqlCommand=@SqlCommand+' From StMain m'
		Set @SqlCommand=@SqlCommand+' inner join Stitem d on(m.entry_ty =d.entry_ty and m.tran_cd =d.tran_cd)'
		Set @SqlCommand=@SqlCommand+' inner join It_mast it on(d.it_code =it.it_code)'
		Set @SqlCommand=@SqlCommand+' Left outer Join StMainAdd sm on (m.Tran_cd=sm.Tran_Cd)'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' left outer Join Ac_Mast acm on (m.cons_id=acm.Ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join  ShipTo sh on (sh.ac_id = m.Cons_id and sh.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join Ac_Mast ac on (m.ac_id =ac.Ac_id)'
		
		Set @SqlCommand=@SqlCommand+' Left outer Join LOC_MASTER lm on (lm.Loc_Code = sm.SHIPTO)'
		
		Set @SqlCommand=@SqlCommand+' Where 1=1 and it.isservice=0 and m.date between '+ char(39)+cast(@SDATE as  varchar(25)) + char(39)+ ' and '+ char(39)+ cast(@EDATE as varchar(25))+ char(39)
		If (@FromInv<>'') Begin Set @SqlCommand=@SqlCommand+' and M.INV_NO BETWEEN '+char(39)+@FromInv+Char(39) +' AND ' + char(39)+@ToInv+Char(39) End
		If (@Bcode_nm<>'') Begin Set @SqlCommand=@SqlCommand+' and M.Entry_ty = '+char(39)+@Bcode_nm+Char(39) End
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand
	END 
	if (@Bcode_nm in ('DC',''))
	BEGIN
		Set @SqlCommand='Insert into #eWayBillExcel'
		--Set @SqlCommand=@SqlCommand+' Select  sel= 1, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Outward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=''Challan'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,105) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Commented by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' Select  sel= 0, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Outward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=''Challan'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,103) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Modified by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' ,PartyCode ='''''
		Set @SqlCommand=@SqlCommand+' ,LgNm=case WHEN isnull(m.scons_id, 0) > 0 THEN  (CASE WHEN ISNULL(SH.MAILNAME,'''') = '''' THEN  Acm.Ac_Name ELSE SH.MAILNAME END ) ELSE AC.AC_NAME END '
		Set @SqlCommand=@SqlCommand+' ,ConCity=case WHEN isnull(m.scons_id, 0) > 0 THEN sh.City ELSE AC.City END '
		Set @SqlCommand=@SqlCommand+',ConState=case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.[state] ELSE AC.[state] END'
		Set @SqlCommand=@SqlCommand+',LgADD = case WHEN isnull(m.scons_id, 0) > 0 THEN  RTRIM(LTRIM(ISNULL(SH.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD3,''''))) ELSE RTRIM(LTRIM(ISNULL(AC.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD3,'''')))  END '
		Set @SqlCommand=@SqlCommand+',LgGstin = case WHEN isnull(m.scons_id, 0) > 0 THEN  Case when  sh.gstin in('''',''Unregistered'') THEN '''' ELSE SH.GSTIN END  ELSE (Case when  AC.gstin in('''',''Unregistered'') THEN '''' ELSE AC.GSTIN END) END '
		Set @SqlCommand=@SqlCommand+' ,LgArea = case WHEN isnull(m.scons_id, 0) > 0 THEN sh.area ELSE AC.AREA END '
		Set @SqlCommand=@SqlCommand+' ,LgpinCode =  case WHEN isnull(m.scons_id, 0) > 0 THEN sh.zip ELSE AC.zip END '
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=case when  year(m.U_LrDt) > 2000 then convert(varchar(11),m.U_LrDt,103)else '''' end ,TranMode=m.u_tMode,AproxDis=m.EWBDIST'
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=case when  year(m.EWBDt) > 2000 then convert(varchar(11),m.EWBDt,103)else '''' end'
		Set @SqlCommand=@SqlCommand+' ,Product=it.it_name,ProdDesc=cast(it.it_desc as varchar(250)),HSN=it.hsncode,Unit=IT.S_UNIT,qty=D.QTY'
		Set @SqlCommand=@SqlCommand+' ,AssValue=D.u_asseamt,TaxRate=(case when (isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)) = 0 then d.gstrate else (isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)) end ),CessAmt=d.compcess'
		Set @SqlCommand=@SqlCommand+' ,m.u_deli,m.trans_id,m.u_vehno ,Remark1='''',Remark2='''''
		Set @SqlCommand=@SqlCommand+' ,ConEmail =(case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.email ELSE AC.email END) '
		Set @SqlCommand=@SqlCommand+' ,CessRate = '''',IGST_AMT=isnull(d.igst_amt,0),CGST_AMT=isnull(d.cgst_amt,0),sGST_AMT=isnull(d.sgst_amt,0),Cess_AMT=isnull(d.compcess,0),TranEmail = isnull(m.TranEmail,''''),itemid =d.item_no'
		
		Set @SqlCommand=@SqlCommand+',DFadd1=isnull(lm.add1,'''')'
		Set @SqlCommand=@SqlCommand+',DFadd2=isnull(lm.add2,'''')'
		Set @SqlCommand=@SqlCommand+',DFPlace=isnull(lm.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',DFPin=isnull(lm.PINCode,'''')'
		Set @SqlCommand=@SqlCommand+',DFstate=isnull(lm.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',STadd1=isnull(sh.add1,'''')'
		Set @SqlCommand=@SqlCommand+',STadd2=isnull(sh.add2,'''')'
		Set @SqlCommand=@SqlCommand+',STPlace=isnull(sh.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',STPin=isnull(sh.zip,'''')'
		Set @SqlCommand=@SqlCommand+',STstate=isnull(sh.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',TOCargo=m.CARGO_TYP'
		Set @SqlCommand=@SqlCommand+',SubTypDes=m.SubTypDes'
		Set @SqlCommand=@SqlCommand+',Tot_AMT=m.net_amt'
		
		Set @SqlCommand=@SqlCommand+' From DCMain m'
		Set @SqlCommand=@SqlCommand+' inner join DCitem d on(m.entry_ty =d.entry_ty and m.tran_cd =d.tran_cd)'
		Set @SqlCommand=@SqlCommand+' inner join It_mast it on(d.it_code =it.it_code)'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' left outer join  Ac_Mast acm on (acm.Ac_Id=m.cons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join  ShipTo sh on (sh.ac_id = m.Cons_id and sh.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join Ac_Mast ac on (m.ac_id =ac.Ac_id)'
		
		Set @SqlCommand=@SqlCommand+' Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'
		
		Set @SqlCommand=@SqlCommand+' Where 1=1 and it.isservice=0 and m.date between '+ char(39)+cast(@SDATE as  varchar(25)) + char(39)+ ' and '+ char(39)+ cast(@EDATE as varchar(25))+ char(39)
		If (@FromInv<>'') Begin Set @SqlCommand=@SqlCommand+' and M.INV_NO BETWEEN '+char(39)+@FromInv+Char(39) +' AND ' + char(39)+@ToInv+Char(39) End
		If (@Bcode_nm<>'') Begin Set @SqlCommand=@SqlCommand+' and M.Entry_ty = '+char(39)+@Bcode_nm+Char(39) End
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	End
	if (@Bcode_nm in ('SR',''))
	BEGIN
		Set @SqlCommand='Insert into #eWayBillExcel' 
		--Set @SqlCommand=@SqlCommand+' Select  sel= 1, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Outward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=''Challan'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,105) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Commented by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' Select  sel= 0, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Outward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=''Challan'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,103) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Modified by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' ,PartyCode ='''''
		Set @SqlCommand=@SqlCommand+' ,LgNm=case WHEN isnull(m.scons_id, 0) > 0 THEN  (CASE WHEN ISNULL(SH.MAILNAME,'''') = '''' THEN  Acm.Ac_Name ELSE SH.MAILNAME END ) ELSE AC.AC_NAME END '
		Set @SqlCommand=@SqlCommand+' ,ConCity=case WHEN isnull(m.scons_id, 0) > 0 THEN sh.City ELSE AC.City END '
		Set @SqlCommand=@SqlCommand+',ConState=case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.[state] ELSE AC.[state] END'
		Set @SqlCommand=@SqlCommand+',LgADD = case WHEN isnull(m.scons_id, 0) > 0 THEN  RTRIM(LTRIM(ISNULL(SH.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD3,''''))) ELSE RTRIM(LTRIM(ISNULL(AC.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD3,'''')))  END '
		Set @SqlCommand=@SqlCommand+',LgGstin = case WHEN isnull(m.scons_id, 0) > 0 THEN  Case when  sh.gstin in('''',''Unregistered'') THEN '''' ELSE SH.GSTIN END  ELSE (Case when  AC.gstin in('''',''Unregistered'') THEN '''' ELSE AC.GSTIN END) END '
		Set @SqlCommand=@SqlCommand+' ,LgArea = case WHEN isnull(m.scons_id, 0) > 0 THEN sh.area ELSE AC.AREA END '
		Set @SqlCommand=@SqlCommand+' ,LgpinCode =  case WHEN isnull(m.scons_id, 0) > 0 THEN sh.zip ELSE AC.zip END '
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=case when  year(m.U_LrDt) > 2000 then convert(varchar(11),m.U_LrDt,103)else '''' end ,TranMode=m.u_tMode,AproxDis=m.EWBDIST'
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=case when  year(m.EWBDt) > 2000 then convert(varchar(11),m.EWBDt,103)else '''' end'
		Set @SqlCommand=@SqlCommand+' ,Product=it.it_name,ProdDesc=cast(it.it_desc as varchar(250)),HSN=it.hsncode,Unit=IT.S_UNIT,qty=D.QTY'
		Set @SqlCommand=@SqlCommand+' ,AssValue=D.u_asseamt,TaxRate=(case when (isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)) = 0 then d.gstrate else (isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)) end ),CessAmt=d.compcess'
		Set @SqlCommand=@SqlCommand+' ,m.u_deli,m.trans_id,m.u_vehno ,Remark1='''',Remark2='''''
		Set @SqlCommand=@SqlCommand+' ,ConEmail =(case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.email ELSE AC.email END) '
		Set @SqlCommand=@SqlCommand+' ,CessRate = '''',IGST_AMT=isnull(d.igst_amt,0),CGST_AMT=isnull(d.cgst_amt,0),sGST_AMT=isnull(d.sgst_amt,0),Cess_AMT=isnull(d.compcess,0),TranEmail = isnull(m.TranEmail,''''),itemid =d.item_no'
		
		Set @SqlCommand=@SqlCommand+',DFadd1=isnull(sh.add1,'''')'
		Set @SqlCommand=@SqlCommand+',DFadd2=isnull(sh.add2,'''')'
		Set @SqlCommand=@SqlCommand+',DFPlace=isnull(sh.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',DFPin=isnull(sh.zip,'''')'
		Set @SqlCommand=@SqlCommand+',DFstate=isnull(sh.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',STadd1=isnull(lm.add1,'''')'
		Set @SqlCommand=@SqlCommand+',STadd2=isnull(lm.add2,'''')'
		Set @SqlCommand=@SqlCommand+',STPlace=isnull(lm.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',STPin=isnull(lm.PINCode,'''')'
		Set @SqlCommand=@SqlCommand+',STstate=isnull(lm.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',TOCargo=m.CARGO_TYP'
		Set @SqlCommand=@SqlCommand+',SubTypDes=m.SubTypDes'
		Set @SqlCommand=@SqlCommand+',Tot_AMT=m.net_amt'
		
		Set @SqlCommand=@SqlCommand+' From SRMain m'
		Set @SqlCommand=@SqlCommand+' inner join SRitem d on(m.entry_ty =d.entry_ty and m.tran_cd =d.tran_cd)'
		Set @SqlCommand=@SqlCommand+' inner join It_mast it on(d.it_code =it.it_code)'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' left outer join Ac_Mast acm on (m.Cons_id=acm.Ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join  ShipTo sh on (sh.ac_id = m.Cons_id and sh.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join Ac_Mast ac on (m.ac_id =ac.Ac_id)'
		
		Set @SqlCommand=@SqlCommand+' Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'
		
		Set @SqlCommand=@SqlCommand+'  Where 1=1 and it.isservice=0 and m.date between '+ char(39)+cast(@SDATE as  varchar(25)) + char(39)+ ' and '+ char(39)+ cast(@EDATE as varchar(25))+ char(39)
		If (@FromInv<>'') Begin Set @SqlCommand=@SqlCommand+' and M.INV_NO BETWEEN '+char(39)+@FromInv+Char(39) +' AND ' + char(39)+@ToInv+Char(39) End
		If (@Bcode_nm<>'') Begin Set @SqlCommand=@SqlCommand+' and M.Entry_ty = '+char(39)+@Bcode_nm+Char(39) End
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	END
	if (@Bcode_nm in ('GC','C6',''))
	BEGIN
		Set @SqlCommand='Insert into #eWayBillExcel' 
		--Set @SqlCommand=@SqlCommand+' Select  sel= 1, DATE=M.DATE,l.Entry_Ty,SuppTyp=(CASE WHEN M.AGAINSTGS IN(''PURCHASES'',''SERVICE PURCHASE BILL'') THEN ''Inward'' ELSE ''Outward'' END ),SubTyp=isnull(m.EWBSUPTYPC,''''),DocTyp=''Credit Note'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,105) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Commented by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' Select  sel= 0, DATE=M.DATE,l.Entry_Ty,SuppTyp=(CASE WHEN M.AGAINSTGS IN(''PURCHASES'',''SERVICE PURCHASE BILL'') THEN ''Inward'' ELSE ''Outward'' END ),SubTyp=isnull(m.EWBSUPTYPC,''''),DocTyp=''Credit Note'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,103) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Modified by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' ,PartyCode ='''''
		Set @SqlCommand=@SqlCommand+' ,LgNm=case WHEN isnull(m.scons_id, 0) > 0 THEN  (CASE WHEN ISNULL(SH.MAILNAME,'''') = '''' THEN  Acm.Ac_Name ELSE SH.MAILNAME END ) ELSE AC.AC_NAME END '
		Set @SqlCommand=@SqlCommand+' ,ConCity=case WHEN isnull(m.scons_id, 0) > 0 THEN sh.City ELSE AC.City END '
		Set @SqlCommand=@SqlCommand+' ,ConState=case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.[state] ELSE AC.[state] END'
		Set @SqlCommand=@SqlCommand+' ,LgADD = case WHEN isnull(m.scons_id, 0) > 0 THEN  RTRIM(LTRIM(ISNULL(SH.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD3,''''))) ELSE RTRIM(LTRIM(ISNULL(AC.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD3,'''')))  END '
		Set @SqlCommand=@SqlCommand+' ,LgGstin = case WHEN isnull(m.scons_id, 0) > 0 THEN  Case when  sh.gstin in('''',''Unregistered'') THEN '''' ELSE SH.GSTIN END  ELSE (Case when  AC.gstin in('''',''Unregistered'') THEN '''' ELSE AC.GSTIN END) END'
		Set @SqlCommand=@SqlCommand+' ,LgArea = case WHEN isnull(m.scons_id, 0) > 0 THEN sh.area ELSE AC.AREA END '
		Set @SqlCommand=@SqlCommand+' ,LgpinCode =  case WHEN isnull(m.scons_id, 0) > 0 THEN sh.zip ELSE AC.zip END '
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=case when  year(m.U_LrDt) > 2000 then convert(varchar(11),m.U_LrDt,103)else '''' end ,TranMode=m.u_tMode,AproxDis=m.EWBDIST'
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=case when  year(m.EWBDt) > 2000 then convert(varchar(11),m.EWBDt,103)else '''' end'
		Set @SqlCommand=@SqlCommand+' ,Product=it.it_name,ProdDesc=cast(it.it_desc as varchar(250)),HSN=it.hsncode,Unit=IT.S_UNIT,qty=D.QTY'
		Set @SqlCommand=@SqlCommand+' ,AssValue=D.u_asseamt,TaxRate=(case when (isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)) = 0 then d.gstrate else (isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)) end ),CessAmt=d.compcess'
		Set @SqlCommand=@SqlCommand+' ,m.u_deli,m.trans_id,m.u_vehno ,Remark1='''',Remark2='''''
		Set @SqlCommand=@SqlCommand+' ,ConEmail =(case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.email ELSE AC.email END) '
		Set @SqlCommand=@SqlCommand+' ,CessRate = '''',IGST_AMT=isnull(d.igst_amt,0),CGST_AMT=isnull(d.cgst_amt,0),sGST_AMT=isnull(d.sgst_amt,0),Cess_AMT=isnull(d.compcess,0),TranEmail = isnull(m.TranEmail,''''),itemid =d.item_no'
		
		Set @SqlCommand=@SqlCommand+',DFadd1=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(sh.add1,'''') ELSE isnull(lm.add1,'''') END'
		Set @SqlCommand=@SqlCommand+',DFadd2=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(sh.add2,'''') ELSE isnull(lm.add2,'''') END'
		Set @SqlCommand=@SqlCommand+',DFPlace=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(sh.CITY,'''') ELSE isnull(lm.CITY,'''') END'
		Set @SqlCommand=@SqlCommand+',DFPin=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(sh.zip,'''') ELSE isnull(lm.PINCode,'''') END'
		Set @SqlCommand=@SqlCommand+',DFstate=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(sh.[state],'''') ELSE isnull(lm.[state],'''') END'
		
		Set @SqlCommand=@SqlCommand+',STadd1=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(lm.add1,'''') ELSE isnull(sh.add1,'''') END'
		Set @SqlCommand=@SqlCommand+',STadd2=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(lm.add2,'''') ELSE isnull(sh.add2,'''') END'
		Set @SqlCommand=@SqlCommand+',STPlace=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(lm.CITY,'''') ELSE isnull(sh.CITY,'''') END'
		Set @SqlCommand=@SqlCommand+',STPin=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(lm.PINCode,'''') ELSE isnull(sh.zip,'''') END'
		Set @SqlCommand=@SqlCommand+',STstate=case WHEN AGAINSTGS=''PURCHASES'' THEN  isnull(lm.[state],'''') ELSE isnull(sh.[state],'''') END'
		
		Set @SqlCommand=@SqlCommand+',TOCargo=m.CARGO_TYP'
		Set @SqlCommand=@SqlCommand+',SubTypDes=m.SubTypDes'
		Set @SqlCommand=@SqlCommand+',Tot_AMT=m.net_amt'
		
		Set @SqlCommand=@SqlCommand+' From CNMain m'
		Set @SqlCommand=@SqlCommand+' inner join CNitem d on(m.entry_ty =d.entry_ty and m.tran_cd =d.tran_cd)'
		Set @SqlCommand=@SqlCommand+' inner join It_mast it on(d.it_code =it.it_code)'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' left outer join Ac_Mast acm on (m.Cons_id=acm.Ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join  ShipTo sh on (sh.ac_id = m.Cons_id and sh.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join Ac_Mast ac on (m.ac_id =ac.Ac_id)'
	
		Set @SqlCommand=@SqlCommand+' Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'
	
		Set @SqlCommand=@SqlCommand+'  Where 1=1 and  it.isservice=0 and m.date between '+ char(39)+cast(@SDATE as  varchar(25)) + char(39)+ ' and '+ char(39)+ cast(@EDATE as varchar(25))+ char(39)
		If (@FromInv<>'') Begin Set @SqlCommand=@SqlCommand+' and M.INV_NO BETWEEN '+char(39)+@FromInv+Char(39) +' AND ' + char(39)+@ToInv+Char(39) End
		If (@Bcode_nm<>'') Begin Set @SqlCommand=@SqlCommand+' and M.Entry_ty = '+char(39)+@Bcode_nm+Char(39) End
		Execute Sp_ExecuteSql @SqlCommand	
	END 
	----IL(LABOUR JOB ISSUE[V]) ,LI	(LABOUR JOB ISSUE[IV])
	if (@Bcode_nm in ('IL','LI',''))
	BEGIN
		Set @SqlCommand='Insert into #eWayBillExcel' 
		--Set @SqlCommand=@SqlCommand+' Select  sel= 1, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Outward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=''Challan'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,105) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Commented by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' Select  sel= 0, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Outward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=''Challan'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,103) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Modified by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' ,PartyCode ='''''
		Set @SqlCommand=@SqlCommand+' ,LgNm=case WHEN isnull(m.scons_id, 0) > 0 THEN  (CASE WHEN ISNULL(SH.MAILNAME,'''') = '''' THEN  Acm.Ac_Name ELSE SH.MAILNAME END ) ELSE AC.AC_NAME END '
		Set @SqlCommand=@SqlCommand+' ,ConCity=case WHEN isnull(m.scons_id, 0) > 0 THEN sh.City ELSE AC.City END '
		Set @SqlCommand=@SqlCommand+',ConState=case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.[state] ELSE AC.[state] END'
		Set @SqlCommand=@SqlCommand+',LgADD = case WHEN isnull(m.scons_id, 0) > 0 THEN  RTRIM(LTRIM(ISNULL(SH.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD3,''''))) ELSE RTRIM(LTRIM(ISNULL(AC.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD3,'''')))  END '
		Set @SqlCommand=@SqlCommand+',LgGstin = case WHEN isnull(m.scons_id, 0) > 0 THEN  Case when  sh.gstin in('''',''Unregistered'') THEN '''' ELSE SH.GSTIN END  ELSE (Case when  AC.gstin in('''',''Unregistered'') THEN '''' ELSE AC.GSTIN END) END'
		Set @SqlCommand=@SqlCommand+' ,LgArea = case WHEN isnull(m.scons_id, 0) > 0 THEN sh.area ELSE AC.AREA END '
		Set @SqlCommand=@SqlCommand+' ,LgpinCode =  case WHEN isnull(m.scons_id, 0) > 0 THEN sh.zip ELSE AC.zip END '
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=case when  year(m.U_LrDt) > 2000 then convert(varchar(11),m.U_LrDt,103)else '''' end ,TranMode=m.u_tMode,AproxDis=m.EWBDIST'
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=case when  year(m.EWBDt) > 2000 then convert(varchar(11),m.EWBDt,103)else '''' end'
		Set @SqlCommand=@SqlCommand+' ,Product=it.it_name,ProdDesc=cast(it.it_desc as varchar(250)),HSN=it.hsncode,Unit=IT.S_UNIT,qty=D.QTY'
		Set @SqlCommand=@SqlCommand+' ,AssValue=D.u_asseamt,TaxRate=(isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)),CessAmt=d.compcess'
		Set @SqlCommand=@SqlCommand+' ,m.u_deli,m.trans_id,m.u_vehno ,Remark1='''',Remark2='''''
		Set @SqlCommand=@SqlCommand+' ,ConEmail =(case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.email ELSE AC.email END) '
		Set @SqlCommand=@SqlCommand+' ,CessRate = '''',IGST_AMT=isnull(d.igst_amt,0),CGST_AMT=isnull(d.cgst_amt,0),sGST_AMT=isnull(d.sgst_amt,0),Cess_AMT=isnull(d.compcess,0),TranEmail = isnull(m.TranEmail,''''),itemid =d.item_no'
		
		Set @SqlCommand=@SqlCommand+',DFadd1=isnull(lm.add1,'''')'
		Set @SqlCommand=@SqlCommand+',DFadd2=isnull(lm.add2,'''')'
		Set @SqlCommand=@SqlCommand+',DFPlace=isnull(lm.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',DFPin=isnull(lm.PINCode,'''')'
		Set @SqlCommand=@SqlCommand+',DFstate=isnull(lm.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',STadd1=isnull(sh.add1,'''')'
		Set @SqlCommand=@SqlCommand+',STadd2=isnull(sh.add2,'''')'
		Set @SqlCommand=@SqlCommand+',STPlace=isnull(sh.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',STPin=isnull(sh.zip,'''')'
		Set @SqlCommand=@SqlCommand+',STstate=isnull(sh.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',TOCargo=m.CARGO_TYP'
		Set @SqlCommand=@SqlCommand+',SubTypDes=m.SubTypDes'
		Set @SqlCommand=@SqlCommand+',Tot_AMT=m.net_amt'
		
		Set @SqlCommand=@SqlCommand+' From IIMAIN m'
		Set @SqlCommand=@SqlCommand+' inner join IIitem d on(m.entry_ty =d.entry_ty and m.tran_cd =d.tran_cd)'
		Set @SqlCommand=@SqlCommand+' inner join It_mast it on(d.it_code =it.it_code)'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' left outer Join Ac_Mast acm on (m.Cons_id=acm.Ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join  ShipTo sh on (sh.ac_id = m.Cons_id and sh.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join Ac_Mast ac on (m.ac_id =ac.Ac_id)'
		
		Set @SqlCommand=@SqlCommand+' Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'
		
		Set @SqlCommand=@SqlCommand+'  Where 1=1 and it.isservice=0 and m.date between '+ char(39)+cast(@SDATE as  varchar(25)) + char(39)+ ' and '+ char(39)+ cast(@EDATE as varchar(25))+ char(39)
		If (@FromInv<>'') Begin Set @SqlCommand=@SqlCommand+' and M.INV_NO BETWEEN '+char(39)+@FromInv+Char(39) +' AND ' + char(39)+@ToInv+Char(39) End
		If (@Bcode_nm<>'') Begin Set @SqlCommand=@SqlCommand+' and M.Entry_ty = '+char(39)+@Bcode_nm+Char(39) End
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	END 
	---RL-LABOUR JOB RECEIPT[IV],LR-LABOUR JOB RECEIPT[V]
	if (@Bcode_nm in ('RL','LR',''))
	BEGIN
		Set @SqlCommand='Insert into #eWayBillExcel' 
		--Set @SqlCommand=@SqlCommand+' Select  sel= 1, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Inward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=''Challan'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,105) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Commented by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' Select  sel= 0, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Inward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=''Challan'',DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,103) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Modified by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' ,PartyCode ='''''
		Set @SqlCommand=@SqlCommand+' ,LgNm=case WHEN isnull(m.scons_id, 0) > 0 THEN  (CASE WHEN ISNULL(SH.MAILNAME,'''') = '''' THEN  Acm.Ac_Name ELSE SH.MAILNAME END ) ELSE AC.AC_NAME END '
		Set @SqlCommand=@SqlCommand+' ,ConCity=case WHEN isnull(m.scons_id, 0) > 0 THEN sh.City ELSE AC.City END '
		Set @SqlCommand=@SqlCommand+',ConState=case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.[state] ELSE AC.[state] END'
		Set @SqlCommand=@SqlCommand+',LgADD = case WHEN isnull(m.scons_id, 0) > 0 THEN  RTRIM(LTRIM(ISNULL(SH.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD3,''''))) ELSE RTRIM(LTRIM(ISNULL(AC.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD3,'''')))  END '
		Set @SqlCommand=@SqlCommand+',LgGstin = case WHEN isnull(m.scons_id, 0) > 0 THEN  Case when  sh.gstin in('''',''Unregistered'') THEN '''' ELSE SH.GSTIN END  ELSE (Case when  AC.gstin in('''',''Unregistered'') THEN '''' ELSE AC.GSTIN END) END '
		Set @SqlCommand=@SqlCommand+' ,LgArea = case WHEN isnull(m.scons_id, 0) > 0 THEN sh.area ELSE AC.AREA END '
		Set @SqlCommand=@SqlCommand+' ,LgpinCode =  case WHEN isnull(m.scons_id, 0) > 0 THEN sh.zip ELSE AC.zip END '
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=case when  year(m.U_LrDt) > 2000 then convert(varchar(11),m.U_LrDt,103)else '''' end ,TranMode=m.u_tMode,AproxDis=m.EWBDIST'
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=case when  year(m.EWBDt) > 2000 then convert(varchar(11),m.EWBDt,103)else '''' end'
		Set @SqlCommand=@SqlCommand+' ,Product=it.it_name,ProdDesc=cast(it.it_desc as varchar(250)),HSN=it.hsncode,Unit=IT.S_UNIT,qty=D.QTY'
		Set @SqlCommand=@SqlCommand+' ,AssValue=D.u_asseamt,TaxRate=(isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)),CessAmt=d.compcess'
		Set @SqlCommand=@SqlCommand+' ,m.u_deli,m.trans_id,m.u_vehno ,Remark1='''',Remark2='''''
		Set @SqlCommand=@SqlCommand+' ,ConEmail =(case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.email ELSE AC.email END) '
		Set @SqlCommand=@SqlCommand+' ,CessRate = '''',IGST_AMT=isnull(d.igst_amt,0),CGST_AMT=isnull(d.cgst_amt,0),sGST_AMT=isnull(d.sgst_amt,0),Cess_AMT=isnull(d.compcess,0),TranEmail = isnull(m.TranEmail,''''),itemid =d.item_no'
		
		Set @SqlCommand=@SqlCommand+',DFadd1=isnull(sh.add1,'''')'
		Set @SqlCommand=@SqlCommand+',DFadd2=isnull(sh.add2,'''')'
		Set @SqlCommand=@SqlCommand+',DFPlace=isnull(sh.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',DFPin=isnull(sh.zip,'''')'
		Set @SqlCommand=@SqlCommand+',DFstate=isnull(sh.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',STadd1=isnull(lm.add1,'''')'
		Set @SqlCommand=@SqlCommand+',STadd2=isnull(lm.add2,'''')'
		Set @SqlCommand=@SqlCommand+',STPlace=isnull(lm.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',STPin=isnull(lm.PINCode,'''')'
		Set @SqlCommand=@SqlCommand+',STstate=isnull(lm.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',TOCargo=m.CARGO_TYP'
		Set @SqlCommand=@SqlCommand+',SubTypDes=m.SubTypDes'
		Set @SqlCommand=@SqlCommand+',Tot_AMT=m.net_amt'
		
		Set @SqlCommand=@SqlCommand+' From IRMain m'
		Set @SqlCommand=@SqlCommand+' inner join IRitem d on(m.entry_ty =d.entry_ty and m.tran_cd =d.tran_cd)'
		Set @SqlCommand=@SqlCommand+' inner join It_mast it on(d.it_code =it.it_code)'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' left outer join Ac_Mast acm on (m.Cons_id=acm.Ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join  ShipTo sh on (sh.ac_id = m.Cons_id and sh.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join Ac_Mast ac on (m.ac_id =ac.Ac_id)'
		
		Set @SqlCommand=@SqlCommand+' Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'
				
		Set @SqlCommand=@SqlCommand+' Where 1=1 and it.isservice=0 and m.date between '+ char(39)+cast(@SDATE as  varchar(25)) + char(39)+ ' and '+ char(39)+ cast(@EDATE as varchar(25))+ char(39)
		If (@FromInv<>'') Begin Set @SqlCommand=@SqlCommand+' and M.INV_NO BETWEEN '+char(39)+@FromInv+Char(39) +' AND ' + char(39)+@ToInv+Char(39) End
		If (@Bcode_nm<>'') Begin Set @SqlCommand=@SqlCommand+' and M.Entry_ty = '+char(39)+@Bcode_nm+Char(39) End
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	END 
	if (@Bcode_nm in ('PT','P1',''))
	BEGIN
		Set @SqlCommand='Insert into #eWayBillExcel' 
		--Set @SqlCommand=@SqlCommand+' Select  sel= 1, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Inward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=Case when m.entry_ty =''PT'' then ''Bill of Supply'' else ''Bill of Entry'' end,DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,105) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Commented by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' Select  sel= 0, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Inward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=Case when m.entry_ty =''PT'' then ''Bill of Supply'' else ''Bill of Entry'' end,DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,103) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Modified by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' ,PartyCode ='''''
		Set @SqlCommand=@SqlCommand+' ,LgNm=case WHEN isnull(m.scons_id, 0) > 0 THEN  (CASE WHEN ISNULL(SH.MAILNAME,'''') = '''' THEN  Acm.Ac_Name ELSE SH.MAILNAME END ) ELSE AC.AC_NAME END '
		Set @SqlCommand=@SqlCommand+' ,ConCity=case WHEN isnull(m.scons_id, 0) > 0 THEN sh.City ELSE AC.City END '
		Set @SqlCommand=@SqlCommand+',ConState=case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.[state] ELSE AC.[state] END'
		Set @SqlCommand=@SqlCommand+',LgADD = case WHEN isnull(m.scons_id, 0) > 0 THEN  RTRIM(LTRIM(ISNULL(SH.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD3,''''))) ELSE RTRIM(LTRIM(ISNULL(AC.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD3,'''')))  END '
		Set @SqlCommand=@SqlCommand+',LgGstin = case WHEN isnull(m.scons_id, 0) > 0 THEN  Case when  sh.gstin in('''',''Unregistered'') THEN '''' ELSE SH.GSTIN END  ELSE (Case when  AC.gstin in('''',''Unregistered'') THEN '''' ELSE AC.GSTIN END) END '
		Set @SqlCommand=@SqlCommand+' ,LgArea = case WHEN isnull(m.scons_id, 0) > 0 THEN sh.area ELSE AC.AREA END '
		Set @SqlCommand=@SqlCommand+' ,LgpinCode =  case WHEN isnull(m.scons_id, 0) > 0 THEN sh.zip ELSE AC.zip END '
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=case when  year(m.U_LrDt) > 2000 then convert(varchar(11),m.U_LrDt,103)else '''' end ,TranMode=m.u_tMode,AproxDis=m.EWBDIST'
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=case when  year(m.EWBDt) > 2000 then convert(varchar(11),m.EWBDt,103)else '''' end'
		Set @SqlCommand=@SqlCommand+' ,Product=it.it_name,ProdDesc=cast(it.it_desc as varchar(250)),HSN=it.hsncode,Unit=IT.S_UNIT,qty=D.QTY'
		Set @SqlCommand=@SqlCommand+' ,AssValue=D.u_asseamt,TaxRate=(isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)),CessAmt=d.compcess'
		Set @SqlCommand=@SqlCommand+' ,m.u_deli,m.trans_id,m.u_vehno ,Remark1='''',Remark2='''''
		Set @SqlCommand=@SqlCommand+' ,ConEmail =(case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.email ELSE AC.email END) '
		Set @SqlCommand=@SqlCommand+' ,CessRate = '''',IGST_AMT=isnull(d.igst_amt,0),CGST_AMT=isnull(d.cgst_amt,0),sGST_AMT=isnull(d.sgst_amt,0),Cess_AMT=isnull(d.compcess,0),TranEmail = isnull(m.TranEmail,''''),itemid =d.item_no'
		
		Set @SqlCommand=@SqlCommand+',DFadd1=isnull(sh.add1,'''')'
		Set @SqlCommand=@SqlCommand+',DFadd2=isnull(sh.add2,'''')'
		Set @SqlCommand=@SqlCommand+',DFPlace=isnull(sh.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',DFPin=isnull(sh.zip,'''')'
		Set @SqlCommand=@SqlCommand+',DFstate=isnull(sh.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',STadd1=isnull(lm.add1,'''')'
		Set @SqlCommand=@SqlCommand+',STadd2=isnull(lm.add2,'''')'
		Set @SqlCommand=@SqlCommand+',STPlace=isnull(lm.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',STPin=isnull(lm.PINCode,'''')'
		Set @SqlCommand=@SqlCommand+',STstate=isnull(lm.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',TOCargo=m.CARGO_TYP'
		Set @SqlCommand=@SqlCommand+',SubTypDes=m.SubTypDes'
		Set @SqlCommand=@SqlCommand+',Tot_AMT=m.net_amt'
		
		
		Set @SqlCommand=@SqlCommand+' From PTMain m'
		Set @SqlCommand=@SqlCommand+' inner join PTitem d on(m.entry_ty =d.entry_ty and m.tran_cd =d.tran_cd)'
		Set @SqlCommand=@SqlCommand+' inner join It_mast it on(d.it_code =it.it_code)'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' left outer join Ac_Mast acm on (m.Cons_id=acm.Ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join  ShipTo sh on (sh.ac_id = m.Cons_id and sh.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join Ac_Mast ac on (m.ac_id =ac.Ac_id)'
		
		Set @SqlCommand=@SqlCommand+' Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'
		
		Set @SqlCommand=@SqlCommand+' Where 1=1 and it.isservice=0 and m.date between '+ char(39)+cast(@SDATE as  varchar(25)) + char(39)+ ' and '+ char(39)+ cast(@EDATE as varchar(25))+ char(39)
		If (@FromInv<>'') Begin Set @SqlCommand=@SqlCommand+' and M.INV_NO BETWEEN '+char(39)+@FromInv+Char(39) +' AND ' + char(39)+@ToInv+Char(39) End
		If (@Bcode_nm<>'') Begin Set @SqlCommand=@SqlCommand+' and M.Entry_ty = '+char(39)+@Bcode_nm+Char(39) End
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand 
	END 
	
	if (@Bcode_nm in ('AR',''))
	BEGIN
		Set @SqlCommand='Insert into #eWayBillExcel' 
		--Set @SqlCommand=@SqlCommand+' Select  sel= 1, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Inward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=Case when m.entry_ty =''PT'' then ''Bill of Supply'' else ''Bill of Entry'' end,DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,105) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Commented by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' Select  sel= 0, DATE=M.DATE,l.Entry_Ty,SuppTyp=''Inward'',SubTyp=isnull(m.EWBSUPTYP,''''),DocTyp=Case when m.entry_ty =''AR'' then ''Bill of Supply'' else ''Bill of Entry'' end,DocNo=m.Inv_No,DocDt= case when year(m.Date) > 2000 then convert(varchar(11),m.Date,103) else '''' end ,OrgCode='+char(39)+@OrgCode+char(39)  --Modified by Priyanka B on 08032018 for Bug-31239
		Set @SqlCommand=@SqlCommand+' ,PartyCode ='''''
		Set @SqlCommand=@SqlCommand+' ,LgNm=case WHEN isnull(m.scons_id, 0) > 0 THEN  (CASE WHEN ISNULL(SH.MAILNAME,'''') = '''' THEN  Acm.Ac_Name ELSE SH.MAILNAME END ) ELSE AC.AC_NAME END '
		Set @SqlCommand=@SqlCommand+' ,ConCity=case WHEN isnull(m.scons_id, 0) > 0 THEN sh.City ELSE AC.City END '
		Set @SqlCommand=@SqlCommand+',ConState=case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.[state] ELSE AC.[state] END'
		Set @SqlCommand=@SqlCommand+',LgADD = case WHEN isnull(m.scons_id, 0) > 0 THEN  RTRIM(LTRIM(ISNULL(SH.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(SH.ADD3,''''))) ELSE RTRIM(LTRIM(ISNULL(AC.ADD1,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD2,''''))) +'' ''+ LTRIM(RTRIM(ISNULL(AC.ADD3,'''')))  END '
		Set @SqlCommand=@SqlCommand+',LgGstin = case WHEN isnull(m.scons_id, 0) > 0 THEN  Case when  sh.gstin in('''',''Unregistered'') THEN '''' ELSE SH.GSTIN END  ELSE (Case when  AC.gstin in('''',''Unregistered'') THEN '''' ELSE AC.GSTIN END) END '
		Set @SqlCommand=@SqlCommand+' ,LgArea = case WHEN isnull(m.scons_id, 0) > 0 THEN sh.area ELSE AC.AREA END '
		Set @SqlCommand=@SqlCommand+' ,LgpinCode =  case WHEN isnull(m.scons_id, 0) > 0 THEN sh.zip ELSE AC.zip END '
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=case when  year(m.U_LrDt) > 2000 then convert(varchar(11),m.U_LrDt,103)else '''' end ,TranMode=m.u_tMode,AproxDis=m.EWBDIST'
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=case when  year(m.EWBDt) > 2000 then convert(varchar(11),m.EWBDt,103)else '''' end'
		Set @SqlCommand=@SqlCommand+' ,Product=it.it_name,ProdDesc=cast(it.it_desc as varchar(250)),HSN=it.hsncode,Unit=IT.S_UNIT,qty=D.QTY'
		Set @SqlCommand=@SqlCommand+' ,AssValue=D.u_asseamt,TaxRate=(isnull(d.cgst_per,0)+isnull(d.sgst_per,0)+isnull(d.igst_per,0)),CessAmt=d.compcess'
		Set @SqlCommand=@SqlCommand+' ,m.u_deli,m.trans_id,m.u_vehno ,Remark1='''',Remark2='''''
		Set @SqlCommand=@SqlCommand+' ,ConEmail =(case WHEN isnull(m.scons_id, 0) > 0 THEN Sh.email ELSE AC.email END) '
		Set @SqlCommand=@SqlCommand+' ,CessRate = '''',IGST_AMT=isnull(d.igst_amt,0),CGST_AMT=isnull(d.cgst_amt,0),sGST_AMT=isnull(d.sgst_amt,0),Cess_AMT=isnull(d.compcess,0),TranEmail = isnull(m.TranEmail,''''),itemid =d.item_no'
		
		Set @SqlCommand=@SqlCommand+',DFadd1=isnull(sh.add1,'''')'
		Set @SqlCommand=@SqlCommand+',DFadd2=isnull(sh.add2,'''')'
		Set @SqlCommand=@SqlCommand+',DFPlace=isnull(sh.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',DFPin=isnull(sh.zip,'''')'
		Set @SqlCommand=@SqlCommand+',DFstate=isnull(sh.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',STadd1=isnull(lm.add1,'''')'
		Set @SqlCommand=@SqlCommand+',STadd2=isnull(lm.add2,'''')'
		Set @SqlCommand=@SqlCommand+',STPlace=isnull(lm.CITY,'''')'
		Set @SqlCommand=@SqlCommand+',STPin=isnull(lm.PINCode,'''')'
		Set @SqlCommand=@SqlCommand+',STstate=isnull(lm.[state],'''')'
		
		Set @SqlCommand=@SqlCommand+',TOCargo=m.CARGO_TYP'
		Set @SqlCommand=@SqlCommand+',SubTypDes=m.SubTypDes'
		Set @SqlCommand=@SqlCommand+',Tot_AMT=m.net_amt'
		
		
		Set @SqlCommand=@SqlCommand+' From ARMain m'
		Set @SqlCommand=@SqlCommand+' inner join ARitem d on(m.entry_ty =d.entry_ty and m.tran_cd =d.tran_cd)'
		Set @SqlCommand=@SqlCommand+' inner join It_mast it on(d.it_code =it.it_code)'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' left outer join Ac_Mast acm on (m.Cons_id=acm.Ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join  ShipTo sh on (sh.ac_id = m.Cons_id and sh.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer Join Ac_Mast ac on (m.ac_id =ac.Ac_id)'
		
		Set @SqlCommand=@SqlCommand+' Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'
		
		Set @SqlCommand=@SqlCommand+' Where 1=1 and it.isservice=0 and m.date between '+ char(39)+cast(@SDATE as  varchar(25)) + char(39)+ ' and '+ char(39)+ cast(@EDATE as varchar(25))+ char(39)
		If (@FromInv<>'') Begin Set @SqlCommand=@SqlCommand+' and M.INV_NO BETWEEN '+char(39)+@FromInv+Char(39) +' AND ' + char(39)+@ToInv+Char(39) End
		If (@Bcode_nm<>'') Begin Set @SqlCommand=@SqlCommand+' and M.Entry_ty = '+char(39)+@Bcode_nm+Char(39) End
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand 
	END 
	select * from #eWayBillExcel order by date,ENTRY_TY,itemid

End