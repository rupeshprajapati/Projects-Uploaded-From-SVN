
ALTER PROCEDURE [dbo].[SP_CREDIT_AVAILABILITY]
@from DATETIME,@to DATETIME
,@supply VARCHAR(50)

AS
BEGIN
	IF(@supply = '0')
	BEGIN 
		--Purchase & Import Purchase update column ECredit 
		IF Exists(Select top 1 Tran_cd from PTITEM WHERE  date between @from AND @to AND entry_ty  IN('PT','P1') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM PTITEM I
			inner JOIN PTMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) --added by Prajakta B. on 04052018 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('PT','P1')  
			and im.isService=0  --added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		
		--Purchase Return update column ECredit 
		IF Exists(Select top 1 Tran_cd from PRITEM WHERE  date between @from AND @to AND entry_ty  IN('PR') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM PRITEM I
			inner JOIN PRMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) --added by Prajakta B. on 04052018 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('PR') 
			and im.isService=0 --added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		
		--Self Invoice update column ECredit 
		IF Exists(Select top 1 Tran_cd from STITEM WHERE  date between @from AND @to AND entry_ty  IN('UB') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM STITEM I
			inner JOIN STMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) --added by Prajakta B. on 04052018 
			
			--WHERE  M.date between @from AND @to AND M.entry_ty in ('UB') AND M.AGAINSTGS='GOODS'   --Comment Rupesh G on 11-05-2018 for Bug no 31401
			WHERE  M.date between @from AND @to AND M.entry_ty in ('UB') 
			and im.isService=0 --added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
						
		End
		
			--DEBIT NOTE SUPPLY OF GOODS update column ECredit 
		IF Exists(Select top 1 Tran_cd from DNITEM WHERE  date between @from AND @to AND entry_ty  IN('GD') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM DNITEM I
			inner JOIN DNMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) --added by Prajakta B. on 04052018 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('GD') AND M.AGAINSTGS='PURCHASES' 
			and im.isService=0 --added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		
		--CREDIT NOTE SUPPLY OF GOODS update column ECredit 
		IF Exists(Select top 1 Tran_cd from CNITEM WHERE  date between @from AND @to AND entry_ty  IN('GC') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM CNITEM I
			inner JOIN CNMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) --added by Prajakta B. on 04052018 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('GC') AND M.AGAINSTGS='PURCHASES' 
			and im.isService=0 --added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		-------------------
	    --Purchase & Import Purchase Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,M.pinvno,M.pinvdt,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' ,a.HSNCODE,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm as 'linerule',(I.COMPCESS+I.COMRPCESS) as 'COMPCESS'
		FROM PTMAIN M 
		INNER JOIN PTITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		INNER JOIN AC_MAST b on (I.Ac_id =b.Ac_id)
		WHERE  M.date between @from AND @to AND M.entry_ty  IN('PT','P1')AND b.Supp_type <> 'Unregistered' AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0) 
		and a.isService=0 --added by Prajakta B. on 04052018 
		
		union all
		
		--Purchase Return Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,case when M.Pinvno='' then M.inv_no else M.Pinvno end,case when M.Pinvdt='1900-01-01 00:00:00.000' then M.date else M.Pinvdt end,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' ,a.HSNCODE,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm,(I.COMPCESS+I.COMRPCESS) as 'COMPCESS' 
		FROM PRMAIN M 
		INNER JOIN PRITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		WHERE  M.date between @from AND @to AND M.entry_ty  IN('PR') AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0) 
		and a.isService=0 --added by Prajakta B. on 04052018 
		
		union all
		
		--Self Invoice Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,case when M.Pinvno='' then M.inv_no else M.Pinvno end,case when M.Pinvdt='1900-01-01 00:00:00.000' then M.date else M.Pinvdt end,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' ,a.HSNCODE,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm,(I.COMPCESS+I.COMRPCESS) as 'COMPCESS'
		FROM STMAIN M 
		INNER JOIN STITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		--Comment Rupesh G on 11-05-2018 for bug 31401
		--WHERE M.AGAINSTGS='GOODS' AND M.date between @from AND @to AND M.entry_ty  IN('UB') AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0) 
			WHERE  M.date between @from AND @to AND M.entry_ty  IN('UB') AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0) 
		and a.isService=0 --added by Prajakta B. on 04052018 
		
		union all
		
		--DEBIT NOTE SUPPLY OF GOODS Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,case when M.Pinvno='' then M.inv_no else M.Pinvno end,case when M.Pinvdt='1900-01-01 00:00:00.000' then M.date else M.Pinvdt end,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' ,a.HSNCODE,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm,(I.COMPCESS+I.COMRPCESS) as 'COMPCESS'
		FROM DNMAIN M 
		INNER JOIN DNITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		WHERE M.AGAINSTGS='PURCHASES' AND M.date between @from AND @to AND M.entry_ty  IN('GD') AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0) 
		and a.isService=0 --added by Prajakta B. on 04052018 
		
		union all
		
		--CREDIT NOTE SUPPLY OF GOODS Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,case when M.Pinvno='' then M.inv_no else M.Pinvno end,case when M.Pinvdt='1900-01-01 00:00:00.000' then M.date else M.Pinvdt end,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' ,a.HSNCODE,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm,(I.COMPCESS+I.COMRPCESS) as 'COMPCESS'
		FROM CNMAIN M 
		INNER JOIN CNITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		WHERE M.AGAINSTGS='PURCHASES' AND M.date between @from AND @to AND M.entry_ty  IN('GC') AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0) 
		and a.isService=0 --added by Prajakta B. on 04052018 

		ORDER BY 6
		
		
	END
	
	ELSE IF(@supply = '1')
	BEGIN 
