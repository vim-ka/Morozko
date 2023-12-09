CREATE PROCEDURE warehouse.ManageRoomsList @ND DATETIME
AS 
BEGIN
DECLARE @NormSpeedStr FLOAT  -- строк/мин
DECLARE @WaitTime FLOAT  -- время, после которого начинает отсчитываться простой

SET @NormSpeedStr = (SELECT CAST(Config.val AS FLOAT) FROM Config WHERE Config.param = 'NormSpeedStr')
SET @WaitTime = (SELECT CAST(Config.val AS FLOAT) FROM Config WHERE Config.param = 'WaitTime')

SET @ND = cast(convert(varchar, @ND, 104) as datetime)


--чтобы найти мин. время начала для каждого терминала/маршрута
if object_id('tempdb..#trooms') is not null drop table #trooms
create table #trooms (nzid INT, Marsh INT, tmEnd VARCHAR(8), srID INT,
                      comp VARCHAR(256))

INSERT INTO #trooms(nzid, marsh, tmEnd, srID, comp)
SELECT t.nzid, t.Marsh,  t.tmEnd, t.srid, t.comp
FROM(
SELECT DISTINCT
       nz.nzid,
       m.Marsh,
       nz.tmEnd,
       skladrooms.srID, 
       comp.value AS comp

  FROM nvzakaz nz
  LEFT JOIN NearLogistic.MarshRequests mr ON mr.reqid = nz.datnom
  LEFT JOIN Marsh m ON m.mhid = mr.mhID
   JOIN SkladList ON nz.skladNo = SkladList.SkladNo
   JOIN SkladGroups ON SkladGroups.skg = SkladList.skg
   JOIN skladrooms ON skladrooms.srID = SkladGroups.srid
  CROSS APPLY (SELECT a.value FROM STRING_SPLIT
                (IIF(CHARINDEX('#', nz.comp)>0, RIGHT(nz.comp, LEN(nz.comp)-CHARINDEX('#', nz.comp)), nz.comp),
                '#') AS a WHERE a.VALUE NOT LIKE('%@Cancel%')) comp    --распарсиваем список компов без первого
 WHERE nz.dt = @ND
   AND (mr.ReqType = 0 OR mr.ReqType IS NULL)
   AND nz.Done = 1
)t
 ORDER BY t.srID ASC, t.comp ASC, t.tmEnd ASC


--чтобы посчитать кол-во строк в комнатах
if object_id('tempdb..#tstr') is not null drop table #tstr
create table #tstr (srID INT, comp VARCHAR(256), strcount INT, tmEnd VARCHAR(8))

INSERT INTO #tstr(srID, comp, strcount, tmEnd)
SELECT t.srID, t.comp, 
       SUM(t.strcount) AS strcount,
       MAX(t.tmEnd) AS tmEnd      

FROM(
SELECT skladrooms.srID, comp.value AS comp,
       COUNT(nz.nzid) AS strcount,                 --набранных строк
       MAX(nz.tmEnd) AS tmEnd                      --последнее время набора

  FROM Marsh m
  JOIN NearLogistic.MarshRequests mr ON m.mhid = mr.mhID
  JOIN nvZakaz nz ON mr.reqid = nz.datnom
  JOIN SkladList ON nz.skladNo = SkladList.SkladNo
  JOIN SkladGroups ON SkladGroups.skg = SkladList.skg
  JOIN skladrooms ON skladrooms.srID = SkladGroups.srid
  CROSS APPLY (SELECT a.value FROM STRING_SPLIT
                  (IIF(CHARINDEX('#', nz.comp)>0, RIGHT(nz.comp, LEN(nz.comp)-CHARINDEX('#', nz.comp)), nz.comp),
                  '#') AS a WHERE a.VALUE NOT LIKE('%@Cancel%')) comp    --распарсиваем список компов без первого 
 WHERE m.ND = @ND
   AND mr.ReqType = 0
   AND nz.Done = 1
GROUP BY skladrooms.srID, comp.value

UNION

SELECT skladrooms.srID, comp.value AS comp,
       COUNT(nz.nzid) AS strcount,                   --набранных строк
       MAX(nz.tmEnd) AS tmEnd                      --последнее время набора

  FROM NC
  JOIN nvZakaz nz ON nz.DatNom = NC.DatNom
  JOIN SkladList ON nz.skladNo = SkladList.SkladNo
  JOIN SkladGroups ON SkladGroups.skg = SkladList.skg
  JOIN skladrooms ON skladrooms.srID = SkladGroups.srid
  CROSS APPLY (SELECT a.value FROM STRING_SPLIT
                  (IIF(CHARINDEX('#', nz.comp)>0, RIGHT(nz.comp, LEN(nz.comp)-CHARINDEX('#', nz.comp)), nz.comp),
                  '#') AS a WHERE a.VALUE NOT LIKE('%@Cancel%')) comp    --распарсиваем список компов без первого
 WHERE nz.dt = @ND
   AND NC.mhID = 0
   AND nz.Done = 1
GROUP BY skladrooms.srID, comp.value

) t
JOIN TSDList ON t.comp = TSDList.tsdname
GROUP BY t.srID, t.comp


