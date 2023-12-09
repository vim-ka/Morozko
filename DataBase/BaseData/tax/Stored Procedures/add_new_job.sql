CREATE procedure tax.add_new_job
@pin int,
@issingle bit,
@op int, 
@type int,
@remark varchar(500),
@job_id int output
as
begin
if object_id('tempdb..#dck_list') is not null drop table #dck_list
create table #dck_list (dck int)
create nonclustered index dck_list_idx on #dck_list(dck)
if @issingle=1 
begin
	insert into #dck_list
  select dck from dbo.defcontract where pin=@pin
end
else
begin	
	declare @master_pin int
  select @master_pin=iif(master>0,master,pin) from dbo.def where pin=@pin
	insert into #dck_list
  select dck from dbo.defcontract dc 
  join dbo.def d on d.pin=dc.pin 
  where iif(d.master>0,d.master,d.pin)=@master_pin
end
if @job_id<=0
begin
	insert into tax.job(pin,issingle)
  select @pin,@issingle
  select @job_id=@@identity
end
if @job_id>0
begin
	insert into tax.job_detail(job_id,job_type,op,deep,debt,overdue,remark)
	select @job_id,@type,@op,isnull(max(s.deep),0),isnull(sum(s.debt),0),isnull(sum(s.overdue),0),@remark
	from #dck_list l
	left join dbo.dailysaldodck s on l.dck=s.dck
	where s.nd=dateadd(day,-1,dbo.today())
end
if object_id('tempdb..#dck_list') is not null drop table #dck_list   
end