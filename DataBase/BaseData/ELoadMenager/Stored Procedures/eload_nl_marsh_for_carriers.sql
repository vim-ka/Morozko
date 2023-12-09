create procedure eLoadmenager.eload_nl_marsh_for_carriers
@nd1 datetime, @nd2 datetime, @crid int
as
begin
set nocount on
select convert(varchar,m.nd,104) [дата], m.marsh [маршрут], 
			 d.fio+''+isnull(', '+d.DriverDoc,'') [водитель],
       iif(m.scannd is null,'',convert(varchar,m.scannd,104)) [дата_сканирования], m.listno [ведомость]
from dbo.marsh m
join dbo.vehicle v on v.v_id=m.v_id 
join dbo.drivers d on d.drid=m.drid
where v.crid=@crid and m.nd between @nd1 and @nd2
order by m.nd, m.marsh, d.fio
set nocount off
end