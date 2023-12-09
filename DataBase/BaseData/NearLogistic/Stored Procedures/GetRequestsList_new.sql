CREATE PROCEDURE NearLogistic.GetRequestsList_new
@mhid INT, @nd DATETIME = '13.12.2018'
as 
begin
set nocount on
--declare @nd datetime

--set @nd=getdate()
 
declare @dn1 bigint
declare @dn2 bigint
declare @sql varchar(max)
declare @headmas varchar(1000)
declare @headvol varchar(1000)
declare @headmas_ varchar(1000)
declare @headvol_ varchar(1000)
declare @h varchar(20)
declare @mW decimal(15,2)
declare @tr bit

select top 1 @mW=isnull(maxweight,0), @tr=isnull(cantrflg,0) from dbo.vehicle where closed=0 order by maxweight desc
if @tr=1
select top 1 @mW=@mW+isnull(maxweight,0) from dbo.vehicle where Closed=0 and vtip=1 order by maxweight desc

set @dn1=dbo.indatnom(0,@nd)
set @dn2=@dn1+9999

if object_id('tempdb..#tmpmass') is not null drop table #tmpmass
if object_id('tempdb..#tmpnc') is not null drop table #tmpnc 
if object_id('tempdb..#tmpnv') is not null drop table #tmpnv 
if object_id('tempdb..#tmprequests') is not null drop table #tmprequests
if object_id('tempdb..#tmphead') is not null drop table #tmphead
if object_id('tempdb..#tmpbody') is not null drop table #tmpbody
if object_id('tempdb..#region') is not null drop table #region
if object_id('tempdb..#tmpdef') is not null drop table #tmpdef
if object_id('tempdb..#tmpnomen') is not null drop table #tmpnomen
if object_id('tempdb..#tmppin') is not null drop table #tmppin
if object_id('tempdb..#tmppmarsh') is not null drop table #tmppmarsh
if object_id('tempdb..#defcolor') is not null drop table #defcolor
if object_id('tempdb..#tmplocked') is not null drop table #tmplocked

select * 
into #region
from [dbo].Regions

create table #defcolor (pin int, clr varchar(18))

insert into #defcolor
select d.pin, dc.color
from dbo.def d 
join NearLogistic.DefColor dc on d.pin=dc.pin
union 
select d.pin, x.color
from dbo.def d
join (select a.master,b.color from dbo.def a join NearLogistic.DefColor b on a.pin=b.pin where b.ismaster=1 and a.master>0) x on x.master=d.master

create table #tmplocked (reqid int, lockid bit not null default 0)
create table #tmpnomen(hitag int,mas decimal(15,2), minp int, vol decimal(20,5), nds int,nlmt int, flgweight bit)
create table #tmpdef(pin int,brName varchar(255),gpName varchar(255),brAddr varchar(255),gpAddr varchar(255),dstAddr varchar(255),
                     reg_id varchar(5),fmt int, tm varchar(8), tmWork varchar(15), for_free bit)
create table #tmpmass(id int,mname varchar(20),rname  varchar(20),weight decimal(15,2),volume decimal(15,2),color varchar(50),ord int,min_term int)
create table #tmpnc(datnom Bigint,remark varchar(500),remarkOp varchar(50),stip int,pin int,sp decimal(15,2),reqtype int,reqaction int,
                    reqorder int not null default 0,
                    mrid int,DelivCancel bit,nd datetime,done bit, meta INT, ourid INT)
create table #tmpnv(datnom Bigint,hitag int,price money,kol int,tekid int, mas decimal(15,2), vol decimal(20,5), nlmt int)
create table #tmprequests(reg_id varchar(5),place varchar(250),nnak int,hitag int,gpname varchar(200),gpaddr varchar(200),
                          sp money,mas decimal(15,2) not null,
                          volume decimal (18,5) not null,mtype varchar(20),remark varchar(500),remarkOp varchar(50),shiptype int,
                          reqtype int,reqaction int,
                          reqorder int,mrid int,DelivCancel bit,pin int,nd datetime,mtid int,min_term int, meta int, 
                          tm varchar(8), tmWork VARCHAR(15), isCoord BIT, ourid int)
