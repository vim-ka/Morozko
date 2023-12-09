CREATE PROCEDURE warehouse.ManageMarshList @ND DATETIME, @check BIT = 0
AS 
BEGIN

DECLARE @SQL VARCHAR(MAX) = '',
        @cols1 VARCHAR(MAX) = '',
        @cols2 VARCHAR(MAX) = '',
        @cols3 VARCHAR(MAX) = '',
        @cols4 VARCHAR(MAX) = '',
        @i INT,
        @rcount INT

SET @ND = cast(convert(varchar, @ND, 104) as datetime)

SET @SQL = ''
SET @cols1 =
        '[' +  STUFF((select  ',' + '[a' +  CAST(skladrooms.srID AS VARCHAR) + ']'
          FROM skladrooms  ORDER BY skladrooms.srID ASC
               for xml path(''))
              ,1,2,'')

SET @cols2 =
        '[' +  STUFF((select  ',' + '[b' +  CAST(skladrooms.srID AS VARCHAR) + ']'
          FROM skladrooms  ORDER BY skladrooms.srID ASC
               for xml path(''))
              ,1,2,'')

SET @cols3 =
        '[' +  STUFF((select  ',' + '[c' +  CAST(skladrooms.srID AS VARCHAR) + ']'
          FROM skladrooms  ORDER BY skladrooms.srID ASC
               for xml path(''))
              ,1,2,'')

SET @cols4 =
        '[' +  STUFF((select  ',' + '[d' +  CAST(skladrooms.srID AS VARCHAR) + ']'
          FROM skladrooms  ORDER BY skladrooms.srID ASC
               for xml path(''))
              ,1,2,'')


SET @rcount= (SELECT COUNT(skladrooms.srID) FROM skladrooms)

SET @SQL = ''
SET @SQL = @SQL +
'
DECLARE @ND1 DATETIME
DECLARE @vND1 VARCHAR(20)

SET @vND1 = ''' + CAST(@ND AS varchar) + '''
SET @ND1 = CAST(@vND1 AS DATETIME)

