

CREATE PROCEDURE NearLogistic.ChooseMarsh
@basend datetime
AS
BEGIN
set nocount on
declare @dn BIGint
declare @mhID int
declare @headmas varchar(1000)
declare @headvol varchar(1000)
declare @sql varchar(max)
declare @h varchar(20)

set @dn=dbo.InDatNom(0, getdate())

if object_id('tempdb..#baseMarshs') is not null drop table #baseMarshs
if object_id('tempdb..#reqs') is not null drop table #reqs
if object_id('tempdb..#tmpmass') is not null drop table #tmpmass
if object_id('tempdb..#pins') is not null drop table #pins

if object_id('tempdb..#tmpnc') is not null drop table #tmpnc
if object_id('tempdb..#tmpnv') is not null drop table #tmpnv
if object_id('tempdb..#tmpnvzakaz') is not null drop table #tmpnvzakaz

select mt.nlmt,mt.mtclname,mt.mtname,mt.[Order] into #tmpmass from nearlogistic.masstype mt

select c.* 
into #tmpnc
from dbo.nc c
join dbo.def d on d.pin=iif(c.b_id2=0,c.b_id,c.b_id2)
LEFT JOIN marsh m ON c.mhID = m.mhid
where c.DatNom>=@dn
    and (c.sp>0 or (c.sp=0 and c.actn=1) or exists(select 1 from nvzakaz z where z.datnom=c.DatNom and z.done=0))
      and c.DayShift=0
      and d.worker=0
      and ISNULL(m.marsh,0)=0

select v.*
into #tmpnv
from dbo.nv v 
join #tmpnc c on c.datnom=v.datnom
where v.kol>0

select z.*
into #tmpnvzakaz
from dbo.nvZakaz z 
join #tmpnc c on c.datnom=z.datnom
where z.done=0

   

create table #reqs (ReqID int, 
          Pin int,
                    Place varchar(500),
                    nlmt int,
                    ReqType int,
                    ReqAction int,
                    [weight] decimal(15,2) default 0,
                    [volume] decimal(15,2) default 0)

select m.mhid,
    m.marsh,
       cast('' as varchar(500)) [direction],
    ms.nlMt,
       ms.mtclname,
       cast(0.0 as decimal(15,2)) [Weight],
       cast(0.0 as decimal(15,2)) [Volume],
       cast(0 as int) [dots],
       cast('' as varchar(5000)) [reqs]
into #baseMarshs
from dbo.marsh m
join #tmpmass ms on 1=1
where m.nd=@basend
   and not m.marsh in (0,99)
      and m.SelfShip=0
order by m.marsh, ms.nlMt

create nonclustered index idx_#basemarshs on #baseMarshs(mhid)

select distinct
    mr.mhid,
    iif(mr.PINFrom=0,mr.PINTo,mr.PINFrom) pin
