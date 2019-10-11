IF EXISTS(SELECT NAME FROM SYSOBJECTS WHERE XTYPE='p' AND name = 'USP_REP_ISD_GST_INWARD_SUMMARY')
BEGIN
	DROP PROCEDURE USP_REP_ISD_GST_INWARD_SUMMARY
END
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[USP_REP_ISD_GST_INWARD_SUMMARY]
@TMPAC NVARCHAR(50),@TMPIT NVARCHAR(50),@SPLCOND VARCHAR(8000),@SDATE  SMALLDATETIME,@EDATE SMALLDATETIME
,@SAC AS VARCHAR(60),@EAC AS VARCHAR(60)
,@SIT AS VARCHAR(60),@EIT AS VARCHAR(60)
,@SAMT FLOAT,@EAMT FLOAT
,@SDEPT AS VARCHAR(60),@EDEPT AS VARCHAR(60)
,@SCATE AS VARCHAR(60),@ECATE AS VARCHAR(60)
,@SWARE AS VARCHAR(60),@EWARE AS VARCHAR(60)
,@SINV_SR AS VARCHAR(60),@EINV_SR AS VARCHAR(60)
,@LYN VARCHAR(20)
,@EXPARA  AS VARCHAR(60)= NULL
AS
 Begin
    declare @sqlstr1 nvarchar(4000),@Tax_Befor_GST  varchar(max),@GST_Befor_GST  varchar(max),@Add_Befor_GST  varchar(max),@NonTax_Befor_GST  varchar(max)
    ,@Fdisc_Befor_GST  varchar(max),@Ded_Befor_GST  varchar(max),@Tax_Aft_GST  varchar(max),@GST_Aft_GST  varchar(max),@Add_Aft_GST  varchar(max),@NonTax_Aft_GST  varchar(max)
    ,@Fdisc_Aft_GST  varchar(max) ,@Ded_Aft_GST  varchar(max),@bcode_nm varchar(2),@entry_ty varchar(2)
    
