CREATE PROCEDURE [ELoadMenager].[VendAllMoveCost] @Ncod int, @StartND datetime, @EndND datetime
AS
BEGIN
IF OBJECT_ID(N'tempdb..#comm', N'U') IS NOT NULL drop table #comm
IF OBJECT_ID(N'tempdb..#realiz7', N'U') IS NOT NULL drop table #realiz7
IF OBJECT_ID(N'tempdb..#realizAll', N'U') IS NOT NULL drop table #realizAll
IF OBJECT_ID(N'tempdb..#Snyat', N'U') IS NOT NULL drop table #Snyat
IF OBJECT_ID(N'tempdb..#Spis', N'U') IS NOT NULL drop table #Spis
IF OBJECT_ID(N'tempdb..#BonusAll', N'U') IS NOT NULL drop table #BonusAll
    
declare @dn0 int, @dn1 int

set @dn0 = dbo.InDatNom(0000, @StartND)
set @dn1 = dbo.InDatNom(9999, @EndND)    

create table #Main (FYear int, FMonth int, hitag int, name varchar(100), kginp real, kg7 real, kgAll real, kgbonus real, kgsnyat real, kgspis real)

create table #TYear (y int)
insert into #TYear (y) values (2017)

create table #TMonth (m int)

insert into #TMonth (m) values (1)
insert into #TMonth (m) values (2)
insert into #TMonth (m) values (3)
insert into #TMonth (m) values (4)
insert into #TMonth (m) values (5)
insert into #TMonth (m) values (6)
insert into #TMonth (m) values (7)

insert into #Main(FYear, FMonth, hitag)
select distinct y.y, m.m, v.hitag from nc c join nv v on c.datnom=v.datnom
                                   join visual i on v.tekid=i.id 
                                   join defcontract d on i.dck=d.dck,
                                   #TYear y, #TMonth m
where c.datnom>=@dn0 and c.datnom<=@dn1 and i.ncod=@ncod and d.contrtip=1 

select year(c.date) as Y,month(c.date) as M, i.hitag ,sum(i.kol*i.cost) as KGInp
into #comm
from comman c join inpdet i on c.ncom=i.ncom 
              join nomen n on i.hitag=n.hitag 
              join defcontract d on c.dck=d.dck
where c.ncod=@Ncod and c.date>=@StartND and d.contrtip=1
group by i.hitag, month(c.date), year(c.date)

select year(c.nd) as Y,month(c.nd) as M,v.hitag, sum(v.kol*iif(t.cost is null,i.cost,t.cost)) as Kg7
into #realiz7
from nc c join nv v on v.datnom=c.datnom
          join visual i on v.tekid=i.id
          left join inpdet t on i.startid=t.id
          join nomen n on v.hitag=n.hitag
where c.datnom>@dn0 and i.ncod=@Ncod and c.ourid=7 and c.stip=0
group by v.hitag, year(c.nd), month(c.nd)

select year(c.nd) as Y,month(c.nd) as M,v.hitag,sum(v.kol*iif(t.cost is null,i.cost,t.cost)) as KgAll
into #realizAll
from nc c join nv v on v.datnom=c.datnom
          join visual i on v.tekid=i.id
          left join inpdet t on i.startid=t.id
          join nomen n on v.hitag=n.hitag
where c.datnom>@dn0 and i.ncod=@Ncod and c.ourid<>7  and c.stip=0
group by v.hitag, year(c.nd), month(c.nd)


select year(c.nd) as Y,month(c.nd) as M,v.hitag,sum(v.kol*iif(t.cost is null,i.cost,t.cost)) as KgBonus
into #BonusAll
from nc c join nv v on v.datnom=c.datnom
          join visual i on v.tekid=i.id
          left join inpdet t on i.startid=t.id
          join nomen n on v.hitag=n.hitag
where c.datnom>@dn0 and i.ncod=@Ncod and c.stip in (1,2,3)
group by v.hitag, year(c.nd), month(c.nd)

select year(z.nd) as Y,month(z.nd) as M,z.hitag,sum((z.kol-z.newkol)*iif(t.cost is null,i.cost,t.cost)) as KgSnyat
into #Snyat
from izmen z join visual i on z.id=i.id
             left join inpdet t on i.startid=t.id
             join nomen n on z.hitag=n.hitag
             join defcontract d on z.dck=d.dck
where z.nd>=@StartND and z.nd<=@EndND and i.ncod=@Ncod and z.act='Снят' and d.ContrTip=1
group by z.hitag, year(z.nd), month(z.nd)

select year(z.nd) as Y,month(z.nd) as M,z.hitag,sum((z.kol-z.newkol)*iif(t.cost is null,i.cost,t.cost)) as KgIspr
into #Spis
from izmen z join visual i on z.id=i.id
             left join inpdet t on i.startid=t.id 
             join nomen n on z.hitag=n.hitag
             join defcontract d on z.dck=d.dck
where z.nd>=@StartND and z.nd<=@EndND and i.ncod=@Ncod and z.act='Испр' and d.ContrTip=1
group by z.hitag, year(z.nd), month(z.nd)

--(FYear int, FMonth int, hitag int, name varchar(30), kginp real, kg7 real, kg8 real, kgbonus real, kgsnyat real, kgspis real)


update #Main set kginp=c.KGInp from #comm c join #Main m on m.FYear=c.Y and m.FMonth=c.M and m.hitag=c.hitag
update #Main set kg7=c.Kg7 from #realiz7 c join #Main m on m.FYear=c.Y and m.FMonth=c.M and m.hitag=c.hitag
update #Main set kgAll=c.KgAll from #realizAll c join #Main m on m.FYear=c.Y and m.FMonth=c.M and m.hitag=c.hitag
update #Main set kgbonus=c.KGBonus from #BonusAll c join #Main m on m.FYear=c.Y and m.FMonth=c.M and m.hitag=c.hitag
update #Main set kgsnyat=c.KGSnyat from #Snyat c join #Main m on m.FYear=c.Y and m.FMonth=c.M and m.hitag=c.hitag
update #Main set kgspis=c.KGIspr from #Spis c join #Main m on m.FYear=c.Y and m.FMonth=c.M and m.hitag=c.hitag
update #Main set name=c.name from nomen c join #Main m on m.hitag=c.hitag


select FYear as 'Год', FMonth as 'Месяц', hitag as 'Код', name as 'Наименование', 
       isnull(kginp,0) as 'Приход',
       isnull(kg7,0) as 'Продажа 7', 
       isnull(kgAll,0) as 'Продажа остальные', 
       isnull(kgbonus,0) as 'Бонус', 
       isnull(kgsnyat,0) as 'Возврат поставщику',
       isnull(kgspis,0) as 'Cписание'
from #Main
order by FYear, FMonth, hitag
                                            

END