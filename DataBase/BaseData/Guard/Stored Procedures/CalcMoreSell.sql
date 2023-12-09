CREATE procedure Guard.CalcMoreSell
  @day0 datetime, @day1 datetime, @day2 datetime, @day3 datetime,
  @Koeff decimal(7,2), @minBaseProd decimal(10,2)=100.0
as
declare @per1 int, @per2 int
begin
  set @per1=1+DATEDIFF(day, @day0, @day1)
  set @per2=1+DATEDIFF(day, @day2, @day3)

  create table #t1 (dck int, sp1 decimal(12,2));

  insert into #t1
    select nc.dck, sum(nc.SP)/@per1*7.0 as SP
    from
    nc
    where
    nd between @day0 and @day1
    and actn=0
    group by nc.dck;


  create table #t2 (dck int, sp2 decimal(12,2));

  insert into #t2
  select dck, sum(sp)/@per1*7.0
  from nc
  where nd between @day2 and @day3 and actn=0
  group by dck;


  select  a.depid, deps.dname, #t2.*, isnull(#t1.sp1,0) as sp1, 
    -- round(#t2.sp2/#t1.sp1,2) as K,
    dc.pin, def.brname, def.gpAddr
  from
    #t2
    left join #t1 on #t1.dck=#t2.dck
    inner join defcontract dc on dc.dck=#t2.dck
    inner join def on def.pin=dc.pin
    inner join agentlist a on a.ag_id=dc.ag_id
    inner join Deps on Deps.depid=a.depid
  where
    #t2.sp2>0 and #t2.sp2 >= @Koeff*isnull(#t1.sp1,0)
    and isnull(#t1.sp1,0) >= @MinBaseProd
  order by a.depid, def.brname
  
end;