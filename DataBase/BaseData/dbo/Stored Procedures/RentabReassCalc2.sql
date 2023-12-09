CREATE PROCEDURE dbo.RentabReassCalc2 @date_from datetime, @date_to datetime, @calctip int
AS
BEGIN
--print @date_from
--print @date_to
if object_id('tempdb..#reinv') is not null drop table #reinv
create table #reinv(date_from DATETIME, date_to DATETIME, ncod INT, plata NUMERIC(18, 2))
INSERT INTO #reinv
select @date_from, convert(varchar, @date_to, 4), k.ncod, sum(k.Plata) 
from dbo.kassa1 k 
--inner join dbo.vendors v on v.ncod = k.ncod
where k.nd >= @date_from and k.nd <= @date_to
and k.remark like 'reass%' and k.ncod in
(
select rbb.ncod from 
dbo.rentabbase2 rbb where rbb.pin = -1
and rbb.date_from = convert(varchar, @date_from, 4)
and rbb.date_to = convert(varchar, @date_to, 4)
group by rbb.ncod
)
group by k.ncod

delete from dbo.rentabreass2 where date_from = convert(varchar, @date_from, 4) 
and date_to = convert(varchar, @date_to, 4)

insert into dbo.rentabreass2
SELECT r.date_from, r.date_to, r.ncod, 
--ROUND(IIF(h.cnt = 0, 0, r.plata / h.cnt), 2) plata 
r.plata
FROM #reinv r
INNER JOIN (SELECT date_from, date_to, ncod, COUNT(DISTINCT hitag) cnt 
FROM dbo.rentabbase2 GROUP BY ncod, date_from, date_to) h ON h.date_from = convert(varchar, @date_from, 4) 
AND h.date_to = convert(varchar, @date_to, 4) AND h.ncod = r.ncod
  
END