/*Temporary Table for dcmast charges*/
select  d.tran_cd ,d.entry_ty ,d.itserial, h.net_amt as Tax_Befor_GST, h.net_amt as GST_Befor_GST  , h.net_amt as Add_Befor_GST  , h.net_amt as NonTax_Befor_GST
, h.net_amt as Fdisc_Befor_GST , h.net_amt as Ded_Befor_GST , h.net_amt as Tax_Aft_GST  , h.net_amt as GST_Aft_GST  , h.net_amt as Add_Aft_GST  , h.net_amt as NonTax_Aft_GST 
, h.net_amt as Fdisc_Aft_GST  , h.net_amt as Ded_Aft_GST into #tmpChrgtbl from STITEM  d  LEFT OUTER JOIN STMAIN H ON (D.ENTRY_TY= H.ENTRY_TY AND D.TRAN_CD =H.TRAN_CD )  where 1=2
/*Transactin wise details for dcmast charges*/
declare  Lother_cursor cursor for select (CASE WHEN bcode_nm <> '' THEN  bcode_nm ELSE Entry_ty END) as bcode_nm,Entry_ty   from LCODE  where Entry_ty in('PT','P1','PR','E1','GD','GC','C6','D6')
open Lother_cursor
FETCH NEXT FROM Lother_cursor INTO @bcode_nm,@entry_ty
WHILE @@FETCH_STATUS = 0
BEGIN
	 SET @Tax_Befor_GST  =''    SET @GST_Befor_GST  =''    SET @Add_Befor_GST  =''    SET @NonTax_Befor_GST  =''    SET @Fdisc_Befor_GST  =''    SET @Ded_Befor_GST  =''
	 SET @Tax_Aft_GST  =''    SET @GST_Aft_GST  =''    SET @Add_Aft_GST  =''    SET @NonTax_Aft_GST  =''    SET @Fdisc_Aft_GST  =''    SET @Ded_Aft_GST  =''
    ----before 
		SET @Tax_Befor_GST    =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft  = 1 and code = 'T' order by entry_ty,code for xml path(''))
		if @Tax_Befor_GST <> ''
			begin 
				set @Tax_Befor_GST = substring(@Tax_Befor_GST,0,len(@Tax_Befor_GST))
			end 
		else
			begin
				set  @Tax_Befor_GST = 0.00
			end		
		SET @GST_Befor_GST    =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft  = 1 and code = 'E' order by entry_ty,code for xml path(''))
		if @GST_Befor_GST <> ''
			begin 
				set @GST_Befor_GST = substring(@GST_Befor_GST,0,len(@GST_Befor_GST))
			end 
		else
			begin
				set  @GST_Befor_GST = 0.00
			end 
		SET @Add_Befor_GST    =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft  = 1 and code = 'A' order by entry_ty,code for xml path(''))
		if @Add_Befor_GST <> ''
			begin 
				set @Add_Befor_GST = substring(@Add_Befor_GST,0,len(@Add_Befor_GST))
			end 
		else
			begin
				set  @Add_Befor_GST = 0.00
			end 
		SET @NonTax_Befor_GST =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft  = 1 and code = 'N' order by entry_ty,code for xml path(''))
		if @NonTax_Befor_GST <> ''
			begin 
				set @NonTax_Befor_GST = substring(@NonTax_Befor_GST,0,len(@NonTax_Befor_GST))
			end 
		else
			begin
				set  @NonTax_Befor_GST = 0.00
			end 
		SET @Fdisc_Befor_GST  =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft  = 1 and code = 'F' order by entry_ty,code for xml path(''))
		if @Fdisc_Befor_GST <> ''
			begin 
				set @Fdisc_Befor_GST = substring(@Fdisc_Befor_GST,0,len(@Fdisc_Befor_GST))
			end 
		else
			begin
				set  @Fdisc_Befor_GST = 0.00
			end 
	    
		SET @Ded_Befor_GST    =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft  = 1 and code = 'D'  order by entry_ty,code for xml path(''))
		if @Ded_Befor_GST <> ''
			begin 
				set @Ded_Befor_GST = substring(@Ded_Befor_GST,0,len(@Ded_Befor_GST))
			end 
		else
			begin
				set  @Ded_Befor_GST = 0.00
			end 
		----After
		SET @Tax_AFt_GST    =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft  IN(2,0) and code = 'T' AND ldeactive = 0 AND FLD_NM <> 'COMPCESS' order by entry_ty,code for xml path(''))
		if @Tax_AFt_GST  <> ''
			begin 
				set @Tax_AFt_GST  = substring(@Tax_AFt_GST ,0,len(@Tax_AFt_GST ))
			end 
		else
			begin
				set  @Tax_AFt_GST  = 0.00
		end 
		---GST
		SET @GST_AFt_GST    =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft   IN(2,0) and code = 'E'  AND ldeactive = 0 AND FLD_NM <> 'COMPCESS' order by entry_ty,code for xml path(''))
		if @GST_AFt_GST  <> ''
			begin 
				set @GST_AFt_GST  = substring(@GST_AFt_GST ,0,len(@GST_AFt_GST ))
			end 
		else
			begin
				set  @GST_AFt_GST  = 0.00
		end 
		SET @Add_AFt_GST    =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft  IN(2,0) and code = 'A' AND ldeactive = 0 AND FLD_NM <> 'COMPCESS' order by entry_ty,code for xml path(''))
		if @Add_AFt_GST  <> ''
			begin 
				set @Add_AFt_GST  = substring(@Add_AFt_GST ,0,len(@Add_AFt_GST))
			end 
		else
			begin
				set  @Add_AFt_GST  = 0.00
		end 
		SET @NonTax_AFt_GST =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft   IN(2,0) and code = 'N'  AND ldeactive = 0 AND FLD_NM <> 'COMPCESS' order by entry_ty,code for xml path(''))
		if @NonTax_AFt_GST  <> ''
			begin 
				set @NonTax_AFt_GST  = substring(@NonTax_AFt_GST ,0,len(@NonTax_AFt_GST))
			end 
		else
			begin
				set  @NonTax_AFt_GST  = 0.00
		end 
		SET @Fdisc_AFt_GST  =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft   IN(2,0) and code = 'F' AND ldeactive = 0 AND FLD_NM <> 'COMPCESS' order by entry_ty,code for xml path(''))
		if @Fdisc_AFt_GST  <> ''
			begin 
				set @Fdisc_AFt_GST  = substring(@Fdisc_AFt_GST ,0,len(@Fdisc_AFt_GST))
			end 
		else
			begin
				set  @Fdisc_AFt_GST  = 0.00
		end 
		SET @Ded_Aft_GST  =(SELECT 'isnull(D.'+ltrim(rtrim(fld_nm))+',0) + '  FROM DCMAST  where Entry_ty =@entry_ty and att_file = 0 and bef_aft  IN(0,2) and code = 'D' AND ldeactive = 0 AND FLD_NM <> 'COMPCESS' order by entry_ty,code for xml path(''))
		if @Ded_Aft_GST <> ''
			begin 
				set @Ded_Aft_GST  = substring(@Ded_Aft_GST ,0,len(@Ded_Aft_GST))
			end 
		else
			begin
			set  @Ded_Aft_GST  = 0.00
		end 
		print '@Tax_Befor_GST   ' + @Tax_Befor_GST		print '@GST_Befor_GST   ' + @GST_Befor_GST  		print '@Add_Befor_GST   ' + @Add_Befor_GST  		print '@NonTax_Befor_GST ' + @NonTax_Befor_GST		print '@Fdisc_Befor_GST ' + @Fdisc_Befor_GST 		print '@Ded_Befor_GST ' + @Ded_Befor_GST 		print '@Tax_Aft_GST ' + @Tax_Aft_GST  		print '@GST_Aft_GST ' + @GST_Aft_GST  		print '@Add_Aft_GST ' + @Add_Aft_GST  		print '@NonTax_Aft_GST ' + @NonTax_Aft_GST 		print '@Fdisc_Aft_GST ' + @Fdisc_Aft_GST  		print '@Ded_Aft_GST ' + @Ded_Aft_GST
	set @sqlstr1 = ''
	set @sqlstr1 = ' insert into #tmpChrgtbl  select  d.tran_cd ,d.entry_ty ,d.itserial,  ' 
	set @sqlstr1 = @sqlstr1  + @Tax_Befor_GST + '  as Tax_Befor_GST ,' 
	set @sqlstr1 = @sqlstr1  + @GST_Befor_GST + '  as GST_Befor_GST ,'
	set @sqlstr1 = @sqlstr1  + @Add_Befor_GST + '  as Add_Befor_GST ,'
	set @sqlstr1 = @sqlstr1  + @NonTax_Befor_GST + '  as NonTax_Befor_GST ,'
	set @sqlstr1 = @sqlstr1  + @Fdisc_Befor_GST + '  as Fdisc_Befor_GST ,'
	set @sqlstr1 = @sqlstr1  + @Ded_Befor_GST + '  as Ded_Befor_GST ,'
	set @sqlstr1 = @sqlstr1  + @Tax_Aft_GST + '  as Tax_Aft_GST ,'
	set @sqlstr1 = @sqlstr1  + @GST_Aft_GST + '  as GST_Aft_GST ,'
	set @sqlstr1 = @sqlstr1  + @Add_Aft_GST + '  as Add_Aft_GST ,'
	set @sqlstr1 = @sqlstr1  + @NonTax_Aft_GST + '  as NonTax_Aft_GST ,'
	set @sqlstr1 = @sqlstr1  + @Fdisc_Aft_GST + '  as Fdisc_Aft_GST ,'
	set @sqlstr1 = @sqlstr1  + @Ded_Aft_GST + '  as Ded_Aft_GST '
	set @sqlstr1 = @sqlstr1  +' from '+@bcode_nm+'ITEM  d  INNER JOIN ' +@bcode_nm+ 'MAIN H ON (D.ENTRY_TY= H.ENTRY_TY AND D.TRAN_CD =H.TRAN_CD ) AND H.ENTRY_TY = ' + '''' + @entry_ty  + ''''  
	PRINT @sqlstr1
   EXECUTE SP_EXECUTESQL @sqlstr1
