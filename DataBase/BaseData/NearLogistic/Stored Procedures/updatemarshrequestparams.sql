CREATE procedure NearLogistic.updatemarshrequestparams
@mhids varchar(5000),
@nd datetime
with recompile
as
begin
--set @mhids=''
--set @nd=dateadd(day,-1,@nd)
set nocount on
if object_id('tempdb..#reqs') is not null drop table #reqs
if object_id('tempdb..#mrs') is not null drop table #mrs
--подготовка временных структур
create table #reqs (mhid int, reqid int, reqtype int, pin int, sp money, marja money, wgh decimal(15,2), vol decimal(17,4), box decimal(15,2), mas18 decimal(15,2), point_id int)
create table #mrs (mhid int, dots int, sp money, marja money, earnings money, wgh decimal(15,2), vol decimal(17,6), driver varchar(80), kolbox decimal(15,2))
create nonclustered index mrs_idx on #mrs(mhid)
create nonclustered index reqs_idx on #reqs(mhid)
create nonclustered index reqs_idx1 on #reqs(reqid)
create nonclustered index reqs_idx2 on #reqs(reqtype)
--заполнение листа выбранных маршрутов
if isnull(@mhids,'')=''
	insert into #mrs(mhid)
	select mhid from dbo.marsh 
	where not marsh in (0,99) and selfship = 0
      	and delivcancel=0 and nd=convert(varchar,@nd,104)
else
	insert into #mrs(mhid)
  select number from dbo.string_to_int(@mhids,';',1)
