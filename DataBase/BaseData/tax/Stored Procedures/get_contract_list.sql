CREATE PROCEDURE tax.get_contract_list
@nd datetime, @op int, @deep int =0, @overdue money =0.00,
@deps varchar(3000) ='', @pins varchar(3000) ='', @dcks varchar(3000) ='',
@agents varchar(3000) ='', @supers varchar(3000) ='', @tips varchar(100) ='',
@our_ids varchar(100) ='', @pin_masters varchar(3000) ='', @dck_masters varchar(3000) ='',
@deep_out int=0, @overdue_out money =0.00
as 
begin
set nocount on
set @nd=dbo.today()

if object_id('tempdb..#contracts') is not null drop table #contracts
create table #contracts (dck int, depid int, pin int,ag_id int, sv_ag_id int,deep int, 
												 overdue money, debt money,contr_name varchar(80), contr_tip varchar(25),
                         client_name varchar(255),phone_br varchar(50), phone_gp varchar(50),
                         contact varchar(50), email varchar(100),contrtip int,our_id int,
                         ourname varchar(60),agent_fio varchar(100),agent_phone varchar(50),
                         super_fio varchar(100),super_phone varchar(50),dep_name varchar(70),
                         pin_master int, dck_master int,
												 ag_id_old int,agent_fio_old varchar(100),agent_phone_old varchar(50),dep_name_old varchar(70))
insert into #contracts 
select s.dck,a.depid,dc.pin,a.ag_id,a.sv_ag_id,s.deep,s.overdue, 
			 s.debt,dc.contrname,dct.tipname,d.brname,d.brphone,d.gpphone,
       d.contact,d.email,dc.contrtip,dc.our_id,fc.ourname,
       ap.fio,ap.phone,sp.fio,sp.phone,de.dname,d.master,dc.dckmaster,
       a_old.ag_id,ap_old.fio,ap_old.phone,de_old.dname
from dbo.dailysaldodck s
join dbo.defcontract dc on s.dck=dc.dck
join dbo.agentlist a on a.ag_id=dc.ag_id
join dbo.agentlist sv on sv.ag_id=a.sv_ag_id
join dbo.person ap on ap.p_id=a.p_id
join dbo.person sp on sp.p_id=sv.p_id
join dbo.defcontracttip dct on dct.contrtip=dc.contrtip
join dbo.def d on d.pin=dc.pin
join dbo.firmsconfig fc on fc.our_id=dc.our_id
join dbo.agentlist a_old on a_old.ag_id=dc.prevag_id
join dbo.person ap_old on ap_old.p_id=a_old.p_id
left join dbo.deps de on de.depid=a.depid
left join dbo.deps de_old on de_old.depid=a_old.depid
where s.nd=iif(@nd=dbo.today(),dateadd(day,-1,@nd),@nd)
			and s.overdue between @overdue and @overdue_out 
      and s.deep between @deep and @deep_out

create nonclustered index contract_idx on #contracts(dck)
create nonclustered index contract_idx1 on #contracts(pin)
create nonclustered index contract_idx2 on #contracts(depid)
create nonclustered index contract_idx3 on #contracts(ag_id)
create nonclustered index contract_idx4 on #contracts(sv_ag_id)
create nonclustered index contract_idx5 on #contracts(pin_master)
create nonclustered index contract_idx6 on #contracts(dck_master)

--фильтр по отделу
if isnull(@deps,'')<>''
delete c from #contracts c with (nolock,index(contract_idx2))
where not c.depid in (select s.[value] from string_split(@deps,',') s)

--фильтр по клиенту
if isnull(@pins,'')<>''
delete c from #contracts c with (nolock,index(contract_idx1))
where not c.pin in (select s.[value] from string_split(@pins,',') s)

--фильтр по договору
if isnull(@dcks,'')<>''
delete c from #contracts c with (nolock,index(contract_idx))
where not c.dck in (select s.[value] from string_split(@dcks,',') s)

--фильтр по агентам
if isnull(@agents,'')<>''
delete c from #contracts c with (nolock,index(contract_idx3))
where not c.ag_id in (select s.[value] from string_split(@agents,',') s)

--фильтр по суперам
if isnull(@supers,'')<>''
delete c from #contracts c with (nolock,index(contract_idx4))
where not c.sv_ag_id in (select s.[value] from string_split(@supers,',') s)

--фильтр по типам договоров
if isnull(@tips,'')<>''
delete c from #contracts c 
where not c.contrtip in (select s.[value] from string_split(@tips,',') s)

--фильтр по организациям
if isnull(@our_ids,'')<>''
delete c from #contracts c 
where not c.our_id in (select s.[value] from string_split(@our_ids,',') s)

--фильтр по сетям клиентов
if isnull(@pin_masters,'')<>''
delete c from #contracts c with (nolock,index(contract_idx5))
where not c.pin_master in (select s.[value] from string_split(@pin_masters,',') s)

--фильтр по сетям договоров
if isnull(@dck_masters,'')<>''
delete c from #contracts c with (nolock,index(contract_idx6))
where not c.dck_master in (select s.[value] from string_split(@dck_masters,',') s)

--учитываем текущие оплаты и отгрузки
if @nd=dbo.today()
begin
	update x set x.debt=x.debt-y.pl
	from #contracts x 
	inner join (select b_id, sum(plata) pl from dbo.kassa1 where nd=@nd group by b_id) y on x.pin=y.b_id
	
	update x set x.debt=x.debt+y.ot
	from #contracts x 
	inner join (select b_id, sum(sp) ot from dbo.nc where nd=@nd group by b_id) y on x.pin=y.b_id
  
  update x set x.overdue=x.overdue+y.ot, x.deep=x.deep+iif(y.ot>0,1,0)
	from #contracts x 
	inner join (select b_id, sum(sp-fact+izmen) ot from dbo.nc where dateadd(day,srok+1,nd)=@nd group by b_id) y on x.pin=y.b_id
end

select * from (
select isnull(sl.list,'') [stage], isnull(w.work_id,-1) [work_id], c.*,
			 cast(iif(exists(select 1 from tax.work_det a join tax.works b on b.work_id=a.work_id where a.dt=dbo.today() and a.op=@op and b.dck=c.dck and a.isdel=0 and b.work_closed=0),1,0) as bit) [viewed], 
       isnull((select top 1 convert(varchar,a.dt,104) from tax.work_det a join tax.works b on b.work_id=a.work_id where b.dck=c.dck and a.isdel=0 and b.work_closed=0 order by cast(a.dt as datetime) desc),'') [last_date],
       isnull((select top 1 a.remark from tax.work_det a join tax.works b on b.work_id=a.work_id where b.dck=c.dck and a.isdel=0 and b.work_closed=0 order by cast(a.dt as datetime) desc),'') [last_remark]
from #contracts c 
left join (select * from tax.works a where a.work_closed=0) w on w.dck=c.dck
left join tax.stage_list sl on sl.id=w.stage_id) x
order by [viewed] desc,[stage],client_name

if object_id('tempdb..#contracts') is not null drop table #contracts
set nocount off
end