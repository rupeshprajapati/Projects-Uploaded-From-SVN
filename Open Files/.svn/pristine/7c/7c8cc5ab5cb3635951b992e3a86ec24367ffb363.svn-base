
/****** Object:  StoredProcedure [dbo].[USP_Ent_eWayBill_Bulk]    Script Date: 05/22/2018 10:15:28 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[USP_Ent_eWayBill_Bulk]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[USP_Ent_eWayBill_Bulk]
GO



-- =============================================
-- Author:		Ruepesh Prajapati
-- Create date: 08/01/2018
-- Description:	This Stored procedure is useful for eWayBill Generation Screen
-- Modify By/date/Reason: 
-- Remark:
-- =============================================
Create  Procedure [dbo].[USP_Ent_eWayBill_Bulk]
(
	--@pGSTIN varchar(15),@PartyNm varchar(100),@Status varchar(30),@TrnName varchar(100)  --Commented by Priyanka B on 02022018 for Bug-31240
	@pGSTIN varchar(15),@PartyNm varchar(100),@TrnName varchar(100)  --Modified by Priyanka B on 02022018 for Bug-31240
	,@sInvno Varchar(20)='',@tInvNo Varchar(20)=''			--Shrikant 19/03/2018	
	,@Sdate Smalldatetime,@Edate SmallDateTime				--Shrikant 19/03/2018	
)
As
Begin
	Declare @SqlCommand nvarchar(4000)

	Select Sel=Cast(0 as bit),Entry_Ty='ST',SuppTyp=cast('' as varchar(20)),SubTyp=cast('' as varchar(50)),DocTyp=cast('' as varchar(20))
	,DocNo=cast('' as varchar(20))
	--,DocDt=cast('' as datetime)  --Commented by Priyanka B on 06022018 for Bug-31240
	,DocDt=convert(varchar,'',105)  --Commented by Priyanka B on 06022018 for Bug-31240
	,GSTIN=cast('' as varchar(15))	
	,LgNm=cast('' as varchar(100)),ConCity=cast('' as varchar(50)),	ConState=cast('' as varchar(30))
	,TranDocNo=cast('' as varchar(30))
	--,	TranDocDt=cast('' as Datetime)  --Commented by Priyanka B on 06022018 for Bug-31240
	,TranDocDt=convert(varchar,'',105)  --Modified by Priyanka B on 06022018 for Bug-31240
	,TranMode=cast('' as varchar(20)),AproxDis=cast('' as varchar(10))
	,eWAYN=cast('' as varchar(20))
	--,eWAYDt=cast('' as DateTime)  --Commented by Priyanka B on 06022018 for Bug-31240
	,eWAYDt=convert(varchar,'',105)  --Modified by Priyanka B on 06022018 for Bug-31240
	,U_VehNo=convert(varchar,'',105),PartyPincode=convert(varchar,'',105),transporterName=Cast('' as varchar(100)),transporterId=convert(varchar,'',105),transDocNo=convert(varchar,'',105),transDocDate=convert(varchar,'',105) --Rup 15/03/2018
	,partynm=cast('' as varchar(100))
	,vehicleType=Cast('' as varchar(30))				--Added By Shrikant S. on 18/05/2018 for Bug-31516
	,mainHsnCode=Cast('' as varchar(30))				--Added By Shrikant S. on 18/05/2018 for Bug-31516
	,tran_cd=Cast(0 as int)  --Added by Priyanka B on 14022019 for Bug-31844
	into #eWayBill where 1=2
	
	If (@TrnName='Sales')
	Begin
		Set @SqlCommand='Insert into #eWayBill' 
		Set @SqlCommand=@SqlCommand+' Select Sel=Cast(0 as bit),l.Entry_Ty,SuppTyp=''Outward'',SubTyp=sm.EWBSUPTYP,DocTyp=''Tax Invoice'',DocNo=m.Inv_No,DocDt=(case when year(m.date)<=1900 then '''' else convert(varchar,m.date,105) end),GSTIN =(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,LgNm =(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.ac_name,'''') end),ConCity=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end),ConState=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.state,'''') else isnull(Cons_ac.state,'''') end)'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end),TranMode=m.u_tMode,AproxDis=sm.EWBDIST'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=(case when year(m.EWBDt)<=1900 then '''' else convert(varchar,m.EWBDt,105) end),m.u_vehno,PartyPincode=Cons_sp.ZIP,transporterName=m.u_Deli,transporterId=m.Trans_Id,transDocNo=m.U_LrNo,transDocDate=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end)'  --Rup 15/03/2018
		--Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)'				--	Added by Shrikant S. on 21/03/2018 for Bug-31385
		Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then (case when isnull(Cons_sp.ac_name,'''')='''' then  isnull(Cons_ac.ac_name,'''') else isnull(Cons_sp.ac_name,'''') end) else isnull(Cons_ac.ac_name,'''') end)'		--Added by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		Set @SqlCommand=(@SqlCommand)+',vehicleType=sm.cargo_typ,mainHsnCode=(Select Top 1 ISNULL(Hsncode,'''') From stitem a inner join it_mast b on (a.it_code=b.it_code) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '	--Added By Shrikant S. on 18/05/2018 for Bug-31516'
		Set @SqlCommand=(@SqlCommand)+',m.tran_cd'  --Added by Priyanka B on 14022019 for Bug-31844
		Set @SqlCommand=@SqlCommand+' From StMain m'
		Set @SqlCommand=@SqlCommand+' Left Join StMainAdd sm on (m.Tran_cd=sm.Tran_Cd)'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Where 1=1'
		If (@pGSTIN<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@pGSTIN+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@PartyNm<>'') Begin Set @SqlCommand=@SqlCommand+' and Cons_ac.Ac_Name='+char(39)+@PartyNm+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		
		if @sInvno<>'' and @tInvno<>''
		Begin
			Set @SqlCommand=@SqlCommand+' and m.Inv_no Between '''+@sInvno+''' and '''+@tInvno+''''
		end
		Set @SqlCommand=@SqlCommand+' and m.Date Between '''+Convert(varchar(50),@Sdate)+''' and '''+Convert(varchar(50),@Edate)+''''
		--Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from stitem  inner join it_mast on (it_mast.it_code=stitem.it_code) where it_mast.isservice=1 group by tran_cd having MAX(item_no)=count(item_no))'		--Commented by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from stitem  inner join it_mast on (it_mast.it_code=stitem.it_code) group by tran_cd having count(tran_cd)=sum(case when it_mast.isservice=1 then 1 else 0 end))'		--Added by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
		
	End
	If (@TrnName='Delivery Challan')
	Begin
		Set @SqlCommand='Insert into #eWayBill' 
		Set @SqlCommand=@SqlCommand+' Select Sel=Cast(0 as bit),l.Entry_Ty,SuppTyp=''Outward'',SubTyp=m.EWBSUPTYP,DocTyp=''Challan'',DocNo=m.Inv_No,DocDt=(case when year(m.date)<=1900 then '''' else convert(varchar,m.date,105) end),GSTIN=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,LgNm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.ac_name,'''') end),ConCity=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end),ConState=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.state,'''') else isnull(Cons_ac.state,'''') end)'  --Modified by Priyanka B on 05022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end),TranMode=m.u_tMode,AproxDis=m.EWBDIST'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=(case when year(m.EWBDt)<=1900 then '''' else convert(varchar,m.EWBDt,105) end),m.u_vehno,PartyPincode=Cons_sp.ZIP,transporterName=m.u_Deli,transporterId=m.Trans_Id,transDocNo=m.U_LrNo,transDocDate=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end)'  --Rup 15/03/2018
		--Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)'				--	Added by Shrikant S. on 21/03/2018 for Bug-31385
		Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then (case when isnull(Cons_sp.ac_name,'''')='''' then  isnull(Cons_ac.ac_name,'''') else isnull(Cons_sp.ac_name,'''') end) else isnull(Cons_ac.ac_name,'''') end)'		--Added by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		Set @SqlCommand=(@SqlCommand)+',vehicleType=m.cargo_typ,mainHsnCode=(Select Top 1 ISNULL(Hsncode,'''') From dcitem a inner join it_mast b on (a.it_code=b.it_code) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '	--Added By Shrikant S. on 18/05/2018 for Bug-31516'
		Set @SqlCommand=(@SqlCommand)+',m.tran_cd'  --Added by Priyanka B on 14022019 for Bug-31844
		Set @SqlCommand=@SqlCommand+' From DCMain m'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Where 1=1'
		If (@pGSTIN<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@pGSTIN+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@PartyNm<>'') Begin Set @SqlCommand=@SqlCommand+' and Cons_ac.Ac_Name='+char(39)+@PartyNm+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@TrnName<>'') Begin Set @SqlCommand=@SqlCommand+' and l.Code_Nm='+char(39)+@TrnName+Char(39) End
		if @sInvno<>'' and @tInvno<>''
		Begin
			Set @SqlCommand=@SqlCommand+' and m.Inv_no Between '''+@sInvno+''' and '''+@tInvno+''''
		end
		Set @SqlCommand=@SqlCommand+' and m.Date Between '''+Convert(varchar(50),@Sdate)+''' and '''+Convert(varchar(50),@Edate)+''''
		--Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from dcitem  inner join it_mast on (it_mast.it_code=dcitem.it_code) where it_mast.isservice=1 group by tran_cd having MAX(item_no)=count(item_no))'					--Commented by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		--Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from dcitem  inner join it_mast on (it_mast.it_code=dtitem.it_code) group by tran_cd having count(tran_cd)=sum(case when it_mast.isservice=1 then 1 else 0 end))'		--Added by Shrikant S. on 13/07/2018 for Sprint 1.0.2 //Commented by Rupesh G. on 21/08/2018 for installer STD
		Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from dcitem  inner join it_mast on (it_mast.it_code=dcitem.it_code) group by tran_cd having count(tran_cd)=sum(case when it_mast.isservice=1 then 1 else 0 end))'		--Added by Rupesh G. on 21/08/2018 for installer STD
		Print @SqlCommand
		
		Execute Sp_ExecuteSql @SqlCommand	
	End
	If (@TrnName='Purchase')
	Begin
		Set @SqlCommand='Insert into #eWayBill' 
		
		Set @SqlCommand=@SqlCommand+' Select Sel=Cast(0 as bit),l.Entry_Ty,SuppTyp=''Inward'',SubTyp=m.EWBSUPTYP,DocTyp=(Case when l.Entry_ty=''P1'' Then ''Bill of Entry'' Else ''Bill of Supply'' end),DocNo=m.Inv_No,DocDt=(case when year(m.date)<=1900 then '''' else convert(varchar,m.date,105) end),GSTIN=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,LgNm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.ac_name,'''') end),ConCity=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end),ConState=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.state,'''') else isnull(Cons_ac.state,'''') end)'  --Modified by Priyanka B on 05022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end),TranMode=m.u_tMode,AproxDis=m.EWBDIST'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=(case when year(m.EWBDt)<=1900 then '''' else convert(varchar,m.EWBDt,105) end),m.u_vehno,PartyPincode=Cons_sp.ZIP,transporterName=m.u_Deli,transporterId=m.Trans_Id,transDocNo=m.U_LrNo,transDocDate=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end)'  --Modified by Priyanka B on 06022018 for Bug-31240
		--Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)'				--	Added by Shrikant S. on 21/03/2018 for Bug-31385
		Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then (case when isnull(Cons_sp.ac_name,'''')='''' then  isnull(Cons_ac.ac_name,'''') else isnull(Cons_sp.ac_name,'''') end) else isnull(Cons_ac.ac_name,'''') end)'		--Added by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		Set @SqlCommand=(@SqlCommand)+',vehicleType=m.cargo_typ,mainHsnCode=(Select Top 1 ISNULL(Hsncode,'''') From ptitem a inner join it_mast b on (a.it_code=b.it_code) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '	--Added By Shrikant S. on 18/05/2018 for Bug-31516'
		Set @SqlCommand=(@SqlCommand)+',m.tran_cd'  --Added by Priyanka B on 14022019 for Bug-31844
		Set @SqlCommand=@SqlCommand+' From PTMain m'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Where 1=1'
		If (@pGSTIN<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@pGSTIN+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@PartyNm<>'') Begin Set @SqlCommand=@SqlCommand+' and Cons_ac.Ac_Name='+char(39)+@PartyNm+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		if @sInvno<>'' and @tInvno<>''
		Begin
			Set @SqlCommand=@SqlCommand+' and m.Inv_no Between '''+@sInvno+''' and '''+@tInvno+''''
		end
		Set @SqlCommand=@SqlCommand+' and m.Date Between '''+Convert(varchar(50),@Sdate)+''' and '''+Convert(varchar(50),@Edate)+''''
		--Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from ptitem  inner join it_mast on (it_mast.it_code=ptitem.it_code) where it_mast.isservice=1 group by tran_cd having MAX(item_no)=count(item_no))'	--Commented by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from ptitem  inner join it_mast on (it_mast.it_code=ptitem.it_code) group by tran_cd having count(tran_cd)=sum(case when it_mast.isservice=1 then 1 else 0 end))'		--Added by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	End
	/*		Added by Shrikant S. on 23/04/2018 for Bug-31481	Start	*/
	If (@TrnName='Goods Receipt')
	Begin
		Set @SqlCommand='Insert into #eWayBill' 
		
		Set @SqlCommand=@SqlCommand+' Select Sel=Cast(0 as bit),l.Entry_Ty,SuppTyp=''Inward'',SubTyp=m.EWBSUPTYP,DocTyp=''Bill of Supply'',DocNo=m.Inv_No,DocDt=(case when year(m.date)<=1900 then '''' else convert(varchar,m.date,105) end),GSTIN=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)'  
		Set @SqlCommand=@SqlCommand+' ,LgNm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.ac_name,'''') end),ConCity=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end),ConState=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.state,'''') else isnull(Cons_ac.state,'''') end)'  
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end),TranMode=m.u_tMode,AproxDis=m.EWBDIST'  
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=(case when year(m.EWBDt)<=1900 then '''' else convert(varchar,m.EWBDt,105) end),m.u_vehno,PartyPincode=Cons_sp.ZIP,transporterName=m.u_Deli,transporterId=m.Trans_Id,transDocNo=m.U_LrNo,transDocDate=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end)'  
		--Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)'				
		Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then (case when isnull(Cons_sp.ac_name,'''')='''' then  isnull(Cons_ac.ac_name,'''') else isnull(Cons_sp.ac_name,'''') end) else isnull(Cons_ac.ac_name,'''') end)'		--Added by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		Set @SqlCommand=(@SqlCommand)+',vehicleType=m.cargo_typ,mainHsnCode=(Select Top 1 ISNULL(Hsncode,'''') From aritem a inner join it_mast b on (a.it_code=b.it_code) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '	--Added By Shrikant S. on 18/05/2018 for Bug-31516'
		Set @SqlCommand=(@SqlCommand)+',m.tran_cd'  --Added by Priyanka B on 14022019 for Bug-31844
		Set @SqlCommand=@SqlCommand+' From ARMain m'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Where 1=1'
		If (@pGSTIN<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@pGSTIN+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@PartyNm<>'') Begin Set @SqlCommand=@SqlCommand+' and Cons_ac.Ac_Name='+char(39)+@PartyNm+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		if @sInvno<>'' and @tInvno<>''
		Begin
			Set @SqlCommand=@SqlCommand+' and m.Inv_no Between '''+@sInvno+''' and '''+@tInvno+''''
		end
		Set @SqlCommand=@SqlCommand+' and m.Date Between '''+Convert(varchar(50),@Sdate)+''' and '''+Convert(varchar(50),@Edate)+''''
		--Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from ARitem  inner join it_mast on (it_mast.it_code=ARitem.it_code) where it_mast.isservice=1 group by tran_cd having MAX(item_no)=count(item_no))'					--Commented by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from aritem  inner join it_mast on (it_mast.it_code=aritem.it_code) group by tran_cd having count(tran_cd)=sum(case when it_mast.isservice=1 then 1 else 0 end))'		--Added by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	End
	/*		Added by Shrikant S. on 23/04/2018 for Bug-31481	End		*/
	If (@TrnName='LABOUR JOB ISSUE[V]' or @TrnName='LABOUR JOB ISSUE[IV]')
	Begin
		Set @SqlCommand='Insert into #eWayBill' 
		Set @SqlCommand=@SqlCommand+' Select Sel=Cast(0 as bit),l.Entry_Ty,SuppTyp=''Outward'',SubTyp=m.EWBSUPTYP,DocTyp=''Challan'',DocNo=m.Inv_No,DocDt=(case when year(m.date)<=1900 then '''' else convert(varchar,m.date,105) end),GSTIN=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,LgNm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.ac_name,'''') end),ConCity=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end),ConState=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.state,'''') else isnull(Cons_ac.state,'''') end)'  --Modified by Priyanka B on 05022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end),TranMode=m.u_tMode,AproxDis=m.EWBDIST'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=(case when year(m.EWBDt)<=1900 then '''' else convert(varchar,m.EWBDt,105) end),m.u_vehno,PartyPincode=Cons_sp.ZIP,transporterName=m.u_Deli,transporterId=m.Trans_Id,transDocNo=m.U_LrNo,transDocDate=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end)'  --Rup 15/03/2018
		--Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)'				--	Added by Shrikant S. on 21/03/2018 for Bug-31385
		Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then (case when isnull(Cons_sp.ac_name,'''')='''' then  isnull(Cons_ac.ac_name,'''') else isnull(Cons_sp.ac_name,'''') end) else isnull(Cons_ac.ac_name,'''') end)'		--Added by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		Set @SqlCommand=(@SqlCommand)+',vehicleType=m.cargo_typ,mainHsnCode=(Select Top 1 ISNULL(Hsncode,'''') From iiitem a inner join it_mast b on (a.it_code=b.it_code) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '	--Added By Shrikant S. on 18/05/2018 for Bug-31516'
		Set @SqlCommand=(@SqlCommand)+',m.tran_cd'  --Added by Priyanka B on 14022019 for Bug-31844
		Set @SqlCommand=@SqlCommand+' From IIMain m'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Where 1=1'
		If (@TrnName='LABOUR JOB ISSUE[V]') Begin Set @SqlCommand=@SqlCommand+' and m.Entry_ty=''IL''' End 
										Else Begin Set @SqlCommand=@SqlCommand+' and m.Entry_ty=''LI''' End
		If (@pGSTIN<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@pGSTIN+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@PartyNm<>'') Begin Set @SqlCommand=@SqlCommand+' and Cons_ac.Ac_Name='+char(39)+@PartyNm+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		if @sInvno<>'' and @tInvno<>''
		Begin
			Set @SqlCommand=@SqlCommand+' and m.Inv_no Between '''+@sInvno+''' and '''+@tInvno+''''
		end
		Set @SqlCommand=@SqlCommand+' and m.Date Between '''+Convert(varchar(50),@Sdate)+''' and '''+Convert(varchar(50),@Edate)+''''
--		Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from iiitem  inner join it_mast on (it_mast.it_code=iiitem.it_code) where it_mast.isservice=1 group by tran_cd having MAX(item_no)=count(item_no))'	--Commented by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from iiitem  inner join it_mast on (it_mast.it_code=iiitem.it_code) group by tran_cd having count(tran_cd)=sum(case when it_mast.isservice=1 then 1 else 0 end))'		--Added by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	End
	
	If (@TrnName='LABOUR JOB RECEIPT[IV]' or @TrnName='LABOUR JOB RECEIPT[V]') /*Both 4 & 5 LR/RL*/  --Modified by Priyanka B on 02022018 for Bug-31240
	Begin
		Set @SqlCommand='Insert into #eWayBill' 
		Set @SqlCommand=@SqlCommand+' Select Sel=Cast(0 as bit),l.Entry_Ty,SuppTyp=''Inward'',SubTyp=m.EWBSUPTYP,DocTyp=''Challan'',DocNo=m.Inv_No,DocDt=(case when year(m.date)<=1900 then '''' else convert(varchar,m.date,105) end),GSTIN=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,LgNm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.ac_name,'''') end),ConCity=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end),ConState=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.state,'''') else isnull(Cons_ac.state,'''') end)'  --Modified by Priyanka B on 05022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end),TranMode=m.u_tMode,AproxDis=m.EWBDIST'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=(case when year(m.EWBDt)<=1900 then '''' else convert(varchar,m.EWBDt,105) end),m.u_vehno,PartyPincode=Cons_sp.ZIP,transporterName=m.u_Deli,transporterId=m.Trans_Id,transDocNo=m.U_LrNo,transDocDate=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end)'  --Rup 15/03/2018
		--Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)'				--	Added by Shrikant S. on 21/03/2018 for Bug-31385
		Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then (case when isnull(Cons_sp.ac_name,'''')='''' then  isnull(Cons_ac.ac_name,'''') else isnull(Cons_sp.ac_name,'''') end) else isnull(Cons_ac.ac_name,'''') end)'		--Added by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		Set @SqlCommand=(@SqlCommand)+',vehicleType=m.cargo_typ,mainHsnCode=(Select Top 1 ISNULL(Hsncode,'''') From iritem a inner join it_mast b on (a.it_code=b.it_code) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '	--Added By Shrikant S. on 18/05/2018 for Bug-31516
		Set @SqlCommand=(@SqlCommand)+',m.tran_cd'  --Added by Priyanka B on 14022019 for Bug-31844
		Set @SqlCommand=@SqlCommand+' From IRMain m'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'		
		Set @SqlCommand=@SqlCommand+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Where 1=1'
		If (@TrnName='LABOUR JOB RECEIPT[IV]') Begin Set @SqlCommand=@SqlCommand+' and m.Entry_ty=''LR''' End 
										Else Begin Set @SqlCommand=@SqlCommand+' and m.Entry_ty=''RL''' End
		If (@pGSTIN<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@pGSTIN+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@PartyNm<>'') Begin Set @SqlCommand=@SqlCommand+' and Cons_ac.Ac_Name='+char(39)+@PartyNm+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		if @sInvno<>'' and @tInvno<>''
		Begin
			Set @SqlCommand=@SqlCommand+' and m.Inv_no Between '''+@sInvno+''' and '''+@tInvno+''''
		end
		Set @SqlCommand=@SqlCommand+' and m.Date Between '''+Convert(varchar(50),@Sdate)+''' and '''+Convert(varchar(50),@Edate)+''''
		--Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from iritem  inner join it_mast on (it_mast.it_code=iritem.it_code) where it_mast.isservice=1 group by tran_cd having MAX(item_no)=count(item_no))'		--Commented by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from iritem  inner join it_mast on (it_mast.it_code=iritem.it_code) group by tran_cd having count(tran_cd)=sum(case when it_mast.isservice=1 then 1 else 0 end))'		--Added by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	End
	
	If (@TrnName='CREDIT NOTE')
	Begin
		Set @SqlCommand='Insert into #eWayBill' 
		Set @SqlCommand=@SqlCommand+' Select Sel=Cast(0 as bit),l.Entry_Ty,SuppTyp=(Case when m.againstgs in (''PURCHASES'',''SERVICE PURCHASE BILL'') then ''Inward'' else ''Outward'' end),SubTyp=m.EWBSUPTYPC,DocTyp=''Credit Note'',DocNo=m.Inv_No,DocDt=(case when year(m.date)<=1900 then '''' else convert(varchar,m.date,105) end),GSTIN=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,LgNm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.ac_name,'''') end),ConCity=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end),ConState=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.state,'''') else isnull(Cons_ac.state,'''') end)'  --Modified by Priyanka B on 05022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end),TranMode=m.u_tMode,AproxDis=m.EWBDIST'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=(case when year(m.EWBDt)<=1900 then '''' else convert(varchar,m.EWBDt,105) end),m.u_vehno,PartyPincode=Cons_sp.ZIP,transporterName=m.u_Deli,transporterId=m.Trans_Id,transDocNo=m.U_LrNo,transDocDate=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end)'  --Rup 15/03/2018
		--Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)'				--	Added by Shrikant S. on 21/03/2018 for Bug-31385
		Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then (case when isnull(Cons_sp.ac_name,'''')='''' then  isnull(Cons_ac.ac_name,'''') else isnull(Cons_sp.ac_name,'''') end) else isnull(Cons_ac.ac_name,'''') end)'		--Added by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		Set @SqlCommand=(@SqlCommand)+',vehicleType=m.cargo_typ,mainHsnCode=(Select Top 1 ISNULL(Hsncode,'''') From cnitem a inner join it_mast b on (a.it_code=b.it_code) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '	--Added By Shrikant S. on 18/05/2018 for Bug-31516
		Set @SqlCommand=(@SqlCommand)+',m.tran_cd'  --Added by Priyanka B on 14022019 for Bug-31844
		Set @SqlCommand=@SqlCommand+' From CNMain m'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Where m.Entry_Ty in(''GC'')'
		If (@pGSTIN<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@pGSTIN+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@PartyNm<>'') Begin Set @SqlCommand=@SqlCommand+' and Cons_ac.Ac_Name='+char(39)+@PartyNm+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		if @sInvno<>'' and @tInvno<>''
		Begin
			Set @SqlCommand=@SqlCommand+' and m.Inv_no Between '''+@sInvno+''' and '''+@tInvno+''''
		end
		Set @SqlCommand=@SqlCommand+' and m.Date Between '''+Convert(varchar(50),@Sdate)+''' and '''+Convert(varchar(50),@Edate)+''''
		--Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from cnitem  inner join it_mast on (it_mast.it_code=cnitem.it_code) where it_mast.isservice=1 group by tran_cd having MAX(item_no)=count(item_no))'		--Commented by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from cnitem  inner join it_mast on (it_mast.it_code=cnitem.it_code) group by tran_cd having count(tran_cd)=sum(case when it_mast.isservice=1 then 1 else 0 end))'		--Added by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	End
	If (@TrnName='SALES RETURN')
	Begin
		Set @SqlCommand='Insert into #eWayBill' 
		Set @SqlCommand=@SqlCommand+' Select Sel=Cast(0 as bit),l.Entry_Ty,SuppTyp=''Inward'',SubTyp=m.EWBSUPTYP,DocTyp=''Challan'',DocNo=m.Inv_No,DocDt=(case when year(m.date)<=1900 then '''' else convert(varchar,m.date,105) end),GSTIN=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,LgNm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.mailname,'''') else isnull(Cons_ac.ac_name,'''') end),ConCity=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.city,'''') else isnull(Cons_ac.city,'''') end),ConState=(Case when isnull(m.scons_id,0)>0 then isnull(Cons_sp.state,'''') else isnull(Cons_ac.state,'''') end)'  --Modified by Priyanka B on 05022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,TranDocNo=M.U_LrNo,TranDocDt=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end),TranMode=m.u_tMode,AproxDis=m.EWBDIST'  --Modified by Priyanka B on 06022018 for Bug-31240
		Set @SqlCommand=@SqlCommand+' ,eWAYN=m.EWBN,eWAYDt=(case when year(m.EWBDt)<=1900 then '''' else convert(varchar,m.EWBDt,105) end),m.u_vehno,PartyPincode=Cons_sp.ZIP,transporterName=m.u_Deli,transporterId=m.Trans_Id,transDocNo=m.U_LrNo,transDocDate=(case when year(m.u_lrdt)<=1900 then '''' else convert(varchar,m.u_lrdt,105) end)'  --Rup 15/03/2018
		--Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.ac_name,'''') else isnull(Cons_ac.ac_name,'''') end)'				--	Added by Shrikant S. on 21/03/2018 for Bug-31385
		Set @SqlCommand=@SqlCommand+' ,partynm=(case WHEN isnull(m.scons_id, 0) > 0 then (case when isnull(Cons_sp.ac_name,'''')='''' then  isnull(Cons_ac.ac_name,'''') else isnull(Cons_sp.ac_name,'''') end) else isnull(Cons_ac.ac_name,'''') end)'		--Added by Shrikant S. on 22/06/2018 for Sprint 1.0.1
		Set @SqlCommand=(@SqlCommand)+',vehicleType=m.cargo_typ,mainHsnCode=(Select Top 1 ISNULL(Hsncode,'''') From sritem a inner join it_mast b on (a.it_code=b.it_code) where a.ismainhsn=1 and a.Tran_cd=m.tran_cd) '	--Added By Shrikant S. on 18/05/2018 for Bug-31516'
		Set @SqlCommand=(@SqlCommand)+',m.tran_cd'  --Added by Priyanka B on 14022019 for Bug-31844
		Set @SqlCommand=@SqlCommand+' From SRMain m'
		Set @SqlCommand=@SqlCommand+' inner Join Lcode l on (m.Entry_Ty=l.Entry_TY)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto Cons_sp ON (Cons_sp.ac_id = m.Cons_id and Cons_sp.shipto_id = m.scons_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast Cons_ac ON (m.cons_id = Cons_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join shipto buyer_sp ON (buyer_sp.ac_id = m.Ac_id and buyer_sp.shipto_id = m.sAc_id)'
		Set @SqlCommand=@SqlCommand+' Left outer join ac_mast buyer_ac ON (m.Ac_id = buyer_ac.ac_id)'
		Set @SqlCommand=@SqlCommand+' Where m.Entry_Ty in(''SR'')'
		If (@pGSTIN<>'') Begin Set @SqlCommand=@SqlCommand+' and (case WHEN isnull(m.scons_id, 0) > 0 then isnull(Cons_sp.gstin,'''') else isnull(Cons_ac.gstin,'''') end)='+char(39)+@pGSTIN+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@PartyNm<>'') Begin Set @SqlCommand=@SqlCommand+' and Cons_ac.Ac_Name='+char(39)+@PartyNm+Char(39) End  --Modified by Priyanka B on 08022018 for Bug-31240
		If (@TrnName<>'') Begin Set @SqlCommand=@SqlCommand+' and l.Code_Nm='+char(39)+@TrnName+Char(39) End
		if @sInvno<>'' and @tInvno<>''
		Begin
			Set @SqlCommand=@SqlCommand+' and m.Inv_no Between '''+@sInvno+''' and '''+@tInvno+''''
		end
		Set @SqlCommand=@SqlCommand+' and m.Date Between '''+Convert(varchar(50),@Sdate)+''' and '''+Convert(varchar(50),@Edate)+''''
		--Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from sritem  inner join it_mast on (it_mast.it_code=sritem.it_code) where it_mast.isservice=1 group by tran_cd having MAX(item_no)=count(item_no))'		--Commented by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Set @SqlCommand=@SqlCommand+' and  m.tran_cd Not in (select tran_cd from sritem  inner join it_mast on (it_mast.it_code=sritem.it_code) group by tran_cd having count(tran_cd)=sum(case when it_mast.isservice=1 then 1 else 0 end))'		--Added by Shrikant S. on 13/07/2018 for Sprint 1.0.2
		Print @SqlCommand
		Execute Sp_ExecuteSql @SqlCommand	
	End

	Update #eWayBill Set PartyPincode=0 Where  ISNUMERIC(PartyPincode)=0
	Update #eWayBill Set AproxDis=0 Where  ISNUMERIC(AproxDis)=0
	Update #eWayBill Set ConState='Other Countries' Where  RTRIM(GSTIN)='' AND ConState='OTHERS'
	Update #eWayBill Set GSTIN='UNREGISTERED' Where  RTRIM(GSTIN)=''
	
	
	 Select Sel,Entry_Ty,SuppTyp,SubTyp,DocTyp,DocNo,DocDt,GSTIN
	,LgNm,ConCity,ConState
	,TranDocNo,TranDocDt,TranMode,AproxDis=cast(AproxDis as Decimal)
	,eWAYN,eWAYDt,u_vehno,PartyPincode,AproxDis=cast(AproxDis as int)	
	,transporterName,transporterId,transDocNo,transDocDate
	,partynm
	,vehicleType=ISNULL(vehicleType,''),mainHsnCode=isnull(mainHsnCode,'')				--Added By Shrikant S. on 18/05/2018 for Bug-31516
	,tran_cd  --Added by Priyanka B on 14022019 for Bug-31844
	From #eWayBill Order By convert(datetime,DocDt,105) asc,DocNo asc					--Added by Shrikant S. on 13/07/2018 for Sprint 1.0.2
	--From #eWayBill Order By DocDt asc,DocNo asc				--Commented by Shrikant S. on 13/07/2018 for Sprint 1.0.2

End



