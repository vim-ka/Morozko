﻿CREATE PROCEDURE dbo.ApplicationForMarsh
@MARSH INT,
@ND DATE,
@PRODUCERS VARCHAR(5000) OUT,
@All BIT=1
AS
BEGIN
--SET STATISTICS TIME ON
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @DN1 BIGINT
DECLARE @DN2 BIGINT
SET @DN1=dbo.InDatNom(0,@nd);
SET @DN2=@DN1+9999
SET @PRODUCERS=''

IF OBJECT_ID('TEMPDB..#TEKIDS') IS NOT NULL DROP TABLE #TEKIDS
CREATE TABLE #TEKIDS (ID INT, PRODUCERID INT, 
                      PRODUCERNAME VARCHAR(50))

IF OBJECT_ID('TEMPDB..#TMPNC') IS NOT NULL DROP TABLE #TMPNC
CREATE TABLE #TMPNC (DATNOM BIGINT, VES DECIMAL(20,2), B_ID INT, MARSH INT, BrNo int, stfnom varchar(17))

/*IF OBJECT_ID('TEMPDB..#TMPDEF') IS NOT NULL DROP TABLE #TMPDEF
CREATE TABLE #TMPDEF (PIN INT,OBL_ID INT, RN_ID int)
SET STATISTICS TIME ON

INSERT INTO #TMPDEF
SELECT PIN, OBL_ID, RN_ID
FROM DEF 
WHERE PIN IN (SELECT DISTINCT B_ID FROM NC WHERE DATNOM BETWEEN @DN1 AND @DN2)
			or pin=32717

CREATE NONCLUSTERED INDEX idx_obl_id ON #TMPDEF(OBL_ID)
CREATE NONCLUSTERED INDEX idx_pin ON #TMPDEF(PIN)
*/

INSERT INTO #TMPNC 
SELECT NC.DATNOM,
       SUM([DBO].[CALCWEIGHTPOS](NV.NVID)),
       NC.B_ID,
       Marsh.MARSH,
       0 as BrNo,--sb.BrNo ,
       NC.stfnom
FROM NC 
INNER JOIN nv WITH (INDEX(nv_datnom_idx)) ON NC.DatNom=NV.DatNom
INNER JOIN nomen ON NV.Hitag = Nomen.hitag
INNER JOIN SertifNomenVetCat sf ON Nomen.hitag = sf.hitag
INNER JOIN DEF ON DEF.pin=nc.b_ID
INNER JOIN Marsh ON NC.mhID = Marsh.mhid
--left join SertifBranch sb on #TMPDEF.RN_ID=sb.RN_ID
--INNER JOIN DefContract dc ON NC.DCK = dc.DCK
WHERE NC.DATNOM >= @DN1 
      AND NC.DATNOM <= @DN2 
      AND Marsh.MARSH=@MARSH
      and sf.IdCat<>-1
      AND NOT NC.OURID IN (10,18,19) 
      AND (PATINDEX('%вет%',LOWER(NC.REMARK))<>0
      OR PATINDEX('%в\с%',LOWER(NC.REMARK))<>0
      OR PATINDEX('%в/с%',LOWER(NC.REMARK))<>0
      OR PATINDEX('%вет%',LOWER(NC.REMARKOP))<>0
      OR PATINDEX('%в\с%',LOWER(NC.REMARKOP))<>0
      OR PATINDEX('%в/с%',LOWER(NC.REMARKOP))<>0
      OR EXISTS(SELECT 1 FROM DEFCONTRACT DC INNER JOIN AGENTLIST AL ON DC.AG_ID=AL.AG_ID WHERE DC.PIN=NC.B_ID AND AL.DEPID=3)
      OR isnull(DEF.Obl_ID,-1)=1)
      --AND dc.ContrTip=2

GROUP BY NC.DatNom,NC.B_ID, Marsh.MARSH,NC.stfnom--sb.BrNo 
--SET STATISTICS TIME OFF

DELETE FROM #TMPNC WHERE VES=0

CREATE NONCLUSTERED INDEX TMPNC_IND ON #TMPNC(DATNOM)

INSERT INTO #TEKIDS(ID)
SELECT DISTINCT TEKID
FROM NV V
INNER JOIN NOMEN N ON N.HITAG=V.HITAG
INNER JOIN SertifNomenVetCat sf ON N.hitag = sf.hitag
INNER JOIN #TMPNC ON #TMPNC.DATNOM=V.DATNOM
WHERE sf.IdCat<>-1

CREATE NONCLUSTERED INDEX TEKIDS_IND ON #TEKIDS(ID)
			                       
UPDATE #TEKIDS SET PRODUCERID=P.PRODUCERID,
                 	 PRODUCERNAME=ISNULL(P.PRODUCERNAME,V.COUNTRY)
FROM #TEKIDS T
INNER JOIN (SELECT V.ID,V.PRODUCERID,V.COUNTRY FROM VISUAL V INNER JOIN #TEKIDS X ON V.ID = X.ID 
 						UNION ALL 
            SELECT V.ID,V.PRODUCERID,V.COUNTRY FROM TDVI V INNER JOIN #TEKIDS X ON V.ID = X.ID) V ON V.ID=T.ID
LEFT JOIN PRODUCER P ON P.PRODUCERID=V.PRODUCERID
  
UPDATE #TEKIDS SET PRODUCERID=P.PRODUCERID,
									 PRODUCERNAME=P.PRODUCERNAME
FROM #TEKIDS T
INNER JOIN PRODUCER P ON PATINDEX(T.PRODUCERNAME+'%',P.PRODUCERNAME)<>0
WHERE T.PRODUCERID IS NULL

DELETE FROM #TEKIDS WHERE PRODUCERID IS NULL

SET @PRODUCERS=
  STUFF((
  SELECT N','+PRODUCERNAME
  FROM 
    (SELECT DISTINCT 
            PRODUCERID, PRODUCERNAME 
     FROM #TEKIDS) SRC
  FOR XML PATH(''), TYPE).value('.','varchar(max)'),1,1,'')
  
DROP TABLE #TEKIDS

SELECT t.B_ID,
       A.GPNAME AS FAM,
       A.GPADDR AS ADDRPOST,
       A.BRINN,
       STUFF((SELECT ', '+CASE WHEN ISNULL(N1.STFNOM,'')='' THEN CAST(DBO.INNNAK(N1.DATNOM) AS VARCHAR(6))
              ELSE N1.STFNOM END
              FROM #TMPNC N1
              WHERE n1.B_ID=t.B_ID
                    --AND n1.marsh=t.marsh
                    --AND n1.nd=@nd
        FOR XML PATH('')),1,2,'') AS LISTNAKS,
        SUM(T.VES) AS VES,
        isnull(t.BrNo,0) as BrNo
FROM #TMPNC t LEFT JOIN DEF A ON A.PIN=t.B_ID
GROUP BY t.B_ID,A.GPNAME,A.GPADDR,A.BRINN,t.MARSH, t.BrNo
ORDER BY BrNo,FAM, B_ID
--SET STATISTICS TIME OFF
SET NOCOUNT OFF
END