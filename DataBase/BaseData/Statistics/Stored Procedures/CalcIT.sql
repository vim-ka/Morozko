CREATE PROCEDURE [Statistics].CalcIT @nd1 datetime, @nd2 datetime
AS
BEGIN
-- сумма премии за месяц I кат - 8
-- сумма премии за месяц II кат - 9
-- сумма премии за месяц III кат - 10

if object_id('tempdb..#o') is not null drop table #o
if object_id('tempdb..#t') is not null drop table #t

CREATE TABLE #o(p_id int, fio varchar(256))
INSERT INTO #o(p_id, fio)
SELECT p.p_id, p.fio FROM dbo.person p WHERE p.depid = 11 and p.closed = 0

CREATE TABLE #t(idx_stat int, kol INT, p_id INT, datefrom DATETIME, dateto datetime, st_sum numeric(15, 2))
INSERT into #t(idx_stat, kol, p_id, datefrom, dateto, st_sum) 

select sm.statid, 1, sm.p_id, @ND1, @ND2, sc.coeffval
from [Statistics].SMain sm 
inner join [Statistics].SCoeff sc on sc.statid = sm.statid
inner join #o on #o.p_id = sm.p_id

--select * from #t

MERGE INTO [Statistics].SCalc sc
USING (SELECT #t.idx_stat, #t.kol, #t.p_id, #t.datefrom, #t.dateto, #t.st_sum from #t  
       ) E
         ON (sc.p_id = E.p_id AND sc.idx_stat = E.idx_stat AND sc.date_from = E.datefrom AND sc.date_to = E.dateto)
       WHEN MATCHED THEN 
          UPDATE SET sc.kol = E.kol, sc.p_id = E.p_id, sc.date_from = E.datefrom, sc.date_to = E.dateto, sc.st_sum = E.st_sum
       WHEN NOT MATCHED THEN 
          INSERT (idx_stat, kol, p_id, date_from, date_to, st_sum) 
          VALUES(E.idx_stat, E.kol, E.p_id, E.datefrom, E.dateto, E.st_sum);
END