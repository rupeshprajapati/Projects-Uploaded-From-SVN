if Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_EWay_BILL_Report')
Begin
	Drop Procedure USP_REP_EWay_BILL_Report
End
Go

--execute USP_REP_EWay_BILL_Report 'Sales Return','','',''

-- =============================================
-- Author	  :	Prajakta B.
-- Create date: 29/05/2018
-- Descriion:	This Stored procedure is useful to generate Purchase Bill Invoice .
-- Remark: 
-- =============================================

Create PROCEDURE [dbo].[USP_REP_EWay_BILL_Report]
	@TrnName varchar(100),@Inv_No varchar(30),@Inv_dt Varchar(50),@Entry_ty Varchar(2),@Compid int
	AS
Begin

 print 11
  set dateformat dmy --Rupesh G. comment on 27/08/2018 for bug no.31777
Declare @SqlCommand nvarchar(MAX)
Select GSTIN,Co_Name,MailName=Left(Mailname,100),Add1=cast(rtrim(Add1) as varchar(50)),Add2=cast(rtrim(Add2) as varchar(50))
,Add3=cast(rtrim(Add3) as varchar(50)),CITY,Zip,cm.state,Gst_State_Code=Cast(st.Gst_State_Code as varchar)
into #Co_mast 
From vudyog..Co_mast cm
Left Join vudyog..state st on (cm.state=st.state)
where cm.CompId=@Compid 

print 1

Select 	userGstin=Cast('' as varchar(30)),docType1=Cast('' as varchar(30)),EWBN=CAST('' AS varchar(20)),EWBDT=convert(datetime,GETDATE()),
U_TMODE=CAST('' AS varchar(20)),EWBDIST=Cast(0 as Decimal(12,2)),EWBVTD=convert(datetime,GETDATE()),EWBSUPTYP=CAST('' AS varchar(25)),inv_no=CAST('' AS varchar(16)),
[date]=convert(datetime,GETDATE()),HSNCODE=CAST('' AS varchar(15)),It_Desc=CAST('' AS varchar(16)),qty=Cast(0 as Decimal(12,2)),U_ASSEAMT=Cast(0 as Decimal(15,2)),CGST_PER=Cast(0 as Decimal(5,2)),
SGST_PER=Cast(0 as Decimal(5,2)),IGST_PER=Cast(0 as Decimal(5,2)),CCESSRATE=CAST('' AS varchar(80)),gro_amt=Cast(0 as Decimal(17,2)),
CGST_AMT=Cast(0 as Decimal(18,2)),SGST_AMT=Cast(0 as Decimal(18,2)),IGST_AMT=Cast(0 as Decimal(18,2)),COMPCESS=Cast(0 as Decimal(12,2)),
u_deli=CAST('' AS varchar(35)),TRANS_ID=CAST('' AS varchar(50)),U_VEHNO=CAST('' AS varchar(15)),U_LRNO=CAST('' AS varchar(50)),U_LRDT=convert(varchar,'',105),
fromGstin=Cast('' as varchar(30)),fromTrdName=Cast('' as varchar(100)),
fromAddr1=Cast('' as varchar(100)),fromAddr2=Cast('' as varchar(100)),fromPlace=Cast('' as varchar(50)),
fromPincode=Cast('' as varchar(30)),fromStateCode=Cast('' as varchar(50)),toGstin=Cast('' as varchar(30)),
toTrdName=Cast('' as varchar(100)),toAddr1=Cast('' as varchar(100)),toAddr2=Cast('' as varchar(100)),
toPlace=Cast('' as varchar(50)),toPincode=Cast('' as varchar(30)),toStateCode=Cast('' as varchar(50))
,fromactStateCode=Cast('' as varchar(50)),toactStateCode=Cast('' as varchar(50))
,EWBValidFrom=CONVERT(datetime,GETDATE())
,SuppTyp=cast('' as varchar(20))
,mainHsnCode=Cast('' as varchar(2000))
,EWBValidTo=CONVERT(datetime,GETDATE())
,Entry_ty=Cast('' as varchar(2))
,ewbqrcode=CAST(0x as varbinary(max))
into #eWayBillCrystal  where 1=2