create table #tmpbody(isheader bit,nnak int,reg_id varchar(500),casher varchar(200),place varchar(250),sp money,
                      smas decimal(15,2), svol decimal(18,5), sdots int,mtype varchar(20),remark varchar(500),remarkOp varchar(50),reqtype int,
                      reqaction int,reqorder int,mrid int,isCancel bit,pin int,nd datetime,min_term int,clr varchar(18),
                      meta int, tm varchar(8), tmWork VARCHAR(15), isCoord BIT, ourid int)                      
create table #tmphead(isheader bit,nnak int,reg_id varchar(500),casher varchar(200),place varchar(250),sp money,
                      smas decimal(15,2),svol decimal(18,5), sdots int,mtype varchar(20),remark varchar(500),remarkOp varchar(50),reqtype int,
                      reqaction int,reqorder int,mrid int,isCancel bit,pin int,nd datetime,min_term int,clr varchar(18),
                      meta int, tm varchar(8), tmWork VARCHAR(15))                      

create nonclustered index tmplocked_idx on #tmplocked(reqid)

create nonclustered index tmpnomen_idx on #tmpnomen(hitag)

create nonclustered index tmpdef_idx on #tmpdef(pin)
create nonclustered index tmpdef_idx1 on #tmpdef(reg_id)
create nonclustered index tmpdef_idx2 on #tmpdef(for_free)
                      
create nonclustered index tmpmass_idx1 on #tmpmass (id)

create nonclustered index tmpnc_idx on #tmpnc (datnom)
create nonclustered index tmpnc_idx1 on #tmpnc (reqtype)

create nonclustered index tmpnv_idx on #tmpnv (datnom)
create nonclustered index tmpnv_idx1 on #tmpnv (tekid)
create nonclustered index tmpnv_idx2 on #tmpnv (hitag)

create nonclustered index tmpreq_idx on #tmprequests (mtid)
create nonclustered index tmpreq_idx2 on #tmprequests (reg_id)

create nonclustered index tmpbody_idx on #tmpbody (reg_id)
create nonclustered index tmpbody_idx1 on #tmpbody (nnak)

create nonclustered index tmphead_idx on #tmphead (reg_id)
create nonclustered index tmphead_idx1 on #tmphead (nnak)

insert into #tmpnomen(hitag,mas,minp,vol,nds,nlmt,flgweight)
select n.hitag,n.Brutto,n.minp,n.volminp,n.nds,g.nlmt_new,n.flgWeight
from dbo.nomen n 
join dbo.gr g on g.Ngrp=n.ngrp
--where g.aginvis=0

insert into #tmpdef(pin,brName,gpName,brAddr,gpAddr,dstAddr,reg_id,fmt,tm,tmWork,for_free)
select d.pin,d.brName,d.gpName,d.brAddr,d.gpAddr,d.dstAddr,d.reg_id,d.fmt,d.TmPost,d.tmWork,0 
from dbo.def d
--where worker=0
union all
select c.casher_id, c.casher_name, c.casher_name,'','','','',0,'','',1
from nearlogistic.marshrequests_cashers c


insert into #tmpmass (id ,mname, rname, weight, volume, color, ord, min_term)
select mt.nlmt,mt.mtclname,mt.mtname,0,0,color,[order],min_term from nearlogistic.masstype mt



