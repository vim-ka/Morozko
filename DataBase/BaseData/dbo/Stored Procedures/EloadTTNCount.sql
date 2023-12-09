CREATE PROCEDURE dbo.EloadTTNCount
@nd1 datetime,
@nd2 datetime 
AS
BEGIN
  select month(p.nd) [Месяц],
         iif(v.CrId=7,cast(1 as bit),cast(0 as bit)) [Морозко],
         count(distinct p.datnom) [Кол-во] 
  from dbo.PrintLog p 
  inner join dbo.nc c on p.DatNom=c.datnom
  inner join dbo.marsh m on m.marsh=c.marsh and m.nd=c.nd
  inner join dbo.vehicle v on v.v_id=m.v_id
  where p.tip & 4 <> 0 
        and p.nd between @nd1 and dateadd(day,1,@nd2)
        and c.frizer=0
        and c.tara=0
        and c.actn=0
        and not c.marsh in (0,99)
  group by month(p.nd),iif(v.CrId=7,cast(1 as bit),cast(0 as bit))
  order by 1,2 desc
END