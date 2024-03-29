If Exists(Select [name] From SysObjects Where xType='P' and [name]='USP_REP_GLEDGER1')
Begin
	Drop Procedure USP_REP_GLEDGER1
End
/****** Object:  StoredProcedure [dbo].[USP_REP_GLEDGER1]    Script Date: 08/30/2018 12:02:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


Create PROCEDURE  [dbo].[USP_REP_GLEDGER1]
 @TMPAC NVARCHAR(60),@TMPIT NVARCHAR(60),@SPLCOND NVARCHAR(500),  
 @SDATE SMALLDATETIME,@EDATE SMALLDATETIME,  
 @SNAME NVARCHAR(60),@ENAME NVARCHAR(60),  
 @SITEM NVARCHAR(60),@EITEM NVARCHAR(60),  
 @SAMT NUMERIC,@EAMT NUMERIC,  
 @SDEPT NVARCHAR(60),@EDEPT NVARCHAR(60),  
 @SCAT NVARCHAR(60),@ECAT NVARCHAR(60),  
 @SINVSR NVARCHAR(60),@EINVSR NVARCHAR(60),  
 @SWARE NVARCHAR(60),@EWARE NVARCHAR(60),  
 @FINYR NVARCHAR(20), @EXTPAR NVARCHAR(60)  
 AS
DECLARE @FCON AS NVARCHAR(4000),@SQLCOMMAND AS NVARCHAR(4000)  
 DECLARE @OPENTRIES AS VARCHAR(50),@OPENTRY_TY AS VARCHAR(50)  
 DECLARE @TBLNM AS VARCHAR(50),@TBLNAME1 AS VARCHAR(50),@TBLNAME2 AS VARCHAR(50),@TBLNAME3 AS VARCHAR(50)  
   
 SET @OPENTRY_TY = '''OB'''  
 SET @TBLNM = (SELECT SUBSTRING(RTRIM(LTRIM(STR(RAND( (DATEPART(MM, GETDATE()) * 100000 )  
     + (DATEPART(SS, GETDATE()) * 1000 )  
     + DATEPART(MS, GETDATE())) , 20,15))),3,20) AS NO)  
 SET @TBLNAME1 = '##TMP1'+@TBLNM  
 SET @TBLNAME2 = '##TMP2'+@TBLNM  
 SET @TBLNAME3 = '##TMP3'+@TBLNM  
  
 DECLARE OPENINGENTRY_CURSOR CURSOR FOR  
  SELECT ENTRY_TY FROM LCODE  
  WHERE BCODE_NM = 'OB'  
 OPEN OPENINGENTRY_CURSOR  
 FETCH NEXT FROM OPENINGENTRY_CURSOR INTO @OPENTRIES  
 WHILE @@FETCH_STATUS = 0  
 BEGIN  
    SET @OPENTRY_TY = @OPENTRY_TY +','''+@OPENTRIES+''''  
    FETCH NEXT FROM OPENINGENTRY_CURSOR INTO @OPENTRIES  
 END  
 CLOSE OPENINGENTRY_CURSOR  
 DEALLOCATE OPENINGENTRY_CURSOR  
  
 EXECUTE USP_REP_FILTCON   
  @VTMPAC=@TMPAC,@VTMPIT=NULL,@VSPLCOND=@SPLCOND,  
  @VSDATE=NULL,@VEDATE=@EDATE,  
  @VSAC =@SNAME,@VEAC =@ENAME,  
  @VSIT=NULL,@VEIT=NULL,  
  @VSAMT=@SAMT,@VEAMT=@EAMT,  
  @VSDEPT=@SDEPT,@VEDEPT=@EDEPT,  
  @VSCATE =@SCAT,@VECATE =@ECAT,  
  @VSWARE =NULL,@VEWARE  =NULL,  
  @VSINV_SR =@SINVSR,@VEINV_SR =@EINVSR,  
  @VMAINFILE='MVW',@VITFILE=NULL,@VACFILE='AVW',  
  @VDTFLD = 'DATE',@VLYN=NULL,@VEXPARA=@EXTPAR,  
  @VFCON =@FCON OUTPUT  
     print @fcon 
 SET @SQLCOMMAND = ''  
 SET @SQLCOMMAND = 'SELECT AVW.TRAN_CD,AVW.ENTRY_TY,AVW.DATE,AVW.AMOUNT,AVW.AMT_TY,  
  MVW.INV_NO,MVW.L_YN,MVW.CHEQ_NO,MNARR=CAST(MVW.NARR AS NVARCHAR(4000)),ANARR=CAST(AVW.NARR AS NVARCHAR(4000)),  
  AC_MAST.AC_ID,AC_MAST.AC_NAME,AC_MAST.ADD1, AC_MAST.ADD2, AC_MAST.ADD3, AC_MAST.CITY,OAC_NAME=SUBSTRING(AVW.OAC_NAME,1,4000),MVW.PINVNO as U_PINVNO,MVW.BANK_NM,MVW.U_CHQDT,MVW.U_BRANCH,MVW.DRAWN_ON,  
  AC_MAST.bankbr,ac_mast.bankno
  INTO '+@TBLNAME1+' FROM LAC_VW AVW (NOLOCK)  
  INNER JOIN AC_MAST (NOLOCK) ON AVW.AC_ID = AC_MAST.AC_ID  
  INNER JOIN LMAIN_VW MVW (NOLOCK)   
   ON AVW.TRAN_CD = MVW.TRAN_CD AND AVW.ENTRY_TY = MVW.ENTRY_TY'+RTRIM(@FCON) 

   print @SQLCOMMAND
 EXECUTE SP_EXECUTESQL @SQLCOMMAND
  
  
 SET @SQLCOMMAND = ''  
 SET @SQLCOMMAND = 'SELECT ENTRY_TY,TRAN_CD,COUNT(ENTRY_TY) AS TOTREC   
  INTO '+@TBLNAME2+' FROM LAC_VW AVW (NOLOCK)  
  GROUP BY ENTRY_TY,TRAN_CD'  
     print @SQLCOMMAND
 EXECUTE SP_EXECUTESQL @SQLCOMMAND  
  
 SET @SQLCOMMAND = ''  
 SET @SQLCOMMAND = 'DELETE FROM '+@TBLNAME1+' WHERE   
  DATE < (SELECT TOP 1 DATE FROM '+@TBLNAME1+ ' WHERE ENTRY_TY IN ('+@OPENTRY_TY+') AND L_YN = '''+@FINYR+''' )  
  AND AC_NAME IN (SELECT AC_NAME FROM '+@TBLNAME1+ ' WHERE ENTRY_TY IN ('+@OPENTRY_TY+') AND L_YN = '''+@FINYR+''' GROUP BY AC_NAME) '   
     print @SQLCOMMAND
 EXECUTE SP_EXECUTESQL @SQLCOMMAND  
 
 SET @SQLCOMMAND = ''  
 SET @SQLCOMMAND = 'SELECT TRAN_CD=0,ENTRY_TY='' '',  
  DATE=CONVERT(SMALLDATETIME,'''+CONVERT(VARCHAR(50),@SDATE)+'''),  
  AMOUNT=ISNULL(SUM(CASE WHEN TVW.AMT_TY = ''DR'' THEN TVW.AMOUNT ELSE -TVW.AMOUNT END),0),  
  TVW.AC_ID,TVW.AC_NAME,TVW.ADD1, TVW.ADD2, TVW.ADD3, TVW.CITY,TVW.OAC_NAME,TVW.U_PINVNO,BANK_NM='' '',
  AMT_TY=''A'',INV_NO='' '',CHEQ_NO='' '',MNARR='' '',ANARR='' '',LNARR='' '',U_CHQDT,U_BRANCH,DRAWN_ON='' '',  
  AC_NAME1=''BALANCE B/F'',AMOUNT1 = 0,AMT_TY1 = '' '',TOTREC=1  ,  bankbr,bankno
  INTO '+@TBLNAME3+' FROM '+@TBLNAME1+' TVW  
  WHERE (TVW.DATE < '''+CONVERT(VARCHAR(50),@SDATE)+''' OR TVW.ENTRY_TY IN ('+@OPENTRY_TY+'))   
  GROUP BY TVW.AC_ID,TVW.AC_NAME,TVW.ADD1, TVW.ADD2, TVW.ADD3, TVW.CITY,TVW.OAC_NAME,TVW.U_PINVNO,U_CHQDT,U_BRANCH,bankbr,bankno
 UNION ALL  
  SELECT TVW.TRAN_CD,TVW.ENTRY_TY,TVW.DATE,  
  AMOUNT=(CASE WHEN TVW.AMT_TY=''DR'' THEN TVW.AMOUNT ELSE -TVW.AMOUNT END),  
  TVW.AC_ID,TVW.AC_NAME,TVW.ADD1, TVW.ADD2, TVW.ADD3, TVW.CITY,TVW.OAC_NAME,TVW.U_PINVNO,TVW.BANK_NM,
  TVW.AMT_TY,TVW.INV_NO,TVW.CHEQ_NO,TVW.MNARR,TVW.ANARR,LNARR=CAST(LVW.NARR AS NVARCHAR(4000)),TVW.U_CHQDT,TVW.U_BRANCH,TVW.DRAWN_ON,  
  AC_NAME1=LVW.AC_NAME,AMOUNT1 = LVW.AMOUNT,AMT_TY1 = LVW.AMT_TY,T1VW.TOTREC,bankbr,bankno
  FROM '+@TBLNAME1+' TVW  
  LEFT JOIN LAC_VW LVW (NOLOCK)   
   ON TVW.TRAN_CD = LVW.TRAN_CD AND TVW.ENTRY_TY = LVW.ENTRY_TY AND TVW.AC_ID != LVW.AC_ID  
  LEFT JOIN '+@TBLNAME2+' T1VW (NOLOCK)   
   ON TVW.TRAN_CD = T1VW.TRAN_CD AND TVW.ENTRY_TY = T1VW.ENTRY_TY  
  WHERE (TVW.DATE BETWEEN '''+CONVERT(VARCHAR(50),@SDATE)+''' AND '''+CONVERT(VARCHAR(50),@EDATE)+''' AND   
	  TVW.ENTRY_TY NOT IN ('+@OPENTRY_TY+'))'
   print @SQLCOMMAND
 EXECUTE SP_EXECUTESQL @SQLCOMMAND 
--SET @SQLCOMMAND = ''  
-- SET @SQLCOMMAND = 'SELECT TVW.*,ac_mast.AC_NAME,AC_MAST.MAILNAME,AC_MAST.[GROUP] AS GRP,AC_MAST.ADD1,AC_MAST.ADD2,AC_MAST.ADD3,AC_MAST.CITY,AC_MAST.ZIP,AC_MAST.STATE,AC_MAST.I_TAX FROM '+@TBLNAME3+' TVW inner join ac_mast  on ac_mast.ac_id=tvw.ac_id  
--  WHERE TVW.AMOUNT <> 0 AND TVW.ENTRY_TY=''BR'' AND AMT_TY1 <> ''DR''
--  ORDER BY TVW.AC_NAME,TVW.DATE,TVW.AMT_TY,TVW.TRAN_CD'  
  
 SET @SQLCOMMAND = ''  
 SET @SQLCOMMAND = 'SELECT TVW.* FROM '+@TBLNAME3+' TVW  
  WHERE TVW.AMOUNT <> 0 AND TVW.ENTRY_TY=''BR'' AND AMT_TY1 <> ''DR''
  ORDER BY TVW.AC_NAME,TVW.DATE,TVW.AMT_TY,TVW.TRAN_CD'  
     print @SQLCOMMAND
 EXECUTE SP_EXECUTESQL @SQLCOMMAND  
  
 SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME1  
 EXECUTE SP_EXECUTESQL @SQLCOMMAND  
 SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME2  
 EXECUTE SP_EXECUTESQL @SQLCOMMAND  
 SET @SQLCOMMAND = 'DROP TABLE '+@TBLNAME3  
 EXECUTE SP_EXECUTESQL @SQLCOMMAND  