print 2
If (@TrnName='Sales')
Begin
	Set @SqlCommand='Insert Into #eWayBillCrystal '
	Set @SqlCommand=@SqlCommand+' '+' select userGstin=cm.GSTIN,docType1=''Tax Invoice'',m.EWBN,EWBDT=m.EWBDT,m.U_TMODE,sm.EWBDIST,EWBVTD=m.EWBVTD,sm.EWBSUPTYP,m.inv_no,[date]=m.date,'
	Set @SqlCommand=@SqlCommand+' '+'itm.HSNCODE,It_Desc=(CASE WHEN ISNULL(itm.it_alias,'''')='''' THEN itm.it_name ELSE itm.it_alias END),'
	Set @SqlCommand=@SqlCommand+' '+'i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,'
	Set @SqlCommand=@SqlCommand+' '+'m.gro_amt,cgst_amt=sum(i.CGST_AMT),sgst_amt=sum(i.SGST_AMT),igst_amt=sum(i.IGST_AMT),'
	Set @SqlCommand=@SqlCommand+' '+'cess_amt=sum(i.COMPCESS),m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,U_LRDT=(case when year(m.U_LRDT)<=1900 then '''' else convert(varchar,m.U_LRDT,103) end),'
	Set @SqlCommand=@SqlCommand+' '+'fromGstin=cm.GSTIN,fromTrdName=cm.MailName'
	Set @SqlCommand=@SqlCommand+' ,fromAddr1=Case When isnull(sm.SHIPTO,'''')<>'''' then lm.Add1 else cm.Add1 End '
	Set @SqlCommand=@SqlCommand+' ,fromAddr2=Case When isnull(sm.SHIPTO,'''')<>'''' then lm.Add2+'' ''+lm.Add3 else cm.Add2+'' ''+Cm.Add3 end'
	Set @SqlCommand=@SqlCommand+' ,fromPlace=Case When isnull(sm.SHIPTO,'''')<>'''' then lm.City else cm.City end'
	Set @SqlCommand=@SqlCommand+' ,fromPincode=Case When isnull(sm.SHIPTO,'''')<>'''' then lm.pincode else cm.ZIP end'
	Set @SqlCommand=@SqlCommand+' ,fromStateCode=Cm.Gst_State_code'
	Set @SqlCommand=@SqlCommand+' ,toGstin=case when buyer_sp.st_type=''OUT OF COUNTRY'' OR buyer_sp.supp_type=''UNREGISTERED'' then ''URP'' ELSE buyer_sp.gstin END '  
	Set @SqlCommand=@SqlCommand+' ,toTrdName=case when buyer_sp.mailname<>'''' then buyer_sp.mailname else buyer_sp.ac_name end'
	Set @SqlCommand=@SqlCommand+' ,toAddr1=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.add1,'''') else isnull(Cons_ac.add1,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,toAddr2=(case WHEN isnull(m.scons_id, 0) > 0 then rtrim(isnull(Cons_sp.add2,''''))+'' ''+rtrim(isnull(Cons_sp.add3,'''')) else rtrim(isnull(Cons_ac.add2,''''))+'' ''+rtrim(isnull(Cons_ac.add3,'''')) end)'
	Set @SqlCommand=@SqlCommand+' ,toPlace=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,toPincode=case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''999999'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.zip,'''') else isnull(Cons_ac.zip,'''') end) END'
	Set @SqlCommand=@SqlCommand+' ,toStateCode=case when buyer_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE buyer_sp.statecode END'  
	Set @SqlCommand=@SqlCommand+' ,actualFromStateCode=Case When isnull(sm.SHIPTO,'''')<>'''' then s.Gst_State_code else Cm.Gst_State_code End'														
	Set @SqlCommand=@SqlCommand+' ,actualToStateCode=case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END'		
	Set @SqlCommand=@SqlCommand+' ,EWBValidFrom=case when year(m.EWBVFD)>1900 then Convert(date,m.EWBVFD) +convert(datetime,m.EWBVFT) else 0 end,SuppTyp=''Outward'''
	Set @SqlCommand=@SqlCommand+' ,mainHsnCode=(Select Top 1 rtrim(c.hsn_code)+''-''+substring(hsn_desc,0,2000) From stitem a inner join it_mast b on (a.it_code=b.it_code) inner join hsn_master c on (b.hsn_id=c.hsn_id) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '
	Set @SqlCommand=@SqlCommand+' ,EWBValidTo=case when year(m.EWBVTD)>1900 then Convert(date,m.EWBVTD) +convert(datetime,m.EWBVTT) else 0 end'
	Set @SqlCommand=@SqlCommand+' ,m.Entry_ty,0x'  
	Set @SqlCommand=@SqlCommand+' '+'From #Co_mast cm,StMain m'
	Set @SqlCommand=@SqlCommand+' '+'Left Join StMainAdd sm on (m.Tran_cd=sm.Tran_Cd)'
	Set @SqlCommand=@SqlCommand+' '+'Inner Join StItem i on (m.Tran_Cd=i.Tran_Cd)'
	Set @SqlCommand=@SqlCommand+' '+'Inner join it_mast itm on (itm.it_code=i.it_code and itm.isservice<>1)'
	Set @SqlCommand=@SqlCommand+' '+'Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
	Set @SqlCommand=@SqlCommand+' '+'Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+'Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
	Set @SqlCommand=@SqlCommand+' '+'Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+'Left join State Cons_ac_st on (Cons_ac_st.State=Cons_ac.State)'
	Set @SqlCommand=@SqlCommand+' '+'Left join State Cons_sp_st on (Cons_sp_st.State=Cons_sp.State)'
	Set @SqlCommand=@SqlCommand+' '+'Left outer Join LOC_MASTER lm on (lm.Loc_Code = sm.SHIPTO)'			
	Set @SqlCommand=@SqlCommand+' Left outer Join [state] s on (lm.state = s.state)'			
	Set @SqlCommand=@SqlCommand+' '+'Where m.Inv_No='+Char(39)+@Inv_No+Char(39)+' and m.Date='''+@Inv_dt+''' and m.Entry_ty='''+@Entry_ty+'''' 
	Set @SqlCommand=@SqlCommand+' '+'group by cm.GSTIN,m.EWBN,m.EWBDT,m.U_TMODE,sm.EWBDIST,m.EWBVTD,sm.EWBSUPTYP,m.inv_no,m.[date],itm.HSNCODE,itm.it_alias,cm.MailName,'
	Set @SqlCommand=@SqlCommand+' '+'itm.it_name,i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,m.gro_amt,m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,m.U_LRDT,'
	Set @SqlCommand=@SqlCommand+' '+'cm.add1,cm.add2,cm.add3,cm.city,cm.zip,cm.Gst_State_Code,m.scons_id,'
	set @SqlCommand=@SqlCommand+' '+'Cons_sp.gstin,Cons_ac.gstin,Cons_sp.mailname,Cons_ac.ac_name,Cons_sp.add1,Cons_ac.add1,Cons_sp.add2,Cons_ac.add2,Cons_sp.city,Cons_ac.city,Cons_sp.zip,Cons_ac.zip,Cons_sp_st.Gst_State_code,Cons_ac_st.Gst_State_code,m.Entry_ty'
	set @SqlCommand=@SqlCommand+' '+',sm.SHIPTO,lm.Add1,lm.add2,lm.add3,lm.City,lm.pincode,buyer_sp.gstin,cm.MailName,buyer_sp.mailname,buyer_sp.ac_name,Cons_sp.add3,Cons_ac.add3,Cons_sp.st_type,Cons_sp.supp_type,buyer_sp.st_type,buyer_sp.supp_type,buyer_sp.Statecode,Cons_sp.Statecode,s.Gst_State_code,m.sac_id,m.EWBVFD,m.EWBVFT,m.Tran_cd,convert(datetime,m.EWBVTT)'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
				
		set @SqlCommand='update a set a.ewbqrcode=b.ewbqrcode from #eWayBillCrystal a inner join stmain b on (a.inv_no=b.inv_no and a.Date=b.date)'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
End

print 3
If (@TrnName='Delivery Challan')
Begin
Set @SqlCommand='Insert Into #eWayBillCrystal '
	Set @SqlCommand=@SqlCommand+' '+' select userGstin=cm.GSTIN,docType1=''Challan'',m.EWBN,EWBDT=m.EWBDT,m.U_TMODE,m.EWBDIST,EWBVTD=m.EWBVTD,m.EWBSUPTYP,m.inv_no,[date]=m.date,'
	Set @SqlCommand=@SqlCommand+' '+'itm.HSNCODE,It_Desc=(CASE WHEN ISNULL(itm.it_alias,'''')='''' THEN itm.it_name ELSE itm.it_alias END),'
	Set @SqlCommand=@SqlCommand+' '+'i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,'
	Set @SqlCommand=@SqlCommand+' '+'m.gro_amt,cgst_amt=sum(i.CGST_AMT),sgst_amt=sum(i.SGST_AMT),igst_amt=sum(i.IGST_AMT),'
	Set @SqlCommand=@SqlCommand+' '+'cess_amt=sum(i.COMPCESS),m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,U_LRDT=(case when year(m.U_LRDT)<=1900 then '''' else convert(varchar,m.U_LRDT,103) end),'
	Set @SqlCommand=@SqlCommand+' '+'fromGstin=cm.GSTIN,fromTrdName=cm.MailName'
	Set @SqlCommand=@SqlCommand+' ,fromAddr1=Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add1 else cm.Add1 End '
	Set @SqlCommand=@SqlCommand+' ,fromAddr2=Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add2+'' ''+lm.Add3 else cm.Add2+'' ''+Cm.Add3 end'
	Set @SqlCommand=@SqlCommand+' ,fromPlace=Case When isnull(m.SHIPTO,'''')<>'''' then lm.City else cm.City end'
	Set @SqlCommand=@SqlCommand+' ,fromPincode=Case When isnull(m.SHIPTO,'''')<>'''' then lm.pincode else cm.ZIP end'
	Set @SqlCommand=@SqlCommand+' ,fromStateCode=Cm.Gst_State_code'
	Set @SqlCommand=@SqlCommand+' ,toGstin=case when buyer_sp.st_type=''OUT OF COUNTRY'' OR buyer_sp.supp_type=''UNREGISTERED'' then ''URP'' ELSE buyer_sp.gstin END '  
	Set @SqlCommand=@SqlCommand+' ,toTrdName=case when buyer_sp.mailname<>'''' then buyer_sp.mailname else buyer_sp.ac_name end'
	Set @SqlCommand=@SqlCommand+' ,toAddr1=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.add1,'''') else isnull(Cons_ac.add1,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,toAddr2=(case WHEN isnull(m.scons_id, 0) > 0 then rtrim(isnull(Cons_sp.add2,''''))+'' ''+rtrim(isnull(Cons_sp.add3,'''')) else rtrim(isnull(Cons_ac.add2,''''))+'' ''+rtrim(isnull(Cons_ac.add3,'''')) end)'
	Set @SqlCommand=@SqlCommand+' ,toPlace=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,toPincode=case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''999999'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.zip,'''') else isnull(Cons_ac.zip,'''') end) END'
	Set @SqlCommand=@SqlCommand+' ,toStateCode=case when buyer_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE buyer_sp.statecode END'  
	Set @SqlCommand=@SqlCommand+' ,actualFromStateCode=Case When isnull(m.SHIPTO,'''')<>'''' then s.Gst_State_code else Cm.Gst_State_code End'														
	Set @SqlCommand=@SqlCommand+' ,actualToStateCode=case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END'		
	Set @SqlCommand=@SqlCommand+' ,EWBValidFrom=case when year(m.EWBVFD)>1900 then Convert(date,m.EWBVFD) +convert(datetime,m.EWBVFT) else 0 end,SuppTyp=''Outward'''
	Set @SqlCommand=@SqlCommand+' ,EWBValidTo=case when year(m.EWBVTD)>1900 then Convert(date,m.EWBVTD) +convert(datetime,m.EWBVTT) else 0 end'
	Set @SqlCommand=@SqlCommand+' ,mainHsnCode=(Select Top 1 rtrim(c.hsn_code)+''-''+substring(hsn_desc,0,2000) From dcitem a inner join it_mast b on (a.it_code=b.it_code) inner join hsn_master c on (b.hsn_id=c.hsn_id) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '
	Set @SqlCommand=@SqlCommand+' ,m.Entry_ty,0x'  
	Set @SqlCommand=@SqlCommand+' '+' From #Co_mast cm,DCMain m'
	Set @SqlCommand=@SqlCommand+' '+' Inner Join DCItem i on (m.Tran_Cd=i.Tran_Cd)'
	Set @SqlCommand=@SqlCommand+' '+' Inner join it_mast itm on (itm.it_code=i.it_code and itm.isservice<>1)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_ac_st on (Cons_ac_st.State=Cons_ac.State)'
	Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_sp_st on (Cons_sp_st.State=Cons_sp.State)'
	Set @SqlCommand=@SqlCommand+' '+'Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'			
	Set @SqlCommand=@SqlCommand+' Left outer Join [state] s on (lm.state = s.state)'			
	Set @SqlCommand=@SqlCommand+' '+'Where m.Inv_No='+Char(39)+@Inv_No+Char(39)+' and m.Date='''+@Inv_dt+''' and m.Entry_ty='''+@Entry_ty+'''' 
	Set @SqlCommand=@SqlCommand+' '+'group by cm.GSTIN,m.EWBN,m.EWBDT,m.U_TMODE,m.EWBDIST,m.EWBVTD,m.EWBSUPTYP,m.inv_no,m.[date],itm.HSNCODE,itm.it_alias,cm.MailName,'
	Set @SqlCommand=@SqlCommand+' '+'itm.it_name,i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,m.gro_amt,m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,m.U_LRDT,'
	Set @SqlCommand=@SqlCommand+' '+'cm.add1,cm.add2,cm.add3,cm.city,cm.zip,cm.Gst_State_Code,m.scons_id,'
	set @SqlCommand=@SqlCommand+' '+'Cons_sp.gstin,Cons_ac.gstin,Cons_sp.mailname,Cons_ac.ac_name,Cons_sp.add1,Cons_ac.add1,Cons_sp.add2,Cons_ac.add2,Cons_sp.city,Cons_ac.city,Cons_sp.zip,Cons_ac.zip,Cons_sp_st.Gst_State_code,Cons_ac_st.Gst_State_code,m.Entry_ty'
	set @SqlCommand=@SqlCommand+' '+',m.SHIPTO,lm.Add1,lm.add2,lm.add3,lm.City,lm.pincode,buyer_sp.gstin,cm.MailName,buyer_sp.mailname,buyer_sp.ac_name,Cons_sp.add3,Cons_ac.add3,Cons_sp.st_type,Cons_sp.supp_type,buyer_sp.st_type,buyer_sp.supp_type,buyer_sp.Statecode,Cons_sp.Statecode,s.Gst_State_code,m.sac_id,m.EWBVFD,m.EWBVFT,m.Tran_cd,m.EWBVTT'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
		set @SqlCommand='update a set a.ewbqrcode=b.ewbqrcode from #eWayBillCrystal a inner join dcmain b on (a.inv_no=b.inv_no and a.Date=b.date)'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
end

print 4
If (@TrnName='Purchase')
Begin
Set @SqlCommand='Insert Into #eWayBillCrystal '
	Set @SqlCommand=@SqlCommand+' '+' select userGstin=cm.GSTIN,docType1=(Case when m.Entry_ty=''P1'' Then ''Bill of Entry'' Else ''Bill of Supply'' end),m.EWBN,EWBDT=m.EWBDT,m.U_TMODE,m.EWBDIST,EWBVTD=m.EWBVTD,m.EWBSUPTYP,m.inv_no,[date]=m.date,'
	Set @SqlCommand=@SqlCommand+' '+'itm.HSNCODE,It_Desc=(CASE WHEN ISNULL(itm.it_alias,'''')='''' THEN itm.it_name ELSE itm.it_alias END),'
	Set @SqlCommand=@SqlCommand+' '+'i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,'
	Set @SqlCommand=@SqlCommand+' '+'m.gro_amt,cgst_amt=sum(i.CGST_AMT),sgst_amt=sum(i.SGST_AMT),igst_amt=sum(i.IGST_AMT),'
	Set @SqlCommand=@SqlCommand+' '+'cess_amt=sum(i.COMPCESS),m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,U_LRDT=(case when year(m.U_LRDT)<=1900 then '''' else convert(varchar,m.U_LRDT,103) end)'
	Set @SqlCommand=@SqlCommand+' ,fromGstin=case when buyer_sp.st_type=''OUT OF COUNTRY'' OR buyer_sp.supp_type=''UNREGISTERED'' then ''URP'' ELSE buyer_sp.gstin END '
	Set @SqlCommand=@SqlCommand+' ,fromTrdName=case when buyer_sp.mailname<>'''' then buyer_sp.mailname else buyer_sp.ac_name end'
	Set @SqlCommand=@SqlCommand+' ,fromAddr1=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.add1,'''') else isnull(Cons_ac.add1,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,fromAddr2=(case WHEN isnull(m.scons_id, 0) > 0 then rtrim(isnull(Cons_sp.add2,''''))+'' ''+rtrim(isnull(Cons_sp.add3,'''')) else rtrim(isnull(Cons_ac.add2,''''))+'' ''+rtrim(isnull(Cons_ac.add3,'''')) end)'
	Set @SqlCommand=@SqlCommand+' ,fromPlace=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,fromPincode=(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''999999'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.zip,'''') else isnull(Cons_ac.zip,'''') end)  END)'
	Set @SqlCommand=@SqlCommand+' ,fromStateCode=(case when buyer_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.sac_id, 0) > 0 then isnull(buyer_sp.Statecode,'''') else isnull(Cons_sp.Statecode,'''') end) END)'
	Set @SqlCommand=@SqlCommand+' ,toGstin=cm.GSTIN'  
	Set @SqlCommand=@SqlCommand+' ,toTrdName=cm.MailName'
	Set @SqlCommand=@SqlCommand+' ,toAddr1=Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add1 else cm.Add1 end'
	Set @SqlCommand=@SqlCommand+' ,toAddr2=Case When isnull(m.SHIPTO,'''')<>'''' then rtrim(lm.Add2)+'' ''+rtrim(lm.Add3) else rtrim(cm.Add2)+'' ''+rtrim(cm.Add3) END'
	Set @SqlCommand=@SqlCommand+' ,toPlace=Case When isnull(m.SHIPTO,'''')<>'''' then lm.city else cm.City end'
	Set @SqlCommand=@SqlCommand+' ,toPincode=Case When isnull(m.SHIPTO,'''')<>'''' then lm.pincode else cm.ZIP end'
	Set @SqlCommand=@SqlCommand+' ,toStateCode=cm.Gst_State_Code'  
	Set @SqlCommand=@SqlCommand+' ,actualFromStateCode=(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END)'		--Added by Shrikant S. on 18/05/2018 for Bug-31516
	Set @SqlCommand=@SqlCommand+' ,actualToStateCode=(Case When isnull(m.SHIPTO,'''')<>'''' then s.Gst_State_code else Cm.Gst_State_code End) '														--Added by Shrikant S. on 18/05/2018 for Bug-31516
	Set @SqlCommand=@SqlCommand+' ,EWBValidFrom=case when year(m.EWBVFD)>1900 then Convert(date,m.EWBVFD) +convert(datetime,m.EWBVFT) else 0 end,SuppTyp=''Inward'''
	Set @SqlCommand=@SqlCommand+' ,EWBValidTo=case when year(m.EWBVTD)>1900 then Convert(date,m.EWBVTD) +convert(datetime,m.EWBVTT) else 0 end'
	Set @SqlCommand=@SqlCommand+' ,mainHsnCode=(Select Top 1 rtrim(c.hsn_code)+''-''+substring(hsn_desc,0,2000) From ptitem a inner join it_mast b on (a.it_code=b.it_code) inner join hsn_master c on (b.hsn_id=c.hsn_id) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '
	Set @SqlCommand=@SqlCommand+' ,m.Entry_ty,0x'  
	Set @SqlCommand=@SqlCommand+' '+' From #Co_mast cm,ptmain m'
	Set @SqlCommand=@SqlCommand+' '+' Inner Join ptitem i on (m.Tran_Cd=i.Tran_Cd)'
	Set @SqlCommand=@SqlCommand+' '+' Inner join it_mast itm on (itm.it_code=i.it_code and itm.isservice<>1)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_ac_st on (Cons_ac_st.State=Cons_ac.State)'
	Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_sp_st on (Cons_sp_st.State=Cons_sp.State)'
	Set @SqlCommand=@SqlCommand+' '+'Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'			
	Set @SqlCommand=@SqlCommand+' Left outer Join [state] s on (lm.state = s.state)'			
	Set @SqlCommand=@SqlCommand+' '+'Where m.Inv_No='+Char(39)+@Inv_No+Char(39)+' and m.Date='''+@Inv_dt+''' and m.Entry_ty='''+@Entry_ty+'''' 
	Set @SqlCommand=@SqlCommand+' '+'group by cm.GSTIN,m.EWBN,m.EWBDT,m.U_TMODE,m.EWBDIST,m.EWBVTD,m.EWBSUPTYP,m.inv_no,m.[date],itm.HSNCODE,itm.it_alias,cm.MailName,'
	Set @SqlCommand=@SqlCommand+' '+'itm.it_name,i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,m.gro_amt,m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,m.U_LRDT,'
	Set @SqlCommand=@SqlCommand+' '+'cm.add1,cm.add2,cm.add3,cm.city,cm.zip,cm.Gst_State_Code,m.scons_id,Cons_sp.add3,Cons_ac.add3,m.Entry_ty,'
	set @SqlCommand=@SqlCommand+' '+'Cons_sp.gstin,Cons_ac.gstin,Cons_sp.mailname,Cons_ac.ac_name,Cons_sp.add1,Cons_ac.add1,Cons_sp.add2,Cons_ac.add2,Cons_sp.city,Cons_ac.city,Cons_sp.zip,Cons_ac.zip,Cons_sp_st.Gst_State_code,Cons_ac_st.Gst_State_code,m.Entry_ty'
	set @SqlCommand=@SqlCommand+' '+',m.SHIPTO,lm.Add1,lm.add2,lm.add3,lm.City,lm.pincode,buyer_sp.gstin,cm.MailName,buyer_sp.mailname,buyer_sp.ac_name,Cons_sp.add3,Cons_ac.add3,Cons_sp.st_type,Cons_sp.supp_type,buyer_sp.st_type,buyer_sp.supp_type,buyer_sp.Statecode,Cons_sp.Statecode,s.Gst_State_code,m.sac_id,m.EWBVFD,m.EWBVFT,m.Tran_cd,m.EWBVTT'
	Print @SqlCommand
	Execute sp_Executesql @SqlCommand
	set @SqlCommand='update a set a.ewbqrcode=b.ewbqrcode from #eWayBillCrystal a inner join ptmain b on (a.inv_no=b.inv_no and a.Date=b.date)'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
end

If (@TrnName='Goods Receipt')
Begin
	Set @SqlCommand='Insert Into #eWayBillCrystal '
	Set @SqlCommand=@SqlCommand+' '+' select userGstin=cm.GSTIN,docType1=''BIL'',m.EWBN,EWBDT=m.EWBDT,m.U_TMODE,m.EWBDIST,EWBVTD=m.EWBVTD,m.EWBSUPTYP,m.inv_no,[date]=m.date,'
	Set @SqlCommand=@SqlCommand+' '+'itm.HSNCODE,It_Desc=(CASE WHEN ISNULL(itm.it_alias,'''')='''' THEN itm.it_name ELSE itm.it_alias END),'
	Set @SqlCommand=@SqlCommand+' '+'i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,'
	Set @SqlCommand=@SqlCommand+' '+'m.gro_amt,cgst_amt=sum(i.CGST_AMT),sgst_amt=sum(i.SGST_AMT),igst_amt=sum(i.IGST_AMT),'
	Set @SqlCommand=@SqlCommand+' '+'cess_amt=sum(i.COMPCESS),m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,U_LRDT=(case when year(m.U_LRDT)<=1900 then '''' else convert(varchar,m.U_LRDT,103) end)'
	Set @SqlCommand=@SqlCommand+' ,fromGstin=case when buyer_sp.st_type=''OUT OF COUNTRY'' OR buyer_sp.supp_type=''UNREGISTERED'' then ''URP'' ELSE buyer_sp.gstin END '
	Set @SqlCommand=@SqlCommand+' ,fromTrdName=case when buyer_sp.mailname<>'''' then buyer_sp.mailname else buyer_sp.ac_name end'
	Set @SqlCommand=@SqlCommand+' ,fromAddr1=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.add1,'''') else isnull(Cons_ac.add1,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,fromAddr2=(case WHEN isnull(m.scons_id, 0) > 0 then rtrim(isnull(Cons_sp.add2,''''))+'' ''+rtrim(isnull(Cons_sp.add3,'''')) else rtrim(isnull(Cons_ac.add2,''''))+'' ''+rtrim(isnull(Cons_ac.add3,'''')) end)'
	Set @SqlCommand=@SqlCommand+' ,fromPlace=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,fromPincode=(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''999999'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.zip,'''') else isnull(Cons_ac.zip,'''') end)  END)'
	Set @SqlCommand=@SqlCommand+' ,fromStateCode=(case when buyer_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.sac_id, 0) > 0 then isnull(buyer_sp.Statecode,'''') else isnull(Cons_sp.Statecode,'''') end) END)'
	Set @SqlCommand=@SqlCommand+' ,toGstin=cm.GSTIN'  
	Set @SqlCommand=@SqlCommand+' ,toTrdName=cm.MailName'
	Set @SqlCommand=@SqlCommand+' ,toAddr1=Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add1 else cm.Add1 end'
	Set @SqlCommand=@SqlCommand+' ,toAddr2=Case When isnull(m.SHIPTO,'''')<>'''' then rtrim(lm.Add2)+'' ''+rtrim(lm.Add3) else rtrim(cm.Add2)+'' ''+rtrim(cm.Add3) END'
	Set @SqlCommand=@SqlCommand+' ,toPlace=Case When isnull(m.SHIPTO,'''')<>'''' then lm.city else cm.City end'
	Set @SqlCommand=@SqlCommand+' ,toPincode=Case When isnull(m.SHIPTO,'''')<>'''' then lm.pincode else cm.ZIP end'
	Set @SqlCommand=@SqlCommand+' ,toStateCode=cm.Gst_State_Code'  
	Set @SqlCommand=@SqlCommand+' ,actualFromStateCode=(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END)'		--Added by Shrikant S. on 18/05/2018 for Bug-31516
	Set @SqlCommand=@SqlCommand+' ,actualToStateCode=(Case When isnull(m.SHIPTO,'''')<>'''' then s.Gst_State_code else Cm.Gst_State_code End) '														--Added by Shrikant S. on 18/05/2018 for Bug-31516
	Set @SqlCommand=@SqlCommand+' ,EWBValidFrom=case when year(m.EWBVFD)>1900 then Convert(date,m.EWBVFD) +convert(datetime,m.EWBVFT) else 0 end,SuppTyp=''Inward'''
	Set @SqlCommand=@SqlCommand+' ,EWBValidTo=case when year(m.EWBVTD)>1900 then Convert(date,m.EWBVTD) +convert(datetime,m.EWBVTT) else 0 end'
	Set @SqlCommand=@SqlCommand+' ,mainHsnCode=(Select Top 1 rtrim(c.hsn_code)+''-''+substring(hsn_desc,0,2000) From aritem a inner join it_mast b on (a.it_code=b.it_code) inner join hsn_master c on (b.hsn_id=c.hsn_id) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '
	Set @SqlCommand=@SqlCommand+' ,m.Entry_ty,0x'  
	Set @SqlCommand=@SqlCommand+' '+' From #Co_mast cm,ARmain m'
	Set @SqlCommand=@SqlCommand+' '+' Inner Join ARitem i on (m.Tran_Cd=i.Tran_Cd)'
	Set @SqlCommand=@SqlCommand+' '+' Inner join it_mast itm on (itm.it_code=i.it_code and itm.isservice<>1)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_ac_st on (Cons_ac_st.State=Cons_ac.State)'
	Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_sp_st on (Cons_sp_st.State=Cons_sp.State)'
	Set @SqlCommand=@SqlCommand+' '+'Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'
	Set @SqlCommand=@SqlCommand+' Left outer Join [state] s on (lm.state = s.state)'						
	Set @SqlCommand=@SqlCommand+' '+'Where m.Inv_No='+Char(39)+@Inv_No+Char(39)+' and m.Date='''+@Inv_dt+''' and m.Entry_ty='''+@Entry_ty+'''' 
	Set @SqlCommand=@SqlCommand+' '+'group by cm.GSTIN,m.EWBN,m.EWBDT,m.U_TMODE,m.EWBDIST,m.EWBVTD,m.EWBSUPTYP,m.inv_no,m.[date],itm.HSNCODE,itm.it_alias,cm.MailName,'
	Set @SqlCommand=@SqlCommand+' '+'itm.it_name,i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,m.gro_amt,m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,m.U_LRDT,'
	Set @SqlCommand=@SqlCommand+' '+'cm.add1,cm.add2,cm.add3,cm.city,cm.zip,cm.Gst_State_Code,m.scons_id,Cons_sp.add3,Cons_ac.add3,m.Entry_ty,'
	set @SqlCommand=@SqlCommand+' '+'Cons_sp.gstin,Cons_ac.gstin,Cons_sp.mailname,Cons_ac.ac_name,Cons_sp.add1,Cons_ac.add1,Cons_sp.add2,Cons_ac.add2,Cons_sp.city,Cons_ac.city,Cons_sp.zip,Cons_ac.zip,Cons_sp_st.Gst_State_code,Cons_ac_st.Gst_State_code,m.Entry_ty'
	set @SqlCommand=@SqlCommand+' '+',m.SHIPTO,lm.Add1,lm.add2,lm.add3,lm.City,lm.pincode,buyer_sp.gstin,cm.MailName,buyer_sp.mailname,buyer_sp.ac_name,Cons_sp.add3,Cons_ac.add3,Cons_sp.st_type,Cons_sp.supp_type,buyer_sp.st_type,buyer_sp.supp_type,buyer_sp.Statecode,Cons_sp.Statecode,s.Gst_State_code,m.sac_id,m.EWBVFD,m.EWBVFT,m.Tran_cd,m.EWBVTT'
	Print @SqlCommand
	Execute sp_Executesql @SqlCommand
		set @SqlCommand='update a set a.ewbqrcode=b.ewbqrcode from #eWayBillCrystal a inner join armain b on (a.inv_no=b.inv_no  and a.Date=b.date)'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
end

If (@TrnName='LABOUR JOB ISSUE[V]' or @TrnName='LABOUR JOB ISSUE[IV]') /*Both 4 & 5 LI/IL*/
Begin
	Set @SqlCommand='Insert Into #eWayBillCrystal '
	Set @SqlCommand=@SqlCommand+' '+' select userGstin=cm.GSTIN,docType1=''Challan'',m.EWBN,EWBDT=m.EWBDT,m.U_TMODE,m.EWBDIST,EWBVTD=m.EWBVTD,m.EWBSUPTYP,m.inv_no,[date]=m.date,'
	Set @SqlCommand=@SqlCommand+' '+'itm.HSNCODE,It_Desc=(CASE WHEN ISNULL(itm.it_alias,'''')='''' THEN itm.it_name ELSE itm.it_alias END),'
	Set @SqlCommand=@SqlCommand+' '+'i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,'
	Set @SqlCommand=@SqlCommand+' '+'m.gro_amt,cgst_amt=sum(i.CGST_AMT),sgst_amt=sum(i.SGST_AMT),igst_amt=sum(i.IGST_AMT),'
	Set @SqlCommand=@SqlCommand+' '+'cess_amt=sum(i.COMPCESS),m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,U_LRDT=(case when year(m.U_LRDT)<=1900 then '''' else convert(varchar,m.U_LRDT,103) end),'
	Set @SqlCommand=@SqlCommand+' '+'fromGstin=cm.GSTIN,fromTrdName=cm.MailName'
	Set @SqlCommand=@SqlCommand+' ,fromAddr1=Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add1 else cm.Add1 End '
	Set @SqlCommand=@SqlCommand+' ,fromAddr2=Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add2+'' ''+lm.Add3 else cm.Add2+'' ''+Cm.Add3 end'
	Set @SqlCommand=@SqlCommand+' ,fromPlace=Case When isnull(m.SHIPTO,'''')<>'''' then lm.City else cm.City end'
	Set @SqlCommand=@SqlCommand+' ,fromPincode=Case When isnull(m.SHIPTO,'''')<>'''' then lm.pincode else cm.ZIP end'
	Set @SqlCommand=@SqlCommand+' ,fromStateCode=Cm.Gst_State_code'
	Set @SqlCommand=@SqlCommand+' ,toGstin=case when buyer_sp.st_type=''OUT OF COUNTRY'' OR buyer_sp.supp_type=''UNREGISTERED'' then ''URP'' ELSE buyer_sp.gstin END '  
	Set @SqlCommand=@SqlCommand+' ,toTrdName=case when buyer_sp.mailname<>'''' then buyer_sp.mailname else buyer_sp.ac_name end'
	Set @SqlCommand=@SqlCommand+' ,toAddr1=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.add1,'''') else isnull(Cons_ac.add1,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,toAddr2=(case WHEN isnull(m.scons_id, 0) > 0 then rtrim(isnull(Cons_sp.add2,''''))+'' ''+rtrim(isnull(Cons_sp.add3,'''')) else rtrim(isnull(Cons_ac.add2,''''))+'' ''+rtrim(isnull(Cons_ac.add3,'''')) end)'
	Set @SqlCommand=@SqlCommand+' ,toPlace=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end)'
	Set @SqlCommand=@SqlCommand+' ,toPincode=case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''999999'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.zip,'''') else isnull(Cons_ac.zip,'''') end) END'
	Set @SqlCommand=@SqlCommand+' ,toStateCode=case when buyer_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE buyer_sp.statecode END'  
	Set @SqlCommand=@SqlCommand+' ,actualFromStateCode=Case When isnull(m.SHIPTO,'''')<>'''' then s.Gst_State_code else Cm.Gst_State_code End'														
	Set @SqlCommand=@SqlCommand+' ,actualToStateCode=case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END'		
	Set @SqlCommand=@SqlCommand+' ,EWBValidFrom=case when year(m.EWBVFD)>1900 then Convert(date,m.EWBVFD) +convert(datetime,m.EWBVFT) else 0 end,SuppTyp=''Outward'''
	Set @SqlCommand=@SqlCommand+' ,EWBValidTo=case when year(m.EWBVTD)>1900 then Convert(date,m.EWBVTD) +convert(datetime,m.EWBVTT) else 0 end'
	Set @SqlCommand=@SqlCommand+' ,mainHsnCode=(Select Top 1 rtrim(c.hsn_code)+''-''+substring(hsn_desc,0,2000) From iiitem a inner join it_mast b on (a.it_code=b.it_code) inner join hsn_master c on (b.hsn_id=c.hsn_id) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '
	Set @SqlCommand=@SqlCommand+' ,m.Entry_ty,0x'  
	Set @SqlCommand=@SqlCommand+' '+' From #Co_mast cm,IIMain m'
	Set @SqlCommand=@SqlCommand+' '+' Inner Join IIItem i on (m.Tran_Cd=i.Tran_Cd)'
	Set @SqlCommand=@SqlCommand+' '+' Inner join it_mast itm on (itm.it_code=i.it_code and itm.isservice<>1)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
	Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_ac_st on (Cons_ac_st.State=Cons_ac.State)'
	Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_sp_st on (Cons_sp_st.State=Cons_sp.State)'
	Set @SqlCommand=@SqlCommand+' '+'Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'			
	Set @SqlCommand=@SqlCommand+' Left outer Join [state] s on (lm.state = s.state)'			
	Set @SqlCommand=@SqlCommand+' '+'Where m.Inv_No='+Char(39)+@Inv_No+Char(39)+' and m.Date='''+@Inv_dt+''' and m.Entry_ty='''+@Entry_ty+'''' 
	If (@TrnName='LABOUR JOB ISSUE[V]') Begin Set @SqlCommand=@SqlCommand+' and m.Entry_ty=''IL''' End 
										Else Begin Set @SqlCommand=@SqlCommand+' and m.Entry_ty=''LI''' End
	Set @SqlCommand=@SqlCommand+' '+'group by cm.GSTIN,m.EWBN,m.EWBDT,m.U_TMODE,m.EWBDIST,m.EWBVTD,m.EWBSUPTYP,m.inv_no,m.[date],itm.HSNCODE,itm.it_alias,cm.MailName,'
	Set @SqlCommand=@SqlCommand+' '+'itm.it_name,i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,m.gro_amt,m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,m.U_LRDT,'
	Set @SqlCommand=@SqlCommand+' '+'cm.add1,cm.add2,cm.add3,cm.city,cm.zip,cm.Gst_State_Code,m.scons_id,Cons_sp.add3,Cons_ac.add3,m.Entry_ty,'
	set @SqlCommand=@SqlCommand+' '+'Cons_sp.gstin,Cons_ac.gstin,Cons_sp.mailname,Cons_ac.ac_name,Cons_sp.add1,Cons_ac.add1,Cons_sp.add2,Cons_ac.add2,Cons_sp.city,Cons_ac.city,Cons_sp.zip,Cons_ac.zip,Cons_sp_st.Gst_State_code,Cons_ac_st.Gst_State_code,m.Entry_ty'
	set @SqlCommand=@SqlCommand+' '+',m.SHIPTO,lm.Add1,lm.add2,lm.add3,lm.City,lm.pincode,buyer_sp.gstin,cm.MailName,buyer_sp.mailname,buyer_sp.ac_name,Cons_sp.add3,Cons_ac.add3,Cons_sp.st_type,Cons_sp.supp_type,buyer_sp.st_type,buyer_sp.supp_type,buyer_sp.Statecode,Cons_sp.Statecode,s.Gst_State_code,m.sac_id,m.EWBVFD,m.EWBVFT,m.Tran_cd,m.EWBVTT'
	Print @SqlCommand
	Execute sp_Executesql @SqlCommand
		set @SqlCommand='update a set a.ewbqrcode=b.ewbqrcode from #eWayBillCrystal a inner join IImain b on (a.inv_no=b.inv_no and a.Date=b.date)'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
