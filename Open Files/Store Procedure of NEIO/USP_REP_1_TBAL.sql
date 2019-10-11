DROP PROCEDURE [USP_REP_1_TBAL]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     PROCEDURE [USP_REP_1_TBAL] 
@EDATE AS SMALLDATETIME,@LVL  AS INTEGER =3
AS

DECLARE @AC_NAME AS VARCHAR(100),@AC_ID AS INT
DECLARE @GACNM1 AS VARCHAR(100),@GACID1  AS INT,@GACNM2 AS VARCHAR(100),@GACID2  AS INT,@GACNM3 AS VARCHAR(100),@GACID3  AS INT,@GACNM4 AS VARCHAR(100),@GACID4  AS INT,@GACNM5 AS VARCHAR(100),@GACID5  AS INT
DECLARE @GACNM6 AS VARCHAR(100),@GACID6  AS INT,@GACNM7 AS VARCHAR(100),@GACID7  AS INT,@GACNM8 AS VARCHAR(100),@GACID8  AS INT,@GACNM9 AS VARCHAR(100),@GACID9  AS INT,@GACNM10 AS VARCHAR(100),@GACID10  AS INT
DECLARE @GACNM11 AS VARCHAR(100),@GACID11  AS INT,@GACNM12 AS VARCHAR(100),@GACID12  AS INT,@GACNM13 AS VARCHAR(100),@GACID13  AS INT,@GACNM14 AS VARCHAR(100),@GACID14  AS INT,@GACNM15 AS VARCHAR(100),@GACID15  AS INT
DECLARE @GACNM16 AS VARCHAR(100),@GACID16  AS INT,@GACNM17 AS VARCHAR(100),@GACID17  AS INT,@GACNM18 AS VARCHAR(100),@GACID18  AS INT,@GACNM19 AS VARCHAR(100),@GACID19  AS INT,@GACNM20 AS VARCHAR(100),@GACID20  AS INT
DECLARE @GACNM21 AS VARCHAR(100),@GACID21  AS INT,@GACNM22 AS VARCHAR(100),@GACID22  AS INT,@GACNM23 AS VARCHAR(100),@GACID23  AS INT,@GACNM24 AS VARCHAR(100),@GACID24  AS INT,@GACNM25 AS VARCHAR(100),@GACID25  AS INT
DECLARE @GACNM26 AS VARCHAR(100),@GACID26  AS INT,@GACNM27 AS VARCHAR(100),@GACID27  AS INT,@GACNM28 AS VARCHAR(100),@GACID28  AS INT,@GACNM29 AS VARCHAR(100),@GACID29  AS INT,@GACNM30 AS VARCHAR(100),@GACID30  AS INT

SELECT CDESC=A.MAILNAME,CID=A.AC_ID,PDESC=A.MAILNAME,PID=A.AC_ID,AMOUNTDR=AMOUNT,AMOUNTCR=AMOUNT,ISGRP='Y' INTO #TBAL FROM AC_MAST A INNER JOIN STACDET M ON (A.AC_ID=M.AC_ID) WHERE 1=2

SELECT AC_NAME,AC_ID=999999999
,GACNM1=[GROUP],GACID1=999999999 ,GACNM2=[GROUP],GACID2=999999999,GACNM3=[GROUP],GACID3=999999999,GACNM4=[GROUP],GACID4=999999999,GACNM5=[GROUP],GACID5=999999999
,GACNM6=[GROUP],GACID6=999999999 ,GACNM7=[GROUP],GACID7=999999999,GACNM8=[GROUP],GACID8=999999999,GACNM9=[GROUP],GACID9=999999999,GACNM10=[GROUP],GACID10=999999999
,GACNM11=[GROUP],GACID11=999999999 ,GACNM12=[GROUP],GACID12=999999999,GACNM13=[GROUP],GACID13=999999999,GACNM14=[GROUP],GACID14=999999999,GACNM15=[GROUP],GACID15=999999999
,GACNM16=[GROUP],GACID16=999999999 ,GACNM17=[GROUP],GACID17=999999999,GACNM18=[GROUP],GACID18=999999999,GACNM19=[GROUP],GACID19=999999999,GACNM20=[GROUP],GACID20=999999999
,GACNM21=[GROUP],GACID21=999999999 ,GACNM22=[GROUP],GACID22=999999999,GACNM23=[GROUP],GACID23=999999999,GACNM24=[GROUP],GACID24=999999999,GACNM25=[GROUP],GACID25=999999999
,GACNM26=[GROUP],GACID26=999999999 ,GACNM27=[GROUP],GACID27=999999999,GACNM28=[GROUP],GACID28=999999999,GACNM29=[GROUP],GACID29=999999999,GACNM30=[GROUP],GACID30=999999999
INTO #TBAL1
 FROM AC_MAST  WHERE 1=2



