CREATE PROCEDURE db_FarLogistic.GetBillInfoByVendor
@dt1 datetime,
@dt2 datetime
AS
BEGIN
	--Для Кати
SELECT gb.dlGroupBillID,
       gb.MarshID,
       gb.WorkID,
       iif(gb.CasherID=16256,0,gb.CasherID) [VendorID],
       gb.CasherID,
       sum(tmc.delta+tmc.KM) [KM],
       gb.ForPay [Cost],
       gb.DepID
INTO #sel_marshs
FROM db_FarLogistic.dlGroupBill gb
INNER JOIN Def d ON d.pin=gb.CasherID
INNER JOIN db_FarLogistic.dlTmpMarshCost tmc ON gb.MarshID = tmc.MarshID AND gb.WorkID = tmc.WorkID
INNER JOIN db_FarLogistic.dlDef d1 ON gb.CasherID=d1.ID
WHERE gb.GivenDate BETWEEN @dt1 AND @dt2
      AND d1.nal=0
GROUP by gb.dlGroupBillID,gb.MarshID,gb.WorkID,iif(gb.CasherID=16256,0,gb.CasherID),gb.CasherID,gb.ForPay,gb.DepID

SELECT ji.MarshID,
       j.NumberWorks,
       iif(ji.CasherID=16256,16256,-1) [CasherID],
       ji.VendorID,
       sum(j.FWeight*1000) [Weight],
       0 [WeightMorozko],
       CAST(0.0 AS DECIMAL(15,4)) [WeightPart]
INTO #sel_jorney
FROM db_FarLogistic.dlJorneyInfo ji
INNER JOIN db_FarLogistic.dlJorney j ON ji.IDReq = j.IDReq
INNER JOIN (SELECT DISTINCT sm.MarshID,sm.WorkID FROM #sel_marshs sm) tm ON j.NumberWorks=tm.WorkID AND ji.MarshID=tm.MarshID
WHERE j.IDdlPointAction IN (2,3)
GROUP BY ji.MarshID,j.NumberWorks,iif(ji.CasherID=16256,16256,-1),ji.VendorID

UPDATE #sel_jorney SET WeightMorozko=x.[w]
FROM #sel_jorney sj 
INNER JOIN (SELECT a.MarshID, a.CasherID, SUM(weight) [w] FROM #sel_jorney a WHERE a.CasherID=16256 GROUP BY a.MarshID, a.CasherID) x ON x.MarshID=sj.marshid AND sj.casherid=x.CasherID

UPDATE #sel_jorney SET WeightPart=IIF(CasherID=16256,iif(WeightMorozko=0,0,Weight/WeightMorozko),1)

SELECT m.dlGroupBillID,
       m.MarshID,
       m.WorkID,
       c.upin [CasherID],
       c.brName,
       v.upin [VendorID],
       v.brName,
       v.Ncod,
       m.km * x.WeightPart [KM],
       m.Cost * x.WeightPart [Cost],
       m.DepID 			[dep],
       de.DName,
       14 [our_id],
       fc.OurName
FROM #sel_marshs m
left JOIN (
SELECT MarshID,
       NumberWorks [WorkID],
       VendorID,
       WeightPart
FROM #sel_jorney
) x ON m.MarshID=x.MarshID AND x.WorkID=m.WorkID
left JOIN Def c ON c.pin=m.CasherID
LEFT JOIN Def v ON v.pin=x.VendorID
left join db_FarLogistic.dlDef dd on dd.id=c.pin 
left join dbo.FirmsConfig fc on fc.our_id=14
left join dbo.deps de on de.depid=m.depid
ORDER BY m.MarshID,x.WorkID

DROP TABLE #sel_marshs
DROP TABLE #sel_jorney

END