if @mhid=0
begin
  insert into #tmpnc (datnom,remark,remarkOp,stip,pin,sp,reqtype,reqaction,reqorder,mrid,DelivCancel,nd,done,meta,ourid)
  select c.datnom,c.remark,c.RemarkOp,c.stip,iif(c.b_id2=0,c.b_id,c.b_id2),c.sp,0,1,0,0,0,c.nd,c.done,0,c.OurID
  from dbo.nc c 
  INNER JOIN Marsh m ON c.mhID = m.mhid 
  --inner join #tmpdef d on d.pin=iif(c.b_id2=0,c.b_id,c.b_id2) and d.for_free=0
  where c.datnom between @dn1 and @dn2
        and (c.sp>0 or (c.sp=0 and c.actn=1))
        and isnull(c.DayShift,0)=0
        and c.mhid=@mhid
        and isnull(m.marsh,0)=0
        and c.done=1
  union 
  select c.datnom,c.remark,c.RemarkOp,c.stip,iif(c.b_id2=0,c.b_id,c.b_id2),c.sp,0,1,0,0,0,c.nd,c.done,0,c.OurID
  from dbo.nc c 
  INNER JOIN Marsh m ON c.mhID = m.mhid 
  --inner join #tmpdef d on d.pin=iif(c.b_id2=0,c.b_id,c.b_id2) and d.for_free=0  
  where isnull(c.DayShift,0)=0
        and c.mhid=@mhid
        and isnull(m.marsh,0)=0
        and c.datnom in (select z.datnom from dbo.nvzakaz z with(index(nvZakaz_idx)) where z.datnom between @dn1 and @dn2 and z.done=0)
  union all
  select  q.parentrk,q.Remark,'',-1,iif(r.pin_from>0,r.pin_from,r.pin),0,1,2,0,0,0,r.ret_nd,cast(1 as bit),q.meta, -1 -- (-1=OurID)
  from dbo.reqreturn r
  inner join dbo.Requests q on r.reqnum=q.ParentRk
  where r.mhid=@mhid and q.rs in (2,5,6) and q.Tip2=197
  union all
  select f.rcmplxid,f.rprim,'',-1,iif(f.rneedact=3,f.rtpcode2,f.rtpcode),0,2,f.rneedact,0,0,0,f.ractdate,cast(1 as bit),0, -1 -- (-1=OurID)
  from dbo.frizrequest f
  where f.ractdate<=@nd
     and f.ractdate>=dateadd(month,-1,@nd)
        and f.mhid=@mhid
        and f.rstatus=iif(@mhid=0,3,f.rstatus)      
  union all
  select mbr.mbrid,mbr.remark,'',-1,mbr.pin,mbr.sumpay,3,1,0,0,0,mbr.nd,cast(1 as bit),0, mbr.our_id
  from nearlogistic.moneybackrequest mbr 
  where mbr.done=iif(@mhid=0,0,mbr.done)
        and mbr.mhid=@mhid
  union all
  select o.OrdID, '','',-1,o.pin,o.summaprice,5,2,0,0,cast(0 as bit),o.DateComm,cast(1 as bit),0, -1 -- (-1=OurID)
 from dbo.Orders o
  join dbo.orddet od on o.ordid=od.ordid 
  join #tmpnomen n on od.hitag=n.hitag
 where o.mhID=@mhID
    and o.DateComm between convert(varchar,dateadd(day,-1,getdate()),104) and convert(varchar,dateadd(day,7,getdate()),104)        
  group by o.OrdID,o.pin,o.summaprice,o.DateComm
  having sum(isnull(od.Qty,0)*isnull(n.mas,0))<=@mW
  union all
  select mf.mrfID,isnull(mf.remark,'')+isnull(char(13)+' '+mf.extcode,''),'',-1,
         mf.pin,mf.cost,-2,mf.ReqAction,0,0,0,mf.nd,cast(1 as bit),0, -1 -- (-1=OurID)
  from nearlogistic.MarshRequests_free mf 
  where mf.mhid=@mhid and mf.isdel=0