--заполнение листа выбранных заявок  
insert into #reqs(mhid,reqid,reqtype)
select mhid, reqid, reqtype
from nearlogistic.marshrequests 
where mhid in (select a.mhid from #mrs a)

--обновление информации по доставке
update a set a.pin=x.pin, a.sp=x.sp, a.box=x.kolbox, 
						 a.marja=x.marja, a.wgh=x.wgh, a.vol=x.vol 
             ,a.mas18=x.mas18,
             a.point_id=x.point_id
from #reqs a 
join (
  select b.datnom, b.pin, sum(b.sp) [sp],
         sum(b.marja) [marja], sum(b.wgh) [wgh],
         sum(b.vol) [vol], sum(b.kolbox) [kolbox]
         ,sum(b.mas18) [mas18], b.point_id
  from (       
    --вычисление основной накладной
    select c.datnom,
           iif(c.b_id2>0,c.b_id2,c.b_id) [pin],
           sum(v.kol*v.price*(1+(c.extra/100))) [sp],

           sum(case when c.stip<>4 
                    --then (v.price*(1+(c.extra/100))-v.cost)*v.kol*100/(n.nds+100)
                    then (v.price*(1+(c.extra/100)))*v.kol*100/(n.nds+100)*0.03
           		      else 
                    case when z.nds=0 
                         then v.price*(v.kol-v.kol_b)*10/100               --z.ourperc/100
               			     else v.price*(v.kol-v.kol_b)*10/(n.nds+100)   --z.ourperc/(n.nds+100) 
                    end 
                end) [marja],

           sum(iif(n.flgweight=1,isnull(t.weight*v.kol,s.weight*v.kol),n.brutto*v.kol)) [wgh],
           sum(n.volminp * v.kol) [vol],
           sum(v.kol/iif(isnull(n.minp,0)=0,1,n.minp)) [kolbox]
           ,0 [mas18]--sum(iif(ms.min_term=-18,iif(n.flgweight=1,isnull(t.weight*v.kol,s.weight*v.kol),n.brutto*v.kol),0)) [mas18]
           ,d.pin as point_id--d.point_id
    from dbo.nc c
    join dbo.nv v with(nolock, index(nv_datnom_idx)) on c.datnom=v.datnom
    join dbo.nomen n on n.hitag=v.hitag
    join dbo.def d on d.pin=iif(c.b_id2>0,c.b_id2,c.b_id)
    join dbo.gr g on g.ngrp=n.ngrp
		join nearlogistic.masstype ms on ms.nlmt=g.nlmt_new
		left join dbo.tdvi t on t.id=v.tekid
    left join dbo.visual s on s.id=v.tekid
    left join (
      select dck,brmaster, nds, sum(ourperc) as ourperc 
      from dbo.defconappendix 
      group by dck,brmaster,nds
    ) z on iif(d.master>0, d.master, d.pin)=z.brmaster and isnull(t.dck,s.dck)=z.dck
    where c.datnom in (select reqid from #reqs where reqtype=0)
    group by c.datnom,iif(c.b_id2>0,c.b_id2,c.b_id),d.pin--d.point_id
    union all --вычисление добивки
    select c.refdatnom,
           iif(c.b_id2>0,c.b_id2,c.b_id) [pin],
           sum(v.kol*v.price*(1+(c.extra/100))) [sp],

           sum(case when c.stip<>4 
                    --then (v.price*(1+(c.extra/100))-v.cost)*v.kol*100/(n.nds+100)
                      then (v.price*(1+(c.extra/100)))*v.kol*100/(n.nds+100)*0.03
           		      else 
                    case when z.nds=0 
                         then v.price*(v.kol-v.kol_b)*10/100               --z.ourperc/100
               			     else v.price*(v.kol-v.kol_b)*10/(n.nds+100)   --z.ourperc/(n.nds+100) 
                end end) [marja],

           sum(iif(n.flgweight=1,isnull(t.weight*v.kol,s.weight*v.kol),n.brutto*v.kol)) [wgh],
           sum(n.volminp * v.kol) [vol],
           sum(v.kol/iif(isnull(n.minp,0)=0,1,n.minp)) [kolbox]
           ,0--sum(iif(ms.min_term=-18,iif(n.flgweight=1,isnull(t.weight*v.kol,s.weight*v.kol),n.brutto*v.kol),0)) [mas18]
           , d.pin--d.point_id
    from dbo.nc c
    join dbo.nv v with(nolock, index(nv_datnom_idx)) on c.datnom=v.datnom
    join dbo.nomen n on n.hitag=v.hitag
    join dbo.def d on d.pin=iif(c.b_id2>0,c.b_id2,c.b_id)
    join dbo.gr g on g.ngrp=n.ngrp
		join nearlogistic.masstype ms on ms.nlmt=g.nlmt_new
		left join dbo.tdvi t on t.id=v.tekid
    left join dbo.visual s on s.id=v.tekid
    left join (
      select dck,brmaster, nds, sum(ourperc) as ourperc 
      from dbo.defconappendix 
      group by dck,brmaster,nds
    ) z on iif(d.master>0, d.master, d.pin)=z.brmaster and isnull(t.dck,s.dck)=z.dck
    where c.refdatnom in (select reqid from #reqs where reqtype=0)
          and c.sp>0
    group by c.refdatnom,iif(c.b_id2>0,c.b_id2,c.b_id),d.pin--d.point_id            
    union all --вычисление заявки    
    select c.datnom,
           iif(c.b_id2>0,c.b_id2,c.b_id) [pin],
           sum(v.zakaz*v.price*(1+(c.extra/100))*iif(n.flgweight=1,n.netto,1)) [sp],
           --sum((v.zakaz*v.price*(1+(c.extra/100))-v.zakaz*v.cost)*iif(n.flgweight=1,n.netto,1)*100/(n.nds+100)) [marja],
           sum(v.zakaz*v.price*(1+(c.extra/100))*iif(n.flgweight=1,n.netto,1)*100/(n.nds+100))*0.03 [marja], 
           sum(v.zakaz*n.netto) [wgh],
           sum(n.volminp * v.zakaz) [vol],
           sum(v.zakaz*n.netto/iif(isnull(n.minp,0)=0,1,n.minp)) [kolbox]
           ,0--sum(iif(ms.min_term=-18,v.zakaz*n.netto,0)) [mas18]
           ,d.pin--d.point_id
    from dbo.nc c
    join dbo.nvzakaz v on c.datnom=v.datnom
    join dbo.def d on d.pin=iif(c.b_id2>0,c.b_id2,c.b_id)
    join dbo.nomen n on n.hitag=v.hitag
    join dbo.gr g on g.ngrp=n.ngrp
		join nearlogistic.masstype ms on ms.nlmt=g.nlmt_new
		where c.datnom in (select reqid from #reqs where reqtype=0)      
          and v.done=0 and v.zakaz>0
    group by c.datnom,iif(c.b_id2>0,c.b_id2,c.b_id),d.pin--d.point_id 
  ) b
group by b.datnom, b.pin, b.point_id 
) x on x.datnom=a.reqid

--обновление информации по возвратам
update a set a.pin=x.pin, a.box=x.kolbox, 
						 a.wgh=x.wgh, a.vol=x.vol
from #reqs a 
join (
  select d.reqretid [reqID],
         r.pin,
         sum(d.fact_weight) [wgh],
         sum((n.volminp / n.minp)*d.kol) [vol],
         sum(d.kol/iif(isnull(n.minp,0)=0,1,n.minp)) [kolbox]
  from dbo.reqreturndet d
  join dbo.reqreturn r on r.reqnum=d.reqretid
  join dbo.nomen n on n.hitag=d.hitag
  where d.reqretid in (select reqid from #reqs where reqtype=1)
  group by d.reqretid,r.pin
) x on x.reqid=a.reqid

--обновление информации по холодильникам
update a set a.pin=x.pin, a.box=x.kolbox, 
						 a.wgh=x.wgh, a.vol=x.vol,
             a.point_id=x.point_id
from #reqs a 
join (
  select i.frizreqid [reqID],
         iif(f.rneedact=3,f.rtpcode2,f.rtpcode) [pin],
         sum(ml.weight) [wgh],
         sum(ml.VolumeBox) [vol],
         count(distinct z.nom) [kolbox],
         d.point_id
  from dbo.frizrequestinvnom i
  join dbo.FrizRequest f on f.rcmplxid=i.frizreqid
  join dbo.def d on d.pin=iif(f.rneedact=3,f.rtpcode2,f.rtpcode)
  join dbo.frizer z on z.nom=i.frizernom
  join dbo.FrizerModel ml on z.FMod=ml.FMod 
  where i.frizreqid in (select reqid from #reqs where reqtype=2) 
  group by i.frizreqid,iif(f.rneedact=3,f.rtpcode2,f.rtpcode),d.point_id
) x on x.reqid=a.reqid

--обновление информации по забору товара
update a set a.pin=x.pin, a.box=x.kolbox, 
						 a.wgh=x.wgh, a.vol=x.vol, a.sp=x.sp,
             a.point_id=x.point_id
from #reqs a 
join (  
	select od.ordid [reqid],
         o.summaprice [sp],         
         sum(n.brutto*od.Qty) [wgh],
         sum((n.volminp / n.minp)*od.Qty) [vol],
         sum(ceiling(od.Qty/iif(isnull(n.minp,0)=0,1,n.minp))) [kolbox],
         o.pin, d.point_id
  from dbo.orders o
  join dbo.def d on d.pin=o.pin
  inner join dbo.orddet od on o.ordid=od.ordid
  join dbo.nomen n on n.hitag=od.hitag
  where od.ordid in (select reqid from #reqs where reqtype=5)
  group by od.OrdID,o.summaprice,o.pin,d.point_id
) x on x.reqid=a.reqid

--обновление информации по свободной заявке
update a set a.pin=x.pin, a.box=x.kolbox, 
						 a.wgh=x.wgh, a.vol=x.vol, a.sp=x.sp,
             a.point_id=x.point_id,
             a.marja = x.req_pay 
from #reqs a 
join (  
  select mf.mrfID [reqid], mf.cost [sp],         
         mf.weight [wgh], mf.volume [vol],
         mf.kolbox, mf.pin, d.point_id,
         cast(ISNULL(bs.req_pay,0)/mm.cnt as decimal(14,5)) as [req_pay]
  from NearLogistic.MarshRequests_free mf
  join NearLogistic.marshrequestsdet d on d.mrfid=mf.mrfID and d.action_id=6
  left join (select sum(bs.req_pay) as req_pay, bs.mhid from NearLogistic.billsSum bs group by bs.mhid) bs ON mf.mhID = bs.mhid  
  left join (select mf.mhid,count(mf.mrfid) as cnt 
             from NearLogistic.MarshRequests_free mf join NearLogistic.marshrequestsdet d on d.mrfid=mf.mrfID and d.action_id=6
             group by mf.mhid) mm on mm.mhid=mf.mhid
  where mf.mrfID in (select reqid from #reqs where reqtype=-2)
) x on x.reqid=a.reqid

--зануляю маршруты с неоплачиваемыми рейсами
update #reqs set marja=isnull(marja,0),sp=isnull(sp,0),wgh=isnull(wgh,0),vol=isnull(vol,0),box=isnull(box,0) 
--обновляю инфо по маршрутам

--select * from #reqs;
update a set a.dots=x.dots, a.sp=x.sp, a.marja=x.marja,
						 a.wgh=x.wgh, a.vol=x.vol, a.kolbox=x.[kolbox]
             ,a.driver=iif(x.mas18=0,'','['+format(x.mas18,'N')+' кг]')
             ,a.earnings=x.marja-[nearlogistic].marsh1calcfact(a.mhid,1,0.0)--[nearlogistic].marsh1otherexpense(a.mhid)
from #mrs a
join (
  select mhid, count(distinct point_id) [dots],
         sum(sp) [sp], sum(marja) [marja],
         sum(wgh) [wgh], sum(vol) [vol],
         sum(mas18) [mas18], sum(box) [kolbox]
  from #reqs 
  where reqtype in (-2,0,2,5,1)
  group by mhid
) x on x.mhid=a.mhid

--зануляю маршруты с неоплачиваемыми рейсами
update #mrs set dots=isnull(dots,0),marja=isnull(marja,0),
								sp=isnull(sp,0),wgh=isnull(wgh,0),vol=isnull(vol,0),
                earnings=isnull(earnings,0)

--select * from #mrs;
update mr set mr.weight_=r.wgh, mr.volume_=r.vol, mr.kolbox_=r.box, mr.cost_=r.sp
from nearlogistic.marshrequests mr
inner join #reqs r on r.reqid=mr.reqid and r.reqtype=mr.reqtype

update m set m.weight=a.wgh, m.volume=a.vol, m.dots=a.dots, m.earnings=a.earnings, 
			 m.driver=a.driver, m.boxqty=a.kolbox
from dbo.marsh m inner join #mrs a on a.mhid=m.mhid


if object_id('tempdb..#mrs') is not null drop table #mrs
if object_id('tempdb..#reqs') is not null drop table #reqs
set nocount off
end