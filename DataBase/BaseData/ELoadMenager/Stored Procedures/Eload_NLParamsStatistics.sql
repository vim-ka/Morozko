CREATE PROCEDURE ELoadMenager.Eload_NLParamsStatistics
@nd1 datetime,
@nd2 datetime 
AS
BEGIN
	set nocount on
  if object_id('tempdb..#tmpMarsh') is not null  drop table #tmpMarsh

  select *
  into #tmpMarsh
  from (
  select cast(datepart(month,m.nd) as varchar)+' '+datename(month,m.nd)+' '+datename(year,m.nd) [nd] ,
         1 [m],
         cast((m.weight+m.dopweight) as decimal(15,0)) [w],
         m.dots [d],
         cast(sum(c.sp) as decimal(15,0)) [r],
         m.mhid
  from dbo.marsh m
  join dbo.vehicle v on m.v_id=v.v_id
  join dbo.nc c on c.mhid=m.mhid
  join dbo.defcontract dc on dc.dck=c.dck
  join dbo.agentlist a on a.ag_id=dc.ag_id
  where m.nd between @nd1 and @nd2 
        and not m.marsh in (0,99) 
        and m.SelfShip=0 
        and m.DelivCancel=0
        --and v.crid<>7
        and a.depid<>43
        and (m.listno<>0 or m.vedno<>0)
        and c.tara=0 
        and c.frizer=0  
        and c.stip<>4
  group by cast(datepart(month,m.nd) as varchar)+' '+datename(month,m.nd)+' '+datename(year,m.nd),m.mhid,cast((m.weight+m.dopweight) as decimal(15,0)),m.dots

  union 

  select cast(datepart(month,m.nd) as varchar)+' '+datename(month,m.nd)+' '+datename(year,m.nd) [Дата] ,
         1 [Маршрутов],
         cast((m.weight+m.dopweight) as decimal(15,0)) [Масса],
         m.dots [Точек],
         cast(sum(c.sp) as decimal(15,0)) [Реализация],
         m.mhid       
  from dbo.marsh m
  join dbo.vehicle v on m.v_id=v.v_id
  join dbo.nc c on c.mhid=m.mhid
  join dbo.defcontract dc on dc.dck=c.dck
  join dbo.agentlist a on a.ag_id=dc.ag_id
  where m.nd between dateadd(year,-1,@nd1) and dateadd(year,-1,@nd2) 
        and not m.marsh in (0,99) 
        and m.SelfShip=0 
        and m.DelivCancel=0
        --and v.crid<>7
        and a.depid<>43
        and (m.listno<>0 or m.vedno<>0)
        and c.tara=0 
        and c.frizer=0  
        and c.stip<>4
  group by cast(datepart(month,m.nd) as varchar)+' '+datename(month,m.nd)+' '+datename(year,m.nd),m.mhid,cast((m.weight+m.dopweight) as decimal(15,0)),m.dots) x

  alter table #tmpMarsh add Cost money
                            
  update m set m.Cost=IIF(isnull(lpd.[OplataSum],0)=0,isnull(mod.[OplataSum],0),isnull(lpd.[OplataSum],0))
  from #tmpMarsh m
  left join dbo.[MarshOplDet] [mod] ON [m].[mhid] = [mod].[mhid]
  left join [NearLogistic].[nlListPayDet] [lpd] ON [m].[mhid] = [lpd].[mhid]

  select nd [Дата],
         sum(m) [Маршрутов],
         sum(w) [Масса],
         sum(d) [Точек],
         sum(r) [Реализация],
         cast(sum(cost) AS decimal(15,0)) [Затраты] 
  from #tmpMarsh
  group BY nd

  if object_id('tempdb..#tmpMarsh') is not null  drop table #tmpMarsh
  set nocount off
END