CREATE procedure warehouse.terminal_getmarshlist_new
@nd datetime,
@list_type int, --0-все, 1-накладные, 2-возвраты, 3-приходы, 4-проверка
@show_done bit,
@sklads varchar(max),
@mhid int = 0
as 
begin
set nocount on
if object_id('tempdb..#skl') is not null drop table #skl
create table #skl (sklad int)
create nonclustered index skl_idx on #skl(sklad)
if object_id('tempdb..#req') is not null drop table #req
create table #req (reqid int, mhid int, nakl_caption varchar(200), weight decimal(15,2), weight_gain decimal(15,2), rowid int, row_type int)
create nonclustered index ord_idx on #req(reqid)
create nonclustered index ord_idx1 on #req(mhid)
if object_id('tempdb..#mrs') is not null drop table #mrs
create table #mrs (mhid int, marsh_caption varchar(200), weight decimal(15,2), weight_gain decimal(15,2), rowid int)
create nonclustered index mrs_idx on #mrs(mhid) 

if isnull(@sklads,'')='' insert into #skl select skladno from dbo.skladlist where upweight=1
else insert into #skl select value from string_split(@sklads,',')

if @list_type in (0, 1)
insert into #req 
select z.datnom,iif(c.mhid=0,isnull(s.sregionid,0),iif(m.selfship=1,-99,c.mhid)),
			 '[накладная] '+cast(c.datnom % 10000 as varchar)+', '+c.fam,
       sum(iif(z.done=1, 0, dbo.getQTY(z.hitag, z.UnID, z.zakaz, 1))),   --sum(iif(z.done=1, 0, z.zakaz*n.netto)),
       sum(iif(z.done=0, 0, dbo.getQTY(z.hitag, z.UnID, z.confKol, 1))),  --sum(iif(z.done=0, 0, z.curweight)),
        0, 1
from dbo.nvzakaz z
join dbo.nomen n on n.hitag=z.hitag
join dbo.nc c on z.datnom=c.datnom
join dbo.def d on d.pin=c.b_id
join dbo.regions r on r.reg_id=d.reg_id
join warehouse.skladreg s on s.sregionid=r.sregionid
left join (select * from dbo.marsh a where a.mhid>0 and a.nd=@nd) m on m.mhid=c.mhid
join #skl on #skl.sklad=z.skladno
where z.done=iif(@show_done=1,z.done,0) 
  and z.nd=@nd and iif(c.mhid=0, isnull(s.sregionid, 0), 
                                 iif(m.selfship=1, -99, c.mhid))=iif(@mhid=0,iif(c.mhid=0,isnull(s.sregionid,0),iif(m.selfship=1,-99,c.mhid)),@mhid)
group by z.datnom,iif(c.mhid=0,isnull(s.sregionid,0),iif(m.selfship=1,-99,c.mhid)),
			   '[накладная] '+cast(c.datnom % 10000 as varchar)+', '+c.fam


--------------------------------------------------------------------------------------------------------------------------------------------------         
if @list_type=2
insert into #req
select r.reqnum, r.mhid,'[возврат] '+cast(r.reqnum as varchar)+', '+isnull(f.brName,f.gpName), 
			 sum(iif(n.flgweight=1,d.fact_weight,d.kol*n.netto)), 
       sum(iif(n.flgweight=1,d.fact_weight2,d.fact_kol2*n.netto)), 0, 2 
from dbo.reqreturndet d 
join dbo.nomen n on n.hitag=d.hitag
join dbo.reqreturn r on r.reqnum=d.reqretid
join dbo.requests q on q.rk=r.reqnum
join dbo.marsh m on m.mhid=r.mhid
join dbo.def f on f.pin=r.pin
where (m.nd=@nd or m.mhid=-99) and q.tip2=197 and r.mhid=iif(@mhid=0,r.mhID,@mhid)
			and d.done=iif(@show_done=1,d.done,0)
group by r.reqnum, r.mhid, '[возврат] '+cast(r.reqnum as varchar)+', '+isnull(f.brName,f.gpName)

if @list_type=3
insert into #req
select p.prihodrid,-99,'[комиссия]'+cast(p.prihodrid as varchar)+', '+f.brname,
			 sum(warehouse.get_qty_from_str(d.prihodrdetkolstr_plan,n.minp,n.flgWeight)),
       sum(iif(d.sklad_done=0,0,warehouse.get_qty_from_str(d.prihodrdetkolstr,n.minp,n.flgWeight))), 0, 3
from dbo.prihodreq p
join dbo.def f on f.pin=p.prihodrvenderpin
join dbo.prihodreqdet d on d.prihodrid=p.prihodrid
join dbo.nomen n on n.hitag=d.prihodrdethitag
where datediff(day,p.prihodrdate,@nd)=0 and p.prihodrdone=10
			and d.sklad_done=iif(@show_done=1,d.sklad_done,0)
