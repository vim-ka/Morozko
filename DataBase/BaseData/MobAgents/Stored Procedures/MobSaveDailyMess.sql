CREATE PROCEDURE MobAgents.MobSaveDailyMess  with recompile
AS
BEGIN
 declare @ND datetime, @StartND datetime, @NumND int
 set @ND=dbo.today()
 set @StartND=DATEADD(DAY,-DAY(@ND)+1,@ND)
 set @NumND=DATEPART(WEEKDAY, @ND)


  -- Отдельная таблица для супервайзеров Сенюшкина и Сафонова:
  if Object_ID('tempdb..#sv56') is not null drop table #sv56;
  create table #sv56(ag_id int, pin int, dck int);
  insert into #sv56
    select v.ag_id, v.pin, v.dck
    from 
      planvisit2 v
      inner join agentlist a on a.ag_id=v.ag_id
    where 
      v.dn=@NumND
      and a.sv_ag_id in (56,73);    


  -- Две временных таблицы для мерчендайзеров (отд.37), вторая будет использоваться вместо PlanVisit2:

  if Object_ID('tempdb..#z') is not null drop table #z;
  create table #z(ag_id int, pin int, dck int);
  insert into #z
    select v.ag_id, v.pin, v.dck
    from 
        planvisit2 v
        inner join agentlist a on a.ag_id=v.ag_id
    where 
      v.dn=@NumND
      and a.DepID=37;
  -- select * from #z order by #t.ag_id;
  if Object_ID('tempdb..#u') is not null drop table #u;
  create table #u(ag_id int, pin int, dck int);
  insert into #u select #z.ag_id, dc.pin, dc.dck from defcontract dc inner join #z on #z.pin=dc.pin order by #z.ag_id;
  -- select * from #u;

  /*declare @datnom int
  declare @FirmGroup int
  declare @Our_id int
 
  set @Our_id=isnull((select p.our_id 
                      from person p join agentlist a on p.p_id=a.p_id
                      where a.ag_id=@ag_id),7)
  
  
  set @datnom=dbo.InDatNom(0,@ND)
  set @FirmGroup=(select f.FirmGroup from FirmsConfig f where f.Our_id=@Our_id)
  */