end

If (@TrnName='LABOUR JOB RECEIPT[IV]' or @TrnName='LABOUR JOB RECEIPT[V]') 
	Begin
		Set @SqlCommand='Insert Into #eWayBillCrystal '
		Set @SqlCommand=@SqlCommand+' '+' select userGstin=cm.GSTIN,docType1=''Challan'',m.EWBN,EWBDT=m.EWBDT,m.U_TMODE,m.EWBDIST,EWBVTD=m.EWBVTD,m.EWBSUPTYP,m.inv_no,[date]=m.date,'
		Set @SqlCommand=@SqlCommand+' '+'itm.HSNCODE,It_Desc=(CASE WHEN ISNULL(itm.it_alias,'''')='''' THEN itm.it_name ELSE itm.it_alias END),'
		Set @SqlCommand=@SqlCommand+' '+'i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,'
		Set @SqlCommand=@SqlCommand+' '+'m.gro_amt,cgst_amt=sum(i.CGST_AMT),sgst_amt=sum(i.SGST_AMT),igst_amt=sum(i.IGST_AMT),'
		Set @SqlCommand=@SqlCommand+' '+'cess_amt=sum(i.COMPCESS),m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,U_LRDT=(case when year(m.U_LRDT)<=1900 then '''' else convert(varchar,m.U_LRDT,103) end)'
		Set @SqlCommand=@SqlCommand+' ,fromGstin=case when buyer_sp.st_type=''OUT OF COUNTRY'' OR buyer_sp.supp_type=''UNREGISTERED'' then ''URP'' ELSE buyer_sp.gstin END '
		Set @SqlCommand=@SqlCommand+' ,fromTrdName=case when buyer_sp.mailname<>'''' then buyer_sp.mailname else buyer_sp.ac_name end'
		Set @SqlCommand=@SqlCommand+' ,fromAddr1=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.add1,'''') else isnull(Cons_ac.add1,'''') end)'
		Set @SqlCommand=@SqlCommand+' ,fromAddr2=(case WHEN isnull(m.scons_id, 0) > 0 then rtrim(isnull(Cons_sp.add2,''''))+'' ''+rtrim(isnull(Cons_sp.add3,'''')) else rtrim(isnull(Cons_ac.add2,''''))+'' ''+rtrim(isnull(Cons_ac.add3,'''')) end)'
		Set @SqlCommand=@SqlCommand+' ,fromPlace=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end)'
		Set @SqlCommand=@SqlCommand+' ,fromPincode=(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''999999'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.zip,'''') else isnull(Cons_ac.zip,'''') end)  END)'
		Set @SqlCommand=@SqlCommand+' ,fromStateCode=(case when buyer_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.sac_id, 0) > 0 then isnull(buyer_sp.Statecode,'''') else isnull(Cons_sp.Statecode,'''') end) END)'
		Set @SqlCommand=@SqlCommand+' ,toGstin=cm.GSTIN'  
		Set @SqlCommand=@SqlCommand+' ,toTrdName=cm.MailName'
		Set @SqlCommand=@SqlCommand+' ,toAddr1=Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add1 else cm.Add1 end'
		Set @SqlCommand=@SqlCommand+' ,toAddr2=Case When isnull(m.SHIPTO,'''')<>'''' then rtrim(lm.Add2)+'' ''+rtrim(lm.Add3) else rtrim(cm.Add2)+'' ''+rtrim(cm.Add3) END'
		Set @SqlCommand=@SqlCommand+' ,toPlace=Case When isnull(m.SHIPTO,'''')<>'''' then lm.city else cm.City end'
		Set @SqlCommand=@SqlCommand+' ,toPincode=Case When isnull(m.SHIPTO,'''')<>'''' then lm.pincode else cm.ZIP end'
		Set @SqlCommand=@SqlCommand+' ,toStateCode=cm.Gst_State_Code'  
		Set @SqlCommand=@SqlCommand+' ,actualFromStateCode=(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END)'		--Added by Shrikant S. on 18/05/2018 for Bug-31516
		Set @SqlCommand=@SqlCommand+' ,actualToStateCode=(Case When isnull(m.SHIPTO,'''')<>'''' then s.Gst_State_code else Cm.Gst_State_code End) '														--Added by Shrikant S. on 18/05/2018 for Bug-31516
		Set @SqlCommand=@SqlCommand+' ,EWBValidFrom=case when year(m.EWBVFD)>1900 then Convert(date,m.EWBVFD) +convert(datetime,m.EWBVFT) else 0 end,SuppTyp=''Inward'''
		Set @SqlCommand=@SqlCommand+' ,EWBValidTo=case when year(m.EWBVTD)>1900 then Convert(date,m.EWBVTD) +convert(datetime,m.EWBVTT) else 0 end'
		Set @SqlCommand=@SqlCommand+' ,mainHsnCode=(Select Top 1 rtrim(c.hsn_code)+''-''+substring(hsn_desc,0,2000) From iritem a inner join it_mast b on (a.it_code=b.it_code) inner join hsn_master c on (b.hsn_id=c.hsn_id) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '
		Set @SqlCommand=@SqlCommand+' ,m.Entry_ty,0x'  
		Set @SqlCommand=@SqlCommand+' '+' From #Co_mast cm,IRMain m'
		Set @SqlCommand=@SqlCommand+' '+' Inner Join IRItem i on (m.Tran_Cd=i.Tran_Cd)'
		Set @SqlCommand=@SqlCommand+' '+' Inner join it_mast itm on (itm.it_code=i.it_code and itm.isservice<>1)'
		Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_ac_st on (Cons_ac_st.State=Cons_ac.State)'
		Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_sp_st on (Cons_sp_st.State=Cons_sp.State)'
		Set @SqlCommand=@SqlCommand+' '+'Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'			
		Set @SqlCommand=@SqlCommand+' Left outer Join [state] s on (lm.state = s.state)'			
		Set @SqlCommand=@SqlCommand+' '+'Where m.Inv_No='+Char(39)+@Inv_No+Char(39)+' and m.Date='''+@Inv_dt+''' and m.Entry_ty='''+@Entry_ty+'''' 
		If (@TrnName='LABOUR JOB RECEIPT[IV]') Begin Set @SqlCommand=@SqlCommand+' and m.Entry_ty=''LR''' End 
											   Else Begin Set @SqlCommand=@SqlCommand+' and m.Entry_ty=''RL''' End
		Set @SqlCommand=@SqlCommand+' '+'group by cm.GSTIN,m.EWBN,m.EWBDT,m.U_TMODE,m.EWBDIST,m.EWBVTD,m.EWBSUPTYP,m.inv_no,m.[date],itm.HSNCODE,itm.it_alias,cm.MailName,'
		Set @SqlCommand=@SqlCommand+' '+'itm.it_name,i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,m.gro_amt,m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,m.U_LRDT,'
		Set @SqlCommand=@SqlCommand+' '+'cm.add1,cm.add2,cm.add3,cm.city,cm.zip,cm.Gst_State_Code,m.scons_id,Cons_sp.add3,Cons_ac.add3,m.Entry_ty,'
		set @SqlCommand=@SqlCommand+' '+'Cons_sp.gstin,Cons_ac.gstin,Cons_sp.mailname,Cons_ac.ac_name,Cons_sp.add1,Cons_ac.add1,Cons_sp.add2,Cons_ac.add2,Cons_sp.city,Cons_ac.city,Cons_sp.zip,Cons_ac.zip,Cons_sp_st.Gst_State_code,Cons_ac_st.Gst_State_code,m.Entry_ty'
		set @SqlCommand=@SqlCommand+' '+',m.SHIPTO,lm.Add1,lm.add2,lm.add3,lm.City,lm.pincode,buyer_sp.gstin,cm.MailName,buyer_sp.mailname,buyer_sp.ac_name,Cons_sp.add3,Cons_ac.add3,Cons_sp.st_type,Cons_sp.supp_type,buyer_sp.st_type,buyer_sp.supp_type,buyer_sp.Statecode,Cons_sp.Statecode,s.Gst_State_code,m.sac_id,m.EWBVFD,m.EWBVFT,m.Tran_cd,m.EWBVTT'
		Print @SqlCommand
		Execute sp_Executesql @SqlCommand
			set @SqlCommand='update a set a.ewbqrcode=b.ewbqrcode from #eWayBillCrystal a inner join IRmain b on (a.inv_no=b.inv_no and a.Date=b.date)'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
