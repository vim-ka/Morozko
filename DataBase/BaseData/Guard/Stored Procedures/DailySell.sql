create procedure Guard.DailySell @Day0 datetime, @AgList varchar(3000)
as
begin
  if object_id('tempdb..#t') is not null drop table #t;
  
  create table #t (ag_id int, b_id int, gpname varchar(200), Sell7day decimal(10,2), WholeAgent bit default 1)
  
  insert into #t(ag_id,b_id,gpname,sell7day)
    select nc.ag_id, nc.b_id, d.gpname, sum(nc.sp) as Sell7day
    from NC inner join def d on d.pin=nc.b_id
    where
      nc.nd = @Day0
      and nc.ag_id  in (select K from dbo.str2intarray(@agList))
      and nc.actn=0
      and nc.sp>0
    group by
      nc.ag_id, nc.b_id, d.gpname;
  
  insert into #t(ag_id,b_id,gpname,sell7day)
    select distinct k2.op-1000 as Ag_id, k.b_id, k.fam, 0.00 as Sell7day
    from
      kassa1 k
      inner join kassa1 k2 on k2.kassid=k.kassid+1
    WHERE
      k.nd=@day0
      and k.oper=-2 and k2.oper=59
      and k2.op-1000 in (select K from dbo.str2intarray(@agList))
      and k.b_id not in (select distinct b_id from #t);
  
  insert into #t(ag_id,b_id,gpname,sell7day)
    select distinct f.ag_id, f.b_id, def.gpname, 0 as sell7day
    from
      guard.FMonitor f
      inner join def on def.pin=f.b_id
    where
      f.saveday=@day0
      and f.ag_id  in (select K from dbo.str2intarray(@agList))
      and f.b_id not in (select distinct b_id from #t);
  
  -- Сделаем список привязок агентов к отдельным точкам:
  if object_id('tempdb..#D') is not null drop table #D;
  create table #D(ag_id int, pin int);

  insert into #d(ag_id,pin) 
    select distinct
    c.SourAG_ID as AG_ID, Dc.pin
    from 
      guard.chaindet D
      inner join guard.Chain C on C.chid=D.ChID
      inner join DefContract dc on dc.dck=d.dck
    WHERE
      c.day0<=@day0 and c.day1>=@day0;
  update #t set WholeAgent=0 from #t inner join #D on #d.ag_id=#T.Ag_ID;

  -- select * from #d;
  -- select * from #t order by ag_id, b_id;

  delete from #t where WholeAgent=0 and b_id not in (select pin from #d);

  select * from #t order by ag_id, b_id;

end;