CREATE procedure tax.get_client_list
@op int, @nd datetime, @deep int, @deep_out int, @over money, @over_out money, 
@deps varchar(3000), @agents varchar(3000), @supers varchar(3000), @our_ids varchar(100)
as
begin
set nocount on
if @nd is null set @nd=dbo.today()
if object_id('tempdb..#dck') is not null drop table #dck
if object_id('tempdb..#tmp') is not null drop table #tmp
if object_id('tempdb..#dsd_slice') is not null drop table #dsd_slice
if object_id('tempdb..#res') is not null drop table #res
if object_id('tempdb..#kss') is not null drop table #kss
create table #dck (dck int)
create table #dsd_slice (dck int, deep int, debt money, overdue money, our_id int, depid int, sv_ag_id int, ag_id int, master_pin int, 
												 pin int, payment_date datetime, max_payment_date datetime, payment_sum money, merge_bit bit)
create table #res (pin int, pin_name varchar(500), deep int, debt money, overdue money, nd datetime, last_pay money)
create table #kss (pin int, master_pin int, dck int, nd datetime, plata money)

create nonclustered index dck_idx on #dck(dck)
create nonclustered index kss_idx on #kss(dck)
create nonclustered index kss_idx1 on #kss(nd)
create nonclustered index dsd_idx on #dsd_slice(dck)
create nonclustered index dsd_idx1 on #dsd_slice(depid)
create nonclustered index dsd_idx2 on #dsd_slice(sv_ag_id)
create nonclustered index dsd_idx3 on #dsd_slice(ag_id)
create nonclustered index dsd_idx4 on #dsd_slice(our_id)


select distinct d.pin, d.master into #tmp
from dbo.dailysaldodck s
join dbo.defcontract dc on dc.dck=s.dck
join dbo.def d on d.pin=dc.pin
where s.nd=iif(@nd=dbo.today(),dateadd(day,-1,@nd),@nd)
			and s.overdue between @over and @over_out 
      and s.deep between @deep and @deep_out 

