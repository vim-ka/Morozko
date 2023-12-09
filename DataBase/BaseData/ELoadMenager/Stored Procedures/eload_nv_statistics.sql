create procedure eloadmenager.eload_nv_statistics
@nd datetime, @sklad varchar(500), @marsh varchar(500), @nakl varchar(500) 
as
begin
if object_id('tempdb..#skl') is not null drop table #skl
if object_id('tempdb..#mar') is not null drop table #mar
if object_id('tempdb..#nak') is not null drop table #nak

create table #skl(sklad int)
create table #mar(marsh int)
create table #nak(nnak int)

if @sklad='' insert into #skl select skladno from dbo.skladlist 
else insert into #skl select value from string_split(@sklad,',')

if @marsh='' insert into #mar select num from nearlogistic.get_range(0,999)   
else insert into #mar select value from string_split(@marsh,',')

if @nakl='' insert into #nak select num from nearlogistic.get_range(0,9999)   
else insert into #nak select value from string_split(@nakl,',')

select count(distinct v.nvid) [Количество строк]
from dbo.nc c 
join dbo.nv v with(nolock, index(nv_datnom_idx)) on v.datnom=c.datnom
join #skl on #skl.sklad=v.sklad
join #mar on #mar.marsh=c.marsh
join #nak on #nak.nnak=c.datnom%10000
where c.nd=@nd

if object_id('tempdb..#skl') is not null drop table #skl
if object_id('tempdb..#mar') is not null drop table #mar
if object_id('tempdb..#nak') is not null drop table #nak
end