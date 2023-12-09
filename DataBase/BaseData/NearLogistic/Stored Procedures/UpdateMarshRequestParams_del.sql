CREATE PROCEDURE NearLogistic.UpdateMarshRequestParams_del
@mhIDs varchar(5000),
@nd datetime
AS
BEGIN
set nocount on
--if (@nd is null)or(abs(datediff(day,@nd,getdate()))<2)and(@mhIDs<>'')
begin  
if isnull(@mhids,'')=''
set @mhids=
  stuff(
         (select N';'+cast(m.mhid as varchar)
          from dbo.Marsh m
          where not m.Marsh in (0,99)
             and m.SelfShip = 0
                and m.DelivCancel=0
                and m.nd=@nd
          for xml path(''), type).value('.','varchar(max)'),1,1,''  
          )
          
if object_id('temdb..#marshs') is not null drop table #marshs
create table #marshs (mhID int not null,reqID int,reqType int,pin int)
insert into #marshs(mhID,reqID,reqType)
select si.number [mhID],
    mr.ReqID,
       mr.ReqType
from dbo.String_to_Int(@mhIDs,';',1) si
join NearLogistic.MarshRequests mr on mr.mhID=si.number

insert into #marshs(mhID,reqID,reqType)
select c.mhid, c.datnom, 0
from #marshs m
join dbo.nc c on c.refdatnom=m.reqid and m.reqtype=0 and c.sp>0 and c.mhid=m.mhid

create nonclustered index marshs_idx1 on #marshs(mhID)
create nonclustered index marshs_idx2 on #marshs(reqID)
create nonclustered index marshs_idx3 on #marshs(reqType)
alter table #marshs add cost decimal(15,2) not null default 0,
            weight decimal(15,2) not null default 0,
                        volume decimal(18,5) not null default 0,
                        kolbox decimal(15,2) not null default 0;

if object_id('tempdb..#computed_req') is not null drop table #computed_req

select * 
into #computed_req
from
(
  select iif(c.refdatnom>0 and c.sp>0,c.refdatnom,c.datnom) [ReqID],
         0 [reqType],
         sum(isnull(c.sp,0)) [cost],
         sum(iif(n.flgweight=0,n.brutto,isnull(t.weight,s.weight))*v.kol) [weight],
         sum((n.volminp / n.minp)*v.kol) [volume],
         sum(ceiling(v.kol/iif(isnull(n.minp,0)=0,1,n.minp))) [kolbox],
         iif(b_id2<>0,b_id2,b_id) [pin]
  from dbo.nc c    
  join dbo.nv v  with (nolock, index(nv_datnom_idx))  on c.datnom=v.datnom
  join #marshs x on x.mhid=c.mhid and x.reqID=c.datnom and x.reqType=0
  join dbo.nomen n on n.hitag=v.hitag
  left join dbo.tdvi t on t.id=v.tekid
  left join dbo.visual s on s.id=v.tekid
  group by iif(c.refdatnom>0 and c.sp>0,c.refdatnom,c.datnom),iif(b_id2<>0,b_id2,b_id)
  --having sum(ceiling(v.kol/iif(isnull(n.minp,0)=0,1,n.minp)))>0

  union all
  
  select iif(c.refdatnom>0 and c.sp>0,c.refdatnom,c.datnom) [ReqID],
         0 [reqType],
         c.sp [cost],
         sum(n.brutto*v.zakaz) [weight],
         sum((n.volminp / n.minp)*v.zakaz) [volume],
         sum(ceiling(v.zakaz/iif(isnull(n.minp,0)=0,1,n.minp))) [kolbox],
         iif(b_id2<>0,b_id2,b_id) [pin]
  from dbo.nc c    
  join dbo.nvzakaz v on c.datnom=v.datnom
  join #marshs x on x.mhid=c.mhid and x.reqID=c.datnom and x.reqType=0
  join dbo.nomen n on n.hitag=v.hitag
  where v.done=0 --and c.mhID in (select x.mhID from computed_mhID x)
  group by iif(c.refdatnom>0 and c.sp>0,c.refdatnom,c.datnom),c.sp,iif(b_id2<>0,b_id2,b_id)
  --having sum(ceiling(v.zakaz/iif(isnull(n.minp,0)=0,1,n.minp)))>0

  union all

  select d.reqretid [reqID],
         1 [reqType],
         0 [cost],
         sum(d.fact_weight) [weight],
         sum((n.volminp / n.minp)*d.kol) [volume],
         sum(ceiling(d.kol/iif(isnull(n.minp,0)=0,1,n.minp))) [kolbox],
         r.pin
  from dbo.reqreturndet d
  join dbo.ReqReturn r on r.reqnum=d.reqretid
  join #marshs x on x.mhid=r.mhid and x.reqID=r.reqnum and x.reqType=1
  join dbo.nomen n on n.hitag=d.hitag
  group by d.reqretid,r.pin
  --having sum(ceiling(d.kol/iif(isnull(n.minp,0)=0,1,n.minp)))>0

  union all   

  select i.frizreqid [reqID],
         2 [reqType],
         0 [cost],
         sum(ml.weight) [weight],
         sum(ml.VolumeBox) [volume],
         count(distinct z.nom) [kolbox],
         iif(f.rneedact=3,f.rtpcode2,f.rtpcode) [pin]
  from dbo.frizrequestinvnom i
  join dbo.FrizRequest f on f.rcmplxid=i.frizreqid
  join #marshs x on x.mhid=f.mhid and x.reqID=f.rcmplxid and x.reqType=2
  join dbo.frizer z on z.nom=i.frizernom
  join dbo.FrizerModel ml on z.FMod=ml.FMod  
  group by i.frizreqid,iif(f.rneedact=3,f.rtpcode2,f.rtpcode)
  --having count(distinct z.nom)>0

  union all 
  
  select od.ordid,
      5 [ReqType],
         o.summaprice,         
         sum(n.brutto*od.Qty) [weight],
         sum((n.volminp / n.minp)*od.Qty) [volume],
         sum(ceiling(od.Qty/iif(isnull(n.minp,0)=0,1,n.minp))) [kolbox],
         o.pin
  from dbo.orders o
  inner join dbo.orddet od on o.ordid=od.ordid
  join dbo.nomen n on n.hitag=od.hitag
  join #marshs x on x.mhid=o.mhid and x.reqID=od.ordid and x.reqType=5
  group by od.OrdID,o.summaprice,o.pin
  
  union all
  
  select mf.mrfID,
      -2 [ReqType],
         mf.cost,         
         mf.weight,
         mf.volume,
         mf.kolbox,
         mf.pin
  from NearLogistic.MarshRequests_free mf
  join #marshs x on x.mhid=mf.mhid and x.reqID=mf.mrfID and x.reqType=-2
) a