end

If (@TrnName='CREDIT NOTE')
	Begin
		Set @SqlCommand='Insert Into #eWayBillCrystal '
		Set @SqlCommand=@SqlCommand+' '+' select userGstin=cm.GSTIN,docType1=''Credit Note'',m.EWBN,EWBDT=m.EWBDT,m.U_TMODE,m.EWBDIST,EWBVTD=m.EWBVTD,m.EWBSUPTYPC,m.inv_no,[date]=m.date,'
		Set @SqlCommand=@SqlCommand+' '+'itm.HSNCODE,It_Desc=(CASE WHEN ISNULL(itm.it_alias,'''')='''' THEN itm.it_name ELSE itm.it_alias END),'
		Set @SqlCommand=@SqlCommand+' '+'i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,'
		Set @SqlCommand=@SqlCommand+' '+'m.gro_amt,cgst_amt=sum(i.CGST_AMT),sgst_amt=sum(i.SGST_AMT),igst_amt=sum(i.IGST_AMT),'
		Set @SqlCommand=@SqlCommand+' '+'cess_amt=sum(i.COMPCESS),m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,U_LRDT=(case when year(m.U_LRDT)<=1900 then '''' else convert(varchar,m.U_LRDT,103) end)'
		Set @SqlCommand=@SqlCommand+' '+',fromGstin=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(case when buyer_sp.st_type=''OUT OF COUNTRY'' OR buyer_sp.supp_type=''UNREGISTERED'' then ''URP'' ELSE buyer_sp.gstin END) ELSE cm.GSTIN END)'
		Set @SqlCommand=@SqlCommand+' '+',fromTrdName=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(case when buyer_sp.mailname<>'''' then buyer_sp.mailname else buyer_sp.ac_name end) ELSE cm.MailName END )'
		Set @SqlCommand=@SqlCommand+' '+',fromAddr1=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.add1,'''') else isnull(Cons_ac.add1,'''') end) '
		Set @SqlCommand=@SqlCommand+' '+'ELSE (Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add1 else cm.Add1 End)	END )'
		Set @SqlCommand=@SqlCommand+' '+',fromAddr2=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(case WHEN isnull(m.scons_id, 0) > 0 then rtrim(isnull(Cons_sp.add2,''''))+'' ''+rtrim(isnull(Cons_sp.add3,'''')) else rtrim(isnull(Cons_ac.add2,''''))+'' ''+rtrim(isnull(Cons_ac.add3,'''')) end)'
		Set @SqlCommand=@SqlCommand+' '+' 	ELSE (Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add2+'' ''+lm.Add3 else cm.Add2+'' ''+Cm.Add3 end) END) '
		Set @SqlCommand=@SqlCommand+' '+',fromPlace=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end)'
		Set @SqlCommand=@SqlCommand+' '+'ELSE (Case When isnull(m.SHIPTO,'''')<>'''' then lm.City else cm.City end) END)'
		Set @SqlCommand=@SqlCommand+' '+',fromPincode=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''999999'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.zip,'''') else isnull(Cons_ac.zip,'''') end)  END)'
		Set @SqlCommand=@SqlCommand+' '+'ELSE 	(Case When isnull(m.SHIPTO,'''')<>'''' then lm.pincode else cm.ZIP end)   END)'
		Set @SqlCommand=@SqlCommand+' '+',fromState=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(case when buyer_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.sac_id, 0) > 0 then isnull(buyer_sp.Statecode,'''') else isnull(Cons_sp.Statecode,'''') end) END)'
		Set @SqlCommand=@SqlCommand+' '+'ELSE Cm.Gst_State_code END )	'
		Set @SqlCommand=@SqlCommand+' '+',toGstin=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then cm.GSTIN ELSE '
		Set @SqlCommand=@SqlCommand+' '+'(case when buyer_sp.st_type=''OUT OF COUNTRY'' OR buyer_sp.supp_type=''UNREGISTERED'' then ''URP'' ELSE buyer_sp.gstin END ) END)'
		Set @SqlCommand=@SqlCommand+' '+',toTrdName=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then cm.MailName else'
		Set @SqlCommand=@SqlCommand+' '+'(case when buyer_sp.mailname<>'''' then buyer_sp.mailname else buyer_sp.ac_name end) END )'
		Set @SqlCommand=@SqlCommand+' '+',toAddr1=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add1 else cm.Add1 end)'
		Set @SqlCommand=@SqlCommand+' '+'ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.add1,'''') else isnull(Cons_ac.add1,'''') end) END)	'
		Set @SqlCommand=@SqlCommand+' '+',toAddr2=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(Case When isnull(m.SHIPTO,'''')<>'''' then rtrim(lm.Add2)+'' ''+rtrim(lm.Add3) else rtrim(cm.Add2)+'' ''+rtrim(cm.Add3) END)'
		Set @SqlCommand=@SqlCommand+' '+'ELSE'
		Set @SqlCommand=@SqlCommand+' '+'(case WHEN isnull(m.scons_id, 0) > 0 then rtrim(isnull(Cons_sp.add2,''''))+'' ''+rtrim(isnull(Cons_sp.add3,'''')) else rtrim(isnull(Cons_ac.add2,''''))+'' ''+rtrim(isnull(Cons_ac.add3,'''')) end)'
		Set @SqlCommand=@SqlCommand+' '+'	END )'
		Set @SqlCommand=@SqlCommand+' '+',toPlace=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(Case When isnull(m.SHIPTO,'''')<>'''' then lm.city else cm.City end)'
		Set @SqlCommand=@SqlCommand+' '+'ELSE'
		Set @SqlCommand=@SqlCommand+' '+'(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end) END)'
		Set @SqlCommand=@SqlCommand+' '+',toPincode=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then 	'
		Set @SqlCommand=@SqlCommand+' '+'	(Case When isnull(m.SHIPTO,'''')<>'''' then lm.pincode else cm.ZIP end)'
		Set @SqlCommand=@SqlCommand+' '+'ELSE'
		Set @SqlCommand=@SqlCommand+' '+'(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END)'
		Set @SqlCommand=@SqlCommand+' '+'END)'
		Set @SqlCommand=@SqlCommand+' '+',toStateCode=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then Cm.Gst_State_Code else '
		Set @SqlCommand=@SqlCommand+' '+'(case when buyer_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE buyer_sp.statecode END)	 END)'
		Set @SqlCommand=@SqlCommand+' '+',actualFromStateCode=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then '
		Set @SqlCommand=@SqlCommand+' '+'(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END)	'
		Set @SqlCommand=@SqlCommand+' '+' else (Case When isnull(m.SHIPTO,'''')<>'''' then s.Gst_State_code else Cm.Gst_State_code End) end)	'
		Set @SqlCommand=@SqlCommand+' '+',actualToStateCode=	(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then (Case When isnull(m.SHIPTO,'''')<>'''' then s.Gst_State_code else Cm.Gst_State_code End	) else	'
		Set @SqlCommand=@SqlCommand+' '+'(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END)'
		Set @SqlCommand=@SqlCommand+' '+'end)'
		Set @SqlCommand=@SqlCommand+' ,EWBValidFrom=case when year(m.EWBVFD)>1900 then Convert(date,m.EWBVFD) +convert(datetime,m.EWBVFT) else 0 end,SuppTyp=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then ''Inward'' else ''Outward'' end)'
		Set @SqlCommand=@SqlCommand+' ,EWBValidTo=case when year(m.EWBVTD)>1900 then Convert(date,m.EWBVTD) +convert(datetime,m.EWBVTT) else 0 end'
		Set @SqlCommand=@SqlCommand+' ,mainHsnCode=(Select Top 1 rtrim(c.hsn_code)+''-''+substring(hsn_desc,0,2000) From cnitem a inner join it_mast b on (a.it_code=b.it_code) inner join hsn_master c on (b.hsn_id=c.hsn_id) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '
		Set @SqlCommand=@SqlCommand+' ,m.Entry_ty,0x'  
		Set @SqlCommand=@SqlCommand+' '+' From #Co_mast cm,CNMain m'
		Set @SqlCommand=@SqlCommand+' '+' Inner Join CNItem i on (m.Tran_Cd=i.Tran_Cd)'
		Set @SqlCommand=@SqlCommand+' '+' Inner join it_mast itm on (itm.it_code=i.it_code and itm.isservice<>1)'
		Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_ac_st on (Cons_ac_st.State=Cons_ac.State)'
		Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_sp_st on (Cons_sp_st.State=Cons_sp.State)'
		Set @SqlCommand=@SqlCommand+' '+'Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'			
		Set @SqlCommand=@SqlCommand+' Left outer Join [state] s on (lm.state = s.state)'			
		Set @SqlCommand=@SqlCommand+' '+'Where m.Inv_No='+Char(39)+@Inv_No+Char(39)+' and m.Date='''+@Inv_dt+''' and m.Entry_ty='''+@Entry_ty+'''' 
		Set @SqlCommand=@SqlCommand+' '+'group by cm.GSTIN,m.EWBN,m.EWBDT,m.U_TMODE,m.EWBDIST,m.EWBVTD,m.EWBSUPTYPC,m.inv_no,m.[date],itm.HSNCODE,itm.it_alias,cm.MailName,'
		Set @SqlCommand=@SqlCommand+' '+'itm.it_name,i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,m.gro_amt,m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,m.U_LRDT,'
		Set @SqlCommand=@SqlCommand+' '+'cm.add1,cm.add2,cm.add3,cm.city,cm.zip,cm.Gst_State_Code,m.scons_id,Cons_sp.add3,Cons_ac.add3,m.Entry_ty,'
		set @SqlCommand=@SqlCommand+' '+'Cons_sp.gstin,Cons_ac.gstin,Cons_sp.mailname,Cons_ac.ac_name,Cons_sp.add1,Cons_ac.add1,Cons_sp.add2,Cons_ac.add2,Cons_sp.city,Cons_ac.city,Cons_sp.zip,Cons_ac.zip,Cons_sp_st.Gst_State_code,Cons_ac_st.Gst_State_code,M.AGAINSTGS,m.Entry_ty'
		set @SqlCommand=@SqlCommand+' '+',m.SHIPTO,lm.Add1,lm.add2,lm.add3,lm.City,lm.pincode,buyer_sp.gstin,cm.MailName,buyer_sp.mailname,buyer_sp.ac_name,Cons_sp.add3,Cons_ac.add3,Cons_sp.st_type,Cons_sp.supp_type,buyer_sp.st_type,buyer_sp.supp_type,buyer_sp.Statecode,Cons_sp.Statecode,s.Gst_State_code,m.sac_id,m.EWBVFD,m.EWBVFT,m.Tran_cd,m.EWBVTT'
		Print @SqlCommand
		Execute sp_Executesql @SqlCommand
			set @SqlCommand='update a set a.ewbqrcode=b.ewbqrcode from #eWayBillCrystal a inner join CNmain b on (a.inv_no=b.inv_no  and a.Date=b.date)'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
end
	
If (@TrnName='Sales Return')
	Begin
			Set @SqlCommand='Insert Into #eWayBillCrystal '
			Set @SqlCommand=@SqlCommand+' '+' select userGstin=cm.GSTIN,docType1=''Challan'',m.EWBN,EWBDT=m.EWBDT,m.U_TMODE,m.EWBDIST,EWBVTD=m.EWBVTD,m.EWBSUPTYP,m.inv_no,[date]=m.date,'
			Set @SqlCommand=@SqlCommand+' '+'itm.HSNCODE,It_Desc=(CASE WHEN ISNULL(itm.it_alias,'''')='''' THEN itm.it_name ELSE itm.it_alias END),'
			Set @SqlCommand=@SqlCommand+' '+'i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,'
			Set @SqlCommand=@SqlCommand+' '+'m.gro_amt,cgst_amt=sum(i.CGST_AMT),sgst_amt=sum(i.SGST_AMT),igst_amt=sum(i.IGST_AMT),'
			Set @SqlCommand=@SqlCommand+' '+'cess_amt=sum(i.COMPCESS),m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,U_LRDT=(case when year(m.U_LRDT)<=1900 then '''' else convert(varchar,m.U_LRDT,103) end)'
			Set @SqlCommand=@SqlCommand+' ,fromGstin=case when buyer_sp.st_type=''OUT OF COUNTRY'' OR buyer_sp.supp_type=''UNREGISTERED'' then ''URP'' ELSE buyer_sp.gstin END '
			Set @SqlCommand=@SqlCommand+' ,fromTrdName=case when buyer_sp.mailname<>'''' then buyer_sp.mailname else buyer_sp.ac_name end'
			Set @SqlCommand=@SqlCommand+' ,fromAddr1=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.add1,'''') else isnull(Cons_ac.add1,'''') end)'
			Set @SqlCommand=@SqlCommand+' ,fromAddr2=(case WHEN isnull(m.scons_id, 0) > 0 then rtrim(isnull(Cons_sp.add2,''''))+'' ''+rtrim(isnull(Cons_sp.add3,'''')) else rtrim(isnull(Cons_ac.add2,''''))+'' ''+rtrim(isnull(Cons_ac.add3,'''')) end)'
			Set @SqlCommand=@SqlCommand+' ,fromPlace=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end)'
			Set @SqlCommand=@SqlCommand+' ,fromPincode=(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''999999'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.zip,'''') else isnull(Cons_ac.zip,'''') end)  END)'
			Set @SqlCommand=@SqlCommand+' ,fromStateCode=(case when buyer_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.sac_id, 0) > 0 then isnull(buyer_sp.Statecode,'''') else isnull(Cons_sp.Statecode,'''') end) END)'
			Set @SqlCommand=@SqlCommand+' ,toGstin=cm.GSTIN'  
			Set @SqlCommand=@SqlCommand+' ,toTrdName=cm.MailName'
			Set @SqlCommand=@SqlCommand+' ,toAddr1=Case When isnull(m.SHIPTO,'''')<>'''' then lm.Add1 else cm.Add1 end'
			Set @SqlCommand=@SqlCommand+' ,toAddr2=Case When isnull(m.SHIPTO,'''')<>'''' then rtrim(lm.Add2)+'' ''+rtrim(lm.Add3) else rtrim(cm.Add2)+'' ''+rtrim(cm.Add3) END'
			Set @SqlCommand=@SqlCommand+' ,toPlace=Case When isnull(m.SHIPTO,'''')<>'''' then lm.city else cm.City end'
			Set @SqlCommand=@SqlCommand+' ,toPincode=Case When isnull(m.SHIPTO,'''')<>'''' then lm.pincode else cm.ZIP end'
			Set @SqlCommand=@SqlCommand+' ,toStateCode=cm.Gst_State_Code'  
			Set @SqlCommand=@SqlCommand+' ,actualFromStateCode=(case when Cons_sp.st_type=''OUT OF COUNTRY'' THEN ''99'' ELSE (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp_st.Gst_State_code,'''') else isnull(Cons_ac_st.Gst_State_code,'''') end) END)'		--Added by Shrikant S. on 18/05/2018 for Bug-31516
			Set @SqlCommand=@SqlCommand+' ,actualToStateCode=(Case When isnull(m.SHIPTO,'''')<>'''' then s.Gst_State_code else Cm.Gst_State_code End) '														--Added by Shrikant S. on 18/05/2018 for Bug-31516
			Set @SqlCommand=@SqlCommand+' ,EWBValidFrom=case when year(m.EWBVFD)>1900 then Convert(date,m.EWBVFD) +convert(datetime,m.EWBVFT) else 0 end,SuppTyp=''Inward'''
			Set @SqlCommand=@SqlCommand+' ,EWBValidTo=case when year(m.EWBVTD)>1900 then Convert(date,m.EWBVTD) +convert(datetime,m.EWBVTT) else 0 end'
			Set @SqlCommand=@SqlCommand+' ,mainHsnCode=(Select Top 1 rtrim(c.hsn_code)+''-''+substring(hsn_desc,0,2000) From sritem a inner join it_mast b on (a.it_code=b.it_code) inner join hsn_master c on (b.hsn_id=c.hsn_id) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '
			Set @SqlCommand=@SqlCommand+' ,m.Entry_ty,0x'  
			Set @SqlCommand=@SqlCommand+' '+' From #Co_mast cm,SRMain m'
			Set @SqlCommand=@SqlCommand+' '+' Inner Join SRItem i on (m.Tran_Cd=i.Tran_Cd)'
			Set @SqlCommand=@SqlCommand+' '+' Inner join it_mast itm on (itm.it_code=i.it_code and itm.isservice<>1)'
			Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
			Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
			Set @SqlCommand=@SqlCommand+' '+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
			Set @SqlCommand=@SqlCommand+' '+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
			Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_ac_st on (Cons_ac_st.State=Cons_ac.State)'
			Set @SqlCommand=@SqlCommand+' '+' Left join State Cons_sp_st on (Cons_sp_st.State=Cons_sp.State)'
			Set @SqlCommand=@SqlCommand+' '+'Left outer Join LOC_MASTER lm on (lm.Loc_Code = m.SHIPTO)'			
			Set @SqlCommand=@SqlCommand+' Left outer Join [state] s on (lm.state = s.state)'			
			Set @SqlCommand=@SqlCommand+' '+'Where m.Inv_No='+Char(39)+@Inv_No+Char(39)+' and m.Date='''+@Inv_dt+''' and m.Entry_ty='''+@Entry_ty+'''' 
			Set @SqlCommand=@SqlCommand+' '+'group by cm.GSTIN,m.EWBN,m.EWBDT,m.U_TMODE,m.EWBDIST,m.EWBVTD,m.EWBSUPTYP,m.inv_no,m.[date],itm.HSNCODE,itm.it_alias,cm.MailName,'
			Set @SqlCommand=@SqlCommand+' '+'itm.it_name,i.qty,i.U_ASSEAMT,i.CGST_PER,i.SGST_PER,i.IGST_PER,i.CCESSRATE,m.gro_amt,m.u_deli,m.TRANS_ID,m.U_VEHNO,m.U_LRNO,m.U_LRDT,'
			Set @SqlCommand=@SqlCommand+' '+'cm.add1,cm.add2,cm.add3,cm.city,cm.zip,cm.Gst_State_Code,m.scons_id,Cons_sp.add3,Cons_ac.add3,m.Entry_ty,'
			set @SqlCommand=@SqlCommand+' '+'Cons_sp.gstin,Cons_ac.gstin,Cons_sp.mailname,Cons_ac.ac_name,Cons_sp.add1,Cons_ac.add1,Cons_sp.add2,Cons_ac.add2,Cons_sp.city,Cons_ac.city,Cons_sp.zip,Cons_ac.zip,Cons_sp_st.Gst_State_code,Cons_ac_st.Gst_State_code,m.Entry_ty'
			set @SqlCommand=@SqlCommand+' '+',m.SHIPTO,lm.Add1,lm.add2,lm.add3,lm.City,lm.pincode,buyer_sp.gstin,cm.MailName,buyer_sp.mailname,buyer_sp.ac_name,Cons_sp.add3,Cons_ac.add3,Cons_sp.st_type,Cons_sp.supp_type,buyer_sp.st_type,buyer_sp.supp_type,buyer_sp.Statecode,Cons_sp.Statecode,s.Gst_State_code,m.sac_id,m.EWBVFD,m.EWBVFT,m.Tran_cd,m.EWBVTT'

		Print @SqlCommand
		Execute sp_Executesql @SqlCommand
			set @SqlCommand='update a set a.ewbqrcode=b.ewbqrcode from #eWayBillCrystal a inner join SRmain b on (a.inv_no=b.inv_no  and a.Date=b.date)'
		Print @SqlCommand
	Execute sp_Executesql @SqlCommand
end		

Update #eWayBillCrystal set fromTrdName=replace(fromTrdName,'"','\"'),toTrdName=replace(toTrdName,'"','\"')

Select userGstin,docType1,EWBN,EWBDT,U_TMODE,EWBDIST,EWBVTD,EWBSUPTYP,inv_no,[date],HSNCODE,It_Desc,qty,U_ASSEAMT,CGST_PER,
SGST_PER,IGST_PER,CCESSRATE,gro_amt,CGST_AMT,SGST_AMT,IGST_AMT,COMPCESS,u_deli,TRANS_ID,U_VEHNO,U_LRNO,U_LRDT,
fromGstin,fromTrdName,fromAddr1,fromAddr2,fromPlace,fromPincode,fromStateCode,toGstin,
toTrdName,toAddr1,toAddr2,toPlace,toPincode,toStateCode,fromactStateCode,toactStateCode,Entry_ty,EWBValidFrom,SuppTyp,mainHsnCode,EWBValidTo,ewbqrcode
From #eWayBillCrystal

Drop table #Co_mast
End



