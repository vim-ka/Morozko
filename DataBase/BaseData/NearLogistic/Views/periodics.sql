create view NearLogistic.periodics as 
select 0 [id], 'еженедельно' [periodic]
union all select 1, 'каждую четную неделю'
union all select 2, 'каждую нечетную неделю'
union all select 3, 'ежемесячно'
union all select 4, 'каждый четный месяц'
union all select 5, 'каждый нечетный месяц'
union all select 6, 'ежегодно'