update s set s.cost=cr.cost,
       s.weight=isnull(cr.weight,0),
             s.volume=isnull(cr.volume,0),
             s.kolbox=isnull(cr.kolbox,0),
             s.pin=cr.pin
from #marshs s
join #computed_req cr on cr.reqID=s.reqID and cr.reqType=s.reqType


--select * from #marshs
--select * from #computed_req

--alter table NearLogistic.MarshRequests disable trigger trg_MarshRequests_u
update mr set mr.Cost_=isnull(m.cost,0),
       mr.Weight_=m.weight,
              mr.Volume_=m.volume,
              mr.KolBox_=m.kolbox
from NearLogistic.MarshRequests mr
join #marshs m on mr.mhid=m.mhid and mr.ReqID=m.reqID
--alter table NearLogistic.MarshRequests enable trigger trg_MarshRequests_u

select mhid,
    sum(weight) [weight],
       sum(volume) [volume],
       count(distinct dots) [dots],
       sum(marja) [marja]
into #MarshParams  
from (select x.mhID, 
             isnull(x.weight_,0) [weight], 
             isnull(x.volume_,0) [volume],
             iif(x.pinfrom<>0, x.pinfrom, x.pinto) [dots],
             isnull(round(sum(case when c.stip<>4 then (v.Price-v.Cost)*v.kol*100/(NM.nds+100) 
                                else case when z.nds=0 then v.Price*(v.kol-v.kol_b)*z.ourperc/100 
                                     else v.Price*(v.kol-v.kol_b)*z.ourperc/(NM.nds+100) end end),2),0) [marja]
      from NearLogistic.MarshRequests x
      left join dbo.nc c on c.datnom=x.reqid 
      left join dbo.nv v with (nolock, index(nv_datnom_idx))  on v.datnom=c.datnom
      left join nomen nm on nm.hitag=v.hitag
      left join def d on d.pin=iif(c.B_Id2>0,c.b_id2,c.b_id)
      left join tdvi t on t.id=v.tekid
      left join visual s on s.id=v.tekid
      left join (select dck,BrMaster, NDS, sum(OurPerc) as OurPerc from DefconAppendix group by dck,BrMaster,NDS) z on iif(D.Master>0, D.Master, D.pin)=z.BrMaster and isnull(t.dck,s.dck)=z.dck
      where x.mhid in (select y.mhID from #marshs y group by y.mhID) 
      group by x.mhID,isnull(x.weight_,0),isnull(x.volume_,0),iif(x.pinfrom<>0, x.pinfrom, x.pinto)) y            
group by mhID

--alter table dbo.Marsh disable trigger trg_Marsh_u
update m set m.Weight=mr.weight,
       m.Volume=mr.volume,
             m.dots=mr.dots,
             m.Earnings=isnull(mr.marja-[NearLogistic].Marsh1CalcFact(m.mhid)-[NearLogistic].Marsh1OtherExpense(m.mhid),0)            
from marsh m
inner join #MarshParams mr on mr.mhid=m.mhid
--alter table dbo.Marsh enable trigger trg_Marsh_u

--select * from #MarshParams
--select * from #Marshs
drop table #marshs
drop table #MarshParams
end
set nocount off
END