CREATE procedure dbo.calculate_cost_delivery_1kg_day
@nd datetime
as
begin
set nocount on
declare @ncom int
declare cur cursor for
select c.ncom from dbo.comman c
where c.date between dateadd(day,-7,@nd) and @nd 
			and (c.dlmarshid>0 or c.dlmarshcost>0)

open cur
fetch next from cur into @ncom
while @@fetch_status=0
begin
	exec dbo.calculate_cost_delivery_1kg @ncom
	fetch next from cur into @ncom
end
close cur
deallocate cur 

set nocount off 
end