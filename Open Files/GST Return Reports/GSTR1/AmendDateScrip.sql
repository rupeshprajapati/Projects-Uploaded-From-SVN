---- For Amend Transactions
IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'ST' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('ST', 'Amend Date     ', 'AmendDate ', 'Datetime     ', 8, 0, 1, '  ', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, ' ', 0, 0, '  ', 0, '  ', '   ', 0, 'ADMIN    ', '06/15/17 14:03:48      ', 0, 'STMAIN    ', 0, 0, '¦¨‚ÚÊÜÈˆÂèÊ    ', 'T', '  ', 0, 0, '  ', '   ', '   ', ' ', ' ', '  ', '   ', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)

END 
EXEC Add_Columns 'STMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'S1' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('S1', 'Amend Date', 'AmendDate ', 'Datetime', 8, 0, 1, '', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, '', 0, 0, '', 0, '', '   ', 0, 'SK', '06/08/17 11:52:40      ', 0, 'SBMMAIN ', 0, 0, '¦¨‚šŠœˆˆ‚¨Š', 'T', '', 0, 0, '', '', '', ' ', ' ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'SBMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'D6' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('D6', 'Amend Date', 'AmendDate ', 'Datetime', 8, 0, 1, '', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, '', 0, 0, '', 0, '', '   ', 0, 'SK', '06/08/17 11:52:40      ', 0, 'DNMAIN', 0, 0, '¦¨‚šŠœˆˆ‚¨Š', 'T', '', 0, 0, '', '', '', ' ', ' ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'DNMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'GD' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('GD', 'Amend Date', 'AmendDate ', 'Datetime', 8, 0, 1, '', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, '', 0, 0, '', 0, '', '   ', 0, 'SK', '06/08/17 11:52:40      ', 0, 'DNMAIN ', 0, 0, '¦¨‚šŠœˆˆ‚¨Š', 'T', '', 0, 0, '', '', '', ' ', ' ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'DNMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'C6' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('C6', 'Amend Date', 'AmendDate ', 'Datetime', 8, 0, 1, '', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, '', 0, 0, '', 0, '', '   ', 0, 'SK', '06/08/17 11:52:40      ', 0, 'CNMAIN ', 0, 0, '¦¨‚šŠœˆˆ‚¨Š', 'T', '', 0, 0, '', '', '', ' ', ' ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'CNMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'GC' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('GC', 'Amend Date', 'AmendDate ', 'Datetime', 8, 0, 1, '', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, '', 0, 0, '', 0, '', '   ', 0, 'SK', '06/08/17 11:52:40      ', 0, 'CNMAIN ', 0, 0, '¦¨‚šŠœˆˆ‚¨Š', 'T', '', 0, 0, '', '', '', ' ', ' ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'CNMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'PT' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('PT', 'Amend Date', 'AmendDate ', 'Datetime', 8, 0, 1, '', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, '', 0, 0, '', 0, '', '   ', 0, 'SK', '06/08/17 11:52:40      ', 0, 'PTMAIN ', 0, 0, '¦¨‚šŠœˆˆ‚¨Š', 'T', '', 0, 0, '', '', '', ' ', ' ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)

END 
EXEC Add_Columns 'PTMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'P1' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('P1', 'Amend Date', 'AmendDate ', 'Datetime', 8, 0, 1, '', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, '', 0, 0, '', 0, '', '   ', 0, 'SK', '06/08/17 11:52:40      ', 0, 'PTMAIN ', 0, 0, '¦¨‚šŠœˆˆ‚¨Š', 'T', '', 0, 0, '', '', '', ' ', ' ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'PTMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'E1' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('E1', 'Amend Date', 'AmendDate ', 'Datetime', 8, 0, 1, '', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, '', 0, 0, '', 0, '', '   ', 0, 'SK', '06/08/17 11:52:40      ', 0, 'EPMAIN ', 0, 0, '¦¨‚šŠœˆˆ‚¨Š', 'T', '', 0, 0, '', '', '', ' ', ' ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)

END 
EXEC Add_Columns 'EPMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'
---- For Amend Transactions