end
else
begin
  insert into #tmpnc (datnom,remark,remarkOp,stip,pin,sp,reqtype,reqaction,reqorder,mrid,DelivCancel,nd,done,ourid)
  select mr.reqid,mr.reqremark,nc.remarkOp,-1,iif(mr.reqtype in (0,1),iif(mr.pinfrom=0,mr.pinto,mr.pinfrom),
         iif(mr.reqtype=2 and mr.reqaction=3,mr.pinfrom,mr.pinto)),mr.Cost_
     ,mr.reqtype,mr.reqaction,mr.reqorder,mr.mrid,mr.DelivCancel,mr.ReqND,cast(1 as bit), -1 -- (-1=OurID)
  from nearlogistic.marshrequests mr
  LEFT JOIN nc ON mr.ReqID = nc.DatNom AND mr.ReqType <> -2
  where mr.mhid=@mhid
  
  update c set c.done=isnull(iif(exists(select 1 from dbo.nvzakaz z where z.datnom=c.datnom and z.done=0),0,n.done),cast(0 as bit)), 
         c.DelivCancel=cast(iif(dc.reqID is null,isnull(n.DelivCancel,0),1) as bit),
               c.stip=case when (r.datnom is not null and r.sp>0) then -3
                      when (n.DayShift>0 or not exists(select 1 from dbo.nv v where v.datnom=c.datnom))and(r.datnom is null)and(not exists(select 1 from dbo.nvzakaz z where z.datnom=n.datnom and z.done=0 and z.zakaz>0)) then -2
                           else c.stip END,
         c.ourid = n.OurID
               --iif((n.Tomorrow=1 or not exists(select 1 from dbo.nv v where v.datnom=c.datnom))and(r.datnom is null and r.sp>0),-2,c.stip)
  from #tmpnc c
  left join dbo.nc n on n.datnom=c.datnom
  left join dbo.nc r on r.refdatnom=c.datnom
  left join dbo.delivcancel dc on dc.reqid=c.datnom
  where c.reqtype in (0,1)
  
  update c set c.meta=isnull(q.meta,0)
  from #tmpnc c 
  join dbo.requests q on q.parentrk=c.datnom
  where c.reqtype=1
  
  update c set c.meta=isnull(c.meta,0)
  from #tmpnc c 
  
  update c set c.remark=isnull(c.remark,'')+isnull(char(13)+' '+mf.extcode,'')
  from #tmpnc c
  join nearlogistic.MarshRequests_free mf on mf.mrfID=c.datnom and c.reqtype=-2
 --select * from #tmpnc
end

insert into #tmpnv (datnom, hitag, price, kol, tekid, mas, vol, nlmt)
select  r.refdatnom,
    v.hitag,
        v.price*v.kol*100/(n.nds+100),
        v.kol,
        v.tekid,
        isnull((case when n.flgWeight=0 then isnull(v.kol,0)*isnull(n.mas,0) else isnull(v.kol,0)*isnull(vi.weight,s.weight) end),0),
        isnull((case when n.flgWeight=0 then isnull(v.kol,0)*isnull(n.vol,0) else isnull(n.vol,0)*isnull(vi.weight,s.weight) end),0),
        n.nlmt
from #tmpnc c
join dbo.nc r on r.refdatnom=c.datnom
join dbo.nv v with (index(nv_datnom_idx))  on r.datnom=v.datnom
inner join #tmpnomen n on v.hitag=n.hitag
left join dbo.tdvi vi on vi.id=v.tekid 
left join dbo.visual s on s.id=v.tekid
where c.STip=-3
union all
select  c.datnom,0,0,0,0,0,0,0
from #tmpnc c
where c.STip=-2
union all  
select  c.datnom,0,mf.cost,1,0,mf.weight,mf.volume,0
from #tmpnc c
join nearlogistic.MarshRequests_free mf on mf.mrfID=c.datnom
where c.reqtype=-2
union all
select  v.datnom,
    v.hitag,
        v.price*v.kol*100/(n.nds+100),
        v.kol,
        v.tekid,
        isnull((case when n.flgWeight=0 then isnull(v.kol,0)*isnull(n.mas,0) else isnull(v.kol,0)*isnull(vi.weight,s.weight) end),0),
        isnull((case when n.flgWeight=0 then isnull(v.kol,0)*isnull(n.vol,0) else isnull(n.vol,0)*isnull(vi.weight,s.weight) end),0),
        n.nlmt
from dbo.nv v with (index(nv_datnom_idx)) 
inner join #tmpnc c on c.datnom=v.datnom
inner join #tmpnomen n on v.hitag=n.hitag
left join dbo.tdvi vi on vi.id=v.tekid 
left join dbo.visual s on s.id=v.tekid
where c.reqtype=0 
union all
select  z.datnom,
    z.hitag,
        z.price*z.Zakaz*100/(n.nds+100),
        z.Zakaz,
        0,
        isnull(z.Zakaz,0)*isnull(n.mas,0),
        iif(n.flgWeight=0,isnull(z.Zakaz,0),isnull(z.Zakaz,0)*isnull(n.mas,0))*isnull(n.vol,0),
        n.nlmt