into #pins 
from NearLogistic.MarshRequests mr
where mr.mhid in (select bm.mhid from #baseMarshs bm)
   and mr.reqtype=0
      
create nonclustered index idx_#pins on #pins(mhid)
create nonclustered index idx_#pins1 on #pins(pin)

declare curMarsh cursor for 
select mhid from #baseMarshs group by mhID

open curMarsh
fetch next from curMarsh into @mhID

while @@fetch_status=0
begin
 truncate table #reqs 
  
  insert into #reqs
  select c.DatNom,
      d.pin,
         r.place,
      ms.nlMt,
         cast(0 as int),
         cast(1 as int),
      sum(case when isnull(s.weight,0)=0 then isnull(v.kol,0)*isnull(n.brutto,0) else isnull(v.kol,0)*isnull(s.weight,0) end) [weight],
     sum(case when isnull(s.weight,0)=0 then isnull(v.kol,0)*isnull(n.volminp,0) else isnull(n.volminp,0)*isnull(s.weight,0) end) [volume]  
  from #tmpnc c 
  join #tmpnv v on c.datnom=v.datnom
  join dbo.nomen n on n.hitag=v.hitag
  join dbo.gr g on g.ngrp=n.ngrp 
  join dbo.def d on d.pin=iif(c.b_id2=0,c.b_id,c.b_id2)
  join #tmpmass ms on ms.nlMt=g.nlmt_new
  left join dbo.tdvi s on s.id=v.tekid
  left join dbo.Regions r on r.Reg_ID=d.Reg_ID
  where iif(c.b_id2=0,c.b_id,c.b_id2) in (select p.pin from #pins p where p.mhID=@mhid)
 group by c.datnom, d.pin, r.Place, ms.nlmt                                                 
                                                    
 union all
    
  select c.DatNom,
      d.pin,
         r.place,
      ms.nlMt,
         cast(0 as int),
         cast(1 as int),
      sum(isnull(v.Zakaz,0)*isnull(n.brutto,0)) [weight],
     sum(isnull(v.Zakaz,0)*isnull(n.volminp,0)) [volume]  
  from #tmpnc c 
  join #tmpnvZakaz v on c.datnom=v.datnom
  join dbo.nomen n on n.hitag=v.hitag
  join dbo.gr g on g.ngrp=n.ngrp 
  join dbo.def d on d.pin=iif(c.b_id2=0,c.b_id,c.b_id2)
  join #tmpmass ms on ms.nlMt=g.nlmt_new
  left join dbo.Regions r on r.Reg_ID=d.Reg_ID
  where iif(c.b_id2=0,c.b_id,c.b_id2) in (select p.pin from #pins p where p.mhID=@mhid) 
  group by c.datnom, d.pin, r.Place, ms.nlmt  
  
  insert into #reqs
  select r.reqnum,
      d.pin,
         rg.Place,
         ms.nlMt,
         cast(1 as int),
         cast(2 as int),
         sum(iif(rd.fact_weight=0,rd.kol*n.brutto,rd.fact_weight)) [weight],
         sum((n.volminp / n.minp)*rd.kol) [volume]
    from dbo.reqreturn r
    join dbo.requests q on r.reqnum=q.rk
    join dbo.ReqReturnDet rd on r.reqnum=rd.reqretid
    join dbo.nomen n on n.hitag=rd.hitag
    join dbo.gr g on g.ngrp=n.ngrp
    left join #tmpmass ms on ms.nlMt=g.nlmt_new
    join dbo.def d on d.pin=r.pin
    left join dbo.Regions rg on rg.Reg_ID=d.Reg_ID
    where r.mhid=0
       and q.Status=1
       and rd.kol>0
          and r.pin in (select #reqs.pin from #reqs)          
         and q.Tip2=194                                                            
  group by r.reqnum, d.pin, rg.Place, ms.nlmt
  
  update m set m.[weight]=isnull(r.[weight],0),
         m.[volume]=isnull(r.[volume],0),
               m.[dots]=(select count(distinct pin) from #reqs where #reqs.ReqType=0),
               m.[direction]=isnull(stuff((select N','+r.Place from #reqs r group by r.place for xml path(''), type).value('.','varchar(max)'),1,1,''),'<..>'),
               m.[reqs]=isnull(stuff((select N'#'+cast(r.ReqID as varchar)+';'+cast(r.reqtype as varchar)+';'+cast(r.ReqAction as varchar) from #reqs r group by r.reqid,r.reqtype,r.reqaction for xml path(''), type).value('.','varchar(max)'),1,1,''),'<..>')
  from #baseMarshs m
  left join (select #reqs.nlmt, sum(#reqs.weight) [weight], sum(#reqs.volume) [volume] from #reqs group by #reqs.nlmt) r on r.nlmt=m.nlmt
  where m.mhID=@mhid 
  
  fetch next from curMarsh into @mhID
end

close curMarsh
deallocate curMarsh

delete from #baseMarshs where [dots]=0

set @headmas=''
set @headvol=''
declare curhead cursor forward_only fast_forward for
select mtclname from #tmpmass

open curhead
fetch next from curhead into @h

while @@fetch_status=0
begin
  if @headmas=''
    set @headmas='[mas$'+@h+']'
  else
    set @headmas=@headmas+',[mas$'+@h+']'
  
  if @headvol=''
    set @headvol='[vol$'+@h+']'
  else
    set @headvol=@headvol+',[vol$'+@h+']'

  fetch next from curhead into @h 
end

close curhead
deallocate curhead

set @sql=N''
set @sql=@sql+N'select h.*,'+replace(@headmas,',','+')+' [Weight],'+replace(@headvol,',','+')+' [Volume],'+@headmas+','+@headvol+' from (select distinct [reqs],mhid, marsh, direction, dots from #baseMarshs) h'+char(13)+char(10)
set @sql=@sql+N'left join (select mhid,'+@headmas+' from (select mhid,''mas$''+mtclname as [columnname], [Weight] from #baseMarshs) as [src] pivot(sum([Weight]) for [columnname] in ('+@headmas+')) as [pvt]) as mas on h.mhid=mas.mhid'+char(13)+char(10)
set @sql=@sql+N'left join (select mhid,'+@headvol+' from (select mhid,''vol$''+mtclname as [columnname], [Volume] from #baseMarshs) as [src] pivot(sum([Volume]) for [columnname] in ('+@headvol+')) as [pvt]) as vol on h.mhid=vol.mhid'+char(13)+char(10)
set @sql=@sql+N' order by [Weight] desc'
exec(@sql)

drop table #baseMarshs
drop table #reqs
drop table #tmpmass
drop table #pins
drop table #tmpnc
drop table #tmpnv
drop table #tmpnvzakaz
set nocount off
END