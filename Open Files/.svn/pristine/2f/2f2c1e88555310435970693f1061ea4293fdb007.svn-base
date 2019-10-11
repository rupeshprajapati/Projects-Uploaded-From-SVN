If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_GS_VOU')
Begin
	Drop Procedure USP_REP_GS_VOU
End
/****** Object:  StoredProcedure [dbo].[USP_REP_GS_VOU]    Script Date: 01/09/2018 11:49:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[USP_REP_GS_VOU]
@ENTRYCOND NVARCHAR(254)
as
Begin
	Declare @SQLCOMMAND as NVARCHAR(4000),@TBLCON as NVARCHAR(4000)

	SET @TBLCON=RTRIM(@ENTRYCOND)	
			Select Entry_ty,Tran_cd=0 Into #Brmain from BRMAIN Where 1=0
			set @SQLCOMMAND='Insert Into #Brmain Select a.Entry_ty,a.Tran_cd from brmain a Where '+@TBLCON
			PRINT @SQLCOMMAND
			execute sp_executesql @SQLCOMMAND

			
	Select a.entry_ty,a.Tran_cd,a.bank_nm,a.Date,a.net_amt,a.u_chandt,
	a.CREDITCNO,a.CREDITCNM,a.NETBANKAC,a.PAYTYPE,a.DepoType,a.BANKACNO,a.BENEACNO,a.BENEACNM,a.BANKCODE
	--,a.EPAY,a.OVERCOUNT,a.NEFTRTGS
	,a.GSTPAYTYPE
	,a.CPIN,a.BANKREFNO,a.BANKACKNO
	,CGST_tax=Case when am.ac_name='Balance with CGST Cash Ledger' and (a.DepoType='' or a.DepoType='Tax') then ac.amount else 0 end
	,SGST_tax=Case when am.ac_name='Balance with SGST Cash Ledger' and (a.DepoType='' or a.DepoType='Tax') then ac.amount else 0 end
	,IGST_tax=Case when am.ac_name='Balance with IGST Cash Ledger' and (a.DepoType='' or a.DepoType='Tax') then ac.amount else 0 end
	,CESS_tax=Case when am.ac_name='Balance with CCESS Cash Ledger' and (a.DepoType='' or a.DepoType='Tax') then ac.amount else 0 end

	,CGST_int=Case when am.ac_name='Balance with CGST Cash Ledger' and a.DepoType='Interest' then ac.amount else 0 end
	,SGST_int=Case when am.ac_name='Balance with SGST Cash Ledger' and a.DepoType='Interest' then ac.amount else 0 end
	,IGST_int=Case when am.ac_name='Balance with IGST Cash Ledger' and a.DepoType='Interest' then ac.amount else 0 end
	,CESS_int=Case when am.ac_name='Balance with CCESS Cash Ledger' and a.DepoType='Interest' then ac.amount else 0 end

	,CGST_penalty=Case when am.ac_name='Balance with CGST Cash Ledger' and a.DepoType='Penalty' then ac.amount else 0 end
	,SGST_penalty=Case when am.ac_name='Balance with SGST Cash Ledger' and a.DepoType='Penalty' then ac.amount else 0 end
	,IGST_penalty=Case when am.ac_name='Balance with IGST Cash Ledger' and a.DepoType='Penalty' then ac.amount else 0 end
	,CESS_penalty=Case when am.ac_name='Balance with CCESS Cash Ledger' and a.DepoType='Penalty' then ac.amount else 0 end

	,CGST_Fee=Case when am.ac_name='Balance with CGST Cash Ledger' and a.DepoType='Fee' then ac.amount else 0 end
	,SGST_Fee=Case when am.ac_name='Balance with SGST Cash Ledger' and a.DepoType='Fee' then ac.amount else 0 end
	,IGST_Fee=Case when am.ac_name='Balance with IGST Cash Ledger' and a.DepoType='Fee' then ac.amount else 0 end
	,CESS_Fee=Case when am.ac_name='Balance with CCESS Cash Ledger' and a.DepoType='Fee' then ac.amount else 0 end

	,CGST_Oth=Case when am.ac_name='Balance with CGST Cash Ledger' and a.DepoType='Others' then ac.amount else 0 end
	,SGST_Oth=Case when am.ac_name='Balance with SGST Cash Ledger' and a.DepoType='Others' then ac.amount else 0 end
	,IGST_Oth=Case when am.ac_name='Balance with IGST Cash Ledger' and a.DepoType='Others' then ac.amount else 0 end
	,CESS_Oth=Case when am.ac_name='Balance with CCESS Cash Ledger' and a.DepoType='Others' then ac.amount else 0 end

	,CGST_Tot=Case when am.ac_name='Balance with CGST Cash Ledger' then ac.amount else 0 end
	,SGST_Tot=Case when am.ac_name='Balance with SGST Cash Ledger' then ac.amount else 0 end
	,IGST_Tot=Case when am.ac_name='Balance with IGST Cash Ledger' then ac.amount else 0 end
	,CESS_Tot=Case when am.ac_name='Balance with CCESS Cash Ledger' then ac.amount else 0 end
	
	,a.Inv_sr,a.Inv_no
	Into #tmppayment
	from Brmain a 
	Inner Join Bracdet ac on (a.Entry_ty=ac.Entry_ty and a.Tran_cd=ac.Tran_cd)
	INNER JOIN #Brmain a2 ON (a.TRAN_CD=a2.TRAN_CD and a.Entry_ty=a2.entry_ty )
	Inner Join ac_mast am on (ac.ac_id=am.ac_id)
	Inner Join ac_mast a1 on(a.bank_nm=a1.ac_name)
	Where a.entry_ty='GS' and am.typ = 'Cash'
	Order by a.inv_sr,a.Inv_no
	
	select a.entry_ty,a.Tran_cd,a.bank_nm,a.Date,a.net_amt,a.u_chandt,
	a.CREDITCNO,a.CREDITCNM,a.NETBANKAC,a.PAYTYPE,a.DepoType,a.BANKACNO,a.BENEACNO,a.BENEACNM,a.BANKCODE
	--,a.EPAY,a.OVERCOUNT,a.NEFTRTGS
	,a.GSTPAYTYPE
	,a.CPIN,a.inv_sr,a.Inv_no,a.BANKREFNO,a.BANKACKNO
	,CGST_tax=SUM(a.CGST_tax),SGST_tax=SUM(a.SGST_tax),IGST_tax=SUM(a.IGST_tax)
	,CESS_tax=SUM(a.CESS_tax)
	,CGST_int=SUM(a.CGST_int),SGST_int=SUM(a.SGST_int),IGST_int=SUM(a.IGST_int)
	,CESS_int=SUM(a.CESS_int)
	,CGST_penalty=SUM(a.CGST_penalty),SGST_penalty=SUM(a.SGST_penalty),IGST_penalty=SUM(a.IGST_penalty)
	,CESS_penalty=SUM(a.CESS_penalty)
	,CGST_Fee=sum(a.CGST_Fee),SGST_Fee=sum(a.SGST_Fee),IGST_Fee=sum(a.IGST_Fee)
	,CESS_Fee=SUM(a.CESS_Fee)
	,CGST_Oth=SUM(a.CGST_Oth),SGST_Oth=SUM(a.SGST_Oth),IGST_Oth=SUM(a.IGST_Oth)
	,CESS_Oth=SUM(a.CESS_Oth)
	,CGST_Tot=sum(a.CGST_Tot),SGST_Tot=sum(a.SGST_Tot),IGST_Tot=sum(a.IGST_Tot)
	,CESS_Tot=SUM(a.CESS_Tot)
	,a.inv_sr,a.Inv_no
	From #tmppayment a  
	group by a.entry_ty,a.Tran_cd,a.bank_nm,a.Date,a.net_amt,a.u_chandt,
	a.CREDITCNO,a.CREDITCNM,a.NETBANKAC,a.PAYTYPE,a.DepoType,a.BANKACNO,a.BENEACNO,a.BENEACNM,a.BANKCODE
	--,a.EPAY,a.OVERCOUNT,a.NEFTRTGS
	,a.GSTPAYTYPE
	,a.CPIN,a.inv_sr,a.Inv_no,a.BANKREFNO,a.BANKACKNO
		order by a.inv_sr,a.Inv_no
End
