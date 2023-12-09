CREATE PROCEDURE dbo.AgentPlan @AgID int, @date datetime
AS
BEGIN
/* declare @AgID int*/
/*set @AgID = 150*/

/*DECLARE @date datetime*/
/*set @date = GETDATE()*/

DECLARE @DayOfWeek varchar
set @DayOfWeek = (select datepart(dw, @date) )
/*select @DayOfWeek*/

DECLARE @Today datetime
set @Today = (SELECT CONVERT (varchar(11), @date, 112))

select p.pin as b_id, tm, d.brname as bname,
        (select convert(varchar(8),MIN(t.tm),108) from NC t where t.ND>=@Today and t.ag_id=@AgID and t.b_id=p.pin and t.sp>0) as factT,
        (select sum(tr.kol) from TaraDet tr where tr.B_ID=p.pin) as Tara, 
        (select convert(varchar(8),MIN(r.nd),108) from Rests r where r.nd>=@Today and r.ag_id=@AgID and r.pin=p.pin) as Audit,
        (select convert(varchar(8),MIN(a.nd),108) from AdvOrder a where a.nd>@Today and a.ag_id=@AgID and a.pin=p.pin) as AdvOrd,
        (select count(distinct ns.hitag) from notsat ns  where ns.nd>=@Today and ns.b_id=p.pin) as NeudSpr,
		isnull((select sum(ks.plata) from kassa1 ks where ks.nd>=@Today-7 and ks.b_id=p.pin and ks.act='ВЫ'),0) as Oplata,
        isnull((select sum(ks.plata) from kassa1 ks where ks.nd>=@Today and ks.b_id=p.pin and ks.act='ВЫ'),0) as OplataTod
from planvisit2 p,def d
where p.ag_id=@AgID and p.dn=@DayOfWeek and d.pin=p.pin and d.tip=1

union

select td.b_id as b_id,0 as tm,td.fam as bname,min(td.tm) as factT,
(select sum(tr.kol) from TaraDet tr where tr.B_ID=td.b_id) as Tara,
(select convert(varchar(8),MIN(r.nd),108) from Rests r where r.nd>=@Today and r.ag_id=@AgID and r.pin=td.b_id) as Audit,
(select convert(varchar(8),MIN(a.nd),108) from AdvOrder a where a.nd>=@Today and a.ag_id=@AgID and a.pin=td.b_id) as AdvOrd,
(select count(distinct ns.hitag)  from notsat ns  where ns.nd>=@Today and ns.b_id=td.b_id) as NeudSpr,
isnull((select sum(ks.plata) from kassa1 ks where ks.nd>=@Today-7 and ks.b_id=td.b_id and ks.act='ВЫ'),0) as Oplata,
isnull((select sum(ks.plata) from kassa1 ks where ks.nd>=@Today and ks.b_id=td.b_id and ks.act='ВЫ'),0) as OplataTod
from NC td
where td.ND>=@Today and td.ag_id=@AgID and td.sp>0 and td.b_id not IN (select p1.pin from planvisit2 p1 where ag_id=@AgID and dn=@DayOfWeek)
group by td.b_id,td.fam

union

select convert(int,a.pin) as b_id, Null as tm,d.brName as bname, Null as FactT,
(select sum(tr.kol) from TaraDet tr where tr.B_ID=a.pin) as Tara,
(select convert(varchar(8),MIN(r.nd),108) from Rests r where r.nd>=@Today and r.ag_id=@AgID and r.pin=a.pin) as Audit,
convert(varchar(8),MIN(a.nd),108) as AdvOrd,
(select count(distinct ns.hitag)  from notsat ns  where ns.nd>=@Today and ns.b_id=a.pin) as NeudSpr,
isnull((select sum(ks.plata) from kassa1 ks where ks.nd>=@Today-7 and ks.b_id=a.pin and ks.act='ВЫ'),0) as Oplata,
isnull((select sum(ks.plata) from kassa1 ks where ks.nd>=@Today and ks.b_id=a.pin and ks.act='ВЫ'),0) as OplataTod
from AdvOrder a, def d
where a.nd>=@Today and a.ag_id=@AgID and a.pin=d.pin and d.tip=1
and a.pin not in
(select p1.pin from planvisit2 p1 where ag_id=@AgID and dn=@DayOfWeek
union 
select distinct td.b_id from NC td where td.ND>=@Today and td.ag_id=@AgID)
group by a.pin, d.brName

union
select r.pin as b_id, Null as tm,d.brname,Null as factT,
(select sum(tr.kol) from TaraDet tr where tr.B_ID=r.pin) as Tara,
 convert(varchar(8),MIN(r.nd),108) as Audit,Null as AdvOrd,
(select count(distinct ns.hitag)  from notsat ns  where ns.nd>=@Today and ns.b_id=r.pin) as NeudSpr,
isnull((select sum(ks.plata) from kassa1 ks where ks.nd>=@Today-7 and ks.b_id=r.pin and ks.act='ВЫ'),0) as Oplata,
isnull((select sum(ks.plata) from kassa1 ks where ks.nd>=@Today and ks.b_id=r.pin and ks.act='ВЫ'),0) as OplataTod
from Rests r, def d
where r.nd>=@Today and r.ag_id=@AgID and r.pin=d.pin and d.tip=1
and r.pin not in
(select p1.pin from planvisit2 p1 where p1.ag_id=@AgID and
p1.dn=@DayOfWeek
 union 
 select distinct td.b_id from NC td where td.ND>=@Today and td.ag_id=@AgID
union 
select distinct a.pin from AdvOrder a where a.ag_id=@AgID)
group by r.pin,d.brname
order by FactT,b_id

/*  INNER JOIN dbo.Def ON (b_id = dbo.Def.pin)
WHERE
  dbo.def.tip=1*/

END