from dbo.nvZakaz z with(index(nvZakaz_idx))
inner join #tmpnc c on c.datnom=z.datnom
inner join #tmpnomen n on z.hitag=n.hitag
where c.reqtype=0 and (z.done=0)
union all 
select  r.reqretid,
    r.hitag,
        0,
        r.kol,
        0,
        isnull(r.kol,0)*iif(r.fact_weight=0,n.mas,r.fact_weight),
        iif(n.flgWeight=0,isnull(r.kol,0),iif(r.fact_weight=0,n.mas,r.fact_weight))*isnull(n.vol,0),
        n.nlmt
from dbo.reqreturndet r
inner join #tmpnc c on c.datnom=r.reqretid
inner join #tmpnomen n on r.hitag=n.hitag
where c.reqtype=1
   and r.kol>0
union all 
select i.frizreqid,
    i.frizernom,
       0,
       1,
       0,
       isnull(ml.weight,0),
    isnull(ml.VolumeBox,0),
       0
from dbo.frizrequestinvnom i
inner join #tmpnc c on c.datnom=i.frizreqid
left join dbo.frizer z on z.nom=i.frizernom
left join dbo.frizermodel ml on ml.fmod=z.fmod
where c.reqtype=2
union all 
select mbr.mbrid,
    -1,
       mbr.sumpay,
       1,
       0,
       0,
       0,
       0
from nearlogistic.moneybackrequest mbr
inner join #tmpnc c on c.datnom=mbr.mbrid
union all
select ms.Mvk,
    -1,
       0,
       1,
       0,
       0,
       0,
       0
from dbo.MarshSertif ms 
inner join #tmpnc c on c.DatNom=ms.Mvk
union all
select od.OrdID,
    od.Hitag,
       od.Price,
       od.Qty,
       0,
       isnull(od.Qty,0)*isnull(n.mas,0),
       iif(n.flgWeight=0,isnull(od.Qty,0),isnull(od.Qty,0)*isnull(n.mas,0))*isnull(n.vol,0),
       n.nlmt       
from dbo.orddet od 
inner join #tmpnc c on c.datnom=od.OrdID
inner join #tmpnomen n on od.hitag=n.hitag
where c.reqtype=5

--select * from #tmpnv

--список покупателей в маршрутах
select [pin],
    [marsh]
into #tmppin       
from (
select iif(mr.reqtype=0,iif(mr.pinfrom=0,mr.pinto,mr.pinfrom),iif(mr.reqtype=2 and mr.reqaction=3,mr.pinfrom,mr.pinto)) [pin],
    m.marsh
from NearLogistic.MarshRequests mr
join dbo.marsh m on m.mhid=mr.mhid
where m.nd=convert(varchar,@nd,104)
   and not m.marsh in (0,99)
      and m.delivcancel=0
      and m.MStatus<4) x
      
      
select [pin],
    isnull(
       stuff((select N','+cast(t.marsh as varchar)
       from #tmppin t 
            where t.pin=p.pin            
            group by t.marsh
            order by t.marsh
            for xml path(''), type).value('.','varchar(max)'),1,1,''),
            '<..>') [marshs]
into #tmppmarsh            
from #tmppin p
group by [pin] 

create nonclustered index idx_tmppin on #tmppin(pin)

insert into #tmprequests
select  case when c.reqtype=-2 then nearlogistic.get_free_reg_id(c.datnom,0)
       when c.reqtype<>4 and c.reqtype<>-2 then d.reg_id 
        else '' end,
    --iif(c.reqtype<>4,d.reg_id,''),
        case when c.reqtype=-2 then nearlogistic.get_free_reg_id(c.datnom,1) else r.place end,
        c.datnom [nnak],
        v.hitag,
        case when c.reqtype=-2 then NearLogistic.get_free_point_name(c.datnom,0)
        else iif(d.fmt=4,'<vip>','')+iif(c.stip=-2,'<DayShift>','')+iif(c.done=0,'<bold>','')
        +cast(d.pin as varchar)+'#'+iif(c.reqtype<>4,isnull(d.gpname,d.brname),sb.BrName) end,
        case when c.reqtype=4 then sb.Address
           when c.reqtype=-2 then nearlogistic.get_free_adress_string(c.datnom,6)
        else iif(isnull(d.dstAddr,'')='',d.gpaddr,d.dstAddr) end,
        --iif(c.reqtype<>4,iif(isnull(d.dstAddr,'')='',d.gpaddr,d.dstAddr),sb.Address),
        v.price,
        v.mas,
        v.vol,
        x.mname [mtype],
        c.remark,
        c.remarkOp,
        c.stip [shiptype],
        c.reqtype,
        c.reqaction,
        c.reqorder,
        c.mrid,
        c.DelivCancel,
        --iif(c.reqtype<>4,d.pin,sb.BrNo),
        case when c.reqtype=-2 then NearLogistic.get_free_point_name(c.datnom,1)
           when c.reqtype=4 then sb.brno
        else d.pin end,
        c.nd,
        x.id,
        x.min_term,
        c.meta,
        d.tm,
        d.tmWork,
        nearlogistic.CheckCoord(iif(c.reqtype=-2,c.datnom,d.pin),iif(c.reqtype=-2,6,0)),
        c.ourid
