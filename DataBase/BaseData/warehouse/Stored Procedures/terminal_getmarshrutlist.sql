CREATE procedure warehouse.terminal_getmarshrutlist
@skladlist nvarchar(1000), @nd datetime, @type int
as
begin
set nocount on
if object_id('tempdb..#sklad') is not null drop table #sklad
if object_id('tempdb..#terminal_marsh') is not null drop table #terminal_marsh
create table #terminal_marsh (row_id int not null, marsh_name nvarchar(5), time_arrival nvarchar(5), 
			 rows_done int not null default 0, rows_all int not null default 0, mas_done decimal(15,2) default 0, mas_all decimal(15,2) not null default 0,
       ord int, done int not null default 0, done_filter bit not null default 0)
create table #sklad (sklad int not null, region nvarchar(5), reg_id int not null)

create nonclustered index sklad_idx on #sklad(sklad)

insert into #sklad
select s.skladno, r.sregname, r.sregionid
from dbo.skladlist s
join string_split(@skladlist, ',') ss on ss.value=s.skladno or isnull(@skladlist,'')=''
left join dbo.skladgroups g on g.skg=s.skg
left join warehouse.skladreg r on r.sregionid=g.srid

if @type=0 --набор товара
begin
  insert into #terminal_marsh(row_id,marsh_name,time_arrival,rows_done,rows_all,mas_done,mas_all,done,done_filter,ord)        
  select z.*, 
         iif(z.done=100,1,0), 
         row_number() over(order by --iif(z.done=100,1,0),
         														iif(z.row_id>300000,0,1), 
                                    iif(z.time_arrival is null,1,0),
                                    cast(convert(varchar,dateadd(day,iif(time_arrival like '0%',1,0),getdate()),104)+' '+time_arrival+':00' as datetime),
                                    len(marsh_name),marsh_name) [ord]
  from (
  select x.*,
         iif(row_done=row_all,100,iif(row_all>0 and mas_all>0,round(iif(row_done*1.0/row_all<mas_done*1.0/mas_all,row_done*1.0/row_all,mas_done*1.0/mas_all)*100,0),0)) [done]
  from (
  select iif(c.mhid=0,s.reg_id,c.mhid) [row_id], iif(c.mhid=0,s.region,cast(m.marsh as varchar)) [marsh_name],
         --iif(c.mhid in (0,-99) or m.selfship=1 or len(m.timeplan)<5 or m.timeplan='0','00:00',left(iif(datediff(hour,convert(varchar,iif(len(m.timeplan)<5,'00:00:01',m.timeplan),108),'10:00:00')>0 and isnull(m.timeplan,'') not like '0%','0','')+convert(varchar,iif(len(m.timeplan)<5,'00:00:01',m.timeplan),108),5)) 
         iif(c.mhid in (0,-99) or m.selfship=1 or len(m.timeplan)<5 or m.timeplan='0',
       		 	 null,
           	 left(iif(charindex(':',m.timeplan)=2,'0','')+m.timeplan,5)) [time_arrival],
         sum(iif(z.done=1,1,0)) [row_done], count(z.nzid) [row_all], 
         sum(iif(n.flgweight=1,iif(z.done=1 and id>0,z.curweight,0),iif(z.done=1 and id>0,z.zakaz*n.brutto,0))) [mas_done], isnull(sum(iif(n.flgweight=1,z.curweight,z.zakaz*n.brutto)),0) [mas_all]              
  from dbo.nvzakaz z
  join dbo.nomen n on n.hitag=z.hitag
  join #sklad s on s.sklad=z.skladno
  join dbo.nc c on c.datnom=z.datnom
  left join dbo.marsh m on m.mhid=c.mhid 
  where z.nd=@nd
  group by iif(c.mhid=0,s.reg_id,c.mhid), iif(c.mhid=0,s.region,cast(m.marsh as varchar)), 
           iif(c.mhid in (0,-99) or m.selfship=1 or len(m.timeplan)<5 or m.timeplan='0',
       		 null,
           left(iif(charindex(':',m.timeplan)=2,'0','')+m.timeplan,5))
           ) x
  ) z
end 

select m.*,isnull(gs.sReg_ID,'') [regs] 
from #terminal_marsh m
left join nearlogistic.getregsstring(@nd) gs on gs.mhid=m.row_id

--select * from #sklad
if object_id('tempdb..#terminal_marsh') is not null drop table #terminal_marsh
if object_id('tempdb..#sklad') is not null drop table #sklad
set nocount off
end