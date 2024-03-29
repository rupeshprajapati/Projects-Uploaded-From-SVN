DROP VIEW [vw_GST_Item]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [vw_GST_Item] as
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT,i.CGST_PER
	,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From PtItem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT
	,i.CGST_PER,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From Stitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT
	,i.CGST_PER,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,ccessrate='',compcess=0,u_asseamt From EPitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT
	,i.CGST_PER,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,ccessrate='',compcess=0,u_asseamt From SBitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT
	,i.CGST_PER,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From SRitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT
	,i.CGST_PER,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From cnitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT
	,i.CGST_PER,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From dnitem i
Union all
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT
	,i.CGST_PER,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From pritem i
Union all	
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT,i.CGST_PER
	,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From BPItem i	
Union all	
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT,i.CGST_PER
	,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From CPItem i	
Union all	
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT,i.CGST_PER
	,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From BRItem i	
Union all	
Select i.Entry_ty,i.Tran_cd,i.ItSerial,i.It_Code,i.Qty,i.Rate,i.tot_deduc,i.tot_add,i.u_asseamt GTAXABLAMT,i.sgst_per,i.SGST_AMT,i.CGST_PER
	,i.CGST_AMT,i.IGST_PER,i.IGST_AMT,i.tot_examt,i.tot_nontax,i.tot_fdisc,i.Gro_Amt,i.pmkey,i.ccessrate,i.compcess,u_asseamt From CRItem i
GO