DECLARE @ACLIST1 CURSOR
EXEC USP_REP_1_ACLIST @ACLIST = @ACLIST1 OUTPUT

FETCH NEXT FROM @ACLIST1 INTO 
@AC_NAME,@AC_ID
,@GACNM1,@GACID1 ,@GACNM2,@GACID2,@GACNM3,@GACID3,@GACNM4,@GACID4,@GACNM5,@GACID5
,@GACNM6,@GACID6 ,@GACNM7,@GACID7,@GACNM8,@GACID8,@GACNM9,@GACID9,@GACNM10,@GACID10
,@GACNM11,@GACID11,@GACNM12,@GACID12,@GACNM13,@GACID13,@GACNM14,@GACID14,@GACNM15,@GACID15
,@GACNM16,@GACID16,@GACNM17,@GACID17,@GACNM18,@GACID18,@GACNM19,@GACID19,@GACNM20,@GACID20
,@GACNM21,@GACID21 ,@GACNM22,@GACID22,@GACNM23,@GACID23,@GACNM24,@GACID24,@GACNM25,@GACID25
,@GACNM26,@GACID26 ,@GACNM27,@GACID27,@GACNM28,@GACID28,@GACNM29,@GACID29,@GACNM30,@GACID30

WHILE (@@FETCH_STATUS = 0)
BEGIN
	INSERT INTO #TBAL1 (
	AC_NAME,AC_ID
	,GACNM1,GACID1 ,GACNM2,GACID2,GACNM3,GACID3,GACNM4,GACID4,GACNM5,GACID5
	,GACNM6,GACID6 ,GACNM7,GACID7,GACNM8,GACID8,GACNM9,GACID9,GACNM10,GACID10	,GACNM11,GACID11,GACNM12,GACID12,GACNM13,GACID13,GACNM14,GACID14,GACNM15,GACID15
	,GACNM16,GACID16 ,GACNM17,GACID17,GACNM18,GACID18,GACNM19,GACID19,GACNM20,GACID20
	,GACNM21,GACID21 ,GACNM22,GACID22,GACNM23,GACID23,GACNM24,GACID24,GACNM25,GACID25
	,GACNM26,GACID26 ,GACNM27,GACID27,GACNM28,GACID28,GACNM29,GACID29,GACNM30,GACID30
	) VALUES
	 (@AC_NAME,@AC_ID
	,@GACNM1,@GACID1 ,@GACNM2,@GACID2,@GACNM3,@GACID3,@GACNM4,@GACID4,@GACNM5,@GACID5
	,@GACNM6,@GACID6 ,@GACNM7,@GACID7,@GACNM8,@GACID8,@GACNM9,@GACID9,@GACNM10,@GACID10
	,@GACNM11,@GACID11,@GACNM12,@GACID12,@GACNM13,@GACID13,@GACNM14,@GACID14,@GACNM15,@GACID15
	,@GACNM16,@GACID16,@GACNM17,@GACID17,@GACNM18,@GACID18,@GACNM19,@GACID19,@GACNM20,@GACID20
	,@GACNM21,@GACID21 ,@GACNM22,@GACID22,@GACNM23,@GACID23,@GACNM24,@GACID24,@GACNM25,@GACID25
	,@GACNM26,@GACID26 ,@GACNM27,@GACID27,@GACNM28,@GACID28,@GACNM29,@GACID29,@GACNM30,@GACID30
	)
	FETCH NEXT FROM @ACLIST1 INTO 
	@AC_NAME,@AC_ID
	,@GACNM1,@GACID1 ,@GACNM2,@GACID2,@GACNM3,@GACID3,@GACNM4,@GACID4,@GACNM5,@GACID5
	,@GACNM6,@GACID6 ,@GACNM7,@GACID7,@GACNM8,@GACID8,@GACNM9,@GACID9,@GACNM10,@GACID10
	,@GACNM11,@GACID11,@GACNM12,@GACID12,@GACNM13,@GACID13,@GACNM14,@GACID14,@GACNM15,@GACID15
	,@GACNM16,@GACID16,@GACNM17,@GACID17,@GACNM18,@GACID18,@GACNM19,@GACID19,@GACNM20,@GACID20
	,@GACNM21,@GACID21 ,@GACNM22,@GACID22,@GACNM23,@GACID23,@GACNM24,@GACID24,@GACNM25,@GACID25
	,@GACNM26,@GACID26 ,@GACNM27,@GACID27,@GACNM28,@GACID28,@GACNM29,@GACID29,@GACNM30,@GACID30
