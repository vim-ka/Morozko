CREATE procedure NearLogistic.print_loadlist_short
@mhid int
as
begin
set nocount on
if object_id('tempdb..#req_list') is not null drop table #req_list
if object_id('tempdb..#res') is not null drop table #res
if object_id('tempdb..#pls') is not null drop table #pls
create table #res (ord int, marsh int, code nvarchar(5), pin_name nvarchar(100), req_list nvarchar(2000), req_count int, box_count int, 
          weight decimal(15,2), places nvarchar(2000), pin int, reqid int, srid int, client_barode nvarchar(16))
create table #req_list(reqid int, pin int, pin_name nvarchar(100), box int, weight decimal(15,2), out_id nvarchar(100), ord int, marsh int, 
            liter_id int, liter nvarchar(2), numsklad nvarchar(50), srid int, client_barode nvarchar(16))
create nonclustered index req_list_idx on #req_list(reqid)
create nonclustered index req_list_idx1 on #req_list(pin)
create nonclustered index req_list_idx2 on #req_list(liter_id)
insert into #req_list
select distinct
    c.datnom, c.b_id, c.fam, mr.kolbox_, mr.weight_, c.stfnom, mr.reqorder,
    m.marsh, mr.liter_id, l.list, isnull('<b>'+sr.room_code+'</b>'+isnull(' ['+rtrim(sr.room_name)+']',''),'<..>'),
       g.srid,
       '630'+right('000000'+cast(c.mhid as nvarchar),7)+right('00000'+cast(c.b_id as nvarchar),6) [client_barcode]
from dbo.nc c
join dbo.nv v with(nolock,index(nv_datnom_idx)) on v.datnom=c.datnom
join dbo.skladlist s on s.skladno=v.sklad
join dbo.skladgroups g on g.skg=s.skg
left join dbo.skladrooms sr on sr.srid=g.srid
join nearlogistic.marshrequests mr on mr.reqid=c.datnom
join nearlogistic.letters_list l on l.id=mr.liter_id
JOIN dbo.marsh m ON mr.mhID = m.mhid
where mr.mhid=@mhid 

union all

select mr.reqid, p.point_id, p.point_name, f.kolbox, f.weight, f.extcode, mr.reqorder,
    m.marsh, -1, '', '<..>',0,'0'
from nearlogistic.marshrequests mr 
join dbo.marsh m on m.mhid=mr.mhid
join nearlogistic.marshrequests_free f on f.mrfid=mr.reqid
join nearlogistic.marshrequestsdet d on d.mrfid=f.mrfid and d.action_id=6
join nearlogistic.marshrequests_points p on p.point_id=d.point_id
where mr.mhid=@mhid

insert into #res (ord, marsh,code, pin_name, req_count, box_count, weight, pin, places,srid,client_barode)
select min(ord), marsh, liter, cast(pin as nvarchar)+'#'+pin_name,
    count(distinct reqid), sum(distinct box), sum(distinct weight), pin,
       numsklad,srid,client_barode
from #req_list
group by marsh, liter, cast(pin as nvarchar)+'#'+pin_name, pin, numsklad, srid, client_barode

select a.pin, sop.srid, sum(distinct sop.places) [cnt]
into #pls
from #req_list a 
join warehouse.sklad_order_places sop on sop.datnom=a.reqid
group by a.pin, sop.srid

update r set r.req_list=stuff( (select distinct N''+iif(isnull(out_id,'')='',cast(reqid % 10000 as nvarchar),out_id+'('+cast(reqid % 10000 as nvarchar)+')')+'; '
                                from #req_list l
                                where l.pin = r.pin
                                for xml path(''), type).value('.','varchar(max)'),1,0,''  
                                ),
             /*r.places=stuff( (select distinct N''+rtrim(numsklad)+'; '--+char(13)
                              from #req_list l
                              where l.pin = r.pin and l.reqid=r.reqid
                              for xml path(''), type).value('.','varchar(max)'),1,0,''  
                              )*/
             r.box_count=case when code='' then (select sum(box) from #req_list where pin=r.pin and liter_id=-1)
                    else isnull((select sum(cnt) from #pls a where a.pin=r.pin and a.srid=r.srid),0) end
from #res r


select *, row_number() over(partition by pin order by ord,pin) [head_index]
from #res order by ord, pin

if object_id('tempdb..#req_list') is not null drop table #req_list
if object_id('tempdb..#res') is not null drop table #res
if object_id('tempdb..#pls') is not null drop table #pls
set nocount off
end