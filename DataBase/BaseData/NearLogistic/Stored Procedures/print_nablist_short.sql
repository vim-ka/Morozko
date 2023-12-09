CREATE procedure NearLogistic.print_nablist_short
@mhid int
as
begin
declare @nd datetime, @marsh int
select @nd=nd,@marsh=marsh from dbo.marsh where mhid=@mhid
set nocount on
if object_id('tempdb..#head') is not null drop table #head
if object_id('tempdb..#body') is not null drop table #body
if object_id('tempdb..#res') is not null drop table #res
if object_id('tempdb..#pls') is not null drop table #pls

create table #head (id int, name nvarchar(500), ord int, barcode nvarchar(15), litter nvarchar(2), pin int, marsh_number int, client_barcode nvarchar(16))
create nonclustered index head_idx on #head(id)
insert into #head
select c.datnom, iif(c.stfnom<>'',c.stfnom+' '+char(13),'')+cast(c.b_id as nvarchar)+'#'+c.fam, mr.reqorder, '10'+format(c.nd,'ddMMyy')+format(c.datnom%10000,'0000'), l.list, c.b_id, m.marsh,
       '630'+right('000000'+cast(c.mhid as nvarchar),7)+right('00000'+cast(c.b_id as nvarchar),6) [client_barcode]
from nearlogistic.marshrequests mr 
join nearlogistic.letters_list l on l.id=mr.liter_id
join dbo.nc c on c.datnom=mr.reqid
JOIN dbo.marsh m ON mr.mhID = m.mhid
where mr.mhid=@mhid and mr.reqtype=0

create table #body (head_id int, id int, sklad int, hitag int, name nvarchar(500), qty decimal(15,2), qty_str nvarchar(50), 
          dater datetime, minp int, volume decimal(15,2), sklad_group int,done bit)
create nonclustered index body_idx on #body(head_id)
create nonclustered index body_idx1 on #body(id)
insert into #body
select v.datnom, v.tekid, v.sklad, n.hitag, n.name, iif(n.flgweight=1,isnull(t.weight,s.weight)*v.kol,v.kol), 
    --iif(n.flgweight=1,cast(cast(isnull(t.weight,s.weight)*v.kol as decimal(15,2)) as varchar)+' кг',iif(v.kol/n.minp>=1,cast(cast(v.kol/n.minp as decimal(15,0)) as varchar),'')+iif(v.kol-(v.kol/n.minp)*n.minp>=1,'+'+cast(cast(v.kol-(v.kol/n.minp)*n.minp as decimal(15,0)) as varchar),'')),
       warehouse.get_str_from_qty(n.flgweight,iif(n.flgweight=1,isnull(t.weight,s.weight)*v.kol,v.kol),n.minp),
       isnull(t.dater,s.dater), n.minp, n.volminp*(v.kol/n.minp), sl.skg, cast(1 as bit)
from dbo.nv v 
join dbo.nomen n  on n.hitag=v.hitag
join dbo.skladlist sl on sl.skladno=v.sklad
join #head on #head.id=v.datnom
left join dbo.visual s on s.id=v.tekid
left join dbo.tdvi t on t.id=v.tekid
where v.kol>0
union all
select z.datnom, z.nzid, z.skladno, n.hitag, n.name, iif(n.flgweight=1,n.netto*z.zakaz,z.zakaz), 
    --iif(n.flgweight=1,cast(cast(n.netto*z.zakaz as decimal(15,2)) as varchar)+' кг',iif(z.zakaz<n.minp,'1',iif(z.zakaz/n.minp>=1,cast(cast(z.zakaz/n.minp as decimal(15,0)) as varchar),'')+iif(z.zakaz-(z.zakaz/n.minp)*n.minp>=1,'+'+cast(cast(z.zakaz-(z.zakaz/n.minp)*n.minp as decimal(15,0)) as varchar),''))),
       warehouse.get_str_from_qty(n.flgweight,iif(n.flgweight=1,n.netto*z.zakaz,z.zakaz),n.minp),
       '', n.minp, n.volminp*(z.zakaz/n.minp), sl.skg, cast(0 as bit)
from dbo.nvzakaz z 
join dbo.nomen n  on n.hitag=z.hitag
join dbo.skladlist sl on sl.skladno=z.skladno
join #head on #head.id=z.datnom
where z.zakaz>0 and z.done=0

select b.sklad_group, g.skgname, h.ord, h.litter, h.id % 10000 [id], h.name, h.barcode, 
    cast('013'+format(@nd,'ddMMyy')+right('00'+cast(@marsh as varchar),3)+iif(len(cast(g.skg as varchar))>2,'00',right('0'+cast(g.skg as varchar),2)) as varchar(14)) [barcode_skg],
    b.sklad, b.name [n_name], b.minp, convert(varchar,b.dater,104) [dater], b.qty, b.qty_str, b.volume, b.done, iif(b.done=0,'не набрано','') [remark],
       cast(0 as decimal(15,4)) [group_litter_qty], h.pin, row_number() over(partition by g.skgName+'.'+h.litter order by g.skgname) [head_index], h.marsh_number, g.srid,
       client_barcode
into #res       
from #body b
join #head h on h.id=b.head_id
join dbo.skladgroups g on g.skg=b.sklad_group

update a set a.[group_litter_qty]=x.[qty]
from #res a
join (select sklad_group,pin,sum(qty) [qty] from #res group by sklad_group,pin) x on x.sklad_group=a.sklad_group and x.pin=a.pin

select a.pin, sop.srid, sum(sop.places) [cnt]
into #pls
from #head a 
join warehouse.sklad_order_places sop on sop.datnom=a.id
group by a.pin, sop.srid

select #res.*,r.room_code,r.room_name [place], isnull(#pls.cnt,0) [cnt_place]
from #res 
join dbo.skladgroups g on g.skg=#res.sklad_group
join dbo.skladrooms r on r.srid=g.srid
left join #pls on #pls.pin=#res.pin and #pls.srid=#res.srid
order by sklad_group, len(litter), litter, id, sklad, name

if object_id('tempdb..#head') is not null drop table #head
if object_id('tempdb..#body') is not null drop table #body
if object_id('tempdb..#res') is not null drop table #res
if object_id('tempdb..#pls') is not null drop table #pls
set nocount off
end