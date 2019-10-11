If exists(Select * from sysobjects where xtype='V' and [name]='vw_GST_RCMItem')
Begin
	Drop view vw_GST_RCMItem
End
/****** Object:  View [dbo].[vw_GST_Item]    Script Date: 03/29/2018 14:58:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create View [dbo].[vw_GST_RCMItem] as
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT,i.CGST_PER
	,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMRPCESS,u_asseamt From PtItem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT
	,i.CGST_PER,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMPCESS,u_asseamt From Stitem i
	WHERE i.entry_ty='UB'
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT
	,i.CGST_PER,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,ccessrate='',COMRPCESS=0,u_asseamt From EPitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT
	,i.CGST_PER,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,ccessrate='',COMRPCESS=0,u_asseamt From SBitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT
	,i.CGST_PER,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMRPCESS,u_asseamt From SRitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT
	,i.CGST_PER,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMRPCESS,u_asseamt From cnitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT
	,i.CGST_PER,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMRPCESS,u_asseamt From dnitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT
	,i.CGST_PER,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMRPCESS,u_asseamt From pritem i
Union all	
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT,i.CGST_PER
	,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMRPCESS,u_asseamt From BPItem i	
Union all	
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT,i.CGST_PER
	,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMRPCESS,u_asseamt From CPItem i	
Union all	
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT,i.CGST_PER
	,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMRPCESS,u_asseamt From BRItem i	
Union all	
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGSRT_AMT,i.CGST_PER
	,i.CGSRT_AMT,i.IGST_PER,i.IGSRT_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.COMRPCESS,u_asseamt From CRItem i	
GO


