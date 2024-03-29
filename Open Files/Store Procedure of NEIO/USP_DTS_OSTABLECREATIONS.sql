DROP PROCEDURE [USP_DTS_OSTABLECREATIONS]
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [USP_DTS_OSTABLECREATIONS] AS

IF EXISTS(SELECT name FROM sysobjects WHERE name = 'OSMAIN' AND type = 'U')
begin
	update OSMAIN set ac_Id=a.ac_Id from ac_mast a,OSMAIN b where a.ac_name=b.party_nm
	update OSITEM set TRAN_CD=a.TRAN_CD from OSMAIN a,OSITEM b where a.Entry_ty=b.Entry_ty And a.Doc_No=b.Doc_No And a.[Date]=b.[Date]
	update OSACDET set TRAN_CD=a.TRAN_CD from OSMAIN a,OSACDET b where a.Entry_ty=b.Entry_ty And a.Doc_No=b.Doc_No And a.[Date]=b.[Date]
--	update OSACDET set DATE_ALL=a.[DATE] from OSMAIN a,OSACDET b where a.Entry_ty=b.Entry_Ty And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
--	update OSACDET set DOC_ALL=a.[DOC_NO] from OSMAIN a,OSACDET b where a.Entry_ty=b.Entry_Ty And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
	update OSMALL set TRAN_CD=a.TRAN_CD from OSMAIN a,OSMALL b where a.Entry_ty=b.Entry_ty And a.Doc_No=b.Doc_No And a.[Date]=b.[Date]
	update OSMALL set MAIN_TRAN=a.[TRAN_CD] from OSMAIN a,OSMALL b where a.Entry_ty=b.Entry_Ty And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
	update OSMALL set DOC_ALL=a.[DOC_NO] from OSMAIN a,OSMALL b where a.Entry_ty=b.Entry_All And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
	update OSMALL set DATE_ALL=a.[DATE] from OSMAIN a,OSMALL b where a.Entry_ty=b.Entry_All And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
	update OSITREF set TRAN_CD=a.TRAN_CD from OSMAIN a,OSITREF b where a.Entry_ty=b.Entry_ty And a.Doc_No=b.Doc_No And a.[Date]=b.[Date]

	DELETE OSMAIN Where party_nm <> 'OPENING STOCK'
	DELETE OSITEM Where TRAN_CD NOT IN (Select Tran_Cd From OSMAIN)
	DELETE OSACDET Where TRAN_CD NOT IN (Select Tran_Cd From OSMAIN)
	DELETE OSMALL Where TRAN_CD NOT IN (Select Tran_Cd From OSMAIN)
	DELETE OSITREF Where TRAN_CD NOT IN (Select Tran_Cd From OSMAIN)

	update OBMAIN set ac_Id=a.ac_Id from ac_mast a,OBMAIN b where a.ac_name=b.party_nm
	update OBITEM set TRAN_CD=a.TRAN_CD from OBMAIN a,OBITEM b where a.Entry_ty=b.Entry_ty And a.Doc_No=b.Doc_No And a.[Date]=b.[Date]
	update OBACDET set TRAN_CD=a.TRAN_CD from OBMAIN a,OBACDET b where a.Entry_ty=b.Entry_ty And a.Doc_No=b.Doc_No And a.[Date]=b.[Date]
	--update OBACDET set DATE_ALL=a.[DATE] from OBMAIN a,OBACDET b where a.Entry_ty=b.Entry_Ty And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
	--update OBACDET set DOC_ALL=a.[DOC_NO] from OBMAIN a,OBACDET b where a.Entry_ty=b.Entry_Ty And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
	update OBMALL set TRAN_CD=a.TRAN_CD from OBMAIN a,OBMALL b where a.Entry_ty=b.Entry_ty And a.Doc_No=b.Doc_No And a.[Date]=b.[Date]
	update OBMALL set MAIN_TRAN=a.[TRAN_CD] from OBMAIN a,OSMALL b where a.Entry_ty=b.Entry_Ty And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
	update OBMALL set DOC_ALL=a.[DOC_NO] from OBMAIN a,OBMALL b where a.Entry_ty=b.Entry_All And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
	update OBMALL set DATE_ALL=a.[DATE] from OBMAIN a,OBMALL b where a.Entry_ty=b.Entry_All And a.Inv_Sr=b.Inv_Sr And a.Inv_No=b.Inv_No And a.L_Yn=b.L_Yn
	update OBITREF set TRAN_CD=a.TRAN_CD from OBMAIN a,OBITREF b where a.Entry_ty=b.Entry_ty And a.Doc_No=b.Doc_No And a.[Date]=b.[Date]

	DELETE OBMAIN Where party_nm LIKE 'OPENING STOCK'
	DELETE OBITEM Where TRAN_CD NOT IN (Select Tran_Cd From OBMAIN)
	DELETE OBACDET Where TRAN_CD NOT IN (Select Tran_Cd From OBMAIN)
	DELETE OBMALL Where TRAN_CD NOT IN (Select Tran_Cd From OBMAIN)
	DELETE OBITREF Where TRAN_CD NOT IN (Select Tran_Cd From OBMAIN)
end
GO