---------------------------------------------------------------------------------------------------------------

SELECT t1.nzid, t1.spk, t1.FIO, t1.Marsh, t1.tmEnd, 

       IIF(t1.compname IS NULL, TSDList.srID, t1.srID) AS srID,     
       IIF(t1.compname IS NULL, skladrooms.room_name, t1.room_name) AS room_name,          
       t1.group_id, 
       IIF(t1.compname IS NULL, TSDList.tsdname, t1.compname) AS compname, 


-- % от нормальной мощности: 

--          кол. набранных строк на терминале / время работы 
--        ____________________________________________________  * 100%
--                         норм. мощность 

     CAST(
       ROUND(
             (CAST(#tstr.strcount AS DECIMAL(6,2)) /
              IIF((CAST(DATEDIFF(minute, (t1.dt_create), GETDATE()) AS DECIMAL(6,2)))=0, 1, 
                   CAST(DATEDIFF(minute, (t1.dt_create), GETDATE()) AS DECIMAL(6,2)))
              / @NormSpeedStr * 100), 
            2)
         AS VARCHAR) + '%' AS prc,
  
          --CONVERT(VARCHAR, (GETDATE() - #tstr.tmEnd), 108) AS StandTime       
  
          IIF(GETDATE() > DATEADD(MINUTE, @WaitTime, @ND + #tstr.tmEnd),
                     CONVERT(VARCHAR, (GETDATE() - DATEADD(MINUTE, @WaitTime, @ND + #tstr.tmEnd) ), 108), 
                     CONVERT(VARCHAR, '', 108)) AS StandTime
      
     
FROM TSDList
LEFT JOIN
(
  SELECT
        MAX(t.nzid) AS nzid, 
        MAX(t.spk) AS spk,
        IIF(CHARINDEX(' ', MAX(t.FIO))>1, LEFT(MAX(t.FIO), CHARINDEX(' ', MAX(t.FIO))-1),
             MAX(t.FIO)
             ) AS FIO,
  
        MAX(t.Marsh) AS Marsh,
        MAX(t.tmEnd) AS tmEnd,
        t.srid, t.room_name,
        MAX(t.group_id) AS group_id,  t.comp  as compname,
        MAX(t.dt_create) AS dt_create

  FROM(
  SELECT DISTINCT
         nz.nzid,
         IIF(nz.group_id > 0, CAST(spks.VALUE AS INT), nz.spk) AS spk,
         IIF(nz.group_id > 0, ISNULL(sp.FIO, ''),
                              ISNULL(SkladPersonal.FIO, '')
                              ) AS FIO,

         isnull(m.Marsh, dbo.InNnak(nz.datnom)) AS Marsh,
         nz.tmEnd,
         skladrooms.srID, skladrooms.room_name,
         nz.group_id,
         comp.value AS comp,
         sgh.dt_create

    FROM nvzakaz nz
    LEFT JOIN NearLogistic.MarshRequests mr ON mr.reqid = nz.datnom
    LEFT JOIN Marsh m ON m.mhid = mr.mhID
     JOIN SkladList ON nz.skladNo = SkladList.SkladNo
     JOIN SkladGroups ON SkladGroups.skg = SkladList.skg
     JOIN skladrooms ON skladrooms.srID = SkladGroups.srid
    LEFT JOIN SkladPersonal ON SkladPersonal.spk = nz.spk
    LEFT JOIN warehouse.sklad_gang_history sgh ON sgh.sgID = nz.group_id
    CROSS APPLY (SELECT a.value FROM STRING_SPLIT(ISNULL(sgh.spks,''),',') AS a) spks
    LEFT JOIN SkladPersonal sp ON CAST(sgh.spks AS INT) = sp.spk
    CROSS APPLY (SELECT a.value FROM STRING_SPLIT
                  (IIF(CHARINDEX('#', nz.comp)>0, RIGHT(nz.comp, LEN(nz.comp)-CHARINDEX('#', nz.comp)), nz.comp),
                  '#') AS a WHERE a.VALUE NOT LIKE('%@Cancel%')) comp    --распарсиваем список компов без первого
   WHERE nz.dt = @ND
     AND (mr.ReqType = 0 OR mr.ReqType IS NULL)
     AND nz.Done = 1
  )t

  WHERE t.tmEnd IN
    (SELECT MIN(#trooms.tmEnd) AS tmMin
       FROM #trooms
      GROUP BY IIF(#trooms.Marsh IS NULL, #trooms.nzid, #trooms.Marsh), #trooms.srID, #trooms.comp
      HAVING MAX(#trooms.tmEnd) IN 
        (SELECT MAX(#trooms.tmEnd) FROM #trooms 
          GROUP BY #trooms.srID, #trooms.comp)
    )

  GROUP BY 
    t.srID, t.room_name,  t.comp

) t1 ON TSDList.tsdname = t1.compname
  JOIN skladrooms ON skladrooms.srID = TSDList.srid  
  LEFT JOIN #tstr ON t1.srID = #tstr.srID AND #tstr.comp = t1.compname

ORDER BY srID ASC, compname ASC, tmEnd ASC, FIO ASC


DROP TABLE #tstr
DROP TABLE #trooms
    
    
END