-----------------added by Prajakta B. on 04052018 Start
	--Purchase & Import Purchase update column ECredit 
		IF Exists(Select top 1 Tran_cd from PTITEM WHERE  date between @from AND @to AND entry_ty  IN('PT','P1') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM PTITEM I
			inner JOIN PTMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('PT','P1')  
			and im.isService=1
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		
		--Purchase Return update column ECredit 
		IF Exists(Select top 1 Tran_cd from PRITEM WHERE  date between @from AND @to AND entry_ty  IN('PR') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM PRITEM I
			inner JOIN PRMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) --added by Prajakta B. on 04052018 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('PR')
			and im.isService=1 --added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
-----------------added by Prajakta B. on 04052018 End		
		--Service Purchase Bill
		
		IF Exists(Select top 1 Tran_cd from EPITEM WHERE  date between @from AND @to AND entry_ty  IN('E1') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM EPITEM I
			inner JOIN EPMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) ---added by Prajakta B. on 04052018 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('E1') 
			and im.isService=1 ---added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		
		--Self Invoice update column ECredit 
		IF Exists(Select top 1 Tran_cd from STITEM WHERE  date between @from AND @to AND entry_ty  IN('UB') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM STITEM I
			inner JOIN STMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) ---added by Prajakta B. on 04052018 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('UB') AND M.AGAINSTGS='SERVICES' 
			 and im.isService=1 ---added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		
		--DEBIT NOTE SUPPLY OF SERVICES update column ECredit 
		IF Exists(Select top 1 Tran_cd from DNITEM WHERE  date between @from AND @to AND entry_ty  IN('D6') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM DNITEM I
			inner JOIN DNMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code) ---added by Prajakta B. on 04052018 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('D6') AND M.AGAINSTGS='SERVICE PURCHASE BILL' 
			and im.isService=1  ---added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		
		--CREDIT NOTE SUPPLY OF GOODS update column ECredit 
		IF Exists(Select top 1 Tran_cd from CNITEM WHERE  date between @from AND @to AND entry_ty  IN('C6') AND 
			((cgst_amt+CGSRT_AMT)>0 OR (sgst_amt+SGSRT_AMT)>0 OR (igst_amt+IGSRT_AMT)>0 OR(COMPCESS+COMRPCESS)>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM CNITEM I
			inner JOIN CNMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code)  ---added by Prajakta B. on 04052018 
			WHERE  M.date between @from AND @to AND M.entry_ty in ('C6') AND M.AGAINSTGS='SERVICE PURCHASE BILL' 
			and im.isService=1  ---added by Prajakta B. on 04052018 
			AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0 OR(I.COMPCESS+I.COMRPCESS)>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		
		--ISD update column ECredit 
		
		IF Exists(Select top 1 Tran_cd from JVITEM WHERE  date between @from AND @to AND entry_ty  IN('J6','J8') AND (cgst_amt>0 OR sgst_amt>0 OR igst_amt>0) AND isnull(ITCSEC,'')='')
		Begin
			UPDATE I SET ECredit=1
			FROM JVITEM I
			inner JOIN JVMAIN M ON (M.ENTRY_TY= I.ENTRY_TY  AND M.TRAN_CD=I.TRAN_CD)
			inner join IT_MAST im on (im.It_code=i.It_code)
			WHERE  M.date between @from AND @to AND M.entry_ty  IN('J6','J8')
			and im.isService=1 ---added by Prajakta B. on 04052018 
			AND (I.cgst_amt>0 OR I.sgst_amt>0 OR I.igst_amt>0)
			AND Isnull(ITCSEC,'')='' and ECredit=0;
		End
		
		------------------------
---------------------added by Prajakta B. on 04052018 Start
		
		--Purchase & Import Purchase Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,M.pinvno,M.pinvdt,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' 
		--,a.HSNCODE --Commented by Prajakta B. on 04052018
		,a.servtcode as HSNCODE -- Modified by Prajakta B. on 04052018
		,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm as 'linerule',(I.COMPCESS+I.COMRPCESS) as 'COMPCESS'
		FROM PTMAIN M 
		INNER JOIN PTITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		INNER JOIN AC_MAST b on (I.Ac_id =b.Ac_id)
		WHERE  M.date between @from AND @to AND M.entry_ty  IN('PT','P1')AND b.Supp_type <> 'Unregistered' AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0) 
		and a.isService=1
		
		union all
		
		--Purchase Return Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,case when M.Pinvno='' then M.inv_no else M.Pinvno end,case when M.Pinvdt='1900-01-01 00:00:00.000' then M.date else M.Pinvdt end,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' 
		--,a.HSNCODE --Commented by Prajakta B. on 04052018
		,a.servtcode as HSNCODE -- Modified by Prajakta B. on 04052018
		,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm,(I.COMPCESS+I.COMRPCESS) as 'COMPCESS' 
		FROM PRMAIN M 
		INNER JOIN PRITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		WHERE  M.date between @from AND @to AND M.entry_ty  IN('PR') AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0) 
		and a.isService=1
		
		Union all
