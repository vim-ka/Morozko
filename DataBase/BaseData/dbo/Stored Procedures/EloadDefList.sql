CREATE PROCEDURE dbo.EloadDefList
AS
BEGIN
SELECT DISTINCT al.AG_ID [Код агента],
                p.Fio [ФИО агента],
                d1.DName [Отдел],
                fc.OurName [Организация],
                d.pin [Код точки],
                d.brName [Наименование точки],
                d.gpAddr [Адрес],
                d.brInn [ИНН],
                d.Contact [Контактное лицо],
                d.brPhone [Телефон 1],
                d.gpPhone [Телефон 2],
                d.Email
FROM Def d
INNER JOIN DefContract dc ON d.pin = dc.pin
INNER JOIN AgentList al ON dc.ag_id = al.AG_ID
INNER JOIN Person p ON al.P_ID = p.P_ID
INNER JOIN Deps d1 ON al.DepID = d1.DepID
INNER JOIN FirmsConfig fc ON dc.Our_id = fc.Our_id
WHERE d.Actual=1
      AND dc.Actual=1
      AND d.Worker=0
ORDER BY d1.DName, 
         p.Fio, 
         d.brName
END