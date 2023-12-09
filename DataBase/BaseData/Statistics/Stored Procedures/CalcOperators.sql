CREATE PROCEDURE [Statistics].CalcOperators @nd1 datetime, @nd2 datetime
AS
BEGIN
declare 
@basevalue numeric(12, 2)
set @basevalue = 0
/*@dn1 INT, 
@dn2 int

set @ND1 = '01.02.2017'
set @ND2 = '28.02.2017' -- 23:59:59'
SET @dn1 = dbo.InDatNom(0001, @nd1)
SET @dn2 = dbo.InDatNom(9999, @nd2)*/

-- количество распечатанных накладных - 1
-- количество строк - 3
-- количество строк по акции - 2

if object_id('tempdb..#o') is not null drop table #o
if object_id('tempdb..#t') is not null drop table #t

CREATE TABLE #o(uin INT, p_id int, fio varchar(256))
INSERT INTO #o(uin, p_id, fio)
SELECT u.uin, u.p_id, p.fio FROM dbo.usrPwd u inner join dbo.person p on p.p_id = u.p_id WHERE u.trid = 4 and p.closed = 0

CREATE TABLE #t(idx_stat int, kol INT, p_id INT, datefrom DATETIME, dateto datetime)
INSERT into #t(idx_stat, kol, p_id, datefrom, dateto) 

SELECT 2, COUNT(v.hitag), #o.p_id, @ND1, @ND2 FROM dbo.printlog p inner JOIN #o ON #o.uin = p.printop 
inner join dbo.nc c on c.datnom = p.datnom inner join dbo.nv v on v.datnom = c.datnom
WHERE p.nd >= @nd1 AND p.ND <= @nd2 and c.Actn=1
group by #o.p_id
UNION all
SELECT 3, count(nv.nvID) kol_strok, o.p_id, @ND1, @ND2 from log l inner join #o o on o.uin = l.op 
inner join nv on nv.DatNom = cast(l.param1 as int) 
where l.ND >= @nd1 and l.nd <= @nd2 and l.tip in ('NShow', 'NEdit')
group by o.p_id
UNION ALL
SELECT 1, count(datnom) kol_nakl, #o.p_id, @ND1, @ND2 from PrintLog p inner JOIN #o ON #o.uin = p.PrintOp 
WHERE p.ND >= @ND1 AND p.nd <= @nd2
GROUP BY #o.p_id
union all
select 7, 1, sm.p_id, @nd1, @nd2 from [Statistics].SMain sm where sm.statid = 7
union all
select 12, count(p.nnak) kol_nakl, #o.p_id, @nd1, @nd2 from dbo.printlog p
inner join dbo.nc c on c.datnom = p.datnom inner join #o on #o.uin = p.printop
where 
c.actn = 1
and p.ND >= @ND1 AND p.nd <= @nd2
group by #o.p_id

--SELECT * FROM #o
--SELECT * FROM #t

select @basevalue = basevalue from [Statistics].SCoeffBase where datefrom = @nd1 and dateto = @nd2 and depid = 22

/*CREATE TABLE #c(b1 bit, statid int, p_id int)
INSERT INTO #c(b1, statid, p_id)
SELECT IIF(#t.kol > @basevalue AND #t.idx_stat = 1, 1, 0), #t.idx_stat, #t.p_id FROM #t
INNER JOIN [Statistics].SCoeff scff ON scff.statid = #t.idx_stat AND scff.datefrom = @nd1 AND scff.dateto =@nd2*/

--SELECT * FROM #c

