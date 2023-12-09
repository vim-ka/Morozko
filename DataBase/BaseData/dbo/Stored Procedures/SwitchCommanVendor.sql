CREATE PROCEDURE dbo.SwitchCommanVendor
@ncoms varchar(max), --коды комиссий через запятую
@dck int, --код договора поставщика, если 0 то не изменяем
@ncod int --код поставщика, если 0 то не изменяем
as
begin
if object_id('tempdb..#ncoms') is not null drop table #ncoms
create table #ncoms (ncom int)
create nonclustered index nocm_idx on #ncoms(ncom)
insert into #ncoms 
select value from string_split(@ncoms,',')

update c set c.ncod=iif(@ncod=0,c.ncod,@ncod),
						 c.dck=iif(@dck=0,c.dck,@dck)
from dbo.comman c 
inner join #ncoms n on c.ncom=n.ncom

update i set i.ncod=iif(@ncod=0,i.ncod,@ncod),
						 i.dck=iif(@dck=0,i.dck,@dck)
from dbo.izmen i 
inner join #ncoms n on i.ncom=n.ncom 

alter table dbo.Kassa1 disable trigger trg_kassa1_u
update k set k.ncod=iif(@ncod=0,k.ncod,@ncod),
						 k.dck=iif(@dck=0,k.dck,@dck)
from dbo.kassa1 k 
inner join #ncoms n on k.nnak=n.ncom
alter table dbo.Kassa1 enable trigger trg_kassa1_u

update t set t.ncod=iif(@ncod=0,t.ncod,@ncod),
						 t.dck=iif(@dck=0,t.dck,@dck)
from dbo.tdvi t 
inner join #ncoms n on t.ncom=n.ncom

update s set s.ncod=iif(@ncod=0,s.ncod,@ncod),
						 s.dck=iif(@dck=0,s.dck,@dck)
from dbo.visual s 
inner join #ncoms n on s.ncom=n.ncom

if object_id('tempdb..#ncoms') is not null drop table #ncoms
end