from #tmpnv v 
inner join #tmpnc c on c.datnom=v.datnom
left join #tmpdef d on d.pin=c.pin and d.for_free=cast(iif(c.reqtype=-2,1,0) as bit)
left join dbo.SertifBranch sb on sb.brno=c.pin
inner join #tmpmass x on x.id=v.nlmt
left join #region r on r.reg_id=d.reg_id

insert into #tmpbody   
select  cast(0 as bit) [isheader],
        nnak [nnak],
        s.reg_id,
        s.gpname,
        s.gpaddr,
        sum(isnull(s.sp,0)) [sp],
        sum(isnull(s.mas,0)) [smas],
        sum(isnull(s.volume,0)) [svol],
        0 [sdots],
        s.mtype,
        iif(@mhid=0 and isnull(m.[marshs],'')<>'','[М='+m.[marshs]+'] ','')+s.remark,
        s.remarkOp,
        s.reqtype,
        s.reqaction,
        s.reqorder,
        s.mrid,
        s.DelivCancel,
        s.pin,
        s.nd,
        min(s.min_term),
        isnull(dc.clr,''),
        s.meta,
        iif(s.tm is null or s.tm='00:00','',s.tm),
        iif(s.tmWork is NULL, '',s.tmWork),
        s.isCoord,
        s.ourid
from #tmprequests s
left join #tmppmarsh m on s.pin=m.pin
left join #defcolor dc on dc.pin=s.pin
group by nnak,s.reg_id,s.gpaddr,s.gpname,iif(@mhid=0 and isnull(m.[marshs],'')<>'','[М='+m.[marshs]+'] ','')+s.remark,s.remarkOp,
     s.mtype,s.reqtype,s.reqaction,s.reqorder,s.mrid,s.DelivCancel,s.pin,s.nd,isnull(dc.clr,''),s.meta,
     iif(s.tm is null or s.tm='00:00','',s.tm),iif(s.tmWork is NULL, '',s.tmWork),s.isCoord,s.ourid