insert into #dck
select dc.dck
from dbo.defcontract dc 
where dc.pin in (select a.pin from dbo.def a where a.pin in (select pin from #tmp)      
								 union all select b.pin from dbo.def b where b.master in (select master from #tmp))

insert into #dsd_slice
select #dck.dck,isnull(s.deep,0),isnull(s.debt,0),isnull(s.overdue,0),dc.our_id,a.depid,a.sv_ag_id,a.ag_id,iif(d.master=0,d.pin,d.master) [master_pin], d.pin [pin],
		   cast(null as datetime) [payment_date], cast(null as datetime) [max_payment_date], cast(0 as money) [payment_sum], 
       cast(0 as bit) [merge_bit]
from #dck 
left join (select a.* 
					 from dbo.dailysaldodck a
           where a.nd=iif(@nd=dbo.today(),dateadd(day,-1,@nd),@nd)
								 and a.overdue between @over and @over_out 
      					 and a.deep between @deep and @deep_out
           )s on s.dck=#dck.dck
join dbo.defcontract dc on dc.dck=#dck.dck
join dbo.def d on d.pin=dc.pin
join dbo.agentlist a on a.ag_id=iif(dc.ag_id=33,dc.prevag_id,dc.ag_id)
 

--фильтр по организациям
if isnull(@our_ids,'')<>''
delete c from #dsd_slice c 
where not c.our_id in (select s.[value] from string_split(@our_ids,',') s)

--фильтр по отделу
if isnull(@deps,'')<>''
delete c from #dsd_slice c 
where not c.depid in (select s.[value] from string_split(@deps,',') s)

--фильтр по суперам
if isnull(@supers,'')<>''
delete c from #dsd_slice c 
where not c.sv_ag_id in (select s.[value] from string_split(@supers,',') s)

--фильтр по агентам
if isnull(@agents,'')<>''
delete c from #dsd_slice c 
where not c.ag_id in (select s.[value] from string_split(@agents,',') s)

insert into #kss
select k.b_id, d.master, k.dck, iif(k.bank_id>0,k.bankday,k.nd), sum(plata)
from dbo.kassa1 k
join dbo.def d on d.pin=k.b_id
join #dsd_slice on #dsd_slice.dck=k.dck
where iif(k.bank_id>0,k.bankday,k.nd) between dateadd(year,-1,@nd) and @nd 
      and k.oper=-2 and k.act='ВЫ'
group by k.b_id, d.master, k.dck, iif(k.bank_id>0,k.bankday,k.nd)
having sum(plata)>0
      
--учитываем текущие оплаты и отгрузки
if @nd=dbo.today()
begin
	update x set x.debt=x.debt-y.pl
	from #dsd_slice x 
	inner join (select dck, sum(plata) pl from #kss where nd=@nd group by dck) y on x.pin=y.dck
	
  update x set x.debt=x.debt+y.ot
	from #dsd_slice x 
	inner join (select b_id, sum(sp) ot from dbo.nc where nd=@nd group by b_id) y on x.pin=y.b_id
  
  update x set x.overdue=x.overdue+y.ot, x.deep=x.deep+iif(y.ot>0,1,0)
	from #dsd_slice x 
	inner join (select b_id, sum(sp-fact+izmen) ot from dbo.nc where dateadd(day,srok+1,nd)=@nd group by b_id) y on x.pin=y.b_id
end

update x set x.payment_date=y.nd
from #dsd_slice x 
inner join (select pin, max(nd) nd from #kss group by pin) y on x.pin=y.pin

update x set x.[payment_sum]=isnull((select sum(z.plata) from #kss z where z.dck=x.dck and z.nd=x.payment_date),0)
from #dsd_slice x

update x set x.[merge_bit]=j.isSingle
from #dsd_slice x 
join (select * from tax.job where closed=0) j on j.pin=x.pin

insert into #res (pin, pin_name, deep, debt, overdue, nd)	
select d.pin, d.brname, max(s.deep) [deep], sum(s.debt) [debt], sum(s.overdue) overdue, max(s.payment_date) [nd]
from #dsd_slice s
join dbo.def d on d.pin=iif(s.[merge_bit]=1,s.[pin],s.[master_pin])
group by d.pin, d.brname, s.[merge_bit]

update s set s.[max_payment_date]=a.[nd]
from #dsd_slice s 
join #res a on a.pin=iif(s.[merge_bit]=1,s.[pin],s.[master_pin])

update x set x.[last_pay]=z.[plata]
from #res x
join (
	select iif(s.[merge_bit]=1,s.[pin],s.[master_pin]) [pin], sum(s.[payment_sum]) [plata]
	from #dsd_slice s 
	where s.[max_payment_date]=s.[payment_date]
  group by iif(s.[merge_bit]=1,s.[pin],s.[master_pin])) z on z.pin=x.pin

select a.*, isnull(j.stage_id,-1) [stage_id], jsl.[list] [stage], 
			 cast(iif(exists(select 1 from tax.job_detail d 
       								 join tax.job_types_list t on t.id=d.job_type 
                       where d.job_id=j.job_id and d.op=@op and d.isdel=0 
                       			 and t.tech_job=0 and datediff(day,d.dt,dbo.today())=0),1,0) as bit) [work_today], 
			 isnull(j.job_id,-1) [job_id], isnull(j.isSingle,0) [isSingle]
from #res a 
left join (select pin ,min(job_id) job_id from tax.job where closed=0 group by pin) b on b.pin=a.pin
left join tax.job j on j.job_id=b.job_id
join tax.job_stages_list jsl on jsl.id=isnull(j.stage_id,-1)
order by overdue desc, pin_name

if object_id('tempdb..#dsd_slice') is not null drop table #dsd_slice
if object_id('tempdb..#res') is not null drop table #res
if object_id('tempdb..#kss') is not null drop table #kss
if object_id('tempdb..#dck') is not null drop table #dck
if object_id('tempdb..#tmp') is not null drop table #tmp
set nocount off
end