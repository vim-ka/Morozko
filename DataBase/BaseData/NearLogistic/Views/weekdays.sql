
create view NearLogistic.weekdays as
select 0 [id], 'ежедневно' [day]
union all select 1, 'понедельник'
union all select 2, 'вторник'
union all select 3, 'среда'
union all select 4, 'четверг'
union all select 5, 'пятница'
union all select 6, 'суббота'
union all select 7, 'воскресенье'