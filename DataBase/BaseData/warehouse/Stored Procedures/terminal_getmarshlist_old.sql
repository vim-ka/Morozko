CREATE procedure warehouse.terminal_getmarshlist_old
@nd datetime,
@list_type int, --0-все, 1-накладные, 2-возвраты, 3-приходы, 4-проверки 
@show_done bit,
@sklads varchar(max)
as 
begin
set nocount on
if object_id('tempdb..#skl') is not null drop table #skl
create table #skl (sklad int)
create nonclustered index skl_idx on #skl(sklad)
if object_id('tempdb..#ord') is not null drop table #ord
create table #ord (datnom int, mhid int, nakl_caption varchar(200), weight decimal(15,2), weight_gain decimal(15,2), rowid int)
create nonclustered index ord_idx on #ord(datnom)
create nonclustered index ord_idx1 on #ord(mhid)
if object_id('tempdb..#ret') is not null drop table #ret
create table #ret (reqid int, mhid int, ret_caption varchar(200), weight decimal(15,2), weight_gain decimal(15,2), rowid int)
create nonclustered index ret_idx on #ret(reqid)
create nonclustered index ret_idx1 on #ret(mhid)
if object_id('tempdb..#mrs') is not null drop table #mrs
create table #mrs (mhid int, marsh_caption varchar(200), weight decimal(15,2), weight_gain decimal(15,2), rowid int)
create nonclustered index mrs_idx on #mrs(mhid) 

if isnull(@sklads,'')='' insert into #skl select skladno from dbo.skladlist where upweight=1
else insert into #skl select value from string_split(@sklads,',')

if @list_type=1
insert into #ord 
select z.datnom,iif(c.mhid=0,isnull(s.sregionid,0),iif(m.selfship=1,-99,c.mhid)),
			 --'['+iif(c.mhid=0,s.sregname,iif(m.selfship=1 or c.mhid=-99,'самовывоз',cast(c.marsh as varchar)))+']
       '[накладная] '+cast(c.datnom % 10000 as varchar)+', '+c.fam,
       sum(iif(z.done=1,0,z.zakaz*n.netto)),sum(iif(z.done=0,0,z.curweight)),0
from dbo.nvzakaz z
join dbo.nomen n on n.hitag=z.hitag
join dbo.nc c on z.datnom=c.datnom
join dbo.def d on d.pin=c.b_id
join dbo.regions r on r.reg_id=d.reg_id
join warehouse.skladreg s on s.sregionid=r.sregionid
left join (select * from dbo.marsh a where a.mhid>0 and a.nd=@nd) m on m.mhid=c.mhid
join #skl on #skl.sklad=z.skladno
where z.done=iif(@show_done=1,z.done,0) and z.nd=@nd
group by z.datnom,iif(c.mhid=0,isnull(s.sregionid,0),iif(m.selfship=1,-99,c.mhid)),
			   --'['+iif(c.mhid=0,s.sregname,iif(m.selfship=1 or c.mhid=-99,'самовывоз',cast(c.marsh as varchar)))+']
         '[накладная] '+cast(c.datnom % 10000 as varchar)+', '+c.fam
         
if @list_type=2
insert into #ret
select r.reqnum, r.mhid,'[возврат] '+cast(r.reqnum as varchar)+', '+isnull(f.brName,f.gpName), sum(iif(n.flgweight=1,d.fact_weight,d.kol*n.netto)), sum(iif(n.flgweight=1,d.fact_weight2,d.fact_kol2*n.netto)),0 
from dbo.reqreturndet d 
join dbo.nomen n on n.hitag=d.hitag
join dbo.reqreturn r on r.reqnum=d.reqretid
join dbo.requests q on q.rk=r.reqnum
join dbo.marsh m on m.mhid=r.mhid
join dbo.def f on f.pin=r.pin
where (m.nd=@nd or m.mhid=-99) and q.tip2=197
			and d.done=iif(@show_done=1,d.done,0)
group by r.reqnum, r.mhid, '[возврат] '+cast(r.reqnum as varchar)+', '+isnull(f.brName,f.gpName)

insert into #mrs
select z.mhid, z.rem, z.[w], z.[wg],
			 case when z.mhid=-99 then -99
  					when z.mhid between 0 and 1000 then 1000+z.marsh
            else row_number() over(order by iif(substring(z.[tm],1,1)='0','1','0')+z.[tm],z.[marsh]) end  
from (
select x.mhid, iif(s.priority is null,m.marsh,s.priority) [marsh],
			 case when x.mhid=-99 then 'САМОВЫВОЗ'
						when x.mhid between 0 and 1000 then s.sregname
            else '['+cast(m.marsh as varchar)+']['+iif(x.mhid<1000,'--:--',left(iif(isnull(m.TimePlan,0)='0','00:00',iif(len(m.TimePlan)=7,'0','')+m.TimePlan),5))+'] '
            		 +isnull(d.fio+', '+d.phone,'<ВОДИТЕЛЬ НЕ НАЗНАЧЕН>') end [rem],
       sum(x.[w]) [w], sum(x.[wg]) [wg], 
       iif(x.mhid<1000,'--:--',left(iif(isnull(m.TimePlan,0)='0','00:00',iif(len(m.TimePlan)=7,'0','')+m.TimePlan),5)) [tm]      
from (
select mhid,sum(weight) [w],sum(weight_gain) [wg] from #ord group by mhid
union all
select mhid,sum(weight),sum(weight_gain) from #ret group by mhid) x
left join [warehouse].skladreg s on s.sregionid=x.mhid
left join dbo.marsh m on m.mhid=x.mhid
left join dbo.drivers d on d.drid=m.drid
group by x.mhid,iif(s.priority is null,m.marsh,s.priority),iif(x.mhid<1000,'--:--',left(iif(isnull(m.TimePlan,0)='0','00:00',iif(len(m.TimePlan)=7,'0','')+m.TimePlan),5)), 
case when x.mhid=-99 then 'САМОВЫВОЗ'
						when x.mhid between 0 and 1000 then s.sregname
            else '['+cast(m.marsh as varchar)+']['+iif(x.mhid<1000,'--:--',left(iif(isnull(m.TimePlan,0)='0','00:00',iif(len(m.TimePlan)=7,'0','')+m.TimePlan),5))+'] '+isnull(d.fio+', '+d.phone,'<ВОДИТЕЛЬ НЕ НАЗНАЧЕН>') end) z

update a set a.rowid=b.rowid
from #ord a
join #mrs b on a.mhid=b.mhid

update a set a.rowid=b.rowid
from #ret a
join #mrs b on a.mhid=b.mhid

select * from (
select 0 [reqid], marsh_caption [capt], weight, weight_gain, rowid, 0 [type] from #mrs
union all
select datnom, nakl_caption, weight, weight_gain, rowid, 1 from #ord
union all
select reqid, ret_caption, weight, weight_gain, rowid, 2 from #ret) x
order by rowid, [type], reqid

if object_id('tempdb..#skl') is not null drop table #skl
if object_id('tempdb..#mrs') is not null drop table #mrs
if object_id('tempdb..#ord') is not null drop table #ord
if object_id('tempdb..#ret') is not null drop table #ret
set nocount off
end