group by p.prihodrid, '[комиссия]'+cast(p.prihodrid as varchar)+', '+f.brname 

if @list_type=4
insert into #req
select c.datnom, c.mhid, '['+cast(mr.reqorder as varchar)+'][проверка] '+cast(c.datnom % 10000 as varchar)+', '+c.fam,
			 --sum(iif(n.flgweight=1,n.netto,isnull(t.weight,s.weight))*v.kol),sum(iif(m.id is null,0,iif(n.flgweight=1,m.kol / 1000.0,m.kol*n.netto))),
       0,iif(exists(select 1 from warehouse.sklad_mobiletermdata m where m.mhid=c.mhid and m.datnom=c.datnom and m.kol>0),0,1),
       0,4
from dbo.nc c
join dbo.nv v with (nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join #skl on #skl.sklad=v.sklad
join dbo.nomen n on n.hitag=v.hitag
--left join warehouse.sklad_mobiletermdata m on m.mhid=c.mhid and m.datnom=c.datnom and m.hitag=v.hitag
join nearlogistic.marshrequests mr on mr.reqid=c.datnom 
--left join dbo.tdvi t on t.id=v.tekid 
--left join dbo.visual s on s.id=v.tekid
where c.nd=@nd and c.mhid<>0 and c.marsh<200 and c.sp>0 and v.kol>0 and c.mhid=iif(@mhid=0,c.mhid,@mhid)
group by c.datnom, c.mhid,'['+cast(mr.reqorder as varchar)+'][проверка] '+cast(c.datnom % 10000 as varchar)+', '+c.fam--,iif(m.id is null,0,1)


------------------------------------------------------------------------------------------------------------------------------------
insert into #mrs
select z.mhid, z.rem, z.[w], z.[wg],
			 case when z.mhid=-99 then -99
  					when z.mhid between 0 and 1000 then 1000+z.marsh
            else row_number() over(order by iif(substring(z.[tm],1,1)='0','1','0')+z.[tm],z.[marsh]) 
        end  
from (
select x.mhid, iif(s.priority is null,m.marsh,s.priority) [marsh],
			 case when x.mhid=-99 then 'САМОВЫВОЗ'
						when x.mhid between 0 and 1000 then s.sregname
            else '['+CAST(m.marsh as varchar)+']['+iif(x.mhid<1000,'--:--',
            left(iif(isnull(m.TimePlan,0)='0','00:00',iif(len(m.TimePlan)=7,'0','')+m.TimePlan),5))+'] '
            		 +isnull(d.fio+', '+d.phone,'<ВОДИТЕЛЬ НЕ НАЗНАЧЕН>') 
        end [rem],
       sum(x.[w]) [w], sum(x.[wg]) [wg], 
       iif(x.mhid<1000,'--:--',
       left(iif(isnull(m.TimePlan,0)='0','00:00',iif(len(m.TimePlan)=7,'0','')+m.TimePlan),5)) [tm]      
from (select mhid, sum(weight) [w], sum(weight_gain) [wg] from #req group by mhid) x
left join [warehouse].skladreg s on s.sregionid=x.mhid
left join dbo.marsh m on m.mhid=x.mhid
left join dbo.drivers d on d.drid=m.drid
group by x.mhid, iif(s.priority is null, m.marsh, s.priority), iif(x.mhid<1000, '--:--',
          left(iif(isnull(m.TimePlan,0)='0','00:00', iif(len(m.TimePlan)=7,'0','') + m.TimePlan),5)), 
case when x.mhid=-99 then 'САМОВЫВОЗ'
						when x.mhid between 0 and 1000 then s.sregname
            else '['+cast(m.marsh as varchar)+']['+iif(x.mhid<1000,'--:--',
            left(iif(isnull(m.TimePlan,0)='0','00:00',iif(len(m.TimePlan)=7,'0','')+m.TimePlan),5))+'] '
            +isnull(d.fio+', '+d.phone,'<ВОДИТЕЛЬ НЕ НАЗНАЧЕН>') END
  ) z

update a set a.rowid=b.rowid
from #req a
join #mrs b on a.mhid=b.mhid

select *,iif(@mhid=0,'ВСЕ МАРШРУТЫ',left(nearlogistic.getmarshregstring(@mhid),75)) [m_capt] 
from (
select 0 [reqid], marsh_caption [capt], weight, weight_gain, rowid, 0 [type] from #mrs
union all
select reqid, nakl_caption, weight, weight_gain, rowid, row_type from #req) x
order by rowid, [type], reqid

if object_id('tempdb..#skl') is not null drop table #skl
if object_id('tempdb..#mrs') is not null drop table #mrs
if object_id('tempdb..#req') is not null drop table #req
set nocount off
end