FETCH NEXT FROM Lother_cursor INTO @bcode_nm,@entry_ty   
END
CLOSE Lother_cursor
DEALLOCATE Lother_cursor

	/*PURCHASE*/
	Select srno = 1 , ORD = 'A', c.code_nm
	,c.code_nm as code_nm1
	, mon=month(b.date),yearr=year(b.date),monthh=datename(mm,b.date),b.date,b.inv_no,b.Entry_ty,b.Tran_cd
	,a.itserial
	,tot_deduc=isnull((sum(d.Fdisc_Befor_GST + d.Ded_Befor_GST)),0)
	,tot_tax=isnull(sum(d.add_Befor_GST + d.Tax_Befor_GST  +  d.NonTax_Befor_GST),0)
	,tot_add=0
	,ChrAfterGST =isnull(sum(d.Tax_Aft_GST  + d.Add_Aft_GST + d.NonTax_Aft_GST),0)
	,tot_fdisc=isnull((sum(d.Fdisc_Aft_GST + d.Ded_Aft_GST)),0)
	,u_asseamt=isnull(sum(a.qty * a.Rate),0)
	,taxname =(case when ISNULL(SUM(a.igst_amt),0) > 0  then 'IGST '+ CAST((CASE WHEN ISNULL(A.IGST_PER,0) = 0 THEN ISNULL(A.GSTRATE,0) ELSE ISNULL(A.IGST_PER,0) END)AS varchar(20))+'%' WHEN ISNULL(SUM(ISNULL(A.CGST_AMT,0)+ ISNULL(a.SGST_AMT,0)),0) > 0 THEN 'CGST+SGST ' + CAST((CASE WHEN (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) = 0  THEN ISNULL(A.GSTRATE,0) ELSE (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) END) AS varchar(20))+'%' ELSE '' END)
	,a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,isnull(sum(a.CGST_AMT),0) as CGST_AMT ,isnull(sum(a.SGST_AMT),0)as SGST_AMT,isnull(sum(a.IGST_AMT),0) as IGST_AMT,isnull(sum(a.COMPCESS),0)as COMPCESS,isnull(SUM(A.GRO_AMT),0) AS ITGRO_AMT
	,pkey = '+' 
	Into #Gstsummary from ptitem a left outer join ptmain b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
	left outer join lcode c on (b.entry_ty = c.entry_ty)
	left outer join #tmpChrgtbl d on (a.Tran_cd =d.Tran_cd and a.entry_ty =d.entry_ty and a.itserial=d.itserial )
	where a.entry_ty in ('PT') and (a.CGST_AMT+a.SGST_AMT+a.IGST_AMT) > 0  and b.date between @sdate and @edate
	group by a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,b.date,b.inv_no,b.Entry_ty,b.Tran_cd,c.code_nm
	,a.itserial	

	/*CREDIT NOTE FOR PURCHASES */
	
	insert into #Gstsummary 
	Select srno = 2 ,ORD = 'A', c.code_nm
	,c.code_nm as code_nm1
	, mon=month(b.date),yearr=year(b.date),monthh=datename(mm,b.date),b.date,b.inv_no,b.Entry_ty,b.Tran_cd
	,a.itserial
	,tot_deduc=isnull((sum(d.Fdisc_Befor_GST + d.Ded_Befor_GST)),0)
	,tot_tax=isnull(sum(d.add_Befor_GST + d.Tax_Befor_GST  +  d.NonTax_Befor_GST),0)
	,tot_add=0
	,ChrAfterGST =isnull(sum(d.Tax_Aft_GST  + d.Add_Aft_GST + d.NonTax_Aft_GST),0)
	,tot_fdisc=isnull((sum(d.Fdisc_Aft_GST + d.Ded_Aft_GST)),0)
	,u_asseamt=isnull(sum(a.qty * a.Rate),0)
	,taxname =(case when ISNULL(SUM(a.igst_amt),0) > 0  then 'IGST '+ CAST((CASE WHEN ISNULL(A.IGST_PER,0) = 0 THEN ISNULL(A.GSTRATE,0) ELSE ISNULL(A.IGST_PER,0) END)AS varchar(20))+'%' WHEN ISNULL(SUM(ISNULL(A.CGST_AMT,0)+ ISNULL(a.SGST_AMT,0)),0) > 0 THEN 'CGST+SGST ' + CAST((CASE WHEN (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) = 0  THEN ISNULL(A.GSTRATE,0) ELSE (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) END) AS varchar(20))+'%' ELSE '' END)
	,a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,isnull(sum(a.CGST_AMT),0) as CGST_AMT ,isnull(sum(a.SGST_AMT),0)as SGST_AMT,isnull(sum(a.IGST_AMT),0) as IGST_AMT,isnull(sum(a.COMPCESS),0)as COMPCESS,isnull(SUM(A.GRO_AMT),0) AS ITGRO_AMT
	,pkey = '+' 
	from CNITEM a left outer join CNMAIN b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
	left outer join lcode c on (b.entry_ty = c.entry_ty)
	left outer join #tmpChrgtbl d on (a.Tran_cd =d.Tran_cd and a.entry_ty =d.entry_ty and a.itserial=d.itserial )
	where  b.AGAINSTGS in('PURCHASES') And b.entry_ty in('GC')
	and (a.CGST_AMT+a.SGST_AMT+a.IGST_AMT) > 0  and b.date between @sdate and @edate
	group by a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,b.date,b.inv_no,b.Entry_ty,b.Tran_cd,c.code_nm
	,a.itserial
		
	/*DEBIT NOTE FOR PURCHASES*/

	insert into #Gstsummary 
	Select srno = 3 ,ORD = 'B', c.code_nm
	,c.code_nm as code_nm1
	, mon=month(b.date),yearr=year(b.date),monthh=datename(mm,b.date),b.date,b.inv_no,b.Entry_ty,b.Tran_cd
	,a.itserial
	,tot_deduc=isnull((sum(d.Fdisc_Befor_GST + d.Ded_Befor_GST)),0)
	,tot_tax=isnull(sum(d.add_Befor_GST + d.Tax_Befor_GST  +  d.NonTax_Befor_GST),0)
	,tot_add=0
	,ChrAfterGST =isnull(sum(d.Tax_Aft_GST  + d.Add_Aft_GST + d.NonTax_Aft_GST),0)
	,tot_fdisc=isnull((sum(d.Fdisc_Aft_GST + d.Ded_Aft_GST)),0)
	,u_asseamt=isnull(sum(a.qty * a.Rate),0)
	,taxname =(case when ISNULL(SUM(a.igst_amt),0) > 0  then 'IGST '+ CAST((CASE WHEN ISNULL(A.IGST_PER,0) = 0 THEN ISNULL(A.GSTRATE,0) ELSE ISNULL(A.IGST_PER,0) END)AS varchar(20))+'%' WHEN ISNULL(SUM(ISNULL(A.CGST_AMT,0)+ ISNULL(a.SGST_AMT,0)),0) > 0 THEN 'CGST+SGST ' + CAST((CASE WHEN (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) = 0  THEN ISNULL(A.GSTRATE,0) ELSE (ISNULL(A.CGST_PER,0)+ISNULL(a.SGST_PER,0)) END) AS varchar(20))+'%' ELSE '' END)
	,a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,isnull(sum(a.CGST_AMT),0) as CGST_AMT ,isnull(sum(a.SGST_AMT),0)as SGST_AMT,isnull(sum(a.IGST_AMT),0) as IGST_AMT,isnull(sum(a.COMPCESS),0)as COMPCESS,isnull(SUM(A.GRO_AMT),0) AS ITGRO_AMT
	,pkey = '-' 
	from DNITEM a left outer join DNMAIN b on (a.entry_ty =b.entry_ty and a.Tran_cd =b.Tran_cd)
	left outer join lcode c on (b.entry_ty = c.entry_ty)
	left outer join #tmpChrgtbl d on (a.Tran_cd =d.Tran_cd and a.entry_ty =d.entry_ty and a.itserial=d.itserial )
	where  b.AGAINSTGS in('PURCHASES') aND B.entry_ty IN('GD')
	and (a.CGST_AMT+a.SGST_AMT+a.IGST_AMT) > 0  and b.date between @sdate and @edate
	group by a.cgst_per,a.sgst_per,a.igst_per,a.GSTRATE,b.date,b.inv_no,b.Entry_ty,b.Tran_cd,c.code_nm
	,a.itserial

	Update a set 
	a.CGST_AMT = a.CGST_AMT - e.ICGST_AMT
	,a.SGST_AMT = a.SGST_AMT - e.ISGST_AMT
	,a.IGST_AMT = a.IGST_AMT - e.IIGST_AMT
	,a.COMPCESS = a.COMPCESS - e.ICESS_AMT
	from #Gstsummary a inner join epayment e on (e.entry_ty=a.entry_ty and e.tran_cd=a.tran_cd and e.itserial=a.itserial)
	
	select *,TAXABLE=(u_asseamt + tot_tax - tot_deduc )
	,GST_AMT=(CGST_AMT +SGST_AMT + IGST_AMT)
	,total=((u_asseamt + tot_tax  + CGST_AMT +SGST_AMT + IGST_AMT + COMPCESS + ChrAfterGST) - (tot_fdisc + tot_deduc))  
	from #Gstsummary 
	order by yearr,mon,gstrate,taxname,date,ORD,srno 
	
drop table #tmpChrgtbl
drop table #Gstsummary
end