END

CLOSE @ACLIST1
DEALLOCATE @ACLIST1

--SELECT * FROM #TBAL1
SELECT A.AC_ID,A.AC_NAME
,AMOUNTDr=CASE WHEN (SUM(CASE WHEN A.AMT_TY='DR' THEN A.AMOUNT ELSE -A.AMOUNT END)>0) THEN SUM(CASE WHEN A.AMT_TY='DR' THEN A.AMOUNT ELSE -A.AMOUNT END) ELSE 0 END
,AMOUNTCr=ABS(CASE WHEN (SUM(CASE WHEN A.AMT_TY='DR' THEN A.AMOUNT ELSE -A.AMOUNT END)<0) THEN SUM(CASE WHEN A.AMT_TY='DR' THEN A.AMOUNT ELSE -A.AMOUNT END) ELSE 0 END)
INTO #TBAL2
FROM LAC_VW A 
INNER JOIN AC_MAST AC ON (A.AC_ID=AC.AC_ID)
WHERE AC.TYPE='B' AND DATE<=@EDATE
GROUP BY A.AC_NAME,A.AC_ID

--SELECT A.AC_NAME,A.AC_ID
--,B.AMOUNTDr
--,B.AMOUNTCr
--,A.GACNM1,A.GACID1 ,A.GACNM2,A.GACID2,A.GACNM3,A.GACID3,A.GACNM4,A.GACID4,A.GACNM5,A.GACID5
--,A.GACNM6,A.GACID6 ,A.GACNM7,A.GACID7,A.GACNM8,A.GACID8,A.GACNM9,A.GACID9,A.GACNM10,A.GACID10--,A.GACNM11,A.GACID11,A.GACNM12,A.GACID12,A.GACNM13,A.GACID13,A.GACNM14,A.GACID14,A.GACNM15,A.GACID15
--,A.GACNM16,A.GACID16 ,A.GACNM17,A.GACID17,A.GACNM18,A.GACID18,A.GACNM19,A.GACID19,A.GACNM20,A.GACID20
--,A.GACNM21,A.GACID21 ,A.GACNM22,A.GACID22,A.GACNM23,A.GACID23,A.GACNM24,A.GACID24,A.GACNM25,A.GACID25
--,A.GACNM26,A.GACID26 ,A.GACNM27,A.GACID27,A.GACNM28,A.GACID28,A.GACNM29,A.GACID29,A.GACNM30,A.GACID30
--FROM #TBAL1 A INNER JOIN #TBAL2 B ON  (A.AC_ID=B.AC_ID)