------------added by Prajakta B. on 04052018  End	
	
		 --Service Purchase Bill
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,M.pinvno,M.pinvdt,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' 
		--,a.HSNCODE --Commented by Prajakta B. on 04052018
		,a.servtcode  as HSNCODE-- Modified by Prajakta B. on 04052018
		,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm as 'linerule',(I.COMPCESS+I.COMRPCESS) as 'COMPCESS'
		FROM EPMAIN M 
		INNER JOIN EPITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		INNER JOIN AC_MAST b on (I.Ac_id =b.Ac_id)
		WHERE  M.date between @from AND @to AND M.entry_ty  IN('E1') AND b.Supp_type <> 'Unregistered' AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0)
		and a.isService=1 ---added by Prajakta B. on 04052018 

		union all
		
		--Self Invoice Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,case when M.Pinvno='' then M.inv_no else M.Pinvno end,case when M.Pinvdt='1900-01-01 00:00:00.000' then M.date else M.Pinvdt end,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' 
		--,a.HSNCODE --Commented by Prajakta B. on 04052018
		,a.servtcode as HSNCODE -- Modified by Prajakta B. on 04052018
		,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm as 'linerule',(I.COMPCESS+I.COMRPCESS) as 'COMPCESS'
		FROM STMAIN M 
		INNER JOIN STITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		WHERE M.AGAINSTGS='SERVICES' AND M.date between @from AND @to AND M.entry_ty  IN('UB') AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0)
		and a.isService=1 ---added by Prajakta B. on 04052018 
		
		union all
		
		--DEBIT NOTE SUPPLY OF SERVICES Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,case when M.Pinvno='' then M.inv_no else M.Pinvno end,case when M.Pinvdt='1900-01-01 00:00:00.000' then M.date else M.Pinvdt end,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' 
		--,a.HSNCODE --Commented by Prajakta B. on 04052018
		,a.servtcode as HSNCODE -- Modified by Prajakta B. on 04052018
		,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm as 'linerule',(I.COMPCESS+I.COMRPCESS) as 'COMPCESS'
		FROM DNMAIN M 
		INNER JOIN DNITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		WHERE --M.AGAINSTGS='SERVICE PURCHASE BILL' --Commented by Prajakta B. on 04052018
		M.AGAINSTGS in ('SERVICE PURCHASE BILL','PURCHASE') --modified by Prajakta B. on 04052018
		AND M.date between @from AND @to 
		--AND M.entry_ty  IN('D6')   --Commented by Prajakta B. on 04052018
		AND M.entry_ty  IN('D6','GD')  --modified by Prajakta B. on 04052018
		AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0)
		and a.isService=1 ---added by Prajakta B. on 04052018 
		
		union all
		
		--CREDIT NOTE SUPPLY OF SERVICES Data
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,case when M.Pinvno='' then M.inv_no else M.Pinvno end,case when M.Pinvdt='1900-01-01 00:00:00.000' then M.date else M.Pinvdt end,M.net_amt,(I.cgst_amt+I.CGSRT_AMT)as 'cgst_amt',(I.sgst_amt+I.SGSRT_AMT) as 'sgst_amt',(I.igst_amt+I.IGSRT_AMT) as 'igst_amt',I.ECredit as'Credit_Availability' 
		--,a.HSNCODE --Commented by Prajakta B. on 04052018
		,a.servtcode as HSNCODE  -- Modified by Prajakta B. on 04052018
		,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm as 'linerule',(I.COMPCESS+I.COMRPCESS) as 'COMPCESS'
		FROM CNMAIN M 
		INNER JOIN CNITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code)
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		WHERE --M.AGAINSTGS='SERVICE PURCHASE BILL' --Commented by Prajakta B. on 04052018
		M.AGAINSTGS in ('SERVICE PURCHASE BILL','PURCHASE') --modified by Prajakta B. on 04052018
		AND M.date between @from AND @to 
		--AND M.entry_ty  IN('D6')   --Commented by Prajakta B. on 04052018
		AND M.entry_ty  IN('D6','GC')  --modified by Prajakta B. on 04052018
		AND ((I.cgst_amt+I.CGSRT_AMT)>0 OR (I.sgst_amt+I.SGSRT_AMT)>0 OR (I.igst_amt+I.IGSRT_AMT)>0  OR(I.COMPCESS+I.COMRPCESS)>0)
		and a.isService=1 ---added by Prajakta B. on 04052018 
		
		union all
		--ISD DATA
		SELECT I.itserial,M.entry_ty,M.tran_cd,M.inv_no,I.item,M.date,M.pinvno,M.pinvdt,M.net_amt,I.cgst_amt,I.sgst_amt,I.igst_amt,I.ECredit as'Credit_Availability'
		--,a.HSNCODE --Commented by Prajakta B. on 04052018
		,a.servtcode as HSNCODE  -- Modified by Prajakta B. on 04052018
		,M.party_nm,I.ITCSEC as'IN_ITC_SEC',l.code_nm as 'linerule',I.COMPCESS
		FROM JVMAIN M 
		INNER JOIN JVITEM I ON (M.ENTRY_TY=I.ENTRY_TY AND M.TRAN_CD=I.TRAN_CD) 
		INNER JOIN IT_MAST a on (I.It_code =a.it_code) 
		INNER JOIN lcode l on(L.ENTRY_TY=M.ENTRY_TY)
		WHERE  M.date between @from AND @to AND M.entry_ty  IN('J6','J8') AND (I.cgst_amt>0 OR I.sgst_amt>0 OR I.igst_amt>0)
		and a.isService=1 ---added by Prajakta B. on 04052018 
		
		ORDER BY 6
	END

END

