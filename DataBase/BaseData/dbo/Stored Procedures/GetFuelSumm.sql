CREATE PROCEDURE dbo.GetFuelSumm
@vehid int,
@dt1 datetime,
@dt2 datetime,
@sum decimal(10,2) out
AS
BEGIN
set nocount on
declare @cardnom varchar(25)
declare @tdt datetime 
declare @dt datetime

select * into #tCardsLog from (
select CardNom, nd, isnull(ndret,@dt2) ndret
from FCardsLog 
where idvehicle=@vehid
			and Org=14
      and (((nd between @dt1 and @dt2) or nd <= @dt1)
      and isnull(ndret,@dt2)<=@dt2)
group by CardNom, nd, ndret
union 
select CardNom, nd, isnull(ndret,@dt2)
from FCards 
where idvehicle=@vehid
			and Org=14
      and (((nd between @dt1 and @dt2) or nd <= @dt1)
      and isnull(vehicleend,@dt2)<=@dt2)
group by CardNom, nd, ndret
union 
select CardNom, vehiclebeg, isnull(vehicleend,@dt2)
from FCards 
where idvehicle=@vehid
			and Org=14
      and (((vehiclebeg between @dt1 and @dt2) or vehiclebeg <= @dt1)
      and isnull(vehicleend,@dt2)<=@dt2)
group by CardNom, vehiclebeg, vehicleend
union 
select CardNom, vehiclebeg, isnull(vehicleend,@dt2)
from FCardsLog 
where idvehicle=@vehid
			and Org=14
      and (((vehiclebeg between @dt1 and @dt2) or vehiclebeg <= @dt1)
      and isnull(vehicleend,@dt2)<=@dt2)
group by CardNom, vehiclebeg, vehicleend) x

create table #CardsPeriod(nd datetime, cardnom varchar(25))

declare cur cursor for 
select cardnom, nd, ndret 
from #tCardsLog 
order by nd

open cur 

fetch next from cur into @cardnom, @dt, @tdt
while @@fetch_status=0
begin
	if datediff(day,@dt,@dt1)>0 set @dt=@dt1
  if datediff(day,@tdt,@dt2)<0 set @tdt=@dt2
	
  while (@dt<=@tdt)
  begin
  	if not exists(select 1 from #CardsPeriod where nd=@dt)
    	insert into #CardsPeriod 
      values(@dt,@cardnom)
    
    set @dt=dateadd(day,1,@dt) 
  end 
  
  fetch next from cur into @cardnom, @dt, @tdt
end

close cur
deallocate cur

drop table #tCardsLog

alter table #CardsPeriod add SumFuel decimal(10,2) not null default 0

update #CardsPeriod set SumFuel=isnull((select sum(isnull(summa,0)) from FFuelNew f where f.cardnum=cardnom and datediff(day,f.nd,#CardsPeriod.nd)=0),0)

set @sum=isnull((select sum(SumFuel) from #CardsPeriod),0)

drop table #CardsPeriod
set nocount off
END