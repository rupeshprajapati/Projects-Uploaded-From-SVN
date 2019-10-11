declare @rrange int 
set @rrange = 0
select @rrange = (max(range)+1)  from com_menu
print @rrange
IF NOT EXISTS(SELECT PADNAME,BARNAME,PROMPNAME FROM COM_MENU WHERE padname = 'GSTRETURN' AND barname = 'FORMGSTR3B')
BEGIN 
	INSERT INTO com_menu([range], [padname], [padnum], [barname], [barnum], [prompname], [numitem], [hotkey], [progname], [E_], [n_], [r_], [t_], [i_], [o_], [b_], [x_], [Menutype], [Isactive], [puser], [mdefault], [labkey], [skipfor], [cprog], [mark], [xtvs_], [dsni_], [mcur_], [tds_], [newrange], [HRPay_], [eou_], [gst_]) 
	VALUES (@rrange, 'GSTRETURN', 0, 'FORMGSTR3B', 10, 'FORM GSTR 3B', 0, '', 'DO UEGSTREPORT WITH 1,"FORM GSTR 3B", "^'+CAST(@RRANGE AS VARCHAR)+'"', null, null, null, null, null, null, null, null, 'Report', null, 'FORM GSTR 3B', null, '', null, null, null, null, null, null, 0, null, 0, 0, 0)
END
IF NOT EXISTS(SELECT[group], [desc], [rep_nm] FROM R_STATUS WHERE [group]= 'FORM GSTR 3B' AND [desc]='FORM GSTR 3B' AND  [rep_nm]='GSTR3B')
BEGIN 
	INSERT INTO R_STATUS([group], [desc], [rep_nm], [rep_nm1], [defa], [ismethod], [isfr_date], [isto_date], [isfr_ac], [isto_ac], [isfr_item], [isto_item], [isfr_amt], [isto_amt], [isdept], [iscategory], [iswarehous], [isinvseri], [vou_type], [spl_condn], [qTable], [runbefore], [runafter], [isfr_area], [isto_area], [dontshow], [methodof], [repfcondn], [repfcodn], [e_], [x_], [i_], [o_], [n_], [r_], [t_], [b_], [ac_group], [it_group], [RetTable], [SQLQUERY], [ZOOMTYPE], [spWhat], [xtvs_], [dsni_], [mcur_], [retfilenm], [tds_], [DISPORD], [isrule], [newgroup], [HRPay_], [ExpFileNm], [EMailSub], [EmailBody], [PGBRKFLD], [PgBrakFld], [copyname], [Datecaption], [zoominfld], [AUTOEMAIL], [isrpttbl], [isfixtbl], [RepoCap], [eou_], [gst_], [RepFor]) 
	VALUES ('FORM GSTR 3B', 'FORM GSTR 3B', 'GSTR3B', '', 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', '', '', 0, 0, 0, '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '_PTMAIN ', 'EXECUTE Usp_Rep_GSTR3B ;', ' ', 'P', 0, 0, 0, '', 0, 0, 0, null, 0, '', '', '', '', '', '', '', '', 0, 0, 0, 'FORM GSTR 3B', 0, 0, 1)
END