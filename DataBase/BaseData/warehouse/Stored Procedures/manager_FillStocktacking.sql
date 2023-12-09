CREATE PROCEDURE warehouse.manager_FillStocktacking
@plid int,
@isDiscard bit,
@op int,
@msg varchar(200) output
as
begin
set @msg=''
insert into warehouse.stocktaking(plID,op)
select p.plid,@op
from dbo.skladplace p
where p.plid=iif(@plid=-1,p.plid,@plid)

if object_id('tempdb..#stocks') is not null drop table #stocks
create table #stocks (stocktakingID int, plID int)
insert into #stocks
select s.stID, s.plID
from warehouse.stocktaking s 
left join warehouse.stocktaking_detail d on d.stocktakingID<>s.stID

insert into warehouse.stocktaking_detail(stocktakingID,hitag,sklad,qty,mass,cost)
select #stocks.stocktakingID,v.hitag,v.sklad,sum(v.morn-v.sell+v.isprav-v.remov-v.bad), 
			 sum(iif(n.flgWeight=1,v.weight,n.netto)*(v.morn-v.sell+v.isprav-v.remov-v.bad)),
       sum(v.cost*(v.morn-v.sell+v.isprav-v.remov-v.bad))
from dbo.tdvi v
join dbo.nomen n on n.hitag=v.hitag
join dbo.skladlist s on s.skladno=v.sklad
join dbo.skladgroups g on g.skg=s.skg
join #stocks on #stocks.plID=g.plid
where v.morn-v.sell+v.isprav-v.remov-v.bad>0
			and s.discard=iif(@isDiscard=1,s.discard,0)
      and s.discount=iif(@isDiscard=1,s.discount,0)
      and s.equipment=0
group by #stocks.stocktakingID,#stocks.plID,v.hitag,v.sklad
order by #stocks.plID,v.sklad,v.hitag
set @msg='Создано ' + cast((select count(stocktakingID) from #stocks) as varchar) + ' ведомостей.'
if object_id('tempdb..#stocks') is not null drop table #stocks
end