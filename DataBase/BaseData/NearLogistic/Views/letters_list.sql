
CREATE view NearLogistic.letters_list
as
select row_number() over(order by len(x.value), x.value) [id], cast(x.value as nvarchar(3)) [list] from (
select value from string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\')
union all
select a.value+b.value
from string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\') a
join string_split('А\Б\Г\Д\Ж\З\И\К\М\О\П\Р\С\У\Ф\Х\Ч\Ш\Ю\Я','\') b on 1=1
where a.value<>b.value
) x
union all 
select 0,'--'