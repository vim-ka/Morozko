CREATE PROCEDURE dbo.EloadListNNAKDone
@skladlist VARCHAR(500),
@nd DATETIME 
AS 
BEGIN 
if OBJECT_ID('tempdb..#s') is not null 
	drop table #s
	
create table #s (s int not null)
insert into #s
select distinct number
from dbo.String_to_Int(@skladlist,',',1) 	

create index tmp_skl_idx on #s(s)

SELECT z.datnom,c.B_ID [pin]
INTO #nnaks
FROM nvZakaz z
INNER JOIN nc c ON z.datnom = c.DatNom
INNER JOIN #s s ON s.s=z.skladNo
WHERE DATEDIFF(DAY,z.ND,@ND)=0
GROUP BY z.datnom,c.b_id

DELETE n 
FROM #nnaks n
INNER JOIN nvZakaz z ON z.datnom=n.datnom
WHERE z.Done=0

SELECT * INTO #tmpResult FROM (
SELECT  r.SkladReg [Регион],
        RIGHT(z.datnom,4) [№ накладной],
        n1.name [Наименование],
        z.skladNo [Склад],
        z.Zakaz [Кол-во]        
FROM nvZakaz z
INNER JOIN Nomen n1 ON z.Hitag = n1.hitag
INNER JOIN #nnaks n ON z.datnom = n.datnom
INNER JOIN Def d ON d.pin=n.pin
INNER JOIN Regions r ON d.Reg_ID = r.Reg_ID
INNER JOIN #s s ON s.s=z.skladNo
UNION ALL 
SELECT '',RIGHT(datnom,4),'',999,NULL 
FROM #nnaks
GROUP BY datnom) x
ORDER BY 2,4

SELECT * FROM #tmpResult

SELECT [Регион],
       [№ накладной],
       [Склад],
       SUM([Кол-во]) [Кол-во]  
FROM #tmpResult r
GROUP BY [Регион],[№ накладной],[Склад]
ORDER BY 2,3

DROP TABLE #nnaks
END