CREATE PROCEDURE dbo.ELOADGetDailySaldoDCK
@nd DATETIME, 
@our_id INT,
@isGroup BIT
AS 
BEGIN
DECLARE @dt DATETIME 
SET @dt=dbo.today()

IF OBJECT_ID('tempdb..#tmpSaldoDCK') IS NOT NULL DROP TABLE #tmpSaldoDCK
IF OBJECT_ID('tempdb..#ourFIRMS') IS NOT NULL DROP TABLE #ourFIRMS
IF OBJECT_ID('tempdb..#tmpSaldo') IS NOT NULL DROP TABLE #tmpSaldo

SELECT fc.Our_id,
       fc.OurName
INTO #ourFIRMS
from FirmsConfig fc
WHERE fc.Our_id=IIF(@our_id=-1,fc.Our_id,IIF(@isGroup=1,fc.Our_id,@our_id))
      AND fc.FirmGroup=IIF(@our_id=-1,fc.FirmGroup,IIF(@isGroup=1,@our_id,fc.FirmGroup))

CREATE TABLE #tmpSaldoDCK(sdID INT IDENTITY(1,1) NOT NULL,
                          DCK INT,
                          DCKNAME VARCHAR(100),
                          PIN INT,
                          PINNAME varchar(100),
                          OURID INT,
                          OURNAME VARCHAR(100),
                          AG_ID INT,
                          AGNAME VARCHAR(100),
                          MUST DECIMAL(20,2) NOT NULL DEFAULT 0,
                          MASTER INT,
                          DEEP INT,
                          SMWEEK DECIMAL(20,2),
                          OVERDUE DECIMAL(20,2)
                          )

INSERT INTO #tmpSaldoDCK(DCK,DCKNAME,PIN,PINNAME,OURID,OURNAME,AG_ID,AGNAME,MASTER)
SELECT dc.DCK, 
       dc.ContrName,
       dc.pin,
       d.brName,
       dc.Our_id,
       fc.OurName,
       dc.ag_id,
       p.Fio,
       d.Master
FROM DefContract dc
INNER JOIN def d ON dc.pin = d.pin
INNER JOIN #ourFIRMS fc ON dc.Our_id = fc.Our_id
LEFT JOIN AgentList al ON dc.ag_id = al.AG_ID
LEFT JOIN Person p ON al.P_ID = p.P_ID
WHERE dc.Actual=1   

SELECT dsd.DCK,
       dsd.Debt,
       dsd.Deep,
       ISNULL((SELECT SUM(k.Plata) FROM Kassa1 k WHERE k.dck=dsd.DCK AND k.BankDay BETWEEN DATEADD(WEEK,-1,@nd) AND @nd AND k.Oper=-2),0) [smweek],
       dsd.Overdue
INTO #tmpSaldo
FROM DailySaldoDck dsd 
WHERE dsd.ND=IIF(@nd=@dt,DATEADD(DAY,-1,@nd),@nd)

if @nd=@dt
begin
	update #tmpsaldo set debt=debt-y.pl
	from #tmpsaldo x 
	inner join ( select dck, sum(plata) pl from Kassa1 where nd=@dt group by dck) y on x.dck=y.dck
	
	update #tmpsaldo set debt=debt+y.ot
	from #tmpsaldo x 
	inner join ( select dck, sum(sp) ot from nc where nd=@dt group by dck) y on x.dck=y.dck
  print '1'
end

UPDATE #tmpSaldoDCK SET MUST=s.Debt,
                        DEEP=s.Deep,
                        SMWEEK=ISNULL(s.smweek,0),
                        OVERDUE=ISNULL(s.Overdue,0)
FROM #tmpSaldoDCK sd
INNER JOIN #tmpSaldo s ON sd.DCK = s.DCK

DELETE FROM #tmpSaldoDCK WHERE MUST=0   

SELECT DCK [КодДоговора],
       DCKNAME [НаименованиеДоговора],
       PIN [КодТочки],
       PINNAME [НаименованиеТочки],
       OURID [КодФирмы],
       OURNAME [НаименованиеФирмы],
       AG_ID [КодАгента],
       AGNAME [ФИОАгента],
       MUST [Долг],
       DEEP [Просрочка, дн.],
       OVERDUE [Просрочка, руб.],
       SMWEEK [Сумма оплат за предыдущие 7 дней, руб.]
from #tmpSaldoDCK sd

SELECT d.pin [Код точки],
       d.brName [Наименование точки],
       d1.depid [Код отдела],
       d1.DName [Отдел],
       x.MUST [Долг],
       x.DEEP [Просрочка, дн.],
       x.OVERDUE [Просрочка, руб.],
       x.SMWEEK [Сумма оплат за предыдущие 7 дней, руб.]
FROM (
SELECT sd.MASTER,
       MIN(sd.DCK) [DCK],
       SUM(sd.MUST) [MUST],
       MAX(DEEP) [DEEP],
       SUM(SMWEEK) [SMWEEK],
       SUM(sd.OVERDUE) [OVERDUE]
FROM #tmpSaldoDCK sd
WHERE sd.MASTER<>0
GROUP BY sd.MASTER) x
INNER JOIN def d ON d.pin=x.MASTER
INNER JOIN DefContract dc ON dc.dck=x.DCK
LEFT JOIN AgentList al ON dc.ag_id = al.AG_ID
LEFT JOIN Deps d1 ON al.DepID = d1.DepID
ORDER BY 4,2

DROP TABLE #tmpSaldoDCK
DROP TABLE #ourFIRMS
DROP TABLE #tmpSaldo
END