SELECT * FROM(
SELECT t4.mhid, t4.Marsh, t4.RegName,
       ''Точки: '' + CAST(COUNT(DISTINCT t4.Points) AS VARCHAR) + CHAR(10)
       + ''Тоннаж: '' + CAST(SUM(t4.WeightAll1) AS VARCHAR) AS Points,

       t4.TimePlan,
'

SET @i=1
WHILE (@i <= @rcount)
BEGIN
  SET @SQL = @SQL +
      '
       IIF(SUM(ISNULL(t4.d'+CAST(@i AS VARCHAR)+',0)) = 0, '''',
       (''Стр.: '' + CAST(SUM(ISNULL(t4.a'+CAST(@i AS VARCHAR)+',0)) AS VARCHAR)
       + ''/'' + CAST(SUM(ISNULL(t4.b'+CAST(@i AS VARCHAR)+',0)) AS VARCHAR) + CHAR(10)
       + ''Вес: '' + CAST(SUM(ISNULL(t4.c'+CAST(@i AS VARCHAR)+',0)) AS VARCHAR)
       + ''/'' + CAST(SUM(ISNULL(t4.d'+CAST(@i AS VARCHAR)+',0)) AS VARCHAR) + CHAR(10)
       + CAST(
              CAST(
                   (IIF(SUM(ISNULL(t4.d'+CAST(@i AS VARCHAR)+',0))=0, 100,
                            (SUM(ISNULL(t4.d'+CAST(@i AS VARCHAR)+',0))-SUM(ISNULL(t4.c'+CAST(@i AS VARCHAR)+
                              ',0)))/SUM(ISNULL(t4.d'+CAST(@i AS VARCHAR)+',0))*100) )
              AS DECIMAL(5,2))
         AS VARCHAR) + ''%''))
       AS r'+CAST(@i AS VARCHAR)+','


  SET @i = @i+1
END

SET @SQL = @SQL +
'
       IIF(SUM(ISNULL(t4.WeightAll1, 0)) = 0, '''',
       (CAST(
            CAST(((SUM(t4.WeightAll1)-SUM(t4.Weight1))/SUM(t4.WeightAll1)*100)
            AS DECIMAL(5,2))
       AS VARCHAR) + ''%'')) AS prc,

       t4.Stockman, t4.Fio,
       t4.LaID, t4.LaName
FROM
(
SELECT * FROM(
SELECT * FROM
(
SELECT *
FROM (
SELECT *
FROM(
SELECT m.mhid, m.Marsh,

       (SELECT DISTINCT STUFF((select DISTINCT '', '' +  sreg.sregName
          FROM warehouse.skladreg sreg
         WHERE sreg.sregionID IN(SELECT DISTINCT sreg.sregionID
                                   FROM NearLogistic.MarshRequests mr1
                                   JOIN nvZakaz nz ON mr1.reqid = nz.datnom
                                   JOIN SkladList ON nz.skladNo = SkladList.SkladNo
                                   JOIN SkladGroups ON SkladGroups.skg = SkladList.skg
                                   JOIN warehouse.skladreg sreg ON sreg.sregionID = SkladGroups.srID
                                  WHERE mr1.mhID = m.mhid
                                )
               for xml path(''''))
              ,1,2,'''')
       ) AS RegName,

        mr.PINTo AS Points,
        SUM(IIF(nz.Done = 0, IIF(nz.zakaz<0, 0, 1), 0)) AS strcount,       --ненабранных строк
        COUNT(IIF(nz.zakaz<0, 0, nz.nzid)) AS strcountAll,                 --всего строк

        SUM(IIF(nz.Done = 0, IIF(nz.zakaz<0, 0, nz.zakaz), 0)) AS Weight,   --ненабранный вес
        SUM(IIF(nz.Done = 0, IIF(nz.zakaz<0, 0, nz.zakaz), 0)) AS Weight1,  --ненабранный вес
        SUM(IIF(nz.zakaz<0, 0, nz.zakaz)) AS WeightAll,                     --вес всего
        SUM(IIF(nz.zakaz<0, 0, nz.zakaz)) AS WeightAll1,                    --вес всего

        ''a'' + cast(skladrooms.srID as VARCHAR) AS a,
        ''b'' + cast(skladrooms.srID as VARCHAR) AS b,
        ''c'' + cast(skladrooms.srID as VARCHAR) AS c,
        ''d'' + cast(skladrooms.srID as VARCHAR) AS d,

        m.TimePlan,
        m.Stockman, SkladPersonal.Fio,
        m.LaID, SkladLoadArea.LaName

  FROM Marsh m
  JOIN NearLogistic.MarshRequests mr ON m.mhid = mr.mhID
  JOIN nvZakaz nz ON mr.reqid = nz.datnom
  JOIN SkladList ON nz.skladNo = SkladList.SkladNo
  JOIN SkladGroups ON SkladGroups.skg = SkladList.skg
  JOIN skladrooms ON skladrooms.srID = SkladGroups.srid
  LEFT JOIN SkladLoadArea ON SkladLoadArea.LaID = m.LaID
  LEFT JOIN SkladPersonal ON SkladPersonal.spk = m.stockman
 WHERE m.ND = @ND1
   AND mr.ReqType = 0
GROUP BY m.mhid, m.Marsh, m.TimePlan,
         skladrooms.srID, mr.PINTo,
         m.Stockman, SkladPersonal.Fio,
         m.LaID, SkladLoadArea.LaName

'
--------------------------------------------------------------------------------------------------------------------------

IF @check=1
SET @SQL = @SQL +
'
UNION
--из NV (проверка)
SELECT ISNULL(m.mhid, 0) AS mhid, m.Marsh,
       (SELECT DISTINCT STUFF((select DISTINCT '', '' +  sreg.sregName
          FROM warehouse.skladreg sreg
         WHERE sreg.sregionID IN(SELECT DISTINCT sreg.sregionID
                                   FROM NearLogistic.MarshRequests mr1
                                   JOIN NV ON mr1.reqid = NV.datnom AND mr1.ReqType = 0
                                   JOIN SkladList ON NV.Sklad = SkladList.SkladNo
                                   JOIN SkladGroups ON SkladGroups.skg = SkladList.skg
                                   JOIN warehouse.skladreg sreg ON sreg.sregionID = SkladGroups.srID
                                  WHERE mr1.mhID = ISNULL(m.mhid, 0)
                                )
               for xml path(''''))
              ,1,2,'''')
       ) AS RegName,

        mr.PINTo AS Points,

        COUNT(IIF(NV.Kol<0, 0, NV.hitag)) - SUM(IIF(mtd.hitag IS NULL, 0, 1)) AS strcount,    --непроверенных строк
        COUNT(IIF(NV.Kol<0, 0, NV.hitag)) AS strcountAll,        --всего строк

        SUM(IIF(NV.Kol<0, 0, NV.Kol)) - SUM(IIF(mtd.kol<0, 0, ISNULL(mtd.kol, 0))) AS Weight,    --непроверенный вес
        SUM(IIF(NV.Kol<0, 0, NV.Kol)) - SUM(IIF(mtd.kol<0, 0, ISNULL(mtd.kol, 0))) AS Weight1,   --непроверенный вес

        --SUM(IIF(mtd.kol<0, 0, ISNULL(mtd.kol, 0))) AS w, --проверенный вес

        SUM(IIF(NV.Kol<0, 0, NV.Kol)) AS WeightAll,                     --вес всего
        SUM(IIF(NV.Kol<0, 0, NV.Kol)) AS WeightAll1,                    --вес всего

        ''a'' + cast(skladrooms.srID as VARCHAR) AS a,
        ''b'' + cast(skladrooms.srID as VARCHAR) AS b,
        ''c'' + cast(skladrooms.srID as VARCHAR) AS c,
        ''d'' + cast(skladrooms.srID as VARCHAR) AS d,

        m.TimePlan,
        m.Stockman, SkladPersonal.Fio,
        m.LaID, SkladLoadArea.LaName

  FROM NC
  JOIN NV with (index(nv_datnom_idx)) ON NC.DatNom = NV.DatNom
  JOIN SkladList ON NV.Sklad = SkladList.SkladNo
  LEFT JOIN NearLogistic.MarshRequests mr ON mr.reqid = NV.datnom AND mr.ReqType = 0
  LEFT JOIN Marsh m ON m.mhid = mr.mhID
  JOIN SkladGroups ON SkladGroups.skg = SkladList.skg
  JOIN skladrooms ON skladrooms.srID = SkladGroups.srid
  LEFT JOIN SkladLoadArea ON SkladLoadArea.LaID = m.LaID
  LEFT JOIN SkladPersonal ON SkladPersonal.spk = m.stockman
  LEFT JOIN warehouse.sklad_mobiletermdata mtd ON m.mhid = mtd.mhid AND NV.DatNom = mtd.datnom AND NV.Hitag = mtd.hitag
 WHERE NC.ND = @ND1
   AND NC.SP > 0
   AND SkladList.UpWeight = 0
GROUP BY ISNULL(m.mhid, 0), m.Marsh, m.TimePlan,
         skladrooms.srID, mr.PINTo,
         m.Stockman, SkladPersonal.Fio,
         m.LaID, SkladLoadArea.LaName, SkladGroups.srid
'

SET @SQL = @SQL +
'
UNION

SELECT 0 AS mhid, NULL AS Marsh,

       (SELECT DISTINCT STUFF((select DISTINCT '', '' +  sreg.sregName
          FROM warehouse.skladreg sreg
         WHERE sreg.sregionID IN(SELECT DISTINCT sg1.srid
                                   FROM SkladGroups sg1
                                  WHERE sg1.srid = SkladGroups.srid
                                )
               for xml path(''''))
              ,1,2,'''')
       ) AS regName,

       NC.B_ID AS Points,

      SUM(IIF(nz.Done = 0, IIF(nz.zakaz<0, 0, 1), 0)) AS strcount,       --ненабранных строк
      COUNT(IIF(nz.zakaz<0, 0, nz.nzid)) AS strcountAll,                 --всего строк

      SUM(IIF(nz.Done = 0, IIF(nz.zakaz<0, 0, nz.zakaz), 0)) AS Weight, --ненабранный вес
      SUM(IIF(nz.Done = 0, IIF(nz.zakaz<0, 0, nz.zakaz), 0)) AS Weight1,--ненабранный вес
      SUM(IIF(nz.zakaz<0, 0, nz.zakaz)) AS WeightAll,                   --вес всего
      SUM(IIF(nz.zakaz<0, 0, nz.zakaz)) AS WeightAll1,                   --вес всего

      ''a'' + cast(skladrooms.srID as VARCHAR) AS a,
      ''b'' + cast(skladrooms.srID as VARCHAR) AS b,
      ''c'' + cast(skladrooms.srID as VARCHAR) AS c,
      ''d'' + cast(skladrooms.srID as VARCHAR) AS d,

      NULL AS TimePlan, NULL AS Stockman,
      NULL AS Fio, NULL AS LaID, NULL AS LaName

  FROM NC
  JOIN nvZakaz nz ON nz.DatNom = NC.DatNom
  JOIN SkladList ON nz.skladNo = SkladList.SkladNo
  JOIN SkladGroups ON SkladGroups.skg = SkladList.skg
  JOIN skladrooms ON skladrooms.srID = SkladGroups.srid
 WHERE NC.nd = @ND1
   AND NC.mhID = 0
GROUP BY NC.mhID, skladrooms.srID, NC.B_ID, SkladGroups.srid

  ) t

  --строк ненабр.
    pivot (
      SUM(t.strcount)
      for t.a in ('+@cols1+')
      ) p
) t1
  --строк всего
      pivot (
      SUM(t1.strcountall)
      for t1.b in ('+@cols2+')
      ) p

) t2
  --вес ненабр.
      pivot (
      SUM(t2.Weight)
      for t2.c in ('+@cols3+')
      ) p
)t3
  --вес всего
      pivot (
      SUM(t3.WeightAll)
      for t3.d in ('+@cols4+')
      ) p

) t4
GROUP BY t4.mhid, t4.Marsh, t4.TimePlan,
         t4.Stockman, t4.Fio,
         t4.LaID, t4.LaName,
         t4.RegName
) t5

ORDER BY
  CASE WHEN t5.Marsh IS NULL then t5.RegName END ASC,  t5.Marsh ASC
'
------------------------------------------------

EXEC(@SQL)

END