--проверка остатков
  if object_id('tempdb..#t') is not null drop table #t

  create table #t (b_id int, gpname varchar(100), ag_id int,StopDate datetime);
  
  insert into #t
  select distinct nc.B_ID, def.gpname, dc.ag_id, @ND
  from 
    nc 
    inner join DefContract dc on dc.dck=nc.dck and dc.ContrTip=2
    inner join Def on Def.pin=dc.pin and def.tip=1
  where nc.sp+nc.izmen-nc.fact>0 and nc.srok>0
  and nc.Nd+NC.srok+5=@ND;
  
  insert into #t
  select distinct nc.B_ID, def.gpname, dc.ag_id,@ND+1 
  from 
    nc 
    inner join DefContract dc on dc.dck=nc.dck and dc.ContrTip=2
    inner join Def on Def.pin=dc.pin and def.tip=1
  where nc.sp+nc.izmen-nc.fact>0 and nc.srok>0
  and nc.Nd+NC.srok+5=@ND+1
  and nc.b_id not in (select b_id from #t);
  
  insert into #t
  select distinct nc.B_ID, def.gpname,dc.ag_id, @ND+2
  from 
    nc 
    inner join DefContract dc on dc.dck=nc.dck and dc.ContrTip=2
    inner join Def on Def.pin=dc.pin and def.tip=1
  where nc.sp+nc.izmen-nc.fact>0 and nc.srok>0
  and nc.Nd+NC.srok+5=@ND+2
  and nc.b_id not in (select b_id from #t);
  
  if object_id('tempdb..#k') is not null drop table #k
  
  create table #k(ag_id int, 
    SP decimal(12,2) default 0, 
    Plata decimal(12,2) default 0, 
    Overdue decimal(12,2) default 0);
  
  -- Продажи за период с начала месяца:
  insert into #k(ag_id, sp)  
  select dc.ag_id, sum(nc.sp) as SP
  from 
    nc
    inner join defcontract dc on dc.DCK=nc.DCK
  where 
    nc.srok>0 and nc.nd between @StartND and @ND
  group by dc.ag_id
    
-- Выплаты за период:
  insert into #k(ag_id, Plata)  
  select dc.ag_id, sum(k.plata) as Plata
  from 
    kassa1 k
    inner join nc on nc.datnom=k.sourdatnom
    inner join defcontract dc on dc.DCK=nc.DCK
  where 
    k.oper=-2
    and k.nd between @StartND and @ND
  group by dc.ag_id  


  -- Просроченная дебиторка:
  insert into #k(ag_id, Overdue)  
  SELECT
    dc.ag_id, sum(nc.sp-nc.fact+nc.Izmen) as Overdue
  from 
    nc inner join DefContract dc on dc.dck=nc.DCK
  where
    nc.srok>0 and nc.sp-nc.fact+nc.Izmen>0
    and nc.nd+nc.Srok<=@ND
  group by dc.ag_id


--информация о продажах, оплатах, дебиторке

select 10 as Tip, #k.ag_id as ag_id, 0 as pin, L.Agent as gpName,0 as hitag, L.ServerName as name,null as ND, sum(#k.SP) SP, sum(#k.Plata) Plata, sum(#k.Overdue) Overdue,  L.FolderName
from #k inner join Agentlist L on L.AG_ID=#k.ag_id
where #k.ag_id>0 and #k.ag_id not in (401,402,403,404,405,406)
group by #k.ag_id, L.Agent, L.ServerName, L.FolderName

UNION
-- просрочка  
select 20 as Tip,t.ag_id, t.b_id as pin, t.gpName, 0 as hitag, '' as name, t.Stopdate as ND, 0 as SP,0 as Plata, 0 as OverDue, '' as FolderName
from #t t where t.ag_id>0 

UNION
--проверка остатков
select distinct 30 as Tip, f.ag_id, d.pin, d.gpName, v.hitag, n.name, null as ND, 0 as SP,0 as Plata, 0 as OverDue, '' as FolderName 
from  nc c join nv v on c.datnom=v.datnom
           join nomen n on v.hitag=n.hitag
           join defcontract f on c.dck=f.dck
           join def d on f.pin=d.pin
where c.nd=@ND-30 and n.ngrp=74 and v.kol-v.kol_b>0 and f.ag_id>0 

UNION

--проверка остатков и уценка
select distinct 40 as Tip, f.ag_id, d.pin, d.gpName, v.hitag, n.name, null as ND, 0 as SP,0 as Plata, 0 as OverDue, '' as FolderName  
from  nc c join nv v on c.datnom=v.datnom
           join nomen n on v.hitag=n.hitag
           join defcontract f on c.dck=f.dck
           join def d on f.pin=d.pin
where c.nd=@ND-60 and n.ngrp=74 and v.kol-v.kol_b>0 and f.ag_id>0 

UNION
  select e.tip, e.ag_id, e.pin, e.gpname,e.hitag,e.name, min(e.nd) nd, e.sp, e.plata,sum(e.OverDue) OverDue,FolderName
  from ( -- заявка на возврат порезанной на куски колбасы, добавлено 21.12.2017:
    select 
      50 as tip, r.ag_id, dc.pin, def.gpname,  R.Hitag, 
      a.ServerName as name, R.NeedDay as nd, CAST(0.0 as money) as SP, CAST(0.0 as money) as Plata,
      -1.0 as OverDue,
      a.FolderNameBackup as FolderName  
    from 
      Rests R
      inner join Defcontract DC on DC.DCK=R.DCK
      inner join Def on Def.pin=DC.pin
      inner join AgentList A on A.ag_id=R.ag_id
    where R.NeedDay=dbo.today()-2 and r.Qty=0 and R.Weight=0.500 

    UNION 

    -- Заявка на возврат ликвида колбасы Царицыно и Микоян для супервайзеров Сенюшкина и Сафонова:
    select distinct 50 as Tip, dc.ag_id, c.dck as pin, d.gpName, v.hitag, a.ServerName as name, 
    c.nd as ND, 777.00 as SP, CAST(0.0 as money) as Plata, 1.0*(v.kol-v.kol_b)*iif(i.weight=0,1,i.weight) as OverDue, 
    a.FolderNameBackup as FolderName
    from  
      nc c 
      join nv v on c.datnom=v.datnom
      join nomen n on v.hitag=n.hitag
      join visual i on v.tekid=i.id
      join gr g on n.ngrp=g.ngrp
      join (select c.dck as dck, c.ag_id as ag_id, c.pin from defcontract c 
           union
           select b.add_dck as dck, b.ag_id as ag_id, d.pin from agaddbases b join defcontract d on b.add_dck=d.dck 
             where b.add_dck<>0
           union
           select  d.dck as dck, b.ag_id as ag_id, d.pin  from agaddbases b join defcontract d on b.add_ag_id=d.ag_id 
  	         where b.add_ag_id<>0
           ) dc on c.dck=dc.dck               
      join #sv56 pl on dc.ag_id=pl.ag_id and dc.pin=pl.pin
      join def d on dc.pin=d.pin
      join agentlist a on dc.ag_id=a.ag_id
    where
      c.ND>=@nd-200
      and v.kol-v.kol_b>0 
      and i.srokh <= @ND -- это важно! 
      and dc.ag_id>0 and srokh>=@nd-6

   UNION

    -- Автозаявка на возврат
    -- Для 37 отдела вместо PlanVisit2 будет использована таблица #U:
    select distinct 50 as Tip, dc.ag_id, c.dck as pin, d.gpName, v.hitag, a.ServerName as name, 
    c.nd as ND, CAST(0.0 as money) as SP, CAST(0.0 as money) as Plata, 1.0*(v.kol-v.kol_b)*iif(i.weight=0,1,i.weight) as OverDue, 
    a.FolderNameBackup as FolderName  
    from  
      nc c 
      join nv v on c.datnom=v.datnom
      join nomen n on v.hitag=n.hitag
      join visual i on v.tekid=i.id
      -- join gr g on iif(dbo.GetGrOnlyParent(n.ngrp) is null, n.ngrp,dbo.GetGrOnlyParent(n.ngrp))=g.ngrp
      join gr g on n.ngrp=g.ngrp
      join (select c.dck as dck, c.ag_id as ag_id, c.pin from defcontract c 
            union
           select b.add_dck as dck, b.ag_id as ag_id, d.pin from agaddbases b join defcontract d on b.add_dck=d.dck 
            where b.add_dck<>0
            union
           select  d.dck as dck, b.ag_id as ag_id, d.pin  from agaddbases b join defcontract d on b.add_ag_id=d.ag_id 
           where b.add_ag_id<>0
           ) dc on c.dck=dc.dck               
      join #U pl on dc.ag_id=pl.ag_id and dc.pin=pl.pin
      -- join defcontract f on c.dck=f.dck
      join def d on dc.pin=d.pin
      join agentlist a on dc.ag_id=a.ag_id
    where
      c.ND>=@nd-200
      and v.kol-v.kol_b>0 
      and i.srokh>@ND -- это важно! 
      and 
      (
        (a.DepID=37 and dc.ag_id>0 and n.ngrp in (77,78) and srokh<@nd+21) -- пресервы и салаты за 21 день
        or (a.DepID=37 and dc.ag_id>0 and n.ngrp not in (77,78) and srokh<@nd+6) -- прочее за 6 дней
      )

  UNION
    select distinct 50 as Tip, dc.ag_id, c.dck as pin, d.gpName, v.hitag, a.ServerName as name, 
    c.nd as ND, 777.00 as SP, CAST(0.0 as money) as Plata, 1.0*(v.kol-v.kol_b)*iif(i.weight=0,1,i.weight) as OverDue, 
    a.FolderNameBackup as FolderName  
    from  
      nc c 
      join nv v on c.datnom=v.datnom
      join nomen n on v.hitag=n.hitag
      join visual i on v.tekid=i.id
      -- join gr g on iif(dbo.GetGrOnlyParent(n.ngrp) is null, n.ngrp,dbo.GetGrOnlyParent(n.ngrp))=g.ngrp
      join gr g on n.ngrp=g.ngrp
      join (select c.dck as dck, c.ag_id as ag_id, c.pin from defcontract c 
            union
           select b.add_dck as dck, b.ag_id as ag_id, d.pin from agaddbases b join defcontract d on b.add_dck=d.dck 
            where b.add_dck<>0
            union
           select  d.dck as dck, b.ag_id as ag_id, d.pin  from agaddbases b join defcontract d on b.add_ag_id=d.ag_id 
           where b.add_ag_id<>0
           ) dc on c.dck=dc.dck               
      join #U pl on dc.ag_id=pl.ag_id and dc.pin=pl.pin
      -- join defcontract f on c.dck=f.dck
      join def d on dc.pin=d.pin
      join agentlist a on dc.ag_id=a.ag_id
    where
      c.ND>=@nd-200
      and v.kol-v.kol_b>0 
      and i.srokh <= @ND -- это важно! 
      and (a.DepID=37 and dc.ag_id>0 and srokh>=@nd-6 /*and g.ngrp in (44,85,91,92,96,105,107,120,122,124,125)*/)      -- Пикалова, колбаса и торты  
  

  UNION
  
    -- Для остальных агентов (кроме отд.37):
    select distinct 50 as Tip, dc.ag_id, c.dck as pin, d.gpName, v.hitag, a.ServerName as name, c.nd as ND, 
      CAST(0.0 as money) as SP, CAST(0.0 as money) as Plata, 1.0*(v.kol-v.kol_b)*iif(i.weight=0,1,i.weight) as OverDue, a.FolderNameBackup as FolderName  
    from  nc c join nv v on c.datnom=v.datnom
             join nomen n on v.hitag=n.hitag
             join visual i on v.tekid=i.id
             -- join gr g on iif(dbo.GetGrOnlyParent(n.ngrp) is null, n.ngrp,dbo.GetGrOnlyParent(n.ngrp))=g.ngrp
             join gr g on n.ngrp=g.ngrp
  
             join (select c.dck as dck, c.ag_id as ag_id, c.pin from defcontract c 
                    union
                   select b.add_dck as dck, b.ag_id as ag_id, d.pin from agaddbases b join defcontract d on b.add_dck=d.dck where b.add_dck<>0
                    union
                   select  d.dck as dck, b.ag_id as ag_id, d.pin  from agaddbases b join defcontract d on b.add_ag_id=d.ag_id where b.add_ag_id<>0) dc on c.dck=dc.dck
                       
             join planvisit2 pl on dc.ag_id=pl.ag_id and dc.pin=pl.pin
             -- join defcontract f on c.dck=f.dck
             join def d on dc.pin=d.pin
             join agentlist a on dc.ag_id=a.ag_id
    where -- Переделано 30.05.2017 - Виктор
      c.ND>=@nd-200
      and a.DepID<>37
      and pl.dn=@NumND   
      and v.kol-v.kol_b>0 
      and i.srokh >= @ND -- это важно! 
      and ((a.DepID=3 and dc.ag_id>0 and ((g.ngrp in (34) and DATEDIFF(day, c.nd, @ND)<=3))  
            or ((i.srokh<@nd+9 or DATEDIFF(day, c.ND, @ND)>=20) and v.hitag in (28715,28242,28241,28240,28583,28582)   ))--эпика 
          or (i.srokh<=@nd+6  and g.ngrp in (44,85,91,92,105,107,120,122,124,125)) -- колбаса  
          or (dc.ag_id in (13,486,706,828,957) and DATEDIFF(day, c.nd, @ND)<=4 and g.ngrp in (34))                   -- торты  
          or (a.DepID=37 and dc.ag_id>0 and srokh<@nd+6 and g.ngrp in (44,85,91,92,96,105,107,120,122,124,125))      -- Пикалова, колбаса и торты  
          or (a.DepID=4 and dc.ag_id>0 and srokh<@nd+5 and g.ngrp in  (44,85,91,92,105,107,120,122,124,125))         -- БИК колбаса
         ) 
          
   UNION
  
    -- Для остальных агентов (кроме отд.37):
    select distinct 50 as Tip, dc.ag_id, c.dck as pin, d.gpName, v.hitag, a.ServerName as name, c.nd as ND, 
      CAST(777.0 as money) as SP, CAST(0.0 as money) as Plata, 1.0*(v.kol-v.kol_b)*iif(i.weight=0,1,i.weight) as OverDue, a.FolderNameBackup as FolderName  
    from  nc c join nv v on c.datnom=v.datnom
             join nomen n on v.hitag=n.hitag
             join visual i on v.tekid=i.id
             -- join gr g on iif(dbo.GetGrOnlyParent(n.ngrp) is null, n.ngrp,dbo.GetGrOnlyParent(n.ngrp))=g.ngrp
             join gr g on n.ngrp=g.ngrp
  
             join (select c.dck as dck, c.ag_id as ag_id, c.pin from defcontract c 
                    union
                   select b.add_dck as dck, b.ag_id as ag_id, d.pin from agaddbases b join defcontract d on b.add_dck=d.dck where b.add_dck<>0
                    union
                   select  d.dck as dck, b.ag_id as ag_id, d.pin  from agaddbases b join defcontract d on b.add_ag_id=d.ag_id where b.add_ag_id<>0) dc on c.dck=dc.dck
                       
             join planvisit2 pl on dc.ag_id=pl.ag_id and dc.pin=pl.pin
             -- join defcontract f on c.dck=f.dck
             join def d on dc.pin=d.pin
             join agentlist a on dc.ag_id=a.ag_id
    where -- Переделано 30.05.2017 - Виктор
      c.ND>=@nd-200
      and a.DepID<>37
      and pl.dn=@NumND   
      and v.kol-v.kol_b>0 
      and (i.srokh<=@nd and i.srokh>=@nd-10 and g.ngrp in (44,85,91,92,105,107,120,122,124,125)) -- колбаса        

  ) E
  where e.ag_id not in (401,402,403,404,405,406)
 
   group by e.tip, e.ag_id, e.pin, e.gpname,e.hitag,e.name, e.sp, e.plata, e.FolderName


order by ag_id, Tip, pin, ND


END