CREATE PROCEDURE [ELoadMenager].Eload_FLCargoCost
@dt1 DATETIME,
@dt2 DATETIME
AS 
BEGIN
CREATE TABLE #tmpMarshCargoCost (id INT IDENTITY(1,1),
                                 MarshID INT,
                                 MarshDescr varchar(500),
                                 DT DATETIME,
                                 VehID INT,
                                 VehName varchar(50),
                                 CargoCost MONEY
                                 )

INSERT INTO #tmpMarshCargoCost (MarshID,MarshDescr,DT,VehID,VehName)
SELECT m.dlMarshID,
       mis.Race,
       CONVERT(VARCHAR,m.dt_end_fact,104),
       m.IDdlVehicles,
       v.Model+' '+v.regnom
FROM db_FarLogistic.dlMarsh m
INNER JOIN db_FarLogistic.dlGroupBill gb ON gb.MarshID=m.dlMarshID
INNER JOIN db_FarLogistic.dlVehicles v ON v.dlVehiclesID=m.IDdlVehicles
INNER JOIN db_FarLogistic.MarshInStrings() mis ON mis.MarshID=m.dlMarshID
WHERE m.dt_end_fact BETWEEN @dt1 AND @dt2
GROUP BY m.dlMarshID,mis.Race,m.dt_end_fact,m.IDdlVehicles,v.Model,v.regnom

UPDATE #tmpMarshCargoCost SET CargoCost=ISNULL((SELECT SUM(ISNULL(ji.CargoCost,0)) FROM db_FarLogistic.dlJorneyInfo ji WHERE ji.MarshID=#tmpMarshCargoCost.MarshID),0)

SELECT CONVERT(VARCHAR,mcc.DT,104) [Дата],
       mcc.MarshID [КодМаршрута],
       mcc.MarshDescr [Направление],
       mcc.VehID [КодМашины],
       mcc.VehName [НаименованиеМашины],
       mcc.CargoCost [СтоимостьГруза] 
FROM #tmpMarshCargoCost mcc
ORDER BY mcc.VehID, mcc.DT

SELECT DATENAME(MONTH,mcc.DT)+CAST(YEAR(mcc.DT) AS VARCHAR) [Дата],
       mcc.VehID [КодМашины],
       mcc.VehName [НаименованиеМашины],
       SUM(mcc.CargoCost) [СтоимостьГруза] 
FROM #tmpMarshCargoCost mcc
GROUP BY DATENAME(MONTH,mcc.DT)+CAST(YEAR(mcc.DT) AS VARCHAR),mcc.VehID,mcc.VehName,YEAR(mcc.DT),MONTH(mcc.DT)
ORDER BY YEAR(mcc.DT),MONTH(mcc.DT),mcc.VehID

DROP TABLE #tmpMarshCargoCost
END