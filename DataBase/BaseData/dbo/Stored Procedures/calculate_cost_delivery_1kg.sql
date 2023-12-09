CREATE procedure dbo.calculate_cost_delivery_1kg
@ncom int
as
begin
set nocount on
declare @marshid int
declare @cost decimal(15,4)
declare @cost1kg decimal(15,4)
declare @mas decimal(15,4)
declare @mas_all decimal(15,4)

select @marshid=iif(c.summacost>0,c.dlmarshid,0), 
			 @cost=iif(c.summacost>0,c.dlmarshcost,0)
from dbo.comman c where c.ncom=@ncom

if @marshid=0 and @cost=0 set @cost1kg=0
else
if @marshid=-1
begin
--заполнена стоимость доставки
	set @cost1kg=isnull((
  	select @cost / sum(iif(n.flgweight=1,i.weight,i.kol*n.brutto))
  	from dbo.inpdet i
  	join dbo.nomen n on n.hitag=i.hitag
  	where i.ncom=@ncom),0)
end
else
begin
--заполнен маршрут
  set @mas=isnull((
    select sum(iif(n.flgweight=1,i.weight*i.kol,i.kol*n.brutto))
    from dbo.inpdet i
    join dbo.nomen n on n.hitag=i.hitag
    where i.ncom=@ncom),0)
  set @mas_all=isnull((
    select sum(iif(n.flgweight=1,i.weight*i.kol,i.kol*n.brutto))
    from dbo.inpdet i
    join dbo.comman c on c.ncom=i.ncom
    join dbo.nomen n on n.hitag=i.hitag
    where c.dlmarshid=@marshid),0)
	set @cost=isnull((
    select sum(b.ForPay)
    from db_farlogistic.dlgroupbill b
    where b.marshid=@marshid and b.casherid=16256 and b.DepID=8),0) 
  set @cost=iif(@mas_all=0,0,@cost*(@mas / @mas_all))
  set @cost1kg=iif(@mas=0,0,@cost / @mas)
end
if @cost1kg>0
update i set i.cost_delivery_1kg=@cost1kg
from dbo.inpdet i
where i.ncom=@ncom
set nocount off
end