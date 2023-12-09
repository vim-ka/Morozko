CREATE FUNCTION NearLogistic.get_marsh_string (@mhid int, @casher_id int)
RETURNS varchar(max)
as
begin
declare @res varchar(max), @pointA varchar(500), @pointB varchar(3000)

select @res= 'Транспортные услуги по перевозке продукции $ #'+cast(m.marsh as varchar)+' от '+format(m.nd,'dd.MM.yyyy')+', водитель: '
						 +isnull(d.Fio,'<@водитель>')+' автомобиль: '+isnull(v.model+' г/н '+v.regnom,'<@автомобиль>')
from dbo.marsh m 
left join dbo.vehicle v on v.v_id=m.v_id
left join dbo.drivers d on d.drid=m.drid
where m.mhid=@mhid

select @pointA=isnull(r.place,'<..>')
from dbo.marsh m
join nearlogistic.marshrequests_points p on m.point_id=p.point_id
join dbo.regions r on r.reg_id=p.reg_id
where m.mhid=@mhid
/*
set @pointB=isnull((
select top 1 isnull(r.place,'<..>')
from nearlogistic.marshrequestsdet d
join nearlogistic.marshrequests_points p on p.point_id=d.point_id 
join dbo.regions r on r.reg_id=p.reg_id
where d.action_id=6 and
		  d.mrfid in (select top 1 f.mrfid from nearlogistic.marshrequests_free f 
								 join nearlogistic.marshrequests mr on mr.reqid=f.mrfid 
								 join nearlogistic.marshrequestsdet t on t.mrfid=f.mrfid
								 where f.mhid=@mhid and f.pin=@casher_id and t.action_id=6                 			 
								 order by mr.reqorder desc)
),'<..>')
*/

set @pointB=stuff((
select N'-'+x.place from (
select distinct r.place
from nearlogistic.marshrequestsdet t
join nearlogistic.marshrequests mr on mr.reqid=t.mrfid 
join nearlogistic.marshrequests_points p on p.point_id=t.point_id 
join dbo.regions r on r.reg_id=p.reg_id
where mr.mhid=@mhid and mr.pinto=@casher_id and t.action_id=6
) x
for xml path(''), type).value('.','varchar(max)'),1,1,'')

if @pointB is null
set @pointB=isnull((
select top 1 isnull(r.place,'<..>')
from nearlogistic.marshrequests mr
join dbo.def d on d.pin=mr.pinto
join dbo.regions r on r.reg_id=d.reg_id
where mr.mhid=@mhid and mr.reqtype=0
order by mr.reqorder desc
),'<..>')

set @pointB=isnull(@pointB,'<..>')
set @pointA=isnull(@pointA,'<..>')

set @res=replace(@res,'$',@pointA+'-'+@pointB+'-'+@pointA)
return @res
end