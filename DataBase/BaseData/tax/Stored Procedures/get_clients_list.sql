CREATE procedure tax.get_clients_list
@pin int
as
begin
	set nocount on
  if object_id('tempdb..#res') is not null drop table #res
  create table #res (pin int, pin_name varchar(200), pin_addr varchar(200), pin_master int, 
  									 deep int not null default 0, debt money not null default 0, overdue money not null default 0)
  create nonclustered index res_idx on #res(pin)
  insert into #res(pin,pin_name,pin_addr,pin_master)
  select pin,'['+cast(pin as varchar)+'] '+brname,dstaddr,master from dbo.def where master=@pin or pin=@pin group by pin,brname,dstaddr,master
  update x set x.deep=isnull(y.deep,0), x.debt=isnull(y.debt,0), x.overdue=isnull(y.overdue,0)
  from #res x 
  join (
    select dc.pin, max(s.deep) [deep], sum(s.debt) [debt], sum(s.overdue) [overdue] 
    from dbo.dailysaldodck s
    join dbo.defcontract dc on dc.dck=s.dck
    join #res on #res.pin=dc.pin
    where s.nd=dateadd(day,-1,dbo.today())
    group by dc.pin) y on y.pin=x.pin
  select *,cast(iif(not exists(select 1 from tax.job a where a.closed=0 and a.issingle=1 and a.pin=#res.pin) and #res.pin_master>0,0,1) as bit) [isSingle] from #res order by pin_name
  if object_id('tempdb..#res') is not null drop table #res
  set nocount off
end