--MERGE INTO [Statistics].SCalc sc
--USING (

--delete from [Statistics].SCalc where date_from = @nd1 and date_to = @nd2 and p_id in (select p_id from #o)

/*insert into [Statistics].SCalc(idx_stat, kol, p_id, date_from, date_to, st_sum)
       SELECT #t.idx_stat, #t.kol, #t.p_id, #t.datefrom, #t.dateto,  
	   ISNULL(CASE WHEN #t.idx_stat in (1, 2, 3) THEN #t.kol END, 0) st_sum
       FROM #t 
       INNER JOIN [Statistics].SCoeff scff ON scff.statid = #t.idx_stat and scff.datefrom = @nd1 and scff.dateto = @nd2*/

/*       SELECT #t.idx_stat, #t.kol, #t.p_id, #t.datefrom, #t.dateto,  
	   ISNULL(CASE WHEN #t.idx_stat in (1, 2, 3) THEN #t.kol * iif(#t.kol > @basevalue, scff.hi, scff.lo) END, 0) -  
       ISNULL(CASE WHEN #t.idx_stat = 7 THEN iif(#t.kol > @basevalue, scff.hi, scff.lo) ELSE 0 END, 0) st_sum FROM #t --типа вычитаем ошибку из премии, хотя количество ошибок не оговаривалось
	   INNER JOIN [Statistics].SCoeff scff ON scff.statid = #t.idx_stat and scff.datefrom = @nd1 and scff.dateto = @nd2
--       INNER JOIN (SELECT statid, coeffval, lo, hi FROM [Statistics].scoeff WHERE datefrom >= @nd1 and dateto <= @nd2) scff ON scff.statid = #t.idx_stat 
       AND #t.kol BETWEEN scff.lo AND scff.hi*/
--       ) E
--         ON (sc.p_id = E.p_id AND sc.idx_stat = E.idx_stat AND sc.date_from = E.datefrom AND sc.date_to = E.dateto)
--       WHEN MATCHED THEN 
--          UPDATE SET sc.kol = E.kol, sc.p_id = E.p_id, sc.date_from = E.datefrom, sc.date_to = E.dateto, sc.st_sum = E.st_sum
--       WHEN NOT MATCHED THEN 
--          INSERT (idx_stat, kol, p_id, date_from, date_to, st_sum) 
--          VALUES(E.idx_stat, E.kol, E.p_id, E.datefrom, E.dateto, E.st_sum); 

/*update [Statistics].SCalc set st_sum = st_sum * iif(E.kf = 1, k.hi, k.lo) 
from
[Statistics].SCalc
inner join
(select sc.p_id, iif(sc.st_sum > @basevalue, 1, 0) kf from [Statistics].SCalc sc
where sc.date_from = @nd1 and sc.date_to = @nd2 
and sc.idx_stat = 1
group by sc.p_id, sc.st_sum) E on E.p_id = [Statistics].SCalc.p_id
inner join [statistics].scoeff k on k.statid = [Statistics].SCalc.idx_stat and k.datefrom = @nd1 and k.dateto = @nd2
where [Statistics].SCalc.date_from = @nd1 and [Statistics].SCalc.date_to = @nd2*/

delete from [Statistics].SCalc where date_from = @nd1 and date_to = @nd2 and p_id in (select p_id from #o)
if object_id('tempdb..#wt') is not null drop table #wt

create table #wt(idx_stat int, kol numeric(15, 2), p_id int, date_from datetime, date_to datetime, st_sum numeric(18,2), kol_vs numeric(15, 2))
--insert into [Statistics].SCalc(idx_stat, kol, p_id, date_from, date_to, st_sum)
insert into #wt
       SELECT #t.idx_stat, #t.kol, #t.p_id, #t.datefrom, #t.dateto,  
	   ISNULL(CASE WHEN #t.idx_stat in (1, 2, 3) THEN #t.kol END, 0) st_sum, #t.kol - #t12.kol kol_vs
       FROM #t 
       inner join (select p_id, kol from #t where idx_stat = 12) #t12 on #t12.p_id = #t.p_id
       INNER JOIN [Statistics].SCoeff scff ON scff.statid = #t.idx_stat and scff.datefrom = @nd1 and scff.dateto = @nd2
       
select @basevalue = basevalue from [Statistics].SCoeffBase where datefrom = @nd1 and dateto = @nd2 and depid = 22
--print @basevalue

--select * from #wt

--select sc.p_id, iif(sc.st_sum > @basevalue, 1, 0) kf from #wt sc
--where sc.date_from = @nd1 and sc.date_to = @nd2 
--and sc.idx_stat = 1
--group by sc.p_id, sc.st_sum

--select * from [statistics].scoeff k where k.datefrom = @nd1 and k.dateto = @nd2

update #wt set st_sum = st_sum * iif(E.kf = 1, k.hi, k.lo) 
from
#wt
inner join
(select sc.p_id, iif(sc.kol_vs > @basevalue, 1, 0) kf from #wt sc
where sc.date_from = @nd1 and sc.date_to = @nd2 
and sc.idx_stat = 1
group by sc.p_id, sc.kol_vs) E on E.p_id = #wt.p_id
inner join [statistics].scoeff k on k.statid = #wt.idx_stat and k.datefrom = @nd1 and k.dateto = @nd2
where #wt.date_from = @nd1 and #wt.date_to = @nd2       

insert into [Statistics].SCalc
select * from #wt

END