----- Refund voucher 
IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'RV' AND fld_nm = 'AmendDate' AND HEAD_NM ='Amend Date')
BEGIN
	INSERT INTO lother([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('RV', 'Amend Date', 'AmendDate ', 'Datetime', 8, 0, 1, '', 'IIF(!EMPTY(this.value),IIF(this.value < MAIN_VW.date,.F.,.T.),.T.)', '"Amend date should be greather than transaction date"', '', '', 81, '', 0, 0, '', 0, '', '   ', 0, 'SK', '06/08/17 11:52:40      ', 0, 'BPMAIN ', 0, 0, '¦¨‚šŠœˆˆ‚¨Š', 'T', '', 0, 0, '', '', '', ' ', ' ', '', '', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'BPMAIN','AmendDate SMALLDATETIME DEFAULT '''' WITH VALUES'
--- for Export U_SBDT
IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'GD' AND fld_nm = 'U_SBDT' AND HEAD_NM ='Shipping Date')
BEGIN
	INSERT INTO LOTHER([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('GD', 'Shipping Date    ', 'U_SBDT    ', 'Datetime            ', 8, 0, 1, '                       ', '                       ', '                       ', '                       ', '', 81, '                 ', 0, 0, 'IIF(MAIN_VW.AGAINSTGS = ''SALES'',.F.,.T.)                ', 0, '                       ', '   ', 0, 'ADMIN                         ', '06/15/17 12:03:25             ', 0, 'DNMAIN    ', 0, 0, 'Žˆª¾¦„ˆ¨         ', 'T', '                       ', 0, 0, '                       ', '          ', '          ', ' ', '        ', ' ', '          ', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'DNMAIN','U_SBDT SMALLDATETIME DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'GC' AND fld_nm = 'U_SBDT' AND HEAD_NM ='Shipping Date')
BEGIN
INSERT INTO LOTHER([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
VALUES ('GC', 'Shipping Date    ', 'U_SBDT    ', 'Datetime            ', 8, 0, 1, '                       ', '                       ', '                       ', '                       ', '', 81, '                 ', 0, 0, 'IIF(MAIN_VW.AGAINSTGS=''SALES'',.F.,.T.)                  ', 0, '                       ', '   ', 0, 'ADMIN                         ', '06/15/17 12:04:14             ', 0, 'CNMAIN    ', 0, 0, 'Ž†ª¾¦„ˆ¨         ', 'T', '                       ', 0, 0, '                       ', '          ', '          ', ' ', '        ', ' ', '          ', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)

END 
EXEC Add_Columns 'CNMAIN','U_SBDT SMALLDATETIME DEFAULT '''' WITH VALUES'
-----For Export u_VESSEL
IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'GD' AND fld_nm = 'u_VESSEL' AND HEAD_NM ='Shipping Bill No')
BEGIN
	INSERT INTO LOTHER([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('GD', 'Shipping Bill No ', 'u_VESSEL  ', 'Varchar             ', 50, 0, 1, '                       ', '                       ', '                       ', '                       ', '', 81, '                 ', 0, 0, 'IIF(MAIN_VW.AGAINSTGS =''SALES'',.F.,.T.)                 ', 0, '                       ', '   ', 0, 'ADMIN                         ', '06/15/17 12:00:31             ', 0, 'DNMAIN    ', 0, 0, 'Žˆê¾¬Š¦¦Š˜       ', 'T', '                       ', 0, 0, '                       ', '          ', '          ', ' ', '        ', ' ', '          ', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'DNMAIN','u_VESSEL Varchar(50) DEFAULT '''' WITH VALUES'

IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'GC' AND fld_nm = 'u_VESSEL' AND HEAD_NM ='Shipping Bill No')
BEGIN
	INSERT INTO LOTHER([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('GC', 'Shipping Bill No ', 'u_VESSEL  ', 'Varchar             ', 50, 0, 1, '                       ', '                       ', '                       ', '                       ', '', 81, '                 ', 0, 0, 'IIF(MAIN_VW.AGAINSTGS = ''SALES'',.F.,.T.)                ', 0, '                       ', '   ', 0, 'ADMIN                         ', '06/15/17 12:02:05             ', 0, 'CNMAIN    ', 0, 0, 'Ž†ê¾¬Š¦¦Š˜       ', 'T', '                       ', 0, 0, '                       ', '          ', '          ', ' ', '        ', ' ', '          ', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
EXEC Add_Columns 'CNMAIN','u_VESSEL Varchar(50) DEFAULT '''' WITH VALUES'

-----for Sales Transatin  for Pick fields 
IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'ST' AND fld_nm = 'u_VESSEL' AND HEAD_NM ='Shipping Bill No')
BEGIN
	INSERT INTO LOTHER([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
	VALUES ('ST', 'Shipping Bill No ', 'u_VESSEL  ', 'Varchar             ', 50, 0, 1, '                       ', '                       ', '                       ', '                       ', '', 81, '                 ', 0, 0, '.T.                    ', 0, '                       ', '   ', 0, 'ADMIN                         ', '06/15/17 11:49:48             ', 0, 'LMC       ', 0, 0, '¦¨ê¾¬Š¦¦Š˜       ', 'T', '                       ', 0, 0, '                       ', '          ', '          ', ' ', '        ', ' ', '          ', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
IF NOT EXISTS(SELECT  HEAD_NM FROM LOTHER WHERE E_CODE = 'ST' AND fld_nm = 'U_SBDT' AND HEAD_NM ='Shipping Date')
BEGIN
		INSERT INTO LOTHER([e_code], [head_nm], [fld_nm], [data_ty], [fld_wid], [fld_dec], [att_file], [whn_con], [val_con], [val_err], [defa_val], [filtcond], [serial], [heading], [lines], [formno], [inter_use], [bef_aft], [mandatory], [com_type], [inpickup], [user_name], [sysdate], [ingrid], [tbl_nm], [inf11], [Pickedit], [Passroute], [Type], [Remarks], [defa_fld], [CompId], [Validity], [pop_tblnm], [pop_fldnm], [hotkey], [tbl_nm1], [formdesc], [inptmask], [SubSerial], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [xtvs_], [dsni_], [mcur_], [tds_], [HRPay_], [SEZU_], [ModuleCode], [Prodcode], [gst_], [LSHWSALETAXFRM], [_UDPOS]) 
		VALUES ('ST', 'Shipping Date    ', 'U_SBDT    ', 'Datetime            ', 8, 0, 1, '                       ', '                       ', '                       ', '                       ', '', 81, '                 ', 0, 0, '.T.                    ', 0, '                       ', '   ', 0, 'ADMIN                         ', '06/15/17 11:50:20             ', 0, 'LMC       ', 0, 0, '¦¨ª¾¦„ˆ¨         ', 'T', '                       ', 0, 0, '                       ', '          ', '          ', ' ', '        ', ' ', '          ', 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, null, 0, 0, 0)
END 