insert into #tmphead   
select  cast(1 as bit) [isheader],
    rank() over(order by s.reg_id)+10000,
    s.reg_id,
    s.place,
    'кол-во точек: '+cast((select count(distinct casher) from #tmpbody where reg_id=s.reg_id) as varchar),
    sum(isnull(s.sp,0)) [sp],
    sum(isnull(s.mas,0)) [smas],
        sum(isnull(s.volume,0)) [svol],
        isnull((select count(distinct casher) from #tmpbody where reg_id=s.reg_id and reqtype<>1 ),0) [sdots],
    s.mtype,
        '',
        '',
    -1,
        0,
        s.reqorder,
        s.mrid,
        s.DelivCancel,
        0,
        convert(varchar,getdate(),104),
        min(s.min_term),
        '',
        0,
        '',
        ''
from #tmprequests s
group by s.reg_id,s.place,s.mtype,s.reqorder,s.mrid,s.DelivCancel

update t set t.svol=0.0, t.smas=0.0
from #tmphead t
where t.sdots=0
/*
update b set b.reg_id=iif(h.reg_id is null,'Регион не указан',h.reg_id+'::'+h.casher+', '+h.place+', тоннаж: '+cast(h.sall as varchar)+'кг., объём: '+cast(h.sallvol as varchar)+'м.куб.')
from #tmpBody b
inner join #tmpHead h on b.reg_id=h.reg_id

update b set b.reg_id=iif(h.reg_id is null,'Регион не указан',h.reg_id+'::'+h.casher+', '+h.place+', тоннаж: '+cast(h.sall as varchar)+'кг., объём: '+cast(h.sallvol as varchar)+'м.куб.')
from #tmpHead b
inner join #tmpHead h on b.reg_id=h.reg_id
*/
update h set h.reg_id='-1::Регион не указан',reqorder=-1*reqorder-1
from #tmpHead h
where h.reg_id is null

update b set b.reg_id='-1::Регион не указан',reqorder=-1*reqorder-1
from #tmpBody b
where b.reg_id is null

set @headmas=''
set @headvol=''
set @headmas_=''
set @headvol_=''
declare curhead cursor forward_only fast_forward for
select mname from #tmpmass

open curhead 
fetch next from curhead into @h

while @@fetch_status=0
begin
  if @headmas=''
  begin
    set @headmas='[mas$'+@h+']'
    set @headmas_='isnull([mas$'+@h+'],0) as [mas$'+@h+']'
  end
  else
  begin
    set @headmas=@headmas+',[mas$'+@h+']'
    set @headmas_=@headmas_+',isnull([mas$'+@h+'],0) as [mas$'+@h+']'
  end  
  if @headvol=''
  begin
    set @headvol='[vol$'+@h+']'
    set @headvol_='isnull([vol$'+@h+'],0) as [vol$'+@h+']'
  end
  else
  begin
    set @headvol=@headvol+',[vol$'+@h+']'
    set @headvol_=@headvol_+',isnull([vol$'+@h+'],0) as [vol$'+@h+']'
  end
  fetch next from curhead into @h 
end
close curhead
deallocate curhead

update ms set volume=x.[vol], 
              weight=x.[mas]
from #tmpmass ms 
inner join (select mtype, sum(svol) [vol], sum(smas) [mas] from #tmphead group by mtype) x on x.mtype=ms.mname

insert into #tmplocked(reqid)
select nnak from #tmpbody

update l set l.lockid=iif(dc.debit=1,1,0)
from #tmplocked l
join dbo.reqreturn r on r.reqnum=l.reqid
join dbo.defcontract dc on dc.dck=r.dck

alter table #tmpbody add casher_req varchar(100) not null default ''
alter table #tmphead add casher_req varchar(100) not null default ''

update b set b.casher_req=c.casher_name
from #tmpbody b
join NearLogistic.MarshRequests_free f on f.mrfid=b.nnak
join nearlogistic.marshrequests_cashers c on c.casher_id=f.pin
where b.reqtype=-2

update b set b.casher_req = IIF(nc.STip = 4, d.shortfam, fc.OurName)
from #tmpbody b
JOIN nc ON b.nnak = NC.datnom
JOIN FirmsConfig fc ON b.ourid=fc.Our_id
LEFT JOIN DefContract dc ON dc.DCK = IIF(nc.stip<>4, NC.DCK, nc.gpOur_ID)   
LEFT JOIN def d ON dc.pin = d.pin
where b.reqtype<>-2

set @sql=''
set @sql=N'select '+iif(@mhid<>0,'r.mrID,r.ReqOrder,','')+'z.*,
        (select reqname from nearlogistic.requeststype t where t.reqtype=z.reqtype) [reqname], 
        isnull((select top 1 lockid from #tmplocked where reqid=z.nnak),0) [locked] from ('+char(13)+char(10)
if @mhID<>0
 set @sql=@sql+N'select mrID, ReqOrder from nearlogistic.marshrequests mr where mr.mhid='
              +cast(@mhid as varchar)+') r inner join ('+char(13)+char(10)
set @sql=@sql+N'select h.*,'+@headmas_+','+@headvol_+' from (select isheader,nnak,reg_id,casher,place,sum(sp) sp,sum(smas) sall,
              sum(svol) sallvol,sdots,remark,remarkOp,reqtype,reqaction,reqorder,mrid,isCancel,pin,nd,cast(case when patindex('
              +''''+'%<vip>%'+''''+',casher)<>0 then 1 else 0 end as bit) [isVip],min(min_term) [min_term],clr,meta,tm,tmWork,casher_req, 
              cast(0 as bit) as isCoord from #tmphead 
              group by isheader,nnak,reg_id,casher,place,sdots,remark,remarkOp,reqtype,
              reqaction,reqorder,mrid,isCancel,pin,nd,clr,meta,tm,tmWork,casher_req) h'+char(13)+char(10)
set @sql=@sql+N'inner join (select nnak,'+@headmas+' from (select nnak,''mas$''+mtype as [columnname],
              smas from #tmphead) as [src] pivot(sum(smas) for [columnname] in ('
              +@headmas+')) as [pvt]) as mas on h.nnak=mas.nnak'+char(13)+char(10)
set @sql=@sql+N'inner join (select nnak,'+@headvol+' from (select nnak,''vol$''+mtype as [columnname],
              svol from #tmphead) as [src] pivot(sum(svol) for [columnname] in ('+@headvol+
              ')) as [pvt]) as vol on h.nnak=vol.nnak'+char(13)+char(10)
set @sql=@sql+N'union'+char(13)+char(10)
set @sql=@sql+N'select b.*,'+@headmas_+','+@headvol_+' from (select isheader,nnak,reg_id,casher,place,sum(sp) sp,
              sum(smas) sall,sum(svol) sallvol,sdots,remark,remarkOp,reqtype,reqaction,reqorder,mrid,isCancel,pin,
              nd,cast(case when patindex('+''''+'%<vip>%'+''''+',casher)<>0 then 1 else 0 end as bit) [isVip],
              min(min_term) [min_term],clr,meta,tm,tmWork,casher_req, isCoord from #tmpbody 
              group by isheader,nnak,reg_id,casher,
              place,sdots,remark,remarkOp,reqtype,reqaction,reqorder,mrid,isCancel,pin,nd,clr,
              meta,tm,tmWork,casher_req, isCoord) b'+char(13)+char(10)
set @sql=@sql+N'inner join (select nnak,'+@headmas+' from (select nnak,''mas$''+mtype as [columnname],
              smas from #tmpbody) as [src] pivot(sum(smas) for [columnname] in ('+@headmas+')) as [pvt]) as mas on b.nnak=mas.nnak'+char(13)+char(10)
set @sql=@sql+N'inner join (select nnak,'+@headvol+' from (select nnak,''vol$''+mtype as [columnname],
              svol from #tmpbody) as [src] pivot(sum(svol) for [columnname] in ('+@headvol+')) as [pvt]) as vol on b.nnak=vol.nnak'+char(13)+char(10)
set @sql=@sql+N') z '+iif(@mhid<>0,'on z.mrid=r.mrid','')+' where isheader=iif('+cast(@mhid as varchar)
              +'>0,0,isheader) order by z.reqorder,z.reg_id,z.isheader desc,z.casher,z.nnak'
exec sys.sp_sqlexec @sql 

select * from #tmpmass order by ord

--declare @reqid int
--set @reqid=1705263700
--select * from #tmpnv where datnom=@reqid
--select * from #tmpnc where datnom=@reqid
--select * from #tmpdef
--select * from #tmprequests where reqtype=-2
--select * from #tmphead where nnak=@reqid
--select * from #tmpbody where nnak=@reqid
--select * from #tmpnomen where hitag=28782

if object_id('tempdb..#tmplocked') is not null drop table #tmplocked
if object_id('tempdb..#tmpmass') is not null drop table #tmpmass
if object_id('tempdb..#tmpnc') is not null drop table #tmpnc 
if object_id('tempdb..#tmpnv') is not null drop table #tmpnv 
if object_id('tempdb..#tmprequests') is not null drop table #tmprequests
if object_id('tempdb..#tmphead') is not null drop table #tmphead
if object_id('tempdb..#tmpbody') is not null drop table #tmpbody
if object_id('tempdb..#region') is not null drop table #region
if object_id('tempdb..#tmpdef') is not null drop table #tmpdef
if object_id('tempdb..#tmpnomen') is not null drop table #tmpnomen
if object_id('tempdb..#tmppin') is not null drop table #tmppin
if object_id('tempdb..#tmppmarsh') is not null drop table #tmppmarsh
if object_id('tempdb..#defcolor') is not null drop table #defcolor
set nocount off
end