DECLARE @AMTDR NUMERIC(16,2),@AMTCR NUMERIC(16,2)
DECLARE  C1TBAL1 CURSOR FOR 
SELECT AC_GROUP_NAME,AC_GROUP_ID,[GROUP],GAC_ID FROM AC_GROUP_MAST ORDER BY AC_GROUP_NAME
OPEN C1TBAL1
FETCH NEXT FROM C1TBAL1 INTO @GACNM1,@GACID1,@GACNM2,@GACID2
WHILE @@FETCH_STATUS=0
BEGIN
	SET @AMTCR=0
	SET @AMTDR=0
	SELECT @AMTDR=CASE WHEN(SUM(B.AMOUNTDR-B.AMOUNTCR)>0) THEN SUM(B.AMOUNTDR-B.AMOUNTCR) ELSE 0 END,@AMTCR=ABS(CASE WHEN(SUM(B.AMOUNTDR-B.AMOUNTCR)<0) THEN SUM(B.AMOUNTDR-B.AMOUNTCR) ELSE 0 END)  
	FROM #TBAL1 A INNER JOIN #TBAL2 B ON (A.AC_ID=B.AC_ID) WHERE @GACID1 IN(GACID1,GACID2,GACID3,GACID3,GACID4,GACID5,GACID6,GACID7,GACID8,GACID9,GACID10,GACID11,GACID12,GACID13,GACID14,GACID15,GACID16,GACID17,GACID18,GACID19,GACID20,GACID21,GACID22,GACID23,GACID24,GACID25,GACID26,GACID27,GACID28,GACID29,GACID30)
	
	INSERT INTO #TBAL(CDESC,CID,PDESC,PID,AMOUNTDR,AMOUNTCR,ISGRP)
	VALUES (@GACNM1,@GACID1,@GACNM2,@GACID2,@AMTDR,@AMTCR,'Y')
	FETCH NEXT FROM C1TBAL1 INTO @GACNM1,@GACID1,@GACNM2,@GACID2
END
CLOSE C1TBAL1
DEALLOCATE C1TBAL1

INSERT INTO #TBAL(CDESC,CID,PDESC,PID,AMOUNTDR,AMOUNTCR,ISGRP) SELECT A.AC_NAME,A.AC_ID,AC.[GROUP],AC.AC_GROUP_ID,AMOUNTDr,AMOUNTCr,ISGRP='N' FROM #TBAL2 A INNER JOIN AC_MAST AC  ON (A.AC_ID=AC.AC_ID)

IF @LVL=1 
BEGIN
	SELECT * FROM #TBAL  WHERE CID=PID
END
ELSE
BEGIN
	SELECT * FROM #TBAL  
END



--SELECT SUM(B.AMOUNTDr)  FROM #TBAL1 A INNER JOIN #TBAL2 B ON  (A.AC_ID=B.AC_ID) WHERE 12 IN(GACID1,GACID2,GACID3,GACID3,GACID4,GACID5,GACID6)

--SELECT A.AC_NAME,A.AC_ID
--,B.AMOUNTDr
--,B.AMOUNTCr
--,A.GACNM1,A.GACID1 ,A.GACNM2,A.GACID2,A.GACNM3,A.GACID3,A.GACNM4,A.GACID4,A.GACNM5,A.GACID5
--,A.GACNM6,A.GACID6 ,A.GACNM7,A.GACID7,A.GACNM8,A.GACID8,A.GACNM9,A.GACID9,A.GACNM10,A.GACID10--,A.GACNM11,A.GACID11,A.GACNM12,A.GACID12,A.GACNM13,A.GACID13,A.GACNM14,A.GACID14,A.GACNM15,A.GACID15
--,A.GACNM16,A.GACID16 ,A.GACNM17,A.GACID17,A.GACNM18,A.GACID18,A.GACNM19,A.GACID19,A.GACNM20,A.GACID20
--,A.GACNM21,A.GACID21 ,A.GACNM22,A.GACID22,A.GACNM23,A.GACID23,A.GACNM24,A.GACID24,A.GACNM25,A.GACID25
--,A.GACNM26,A.GACID26 ,A.GACNM27,A.GACID27,A.GACNM28,A.GACID28,A.GACNM29,A.GACID29,A.GACNM30,A.GACID30
--FROM #TBAL1 A INNER JOIN #TBAL2 B ON  (A.AC_ID=B.AC_ID) WHERE 12 IN(GACID1,GACID2,GACID3,GACID3,GACID4,GACID5,GACID6)


--SELECT CDESC=A.MAILNAME,CIDAC_ID=A.AC_ID,PDESC=A.MAILNAME,PID=A.AC_ID,AMOUNTDR=AMOUNT,AMOUNTCR=AMOUNT,ISGRP='Y' INTO #TBAL FROM AC_MAST A INNER JOIN STACDET M ON (A.AC_ID=M.AC_ID) WHERE 1=2

--@AMTCR=ABS(CASE WHEN(SUM(AMONTDR-AMOUNTDR)<0,SUM(AMONTDR-AMOUNTDR),0))


--SELECT * FROM #TBAL2
  
/****** Object:  StoredProcedure [dbo].[USP_REP_SERV_ST3]    Script Date: 06/13/2007 15:49:38 ******/
GO
